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
                webView.loadFileURL(docsIndex, allowingReadAccessTo: docsWebapp)
                return
            }
        }

        // Fallback to bundled webapp
        if let indexURL = Bundle.main.url(forResource: "winzige_giganten_index", withExtension: "html", subdirectory: "winzige_giganten_webapp") {
            let folderURL = Bundle.main.bundleURL.appendingPathComponent("winzige_giganten_webapp")
            webView.loadFileURL(indexURL, allowingReadAccessTo: folderURL)
        } else {
            let label = UILabel()
            label.text = "Missing web files in bundle"
            label.textAlignment = .center
            label.frame = view.bounds
            view.addSubview(label)
        }
    }

    // Optional: force landscape
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
