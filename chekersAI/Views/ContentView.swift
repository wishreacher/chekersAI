//
//  FloatingTabBarView.swift
//  chekersAI
//
//  Created by Володимир on 21.06.2025.
//
import SwiftUI

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

struct ContentView: View {
    @State private var selectedTab: Tab = .photo

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                if selectedTab == .photo {
                    PhotoSelectionView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea(.all, edges: .bottom)
                } else {
                    makeCameraSelectionView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea(.all, edges: .bottom)
                }
            }

            HStack(spacing: 0) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Button(action: {
                        selectedTab = tab
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: tab.systemImage)
                                .font(.title2)
                            Text(tab.displayName)
                                .font(.caption)
                        }
                        .foregroundColor(selectedTab == tab ? .accentColor : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Material.ultraThin)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 40)
            )
            
            .padding(.bottom, 0)
            
        }
    }

    private func makeImageSelectionView() -> some View {
        Text("Image Selection View")
            .font(.largeTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.blue.opacity(0.1))
    }

    private func makeCameraSelectionView() -> some View {
        Text("Camera Selection View")
            .font(.largeTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.green.opacity(0.1))
    }
}

#Preview {
    ContentView()
}
