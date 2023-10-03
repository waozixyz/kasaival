FROM ubuntu:latest

RUN apt-get update && apt-get install -y lua5.4 make zip

COPY . /app
WORKDIR /app
RUN make web
