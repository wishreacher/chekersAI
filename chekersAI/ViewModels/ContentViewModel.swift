import Foundation

enum Tab: String, CaseIterable {
    case photo = "photo"
    case camera = "camera"

    var systemImage: String {
        switch self {
        case .photo: return "photo"
        case .camera: return "camera"
        }
    }
    var displayName: String {
        switch self {
        case .photo: return "Photos"
        case .camera: return "Camera"
        }
    }
}

final class ContentViewModel: ObservableObject {
    @Published var selectedTab: Tab = .photo
}
