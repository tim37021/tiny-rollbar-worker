ARG BASE_RUBY_IMAGE=ruby:3.0-alpine3.14
FROM $BASE_RUBY_IMAGE

# RUN apt-get update && apt-get install git
RUN apk add --update git curl

WORKDIR /usr/src

COPY . . 

RUN bundle install

CMD ["./scripts/start_worker.sh"]
