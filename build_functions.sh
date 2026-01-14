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
    atom) case "${3}" in
            logical) echo "Downloading logical images for atom ${2}..."
                     wget -q -o "dlcache/${2}.logical.001" "https://github.com/spike0en/nothing_archive/releases/download/${2}/${2}-image-logical.7z.001"
                     case ${?} in
                       0) echo 'Downloaded.';;
                       *) exit 1;;
                     esac
                     for LOGICALNUM in 002 003 004 005 006; do
                       wget -q -o "dlcache/${2}.logical.${LOGICALNUM}" "https://github.com/spike0en/nothing_archive/releases/download/${2}/${2}-image-logical.7z.${LOGICALNUM}"
                       case ${?} in
                         0|8) echo 'Downloaded or not needed.';;
                         *) exit 1;;
                       esac
                     done;;
            all) echo "Downloading all images for atom ${2}..."
                 wget -q -o "dlcache/${2}.fw" "https://github.com/spike0en/nothing_archive/releases/download/${2}/${2}-image-firmware.7z"
                 case ${?} in
                   0) echo 'Downloaded.';;
                   *) exit 1;;
                 esac
                 wget -q -o "dlcache/${2}.boot" "https://github.com/spike0en/nothing_archive/releases/download/${2}/${2}-image-boot.7z"
                 case ${?} in
                   0) echo 'Downloaded.';;
                   *) exit 1;;
                 esac
                 wget -q -o "dlcache/${2}.logical.001" "https://github.com/spike0en/nothing_archive/releases/download/${2}/${2}-image-logical.7z.001"
                 case ${?} in
                   0) echo 'Downloaded.';;
                   *) exit 1;;
                 esac
                 for LOGICALNUM in 002 003 004 005 006; do
                   wget -q -o "dlcache/${2}.logical.${LOGICALNUM}" "https://github.com/spike0en/nothing_archive/releases/download/${2}/${2}-image-logical.7z.${LOGICALNUM}"
                   case ${?} in
                     0|8) echo 'Downloaded or not needed.';;
                     *) exit 1;;
                   esac
                 done;;
            *) exit 1;;
          esac;;
    latest) echo "Searching Nothing Archive for the latest build of ${2}..."
            A="$(curl -s "https://api.github.com/repos/spike0en/nothing_archive/releases" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | grep "^${2}_" | head -n 1)"
            [ -z "${A}" ] && echo 'Error while searching Nothing Archive for the latest build!' && exit 1
            case "${3}" in
            logical) echo "Downloading logical images for atom ${A}..."
                     wget -q -o "dlcache/${2}_latest.logical.001" "https://github.com/spike0en/nothing_archive/releases/download/${A}/${A}-image-logical.7z.001"
                     case ${?} in
                       0) echo 'Downloaded.';;
                       *) exit 1;;
                     esac
                     for LOGICALNUM in 002 003 004 005 006; do
                       wget -q -o "dlcache/${2}_latest.logical.${LOGICALNUM}" "https://github.com/spike0en/nothing_archive/releases/download/${A}/${A}-image-logical.7z.${LOGICALNUM}"
                       case ${?} in
                         0|8) echo 'Downloaded or not needed.';;
                         *) exit 1;;
                       esac
                     done;;
            all) echo "Downloading all images for atom ${A}..."
                 wget -q -o "dlcache/${2}_latest.fw" "https://github.com/spike0en/nothing_archive/releases/download/${A}/${A}-image-firmware.7z"
                 case ${?} in
                   0) echo 'Downloaded.';;
                   *) exit 1;;
                 esac
                 wget -q -o "dlcache/${2}_latest.boot" "https://github.com/spike0en/nothing_archive/releases/download/${A}/${A}-image-boot.7z"
                 case ${?} in
                   0) echo 'Downloaded.';;
                   *) exit 1;;
                 esac
                 wget -q -o "dlcache/${2}_latest.logical.001" "https://github.com/spike0en/nothing_archive/releases/download/${A}/${A}-image-logical.7z.001"
                 case ${?} in
                   0) echo 'Downloaded.';;
                   *) exit 1;;
                 esac
                 for LOGICALNUM in 002 003 004 005 006; do
                   wget -q -o "dlcache/${2}_latest.logical.${LOGICALNUM}" "https://github.com/spike0en/nothing_archive/releases/download/${A}/${A}-image-logical.7z.${LOGICALNUM}"
                   case ${?} in
                     0|8) echo 'Downloaded or not needed.';;
                     *) exit 1;;
                   esac
                 done;;
            *) exit 1;;
          esac;;
    *) echo 'Specify atom or latest to dl_images. (eg. "dl_images atom Pong_B4.0-251226-1110 all" or "dl_images latest Metroid logical")'
       exit 1;;
  esac
}
