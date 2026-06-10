import SwiftUI
import AuthenticationServices

// MARK: - Logo Shape (S-curve river from logo-light.svg)
struct NvestLogoShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 300
        let sy = rect.height / 300
        var p = Path()
        p.move(to: CGPoint(x: 30 * sx, y: 240 * sy))
        p.addCurve(to: CGPoint(x: 120 * sx, y: 140 * sy),
                   control1: CGPoint(x: 70 * sx, y: 240 * sy),
                   control2: CGPoint(x: 90 * sx, y: 140 * sy))
        p.addCurve(to: CGPoint(x: 190 * sx, y: 200 * sy),
                   control1: CGPoint(x: 150 * sx, y: 140 * sy),
                   control2: CGPoint(x: 160 * sx, y: 200 * sy))
        p.addCurve(to: CGPoint(x: 270 * sx, y: 60 * sy),
                   control1: CGPoint(x: 230 * sx, y: 200 * sy),
                   control2: CGPoint(x: 240 * sx, y: 100 * sy))
        return p
    }
}

struct LoginView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            VStack(spacing: 16) {
                NvestLogoShape()
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
                    .frame(width: 200, height: 200)

                Text("Nvest")
                    .font(.largeTitle.bold())

                Text("Professional DCF valuation tool for investors.\nCalculate intrinsic value in seconds.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            Spacer()

            VStack(spacing: 16) {
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    authViewModel.handleAppleSignIn(result: result)
                }
                .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                .frame(height: 50)
                .frame(maxWidth: 300)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Text("By signing in, you agree to our Terms of Service and Privacy Policy")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .padding(.bottom, 60)
        }
    }
}

#Preview {
    LoginView()
        .environment(AuthViewModel())
}
