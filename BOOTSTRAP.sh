#!/bin/bash
# bootstrap the source

if [ -f "./source_root.attr_override.list" ]; then
  cat "./source_root.attr_override.list" | while IFS= read -r TARGET_LINE; do
    TGT_FILE_OR_DIR="$(echo "${TARGET_LINE}" | cut -d' ' -f1)"
    TGT_ATTR="$(echo "${TARGET_LINE}" | cut -d' ' -f2)"
    chmod -Rv "${TGT_ATTR}" "./${TGT_FILE_OR_DIR}" || exit 1
  done
else
  echo 'Pro tip: Always run ALL scripts of this project while your PWD is the root of the cloned repository.'
  exit 1
fi

exit 0
