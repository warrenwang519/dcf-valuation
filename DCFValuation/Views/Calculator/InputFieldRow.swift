import SwiftUI

struct InputFieldRow: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .decimalPad
    var numericOnly: Bool = true
    var suffix: String?
    var errorMessage: String?
    var isFocused: FocusState<Bool>.Binding

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .frame(width: 120, alignment: .leading)

                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .multilineTextAlignment(.trailing)
                    .textFieldStyle(.roundedBorder)
                    .focused(isFocused)
                    .onChange(of: text) {
                        if numericOnly {
                            var seenDot = false
                            let cleaned = text.filter { char in
                                if char == "." {
                                    if seenDot { return false }
                                    seenDot = true
                                }
                                return char.isNumber || char == "."
                            }
                            if cleaned != text {
                                text = cleaned
                            }
                        }
                    }

                if let suffix {
                    Text(suffix)
                        .foregroundStyle(.secondary)
                        .frame(width: 30)
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused.wrappedValue = false
        }
    }
}

struct InputStepperRow: View {
    let title: String
    @Binding var value: Int
    var range: ClosedRange<Int>

    var body: some View {
        HStack {
            Text(title)
                .frame(width: 120, alignment: .leading)

            Spacer()

            Stepper("\(value)", value: $value, in: range)
        }
    }
}
