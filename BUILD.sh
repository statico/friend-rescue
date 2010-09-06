#!/bin/sh

set -e

if [ -z "$FLEX_SDK" ]; then
  echo "FLEX_SDK is not defined. Please set it to the path to "
  echo "your Flex 3 SDK installation."
  echo
  echo "This project requires the Flex 3 SDK:"
  echo "http://opensource.adobe.com/wiki/display/flexsdk/Flex+SDK"
  exit 1
fi

if [ -z "$AS3CORELIB" ]; then
  echo "AS3CORELIB is not defined. Please set it to the path to "
  echo "the the as3corelib directory."
  echo
  echo "This project requires as3corelib, which can be found at:"
  echo "http://github.com/mikechambers/as3corelib"
  exit 1
fi

mxmlc=$FLEX_SDK/bin/mxmlc
output=backend/deploy/FriendRescue.swf

mkdir -vp "$(dirname $output)"

$mxmlc \
  -output $output \
  -source-path+=src \
  -source-path+=$AS3CORELIB/src \
  src/FriendRescue.as

echo
echo "$output created."
