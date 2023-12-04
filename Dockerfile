FROM ruby:2.7.8

RUN gem install bundler

WORKDIR /app
COPY . /app/
RUN bundle install
