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


