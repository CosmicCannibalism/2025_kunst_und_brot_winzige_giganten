import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!

    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        if #available(iOS 10.0, *) {
            webConfiguration.mediaTypesRequiringUserActionForPlayback = []
        } else {
            webConfiguration.requiresUserActionForMediaPlayback = false
        }

        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.scrollView.isScrollEnabled = false
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Prefer loading an updated webapp copied by Finder into Documents/
        // If not present, fall back to the bundled webapp in the app bundle.
        let fileManager = FileManager.default
        if let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let docsWebapp = docs.appendingPathComponent("winzige_giganten_webapp")
            let docsIndex = docsWebapp.appendingPathComponent("winzige_giganten_index.html")
            if fileManager.fileExists(atPath: docsIndex.path) {
                // Load from Documents and allow read access to the whole folder
                print("[WinzigeGiganten] Loading webapp from Documents: \(docsIndex.path)")
                webView.loadFileURL(docsIndex, allowingReadAccessTo: docsWebapp)
                return
            }
        }

        // Fallback to bundled webapp
        if let indexURL = Bundle.main.url(forResource: "winzige_giganten_index", withExtension: "html", subdirectory: "winzige_giganten_webapp") {
            let folderURL = Bundle.main.bundleURL.appendingPathComponent("winzige_giganten_webapp")
            print("[WinzigeGiganten] Loading webapp from bundle: \(indexURL.path)")
            webView.loadFileURL(indexURL, allowingReadAccessTo: folderURL)
        } else {
            print("[WinzigeGiganten] ERROR: Missing web files in bundle and no Documents copy found")
            // Load a simple debug HTML so the user sees a helpful error screen instead of a white screen
            let html = "<html><head><meta name=viewport content=\"width=device-width,initial-scale=1\"></head><body style='font-family: -apple-system; padding: 24px; color: #333; background: #fff;'><h1>Missing web files</h1><p>The embedded webapp was not found in the app bundle and no Documents copy is present.</p><p>Please ensure <code>winzige_giganten_webapp/winzige_giganten_index.html</code> is included in the app resources.</p></body></html>"
            webView.loadHTMLString(html, baseURL: nil)
        }
    }

    // MARK: - WKNavigationDelegate (logging)
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("[WinzigeGiganten] webView didFinish: \(webView.url?.absoluteString ?? "(no url)")")
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("[WinzigeGiganten] webView didFail navigation: \(error.localizedDescription)")
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("[WinzigeGiganten] webView didFailProvisionalNavigation: \(error.localizedDescription)")
    }

    // Optional: force landscape
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
