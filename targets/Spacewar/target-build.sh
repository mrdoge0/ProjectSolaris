# no shebang, this is meant to be sourced in build time
# Build target - Nothing Phone (1) (Spacewar)
# (c) 2026 mrdoge0 and the Project Solaris contributors, Free Software Licensed under GPLv3.

# Determine vendor layer and firmware images version
VND_VERSION_ATOM='Spacewar_V3.2-251219-1652'

# Download full images for Pong and Spacewar
dl_images latest Pong logical
dl_images atom "${VND_VERSION_ATOM}" all

# Spacewar NOS4 is obv port from Pong
use_system_images latest Pong
use_vendor_images atom "${VND_VERSION_ATOM}"

# Extract system and it's splits
extract_to_work erofs

# Install main patchset which is what makes Project Solaris, Project Solaris
install_patchset main

# Install solaris.conf, HAL&Glyph downgrades, props etc for Spacewar
install_patchset Spacewar

# Package system and it's splits to Ext4 images
package_work ext4

# Package result both in a Fastboot package, AND a payload update
package_to_out fastboot
package_to_out payload
