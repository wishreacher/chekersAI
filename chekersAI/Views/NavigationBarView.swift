import SwiftUI

struct NavigationBarView: View {
    @ObservedObject var viewModel: ContentViewModel
    @ObservedObject var analysisViewModel: ImageAnalysisViewModel
    
    var body: some View {
        VStack (alignment: .leading, spacing: 25) {
            ZStack {
                if analysisViewModel.currentPlayer == .black {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                } else {
                    Image(systemName: "crown")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                }
                
                Circle()
                    .stroke(Color.blue, lineWidth: 1)
                    .frame(width: 50, height: 50)
                    .opacity(0.1)
                
            }
            .background(
                Capsule()
                    .fill(Material.ultraThin)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            )
            .onTapGesture {
                if analysisViewModel.currentPlayer == .black {
                    analysisViewModel.currentPlayer = .white
                } else {
                    analysisViewModel.currentPlayer = .black
                }
            }
            
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
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Material.ultraThin)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    
            )

            .padding(.bottom, 0)
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    NavigationBarView(viewModel: ContentViewModel(), analysisViewModel: ImageAnalysisViewModel())
}
