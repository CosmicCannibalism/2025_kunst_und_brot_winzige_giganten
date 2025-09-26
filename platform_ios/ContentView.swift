import SwiftUI
import UIKit

// Wrapper to host your existing UIKit ViewController (WKWebView) in SwiftUI
struct WebAppViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return ViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No dynamic updates needed for now
    }
}

struct ContentView: View {
    var body: some View {
        WebAppViewControllerRepresentable()
            .edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
