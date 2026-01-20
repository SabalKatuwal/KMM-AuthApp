import SwiftUI
import Shared

/// Home view shown when user is authenticated.
struct HomeView: View {
    @ObservedObject var viewModel: AuthViewModelWrapper

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 30) {
                    // User profile section
                    profileSection

                    // User info cards
                    userInfoSection

                    Spacer()

                    // Logout button
                    logoutButton
                }
                .padding()
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - View Components

    private var profileSection: some View {
        VStack(spacing: 16) {
            // Profile image
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                if let photoUrl = viewModel.currentUser?.photoUrl,
                   let url = URL(string: photoUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        userInitials
                    }
                    .frame(width: 96, height: 96)
                    .clipShape(Circle())
                } else {
                    userInitials
                }
            }

            // User name
            Text(viewModel.currentUser?.displayName ?? "User")
                .font(.title2)
                .fontWeight(.semibold)

            // Email
            if let email = viewModel.currentUser?.email {
                Text(email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 20)
    }

    private var userInitials: some View {
        Text(getInitials())
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.white)
    }

    private var userInfoSection: some View {
        VStack(spacing: 12) {
            InfoCard(
                title: "User ID",
                value: viewModel.currentUser?.uid ?? "N/A",
                icon: "person.fill"
            )

            InfoCard(
                title: "Email Verified",
                value: viewModel.currentUser?.isEmailVerified == true ? "Yes" : "No",
                icon: "checkmark.seal.fill"
            )

            InfoCard(
                title: "Account Type",
                value: viewModel.currentUser?.isAnonymous == true ? "Anonymous" : "Registered",
                icon: "shield.fill"
            )
        }
    }

    private var logoutButton: some View {
        Button(action: {
            viewModel.logout()
        }) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Sign Out")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(viewModel.isLoading)
        .padding(.bottom, 20)
    }

    // MARK: - Helper Methods

    private func getInitials() -> String {
        if let displayName = viewModel.currentUser?.displayName, !displayName.isEmpty {
            let names = displayName.split(separator: " ")
            let initials = names.prefix(2).compactMap { $0.first }.map { String($0) }.joined()
            return initials.uppercased()
        } else if let email = viewModel.currentUser?.email, !email.isEmpty {
            return String(email.prefix(1)).uppercased()
        }
        return "U"
    }
}

// MARK: - Info Card Component

struct InfoCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Preview

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: AuthViewModelWrapper())
    }
}

