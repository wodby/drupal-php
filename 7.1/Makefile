-include env_make

VERSION ?= 7.1

REPO = wodby/drupal-php
NAME = drupal-php-$(VERSION)

.PHONY: build test push shell run start stop logs rm release

build:
	docker build -t $(REPO):$(VERSION) ./

test:
	REPO=$(REPO) VERSION=$(VERSION) NAME=$(NAME) sh tests.sh

push:
	docker push $(REPO):$(VERSION)

shell:
	docker run --rm --name $(NAME) -i -t $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(VERSION) /bin/bash

run:
	docker run --rm --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(VERSION)

start:
	docker run -d --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(VERSION)

stop:
	docker stop $(NAME)

logs:
	docker logs $(NAME)

rm:
	docker rm -f $(NAME)

release: build
	make push -e VERSION=$(VERSION)

default: build
