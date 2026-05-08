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

<!-- GLOBAL_RULES_START -->
## Global Rules (synced from ~/.claude/CLAUDE.md)

### 成果物報告（最重要・毎回必須）
ファイルを1つでも作成・更新・pushしたら、**すべて**を3列表で報告する。例外なし。

| 成果物 | 説明 | リンク |
|---|---|---|
| ファイル名 | 1行説明 | [開く](https://github.com/OWNER/REPO/blob/BRANCH/PATH) |

厳守事項（違反＝再提出）:
1. Markdownリンク `[表示名](URL)` 形式必須。plain URL禁止。
2. `/blob/<実ブランチ名>/<実パス>` 形式。トップURL禁止。
3. 提示前に `gh api repos/OWNER/REPO/contents/PATH?ref=BRANCH` で存在確認。
4. ブランチ名は `git rev-parse --abbrev-ref HEAD` で取得。推測禁止。
5. push完了後のみURL生成。未pushはローカル絶対パス＋「（ローカル）」明記。
6. 404発生時は即訂正＋原因1行報告。

### ツール実行
- 確認不要・即実行。「Should I...?」等の事前確認文は出力しない。
- 例外（事前確認必須）: main/masterへの `git push --force`、`gh repo delete`。
- 長時間処理は `run_in_background: true` を積極使用。

### モデル・サブエージェント
- メイン Opus / 探索・検索・テスト系サブは Sonnet (`model: "sonnet"`)。
- サブ起動promptに必ず明記:「成果物は3列表報告・URL検証必須・Markdownリンク形式」

### 回答スタイル
- 回答末尾に「**Next Action:**」でユーザーの次アクションを具体推奨。
<!-- GLOBAL_RULES_END -->
