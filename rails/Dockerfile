FROM ruby:3.1.2
RUN apt-get update -qq && apt-get install -y build-essential \
    nodejs \
    libpq-dev \
    vim

RUN mkdir /myapp
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock

RUN bundle install
COPY . /myapp