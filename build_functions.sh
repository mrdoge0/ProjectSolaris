# no shebang, this is meant to be sourced
# Build functions
# (c) 2026 mrdoge0 and the Project Solaris contributors, Free Software Licensed under GPLv3.

## 
## INSTALL PATCHSET
## 
install_patchset() {
  PATCHSET="${1}"

  # Check if patchset exists
  [ ! -d "./rom-patchsets/${PATCHSET}" ] && echo "ERROR: Patchset '${PATCHSET}' does not exist!" && exit 1

  # Log process
  echo "INFO: Applying patchset ${PATCHSET}..."

  # Handle system.delete.list
  if [ -f "./rom-patchsets/${PATCHSET}/system.delete.list" ]; then
    cat "./rom-patchsets/${PATCHSET}/system.delete.list" | while IFS= read -r TARGET_FILE_OR_DIR; do
      rm -rvf "./work/system/system/${TARGET_FILE_OR_DIR}" || exit 1
    done
  fi

  # Handle system_ext.delete.list
  if [ -f "./rom-patchsets/${PATCHSET}/system_ext.delete.list" ]; then
    cat "./rom-patchsets/${PATCHSET}/system_ext.delete.list" | while IFS= read -r TARGET_FILE_OR_DIR; do
      rm -rvf "./work/system_ext/${TARGET_FILE_OR_DIR}" || exit 1
    done
  fi

  # Handle product.delete.list
  if [ -f "./rom-patchsets/${PATCHSET}/product.delete.list" ]; then
    cat "./rom-patchsets/${PATCHSET}/product.delete.list" | while IFS= read -r TARGET_FILE_OR_DIR; do
      rm -rvf "./work/product/${TARGET_FILE_OR_DIR}" || exit 1
    done
  fi

  # Handle add-or-replace
  if [ -d "./rom-patchsets/${PATCHSET}/add-or-replace" ]; then
    if [ -d "./rom-patchsets/${PATCHSET}/add-or-replace/system" ]; then
      cp -rvf "./rom-patchsets/${PATCHSET}/add-or-replace/system/*" "./work/system/system/" || exit 1
    fi
    if [ -d "./rom-patchsets/${PATCHSET}/add-or-replace/system_ext" ]; then
      cp -rvf "./rom-patchsets/${PATCHSET}/add-or-replace/system_ext/*" "./work/system_ext/" || exit 1
    fi
    if [ -d "./rom-patchsets/${PATCHSET}/add-or-replace/product" ]; then
      cp -rvf "./rom-patchsets/${PATCHSET}/add-or-replace/product/*" "./work/product/" || exit 1
    fi
  fi
}
