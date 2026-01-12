import SwiftUI

/// Main ContentView that handles authentication state and navigation.
struct ContentView: View {
    @StateObject private var viewModel = AuthViewModelWrapper()

    var body: some View {
        Group {
            if viewModel.isAuthenticated {
                HomeView(viewModel: viewModel)
            } else {
                AuthView(viewModel: viewModel)
            }
        }
        .animation(.easeInOut, value: viewModel.isAuthenticated)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
