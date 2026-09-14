#!/usr/bin/env bash
# Syncs JoyMapper's live settings.bin with this repo clone.
#
# Default direction: copies the live settings into this repo and regenerates
# the human-readable rendering, so `git diff`/`git log` show what changed.
# Run manually after changing mappings in the app.
#
# --restore reverses direction: copies this repo's settings.bin onto the live
# path, so you can push a committed settings file (e.g. from another machine)
# into the app. The live file is backed up first.
#
# JoyMapper is sandboxed, so its settings file must stay a real file at its
# container path (do not replace it with a symlink into this repo — that has
# broken purchase/trial state before).
set -euo pipefail

RESTORE=0
for arg in "$@"; do
  case "$arg" in
    --restore) RESTORE=1 ;;
    *)
      echo "error: unknown argument: $arg" >&2
      echo "usage: $0 [--restore]" >&2
      exit 1
      ;;
  esac
done

LIVE="$HOME/Library/Containers/com.diaohs.joym/Data/Library/Application Support/com.diaohs.joym/settings.bin"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_BIN="$REPO_DIR/settings.bin"
READABLE="$REPO_DIR/settings.readable.json"

if [ -L "$LIVE" ]; then
  echo "error: live settings path is a symlink, refusing to sync:" >&2
  echo "  $LIVE" >&2
  echo "JoyMapper is sandboxed and can't reliably read/write through a symlink" >&2
  echo "that points outside its container — replace it with a real file first." >&2
  exit 1
fi

if [ "$RESTORE" -eq 1 ]; then
  if [ ! -f "$REPO_BIN" ]; then
    echo "error: no settings.bin in repo to restore from:" >&2
    echo "  $REPO_BIN" >&2
    exit 1
  fi

  read -r -p "This will overwrite the live JoyMapper settings at:
  $LIVE
with the repo's committed settings.bin. Continue? [y/N] " reply
  case "$reply" in
    [yY]|[yY][eE][sS]) ;;
    *) echo "Aborted."; exit 1 ;;
  esac

  if [ -f "$LIVE" ]; then
    BACKUP="$LIVE.bak.$(date +%Y%m%d%H%M%S)"
    cp -p "$LIVE" "$BACKUP"
    echo "Backed up live settings to $BACKUP"
  fi

  cp -p "$REPO_BIN" "$LIVE"
  echo "Restored $REPO_BIN onto live settings at $LIVE"
  exit 0
fi

if [ ! -f "$LIVE" ]; then
  echo "error: JoyMapper settings not found at:" >&2
  echo "  $LIVE" >&2
  exit 1
fi

cp -p "$LIVE" "$REPO_BIN"
"$REPO_DIR/write-settings.sh" "$REPO_BIN" > "$READABLE"
echo "Copied live settings into $REPO_BIN and regenerated $READABLE"

cd "$REPO_DIR"
if [ -z "$(git status --porcelain -- settings.bin settings.readable.json)" ]; then
  echo "No changes since last sync."
else
  echo
  echo "Changed. Review and commit when ready:"
  echo "  git -C \"$REPO_DIR\" diff -- settings.readable.json"
  echo "  git -C \"$REPO_DIR\" add settings.bin settings.readable.json && git -C \"$REPO_DIR\" commit -m 'Update settings'"
fi
