PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

PRODUCT_PROPERTY_OVERRIDES += \
    keyguard.no_require_sim=true

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.disable_rescue=true \
    persist.debug.wfd.enable=1 \
    persist.sys.wfd.virtual=0 \
    ro.build.selinux=1

# Disable excessive dalvik debug messages
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.debug.alloc=0

# Backup tool
PRODUCT_COPY_FILES += \
    vendor/opaosp/prebuilt/common/bin/backuptool.sh:install/bin/backuptool.sh \
    vendor/opaosp/prebuilt/common/bin/backuptool.functions:install/bin/backuptool.functions \
    vendor/opaosp/prebuilt/common/bin/50-opaosp.sh:$(TARGET_COPY_OUT_SYSTEM)/addon.d/50-opaosp.sh \
    vendor/opaosp/prebuilt/common/bin/clean_cache.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/clean_cache.sh

ifeq ($(AB_OTA_UPDATER),true)
PRODUCT_COPY_FILES += \
    vendor/opaosp/prebuilt/common/bin/backuptool_ab.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_ab.sh \
    vendor/opaosp/prebuilt/common/bin/backuptool_ab.functions:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_ab.functions \
    vendor/opaosp/prebuilt/common/bin/backuptool_postinstall.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_postinstall.sh
endif

# Backup services whitelist
PRODUCT_COPY_FILES += \
    vendor/opaosp/config/permissions/backup.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/sysconfig/backup.xml

# Signature compatibility validation
PRODUCT_COPY_FILES += \
    vendor/opaosp/prebuilt/common/bin/otasigcheck.sh:install/bin/otasigcheck.sh

# OPAOSP-specific init file
PRODUCT_COPY_FILES += \
    vendor/opaosp/prebuilt/common/etc/init.local.rc:root/init.opaosp.rc

# Copy LatinIME for gesture typing
PRODUCT_COPY_FILES += \
    vendor/opaosp/prebuilt/common/lib/libjni_latinimegoogle.so:$(TARGET_COPY_OUT_SYSTEM)/lib/libjni_latinimegoogle.so

# SELinux file system labels
PRODUCT_COPY_FILES += \
    vendor/opaosp/prebuilt/common/etc/init.d/50selinuxrelabel:$(TARGET_COPY_OUT_SYSTEM)/etc/init.d/50selinuxrelabel

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.software.sip.voip.xml

# Fix Dialer
#PRODUCT_COPY_FILES +=  \
#    vendor/opaosp/prebuilt/common/sysconfig/dialer_experience.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/sysconfig/dialer_experience.xml

# privapp permissions
PRODUCT_COPY_FILES += \
    vendor/opaosp/prebuilt/common/etc/permissions/privapp-permissions-gzr.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/privapp-permissions-gzr.xml \
    vendor/opaosp/prebuilt/common/etc/permissions/privapp-permissions-google.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/privapp-permissions-google.xml \
    vendor/opaosp/config/permissions/privapp-permissions-opaosp-product.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-opaosp.xml

# Fonts
PRODUCT_PACKAGES += \
    FontArbutusSourceOverlay \
    FontArvoLatoOverlay \
    FontRubikRubikOverlay \
    FontGoogleSansOverlay \

-include vendor/opaosp/config/fonts.mk

PRODUCT_PACKAGES += \
     OverlayStub

# Power whitelist
PRODUCT_COPY_FILES += \
    vendor/opaosp/config/permissions/opaosp-power-whitelist.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/sysconfig/opaosp-power-whitelist.xml

# Required packages
PRODUCT_PACKAGES += \
    CellBroadcastReceiver \
    Development \
    SpareParts \
    LockClock \
    su

# Optional packages
PRODUCT_PACKAGES += \
    Basic \
    LiveWallpapersPicker \
    PhaseBeam \
    ThemePicker

# Include explicitly to work around GMS issues
PRODUCT_PACKAGES += \
    libprotobuf-cpp-full \
    librsjni

# AudioFX
PRODUCT_PACKAGES += \
    AudioFX

# Disable vendor restrictions
PRODUCT_RESTRICT_VENDOR_FILES := false

# Extra Optional packages
PRODUCT_PACKAGES += \
    Calculator \
    LatinIME \
    BluetoothExt \
    Launcher3Dark


# Extra tools
PRODUCT_PACKAGES += \
    openvpn \
    e2fsck \
    mke2fs \
    tune2fs \
    fsck.exfat \
    mkfs.exfat \
    ntfsfix \
    ntfs-3g


