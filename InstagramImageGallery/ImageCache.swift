import SwiftUI

/// In-memory image cache backed by NSCache.
/// Provides synchronous lookups so that `CachedAsyncImage` can display
/// previously-loaded images on the very first frame, avoiding the brief
/// placeholder flash that `AsyncImage` would otherwise show.
final class ImageCache: @unchecked Sendable {
    static let shared = ImageCache()
    private let cache = NSCache<NSURL, UIImage>()

    private init() {
        cache.countLimit = 200
    }

    func get(_ url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }

    func set(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
    }
}

/// A drop-in replacement for `AsyncImage` that checks `ImageCache` synchronously
/// in its body before falling back to a network load. This guarantees that cached
/// images render immediately with no placeholder flash — critical for the fallback
/// layer behind the zoom transition source (see `ContentView`).
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder

    @State private var uiImage: UIImage?

    var body: some View {
        // Synchronous cache check first — no async delay, no placeholder frame.
        if let resolved = ImageCache.shared.get(url) ?? uiImage {
            content(Image(uiImage: resolved))
        } else {
            placeholder()
                .task(id: url) {
                    await loadImage()
                }
        }
    }

    private func loadImage() async {
        if let cached = ImageCache.shared.get(url) {
            uiImage = cached
            return
        }
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let image = UIImage(data: data) else { return }
        ImageCache.shared.set(image, for: url)
        uiImage = image
    }
}
