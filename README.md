# SSHwrap

This provides a wrapper for ssh that execute a command on multiple machines,
optionally in parallel, and handles any sudo prompts that result.

## Installation

Add this line to your application's Gemfile:

    gem 'sshwrap'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sshwrap

## Usage

Usage: sshwrap [options]
  -c, --command, --cmd=CMD Command to run
  -u, --user=USER          SSH as specified user
  -k, --ssh-key=KEY        Use the specified SSH private key
      --abort-on-failure   Abort if connection or command fails with any target
      --max-workers=NUM    Use specified number of parallel connections
      --debug              Enable debugging

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
