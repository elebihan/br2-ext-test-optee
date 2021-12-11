################################################################################
#
# hello-ta
#
################################################################################

HELLO_TA_VERSION = 6f2c3b9
HELLO_TA_SITE = $(call github,elebihan,hello-ta,$(HELLO_TA_VERSION))
HELLO_TA_LICENSE = ISC
HELLO_TA_LICENSE_FILES = LICENSE-ISC

HELLO_TA_DEPENDENCIES = optee-client optee-os

define HELLO_TA_BUILD_TA
	$(MAKE) CROSS_COMPILE=$(TARGET_CROSS) \
	TA_DEV_KIT_DIR=$(OPTEE_OS_SDK) \
	O=out -C $(@D)/ta all
endef

ifeq ($(BR2_PACKAGE_HELLO_TA_SIGN_TA),y)
HELLO_TA_SIGN_PRIV_KEY=$(call qstrip,$(BR2_PACKAGE_HELLO_TA_SIGN_TA_PRIV_KEY))
HELLO_TA_SIGN_PUB_KEY=$(call qstrip,$(BR2_PACKAGE_HELLO_TA_SIGN_TA_PUB_KEY))
HELLO_TA_UUID=$(call qstrip,$(BR2_PACKAGE_HELLO_TA_UUID))
define HELLO_TA_SIGN_TA
	$(BR2_EXTERNAL_TEST_OPTEE_PATH)/tools/sign-encrypt \
		-T $(OPTEE_OS_DIR)/scripts/sign_encrypt.py \
		-K $(HELLO_TA_SIGN_PRIV_KEY) \
		-P $(HELLO_TA_SIGN_PUB_KEY) \
		$(HELLO_TA_UUID) \
		$(@D)/ta/out/$(HELLO_TA_UUID).stripped.elf
endef
endif

define HELLO_TA_INSTALL_TA
	@mkdir -p $(TARGET_DIR)/lib/optee_armtz
	@$(INSTALL) -D -m 444 -t $(TARGET_DIR)/lib/optee_armtz $(@D)/ta/out/*.ta
endef

define HELLO_TA_INSTALL_HOST
	@mkdir -p $(TARGET_DIR)/usr/bin
	@$(INSTALL) -D -m 755 -t $(TARGET_DIR)/usr/bin $(@D)/host/hello_ta
endef

define HELLO_TA_BUILD_HOST
	$(MAKE) \
	CC=$(TARGET_CC) \
	LD=$(TARGET_CC) \
	TA_DEV_KIT_DIR=$(OPTEE_OS_SDK) \
	TEEC_EXPORT=$(STAGING_DIR)/usr \
	-C $(@D)/host all
endef

define HELLO_TA_BUILD_CMDS
	$(HELLO_TA_BUILD_TA)
	$(HELLO_TA_SIGN_TA)
	$(HELLO_TA_BUILD_HOST)
endef

define HELLO_TA_INSTALL_TARGET_CMDS
	$(HELLO_TA_INSTALL_TA)
	$(HELLO_TA_INSTALL_HOST)
endef

$(eval $(generic-package))
