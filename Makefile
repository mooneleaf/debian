#!/usr/bin/make -f

#SHELL := /bin/sh -eux
PACKER := packer
ISO_HELPER := ./bin/iso-helper.sh
BOX_SUFFIX := .box
BUILDER_TYPES ?= vmware virtualbox parallels
BASE_FILE ?= debian.json
BOX_DIR := box
ISO_PATH ?= iso

TEMPLATE_FILENAMES := $(wildcard debian*-*.json)

# Todo: convert to a template with a configure script
# Makefile then depends on the json files + the configure script
# Configure script:
# - detects which DL tool to use
# - sets up rules for DL by hash
# 	- ISO depends on %.sum
#	- %.sum runs always (depend on FORCE)
#   - %.sum  


# Callable functions

# Query a template using jq. Args: template file, jq query
json_query = $(shell jq --raw-output --slurpfile override "$(1)"  ".variables * \$$override[] | . as \$$vars | $(2)" "$(BASE_FILE)")

# Get the ISO name from a config file
iso_name = $(addprefix $(ISO_PATH)/,$(call json_query,$(1),".iso_name"))

# Get the VM name from a config file
vm_name = $(call json_query,$(1),".vm_name")

# Get the version from a config file
vm_version = $(call json_query,$(1),".version")

# Get the config file for a box file
box_config_file = $(shell basename $(shell dirname $(shell dirname $(1)))).json

# Get the ISO name for a box file
box_iso_name = $(call iso_name,$(call box_config_file,$(1)))

# Get the config file for an ISO
iso_config_file = $(shell grep -l $(1) $(TEMPLATE_FILENAMES))

BOX_NAMES := $(addprefix $(BOX_DIR)/,$(foreach config,$(TEMPLATE_FILENAMES),$(foreach builder,$(BUILDER_TYPES),$(call vm_name,$(config))/$(call vm_version,$(config))/$(builder).box)))

ISO_NAMES := $(foreach config,$(TEMPLATE_FILENAMES),$(call iso_name,$(config)))

MAKEFLAGS += --no-builtin-rules
.SUFFIXES:
.SECONDEXPANSION:

all: $(BOX_NAMES)

isos: $(ISO_NAMES)

%$(BOX_SUFFIX): $$(call box_config_file,$$@) $(BASE_FILE) $$(call box_iso_name,$$@)
	$(PACKER) build -only=$$(basename $@ $(BOX_SUFFIX)) -var-file=$< $(BASE_FILE)

%.iso: $$(call iso_config_file,$$(shell basename $$@)) $(BASE_FILE)
	$(ISO_HELPER) $@ $< $(BASE_FILE)

print-%:
	@echo '$*=$($*)'

.PHONY: all isos
