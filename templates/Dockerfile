# cd tmp/lurker_app_*, run with
# docker run -e DATABASE_URL=postgres://user@host.docker.internal/lurker_app_rails_6 -p 3000:3000 lurker"
FROM ruby:2.7-alpine as build

WORKDIR /app

RUN apk add git postgresql-dev libpq

COPY Gemfile* ./

RUN apk add --no-cache --update alpine-sdk make && \
    bundler config set without 'development test' && \
    bundler config set path 'vendor/bundle' && \
    bundler install

COPY . ./

EXPOSE 3000

ENV PATH "$PATH:/app/vendor/bundle/ruby/2.7.0/bin"
ENV GEM_HOME "/app/vendor/bundle/ruby/2.7.0"
ENV RAILS_ENV "production"
ENV RAILS_SERVE_STATIC_FILES "1"
ENV RAILS_LOG_TO_STDOUT "1"

CMD ["bin/rails", "s", "-b", "0.0.0.0"]