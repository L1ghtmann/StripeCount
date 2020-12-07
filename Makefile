DEBUG=0
ARCHS = arm64 arm64e
INSTALL_TARGET_PROCESSES = Zebra

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = StripeCount

StripeCount_FILES = Tweak.xm
StripeCount_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
