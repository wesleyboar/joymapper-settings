#!/usr/bin/env bash
# Copies JoyMapper's live settings into this repo clone and regenerates the
# human-readable rendering, so `git diff`/`git log` show what changed. Run
# manually after changing mappings in the app.
#
# JoyMapper is sandboxed, so its settings file must stay a real file at its
# container path (do not replace it with a symlink into this repo — that has
# broken purchase/trial state before).
set -euo pipefail

SRC="$HOME/Library/Containers/com.diaohs.joym/Data/Library/Application Support/com.diaohs.joym/settings.bin"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$REPO_DIR/settings.bin"
READABLE="$REPO_DIR/settings.readable.json"

if [ ! -f "$SRC" ]; then
  echo "error: JoyMapper settings not found at:" >&2
  echo "  $SRC" >&2
  exit 1
fi

cp -p "$SRC" "$DEST"
"$REPO_DIR/write-settings.sh" "$DEST" > "$READABLE"
echo "Copied live settings into $DEST and regenerated $READABLE"

cd "$REPO_DIR"
if [ -z "$(git status --porcelain -- settings.bin settings.readable.json)" ]; then
  echo "No changes since last sync."
else
  echo
  echo "Changed. Review and commit when ready:"
  echo "  git -C \"$REPO_DIR\" diff -- settings.readable.json"
  echo "  git -C \"$REPO_DIR\" add settings.bin settings.readable.json && git -C \"$REPO_DIR\" commit -m 'Update settings'"
fi
