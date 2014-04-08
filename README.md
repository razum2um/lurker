# Lurker

The new de-facto for API testing your Rails application (Rails 4 compatible, Rails 3 unknown)

[![Gem Version][GV img]][Gem Version]
[![Build Status][BS img]][Build Status]
[![Dependency Status][DS img]][Dependency Status]
[![Code Climate][CC img]][Code Climate]
[![Coverage Status][CS img]][Coverage Status]
[![Inline docs](http://inch-pages.github.io/github/razum2um/lurker.png)](http://inch-pages.github.io/github/razum2um/lurker)
[![githalytics.com alpha](https://cruel-carlota.pagodabox.com/87ced56265849ad6386c2ba0a78f8038 "githalytics.com")](http://githalytics.com/razum2um/lurker)


## Installation

Add this line to your application's Gemfile:

    gem 'lurker'

## Usage

Write your [RSpec][rspec] [controller][rspec_controller_spec] or [request][rspec_request_spec] specs as usual,
but add `:lurker` mark (like documented [controller example][controler_spec_example] or [request spec example][request_spec_example]).

    describe Api::V1::UsersController, :lurker do
      ...

And run the specs. That's all, easy!

Please, commit your files under `Rails.root/lurker` directory.
Feel free to edit them according to [json-schema][json_schema] standart.
It can be very strict and flexible if you wish: see [example][json_schema_example],
but scaffolded schemas are pretty good by default.

    A  lurker/ExampleApp.service.yml
    A  lurker/api/v1/users-GET.json.yml
    A  lurker/api/v1/users/__user_id/repos-GET.json.yml

## Profit!

Now, every test run lurker will look into your requests and [vaditate them][failed_spec_example]
and it fails if your code changes the api!

    Failure/Error: post :create [...]
    Lurker::ValidationError:
      Request
      - The property '#/' contains additional properties ["social_network"] outside of the schema
        when none are allowed in schema file:///.../lurker/api/v1/users-POST.json.yml#
      Response
      - The property '#/user/last_sign_in_at' of type String did not match the following type:
        null in schema file:///.../lurker/api/v1/users-POST.json.yml#

Let's run your `rails s` and visit [http://localhost:3000/lurker/](http://localhost:3000/lurker/) (or see [demo][demo_app])

Now, you can test your API on-line (for real)

## Features

- [Autoscaffolding for non-covered API endpoints][controler_spec_example]
- [Autotesting for covered endpoint once written][failed_spec_example] (both request & response!)
- [Pretty HTML documentation based on your schemas][html_generation_example]
- Pretty submit form to test API endpoints (live) based on schemas
- [Handling URLs with dynamic segments][nested_controller_spec_example] (such as `api/v1/:user_id/repos`)
- Multiple docs for many test cases
- JSON-Schema partials (inline reference to other schemas)
- ERB support inside `.json.yml.erb`
- HTTP-Auth authorization for your online docs
- Separate API-services generated within one test suite
- Capistrano integration
- JSON-Schema draft-v4 support

## Sandbox mode for Live API testing

    # make sure it's not production!
    # e.g. config/environtents/staging.rb
    config.middleware.use Lurker::Sandbox

## Demo application

You can clone the repo & run `rake build_example_docs`.
It will generate testing rails application under `tmp/lurker_app`.
Currently it is deployed [here][demo_app].

## Contributions

To get new version of bundled `bootstrap` or to use debugger in specs run:

    bundle --gemfile Gemfile.local
    export BUNDLE_GEMFILE=$PWD/Gemfile.local

    rake assets:precompile # to build assets
    cucumber some/feature  # to use pry-debugger

## Todo

- More tests
- More docs
- Auto extraction for models into json-schema partials (in responses at least)
- Auto marking of attributes as required if `strong_params` are used
- Sinatra support
- Better Diff expected-schema vs recorded schema
- XML api testing via *.xsd

## Acknoledgements

Sponsored by [Evil Martians][evil_martians], thanks!

This gem is quite opinionated and relies on rails & rspec - if you're
interested in anything else, please take a look at [api_taster][api_taster] or [fdoc][fdoc],
This gem is heavily inspirated by them. Thanks, @square & @fredwu

[rspec]: https://github.com/rspec/rspec-rails
[api_taster]: https://github.com/fredwu/api_taster
[fdoc]: https://github.com/square/fdoc
[rspec_controller_spec]: https://www.relishapp.com/rspec/rspec-rails/docs/controller-specs
[rspec_request_spec]: https://www.relishapp.com/rspec/rspec-rails/docs/request-specs/request-spec
[json_schema]: http://json-schema.org/
[json_schema_example]: http://json-schema.org/example2.html
[failed_spec_example]: https://www.relishapp.com/razum2um/lurker/docs/controller-specs/test-endpoint
[controler_spec_example]: https://www.relishapp.com/razum2um/lurker/docs/controller-specs/schema-scaffolding
[nested_controller_spec_example]: https://www.relishapp.com/razum2um/lurker/docs/controller-specs/nested-schema-scaffolding
[request_spec_example]: https://www.relishapp.com/razum2um/lurker/docs/request-specs/schema-scaffolding
[html_generation_example]: https://www.relishapp.com/razum2um/lurker/docs/docs-generation/html-generation
[evil_martians]: http://evilmartians.com/
[demo_app]: http://lurker-app.herokuapp.com/lurker/

[Gem Version]: https://rubygems.org/gems/lurker
[Build Status]: https://travis-ci.org/razum2um/lurker
[Dependency Status]: https://gemnasium.com/razum2um/lurker
[Code Climate]: https://codeclimate.com/github/razum2um/lurker
[Coverage Status]: https://coveralls.io/r/razum2um/lurker

[GV img]: https://badge.fury.io/rb/lurker.png
[BS img]: https://travis-ci.org/razum2um/lurker.png
[DS img]: https://gemnasium.com/razum2um/lurker.png
[CC img]: https://codeclimate.com/github/razum2um/lurker.png
[CS img]: https://coveralls.io/repos/razum2um/lurker/badge.png?branch=master
