FROM ubuntu:latest

RUN apt-get update && apt-get install -y lua5.4 make zip curl
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get install -y nodejs

RUN npm install -g http-server

COPY . /app
WORKDIR /app
RUN make web

EXPOSE 8080

CMD ["http-server", "releases/web"]
