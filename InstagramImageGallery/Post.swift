import Foundation

struct Post: Identifiable, Hashable {
    let id: Int
    let imageURL: URL
    let caption: String
    let likes: String
    let comments: String
    let shares: String
    let saves: String
    let date: String
    let hasMultiple: Bool
    let isVideo: Bool
}

extension Post {
    static let samples: [Post] = {
        let captions = [
            "We keep growing together! Important win!",
            "Training day 💪",
            "Family time ❤️",
            "Another day, another goal ⚽",
            "Never give up on your dreams",
            "Blessed 🙏",
            "Hard work pays off",
            "Matchday vibes"
        ]
        let likeOptions = ["2 M", "1.5 M", "3.2 M", "890 K", "4.1 M", "670 K"]
        let commentOptions = ["26.6K", "15.3K", "42.1K", "8.7K", "55.2K", "12.0K"]
        let shareOptions = ["18.2K", "12.5K", "30.0K", "5.1K", "22.8K", "9.3K"]
        let saveOptions = ["5,354", "3,210", "8,102", "1,890", "6,432", "2,100"]
        let dateOptions = ["1 March", "28 February", "25 February", "20 February", "15 February", "10 February"]

        return (0..<30).map { i in
            Post(
                id: i,
                imageURL: URL(string: "https://picsum.photos/seed/insta\(i)/600/600")!,
                caption: captions[i % captions.count],
                likes: likeOptions[i % likeOptions.count],
                comments: commentOptions[i % commentOptions.count],
                shares: shareOptions[i % shareOptions.count],
                saves: saveOptions[i % saveOptions.count],
                date: dateOptions[i % dateOptions.count],
                hasMultiple: [0, 3, 6, 9, 15, 21].contains(i),
                isVideo: [2, 5, 8, 14, 20].contains(i)
            )
        }
    }()
}
