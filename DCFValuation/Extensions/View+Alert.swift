import SwiftUI

extension View {
    func errorAlert(errors: Binding<[ValidationError]>) -> some View {
        modifier(ErrorAlertModifier(errors: errors))
    }
}

struct ErrorAlertModifier: ViewModifier {
    @Binding var errors: [ValidationError]

    func body(content: Content) -> some View {
        content.alert(
            "Invalid Input",
            isPresented: .init(
                get: { !errors.isEmpty },
                set: { if !$0 { errors = [] } }
            )
        ) {
            Button("OK") {
                errors = []
            }
        } message: {
            Text(errors.map(\.localizedDescription).joined(separator: "\n"))
        }
    }
}
