require 'net/ssh'
require 'highline/import'

class SSHwrap::Main
  def initialize(options={})
    @mutex = Mutex.new
    @max_workers = options[:max_workers] || 1
    @abort_on_failure = options[:abort_on_failure]
    @user = options[:user] || Etc.getlogin
    @ssh_key = options[:ssh_key]
    @debug = options[:debug]
    @password = nil
  end
  
  def get_password
    @mutex.synchronize do
      if !@password
        @password = ask("Password for #{@user}: ") { |q| q.echo = "x" }
      end
    end
    @password
  end
  
  def ssh_execute(cmd, target)
    exitstatus = nil
    stdout = []
    stderr = []
    
    params = {}
    if @ssh_key
      params[:keys] = [@ssh_key]
    end
    using_password = false
    if @password
      using_password = true
      params[:password] = @password
    end
    
    begin
      Net::SSH.start(target, @user, params) do |ssh|
        puts "Connecting to #{target}" if @debug
        ch = ssh.open_channel do |channel|
          # Now we request a "pty" (i.e. interactive) session so we can send
          # data back and forth if needed.  It WILL NOT WORK without this,
          # and it has to be done before any call to exec.
          channel.request_pty do |ch_pty, success|
            if !success
              raise "Could not obtain pty (interactive ssh session) on #{target}"
            end
          end
          
          channel.exec(cmd) do |ch_exec, success|
            puts "Executing '#{cmd}' on #{target}" if @debug
            # 'success' isn't related to process exit codes or anything, but
            # more about ssh internals.  Not sure why it would fail at such
            # a basic level, but it seems smart to do something about it.
            if !success
              raise "SSH unable to execute command on #{target}"
            end
            
            # on_data is a hook that fires when ssh returns output data.  This
            # is what we've been doing all this for; now we can check to see
            # if it's a password prompt, and interactively return data if so
            # (see request_pty above).
            channel.on_data do |ch_data, data|
              # This is the standard sudo password prompt
              if data =~ /Password:/
                channel.send_data "#{get_password}\n"
              else
                stdout << data unless (data.nil? or data.empty?)
              end
            end
            
            channel.on_extended_data do |ch_onextdata, type, data|
              stderr << data unless (data.nil? or data.empty?)
            end
            
            channel.on_request "exit-status" do |ch_onreq, data|
              exitstatus = data.read_long
            end
          end
        end
        ch.wait
        ssh.loop
      end
    rescue Net::SSH::AuthenticationFailed
      if !using_password
        get_password
        return ssh_execute(cmd, target)
      else
        stderr << "Authentication failed to #{target}"
      end
    rescue Exception => e
      stderr << "SSH connection error: #{e.message}"
    end
    
    [exitstatus, stdout, stderr]
  end
  
  # cmd is a string or array of strings containing the command and arguments
  # targets is an array of remote system hostnames
  def sshwrap(cmd, targets)
    cmdstring = nil
    if cmd.kind_of?(Array)
      cmdstring = cmd.join(' ')
    else
      cmdstring = cmd.to_s
    end
    
    statuses = {}
    
    threads = (1..@max_workers).map do |i|
      Thread.new("worker#{i}") do |tname|
        while true
          target = nil
          @mutex.synchronize do
            target = targets.shift
          end
          if !target
            break
          end
          puts "Thread #{tname} processing target #{target}" if @debug
          
          exitstatus, stdout, stderr = ssh_execute(cmdstring, target)
          statuses[target] = exitstatus
          
          @mutex.synchronize do
            puts '=================================================='
            if !stdout.empty?
              puts "Output from #{target}:"
              puts stdout.join
            end
            if !stderr.empty?
              puts "Error from #{target}:"
              puts stderr.join
            end
            puts "Exit status from #{target}: #{exitstatus}"
          end
          
          if @abort_on_failure && exitstatus != 0
            exit exitstatus
          end
        end
      end
    end
    
    threads.each(&:join)
    
    statuses
  end
end