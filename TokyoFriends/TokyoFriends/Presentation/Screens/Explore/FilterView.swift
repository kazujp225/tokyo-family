import SwiftUI

/// フィルタ画面
/// 画面ID: PG-33 - フィルタ設定（0.4_ページ定義.md）
/// - 地域フィルタ
/// - 年齢範囲フィルタ
/// - 属性フィルタ
/// - 興味タグフィルタ
struct FilterView: View {

    @Binding var filters: CardFilters
    @Environment(\.dismiss) private var dismiss

    @State private var selectedDistricts: Set<String> = []
    @State private var selectedAgeRanges: Set<AgeRange> = []
    @State private var selectedAttributes: Set<Attribute> = []
    @State private var selectedInterests: Set<String> = []

    var body: some View {
        NavigationStack {
            Form {
                // 地域セクション
                Section {
                    ForEach(districts, id: \.self) { district in
                        Toggle(district, isOn: Binding(
                            get: { selectedDistricts.contains(district) },
                            set: { isOn in
                                if isOn {
                                    selectedDistricts.insert(district)
                                } else {
                                    selectedDistricts.remove(district)
                                }
                            }
                        ))
                    }
                } header: {
                    Text("地域")
                } footer: {
                    Text("選択した地域のユーザーのみ表示します")
                }

                // 年齢範囲セクション
                Section {
                    ForEach(AgeRange.allCases, id: \.self) { range in
                        Toggle(range.displayText, isOn: Binding(
                            get: { selectedAgeRanges.contains(range) },
                            set: { isOn in
                                if isOn {
                                    selectedAgeRanges.insert(range)
                                } else {
                                    selectedAgeRanges.remove(range)
                                }
                            }
                        ))
                    }
                } header: {
                    Text("年齢範囲")
                }

                // 属性セクション
                Section {
                    Toggle(Attribute.student.displayText, isOn: Binding(
                        get: { selectedAttributes.contains(.student) },
                        set: { isOn in
                            if isOn {
                                selectedAttributes.insert(.student)
                            } else {
                                selectedAttributes.remove(.student)
                            }
                        }
                    ))

                    Toggle(Attribute.worker.displayText, isOn: Binding(
                        get: { selectedAttributes.contains(.worker) },
                        set: { isOn in
                            if isOn {
                                selectedAttributes.insert(.worker)
                            } else {
                                selectedAttributes.remove(.worker)
                            }
                        }
                    ))
                } header: {
                    Text("属性")
                }

                // 興味タグセクション
                Section {
                    ForEach(OnboardingViewModel.availableInterests, id: \.self) { interest in
                        Toggle(interest, isOn: Binding(
                            get: { selectedInterests.contains(interest) },
                            set: { isOn in
                                if isOn {
                                    selectedInterests.insert(interest)
                                } else {
                                    selectedInterests.remove(interest)
                                }
                            }
                        ))
                    }
                } header: {
                    Text("興味タグ")
                } footer: {
                    Text("選択したタグのいずれかに一致するユーザーを表示します")
                }

                // リセットボタン
                Section {
                    Button(role: .destructive) {
                        resetFilters()
                    } label: {
                        HStack {
                            Spacer()
                            Text("すべてのフィルタをクリア")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("フィルタ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("適用") {
                        applyFilters()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                loadCurrentFilters()
            }
        }
    }

    // MARK: - Data

    private let districts = [
        "新宿区", "渋谷区", "港区", "千代田区",
        "中央区", "台東区", "品川区", "目黒区"
    ]

    // MARK: - Actions

    private func loadCurrentFilters() {
        selectedDistricts = Set(filters.districts ?? [])
        selectedAgeRanges = Set(filters.ageRanges ?? [])
        selectedAttributes = Set(filters.attributes ?? [])
        selectedInterests = Set(filters.interests ?? [])
    }

    private func applyFilters() {
        filters = CardFilters(
            districts: selectedDistricts.isEmpty ? nil : Array(selectedDistricts),
            ageRanges: selectedAgeRanges.isEmpty ? nil : Array(selectedAgeRanges),
            attributes: selectedAttributes.isEmpty ? nil : Array(selectedAttributes),
            interests: selectedInterests.isEmpty ? nil : Array(selectedInterests)
        )
    }

    private func resetFilters() {
        selectedDistricts.removeAll()
        selectedAgeRanges.removeAll()
        selectedAttributes.removeAll()
        selectedInterests.removeAll()
    }
}

// MARK: - Preview

#if DEBUG
struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView(filters: .constant(CardFilters()))
            .previewDisplayName("Filter View")
    }
}
#endif
