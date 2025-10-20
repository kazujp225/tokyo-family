import SwiftUI

/// 確認ダイアログコンポーネント
/// デザイン定義: 0.5_デザイン定義.md - 4.7 モーダル
struct ConfirmationDialogContent: View {

    let title: String
    let message: String
    let confirmTitle: String
    let confirmRole: ButtonRole?
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: Spacing.xl) {
            // アイコン
            if confirmRole == .destructive {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(ColorTokens.accentWarning)
            } else {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(ColorTokens.accentPrimary)
            }

            // タイトル
            Text(title)
                .font(Typography.title2)
                .foregroundColor(ColorTokens.textPrimary)
                .multilineTextAlignment(.center)

            // メッセージ
            Text(message)
                .font(Typography.body)
                .foregroundColor(ColorTokens.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(Typography.lineSpacing)

            // ボタン
            VStack(spacing: Spacing.m) {
                if confirmRole == .destructive {
                    Button(action: onConfirm) {
                        Text(confirmTitle)
                            .font(Typography.callout)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(ColorTokens.accentDanger)
                            .cornerRadius(CornerRadius.button)
                    }
                } else {
                    PrimaryButton(title: confirmTitle, action: onConfirm)
                }

                SecondaryButton(title: "キャンセル", action: onCancel)
            }
        }
        .padding(Spacing.xl)
        .background(ColorTokens.bgCard)
        .cornerRadius(CornerRadius.card)
        .padding(Spacing.l)
    }
}

// MARK: - Confirmation Dialog Modifier

extension View {
    /// 確認ダイアログを表示
    func confirmationDialog(
        title: String,
        message: String,
        confirmTitle: String,
        confirmRole: ButtonRole? = nil,
        isPresented: Binding<Bool>,
        onConfirm: @escaping () -> Void
    ) -> some View {
        ZStack {
            self

            if isPresented.wrappedValue {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isPresented.wrappedValue = false
                    }

                ConfirmationDialogContent(
                    title: title,
                    message: message,
                    confirmTitle: confirmTitle,
                    confirmRole: confirmRole,
                    onConfirm: {
                        onConfirm()
                        isPresented.wrappedValue = false
                    },
                    onCancel: {
                        isPresented.wrappedValue = false
                    }
                )
                .transition(.scale.combined(with: .opacity))
                .animation(.spring(response: 0.3), value: isPresented.wrappedValue)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ConfirmationDialog_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Background Content")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorTokens.bgBase)
        .confirmationDialog(
            title: "ブロックしますか？",
            message: "ブロックすると、このユーザーとのマッチが解除され、今後カードに表示されなくなります。",
            confirmTitle: "ブロック",
            confirmRole: .destructive,
            isPresented: .constant(true),
            onConfirm: {}
        )
        .previewDisplayName("Confirmation Dialog")
    }
}
#endif
