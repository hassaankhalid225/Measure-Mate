# Measure Mate — release & signing

## App identity

| | |
|---|---|
| App name | **Measure Mate** |
| Package / applicationId | `com.gts.cal.mesure` |
| iOS bundle identifier | `com.gts.cal.mesure` |
| versionName | `0.2` |
| versionCode | `2` |
| minSdk | 24 (Android 7.0) |
| targetSdk | 36 (Android 16) |
| ABIs | `arm64-v8a`, `armeabi-v7a`, `x86_64` |

> The package name is spelled **`mesure`**, exactly as supplied. Play Store
> package names are permanent — they cannot be changed after the first upload,
> only replaced with a brand-new listing.

## Release history

| Version | Code | Notes |
|---|---|---|
| 0.2 | 2 | Added Loan EMI, Tip & split, Number base converter; drag-to-reorder home screen. |
| 0.1 | 1 | First Play Store release. |

Every upload needs a **higher versionCode** than the last one. Bump the `+N` in
`pubspec.yaml` and the pinned `versionName` in `android/app/build.gradle.kts`
together.

## Keystore

| | |
|---|---|
| File | `android/measure-mate.jks` |
| Format | PKCS#12 |
| Alias | `measure-mate` |
| Store password | `MeasureMate@2026` |
| Key password | `MeasureMate@2026` |
| Key algorithm | RSA 2048-bit |
| Signature algorithm | SHA384withRSA |
| Created | 17 Aug 2026 |
| Valid until | 02 Jan 2054 (10 000 days) |
| Owner / Issuer | `CN=Measure Mate, OU=GTS, O=GTS, L=Lahore, ST=Punjab, C=PK` |
| SHA-1 | `2E:6E:19:07:65:8D:47:BC:AA:94:05:DB:5D:24:23:3E:D2:49:FE:77` |
| SHA-256 | `A0:FF:C4:9F:97:4A:53:B1:85:E4:B6:52:12:2B:C7:DB:5B:88:D8:BC:12:FE:A3:06:80:5A:31:EB:D4:83:43:93` |

Credentials are read from `android/key.properties`. Both that file and the
`.jks` are in `.gitignore`; if `key.properties` is absent the build falls back
to debug signing so a fresh checkout still runs.

### ⚠️ Back this up

Google Play binds an app to its signing key **permanently**. If the keystore or
its password is lost, `com.gts.cal.mesure` can never be updated again — the only
option is publishing a new listing and losing all installs and reviews.

Keep an offline copy of `measure-mate.jks` **and** the password in at least two
places (password manager + encrypted backup). Do not email them.

If Play App Signing is enabled at upload (recommended), this key becomes the
*upload key*, which Google can help reset if lost — but the backup rule still
applies until that is switched on.

### Regenerating the keystore

Only possible **before** the first Play upload:

```bash
keytool -genkeypair -v -keystore android/measure-mate.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias measure-mate
```

Then update the passwords in `android/key.properties`.

## Building

```bash
flutter build appbundle --release   # build/app/outputs/bundle/release/app-release.aab
flutter build apk --release         # build/app/outputs/flutter-apk/app-release.apk
```

Upload the **.aab** to Play Console. The **.apk** is for direct install and
testing — Play does not accept APKs for new apps.

Smaller per-device APKs for sideloading:

```bash
flutter build apk --release --split-per-abi
```

### Verifying a build

```bash
# identity
aapt2 dump badging app-release.apk | findstr "package: application-label"

# signature — must show CN=Measure Mate, not "Android Debug"
apksigner verify --print-certs app-release.apk
```

## Google Play compliance

Handled in the project:

- [x] **App Bundle** — `.aab` produced for upload.
- [x] **Target API level** — targetSdk 36, above Play's current requirement.
- [x] **64-bit support** — `arm64-v8a` included.
- [x] **Release signing** — signed with the release key, not the debug key.
- [x] **No permissions** — the manifest declares no `INTERNET` and no runtime
      permissions. The only entry is `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`,
      which AndroidX adds automatically and is signature-level.
- [x] **Edge-to-edge** — required for targetSdk 35+; every screen wraps its body
      in `SafeArea`, so nothing sits under the gesture bar.
- [x] **No ads, no analytics, no trackers, no third-party SDKs.** The only
      dependency is `shared_preferences` (local storage).
- [x] **No debug banner, no debug logging in release.**

Still to be done in Play Console (not code):

- [ ] **Privacy policy URL** — required for every app. Host `PRIVACY_POLICY.md`
      (GitHub Pages, Google Sites, or any static host) and paste the link.
- [ ] **Data safety form** — see the answers below.
- [ ] **Content rating questionnaire** — a utility app with no user content
      rates "Everyone" / PEGI 3.
- [ ] **Target audience & content** — not directed at children (choose 13+ to
      avoid Families policy obligations, unless the client wants otherwise).
- [ ] **Store listing** — title, short & full description, 512×512 icon,
      feature graphic (1024×500), and at least 2 phone screenshots.
- [ ] **App category** — Tools.
- [ ] **App access** — "All functionality is available without special access";
      there is no login.
- [ ] **Ads declaration** — "No, my app does not contain ads".

### Data safety answers

| Question | Answer |
|---|---|
| Does your app collect or share any user data? | **No** |
| Is all user data encrypted in transit? | N/A — no data leaves the device |
| Do you provide a way to request data deletion? | N/A — nothing is collected; uninstalling removes the local settings |

The app stores only the user's own preferences (theme, chosen tools, last-used
units) in Android's local `SharedPreferences`. That is on-device storage, not
collection, and does not need to be declared.

## App icon

Generated from `assets/icon/icon.png` (512×512 PNG):

```bash
dart run flutter_launcher_icons
```

This writes every Android mipmap density, the adaptive icon layers and the iOS
`AppIcon` set. Re-run after any change to the source image, then rebuild.

The same 512×512 PNG is also what Play Console wants for the store listing icon.
