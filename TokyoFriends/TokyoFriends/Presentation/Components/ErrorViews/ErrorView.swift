import SwiftUI

/// エラー表示コンポーネント
/// デザイン定義: 0.5_デザイン定義.md - 4.5 エラー状態
struct ErrorView: View {

    let error: Error
    let retryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: Spacing.xl) {
            // エラーアイコン
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(ColorTokens.accentDanger)

            // エラーメッセージ
            VStack(spacing: Spacing.s) {
                Text("エラーが発生しました")
                    .font(Typography.headline)
                    .foregroundColor(ColorTokens.textPrimary)

                Text(error.localizedDescription)
                    .font(Typography.footnote)
                    .foregroundColor(ColorTokens.textSecondary)
                    .multilineTextAlignment(.center)
            }

            // リトライボタン
            if let retryAction = retryAction {
                Button(action: retryAction) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("再試行")
                    }
                    .font(Typography.callout)
                    .foregroundColor(ColorTokens.accentPrimary)
                }
            }
        }
        .padding(Spacing.xl)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("エラー: \(error.localizedDescription)")
    }
}

// MARK: - Inline Error View

struct InlineErrorView: View {
    let message: String

    var body: some View {
        HStack(spacing: Spacing.s) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(ColorTokens.accentDanger)

            Text(message)
                .font(Typography.footnote)
                .foregroundColor(ColorTokens.accentDanger)

            Spacer()
        }
        .padding(Spacing.m)
        .background(ColorTokens.accentDanger.opacity(0.1))
        .cornerRadius(CornerRadius.card)
    }
}

// MARK: - Error Handling Modifier

extension View {
    /// エラーハンドリングを追加
    func handleError(
        error: Binding<Error?>,
        retryAction: (() -> Void)? = nil
    ) -> some View {
        ZStack {
            self

            if let currentError = error.wrappedValue {
                VStack {
                    Spacer()

                    InlineErrorView(message: currentError.localizedDescription)
                        .padding(Spacing.l)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .onTapGesture {
                            error.wrappedValue = nil
                        }
                }
                .animation(.spring(), value: error.wrappedValue != nil)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Spacing.xxl) {
            ErrorView(
                error: NSError(
                    domain: "",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "ネットワーク接続に失敗しました"]
                ),
                retryAction: {}
            )

            InlineErrorView(message: "プロフィールの読み込みに失敗しました")
        }
        .padding()
        .background(ColorTokens.bgBase)
        .previewDisplayName("Error Views")
    }
}
#endif
