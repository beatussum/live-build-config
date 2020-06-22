HOSTNAME	?= bsum-kali
MIRROR		?= $(shell cat .mirror)
USERNAME	?=
FULLNAME	?=

PATCH_FILES		?= $(wildcard patches/*.patch)
ARCHIVE_NAME	?= live-build-config-master
KALI_UPSTREAM	?= https://gitlab.com/kalilinux/build-scripts/live-build-config/-/archive/master

VARIANT				= kali-config/variant-bsum
INC_CHROOT			= $(VARIANT)/includes.chroot
INC_BINARY			= $(VARIANT)/includes.binary
HOME				= $(INC_CHROOT)/home
PRESEED_INSTALLER	= $(VARIANT)/debian-installer/preseed.cfg
LB_CONFIG			= $(INC_BINARY)/live/config.conf

RM			?= rm -f
RM_DIR		?= rm -fr
PATCH		?= patch -p1
TAR			?= tar xf
TAR_OPTS	?= --strip-components=1 --exclude="$(ARCHIVE_NAME)/README.md" --exclude="$(ARCHIVE_NAME)/.gitignore"
WGET		?= wget
CP_DIR		?= cp -air
SED			?= sed

.PHONY: all
all: patch-kali-live-build-config $(HOME)/$(USERNAME) $(PRESEED_INSTALLER) $(LB_CONFIG)
	./build.sh

.PHONY: clean
clean:
	find kali-config -maxdepth 1 -mindepth 1 \
		! -name "variant-bsum" \
		-exec $(RM_DIR) {} \;
	$(RM_DIR) auto simple-cdd
	$(RM) .getopt.sh build.sh build_all.sh \
		$(ARCHIVE_NAME).tar.gz \
		$(PRESSED_INSTALLER) $(LB_CONFIG)

.PHONY: patch-kali-live-build-config
patch-kali-live-build-config: $(ARCHIVE_NAME)
	for i in $(PATCH_FILES); do \
		$(PATCH) < "$${i}"; \
	done; unset i

$(ARCHIVE_NAME): $(ARCHIVE_NAME).tar.gz
	$(TAR) "$<" $(TAR_OPTS)

$(ARCHIVE_NAME).tar.gz:
	$(WGET) "$(KALI_UPSTREAM)/$(ARCHIVE_NAME).tar.gz"

$(HOME)/$(USERNAME): $(HOME)/@USERNAME@
	$(CP_DIR) "$<" "$@"

$(PRESEED_INSTALLER): $(PRESEED_INSTALLER).in
	$(SED) -e "s|@HOSTNAME@|$(HOSTNAME)|" \
		-e "s|@MIRROR@|$(MIRROR)|" \
		"$<" > "$@"

$(LB_CONFIG): $(LB_CONFIG).in
	$(SED) -e "s|@HOSTNAME@|$(HOSTNAME)|" \
		-e "s|@USERNAME@|$(USERNAME)|" \
		-e "s|@FULLNAME@|$(FULLNAME)|" \
		"$<" > "$@"

