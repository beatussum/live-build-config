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
LIVE_CONFIG		= includes.binary/live/config.conf
HOME			= $(VARIANT_DIR)/includes.chroot/home
ROOT			= config/includes.chroot/root
PRESEED_INSTALLER	= debian-installer/preseed.cfg
FIX_PERMS_HOOK		= hooks/live/fix-permissions.chroot

PATCHES_CONFIG		?= $(wildcard patches/config/*.patch)
PATCHES_UPSTREAM	?= $(wildcard patches/upstream/*.patch)

LN		?= ln -rs
RM_DIR		?= rm -fr
PATCH		?= patch -p1
TAR		?= tar xf
TAR_OPTS	?= --strip-components=1					\
			--exclude="$(ARCHIVE_NAME)-$(LOCK)/README.md"	\
			--exclude="$(ARCHIVE_NAME)-$(LOCK)/.gitignore"
CURL		?= curl
MKDIR		?= mkdir -p
SED		?= sed
CP_DIR		?= cp -r
RM		?= rm -f

.PHONY: build
build: clean-home-template patch-config $(ROOT)
	lb build 2>&1 | tee -a "$(BUILD_LOG)"

.PHONY: clean-templates
clean-home-template: config
	$(RM_DIR) "config/$(HOME:$(VARIANT_DIR)/%=%)/@USERNAME@/"

.PHONY: patch-config
patch-config: config
	for i in $(PATCHES_CONFIG); do	\
		$(PATCH) < "$${i}";	\
	done; unset i

$(ROOT): config/$(HOME:$(VARIANT_DIR)/%=%)/$(USERNAME)
	$(LN) "$<" "$@"

.PHONY: config
config: patch-upstream config/$(LIVE_CONFIG) $(HOME)/$(USERNAME) config/$(PRESEED_INSTALLER) config/$(FIX_PERMS_HOOK)
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

config/$(LIVE_CONFIG): $(VARIANT_DIR)/$(LIVE_CONFIG).in
	$(MKDIR) "$(dir $@)"
	$(SED) -e "s|@HOSTNAME@|$(HOSTNAME)|g"	\
		-e "s|@USERNAME@|$(USERNAME)|g"	\
		-e "s|@FULLNAME@|$(FULLNAME)|g"	\
		"$<" > "$@"

$(HOME)/$(USERNAME): $(HOME)/@USERNAME@
	$(CP_DIR) "$<" "$@"

config/$(PRESEED_INSTALLER): $(VARIANT_DIR)/$(PRESEED_INSTALLER).in
	$(MKDIR) "$(dir $@)"
	$(SED) -e "s|@HOSTNAME@|$(HOSTNAME)|g"		\
		-e "s|@MIRROR@|$(MIRROR:%/kali/=%)|g"	\
		"$<" > "$@"

config/$(FIX_PERMS_HOOK): $(VARIANT_DIR)/$(FIX_PERMS_HOOK).in
	$(MKDIR) "$(dir $@)"
	$(SED) "s|@USERNAME@|$(USERNAME)|g" "$<" > "$@"

.PHONY: clean
clean:
	find kali-config -maxdepth 1 -mindepth 1	\
		! -name "variant-bsum" 			\
		-exec $(RM_DIR) {} \;
	$(RM_DIR) auto/ config/ simple-cdd/
	$(RM) .getopt.sh build.sh build_all.sh

ifneq ($(USERNAME),)
	$(RM_DIR) "$(HOME)/$(USERNAME)"
endif

	$(RM) "$(BUILD_LOG)" chroot.* *.contents *.files	\
		*.packages
	$(RM_DIR) .build/ binary/ cache/ chroot/ config/	\
		images/ local/

.PHONY: mrproper
mrproper:
	$(RM) live-build-config.tar.gz
	$(RM) *.iso*
