# Nexop

The *Nexop* library provides an implementation of the SSH packet- and
transport-layer. The project does not provide a ready-to-use SSH-daemon! It
enables you to integrate SSH encryption abilities into existing applications.
With an open service architecture you are able to run any services (even
self-implemented) on the top of SSH.

There are already some services available, which are maintained in separate
projects:

  * [nexop-userauth](https://github.com/drobin/nexop-userauth) implements the
    `ssh-userauth` service.

## Usage

Here you need an introduction into the usage of the library.

## Installation

Add this line to your application's Gemfile:

    gem 'nexop'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nexop

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
