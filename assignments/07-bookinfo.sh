#!/bin/sh

set -e

# rating setup
docker build -t ratings ratings

docker run -d --name mongodb -p 27017:27017 -v ~/ratings/databases:/docker-entrypoint-initdb.d bitnami/mongodb:5.0.2-debian-10-r2

docker run -d --name ratings -p 8080:8080 --link mongodb:mongodb -e SERVICE_VERSION=v2 -e 'MONGO_DB_URL=mongodb://mongodb:27017/ratings' ratings

# details setup
docker build -t details itkmitl-bookinfo-details

docker run -d --name details -p 8081:9080 details

# reviews setup
docker build -t reviews itkmitl-bookinfo-reviews

docker run -d --rm -p 8082:9080 --name reviews-service --link ratings:ratings -e 'RATINGS_SERVICE=http://ratings:8080' -e ENABLE_RATINGS="true" reviews

# productpage setup

docker build -t productpage itkmitl-bookinfo-productpage

docker run -d --rm -p 8083:9080 --name productpage-service --link details --link ratings --link reviews-service -e DETAILS_HOSTNAME="http://details:9080" -e RATINGS_HOSTNAME="http://ratings:9080" -e REVIEWS_HOSTNAME="http://reviews-service:9080" productpage

