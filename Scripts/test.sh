#!/usr/bin/env bash

set -o pipefail
xcodebuild -version
xcodebuild -showsdks

# Build Framework in Debug and Run Tests if specified
if [ $RUN_TESTS == "YES" ]; then
  xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -sdk "$SDK" -destination "$DESTINATION" -configuration Debug ONLY_ACTIVE_ARCH=NO test | xcpretty -c;
else
  xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -sdk "$SDK" -destination "$DESTINATION" -configuration Debug ONLY_ACTIVE_ARCH=NO build | xcpretty -c;
fi

# Build Framework in ReleaseTest and Run Tests if specified
if [ $RUN_TESTS == "YES" ]; then
  xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -sdk "$SDK" -destination "$DESTINATION" -configuration ReleaseTest ONLY_ACTIVE_ARCH=NO test | xcpretty -c;
else
  xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -sdk "$SDK" -destination "$DESTINATION" -configuration ReleaseTest ONLY_ACTIVE_ARCH=NO build | xcpretty -c;
fi

# Run `pod lib lint` if specified
if [ $POD_LINT == "YES" ]; then
  pod lib lint --allow-warnings;
fi
