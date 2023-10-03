# Start from a base image, for example, Ubuntu
FROM ubuntu:latest

# Install Lua
RUN apt-get update && apt-get install -y lua5.4

# Assuming you have a Makefile in the root directory of your project
# that contains a 'web' target:
COPY . /app
WORKDIR /app
RUN make web
