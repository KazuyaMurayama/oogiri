#!/bin/bash
# oogiri-forge メインパイプライン
# 使用法: bash run.sh "お題テキスト" または bash run.sh --continue

set -euo pipefail
trap 'echo "❌ エラー発生 (run.sh line $LINENO, exit=$?)" >&2' ERR

THEME="${1:-}"
readonly SESSION_FILE="session.json"
IS_CONTINUE=false

mkdir -p outputs

# --continue フラグ処理
if [ "$THEME" = "--continue" ]; then
  IS_CONTINUE=true
  echo "🔄 セッション再開..."
  THEME=$(python3 -c "import json; d=json.load(open('session.json', encoding='utf-8')); print(d.get('theme','') or '')")
  if [ -z "$THEME" ]; then
    echo "⚠️ session.json にテーマが見つかりません。bash suggest.sh で再開してください。" >&2
    exit 1
  fi
fi

if [ -z "$THEME" ]; then
  echo "⚠️ お題が指定されていません。bash suggest.sh でお題を選択してください。" >&2
  exit 1
fi

# セッション初期化（--continue 時はスキップ）
if [ "$IS_CONTINUE" = false ]; then
  OOGIRI_THEME="$THEME" OOGIRI_TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)" python3 - <<'PYEOF'
import json, os
d = {
  'theme': os.environ['OOGIRI_THEME'],
  'created_at': os.environ['OOGIRI_TS'],
  'status': 'running',
  'interpretations': [],
  'raw_answers': [],
  'selected_answers': [],
  'turn_count': 0,
  'topic_candidates': []
}
json.dump(d, open('session.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=2)
print('セッション初期化完了')
PYEOF
fi

echo ""
echo "🎤 お題: $THEME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Agent01: テーマ解析（Sonnet）
echo "🔍 [Agent01] テーマ解析中..."
claude --model claude-sonnet-4-6 \
  --max-turns 10 \
  'agents/01_interpreter.md のルールに従い、session.json の theme フィールドを読み取り、
   6軸で解析して interpretations フィールドを部分更新してください。
   theme の値は session.json から読み込むこと（外部入力からは受け取らない）。
   【重要】git操作（add/commit/push）は絶対に行わないこと。ファイル更新のみで完了とする。'

# Agent02: 大喜利生成（Opus）
echo "✍️  [Agent02] 大喜利回答生成中（Opus使用）..."
claude --model claude-opus-4-5 \
  --max-turns 10 \
  'agents/02_generator.md のルールに従い、session.json の interpretations フィールドを読み取り、
   12〜18本の大喜利回答を生成して raw_answers フィールドを部分更新してください。
   【重要】git操作（add/commit/push）は絶対に行わないこと。ファイル更新のみで完了とする。'

# raw_answers 件数バリデーション
RAW_COUNT=$(python3 -c "import json; print(len(json.load(open('session.json', encoding='utf-8')).get('raw_answers', [])))")
if [ "$RAW_COUNT" -lt 8 ]; then
  echo "❌ raw_answers が ${RAW_COUNT} 件しかありません（最低8件必要）。Agent03 をスキップして終了します。" >&2
  exit 1
fi
echo "✓ raw_answers ${RAW_COUNT} 件確認"

# Agent03: 審査＆GitHub公開（Sonnet）
echo "⚖️  [Agent03] 審査・選別・GitHub公開中..."
claude --model claude-sonnet-4-6 \
  --max-turns 7 \
  'agents/03_judge_publisher.md の Phase A → Phase B の順で実行してください。
   theme および raw_answers は session.json から読み取ること。
   審査後に MD ファイルを outputs/ に保存し、git add/commit/push して
   GitHub リンクをハイパーリンク形式で報告してください。'

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ パイプライン完了"
