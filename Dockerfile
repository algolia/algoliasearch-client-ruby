FROM ruby:2.6.3

ARG ALGOLIA_APPLICATION_ID_1
ARG ALGOLIA_ADMIN_KEY_1
ARG ALGOLIA_SEARCH_KEY_1
ARG ALGOLIA_APPLICATION_ID_2
ARG ALGOLIA_ADMIN_KEY_2
ARG ALGOLIA_APPLICATION_ID_MCM
ARG ALGOLIA_ADMIN_KEY_MCM

ENV ALGOLIA_APPLICATION_ID_1=$ALGOLIA_APPLICATION_ID_1
ENV ALGOLIA_ADMIN_KEY_1=$ALGOLIA_ADMIN_KEY_1
ENV ALGOLIA_SEARCH_KEY_1=$ALGOLIA_SEARCH_KEY_1
ENV ALGOLIA_APPLICATION_ID_2=$ALGOLIA_APPLICATION_ID_2
ENV ALGOLIA_ADMIN_KEY_2=$ALGOLIA_ADMIN_KEY_2
ENV ALGOLIA_APPLICATION_ID_MCM=$ALGOLIA_APPLICATION_ID_MCM
ENV ALGOLIA_ADMIN_KEY_MCM=$ALGOLIA_ADMIN_KEY_MCM

RUN gem install bundler

WORKDIR /app
COPY . /app/
RUN bundle install
