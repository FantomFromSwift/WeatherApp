import SwiftUI

extension View {
    func errorAlert(error: Error?, onDismiss: @escaping () -> Void) -> some View {
        alert(
            error?.alertTitle ?? "Error",
            isPresented: .init(
                get: { error != nil },
                set: { if !$0 { onDismiss() } }
            )
        ) {
            Button("OK", action: onDismiss)
        } message: {
            if let error = error, let recovery = error.alertRecoveryMessage {
                Text(recovery)
            }
        }
    }
}
