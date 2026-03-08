extends Node

# ── 球事件（场景节点 → Autoload 状态）───────────────────────
signal ball_merge_requested(ball_a: Ball, ball_b: Ball)
signal game_over_triggered                              # DeadLine → GameStateInPlay

# ── 游戏流程（UI ↔ GameManager 状态机）─────────────────────
signal game_to_be_pause                                 # UI → GameStateInPlay
signal game_to_be_continue                              # UI → GameStatePause
signal game_continued                                   # GameStatePause → UI

# ── 数据展示（GameManager → 场景节点）──────────────────────
signal score_changed(score: int)                        # → UI
signal game_over(final_score: int)                      # → UI
signal launcher_preview_updated(texture_path: String, radius: float)  # → LauncherManager
signal queue_preview_updated(texture_paths: Array[String])             # → UI
