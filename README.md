# Delete

Minimal downstream Chromium for Android with Chromium's upstream extension-capable Desktop Android runtime.

## Baseline

- Chromium `151.0.7922.71` pinned by exact revision
- ARM64
- package: `com.garfbargle.delete`
- Delete version: `0.1.0` / versionCode `1`
- `is_desktop_android = true`

## Build

GitHub Actions builds the pinned Chromium source and our patch stack. The Chromium checkout/cache lives on a self-hosted runner labeled:

`self-hosted`, `linux`, `x64`, `chromium`

Regular **Build Android** runs upload an unsigned test artifact whose name is not consumed by Library.

## Release

Releases are explicit. Run **Actions → Release → Run workflow** only when we want to ship.

That workflow uploads exactly one raw unsigned APK as the Actions artifact `library-unsigned-apk`. `.library.json` enrolls the package in `garfbargle/library` managed signing. Library aligns/signs it and publishes the stable GitHub Release back to this repository.

Bump `app.version` before each release. `DELETE_VERSION_CODE` must always increase.

## Downstream changes

Keep Chromium changes as ordered patches under `patches/`. Update the pinned Chromium revision deliberately, rebuild, and only promote it after tests pass.
