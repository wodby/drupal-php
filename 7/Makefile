-include env_make

PHP_VER ?= 7.1

BASE_IMAGE_TAG = $(PHP_VER)
REPO = wodby/drupal-php
NAME = drupal-php-$(PHP_VER)

ifeq ($(TAG),)
    ifneq ($(PHP_DEV_MACOS),)
    	TAG = $(PHP_VER)-dev-macos
    else ifneq ($(PHP_DEV),)
        TAG = $(PHP_VER)-dev
    else
        TAG = $(PHP_VER)
    endif
endif

ifneq ($(PHP_DEV_MACOS),)
    NAME := $(NAME)-dev-macos
    BASE_IMAGE_TAG := $(BASE_IMAGE_TAG)-dev-macos
else ifneq ($(PHP_DEV),)
    NAME := $(NAME)-dev
    BASE_IMAGE_TAG := $(BASE_IMAGE_TAG)-dev
endif

ifneq ($(BASE_IMAGE_STABILITY_TAG),)
    BASE_IMAGE_TAG := $(BASE_IMAGE_TAG)-$(BASE_IMAGE_STABILITY_TAG)
endif

ifneq ($(STABILITY_TAG),)
    ifneq ($(TAG),latest)
        override TAG := $(TAG)-$(STABILITY_TAG)
    endif
endif

.PHONY: build test push shell run start stop logs clean release

default: build

build:
	docker build -t $(REPO):$(TAG) --build-arg BASE_IMAGE_TAG=$(BASE_IMAGE_TAG) ./

test:
	cd ./test/8 && IMAGE=$(REPO):$(TAG) ./run.sh
	cd ./test/7 && IMAGE=$(REPO):$(TAG) ./run.sh

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
