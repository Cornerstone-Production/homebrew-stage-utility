# Stage Utility — Homebrew tap

A [Homebrew](https://brew.sh) tap for
[Stage Utility](https://github.com/Cornerstone-Production/Stage-Utility): stage
monitors driven by Planning Center and the gear you already run.

```bash
brew tap Cornerstone-Production/stage-utility
brew install stage-utility
brew services start stage-utility
```

Then open `http://localhost:8788/`.

Configuration and history live in `$(brew --prefix)/var/stage-utility`, outside
the keg, so `brew upgrade` never touches them.

| | |
|---|---|
| `brew services start stage-utility` | run it now and at login |
| `brew services stop stage-utility` | stop it |
| `brew upgrade stage-utility` | move to the newest release |
| `brew services info stage-utility` | is it running, and where are the logs |

The formula installs a prebuilt archive that already contains its own Node
runtime, so it depends on nothing and compiles nothing.

## Which install to use

The [one-line installer](https://github.com/Cornerstone-Production/Stage-Utility#install-it)
registers a **system** service that starts at boot, before anyone logs in, and can
serve on port 80. That is what a stage machine or a Raspberry Pi wants.

Homebrew runs it as a **user** agent that starts at login, on port 8788 only.
That suits a laptop or workstation where the app is one of several things you run.

A Homebrew install is not a git checkout, so **Settings → Advanced → Updates**
reports the running version but does not apply updates — Homebrew owns the files.
Use `brew upgrade stage-utility`.

## This repository

`Formula/stage-utility.rb` is **generated** by the Stage Utility release workflow
and pushed here on every release. Editing it directly will be overwritten; change
`packaging/homebrew/stage-utility.rb` in the
[main repository](https://github.com/Cornerstone-Production/Stage-Utility) instead.

## Licence

This tap — the formula and everything else here — is **BSD-2-Clause**, matching
Homebrew's own licensing, because a formula is a build recipe rather than the
application.

**Stage Utility itself is [GPL-3.0-or-later](https://github.com/Cornerstone-Production/Stage-Utility/blob/main/LICENSE).**
Installing through this tap does not change that: the licence on the recipe is
not the licence on the software it fetches.
