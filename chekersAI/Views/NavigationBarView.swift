import SwiftUI

struct NavigationBarView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button(action: {
                    viewModel.selectedTab = tab
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.systemImage)
                            .font(.title2)
                        Text(tab.displayName)
                            .font(.caption)
                    }
                    .foregroundColor(viewModel.selectedTab == tab ? .accentColor : .secondary)
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

#Preview {
    NavigationBarView(viewModel: ContentViewModel())
}
