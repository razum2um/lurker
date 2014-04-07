# Lurker

The new de-facto for API testing

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
but add `:lurker` mark.

    describe Api::V1::UsersController, :lurker do
      ...

And run the specs. That's all, easy!

Please, commit your files under `Rails.root/lurker` directory.
Feel free to edit them according to [json-schema][json_schema] standart,
but scaffolded schemas are pretty good by default.

    A  lurker/ExampleApp.service.yml
    A  lurker/api/v1/users-GET.json.yml
    A  lurker/api/v1/users/__user_id/repos-GET.json.yml

Now, every test run lurker will look into your requests and [vaditate them][validation_example]
and it fails if your code changes the api!

    Failure/Error: post :create, {
    Fdoc::ValidationError:
      Request
      - The property '#/' contains additional properties ["social_network"] outside of the schema
        when none are allowed in schema c0ec70af-3d75-5a46-8206-a73a2b6250b3#
      Response
      - The property '#/user/last_sign_in_at' of type String did not match the following type:
        null in schema 83b0e4ef-4f9e-567e-ab37-8941366c0126#
      Diff
             required: []
      +    social_network:
      +      type: object
      +      properties:
      +        provider:
      +          type: string
      +        uid:
      +          type: string
      +      required: []
         required: []
               last_sign_in_at:
      -          type: 'null'
      -      required:
      -      - email
      +          type: string
      +      required: []
         required: []

Let's run your `rails s` and visit [http://localhost:3000/lurker/](http://localhost:3000/lurker/) (or see [example][html_schema_example])

Now, you can test your API on-line (for real)

## Features

- [Autoscaffolding for non-covered API endpoints][controler_spec_example]
- Autotesting for covered endpoint once written (both request & response!)
- Pretty HTML documentation based on your schemas
- Pretty submit form to test API endpoints (live) based on schemas
- [Handling URLs with dynamic segments][nested_controller_spec_example] (such as `api/v1/:user_id/repos`)
- Multiple docs for many test cases
- JSON-Schema partials (inline reference to other schemas)
- ERB support inside `.json.yml.erb`
- HTTP-Auth authorization for your online docs
- Capistrano integration

## Demo application

You can clone the repo & run `rake features`. It will generate testing rails application for some api

## TODO

- Auto extraction for models into json-schema partials (in responses at least)
- Auto marking of attributes as required if `strong_params` are used
- Better Diff expected-schema vs recorded schema
- XML api testing via *.xsd
- More unit tests

[json_schema]: http://json-schema.org/
[validation_example]: http://
[html_schema_example]: http://
[controler_spec_example]: https://www.relishapp.com/razum2um/lurker/docs/controller-specs/schema-scaffolding
[nested_controller_spec_example]: https://www.relishapp.com/razum2um/lurker/docs/controller-specs/nested-schema-scaffolding
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
