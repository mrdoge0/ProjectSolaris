# no shebang, this is meant to be sourced
# Attribute and SELinux functions
# (c) 2026 mrdoge0 and the Project Solaris contributors, Free Software Licensed under GPLv3.

## 
## INSTALL ATTR_OVERRIDE
## 
install_attr_override() {
  # Syntax:
  # install_attr_override [mountpoint] [source_override] [target_fsconf]

  # Declare vars
  MOUNTPOINT="${1}"
  OVERRIDE="${2}"
  TARGET_FSCONF="${3}"

  # If TARGET_FSCONF is N/A
  if [ -z "${TARGET_FSCONF}" ]; then
    TARGET_FSCONF='na'
  fi

  # Cook it
  cat "${OVERRIDE}" | while IFS= read -r LINE; do
    if [ "${TARGET_FSCONF}" == 'na' ]; then
      TFILE="$(echo "${LINE}" | cut -d' ' -f1)"
      TUID="$(echo "${LINE}" | cut -d' ' -f2)"
      TGID="$(echo "${LINE}" | cut -d' ' -f3)"
      TPERM="$(echo "${LINE}" | cut -d' ' -f4)"
      if [ "${TUID}" != 'na' ] && [ "${TGID}" != 'na' ]; then
        chown -v ${TUID}:${TGID} "${MOUNTPOINT}/${TFILE}"
      fi
      chmod -v ${TPERM} "${MOUNTPOINT}/${TFILE}"
    else
    fi
  done
}
