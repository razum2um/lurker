# Lurker

[![Gem Version][GV img]][Gem Version]
[![Build Status][BS img]][Build Status]
[![Dependency Status][DS img]][Dependency Status]
[![Code Climate][CC img]][Code Climate]
[![Coverage Status][CS img]][Coverage Status]
[![githalytics.com alpha](https://cruel-carlota.pagodabox.com/87ced56265849ad6386c2ba0a78f8038 "githalytics.com")](http://githalytics.com/razum2um/lurker)


## Installation

Add this line to your application's Gemfile:

    gem 'lurker'

## Usage

Write your [contorller][controler_spec_example] or [request][request_spec_example] specs as usual,
but add `:lurker` mark. Please, commit your [json-schemas][json_schema] under Rails.root/lurker directory.

Now, every test run lurker will look into your requests and [vaditate them][validation_example]!

Let's run your `rails s` and visit [http://localhost:3000/lurker] (or see [example][html_schema_example])

Now, you can test your API on-line (for real)

## Features

- Autoscaffolding for non-covered API endpoints
- Autotesting for covered endpoint once written (both request & response!)
- Pretty HTML documentation based on your schemas
- Pretty submit form to test API endpoints (live) based on schemas
- Handling URLs with dynamic segments (such as `api/v1/:user_id/repos`)
- Multiple docs for many test cases
- JSON-Schema partials (inline reference to other schemas)
- ERB support inside `.json.yml.erb`
- HTTP-Auth authorization for your online docs
- Capistrano integration

## Demo

You can clone the repo & run `rake regenerate`. It will generate testing rails application for some api

## TODO

- Auto extraction for models into json-schema partials (in responses at least)
- Auto marking of attributes as required if `strong_params` are used
- More unit tests

[json_schema]: http://json-schema.org/
[validation_example]: http://
[html_schema_example]: http://
[controler_spec_example]: https://www.relishapp.com/razum2um/lurker/docs/controller-specs/schema-scaffolding
[request_spec_example]: https://www.relishapp.com/razum2um/lurker/docs/request-specs/schema-scaffolding

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
