# Samsung Galaxy S9 SM-G9600 (starqltechn) – TWRP device tree

TWRP device tree for **Galaxy S9 Qualcomm SM-G9600** (Latin America / Brazil, dual SIM).

This branch targets devices running **Android 10** firmware. Build with the TWRP 9.0 manifest; the resulting recovery is intended for use on Android 10.

---

## Build (Android 10)

### Option 1: Build script (recommended)

On Linux, from this repo root, run:

```bash
./scripts/build-twrp.sh
```

Optional: pass a custom build directory:

```bash
./scripts/build-twrp.sh /path/to/twrp_build
```

The script will init the TWRP Omni manifest (twrp-9.0), add this device tree via local manifest, sync, build, and package `recovery.img` into an Odin-ready `.tar` in the build directory under `release/`.

### Option 2: Manual build

Use the minimal TWRP manifest (twrp-9.0). Example:

```bash
repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-9.0
```

Add this device tree (android-10 branch) in `.repo/local_manifests/` (see [local_manifests_example.xml](local_manifests_example.xml)), then:

```bash
repo sync
. build/envsetup.sh
lunch omni_starqltechn-eng
mka recoveryimage
```

Package for Odin from `out/target/product/starqltechn/recovery.img`:

```bash
tar -cvf twrp-starqltechn-android10.tar recovery.img
```

---

## Releases

After building, create a **GitHub Release** and attach the built `.tar` so others can download it:

1. Go to [Releases](https://github.com/mnbreno/android_device_samsung_starqltechn/releases) → **Create a new release**.
2. Choose a tag (e.g. `v1.0-android10`) and title (e.g. "TWRP starqltechn Android 10").
3. Upload the Odin `.tar` from `twrp_build/release/` (or your build dir) as a release asset.
4. Publish the release.

With [GitHub CLI](https://cli.github.com/):  
`gh release create v1.0-android10 path/to/twrp-starqltechn-android10-*.tar --title "TWRP starqltechn Android 10"`

---

## Next steps (build and release a TWRP build)

1. **Use a Linux build machine** (or WSL/VM) with enough disk (~50 GB+ free) and install:
   - [Android repo tool](https://source.android.com/docs/setup/start#installing-repo): `sudo apt install repo` (or install manually and add to PATH).
   - JDK 8 or 11, `git`, `python2` (twrp-9.0 may need it), and other [AOSP build dependencies](https://source.android.com/docs/setup/start/requirements).
2. **Clone this repo and run the build:**
   ```bash
   git clone https://github.com/mnbreno/android_device_samsung_starqltechn.git
   cd android_device_samsung_starqltechn
   git checkout android-10
   ./scripts/build-twrp.sh
   ```
3. **When the build finishes**, the Odin `.tar` is in `twrp_build/release/`. Create a [new GitHub Release](https://github.com/mnbreno/android_device_samsung_starqltechn/releases/new), choose a tag (e.g. `v1.0-android10`), and upload that `.tar` as an asset.

### Kernel

Prebuilt kernel is included. To build from source:

- [klabit87/android_kernel_g9650-chn – twrp branch](https://github.com/klabit87/android_kernel_g9650-chn/tree/twrp)

---

## Flashing TWRP (Odin)

1. Enable **Developer options** → **OEM unlocking**.
2. Remove all **Google and Samsung accounts** (to avoid FRP blocking the flash).
3. In **Download mode**, turn **Secure download** **OFF** (e.g. long-press Vol Up in Download mode until it shows disabled).
4. Flash the TWRP `.tar` in Odin in the **AP** slot only. Uncheck **Auto Reboot**.
5. After **PASS**, immediately boot to recovery: **Vol Up + Bixby + Power** (hold until TWRP appears). Do not let the system boot first or stock recovery may overwrite TWRP.

---

## Android 10 and vbmeta

On Android 10, **Android Verified Boot (AVB)** can block boot after you flash TWRP or modify system. If the device fails to boot or shows vbmeta/verification errors:

1. Get a **vbmeta image** with verification disabled (from your stock firmware or a pre-made “vbmeta disabled” image for your model).
2. Flash it in Odin (e.g. in **AP** together with the TWRP tar, or in a separate step), or via fastboot if available:
   ```bash
   fastboot --disable-verity --disable-verification flash vbmeta vbmeta.img
   ```

Flashing a vbmeta with verification disabled allows the device to boot with custom recovery and/or root.

---

## Partitions

Non-dynamic layout: `system`, `vendor`, `boot`, `recovery`, `userdata`, etc. Same by-name block devices as on Android 8/9 for this device.

---

## References

- [TeamWin device tree (upstream)](https://github.com/TeamWin/android_device_samsung_starqltechn)
- [TWRP and Android 10](https://twrp.me/site/update/2019/10/23/twrp-and-android-10.html)
