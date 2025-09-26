Bundle the webapp into a native iOS app (WKWebView)

Goal

Make the exhibit fully offline on an iPad by packaging the static webapp and its video assets into a native iOS app (APK equivalent for iOS). The app uses a WKWebView to load the local `winzige_giganten_index.html` file from the app bundle, so Safari/PWA/Service Worker HTTPS requirements are no longer relevant.

Why this approach

- iOS PWAs and service workers are unreliable for large media offline (iOS can evict caches).
- Bundling assets in a native app makes offline playback predictable and gives full control over media playback.
- You can lock orientation, enable autoplay/playsinline, and pre-install on the device using Xcode.

What you'll get in this repo after following these steps

- A ready-to-copy `winzige_giganten_webapp/` folder containing the site and videos.
- Instructions to create an Xcode project and embed the site in the app bundle.
- A sample `ViewController.swift` you can paste into your Xcode project.
- A small `tools/compress_videos.sh` script to generate lower-bitrate copies for smaller app size.

Prerequisites

- A Mac with Xcode (14+) installed.
- An iPad for testing and/ or an Apple Developer account (or free provisioning with an Apple ID).
- ffmpeg (optional, for compressing videos): brew install ffmpeg

Steps — quick summary

1. Prepare smaller video variants (optional but recommended).
2. Create a new Xcode project (Single View App or App) configured for iPad and landscape orientation.
3. Add the `winzige_giganten_webapp` folder into the Xcode project and make sure files are copied into the app bundle.
4. Replace the default view controller with the provided `ViewController.swift` (see below) and set configuration to allow inline playback.
5. Configure project settings: supported interface orientations (landscape), provisioning/signing, and Info.plist permissions if needed.
6. Build and run on the connected iPad. The app will load the local `winzige_giganten_index.html` and play videos directly from the bundle.

Detailed instructions

1) (Optional) Generate smaller video variants to reduce app size

From repo root, run:

```bash
# make executable and run
chmod +x tools/compress_videos.sh
./tools/compress_videos.sh
```

This creates `videos/main_720.mp4` and `videos/teaser_720.mp4` (and 360p variants), which you can include instead of the hi-res originals.

2) Create a new Xcode app

- Open Xcode → Create a new project → App (iOS) → Interface: Storyboard or SwiftUI (we provide a UIKit ViewController example).
- Product Name: WinzigeGiganten
- Team: your Apple Developer account or your Apple ID (free provisioning).
- Deployment Target: choose the iOS version used by your exhibition iPad.
- Device: iPad (or Universal).

3) Configure orientation and Info.plist

- In your project target → General → Deployment Info → Device Orientation: check only "Landscape Left" and "Landscape Right".
- In Info.plist, you may set "Requires full screen" to YES if desired.

4) Add the webapp files to the app bundle

- In Finder, locate this repo's `winzige_giganten_webapp` folder.
- In Xcode, right-click the project navigator and choose "Add Files to <YourProject>...".
- Select the entire `winzige_giganten_webapp` folder. In the dialog, check "Copy items if needed" and add to your app target. Use "Create folder references" or "Create groups" — folder reference is okay but groups is easier for static resources.
- Confirm the files appear under the app target and are included in "Build Phases → Copy Bundle Resources".

Bundling the original (uncompressed) videos — exact steps and warnings

If you want to bundle the original `main.mp4` and `teaser.mp4` files without running the compression script, follow these exact steps. This will make the videos available offline in the app bundle immediately, but be aware the IPA size will grow by the total size of those files.

Steps

1. Ensure the hi-resolution files exist at `winzige_giganten_webapp/videos/main.mp4` and `winzige_giganten_webapp/videos/teaser.mp4` in the repo.
2. In Xcode, use File → Add Files to "<YourProject>..." and select the `winzige_giganten_webapp/videos` folder (or the two mp4 files). In the dialog:
	- Check "Copy items if needed" if you want Xcode to copy them into the project folder.
	- Ensure your app target is checked in "Add to targets".
