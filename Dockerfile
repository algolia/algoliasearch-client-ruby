FROM ruby:3.3.4

RUN gem install bundler

WORKDIR /app
COPY . /app/
RUN bundle install
