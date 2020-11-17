# Lurker

<img align="right" width="94" height="71" src="https://cdn.rawgit.com/razum2um/lurker/master/lurker-bw.svg">

Generates API schemas, validates code against them and creates a handy web interface for testing the API.
Tested on on Rails 4, 5, 6 and Ruby >= 2.6

[![Gem Version](https://badge.fury.io/rb/lurker.svg)](https://badge.fury.io/rb/lurker)
[![Build Status][BS img]][Build Status]

## Usage

Wrap your integration test code, which does request like this

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

NOTE: If you use `rspec-rails`, it should be required first

    require 'rspec/rails'
    require 'lurker/spec_helper'

## Minitest usage

You can use [minitest-around][minitest_around] to wrap your test classes like this:

    class DestroyRepoTest < ActionDispatch::IntegrationTest
      def around(&block)
        Lurker::Spy.on(&block)
      end
    end

You also can wrap any block with API requests [manually][minitest_example].

## Schemas

Please, commit your files under `Rails.root/lurker` directory.
Feel free to edit them according to [json-schema][json_schema] standard.
It can be very strict and flexible if you wish: see an [example][json_schema_example],
but scaffolded schemas are pretty good by default.

    A  lurker/ExampleApp.service.yml
    A  lurker/api/v1/users-GET.json.yml
    A  lurker/api/v1/users/__user_id/repos-GET.json.yml

I also advise you to look on [Understanding JSON Schema][json_schema_book] book,
it is up-to-date with draft4 and contains lot of examples.

## Profit!

Now, every test run lurker will look into your requests and [validate them][failed_spec_example],
and it fails if your code changes the API!

    Failure/Error: post :create [...]
    Lurker::ValidationError:
      Request
      - The property '#/' contains additional properties ["social_network"] outside of the schema
        when none are allowed in schema file:///.../lurker/api/v1/users-POST.json.yml#
      Response
      - The property '#/user/last_sign_in_at' of type String did not match the following type:
        null in schema file:///.../lurker/api/v1/users-POST.json.yml#

The generation of live-documentation is pretty simple:

    bin/lurker convert           # builds html under `Rails.root/public/lurker` to be served under `/lurker` url
    bin/lurker convert -f pdf    # builds `Rails.root/public/lurker/snake_cased_name.pdf`

For different document root or serving URL prefix use `-o` and `-u` options accordingly.

If you want to provide additional documentation for your API (and you probably should),
you can use separate Markdown files in the schema folder. To generate documentation
stubs for the current schema:

    bin/lurker init_docs         # generate documentation stubs for the current schema


Let's run your `rails s` and visit [http://localhost:3000/lurker/](http://localhost:3000/lurker/)
(or see [demo][demo_app2] for example)

Now, you can test your API on-line (for real)

## [Demo application][demo_app3]

You can run this to get the demo running locally:

    git clone https://github.com/razum2um/lurker.git
    cd lurker
    export BUNDLE_GEMFILE=gemfiles/rails_6.gemfile
    bundle install
    rake build_example_docs
    cd tmp/lurker_app_rails_6
    bin/rails s

Lurker supports multiple domains (usually `staging` and `production`) and can be deployed
statically everywhere as well as be served by the current `Rails` instance.

For example:

- [Github Pages][demo_app3] is deployed statically; no API endpoint
- [Custom domain][demo_app2] static + demo api production endpoint (in `Sandbox` mode)

## Features

- [Autoscaffolding for non-covered API endpoints][controler_spec_example]
- [Autotesting for covered endpoint once written][failed_spec_example] (both request & response!)
- [Pretty HTML documentation based on your schemas][html_generation_example]
- [Pretty submit form to test API endpoints (live) based on schemas][demo_live] (enter a name & press "Submit")
- [Handling URLs with dynamic segments][nested_controller_spec_example] (such as `api/v1/:user_id/repos`)
- [JSON-Schema partials][partial_example], also in YAML format ([demo][partial_example_demo])
- [Generation PDF documentation][pdf_example] (*NOTE*: add `gem 'pdfkit'` to Gemfile)
- [Multiple docs for many usecases][suffixes_example] (e.g `:lurker => '...'`)
- ERB support inside `.json.yml.erb`
- Insert custom content in Markdown into `index.html` (*NOTE*: add `gem 'kramdown'` to Gemfile)
- Syntax highlighting for sample response (add `gem 'execjs'` to Gemfile)
- Separate API-services generated within one test suite
- Capistrano integration
- JSON-Schema draft-v4 support
- Static site deploy and milti-domain support
- Builtin Rack middleware `Lurker::Server.to_rack` serves cached digested assets
- [RSpec][failed_spec_example] & [Minitest][minitest_example] support

## Related gems

- [Swarker](https://github.com/sponomarev/swarker) converts
  Lurker schemas to [Swagger](http://swagger.io) schema

## Token authentication with sandbox

`Lurker::Sandbox` allows you to test services with token authentication:

    # make sure it's not production!
    # e.g. config/environtents/staging.rb
    config.middleware.use Lurker::Sandbox

E.g. demo application on Heroku runs with it: when creating, updating repos or users
ids getting increased, but if you look into GET #index,
new items are NOT showing up. **This is NOT a bug!** Sequences in PostgreSQL
are increasing notwithstanding ROLLBACK is called. As such:

- run all your specs with **the same** testing token
- ensure the same token to be accepted on your demo application
- insert `Lurker::Sandbox` and the recorded examples should be ok to submit again

## Contributions

[![Code Climate][CC img]][Code Climate]
[![Coverage Status][CS img]][Coverage Status]
[![Inline docs](http://inch-pages.github.io/github/razum2um/lurker.png)](http://inch-pages.github.io/github/razum2um/lurker)
[![Stories in Ready](https://badge.waffle.io/razum2um/lurker.png?label=ready&title=Ready&_=1)][waffle]

**NOTE:** to get new version of bundled `bootstrap` or update JS/CSS,
don't touch files under `lib/lurker/templates/public` - they are autogenerated
and copied to static generated site while `bin/lurker convert`

    export BUNDLE_GEMFILE=gemfiles/rails_6.gemfile
    rake assets:precompile # to build them

Don't commit `lib/lurker/templates/public/**/*` to avoid conflicts.

**NOTE:** if you write features keep in mind to generate different files with aruba
because they are kept in the `lurker_app` directory to be deployed as a demo. Please, write
features in a way to generate **new** relevant `lurker/**/*.json.yml` files

**NOTE:** template partial `submit_form.html.erb` and it's partials is a big `jsx` script for `React`
so there are `<label htmlFor` instead of `<label for>` and `<div className` instead of `<div class`
### Demo app == Testing app

Currently, the testing application is using PostgreSQL because **the same** testing app is deployed to serve demo purposes.

This is also the reason not to delete anything under `lurker` directory between feature tests
and using **different** API endpoints of the testing app. To run cucumber with clean `lurker` & `public/lurker` directories run:

    CLEAN=1 export BUNDLE_GEMFILE=gemfiles/rails_6.gemfile bundle exec cucumber features

Beware while writing your feature tests for PRs.

## Acknowledgments

This gem is quite opinionated and relies on rails - if you're
interested in anything else, please take a look at [api_taster][api_taster] or [fdoc][fdoc],
This gem is heavily inspired by them. Thanks, @square & @fredwu

Also thanks to

- [Andrey Deryabin][aderyabin] for advice
- [Evil Martians][evil_martians] initial version sponsors
- [React.js][reactjs] for reactive UI
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
[evil_martians]: https://evilmartians.com/
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

[demo_app2]: https://lurker.razum2um.me
[demo_app3]: https://razum2um.github.io/lurker/
[demo_live]: https://lurker.razum2um.me/lurker/api/v1/users-POST.html
[pdf_example]: http://razum2um.github.io/lurker/lurker_demo_application.pdf
[partial_example_demo]: http://razum2um.github.io/lurker/api/v1/users/__user_id/repos-POST.html

[Gem Version]: https://rubygems.org/gems/lurker
[Build Status]: https://travis-ci.org/razum2um/lurker
[Dependency Status]: https://gemnasium.com/razum2um/lurker
[Code Climate]: https://codeclimate.com/github/razum2um/lurker
[Coverage Status]: https://coveralls.io/r/razum2um/lurker

[BS img]: https://travis-ci.org/razum2um/lurker.png
[CC img]: https://codeclimate.com/github/razum2um/lurker.png
[CS img]: https://coveralls.io/repos/razum2um/lurker/badge.png?branch=master
