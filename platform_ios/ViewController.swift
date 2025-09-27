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
        // Load iOS-patched index from flat bundle root
        if let indexURL = Bundle.main.url(forResource: "winzige_giganten_index_ios", withExtension: "html") {
            print("[WinzigeGiganten] Loading iOS webapp from flat bundle: \(indexURL.path)")
            webView.loadFileURL(indexURL, allowingReadAccessTo: Bundle.main.bundleURL)
        } else {
            print("[WinzigeGiganten] ERROR: Missing iOS index in flat bundle")
            let html = "<html><body><h1>Missing iOS index file</h1></body></html>"
            webView.loadHTMLString(html, baseURL: nil)
        }
    }

    // ...existing code...
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

