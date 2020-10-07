-include /usr/local/bin/php.mk

.PHONY: git-checkout drush-import init-drupal cache-clear cache-rebuild drush8-alias drush9-alias

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Required parameter is missing: $1$(if $2, ($2))))

is_hash ?= 0
target ?= all

ifeq ("$(DOCROOT_SUBDIR)", "")
    DRUPAL_ROOT=$(APP_ROOT)
else
    DRUPAL_ROOT=$(APP_ROOT)/$(DOCROOT_SUBDIR)
endif

DRUPAL_SITE_DIR=$(DRUPAL_ROOT)/sites/$(DRUPAL_SITE)

default: cache-clear

git-checkout:
	$(call check_defined, target)
	chmod 755 $(DRUPAL_SITE_DIR) || true
	git_checkout $(target) $(is_hash)

drush-import:
	$(call check_defined, source)
	drush_import $(source)

init-drupal:
	DRUPAL_SITE_DIR=$(DRUPAL_SITE_DIR) DRUPAL_ROOT=$(DRUPAL_ROOT) init_drupal

cache-clear:
	drush -r $(DRUPAL_ROOT) cache-clear $(target)

cache-rebuild:
	drush -r $(DRUPAL_ROOT) cache-rebuild

drush8-alias:
	@DRUPAL_SITE_DIR=$(DRUPAL_SITE_DIR) DRUPAL_ROOT=$(DRUPAL_ROOT) drush8_alias

drush9-alias:
	@DRUPAL_SITE_DIR=$(DRUPAL_SITE_DIR) DRUPAL_ROOT=$(DRUPAL_ROOT) drush9_alias
