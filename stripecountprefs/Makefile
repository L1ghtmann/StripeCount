ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = StripeCountPrefs

StripeCountPrefs_FILES = StripeCountRootListController.m
StripeCountPrefs_FRAMEWORKS = UIKit
StripeCountPrefs_PRIVATE_FRAMEWORKS = Preferences
StripeCountPrefs_INSTALL_PATH = /Library/PreferenceBundles
StripeCountPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
