# oogiri-forge CLAUDE.md

## プロジェクト概要
ユーザーのお題に対し、一流芸人が称賛するレベルの大喜利回答を生成するパイプライン。

## コマンド一覧
| コマンド | 説明 |
|---|---|
| `bash suggest.sh` | お題候補を提示（番号選択でパイプライン起動） |
| `bash run.sh "お題"` | お題を直接指定してパイプライン起動 |
| `bash run.sh --continue` | 中断セッションを再開 |

## ユーザーがお題・テーマを求めたとき
→ 必ず `bash suggest.sh` を実行し、番号付き候補を提示すること。
→ ユーザーが番号を入力したら `bash run.sh` を対応するお題で実行すること。

## エージェント構成（詳細は agents/*.md 参照）
| # | ファイル | モデル | 最大ターン |
|---|---|---|---|
| 00 | agents/00_topic_suggester.md | Sonnet | 3 |
| 01 | agents/01_interpreter.md | Sonnet | 3 |
| 02 | agents/02_generator.md | Opus | 3 |
| 03 | agents/03_judge_publisher.md | Sonnet | 3 |

## 総ターン上限: 12turn / パイプライン全体
## Git操作: ブランチ作成禁止。main上でadd/commit/pushのみ
## モデル: 計画・生成=Opus / それ以外=Sonnet
## 成果物報告: GitHubハイパーリンク必須
## 禁止: おべっか / 楽観コメント / 名前誤表記（村山/Murayama禁止）
## タスク管理: tasks.md 参照
## ファイル一覧: file_index.md 参照

## 開発者情報

このリポジトリの開発者・所有者は **男座員也（Kazuya Oza / おざ かずや）** です。

- ドキュメント・コード・コミット等で開発者名を記載する際は必ず **男座員也** または **Kazuya Oza** を使用する
- 「Murayama」「村山」「Otokoza」「おとこざ」など誤表記は使用しない

### 開発者の作業環境
- **OS:** Windows 11（Macではない）。シェルは PowerShell 5.1 / Bash（WSL/Git Bash）。`brew` / `Cmd+` / Mac専用コマンドは使用不可。パッケージ管理は `winget` / `scoop`。
- **スマートフォン:** iPhone（iOS）。Android固有の手順・adb・Play Store等は不要。
- コマンド例はPowerShell構文（`;` 連結、`$env:VAR`）で提示。macOS専用ツールを回答に含めない。

## 作業品質ルール

### Git・ブランチ管理
- 作業前: `git branch --show-current` でブランチ確認 → main以外なら `git checkout main && git pull` してから開始。

### ファイル特定（編集前）
- ユーザー発話のキーワード全てをファイル名と照合してから編集。キーワード不完全一致・候補不確かなら必ず確認。

### 成果物報告
- ファイル作成・更新・push後は必ず3列表で報告: `| 成果物 | 説明 | リンク |`
- リンクは `/blob/<実ブランチ>/<パス>` 形式。報告前に `gh api repos/OWNER/REPO/contents/PATH?ref=BRANCH` で存在確認。push前はURL生成しない。

### ドキュメント品質
- UIパス・コマンド・設定名は公式ドキュメントで確認後に記載。確認不可なら「[要確認]」と明記。
- OS/環境制約（例: Windows専用）をタスク開始時に確認。完成後に `brew`/`Cmd`/`macOS` 等をgrepして除去。

<!-- SKILLS_RULES_START -->
## Skill 起動ルール（v2.0 / 2026-05-28）
以下のスキルは **必須・スキップ禁止**。該当シーンでは SKILL.md を読んでから作業を開始すること。

- **新機能実装・設計を始める前に必ず** `.claude/skills/sp-brainstorming/SKILL.md` でアイデアを出し、`.claude/skills/sp-writing-plans/SKILL.md` で計画を作成してから着手する
- **複雑な多段タスクは** `.claude/skills/sp-executing-plans/SKILL.md` の手順で実行する
- **アーキ図・フロー図が必要な時は必ず** `.claude/skills/mermaid-agents365/SKILL.md` を読んでからダイアグラムを作成する
- **成果物を納品・コミットする前に必ず** `.claude/skills/sp-verification-before-completion/SKILL.md` のチェックリストを実行する
- **要件調査が真に必要な時のみ** `.claude/skills/research-deep/SKILL.md` を読んで Web リサーチを実行する
<!-- SKILLS_RULES_END -->

## 🚀 自動実行ポリシー

### 確認不要で即実行する操作
- 全ファイル操作（作成・編集・削除）
- 全シェルコマンド（PowerShell, Bash, git, gh, npm, node, python）
- Git操作: add / commit / push / pull / fetch / merge / branch -D / reset --hard
- GitHub操作: gh pr create / gh api 全般 / ブランチ削除
- パッケージ操作: npm install / pip install / Web検索・フェッチ

### 事前確認が必要な操作（例外のみ）
- `git push --force` を main / master ブランチに対して実行する場合
- `gh repo delete` 実行時

### 動作原則
- 計画提示（簡潔）→ 即実行 → 結果報告 のフロー厳守
- 事前確認文（「Should I run...?」等）を出力しない

## ドキュメント日付ルール

レポート系 .md ファイル新規生成時は H1 タイトル直下に必ず記載:
```
作成日: YYYY-MM-DD
最終更新日: YYYY-MM-DD
```
- 更新時は最終更新日のみ当日付に書き換え（作成日は変更しない）
- 除外: README.md / CLAUDE.md / FILE_INDEX.md / tasks.md / CHANGELOG.md

