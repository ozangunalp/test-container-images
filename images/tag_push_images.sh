#!/bin/bash

#####
# SUPPORTED KAFKA VERSIONS
#####
KAFKA_VERSIONS=$(cat supported_kafka.versions)

#####
# SUPPORTED SCALA VERSIONS
#####
SCALA_VERSION=$(cat supported_scala.version)

#####
# PRODUCT VERSION
#####
PRODUCT_VERSION=$(cat release.version)

#####
# DOCKER AND PROJECT auxiliary variables
#####
PROJECT_NAME=$1
REGISTRY=$2
REGISTRY_ORGANIZATION=$3
QUAY_USER=$4
QUAY_PASS=$5
ARCHITECTURES=$6

# PRINT ALL IMAGES
docker images

echo "Login into registry..."
docker login -u $QUAY_USER -p $QUAY_PASS $REGISTRY

#####
# FOR EACH KAFKA VERSION TAG AND PUSH IMAGE
#####
for KAFKA_VERSION in $KAFKA_VERSIONS
do
    CURRENT_TAG="$PRODUCT_VERSION-kafka-$KAFKA_VERSION"
    echo "[INFO] Delete the manifest to the registry, ignore the error if manifest doesn't exist"
	docker manifest rm $REGISTRY/$REGISTRY_ORGANIZATION/$PROJECT_NAME:$CURRENT_TAG || true
    for ARCH in $ARCHITECTURES
    do
        echo "[INFO] Tagging strimzi/$PROJECT_NAME:$CURRENT_TAG-$ARCH to $REGISTRY/$REGISTRY_ORGANIZATION/$PROJECT_NAME:$CURRENT_TAG-$ARCH ..."
        docker tag strimzi/$PROJECT_NAME:$CURRENT_TAG-$ARCH $REGISTRY/$REGISTRY_ORGANIZATION/$PROJECT_NAME:$CURRENT_TAG-$ARCH
        echo "[INFO] Pushing image with name: $REGISTRY/$REGISTRY_ORGANIZATION/$PROJECT_NAME:$CURRENT_TAG-$ARCH ..."
	    docker push $REGISTRY/$REGISTRY_ORGANIZATION/$PROJECT_NAME:$CURRENT_TAG-$ARCH
        echo "[INFO] Create / Amend the manifest"
	    docker manifest create $REGISTRY/$REGISTRY_ORGANIZATION/$PROJECT_NAME:$CURRENT_TAG --amend $REGISTRY/$REGISTRY_ORGANIZATION/$PROJECT_NAME:$CURRENT_TAG-$ARCH
    done
    echo "[INFO] Push the manifest to the registry"
	docker manifest push $REGISTRY/$REGISTRY_ORGANIZATION/$PROJECT_NAME:$CURRENT_TAG
done

#####
# SUPPORTED KAFKA KRAFT VERSIONS
#####
KRAFT_VERSIONS=$(cat supported_kraft.versions)

#####
# FOR EACH KAFKA VERSION TAG AND PUSH IMAGE
#####
for KRAFT_VERSION in $KRAFT_VERSIONS
do
    CURRENT_TAG="$PRODUCT_VERSION-kafka-kraft-$KRAFT_VERSION"
    echo "[INFO] Delete the manifest to the registry, ignore the error if manifest doesn't exist"
	docker manifest rm $REGISTRY/$REGISTRY_ORGANIZATION/$PROJECT_NAME:$CURRENT_TAG || true
    for ARCH in $ARCHITECTURES
    do
        echo "[INFO] Tagging strimzi/$PROJECT_NAME:$CURRENT_TAG-$ARCH to $REGISTRY/$REGISTRY_ORGANIZATION/$PROJECT_NAME:$CURRENT_TAG-$ARCH ..."
        docker tag strimzi/$PROJECT_NAME:$CURRENT_TAG-$ARCH $REGISTRY/$REGISTRY_ORGANIZATION/$PROJECT_NAME:$CURRENT_TAG-$ARCH
        echo "[INFO] Pushing image with name: $REGISTRY/$REGISTRY_ORGANIZATION/$PROJECT_NAME:$CURRENT_TAG-$ARCH ..."
	    docker push $REGISTRY/$REGISTRY_ORGANIZATION/$PROJECT_NAME:$CURRENT_TAG-$ARCH
        echo "[INFO] Create / Amend the manifest"
	    docker manifest create $REGISTRY/$REGISTRY_ORGANIZATION/$PROJECT_NAME:$CURRENT_TAG --amend $REGISTRY/$REGISTRY_ORGANIZATION/$PROJECT_NAME:$CURRENT_TAG-$ARCH
    done
    echo "[INFO] Push the manifest to the registry"
	docker manifest push $REGISTRY/$REGISTRY_ORGANIZATION/$PROJECT_NAME:$CURRENT_TAG
done