#!/bin/bash
# oogiri-forge お題提案スクリプト
# 使用法: bash suggest.sh

set -euo pipefail
trap 'echo "❌ エラー発生 (suggest.sh line $LINENO)" >&2' ERR

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "🎤 お題候補を生成しています..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━"

# session.json を提案フェーズ用に初期化
python3 - <<'PYEOF'
import json, datetime
d = {
  'theme': '',
  'created_at': datetime.datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ'),
  'status': 'topic_suggesting',
  'topic_candidates': [],
  'interpretations': [],
  'raw_answers': [],
  'selected_answers': [],
  'turn_count': 0
}
json.dump(d, open('session.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=2)
PYEOF

# Agent00: お題候補をStep1〜Step3のみ実行し、topic_candidatesに保存
# Step4（ユーザー入力受付）はシェル側で行うため Agent00 は提示まで
claude --model claude-sonnet-4-6 \
  --max-turns 4 \
  'agents/00_topic_suggester.md の Step1〜Step3 を実行してください。
   上位6本のお題を画面に番号付きで提示し、さらに session.json の topic_candidates フィールドに
   文字列の配列として保存してください（例: ["お題1", "お題2", ...]）。
   Step4 は実行しないこと。番号の受け付けはシェルスクリプト側で行います。'

echo ""

# ユーザー入力をシェルで受け付ける
read -r -p "番号(1-6)または独自のお題を入力してください: " INPUT

if [[ "$INPUT" =~ ^[1-6]$ ]]; then
  THEME=$(python3 - <<PYEOF
import json, sys
try:
    d = json.load(open('session.json', encoding='utf-8'))
    candidates = d.get('topic_candidates', [])
    idx = int('$INPUT') - 1
    if 0 <= idx < len(candidates):
        print(candidates[idx])
    else:
        print('')
except Exception:
    print('')
PYEOF
)
  if [ -z "$THEME" ]; then
    echo "⚠️ 候補が取得できませんでした。お題を直接入力してください。" >&2
    read -r -p "お題を入力: " THEME
  fi
else
  THEME="$INPUT"
fi

if [ -z "$THEME" ]; then
  echo "⚠️ お題が空です。終了します。" >&2
  exit 1
fi

echo ""
exec bash "$SCRIPT_DIR/run.sh" "$THEME"
