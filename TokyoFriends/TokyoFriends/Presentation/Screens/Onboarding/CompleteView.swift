import SwiftUI

/// オンボーディング完了画面
/// 画面ID: PG-09 - オンボーディング完了（0.4_ページ定義.md）
struct CompleteView: View {

    var onComplete: () -> Void

    var body: some View {
        VStack(spacing: Spacing.xxl) {
            Spacer()

            // 成功アイコン
            ZStack {
                Circle()
                    .fill(ColorTokens.accentSuccess.opacity(0.1))
                    .frame(width: 120, height: 120)

                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(ColorTokens.accentSuccess)
            }

            // メッセージ
            VStack(spacing: Spacing.m) {
                Text("プロフィール作成完了！")
                    .font(Typography.largeTitle)
                    .foregroundColor(ColorTokens.textPrimary)

                Text("さっそく東京で友達を探しましょう")
                    .font(Typography.body)
                    .foregroundColor(ColorTokens.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            // はじめるボタン
            PrimaryButton(
                title: "Tokyo Friendsをはじめる",
                action: onComplete
            )
            .padding(.horizontal, Spacing.l)

            Spacer()
                .frame(height: 50)
        }
        .background(ColorTokens.bgBase)
    }
}

// MARK: - Preview

#if DEBUG
struct CompleteView_Previews: PreviewProvider {
    static var previews: some View {
        CompleteView(onComplete: {})
            .previewDisplayName("Complete View")
    }
}
#endif
