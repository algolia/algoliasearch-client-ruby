FROM ruby:3.3.0

RUN gem install bundler

WORKDIR /app
COPY . /app/
RUN bundle install
