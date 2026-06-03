# oogiri-forge — Claude Code 運用ルール

ユーザーのお題に対し、一流芸人が称賛するレベルの大喜利回答を生成するパイプライン（4エージェント）。

> **本ファイルは VSCode版 / Web版 Claude Code（claude.ai）の両方で本リポジトリの単独完結ガイド**。
> Web版はグローバル `~/.claude/CLAUDE.md` を参照しない前提で、本リポの運用に必要な全ルールをここに集約。

---

## 0. コマンド一覧
| コマンド | 説明 |
|---|---|
| `bash suggest.sh` | お題候補を提示（番号選択でパイプライン起動） |
| `bash run.sh "お題"` | お題を直接指定してパイプライン起動 |
| `bash run.sh --continue` | 中断セッションを再開 |

### ユーザーがお題・テーマを求めたとき
→ 必ず `bash suggest.sh` を実行し、番号付き候補を提示すること。
→ ユーザーが番号を入力したら `bash run.sh` を対応するお題で実行すること。

---

## 1. エージェント構成
| # | ファイル | モデル | 最大ターン |
|---|---|---|---|
| 00 | `agents/00_topic_suggester.md` | Sonnet | 3 |
| 01 | `agents/01_interpreter.md` | Sonnet | 3 |
| 02 | `agents/02_generator.md` | Opus | 3 |
| 03 | `agents/03_judge_publisher.md` | Sonnet | 3 |

- **総ターン上限**: 12turn / パイプライン全体
- **モデル使い分け**: 計画・生成=Opus / それ以外=Sonnet（期間限定で全タスクOpusの場合もある）
- **タスク管理**: `tasks.md` 参照
- **ファイル一覧**: `file_index.md` 参照

---

## 2. 開発者情報・命名ルール

| 種別 | 表記 | 用途 |
|---|---|---|
| **システム識別子（変更不可）** | `KazuyaMurayama` | GitHub ユーザー名 / URL / `@KazuyaMurayama` |
| **システム識別子（変更不可）** | `kazuya.murayama.21@gmail.com` | git `user.email` / 連絡先 |
| **表記名（人間として記載する場合）** | **男座員也（Kazuya Oza / おざ かずや）** | ドキュメント本文の著者名 / コミット message 中の自己言及 |

- ドキュメント本文等で開発者名を**人間として**記載する際は **男座員也 / Kazuya Oza** を使用
- 「Murayama」「村山」「Otokoza」「おとこざ」を**表記名**として誤用しない（システム識別子としての `KazuyaMurayama` は許容）

### 開発者の作業環境
- OS: Windows 11 / PowerShell 5.1 + Bash 併用可
- スマートフォン: iPhone（iOS）

---

## 3. ツール実行・Git・ファイル保存
- 確認不要・即実行（事前確認文を出力しない）
- 例外（事前確認必須）: main への `git push --force`、`gh repo delete`
- **Git 操作**: ブランチ作成禁止。main 上で add / commit / push のみ
- **ファイル保存**: 本リポ内のみ。`C:\Users\user\Desktop` への出力禁止

---

## 4. 成果物報告ルール（GitHub ハイパーリンク必須）

| 成果物 | 説明 | リンク |
|---|---|---|
| file.md | 1行説明 | [開く](https://github.com/KazuyaMurayama/oogiri/blob/main/path/to/file.md) |

- Markdownリンク `[表示名](URL)` 形式必須 / `/blob/<実ブランチ>/<実パス>` 形式
- **報告前にURL存在確認**：`Invoke-WebRequest -Uri https://api.github.com/repos/KazuyaMurayama/oogiri/contents/PATH?ref=main -UseBasicParsing` でステータス200確認
- push完了後のみURL生成

---

## 5. 禁止事項
- おべっか / 楽観コメント
- 名前誤表記（村山/Murayama 表記名としては禁止）
- ブランチ作成（main 単一運用）

---

## 6. Skill 起動ルール

| トリガー | スキル |
|---|---|
| アイデア出し・選択肢 | `.claude/skills/sp-brainstorming/SKILL.md` |
| 計画立案・実行 | `.claude/skills/sp-writing-plans/SKILL.md` + `sp-executing-plans/SKILL.md` |
| 並列エージェント運用 | `.claude/skills/sp-dispatching-parallel-agents/SKILL.md` |
| QC・レビュー前 | `.claude/skills/analysis-qa-checklist/SKILL.md` |
| 成果物の納品・コミット前 | `.claude/skills/sp-verification-before-completion/SKILL.md` |

---

## ドキュメント命名・日付ルール（v2.0 / 2026-06-03 改訂）

### ファイル名
- `<TOPIC>_YYYYMMDD.md` 形式（**サフィックス・ハイフンなし**）
  - 例: `STRATEGY_REPORT_20260603.md`
- **同日中の追加更新**: `-v2`、`-v3` を追加（例: `STRATEGY_REPORT_20260603-v2.md`）
- **翌日1回目**: v サフィックスをリセット（例: `STRATEGY_REPORT_20260604.md`）

### 表記の区別
- **ファイル名**: ハイフン**なし** `YYYYMMDD`（例: `20260603`）
- **本文中の日付表記**: ハイフン**あり** `YYYY-MM-DD`（例: `2026-06-03`）

### H1直下の日付メタデータ
レポート系 .md 新規作成時は H1直下に必ず記載:
```
作成日: YYYY-MM-DD
最終更新日: YYYY-MM-DD
```
更新時は **最終更新日のみ** 当日付に書き換え（作成日は固定）。

### 対象外（日付サフィックスを入れない）
- README / CLAUDE.md / FILE_INDEX / tasks.md / CHANGELOG / LICENSE / SPEC.md
- `CURRENT_*.md`（常に最新で参照される単一ファイル）
- パイプライン自動生成ファイル（例: `REPORT.md`、`outputs/*.md`）

### 旧形式（廃止・新規禁止）
- ❌ `<TOPIC>_2026-06-03.md`（ハイフン区切り）
- ✅ `<TOPIC>_20260603.md`（**現行ルール**）
