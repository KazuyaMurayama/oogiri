#!/bin/bash
# oogiri-forge お題提案スクリプト
# 使用法: bash suggest.sh

set -euo pipefail
trap 'echo "❌ エラー発生 (suggest.sh line $LINENO)" >&2' ERR

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "🎤 お題候補を生成しています..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━"

# -p モードで出力のみ取得（ファイル書き込みなし → stop hook 不発）
# claude が JSON 1行を末尾に出力するよう指示
TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

claude -p --model claude-sonnet-4-6 \
  'サラリーマン・子育て中・犬飼いのユーザーに刺さる大喜利お題6本を選んでください。

条件:
- 「もし〇〇だったら」または「〇〇な△△」形式
- 各30文字以内、固有名詞・時事ネタ禁止
- 興味度(1-5)×面白さ(1-5)でスコアリングし合計8点以上のみ

出力は必ず以下の2ブロック構成にすること（他の説明文は一切不要）:

【ブロック1: 表示用テキスト】
━━━━━━━━━━━━━━━━━━━━━━━━━━
🎤 今日の大喜利 お題候補
━━━━━━━━━━━━━━━━━━━━━━━━━━

1️⃣  {お題1}
   📊 興味度 ★★★★★  面白さ ★★★★☆  合計 9/10

2️⃣  {お題2}
   📊 興味度 ★★★★☆  面白さ ★★★★★  合計 9/10

（以下同様に6番まで）

━━━━━━━━━━━━━━━━━━━━━━━━━━
番号を入力するか、独自のお題を入力してください。
━━━━━━━━━━━━━━━━━━━━━━━━━━

【ブロック2: パース用JSON（必ず最終行に1行で出力）】
CANDIDATES_JSON:{"topics":["お題1","お題2","お題3","お題4","お題5","お題6"]}' \
  > "$TMPFILE" 2>/dev/null || true

# ブロック1（CANDIDATES_JSON行の前まで）を画面に表示
grep -v '^CANDIDATES_JSON:' "$TMPFILE" || true
echo ""

# ブロック2からお題リストを抽出してsession.jsonに保存
python3 - "$TMPFILE" <<'PYEOF'
import json, sys, re

with open(sys.argv[1], encoding='utf-8') as f:
    content = f.read()

match = re.search(r'CANDIDATES_JSON:(\{.*\})', content)
candidates = json.loads(match.group(1)).get('topics', []) if match else []

import datetime
d = {
  'theme': '',
  'created_at': datetime.datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ'),
  'status': 'topic_suggesting',
  'topic_candidates': candidates,
  'interpretations': [], 'raw_answers': [], 'selected_answers': [], 'turn_count': 0
}
json.dump(d, open('session.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=2)

if not candidates:
    print("⚠️ JSON取得失敗。お題を直接入力してください。", file=sys.stderr)
PYEOF

CANDIDATE_COUNT=$(python3 -c "import json; print(len(json.load(open('session.json',encoding='utf-8')).get('topic_candidates',[])))")

if [ "$CANDIDATE_COUNT" -eq 0 ]; then
  read -r -p "お題を直接入力してください: " THEME
else
  read -r -p "番号(1-${CANDIDATE_COUNT})または独自お題を入力: " INPUT

  if [[ "$INPUT" =~ ^[1-6]$ ]]; then
    THEME=$(python3 -c "
import json, sys
idx = int('$INPUT') - 1
d = json.load(open('session.json', encoding='utf-8'))
c = d.get('topic_candidates', [])
print(c[idx] if 0 <= idx < len(c) else '')
")
    if [ -z "$THEME" ]; then
      read -r -p "お題を直接入力してください: " THEME
    fi
  else
    THEME="$INPUT"
  fi
fi

[ -z "$THEME" ] && { echo "⚠️ お題が空です。終了します。" >&2; exit 1; }

echo ""
exec bash "$SCRIPT_DIR/run.sh" "$THEME"
