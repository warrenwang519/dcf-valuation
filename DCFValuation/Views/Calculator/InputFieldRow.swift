import SwiftUI

struct InputFieldRow: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .decimalPad
    var numericOnly: Bool = true
    var suffix: String?

    var body: some View {
        HStack {
            Text(title)
                .frame(width: 120, alignment: .leading)

            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .multilineTextAlignment(.trailing)
                .textFieldStyle(.roundedBorder)
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
