To sync [JoyMapper](https://diaohs.com/joymapper/) settings —

`~/Library/Containers/com.diaohs.joym/Data/Library/Application Support/com.diaohs.joym/settings.bin`

— between different users on the same system.

## Scripts

- `sync-settings.sh` — Copies the live settings into this repo and regenerates `settings.readable.json`. Run after changing mappings in the app.
- `sync-settings.sh --restore` — Reverse direction: copies this repo's `settings.bin` onto the live path (e.g. to apply settings pulled from another machine). Backs up the live file first and asks for confirmation.
- `write-settings.sh <path>` — Decodes a `settings.bin` file to a readable JSON array on stdout (binary-valued fields like `int64`/`bool` show their name and type, not their value — not printable text, not decoded here).


> [!NOTE]
> Nothing runs automatically — run `./sync-settings.sh` whenever you want to sync, then review `git diff -- settings.readable.json` and commit/push at will. Use `./sync-settings.sh --restore` to push the repo's settings back onto this machine.

> [!WARNING]
> **Do not symlink JoyMapper's settings path to this repo**, because JoyMapper can't reliably read/write through a symlink that points outside its container (because it is sandboxed) — it silently resets to a fresh trial when it fails to load settings that way.
