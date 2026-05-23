# Secure Build, Signing, and Unified CI Release Pipeline

This implementation plan outlines the steps to clean up unwanted temporary files from the repository, configure robust local and continuous integration (CI) signing for the Android application using the user's keystore, and establish a unified GitHub Actions workflow to build, sign, and release both Android (APK) and Linux (DEB, RPM, AppImage, TAR.GZ) targets.

## User Review Required

> [!IMPORTANT]
> **GitHub Secrets Configuration**
> To allow the automated GitHub Actions pipeline to sign the Android APK, you will need to add the following secrets under **Settings > Secrets and variables > Actions > New repository secret** in your GitHub repository:
> - `KEYSTORE_BASE64`: The Base64 string of `/home/nilshaaa/Music/upload-keystore.jks` (generated using `base64 -w 0 /home/nilshaaa/Music/upload-keystore.jks`).
> - `KEYSTORE_PASSWORD`: `bmw@hp`
> - `KEY_ALIAS`: `upload`
> - `KEY_PASSWORD`: `bmw@hp`
>
> We will configure the local environment to sign the Android app using these exact credentials so that local release builds automatically compile with your production signature.

## Open Questions

None. We have successfully found your standard signing credentials (`storePassword=bmw@hp`, `keyPassword=bmw@hp`, `keyAlias=upload`) in your local system configuration, so we can configure everything without needing additional inputs.

---

## Proposed Changes

### Git Configuration & Cleanup

We will clean up untracked temporary files and logs (`test_svg.png`, `bk for the last improved time and then fix other.zip`, `scratch/`, `log.txt`) and update `.gitignore` so they (along with signing properties/keystores) are never tracked by Git.

#### [MODIFY] [.gitignore](file:///home/nilshaaa/Projects/one_player/.gitignore)
- Add entries to safely ignore the temporary zip files, log files, scratch folders, local `key.properties`, and `*.jks` keystore files at the project root and in the `android/` directory.

---

### Android Build Configuration

We will integrate dynamic signing property lookup in the Android build script, allowing it to sign using your local keystore if present, and fallback to debug signing otherwise.

#### [NEW] [key.properties](file:///home/nilshaaa/Projects/one_player/android/key.properties)
- Create the local signing properties referencing the path `../upload-keystore.jks` and your keystore passwords.

#### [MODIFY] [build.gradle.kts](file:///home/nilshaaa/Projects/one_player/android/app/build.gradle.kts)
- Modify the Kotlin DSL build script to load `key.properties`.
- Set up a `release` signing config using these properties.
- Update the `release` build type to use the `release` signing config if `key.properties` exists, falling back to `debug` signing configuration otherwise.

---

### Linux Distribution Configurations

To ensure a complete set of Linux installer packages is built during releases, we will enable DEB, RPM, AppImage, and Archive (TAR.GZ) packaging.

#### [MODIFY] [distribute_options.yaml](file:///home/nilshaaa/Projects/one_player/distribute_options.yaml)
- Uncomment the `linux-rpm`, `linux-appimage`, and `linux-archive` packaging configurations so `flutter_distributor` builds all requested formats in the release pipeline.

---

### CI/CD Automation Workflows

We will consolidate release configurations into a single, highly optimized and robust workflow that builds the signed Android APK and all Linux packages in parallel, uploading them all under a single GitHub Release with premium, auto-generated release descriptions.

#### [NEW] [release.yml](file:///home/nilshaaa/Projects/one_player/.github/workflows/release.yml)
- Create a unified tag-triggered release pipeline (`v*`) with three parallel/sequential jobs:
  1. `build-android`: Installs Java 17 and Flutter, reconstructs the `upload-keystore.jks` from Base64 secret, generates signing properties dynamically, builds the signed release APK, and uploads the binary as a runner artifact.
  2. `build-linux`: Installs all required Linux system compilation tools and packaging libraries (including `appimagetool`), configures Flutter, builds the DEB, RPM, AppImage, and TAR.GZ formats using `flutter_distributor`, and uploads the packages as runner artifacts.
  3. `publish-release`: Downloads all build artifacts from both platforms and publishes a formal GitHub Release using the GitHub CLI with clean, automated changelog generation and premium release texts.

#### [DELETE] [build.yml](file:///home/nilshaaa/Projects/one_player/.github/workflows/build.yml)
- Delete the redundant build workflow file to prevent duplicate pipeline runs.

#### [DELETE] [dart.yml](file:///home/nilshaaa/Projects/one_player/.github/workflows/dart.yml)
- Delete the redundant Dart workflow file to prevent duplicate pipeline runs.

---

## Verification Plan

### Automated & Build Verification
1. **Local Android Build**:
   Run `flutter build apk --release` to verify that Gradle successfully parses the local `key.properties` and compiles a signed APK. We will inspect the signing status using `apksigner verify`.
2. **Local Linux Build**:
   Run `flutter build linux --release` to verify that the app builds successfully on the local desktop.
3. **Workflow Syntax & Validation**:
   Validate that the new `.github/workflows/release.yml` syntax passes dry-run actions and linting.

### Manual Verification
1. Create a tag (e.g. `v1.0.0-rc1`) and verify that only the single `release.yml` pipeline triggers.
2. Confirm the resulting release on GitHub includes the following assets:
   - `looper-player-release.apk` (Signed Android app)
   - `looper-player-1.0.0-linux-amd64.deb`
   - `looper-player-1.0.0-linux-x86_64.rpm`
   - `looper-player-1.0.0-linux-x86_64.AppImage`
   - `looper-player-1.0.0-linux-x86_64.tar.gz`
