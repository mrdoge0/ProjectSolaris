# no shebang, this is meant to be sourced in build time
# Build target - Nothing Phone (2) (Pong)
# (c) 2026 mrdoge0 and the Project Solaris contributors, Free Software Licensed under GPLv3.

# Download full images for Pong
dl_images latest Pong all

# Since Pong is natively supported, it's zero problem to make a fully native mod
use_system_images latest Pong
use_vendor_images latest Pong

# Extract system and it's splits
extract_to_work erofs

# Install main patchset which is what makes Project Solaris, Project Solaris
install_patchset main

# Install generic solaris.conf for native builds
install_patchset native-mod

# Package system and it's splits to EROFS images
package_work erofs

# Install vendor_boot mod
install_vendorboot_mod Pong

# Package result both in a Fastboot package, AND a payload update
package_to_out fastboot
package_to_out payload
