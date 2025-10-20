import SwiftUI

/// トーストメッセージ（一時的な通知）
/// デザイン定義: 0.5_デザイン定義.md - 4.5 その他
struct ToastView: View {

    // MARK: - Properties

    let message: String
    let type: ToastType

    // MARK: - Toast Type

    enum ToastType {
        case success
        case error
        case info

        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "exclamationmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .success: return ColorTokens.accentSuccess
            case .error: return ColorTokens.accentDanger
            case .info: return ColorTokens.accentPrimary
            }
        }
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: Spacing.m) {
            Image(systemName: type.icon)
                .foregroundColor(type.color)

            Text(message)
                .font(Typography.footnote)
                .foregroundColor(ColorTokens.textPrimary)

            Spacer()
        }
        .padding(Spacing.m)
        .background(ColorTokens.bgCard)
        .cornerRadius(CornerRadius.card)
        .shadow(
            color: Color.black.opacity(Elevation.one.opacity),
            radius: Elevation.one.blur,
            x: 0,
            y: Elevation.one.yOffset
        )
        .padding(.horizontal, Spacing.l)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(typeDescription): \(message)")
    }

    // MARK: - Accessibility

    private var typeDescription: String {
        switch type {
        case .success: return "成功"
        case .error: return "エラー"
        case .info: return "情報"
        }
    }
}

// MARK: - Toast Modifier

extension View {
    /// トーストを表示するModifier
    func toast(
        message: String,
        type: ToastView.ToastType = .info,
        isPresented: Binding<Bool>
    ) -> some View {
        ZStack {
            self

            if isPresented.wrappedValue {
                VStack {
                    ToastView(message: message, type: type)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.spring(), value: isPresented.wrappedValue)

                    Spacer()
                }
                .padding(.top, 50)
                .onAppear {
                    // 3秒後に自動で消す
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        isPresented.wrappedValue = false
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Spacing.xl) {
            ToastView(message: "保存しました", type: .success)
            ToastView(message: "エラーが発生しました", type: .error)
            ToastView(message: "新しいマッチがあります", type: .info)
        }
        .padding()
        .background(ColorTokens.bgBase)
        .previewDisplayName("Toast View")
    }
}
#endif
