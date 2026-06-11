# oogiri-forge — Claude Code 運用ルール

ユーザーのお題に対し、一流芸人が称賛するレベルの大喜利回答を生成するパイプライン（4エージェント）。

> **本ファイルは VSCode版 / Web版 Claude Code（claude.ai）の両方で、本リポジトリの単独完結ガイドです。**
> Web版はグローバル `~/.claude/CLAUDE.md` を参照しません。本リポの運用に必要な全ルールをこの1ファイルに集約しています（他リポ・グローバルとの重複は完結性のため許容）。

---

## 1. セッション開始手順（毎回・最初に実行）

セッション開始時、次の順で必ず読み込んでから作業を始める：

1. **本ファイル（CLAUDE.md）** — 前提制約・実行ルール
2. **`tasks.md`** — セッション間引継ぎタスク（次にやること・優先順位）
3. **`file_index.md`** — ファイル構成の索引

> 編集前に、ユーザー発話のキーワードを `file_index.md` と照合してから対象ファイルを特定する（推測で着手しない）。

---

## 2. コマンド一覧・エージェント構成

| コマンド | 説明 |
|---|---|
| `bash suggest.sh` | お題候補を提示（番号選択でパイプライン起動） |
| `bash run.sh "お題"` | お題を直接指定してパイプライン起動 |
| `bash run.sh --continue` | 中断セッションを再開 |

- ユーザーがお題・テーマを求めたとき → 必ず `bash suggest.sh` を実行し、番号付き候補を提示すること。
- ユーザーが番号を入力したら `bash run.sh` を対応するお題で実行すること。

### エージェント構成
| # | ファイル | モデル | 最大ターン |
|---|---|---|---|
| 00 | `agents/00_topic_suggester.md` | Sonnet | 3 |
| 01 | `agents/01_interpreter.md` | Sonnet | 3 |
| 02 | `agents/02_generator.md` | Opus | 3 |
| 03 | `agents/03_judge_publisher.md` | Sonnet | 3 |

- **総ターン上限**: 12turn / パイプライン全体
- **モデル使い分け**: 計画・生成=Opus / それ以外=Sonnet（期間限定で全タスクOpusの場合もある）

---

## 3. 開発者情報・命名ルール

| 種別 | 表記 | 用途 |
|---|---|---|
| **システム識別子（変更不可）** | `KazuyaMurayama` | GitHub ユーザー名 / URL / `@KazuyaMurayama` |
| **システム識別子（変更不可）** | `kazuya.murayama.21@gmail.com` | git `user.email` / 連絡先 |
| **表記名（人間として記載する場合）** | **男座員也（Kazuya Oza / おざ かずや）** | ドキュメント本文の著者名 / コミット message 中の自己言及 |

- ドキュメント本文等で開発者名を**人間として**記載する際は **男座員也 / Kazuya Oza** を使用。
- 「Murayama」「村山」「Otokoza」「おとこざ」を**表記名**として誤用しない（システム識別子 `KazuyaMurayama` の出現は許容）。
- 開発者の作業環境: OS: Windows 11 / PowerShell 5.1 + Bash 併用可、スマートフォン: iPhone（iOS）。

---

## 4. ツール実行ルール

- **確認不要・即実行**。「Allow〜?」「Should I…?」等の事前確認文を出力しない。即実行 → 事後報告。
- 長時間処理は積極的にバックグラウンド実行する。
- ファイル操作（編集・検索・読み込み）は専用ツール（Edit/Write/Read/Grep/Glob）を直接使用する。
- **例外（事前確認必須）**: main への `git push --force`、`gh repo delete`、その他の不可逆・破壊的操作。

---

## 5. ブランチ管理

- **既定: main へ直接コミット**。ブランチ作成はユーザーが明示指示した場合のみ。
- ブランチを作成した場合、回答完了前に必ず `main` へマージ → ブランチ削除 → push まで完了させる。
  - 手順: `git checkout main; git pull; git merge <branch> --no-ff; git push origin main; git branch -d <branch>`
- 「完了 = main にマージ済み＆push済み」。ブランチにファイルを残したまま回答を終えない。

---

## 6. ファイル保存ルール

