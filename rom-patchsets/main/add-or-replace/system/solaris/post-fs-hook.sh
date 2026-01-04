#!/system/bin/sh
# Project Solaris post-fs hook

# Inherit solaris.conf
source /system/solaris/solaris.conf
#SPOOF_PROPS='true'
#BRAND='Nothing'
#MANUFACTURER="${BRAND}"
#DEVICE='Spacewar'
#MODEL='A063'
#MARKETNAME='Nothing Phone (1)'
#FINGERPRINT='Nothing/Spacewar/Spacewar:15/AQ3A.240929.001/2512191652:user/release-keys'

# Resetprop path
RP_BIN='/system/solaris/resetprop'

# Resetprops
if [ "${SPOOF_PROPS}" == 'true' ]; then
  "${RP_BIN}" -n 'ro.product.brand' "${BRAND}"
  "${RP_BIN}" -n 'ro.product.manufacturer' "${MANUFACTURER}"
  "${RP_BIN}" -n 'ro.product.device' "${DEVICE}"
  "${RP_BIN}" -n 'ro.product.model' "${MODEL}"
  "${RP_BIN}" -n 'ro.product.brand_device_name' "${MARKETNAME}"
  "${RP_BIN}" -n 'ro.build.fingerprint' "${FINGERPRINT}"
fi
