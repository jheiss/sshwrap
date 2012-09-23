#
# Test sshwrap command line options
#

require 'test/unit'
require 'open4'
require 'rbconfig'

RUBY = File.join(*RbConfig::CONFIG.values_at("bindir", "ruby_install_name")) +
         RbConfig::CONFIG["EXEEXT"]
LIBDIR = File.join(File.dirname(File.dirname(__FILE__)), 'lib')
SSHWRAP = File.expand_path('../bin/sshwrap', File.dirname(__FILE__))

class SSHwrapOptionTests < Test::Unit::TestCase
  def test_help
    output = nil
    IO.popen("#{RUBY} -I #{LIBDIR} #{SSHWRAP} --help") do |pipe|
      output = pipe.readlines
    end
    # Make sure at least something resembling help output is there
    assert(output.any? {|line| line.include?('Usage: sshwrap [options]')}, 'help output content')
    # Make sure it fits on the screen
    assert(output.all? {|line| line.length <= 80}, 'help output columns')
    assert(output.size <= 23, 'help output lines')
  end
  
  def test_command_arg_required
  end
  def test_command
  end
  
  def test_user_arg_required
  end
  def test_user
  end
  
  def test_ssh_key_arg_required
    output = nil
    error = nil
    status = Open4.popen4("#{RUBY} -I #{LIBDIR} #{SSHWRAP} --ssh-key") do |pid, stdin, stdout, stderr|
      stdin.close
      output = stdout.readlines
      error = stderr.readlines
    end
    assert_equal(1, status.exitstatus, "-ssh-key arg required exitstatus")
    # Make sure the expected lines are there
    assert(error.any? {|line| line.include?('missing argument: --ssh-key')})
  end
  def test_ssh_key_bogus_file
    # error = nil
    # status = Open4.popen4("#{RUBY} -I #{LIBDIR} #{SSHWRAP} --ssh-key bogus") do |pid, stdin, stdout, stderr|
    #   stdin.close
    #   error = stderr.readlines
    # end
    # # Make sure the expected lines are there
    # assert(error.any? {|line| line.include?('Unable to read ssh key from bogus')})
  end
  def test_ssh_key
  end
  
  def test_abort_on_failure
  end
  
  def test_max_workers_arg_required
  end
  def test_max_workers
  end
  
  def test_debug
  end
end