PRODUCT_PACKAGES += \
    charger_res_images

# Stagefright FFMPEG plugin
PRODUCT_PACKAGES += \
    libffmpeg_extractor \
    libffmpeg_omx \
    media_codecs_ffmpeg.xml

PRODUCT_PROPERTY_OVERRIDES += \
    media.sf.omx-plugin=libffmpeg_omx.so \
    media.sf.extractor-plugin=libffmpeg_extractor.so

# Storage manager
PRODUCT_PROPERTY_OVERRIDES += \
    ro.storage_manager.enabled=true

# easy way to extend to add more packages
-include vendor/extra/product.mk

PRODUCT_PACKAGES += \
    AndroidDarkThemeOverlay \
    SettingsDarkThemeOverlay

# Common overlay
DEVICE_PACKAGE_OVERLAYS += vendor/opaosp/overlay/common

# Boot animation include
ifneq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))

# determine the smaller dimension
TARGET_BOOTANIMATION_SIZE := $(shell \
  if [ $(TARGET_SCREEN_WIDTH) -lt $(TARGET_SCREEN_HEIGHT) ]; then \
    echo $(TARGET_SCREEN_WIDTH); \
  else \
    echo $(TARGET_SCREEN_HEIGHT); \
  fi )

# get a sorted list of the sizes
bootanimation_sizes := $(subst .zip,, $(shell ls vendor/opaosp/prebuilt/common/bootanimation))
bootanimation_sizes := $(shell echo -e $(subst $(space),'\n',$(bootanimation_sizes)) | sort -rn)

# find the appropriate size and set
define check_and_set_bootanimation
$(eval TARGET_BOOTANIMATION_NAME := $(shell \
  if [ -z "$(TARGET_BOOTANIMATION_NAME)" ]; then \
    if [ $(1) -le $(TARGET_BOOTANIMATION_SIZE) ]; then \
      echo $(1); \
      exit 0; \
    fi; \
  fi; \
  echo $(TARGET_BOOTANIMATION_NAME); ))
endef
$(foreach size,$(bootanimation_sizes), $(call check_and_set_bootanimation,$(size)))

ifeq ($(TARGET_BOOTANIMATION_HALF_RES),true)
PRODUCT_COPY_FILES += \
    vendor/opaosp/prebuilt/common/bootanimation/halfres/$(TARGET_BOOTANIMATION_NAME).zip:$(TARGET_COPY_OUT_SYSTEM)/media/bootanimation.zip
else
PRODUCT_COPY_FILES += \
    vendor/opaosp/prebuilt/common/bootanimation/$(TARGET_BOOTANIMATION_NAME).zip:$(TARGET_COPY_OUT_SYSTEM)/media/bootanimation.zip
endif
endif

# Versioning System
# OPAOSP first version.
PRODUCT_VERSION_MAJOR = 10
PRODUCT_VERSION_MINOR = Stable
PRODUCT_VERSION_MAINTENANCE = 2.0
OPAOSP_POSTFIX := -$(shell date +"%Y%m%d-%H%M")
ifdef OPAOSP_BUILD_EXTRA
    OPAOSP_POSTFIX := -$(OPAOSP_BUILD_EXTRA)
endif

ifndef OPAOSP_BUILD_TYPE
    OPAOSP_BUILD_TYPE := UNOFFICIAL
endif

# Set all versions
OPAOSP_VERSION := OnePlusAOSP-$(OPAOSP_BUILD)-$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)-$(OPAOSP_BUILD_TYPE)$(OPAOSP_POSTFIX)
OPAOSP_MOD_VERSION := OnePlusAOSP-$(OPAOSP_BUILD)-$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)-$(OPAOSP_BUILD_TYPE)$(OPAOSP_POSTFIX)

PRODUCT_PROPERTY_OVERRIDES += \
    BUILD_DISPLAY_ID=$(BUILD_ID) \
    opaosp.ota.version=$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE) \
    ro.opaosp.version=$(OPAOSP_VERSION) \
    ro.modversion=$(OPAOSP_MOD_VERSION) \
    ro.opaosp.buildtype=$(OPAOSP_BUILD_TYPE)

# Google sounds
include vendor/opaosp/google/GoogleAudio.mk

EXTENDED_POST_PROCESS_PROPS := vendor/opaosp/tools/opaosp_process_props.py
