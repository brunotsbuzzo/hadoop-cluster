.PHONY: build

build:
	@docker build -t brunobuzzo/hadoop-cluster:1.0.0 ./docker/spark-base