# cd tmp/lurker_app_*, run with
# docker run -e DATABASE_URL=postgres://user@host.docker.internal/lurker_app_rails_6 -p 3000:3000 lurker"
FROM ruby:2.7-alpine as build

WORKDIR /app

RUN apk add git postgresql-dev

COPY Gemfile ./

RUN apk add --no-cache --update alpine-sdk make && \
    bundler config set without 'development test' && \
    bundler config set path 'vendor/bundle' && \
    bundler install


FROM ruby:2.7-alpine

WORKDIR /app

RUN apk add libpq

RUN bundler config set without 'development test' && \
    bundler config set path 'vendor/bundle'

COPY --from=build /app/vendor /app/vendor

COPY . /app

RUN bin/lurker convert

EXPOSE 3000

ENV PATH "$PATH:/app/vendor/bundle/ruby/2.7.0/bin"
ENV GEM_HOME "/app/vendor/bundle/ruby/2.7.0"
ENV RAILS_ENV "production"

CMD ["puma"]