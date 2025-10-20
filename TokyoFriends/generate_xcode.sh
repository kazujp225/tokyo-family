#!/bin/bash

# Tokyo Friends Xcode プロジェクト生成スクリプト

echo "🚀 Tokyo Friends Xcode プロジェクト生成開始..."

cd "$(dirname "$0")"

# SwiftPMからXcodeプロジェクトを生成
echo "📦 Swift Package Managerからプロジェクトを生成中..."
swift package generate-xcodeproj

if [ $? -eq 0 ]; then
    echo "✅ Xcodeプロジェクトファイルが生成されました"
    echo "📂 TokyoFriends.xcodeproj が作成されています"
    echo ""
    echo "🎉 完了！以下のコマンドでXcodeを開けます："
    echo "   open TokyoFriends.xcodeproj"
else
    echo "❌ エラーが発生しました"
    exit 1
fi
