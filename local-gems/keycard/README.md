[![Build Status](https://travis-ci.org/mlibrary/keycard.svg?branch=master)](https://travis-ci.org/mlibrary/keycard?branch=master)
[![Coverage Status](https://coveralls.io/repos/github/mlibrary/keycard/badge.svg?branch=master)](https://coveralls.io/github/mlibrary/keycard?branch=master)

# Keycard

Keycard provides authentication support and user/request information, especially
in Rails applications.

Keycard is designed to give you sound guidelines and integration between
authentication and authorization without constraining your application. It
takes inspiration from [Sorcery](https://github.com/Sorcery/sorcery), but has
four important distinctions:

1. It does not use mixins to configure a "model that can log in".
2. It provides a way to retrieve user and session attributes like directory
   information or IP address-based region, rather than being strictly about
   logging in and out.
3. It only provides one built-in strategy for logins, focused on single sign-on
   scenarios.
4. It offers an optional group implementation for whatever objects your
   application manages as accounts or users.

The ultimate goal is to provide useful tools that integrate easily and simplify
building applications that have clean, well-factored designs. Keycard should
help you focus on solving your application problems, while remaining invisible
-- not magical -- to most of your application.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'keycard'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install keycard

## License

Keycard is licensed under the BSD-3-Clause license. See [LICENSE.md](LICENSE.md).
