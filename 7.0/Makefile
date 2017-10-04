-include env_make

PHP_VER = 7.0
FROM_TAG = $(PHP_VER)

TAG ?= $(PHP_VER)
PHP_DEBUG ?= 0

REPO = wodby/drupal-php
NAME = drupal-php-$(PHP_VER)

ifeq ($(PHP_DEBUG), 1)
    override TAG := $(TAG)-debug
    FROM_TAG := $(FROM_TAG)-debug
    NAME := $(NAME)-debug
endif

.PHONY: build test push shell run start stop logs clean release

default: build

build:
	docker build -t $(REPO):$(TAG) --build-arg FROM_TAG=$(FROM_TAG) ./

test:
	cd ./test/7 && IMAGE=$(REPO):$(TAG) ./run.sh
	cd ./test/8 && IMAGE=$(REPO):$(TAG) ./run.sh

push:
	docker push $(REPO):$(TAG)

shell:
	docker run --rm --name $(NAME) -i -t $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) /bin/bash

run:
	docker run --rm --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) $(CMD)

start:
	docker run -d --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG)

stop:
	docker stop $(NAME)

logs:
	docker logs $(NAME)

clean:
	-docker rm -f $(NAME)

release: build push