- 生成物・スクリプト・中間ファイルはすべて**本リポジトリ内**に保存する。
- `C:\Users\user\Desktop` への出力は禁止（ユーザーが明示した場合のみ例外）。
- 一時スクリプトも本リポ内に作成し、作業後に削除またはコミットする。

---

## 7. 成果物報告ルール（毎回必須）

ファイルを1つでも作成・更新・push したら、**すべての**成果物を次の3列表で報告する。例外なし。

| 成果物 | 説明 | リンク |
|---|---|---|
| file.md | 1行説明 | [開く](https://github.com/KazuyaMurayama/oogiri/blob/main/path/to/file.md) |

**厳守事項**
1. 必ず Markdownリンク `[表示名](URL)` 形式。plain text URL 禁止。
2. `/blob/<実ブランチ>/<実パス>` 形式。リポトップ URL 禁止。
3. **報告前に URL 存在確認**: `gh api repos/KazuyaMurayama/oogiri/contents/PATH?ref=main` でステータス200を確認。
4. ブランチ名は推測せず `git rev-parse --abbrev-ref HEAD` で実値取得。
5. **push 完了後にのみ URL 生成**。未push ファイルは絶対パス＋「（ローカル）」と明記。
6. 404 を出したら即訂正版を提示し、原因を1行報告。

---

## 8. ドキュメント命名・日付ルール（v2.0 / 2026-06-03 改訂）

### ファイル名
- 基本形 `<TOPIC>_YYYYMMDD.md`（**サフィックス・ハイフンなし**）。例: `STRATEGY_REPORT_20260603.md`
- 同日中の追加更新は `-v2`、`-v3`（例: `STRATEGY_REPORT_20260603-v2.md`）。
- 日付が変わったら v サフィックスをリセット。

### 表記の区別
- **ファイル名**: ハイフン**なし** `YYYYMMDD`。
- **本文中の日付**: ハイフン**あり** `YYYY-MM-DD`。

### H1直下の日付メタデータ
レポート系 .md 新規作成時は H1直下に必ず記載し、更新時は **最終更新日のみ** 当日付に書き換える（作成日は固定）：
```
作成日: YYYY-MM-DD
最終更新日: YYYY-MM-DD
```

### 対象外（日付サフィックスを入れない）
README / CLAUDE.md / file_index / tasks.md / CHANGELOG / LICENSE / SPEC.md / `CURRENT_*.md` / `outputs/*.md`（パイプライン出力）。

### 旧形式（廃止・新規禁止）
- ❌ `2026-06-03_<TOPIC>.md` / ❌ `<TOPIC>_2026-06-03.md`
- ✅ `<TOPIC>_20260603.md`（現行ルール）

---

## 9. モデル使い分け

- **メイン: Claude Fable 5（`claude-fable-5`）** — 計画・中〜高難易度の実装/分析・全体指揮。
- **実行フェーズ（定型実装・ファイル編集・テスト実行）**: サブエージェントを `model: "sonnet"` で起動して委譲。
- ※難易度ベースの自動メイン切替は不可。Fable の自動切替は安全性ブロック時の Opus 4.8 フォールバックのみ。

---

## 10. Skill 起動ルール

該当シーンでは、本リポ `.claude/skills/<name>/SKILL.md` を読んでから作業を開始する（**本リポに実在する skill のみ掲載**）。

| トリガー | スキル |
|---|---|
| アイデア出し・選択肢 | `.claude/skills/sp-brainstorming/SKILL.md` |
| 計画立案 | `.claude/skills/sp-writing-plans/SKILL.md` |
| 計画に沿った実行 | `.claude/skills/sp-executing-plans/SKILL.md` |
| 図表生成 | `.claude/skills/mermaid-agents365/SKILL.md` |
| 成果物の納品・コミット前チェック | `.claude/skills/sp-verification-before-completion/SKILL.md` |

> 追加ルール（`.claude/` 配下）: `quality-rules.md`（品質）/ `cross-repo.md`（関連リポ連携）も必要時に参照。

---

## 11. 禁止事項

- おべっか / 楽観コメント
- 名前誤表記（「村山」「Murayama」を表記名として使用禁止）
- ブランチ作成（main 単一運用）

---

## 12. 回答スタイル

- 日本語で回答する。
- 回答末尾に「**Next Action:**」でユーザーの次アクションを具体的に推奨する。迷う場面は「**推奨:**」で明示する。