3. After adding, open your target → Build Phases → Copy Bundle Resources and verify both mp4 files are listed.
4. (Optional) If you prefer groups instead of folder references, add the parent `winzige_giganten_webapp` folder as a group so paths inside the bundle match the app's expected structure.

Estimate IPA size increase before building

From the repo root you can estimate the added size the videos will contribute to the app bundle:

```bash
# show the combined size of the videos folder
du -sh winzige_giganten_webapp/videos
```

The IPA will include these bytes (plus a small packaging overhead). If the videos folder is several GB, expect the IPA to be roughly that size.

Warnings and tips

- Large IPAs: bundling multi-gigabyte video files will produce a very large IPA. This can make installs slow and may require using Apple Configurator or physical connections for installation (TestFlight supports large builds but has limits and longer upload times).
- Device storage: ensure exhibition iPads have enough free storage for the app and videos.
- Backups and updates: updating videos requires replacing the app (rebuild/reinstall) unless you use the Finder copy workflow described earlier (enable `UIFileSharingEnabled` and copy into Documents). If you expect frequent content updates, prefer the Finder copy workflow instead of rebuilding each time.
- If you later change your mind: you can revert to the compressed `_720.mp4` variants by running `tools/compress_videos.sh` and swapping filenames in the webapp folder.

Automatic copy at build time (Run Script)

If you prefer Xcode to copy the `winzige_giganten_webapp` (including the uncompressed videos) into the app bundle automatically at build time, add the provided script as a Run Script build phase.

1. In Xcode, open your app target → Build Phases → click '+', choose 'New Run Script Phase'.
2. Move the phase before 'Copy Bundle Resources' so the files are available to be packaged.
3. Set the shell to '/bin/sh' and use this script invocation (assuming your project root is the repo root):

	${SRCROOT}/platform_ios/scripts/copy_webapp_to_bundle.sh

4. Tell Xcode about the script's output (avoid "Run script will be run during every build")

	Xcode runs a script phase every build if it cannot determine outputs. The provided script writes a small marker file into the bundle; add that path to the Run Script phase's "Output Files" so Xcode can perform dependency analysis and skip the script when not needed.

	- In the Run Script phase, open the "Output Files" section and add a single line with the following path (use the exact line, replacing ${TARGET_BUILD_DIR} with that literal; Xcode will expand it at build time):

	  ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/winzige_giganten_webapp/.winzige_webapp_copied

	- With that Output Files entry present, Xcode will only run the script when the output is missing or stale.

Duplicate Info.plist error

If you see an error like "duplicate output file '.../WinzigeGiganten.app/Info.plist'" it often means two build steps are producing the same file (for example a manual copy step and the normal Info.plist processing). To resolve:

1. Make sure you're not also copying an Info.plist into the app resources via Copy Bundle Resources. The only Info.plist that should be processed is the one specified in the target's build settings (Info.plist File). If you accidentally added `platform_ios/Info.plist` to Copy Bundle Resources, remove it from that phase.

2. If the error remains and points to ProcessInfoPlistFile, try the following:
	- Confirm your target's "Info.plist File" in Build Settings points to the single Info.plist you want Xcode to process (for example, `platform_ios/Info.plist`).
	- Ensure you did not add the same Info.plist as a resource via the Run Script or Copy Bundle Resources phases.

3. As a last resort for transient build system issues, Clean Build Folder (Shift-Command-K) and rebuild. If the build system state is corrupted, a clean often resolves duplicate-output errors.

4. If you intentionally need two different Info.plist files for different configurations, use separate targets or adjust the Build Settings per-configuration so only one Info.plist is produced per target.

4. (Optional) If you don't use ${SRCROOT} in your project configuration, you can expand it to the absolute path. The script uses Xcode-provided environment variables like TARGET_BUILD_DIR and UNLOCALIZED_RESOURCES_FOLDER_PATH to place the files into the app resources folder.

