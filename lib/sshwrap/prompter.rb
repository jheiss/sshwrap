class SSHwrap::Prompter
  attr_reader :passwords
  def initialize
    @mutex = Mutex.new
    @passwords = {}
  end
  def prompt(prompt, echo=false)
    @mutex.synchronize do
      if !@passwords[prompt]
        @passwords[prompt] = ask(prompt) { |q| q.echo = echo }
      end
    end
    @passwords[prompt]
  end
end
