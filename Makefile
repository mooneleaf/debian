ISO_HELPER := ./bin/iso-helper.sh
BOX_SUFFIX := .box
BUILDER_TYPES ?= vmware virtualbox parallels
BASE_FILE = debian.json
TEMPLATE_FILENAMES := $(filter-out $(BASE_FILE),$(wildcard *.json))
BOX_NAMES := $(basename $(TEMPLATE_FILENAMES))
BOX_FILENAMES := $(TEMPLATE_FILENAMES:.json=$(BOX_SUFFIX))
BOX_FILES := $(foreach type, $(BUILDER_TYPES), $(addprefix box/$(type)/,$(BOX_FILENAMES)))

VMWARE_BOX_DIR ?= box/vmware
#VMWARE_TEMPLATE_FILENAMES = $(TEMPLATE_FILENAMES)
#VMWARE_BOX_FILENAMES := $(VMWARE_TEMPLATE_FILENAMES:.json=$(BOX_SUFFIX))
VMWARE_BOX_FILES := $(addprefix box/vmware/,$(BOX_FILENAMES))
VIRTUALBOX_BOX_DIR ?= box/virtualbox
#VIRTUALBOX_TEMPLATE_FILENAMES = $(TEMPLATE_FILENAMES)
#VIRTUALBOX_BOX_FILENAMES := $(VIRTUALBOX_TEMPLATE_FILENAMES:.json=$(BOX_SUFFIX))
VIRTUALBOX_BOX_FILES := $(addprefix box/virtualbox/,$(BOX_FILENAMES))
PARALLELS_BOX_DIR ?= box/parallels
#PARALLELS_TEMPLATE_FILENAMES = $(TEMPLATE_FILENAMES)
#PARALLELS_BOX_FILENAMES := $(PARALLELS_TEMPLATE_FILENAMES:.json=$(BOX_SUFFIX))
PARALLELS_BOX_FILES := $(addprefix box/parallels/,$(BOX_FILENAMES))

#BOX_FILES := $(VMWARE_BOX_FILES) $(VIRTUALBOX_BOX_FILES) $(PARALLELS_BOX_FILES)
ISO_PATH := $(shell jq --raw-output '.variables.iso_path' $(BASE_FILE))
ISO_FILES := $(addprefix $(ISO_PATH)/, $(TEMPLATE_FILENAMES:json=iso))

MAKEFLAGS += --no-builtin-rules
.SUFFIXES:

build: $(BOX_FILES)

all: isos build assure deliver

isos: $(ISO_FILES)

parallels: $(PARALLELS_BOX_FILES)

vmware: $(VMWARE_BOX_FILES)

virtualbox: $(VIRTUALBOX_BOX_FILES)

$(TEMPLATE_FILENAMES): $(BASE_FILE)

$(VMWARE_BOX_DIR)/%$(BOX_SUFFIX) $(VIRTUALBOX_BOX_DIR)/%$(BOX_SUFFIX) $(PARALLELS_BOX_DIR)/%$(BOX_SUFFIX): %.json $(ISO_PATH)/%.iso
	packer build -only=$$(basename $$(dirname $@)) -var-file=$< $(BASE_FILE)

$(ISO_PATH)/%.iso: %.json
	$(ISO_HELPER) $@ $< $(BASE_FILE)

assure: assure_vmware assure_virtualbox assure_parallels

assure_vmware: $(VMWARE_BOX_FILES)
	@for vmware_box_file in $(VMWARE_BOX_FILES) ; do \
		echo Checking $$vmware_box_file ; \
		bin/box test $$vmware_box_file vmware ; \
	done

assure_virtualbox: $(VIRTUALBOX_BOX_FILES)
	@for virtualbox_box_file in $(VIRTUALBOX_BOX_FILES) ; do \
		echo Checking $$virtualbox_box_file ; \
		bin/box test $$virtualbox_box_file virtualbox ; \
	done

assure_parallels: $(PARALLELS_BOX_FILES)
	@for parallels_box_file in $(PARALLELS_BOX_FILES) ; do \
		echo Checking $$parallels_box_file ; \
		bin/box test $$parallels_box_file parallels ; \
	done

assure_atlas: assure_atlas_vmware assure_atlas_virtualbox assure_atlas_parallels

assure_atlas_vmware:
	@for box_name in $(BOX_NAMES) ; do \
		echo Checking $$box_name ; \
		bin/test-vagrantcloud-box box-cutter/$$box_name vmware ; \
		bin/test-vagrantcloud-box boxcutter/$$box_name vmware ; \
	done

assure_atlas_virtualbox:
	@for box_name in $(BOX_NAMES) ; do \
		echo Checking $$box_name ; \
		bin/test-vagrantcloud-box box-cutter/$$box_name virtualbox ; \
		bin/test-vagrantcloud-box boxcutter/$$box_name virtualbox ; \
	done

assure_atlas_parallels:
	@for box_name in $(BOX_NAME) ; do \
		echo Checking $$box_name ; \
		bin/test-vagrantcloud-box box-cutter/$$box_name parallels ; \
		bin/test-vagrantcloud-box boxcutter/$$box_name parallels ; \
	done

deliver:
	@for box_name in $(BOX_NAMES) ; do \
		echo Uploading $$box_name to Atlas ; \
		bin/register_atlas.sh $$box_name $(BOX_SUFFIX) $(BOX_VERSION) ; \
	done

clean:
	@for builder in $(BUILDER_TYPES) ; do \
		echo Deleting output-*-$$builder-iso ; \
		echo rm -rf output-*-$$builder-iso ; \
	done
	@for builder in $(BUILDER_TYPES) ; do \
		if test -d box/$$builder ; then \
			echo Deleting box/$$builder/*.box ; \
			find box/$$builder -maxdepth 1 -type f -name "*.box" ! -name .gitignore -exec rm '{}' \; ; \
		fi ; \
	done
	@if [ -L iso ] ; then \
		echo "NOT deleting iso (it is a symlink)" ; \
	else \
		echo rm -rf iso ; \
		rm -rf iso ; \
	fi ;

.PHONY: all clean isos assure deliver parallels vmware virtualbox assure_atlas assure_atlas_vmware assure_atlas_virtualbox assure_atlas_parallels
