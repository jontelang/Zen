TARGET=iphone:clang:8.4
ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

TWEAK_NAME = Zen
Zen_FILES = Tweak.xm
Zen_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
