FROM ruby:3.0

WORKDIR /usr/src/app
COPY ./ /usr/src/app

RUN bundle install

CMD ["bundle","exec","jekyll","serve","--host","0.0.0.0"]
# CMD ["bash","deploy/server.sh"]

EXPOSE 4000