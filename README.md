# Lurker

The new de-facto for API testing your Rails application.
Works on Rails 3.2, 4.0, 4.1 & Ruby 1.9.3, 2.0.0, 2.1.1.

[![Gem Version][GV img]][Gem Version]
[![Build Status][BS img]][Build Status]
[![Dependency Status][DS img]][Dependency Status]
[![githalytics.com alpha](https://cruel-carlota.pagodabox.com/87ced56265849ad6386c2ba0a78f8038 "githalytics.com")](http://githalytics.com/razum2um/lurker)

## Installation

Add this line to your application's Gemfile:

    gem 'lurker'

Add to `test_helper.rb` or `spec_helper.rb`:

    require 'lurker/spec_helper'

## Usage

Wrap your intergation test code, which does request like this

    Lurker::Spy.on do
      get "/api/v1/users.json"
    end

And run the specs and commit your schemas. That's all, easy!

## RSpec usage

Write your RSpec [controller][rspec_controller_spec] or [request][rspec_request_spec] specs as usual,
but add `:lurker` mark (like documented [controller example][controler_spec_example] or [request spec example][request_spec_example]).

    it "lists users", :lurker do
      get "/api/v1/users.json"
    end

## Minitest usage

You can use [minitest-around][minitest_around] to wrap your test classes like this:

    class DestroyRepoTest < ActionDispatch::IntegrationTest
      def around(&block)
        Lurker::Spy.on(&block)
      end
    end

## Schemas

Please, commit your files under `Rails.root/lurker` directory.
Feel free to edit them according to [json-schema][json_schema] standart.
It can be very strict and flexible if you wish: see [example][json_schema_example],
but scaffolded schemas are pretty good by default.

    A  lurker/ExampleApp.service.yml
    A  lurker/api/v1/users-GET.json.yml
    A  lurker/api/v1/users/__user_id/repos-GET.json.yml

I also advise you to look on [Understanding JSON Schema][json_schema_book] book,
it is up-to-date with draft4 and contains lot's of examples.

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

Let's run your `rails s` and visit [http://localhost:3000/lurker/](http://localhost:3000/lurker/)
(or see [demo][demo_app2] for example)

Now, you can test your API on-line (for real)

## [Demo application][demo_app3]

You can clone the repo & run `rake build_example_docs && cd tmp/lurker_app && bin/rails s`
to get your running demo.

Lurker supports multiple domains (usually `staging` and `production`) and can be deployed
statically everywhere as well as be served by current `Rails` instance.

For example:

- [Github Pages][demo_app3] is deployed statically; no api endpoint
- [Custom domain][demo_app2] html deployed under nginx; passenger serves demo api production endpoint
- [Heroku][demo_app] html is served by unicorn as well as staging api endpoint in `Sandbox` mode

## Features

- [Autoscaffolding for non-covered API endpoints][controler_spec_example]
- [Autotesting for covered endpoint once written][failed_spec_example] (both request & response!)
- [Pretty HTML documentation based on your schemas][html_generation_example]
- [Pretty submit form to test API endpoints (live) based on schemas][demo_live] (enter a name & press "Submit")
- [Handling URLs with dynamic segments][nested_controller_spec_example] (such as `api/v1/:user_id/repos`)
- [JSON-Schema partials][partial_example], also in YAML format ([demo][partial_example_demo])
- [Generation PDF documentation][pdf_example]
- [Multiple docs for many usecases][suffixes_example] (e.g `:lurker => '...'`)
- ERB support inside `.json.yml.erb`
- HTTP-Auth authorization for your online docs
- Separate API-services generated within one test suite
- Capistrano integration
- JSON-Schema draft-v4 support
- Static site deploy and milti-domain support
- Builtin Rack middlware `Lurker::Server.to_rack` serves cached digested assets
- [RSpec][failed_spec_example] & [Minitest][minitest_example] support

## Token authentication with sandbox

`Lurker::Sandbox` allows you to test services with token authentication:

    # make sure it's not production!
    # e.g. config/environtents/staging.rb
    config.middleware.use Lurker::Sandbox

E.g. demo application on Heroku runs with it: when creating, updating repos or users
ids getting increased, but if you look into GET #index,
new items are NOT showing up. **This is NOT a bug!** - sequences in postgres
are increasing notwithstanding ROLLBACK is called. As such:

- run all your specs with **the same** testing token
- ensure the same token to be accepted on your demo application
- insert `Lurker::Sandbox` and the recorded examples should be ok to submit again

## Contributions

[![Code Climate][CC img]][Code Climate]
[![Coverage Status][CS img]][Coverage Status]
[![Inline docs](http://inch-pages.github.io/github/razum2um/lurker.png)](http://inch-pages.github.io/github/razum2um/lurker)
[![Stories in Ready](https://badge.waffle.io/razum2um/lurker.png?label=ready&title=Ready&_=1)][waffle]

I try to use [Waffle][waffle] to develop this gem, if you want to help:

- look on "Ready" section
- drag an issue to "In Progress" and assign to yourself
- have fun!

**NOTE:** to get new version of bundled `bootstrap` or update js/css,
don't touch files under `lib/lurker/templates/public` - they are autogenerated
and copied to static generated site while `bin/lurker convert`

    rake assets:precompile # to build them

Don't commit `lib/lurker/templates/public/**/*` to avoid conflicts.

**NOTE:** if you write features keep in mind to generate different files with aruba,
because they are kept in `lurker_app` directory to be deployed as a demo. Please, write
features in a way to generate **new** relevant `lurker/**/*.json.yml` files

To run cucumber in a clean `lurker` & `html` directories run:

    CLEAN=1 cucumber features

**NOTE:** template partial `submit_form.html.erb` and it's partials is a big `jsx` script for `React`
so there are `<label htmlFor` instead of `<label for>` and `<div className` instead of `<div class`

## Acknoledgements

Sponsored by [Evil Martians][evil_martians], thanks!

This gem is quite opinionated and relies on rails - if you're
interested in anything else, please take a look at [api_taster][api_taster] or [fdoc][fdoc],
This gem is heavily inspirated by them. Thanks, @square & @fredwu

Also thanks to

- [Andrey Deryabin][aderyabin] for advice
- [React.js][reactjs] for two-way binding
- [highlight.js][hljs] for syntax highlighting

[aderyabin]: https://twitter.com/aderyabin
[hljs]: http://highlightjs.org/
[waffle]: https://waffle.io/razum2um/lurker
[gh_api]: https://developer.github.com/v3/meta/
[api_taster]: https://github.com/fredwu/api_taster
[reactjs]: http://facebook.github.io/react/
[fdoc]: https://github.com/square/fdoc
[json_schema]: http://json-schema.org/
[json_schema_example]: http://json-schema.org/example2.html
[json_schema_book]: http://spacetelescope.github.io/understanding-json-schema/
[evil_martians]: http://evilmartians.com/
[rspec_controller_spec]: https://www.relishapp.com/rspec/rspec-rails/docs/controller-specs
[rspec_request_spec]: https://www.relishapp.com/rspec/rspec-rails/docs/request-specs/request-spec
[minitest_around]: https://github.com/splattael/minitest-around

[failed_spec_example]: https://www.relishapp.com/razum2um/lurker/docs/test-endpoint
[controler_spec_example]: https://www.relishapp.com/razum2um/lurker/docs/controller-schema-scaffolding
[nested_controller_spec_example]: https://www.relishapp.com/razum2um/lurker/docs/controller-nested-schema-scaffolding
[request_spec_example]: https://www.relishapp.com/razum2um/lurker/docs/request-schema-scaffolding
[html_generation_example]: https://www.relishapp.com/razum2um/lurker/docs/html-generation
[partial_example]: https://www.relishapp.com/razum2um/lurker/docs/partials
[suffixes_example]: https://www.relishapp.com/razum2um/lurker/docs/request-schema-suffixes
[minitest_example]: https://www.relishapp.com/razum2um/lurker/docs/minitest

[demo_app]: http://lurker-app.herokuapp.com
[demo_app2]: http://lurker.razum2um.me
[demo_app3]: http://razum2um.github.io/lurker/
[demo_live]: http://lurker.razum2um.me/lurker/api/v1/users-POST.html
[pdf_example]: http://razum2um.github.io/lurker/Lurker%20Demo%20Application.pdf
[partial_example_demo]: http://razum2um.github.io/lurker/api/v1/users/__user_id/repos-POST.html

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
