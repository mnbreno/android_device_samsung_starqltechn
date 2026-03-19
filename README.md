# Samsung Galaxy S9 SM-G9600 (starqltechn) – TWRP device tree

TWRP device tree for **Galaxy S9 Qualcomm SM-G9600** (Latin America / Brazil, dual SIM).

This branch targets devices running **Android 10** firmware. Build with the TWRP 9.0 manifest; the resulting recovery is intended for use on Android 10.

---

## Build (Android 10)

### Manifest

Use the minimal TWRP manifest (twrp-9.0). Example:

```bash
repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-9.0
```

Add this device tree (android-10 branch) and sync:

```bash
# In .repo/local_manifests/ (create if needed), add a manifest that includes:
# <project path="device/samsung/starqltechn" name="mnbreno/android_device_samsung_starqltechn" remote="github" revision="android-10" />
repo sync
```

Then build:

```bash
. build/envsetup.sh
lunch omni_starqltechn-eng
mka recoveryimage
```

The recovery image (or `recovery.img` tar for Odin) will be in the build output.

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
