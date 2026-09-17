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

## Saved profiles

Named git tags snapshot whole `settings.bin` configurations so you can switch between them without losing either one.

- `profile/dual-joycon-full-parity` — Both Joy-Cons independently support all actions (built for using them one-at-a-time, each fully capable on its own).

To switch to a saved profile:

```bash
git checkout <tag-name> -- settings.bin
./sync-settings.sh --restore
```

This overwrites the live JoyMapper settings with the tagged `settings.bin` (backing up the current live file first), then leaves your working tree on `<tag-name>`'s version of `settings.bin` — run `git checkout main -- settings.bin` afterward if you want your working tree back on `main`'s version without touching the live settings again.

To save the current live config as a new named profile before switching away from it:

```bash
./sync-settings.sh
git add settings.bin settings.readable.json && git commit -m "Update settings"
git tag -a profile/<name> -m "<short description>"
git push origin profile/<name>
```
