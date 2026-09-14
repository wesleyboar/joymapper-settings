To sync [JoyMapper](https://diaohs.com/joymapper/) settings —

`~/Library/Containers/com.diaohs.joym/Data/Library/Application Support/com.diaohs.joym/settings.bin`

— between different users on the same system.

## Usage

After changing mappings in the app, run:

```
./sync-settings.sh
```

This copies the live settings file into this repo clone so `git diff` shows what changed. Commit/push at will — it's a manual, run-when-you-want-it script, not a background process.

**Do not symlink JoyMapper's settings path to this repo.** JoyMapper is sandboxed and can't reliably read/write through a symlink that points outside its container — it silently resets to a fresh trial when it fails to load settings that way.
