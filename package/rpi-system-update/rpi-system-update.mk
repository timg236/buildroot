################################################################################
#
# rpi-system-update
#
################################################################################

RPI_SYSTEM_UPDATE_VERSION = master
RPI_SYSTEM_UPDATE_SITE = $(call github,timg236,rpi-system-update,$(RPI_SYSTEM_UPDATE_VERSION))
RPI_SYSTEM_UPDATE_LICENSE = Apache-2.0
RPI_SYSTEM_UPDATE_LICENSE_FILES = LICENSE

ifeq ($(BR2_PACKAGE_SYSTEMD)$(BR2_PACKAGE_RPI_SYSTEM_UPDATE_MONITOR),yy)
define RPI_SYSTEM_UPDATE_INSTALL_MONITOR_CMDS
	$(INSTALL) -D -m 0644 $(@D)/rpi-system-update-download.timer $(TARGET_DIR)/lib/systemd/system/rpi-system-update-download.timer
	$(INSTALL) -D -m 0644 $(@D)/rpi-system-update-download.service $(TARGET_DIR)/lib/systemd/system/rpi-system-update-download.service
	$(INSTALL) -D -m 0644 $(@D)/rpi-system-update-upgrade.service $(TARGET_DIR)/lib/systemd/system/rpi-system-update-upgrade.service
endef
endif

ifeq ($(BR2_PACKAGE_SYSTEMD)$(BR2_PACKAGE_RPI_SYSTEM_UPDATE_DOCKER_APPLICATION),yy)
define RPI_SYSTEM_UPDATE_UPDATE_DOCKER_APPLICATION_CMDS
	$(INSTALL) -D -m 0644 $(@D)/rpi-system-update-application-init.service $(TARGET_DIR)/lib/systemd/system/rpi-system-update-application-init.service
	$(INSTALL) -D -m 0644 $(@D)/rpi-system-update-application-monitor.service $(TARGET_DIR)/lib/systemd/system/rpi-system-update-application-monitor.service
	$(INSTALL) -D -m 0644 $(@D)/docker/$(BR2_PACKAGE_RPI_SYSTEM_UPDATE_DOCKER_SERVICE_NAME).service $(TARGET_DIR)/lib/systemd/system/$(BR2_PACKAGE_RPI_SYSTEM_UPDATE_DOCKER_SERVICE_NAME).service
	$(INSTALL) -D -m 0644 $(@D)/docker/$(BR2_PACKAGE_RPI_SYSTEM_UPDATE_DOCKER_SERVICE_NAME).yml $(TARGET_DIR)/etc/rpi-system-update-compose.yml
	$(INSTALL) -D -m 0755 $(@D)/applications/docker $(TARGET_DIR)/usr/lib/rpi-system-update/functions
	echo DOCKER_SERVICE_NAME=$(BR2_PACKAGE_RPI_SYSTEM_UPDATE_DOCKER_SERVICE_NAME) >> $(TARGET_DIR)/etc/default/rpi-system-update
endef
else
define RPI_SYSTEM_UPDATE_UPDATE_DOCKER_APPLICATION_CMDS
	rm -f $(TARGET_DIR)/usr/lib/rpi-system-update/functions
endef
endif

ifeq ($(BR2_PACKAGE_SYSTEMD)$(BR2_PACKAGE_RPI_SYSTEM_UPDATE_AUTO_INSTALL),yy)
define RPI_SYSTEM_UPDATE_INSTALL_AUTO_INSTALL_CMDS
	echo BOOT_PARTITION_MB=$(BR2_PACKAGE_RPI_SYSTEM_UPDATE_AUTO_INSTALL_BOOT_PARTITION_MB) >> $(TARGET_DIR)/etc/default/rpi-system-update
	$(INSTALL) -D -m 0644 $(@D)/rpi-system-update-install.service $(TARGET_DIR)/lib/systemd/system/rpi-system-update-install.service
endef
endif

ifeq ($(BR2_PACKAGE_SYSTEMD)$(BR2_PACKAGE_RPI_SYSTEM_UPDATE_ENCRYPT_APPLICATION_FS),yy)
define RPI_SYSTEM_UPDATE_INSTALL_CRYPT_CMDS
	 echo ENCRYPT_APPLICATION_FS=1 >> $(TARGET_DIR)/etc/default/rpi-system-update
endef
endif

define RPI_SYSTEM_UPDATE_INSTALL_COMMON_CMDS
	$(INSTALL) -D -m 0755 $(@D)/rpi-system-update $(TARGET_DIR)/bin/rpi-system-update
	$(INSTALL) -D -m 0755 $(BR2_PACKAGE_RPI_SYSTEM_UPDATE_PUBLIC_KEY) $(TARGET_DIR)/var/lib/rpi-system-update/rpi-system-update.pem
	$(INSTALL) -D -m 0644 $(@D)/rpi-system-update.default $(TARGET_DIR)/etc/default/rpi-system-update
	echo VERSION=$(BR2_PACKAGE_RPI_SYSTEM_UPDATE_VERSION) >> $(TARGET_DIR)/etc/default/rpi-system-update
	echo UPDATE_URL=$(BR2_PACKAGE_RPI_SYSTEM_UPDATE_URL) >> $(TARGET_DIR)/etc/default/rpi-system-update
	echo BOOT_BLKDEV=$(BR2_PACKAGE_RPI_SYSTEM_UPDATE_BOOT_DEVICE) >> $(TARGET_DIR)/etc/default/rpi-system-update
endef

define RPI_SYSTEM_UPDATE_INSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/etc/default/rpi-system-update
	$(RPI_SYSTEM_UPDATE_INSTALL_COMMON_CMDS)
	$(RPI_SYSTEM_UPDATE_INSTALL_AUTO_INSTALL_CMDS)
	$(RPI_SYSTEM_UPDATE_INSTALL_MONITOR_CMDS)
	$(RPI_SYSTEM_UPDATE_UPDATE_DOCKER_APPLICATION_CMDS)
	$(RPI_SYSTEM_UPDATE_INSTALL_SYSTEMD)
	$(RPI_SYSTEM_UPDATE_ADMIN_SSH_LOGIN_CMDS)
	$(RPI_SYSTEM_UPDATE_INSTALL_CRYPT_CMDS)
endef

$(eval $(generic-package))
