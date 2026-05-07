#!/bin/bash
# oogiri-forge メインパイプライン
# 使用法: bash run.sh "お題テキスト" または bash run.sh --continue

set -e
THEME="${1:-}"
SESSION_FILE="session.json"
IS_CONTINUE=false

# --continue フラグ処理
if [ "$THEME" = "--continue" ]; then
  IS_CONTINUE=true
  echo "🔄 セッション再開..."
  THEME=$(python3 -c "import json; d=json.load(open('$SESSION_FILE')); print(d.get('theme',''))")
  if [ -z "$THEME" ]; then
    echo "⚠️ session.json にテーマが見つかりません。bash suggest.sh で再開してください。"
    exit 1
  fi
fi

if [ -z "$THEME" ]; then
  echo "⚠️ お題が指定されていません。bash suggest.sh でお題を選択してください。"
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
json.dump(d, open('session.json', 'w'), ensure_ascii=False, indent=2)
print('セッション初期化完了')
PYEOF
fi

echo ""
echo "🎤 お題: $THEME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Agent01: テーマ解析（Sonnet）
echo "🔍 [Agent01] テーマ解析中..."
claude --model claude-sonnet-4-6 \
  --max-turns 3 \
  "agents/01_interpreter.md のルールに従い、session.json のtheme「$THEME」を
   6軸で解析し、interpretationsフィールドに保存してください。"

# Agent02: 大喜利生成（Opus）
echo "✍️  [Agent02] 大喜利回答生成中（Opus使用）..."
claude --model claude-opus-4-5 \
  --max-turns 3 \
  "agents/02_generator.md のルールに従い、session.json のinterpretationsをもとに
   12〜18本の大喜利回答を生成し、raw_answersフィールドに保存してください。"

# Agent03: 審査＆GitHub公開（Sonnet）
echo "⚖️  [Agent03] 審査・選別・GitHub公開中..."
claude --model claude-sonnet-4-6 \
  --max-turns 3 \
  "agents/03_judge_publisher.md のPhaseA→PhaseBの順で実行してください。
   審査後にMDファイルを outputs/ に保存し、git add/commit/pushして
   GitHubリンクをハイパーリンク形式で報告してください。"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ パイプライン完了"
