To sync [JoyMapper](https://diaohs.com/joymapper/) settings —

`~/Library/Containers/com.diaohs.joym/Data/Library/Application Support/com.diaohs.joym/settings.bin`

— between different users on the same system.

## Usage

After changing mappings in the app, you can sync the changes to this repository via:

```sh
./sync-settings.sh
```

This manual script copies the live settings file into this repo clone so `git diff` shows what changed.

> [!WARNING]
> **Do not symlink JoyMapper's settings path to this repo**, because JoyMapper can't reliably read/write through a symlink that points outside its container (because it is sandboxed) — it silently resets to a fresh trial when it fails to load settings that way.
