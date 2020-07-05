SHELL	= /bin/bash

VARIANT		?= bsum
HOSTNAME	?= $(VARIANT)-kali
USERNAME	?=
FULLNAME	?=

ifeq ($(wildcard .lock_upstream),)
	LOCK	= master
else
	LOCK	= $(shell cat .lock_upstream)
endif

MIRROR		= $(shell cat .mirror)
ARCHIVE_NAME	?= live-build-config
KALI_UPSTREAM	?= https://gitlab.com/kalilinux/build-scripts/live-build-config/-/archive/$(LOCK)

BUILD_LOG		= build.log
VARIANT_DIR		?= kali-config/variant-$(VARIANT)
HOME			= $(VARIANT_DIR)/includes.chroot/home
PRESEED_INSTALLER	= $(VARIANT_DIR)/debian-installer/preseed.cfg
LIVE_CONFIG		= $(VARIANT_DIR)/includes.binary/live/config.conf

PATCHES_CONFIG		?= $(wildcard patches/config/*.patch)
PATCHES_UPSTREAM	?= $(wildcard patches/upstream/*.patch)

PATCH		?= patch -p1
TAR		?= tar xf
TAR_OPTS	?= --strip-components=1					\
			--exclude="$(ARCHIVE_NAME)-$(LOCK)/README.md"	\
			--exclude="$(ARCHIVE_NAME)-$(LOCK)/.gitignore"
CURL		?= curl
MKDIR		?= mkdir -p
CP_DIR		?= cp -r
SED		?= sed
RM_DIR		?= rm -fr
RM		?= rm -f

.PHONY: build
build: clean-templates patch-config
	lb build 2>&1 | tee -a "$(BUILD_LOG)"

.PHONY: clean-templates
clean-templates: config
	$(RM) config/{$(PRESEED_INSTALLER:$(VARIANT_DIR)/%=%),\
	$(LIVE_CONFIG:$(VARIANT_DIR)/%=%)}.in

	$(RM_DIR) "config/$(HOME:$(VARIANT_DIR)/%=%)/@USERNAME@/"

.PHONY: patch-config
patch-config: config
	for i in $(PATCHES_CONFIG); do	\
		$(PATCH) < "$${i}";	\
	done; unset i

.PHONY: config
config: patch-upstream $(HOME)/$(USERNAME) $(PRESEED_INSTALLER) $(LIVE_CONFIG)
	./build.sh --variant bsum --verbose

.PHONY: patch-upstream
patch-upstream: unpack
	for i in $(PATCHES_UPSTREAM); do	\
		$(PATCH) < "$${i}";		\
	done; unset i

.PHONY: unpack
unpack: $(ARCHIVE_NAME).tar.gz
	$(TAR) "$<" $(TAR_OPTS)

$(ARCHIVE_NAME).tar.gz:
	$(CURL) "$(KALI_UPSTREAM)/$(ARCHIVE_NAME).tar.gz" -o "$@"

$(HOME)/$(USERNAME): $(HOME)/@USERNAME@
	$(MKDIR) "$(dir $@)"
	$(CP_DIR) "$<" "$@"

$(PRESEED_INSTALLER): $(PRESEED_INSTALLER).in
	$(MKDIR) "$(dir $@)"
	$(SED) -e "s|@HOSTNAME@|$(HOSTNAME)|"		\
		-e "s|@MIRROR@|$(MIRROR:%/kali/=%)|"	\
		"$<" > "$@"

$(LIVE_CONFIG): $(LIVE_CONFIG).in
	$(MKDIR) "$(dir $@)"
	$(SED) -e "s|@HOSTNAME@|$(HOSTNAME)|"	\
		-e "s|@USERNAME@|$(USERNAME)|"	\
		-e "s|@FULLNAME@|$(FULLNAME)|"	\
		"$<" > "$@"

.PHONY: clean
clean:
	find kali-config -maxdepth 1 -mindepth 1	\
		! -name "variant-bsum" 			\
		-exec $(RM_DIR) {} \;
	$(RM_DIR) auto/ config/ simple-cdd/
	$(RM) .getopt.sh build.sh build_all.sh
	$(RM) "$(PRESEED_INSTALLER)" "$(LIVE_CONFIG)"
	$(RM) "$(BUILD_LOG)" chroot.* *.contents *.files	\
		*.packages
	$(RM_DIR) .build/ binary/ cache/ chroot/ config/	\
		images/ local/

.PHONY: mrproper
mrproper:
	$(RM) live-build-config.tar.gz
	$(RM) *.iso*
