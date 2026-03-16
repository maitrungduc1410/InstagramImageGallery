import SwiftUI

struct PostDetailView: View {
    let post: Post

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                postHeader
                postImage
                actionBar
                captionView
                dateView
            }
        }
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 1) {
                    Text("Posts")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("cristiano")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .toolbarBackground(.visible, for: .navigationBar)
    }

    // MARK: - Post Header

    private var postHeader: some View {
        HStack(spacing: 8) {
            CachedAsyncImage(url: URL(string: "https://picsum.photos/seed/cr7face/100/100")!) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay {
                        Image(systemName: "person.fill")
                            .foregroundStyle(.gray)
                            .font(.caption)
                    }
            }
            .frame(width: 34, height: 34)

            HStack(spacing: 3) {
                Text("cristiano")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.blue)
                    .font(.caption2)
            }

            Spacer()

            Image(systemName: "ellipsis")
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Post Image

    private var postImage: some View {
        CachedAsyncImage(url: post.imageURL) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            Color.gray.opacity(0.1)
                .aspectRatio(1, contentMode: .fit)
                .overlay { ProgressView() }
        }
    }

    // MARK: - Action Bar

    private var actionBar: some View {
        HStack(spacing: 14) {
            actionItem(icon: "heart", count: post.likes)
            actionItem(icon: "bubble.right", count: post.comments)
            actionItem(icon: "paperplane", count: post.shares)

            Spacer()

            actionItem(icon: "bookmark", count: post.saves)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private func actionItem(icon: String, count: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
            Text(count)
                .font(.subheadline)
        }
    }

    // MARK: - Caption

    private var captionView: some View {
        (
            Text("cristiano").fontWeight(.semibold) +
            Text(" \(post.caption)")
        )
        .font(.subheadline)
        .padding(.horizontal, 12)
    }

    // MARK: - Date

    private var dateView: some View {
        HStack(spacing: 4) {
            Text(post.date)
            Text("·")
            Text("See Translation")
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 12)
        .padding(.top, 6)
        .padding(.bottom, 20)
    }
}

#Preview {
    NavigationStack {
        PostDetailView(post: Post.samples[0])
    }
}
