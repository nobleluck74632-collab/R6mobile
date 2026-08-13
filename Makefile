TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = RainbowSixMobile

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = R6MobileMod

R6MobileMod_FILES = Tweak.x
R6MobileMod_CFLAGS = -fobjc-arc
R6MobileMod_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