Verification

- Build the app for a simulator or device. After a successful build, inspect the built product in the Finder by right-clicking the .app in Xcode's Products group → Show in Finder → Right-click the .app → Show Package Contents. You should see `winzige_giganten_webapp` under the Resources folder and the original `main.mp4` and `teaser.mp4` files inside `videos/`.
- Alternatively, after installing the app on device, you can inspect the bundle using ideviceinstaller or by exporting the archived IPA and unzipping it to verify the resources.

Notes

- This Run Script will copy the raw, uncompressed video files into the app bundle. Use it only if you intend to ship the originals; otherwise prefer the compression workflow in `tools/compress_videos.sh` to reduce IPA size.
- If you also enable the Finder update workflow (UIFileSharingEnabled), copying a `winzige_giganten_webapp` into Documents will take precedence at runtime because `ViewController.swift` prefers the Documents copy when present.

5) Replace the default ViewController with the provided `ViewController.swift`

- Delete or replace the auto-generated view controller code and add the sample `ViewController.swift` from this repository (paste into a new Swift file in the project).
- The sample config enables `allowsInlineMediaPlayback` and does `loadFileURL(_:allowingReadAccessTo:)` so the WKWebView can read bundled files.

6) Build & Run on connected iPad

- Connect iPad to your Mac with a cable and unlock it.
- In Xcode, select your device as the run destination, then press Run.
- Xcode will sign, install and launch the app on the device.
- On first launch, the web UI should appear and videos should autoplay (muted, playsinline attributes required).

7) Final packaging

- For long-term exhibition, create an archive (Product → Archive) and distribute via TestFlight or Apple Configurator / mdm to the exhibition iPad.

Notes & caveats

- App size: bundling multiple high-resolution videos will make the IPA large. Use compressed variants when possible.
- Autoplay: videos must have `muted` and `playsinline` attributes for autoplay to work in WKWebView.
- If you need to update web assets frequently, you can ship an updater inside the app that copies updated files from a removable storage or downloads when connected to a network — basic offline use assumes assets are bundled at build time.

If you want, I can:
- Prepare a minimal Xcode project (template) that already contains the webapp files and the `ViewController.swift` wired up (this requires a bit more work and will add binary/project files to the repo).
- Or I can add a small debug button to the webapp that prints cache/bundle information to the console while you run in the simulator.

Using Finder to copy/update the webapp on-device (optional)

If you prefer to update the webapp on the iPad without rebuilding the app, you can copy the entire `winzige_giganten_webapp` folder into the app's Documents directory using Finder file sharing. The `ViewController` now prefers a `Documents/winzige_giganten_webapp/winzige_giganten_index.html` if present, so copying the folder is enough to replace the web assets on-device.

Steps to enable and use Finder file sharing:

1. In your Xcode project's `Info.plist` add the boolean key `UIFileSharingEnabled` and set it to `YES` (this makes the app visible in Finder's Files tab when the device is connected).

2. Build and install the app on the iPad once (so the app appears in Finder). You can use free provisioning.

3. Connect the iPad to your Mac with a cable and open Finder. Select the iPad in the sidebar and choose the "Files" tab.

4. Find your app in the list (it appears when `UIFileSharingEnabled` is true). Drag the entire `winzige_giganten_webapp` folder from Finder into the app's Documents area. This copies the folder to `Documents/winzige_giganten_webapp` on the iPad.

5. Launch the app on the iPad. The `ViewController` will detect the Documents copy and load `winzige_giganten_index.html` from there. If the app is already running, quit and relaunch it to pick up the new files.

Notes on updating files:
- If you copy only changed files, ensure the folder structure matches the original (videos/ subfolder, icons, etc.).
- Deleting the folder from Finder and copying again is a clean way to ensure no stale files remain.
- This approach avoids rebuilding the app for small content updates and is suitable for exhibition workflows where you want to tweak assets on-device.


