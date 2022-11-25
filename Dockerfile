FROM ruby:2.7.7

RUN gem install bundler

WORKDIR /app
COPY . /app/
RUN bundle install
