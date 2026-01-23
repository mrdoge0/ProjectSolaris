#!/bin/bash
# Build script
# (c) 2026 mrdoge0 and the Project Solaris contributors, Free Software Licensed under GPLv3.

# Command syntax error
cmdline_syntax_error() {
  echo 'Usage: ./brunch.sh [target]'
  echo 'Examples: ./brunch.sh Pong'
  echo '          ./brunch.sh Asteroids'
  echo '          ./brunch.sh Spacewar'
  echo '          ./brunch.sh gsi_qcom'
  exit 1
}

# Check for command line syntax
[ -z "${1}" ] && cmdline_syntax_error

# Check for PWD is a Project Solaris source root
if [ -f "./.PROJECTSOLARIS_SOURCE_MARK" ] || [ -f "./source_root.attr_override.list" ]; then
  echo 'Checking if the PWD is the source root... ok'
else
  echo 'Checking if the PWD is the source root... error'
  echo 'Pro tip: Always run ALL scripts of this project while your PWD is the root of the cloned repository.'
  exit 1
fi

# Declare target
BUILD_TGT="${1}"

# Check for existence of target
if [ -f "./targets/${BUILD_TGT}/target_build.sh" ]; then
  echo "Checking for existence of target \"${BUILD_TGT}\"... ok"
else
  echo "Checking for existence of target \"${BUILD_TGT}\"... error"
  echo "ERROR: Target \"${BUILD_TGT}\" does NOT exist in source!"
  exit 1
fi

# Source functions
source ./build_functions.sh

# Ready, set, go!
echo 'BUILDING TARGET!!!'

# BUILD!
source ./targets/${BUILD_TGT}/target_build.sh

# Exit 0
exit 0
