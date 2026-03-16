import SwiftUI

struct ContentView: View {
    @Namespace private var heroNamespace
    @State private var path = NavigationPath()

    /// Tracks which cell is currently being viewed in the detail page.
    /// Used to hide that specific cell's fallback image so the zoom
    /// transition gives the "same instance" illusion (image leaves the cell).
    @State private var activePostID: Int?

    private let posts = Post.samples
    private let columns = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1)
    ]

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                profileTabBar

                LazyVGrid(columns: columns, spacing: 1) {
                    ForEach(posts) { post in
                        ZStack {
                            // Fallback image layer — sits BEHIND the NavigationLink.
                            //
                            // `.matchedTransitionSource` can fail to restore the
                            // NavigationLink's content after a fast interactive pop
                            // (quick edge swipe), leaving the cell blank. This
                            // fallback is NOT managed by matchedTransitionSource,
                            // so it always renders correctly from the image cache.
                            //
                            // Only the actively-viewed cell's fallback is hidden
                            // (opacity 0) to preserve the "image leaves the cell"
                            // illusion during the push transition. All other cells
                            // keep their fallbacks visible at all times.
                            //
                            // NOTE: When dismissing via the back button, this causes
                            // the cell image to be visible during the pop animation
                            // (the cell doesn't appear empty). This is an intentional
                            // trade-off to eliminate the white flash on quick swipes,
                            // which is a worse UX issue.
                            CachedAsyncImage(url: post.imageURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Color.gray.opacity(0.1)
                            }
                            .aspectRatio(1, contentMode: .fit)
                            .clipped()
                            .opacity(activePostID == post.id ? 0 : 1)

                            // Primary layer — the NavigationLink with zoom transition source.
                            NavigationLink(value: post) {
                                gridCell(for: post)
                            }
                            .buttonStyle(.plain)
                            .matchedTransitionSource(id: post.id, in: heroNamespace)
                            .simultaneousGesture(TapGesture().onEnded {
                                activePostID = post.id
                            })
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .fontWeight(.semibold)
                        HStack(spacing: 3) {
                            Text("cristiano")
                                .font(.title3)
                                .fontWeight(.bold)
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.blue)
                                .font(.subheadline)
                        }
                    }
                    .foregroundStyle(.primary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Image(systemName: "bell")
                            .font(.title3)
                        Image(systemName: "ellipsis")
                            .font(.title3)
                    }
                    .foregroundStyle(.primary)
                }
            }
            .navigationDestination(for: Post.self) { post in
                PostDetailView(post: post)
                    // Zoom transition: the system handles hero animation, interactive
                    // edge-swipe dismiss with device corner radius, and gallery
                    // scale-out — all driven by matchedTransitionSource above.
                    .navigationTransition(.zoom(sourceID: post.id, in: heroNamespace))
            }
            .onChange(of: path.count) { oldCount, newCount in
                // On navigation pop, immediately restore the fallback for the
                // previously-active cell so it's visible if matchedTransitionSource
                // fails to un-hide the NavigationLink content (quick swipe bug).
                if newCount < oldCount {
                    activePostID = nil
                }
            }
        }
    }

    // MARK: - Profile Tab Bar

    private var profileTabBar: some View {
        HStack(spacing: 0) {
            tabBarItem(icon: "square.grid.3x3.fill", isSelected: true)
            tabBarItem(icon: "play.square", isSelected: false)
            tabBarItem(icon: "person.crop.square", isSelected: false)
        }
        .padding(.top, 4)
    }

    private func tabBarItem(icon: String, isSelected: Bool) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(isSelected ? .primary : .secondary)
                .frame(maxWidth: .infinity)
            Rectangle()
                .fill(isSelected ? Color.primary : .clear)
                .frame(height: 0.5)
        }
        .padding(.top, 8)
    }

    // MARK: - Grid Cell

    @ViewBuilder
    private func gridCell(for post: Post) -> some View {
        CachedAsyncImage(url: post.imageURL) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Color.gray.opacity(0.1)
        }
        .aspectRatio(1, contentMode: .fit)
        .clipped()
        .overlay(alignment: .topTrailing) {
            if post.hasMultiple {
                Image(systemName: "square.on.square")
                    .font(.caption)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.5), radius: 2)
                    .padding(6)
            } else if post.isVideo {
                Image(systemName: "play.fill")
                    .font(.caption2)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.5), radius: 2)
                    .padding(6)
            }
        }
    }
}

#Preview {
    ContentView()
}
