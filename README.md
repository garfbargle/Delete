# Delete

A minimal downstream build of upstream Chromium for Android, using Chromium's experimental Desktop Android extension runtime.

## Principles

- Chromium is pinned to an explicit upstream revision.
- Nothing updates automatically.
- GitHub Actions builds the pinned source and uploads an APK artifact.
- Releases are manual and explicit.
- Local changes live as a small patch stack instead of a Chromium source mirror.

## Current baseline

Chromium `151.0.7922.71`, ARM64, unbranded Chromium, built with `is_desktop_android = true` so the upstream Android extension runtime is included.

## Runner

Chromium needs substantially more disk/RAM than a normal GitHub-hosted runner provides. The workflows target a self-hosted Linux x64 runner with the labels:

`self-hosted`, `linux`, `x64`, `chromium`

The checkout/build cache is kept outside the Actions workspace at `$HOME/.cache/delete-chromium` by default. Set `DELETE_WORKDIR` on the runner to move it elsewhere.

## Build

Run **Actions → Build Android → Run workflow**. The result is uploaded as an Actions artifact.

Run **Actions → Release → Run workflow** only when we intentionally want to publish a release.
