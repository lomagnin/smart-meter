#docker network create --driver overlay smart-meter-net
#docker service rm $(docker service ls -q)

docker service create \
	--name spark-master \
	-e SERVICE_NAME=spark-master \
	--network smart-meter-net \
	--constraint 'node.role == manager' \
	--log-driver=json-file \
	gettyimages/spark:2.0.1-hadoop-2.7
	
docker service create \
	--name spark-slave \
	-e SERVICE_NAME=spark-slave \
	--network smart-meter-net \
	--replicas=2 \
	gettyimages/spark:2.0.1-hadoop-2.7 \
		bin/spark-class org.apache.spark.deploy.worker.Worker spark://spark-master:7077
		
docker service create \
	--name nats \
	--network smart-meter-net \
	--replicas=1 \
	nats

#docker pull logimethods/smart-meter:app-streaming
docker service create \
	--name app-streaming \
	-e NATS_URI=nats://nats:4222 \
	-e SPARK_MASTER_URL=spark://spark-master:7077 \
	-e LOG_LEVEL=DEBUG \
	--network smart-meter-net \
	--replicas=1 \
	logimethods/smart-meter:app-streaming \
		"smartmeter.voltage.>" "smartmeter.max."

#docker pull logimethods/smart-meter:monitor
docker service create \
	--name monitor \
	-e NATS_URI=nats://nats:4222 \
	--network smart-meter-net \
	--replicas=1 \
	logimethods/smart-meter:monitor \
		"smartmeter.max.>"

#docker pull logimethods/smart-meter:inject
docker service create \
	--name inject \
	-e GATLING_TO_NATS_SUBJECT=smartmeter.voltage \
	-e NATS_URI=nats://nats:4222 \
	--network smart-meter-net \
	--replicas=1 \
	logimethods/smart-meter:inject \
		--no-reports -s com.logimethods.smartmeter.inject.NatsInjection