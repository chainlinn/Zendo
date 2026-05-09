APP_NAME := Zendo
BUILD_DIR := .build
APP_BUNDLE := $(BUILD_DIR)/$(APP_NAME).app
SOURCES := $(shell find Zendo -name '*.swift' | sort)
SDK_PATH := $(shell xcrun --show-sdk-path --sdk macosx)
SWIFTFLAGS := -sdk $(SDK_PATH) -target arm64-apple-macos14.0 -O

.PHONY: build run clean debug

build: $(APP_BUNDLE)

$(APP_BUNDLE): $(SOURCES) Zendo/Resources/Info.plist
	@mkdir -p $(APP_BUNDLE)/Contents/MacOS
	@mkdir -p $(APP_BUNDLE)/Contents/Resources
	@echo "Compiling $(words $(SOURCES)) Swift files..."
	swiftc $(SWIFTFLAGS) \
		-o $(APP_BUNDLE)/Contents/MacOS/$(APP_NAME) \
		$(SOURCES)
	@cp Zendo/Resources/Info.plist $(APP_BUNDLE)/Contents/Info.plist
	@if [ -f Zendo.icns ]; then cp Zendo.icns $(APP_BUNDLE)/Contents/Resources/; fi
	@echo "Built $(APP_BUNDLE)"

run: build
	open $(APP_BUNDLE)

debug: SWIFTFLAGS := -sdk $(SDK_PATH) -target arm64-apple-macos14.0 -g -Onone
debug: build

clean:
	rm -rf $(BUILD_DIR)

DMG_DIR := $(BUILD_DIR)/dmg
DMG_FILE := $(BUILD_DIR)/Zendo.dmg

dmg: build
	@mkdir -p $(DMG_DIR)
	@cp -R $(APP_BUNDLE) $(DMG_DIR)/
	@ln -sf /Applications $(DMG_DIR)/Applications
	@hdiutil create -volname Zendo -srcfolder $(DMG_DIR) -ov -format UDZO $(DMG_FILE) 2>&1 | tail -1
	@rm -rf $(DMG_DIR)
	@echo "DMG: $(DMG_FILE)"

# Generate Xcode project
xcode:
	swift package init --type executable --name Zendo 2>/dev/null || true
	@echo "Note: For full Xcode integration, open the project in Xcode and add files manually,"
	@echo "or use 'xcodebuild' with the generated project."
