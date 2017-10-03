-include env_make

VERSION ?= 5.6

REPO = wodby/drupal-php
NAME = drupal-php-5.6
PHP_DEBUG = 0
FROM_TAG = 5.6

ifeq ($(PHP_DEBUG), 1)
    override VERSION := $(VERSION)-debug
    FROM_TAG := $(FROM_TAG)-debug
    NAME := $(NAME)-debug
endif

.PHONY: build test push shell run start stop logs clean release

default: build

build:
	docker build -t $(REPO):$(VERSION) --build-arg FROM_TAG=$(FROM_TAG) ./

test:
	cd ./test/6 && IMAGE=$(REPO):$(VERSION) ./run.sh
	cd ./test/7 && IMAGE=$(REPO):$(VERSION) ./run.sh

push:
	docker push $(REPO):$(VERSION)

shell:
	docker run --rm --name $(NAME) -i -t $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(VERSION) /bin/bash

run:
	docker run --rm --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(VERSION) $(CMD)

start:
	docker run -d --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(VERSION)

stop:
	docker stop $(NAME)

logs:
	docker logs $(NAME)

clean:
	-docker rm -f $(NAME)

release: build push
