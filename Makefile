TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = SpringBoard

ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ImGuiMetalTweak

ImGuiMetalTweak_FILES = Tweak.xm Menu.mm

ImGuiMetalTweak_FILES += imgui/imgui.cpp imgui/imgui_draw.cpp imgui/imgui_tables.cpp imgui/imgui_widgets.cpp
ImGuiMetalTweak_FILES += imgui/backends/imgui_impl_metal.mm

ImGuiMetalTweak_FRAMEWORKS = UIKit QuartzCore Metal MetalKit

ImGuiMetalTweak_CFLAGS = -fobjc-arc -I./imgui -I./imgui/backends
ImGuiMetalTweak_CXXFLAGS = -std=c++14 -fobjc-arc -I./imgui -I./imgui/backends

include $(THEOS_MAKE_PATH)/tweak.mk
