import SwiftUI

struct ContactView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "envelope.fill")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            VStack(spacing: 8) {
                Text("warren0519@outlook.com")
                    .font(.title3.weight(.semibold))

                Text("For bug reports or improvement suggestions,\nfeel free to contact me via email.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Contact Us")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ContactView()
    }
}
