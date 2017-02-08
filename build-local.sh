#!/bin/bash

. set_properties_to_dockerfile_templates.sh

pushd dockerfile-inject
sbt update
sbt docker
sbt eclipse
popd

pushd dockerfile-app-streaming
sbt update
sbt docker
sbt eclipse
popd

pushd dockerfile-app-batch
sbt update assembly eclipse
docker build -t logimethods/smart-meter:app-batch-local .
popd

pushd dockerfile-monitor
sbt update
sbt docker
sbt eclipse
popd

pushd dockerfile-cassandra
docker build -t logimethods/smart-meter:cassandra-local .
popd

pushd dockerfile-cassandra-inject
docker build -t logimethods/smart-meter:cassandra-inject-local .
popd

pushd dockerfile-nats-server
docker build -t logimethods/smart-meter:nats-server-local .
popd
