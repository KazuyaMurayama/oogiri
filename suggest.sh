#!/bin/bash
# oogiri-forge お題提案スクリプト
# 使用法: bash suggest.sh

echo "🎤 お題を考えています..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━"

claude --model claude-sonnet-4-6 \
  --max-turns 3 \
  "agents/00_topic_suggester.md のStep1〜Step3のルールに従い、
   お題候補を20本生成→スクリーニング→上位6本を番号付きで提示してください。
   提示後はStep4の指示に従い、ユーザーの入力を待ってください。"
