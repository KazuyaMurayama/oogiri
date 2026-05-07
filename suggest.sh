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
  'interpretations': [], 'raw_answers': [], 'selected_answers': [], 'turn_count': 0
}
json.dump(d, open('session.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=2)
PYEOF

# Agent00: お題を生成・表示・session.jsonに保存。エラー（max-turns等）は || true で吸収
claude --model claude-sonnet-4-6 --max-turns 5 \
  'agents/00_topic_suggester.md の Step1〜Step3 を実行してください。
   上位6本のお題を画面に番号付きで提示し、Write ツールで session.json の
   topic_candidates フィールドを6本の文字列配列に更新してください。
   git 操作・コミット・プッシュは一切行わないこと。Step4 も実行しないこと。' || true

echo ""

# topic_candidates が保存されていれば番号入力、なければ手動入力にフォールバック
CANDIDATE_COUNT=$(python3 -c "
import json
try:
    d = json.load(open('session.json', encoding='utf-8'))
    print(len(d.get('topic_candidates', [])))
except Exception:
    print(0)
")

if [ "$CANDIDATE_COUNT" -eq 0 ]; then
  echo "⚠️ 候補の自動取得に失敗しました。お題を直接入力してください。" >&2
  read -r -p "お題を入力: " THEME
else
  read -r -p "番号(1-${CANDIDATE_COUNT})または独自のお題を入力してください: " INPUT

  if [[ "$INPUT" =~ ^[1-6]$ ]]; then
    THEME=$(python3 - "$INPUT" <<'PYEOF'
import json, sys
idx = int(sys.argv[1]) - 1
with open('session.json', encoding='utf-8') as f:
    d = json.load(f)
candidates = d.get('topic_candidates', [])
print(candidates[idx] if 0 <= idx < len(candidates) else '')
PYEOF
)
    if [ -z "$THEME" ]; then
      echo "⚠️ 候補が取得できませんでした。お題を直接入力してください。" >&2
      read -r -p "お題を入力: " THEME
    fi
  else
    THEME="$INPUT"
  fi
fi

if [ -z "$THEME" ]; then
  echo "⚠️ お題が空です。終了します。" >&2
  exit 1
fi

echo ""
exec bash "$SCRIPT_DIR/run.sh" "$THEME"
