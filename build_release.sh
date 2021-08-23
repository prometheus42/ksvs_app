#! /bin/bash

PROGRAM="ksvs-app"
VERSION="v0.2"

echo "Building:" ${PROGRAM}

# clean build directory
echo "Cleaning build directories..."
flutter clean

# build for web deployment
echo "Building web version..."
flutter build web --base-href=/mq/ --no-sound-null-safety
cd build || exit
mv web "${PROGRAM}-web"
zip -r "${PROGRAM}-${VERSION}-web.zip" "${PROGRAM}-web"
cd ..
mv "build/${PROGRAM}-${VERSION}-web.zip" .

# build Android version
echo "Building Android version..."
#flutter build appbundle --no-sound-null-safety
#cp build/app/outputs/bundle/release/app-release.aab ./${PROGRAM}-${VERSION}-release.aab
flutter build apk --split-per-abi --no-sound-null-safety
cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk ./${PROGRAM}-${VERSION}-arm64-v8a-release.apk
cp build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk ./${PROGRAM}-${VERSION}-armeabi-v7a-release.apk
cp build/app/outputs/flutter-apk/app-x86_64-release.apk ./${PROGRAM}-${VERSION}-x86_64-release.apk
