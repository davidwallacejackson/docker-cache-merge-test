# syntax=docker/dockerfile:1.4

FROM alpine

COPY test-file /
RUN sleep 1
