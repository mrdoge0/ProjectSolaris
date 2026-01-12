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

  # Handle post-apply dependency patchsets
  if [ -f "./rom-patchsets/${PATCHSET}/patchsets.pre_apply.dependencies.list" ]; then
    cat "./rom-patchsets/${PATCHSET}/patchsets.pre_apply.dependencies.list" | while IFS= read -r DEP; do
      install_patchset "${DEP}"
    done
  fi

  # Log process
  echo "INFO: Applying patchset ${PATCHSET}..."

  # Handle system.delete.list
  if [ -f "./rom-patchsets/${PATCHSET}/system.delete.list" ]; then
    cat "./rom-patchsets/${PATCHSET}/system.delete.list" | while IFS= read -r TARGET_FILE_OR_DIR; do
      rm -rvf "./work/system/system/${TARGET_FILE_OR_DIR}" || exit 1
    done
  fi

  # Handle .delete.list for system splits
  for SPLIT in 'system_ext' 'product'; do
    if [ -f "./rom-patchsets/${PATCHSET}/${SPLIT}.delete.list" ]; then
      cat "./rom-patchsets/${PATCHSET}/${SPLIT}.delete.list" | while IFS= read -r TARGET_FILE_OR_DIR; do
        rm -rvf "./work/${SPLIT}/${TARGET_FILE_OR_DIR}" || exit 1
      done
    fi
  done

  # Handle add-or-replace
  if [ -d "./rom-patchsets/${PATCHSET}/add-or-replace" ]; then
    if [ -d "./rom-patchsets/${PATCHSET}/add-or-replace/system" ]; then
      cp -rvf "./rom-patchsets/${PATCHSET}/add-or-replace/system/*" "./work/system/system/" || exit 1
    fi
    for SPLIT in 'system_ext' 'product'; do
      if [ -d "./rom-patchsets/${PATCHSET}/add-or-replace/${SPLIT}" ]; then
        cp -rvf "./rom-patchsets/${PATCHSET}/add-or-replace/${SPLIT}/*" "./work/${SPLIT}/" || exit 1
      fi
    done
  fi

  # Handle system.attr_override.list
  if [ -f "./rom-patchsets/${PATCHSET}/system.attr_override.list" ]; then
    cat "./rom-patchsets/${PATCHSET}/system.attr_override.list" | while IFS= read -r TARGET_LINE; do
      TGT_FILE_OR_DIR="$(echo "${TARGET_LINE}" | cut -d' ' -f1)"
      TGT_ATTR="$(echo "${TARGET_LINE}" | cut -d' ' -f2)"
      chmod -Rv "${TGT_ATTR}" "./work/system/system/${TGT_FILE_OR_DIR}" || exit 1
    done
  fi

  # Handle .attr_override.list for system splits
  for SPLIT in 'system_ext' 'product'; do
    if [ -f "./rom-patchsets/${PATCHSET}/${SPLIT}.attr_override.list" ]; then
      cat "./rom-patchsets/${PATCHSET}/${SPLIT}.attr_override.list" | while IFS= read -r TARGET_LINE; do
        TGT_FILE_OR_DIR="$(echo "${TARGET_LINE}" | cut -d' ' -f1)"
        TGT_ATTR="$(echo "${TARGET_LINE}" | cut -d' ' -f2)"
        chmod -Rv "${TGT_ATTR}" "./work/${SPLIT}/${TGT_FILE_OR_DIR}" || exit 1
      done
    fi
  done

  # Handle prop merges for system
  if [ -f "./rom-patchsets/${PATCHSET}/system.merge.prop" ]; then
    tee -a './work/system/system/build.prop' <<EOF
# PROJECT SOLARIS - From: rom-patchsets/${PATCHSET}/system.merge.prop
$(cat "./rom-patchsets/${PATCHSET}/system.merge.prop")
# end of rom-patchsets/${PATCHSET}/system.merge.prop
EOF
  fi

  # Handle prop merges for system splits
  for SPLIT in 'system_ext' 'product'; do
    if [ -f "./rom-patchsets/${PATCHSET}/${SPLIT}.merge.prop" ]; then
      tee -a "./work/${SPLIT}/etc/build.prop" <<EOF
# PROJECT SOLARIS - From: rom-patchsets/${PATCHSET}/${SPLIT}.merge.prop
$(cat "./rom-patchsets/${PATCHSET}/${SPLIT}.merge.prop")
# end of rom-patchsets/${PATCHSET}/${SPLIT}.merge.prop
EOF
    fi
  done

  # Handle post-apply dependency patchsets
  if [ -f "./rom-patchsets/${PATCHSET}/patchsets.post_apply.dependencies.list" ]; then
    cat "./rom-patchsets/${PATCHSET}/patchsets.post_apply.dependencies.list" | while IFS= read -r DEP; do
      install_patchset "${DEP}"
    done
  fi
}

## 
## DOWNLOAD IMAGES
## 
dl_images() {
  case "${1}" in
    atom)
    latest)
    *) echo 'Specify atom or latest to dl_images.'
       exit 1;;
  esac
}
