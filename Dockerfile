FROM ruby:3.1.3

RUN gem install bundler

WORKDIR /app
COPY . /app/
RUN bundle install
