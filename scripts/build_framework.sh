#!/bin/bash

PREFIX=$1
LIB_NAME=$2
LIB_VERSION=$3
LIB_FRAMEWORK=$PREFIX/framework/$LIB_NAME.framework
LIB_XCFRAMEWORK=$PREFIX/xcframework/$LIB_NAME.xcframework

# build framework
rm -rf $LIB_FRAMEWORK

mkdir -p $LIB_FRAMEWORK/Headers
cp -R $PREFIX/include/$LIB_NAME/ $LIB_FRAMEWORK/Headers

cp $PREFIX/lib/$LIB_NAME.a $LIB_FRAMEWORK/$LIB_NAME

cat > $LIB_FRAMEWORK/Info.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleExecutable</key>
	<string>$LIB_NAME</string>
	<key>CFBundleIdentifier</key>
	<string>org.ffmpeg.$LIB_NAME</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$LIB_NAME</string>
	<key>CFBundlePackageType</key>
	<string>FMWK</string>
	<key>CFBundleShortVersionString</key>
	<string>$LIB_VERSION</string>
	<key>CFBundleVersion</key>
	<string>$LIB_VERSION</string>
	<key>CFBundleSignature</key>
	<string>????</string>
	<key>NSPrincipalClass</key>
	<string></string>
</dict>
</plist>
EOF

# build xcframework
rm -rf $LIB_XCFRAMEWORK

# xcodebuild \
#   -create-xcframework \
#   -framework $LIB_FRAMEWORK \
#   -output $LIB_XCFRAMEWORK
# 
# error: unable to find any specific architecture information in the binary at xxx

mkdir -p $LIB_XCFRAMEWORK/macos-x86_64
cp -R $LIB_FRAMEWORK $LIB_XCFRAMEWORK/macos-x86_64

cat > $LIB_XCFRAMEWORK/Info.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>AvailableLibraries</key>
	<array>
		<dict>
			<key>LibraryIdentifier</key>
			<string>macos-x86_64</string>
			<key>LibraryPath</key>
			<string>$LIB_NAME.framework</string>
			<key>SupportedArchitectures</key>
			<array>
				<string>x86_64</string>
			</array>
			<key>SupportedPlatform</key>
			<string>macos</string>
		</dict>
	</array>
	<key>CFBundlePackageType</key>
	<string>XFWK</string>
	<key>XCFrameworkFormatVersion</key>
	<string>1.0</string>
</dict>
</plist>
EOF
