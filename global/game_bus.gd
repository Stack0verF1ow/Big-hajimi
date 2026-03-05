# 注册为 Autoload，名称：GameBus
# 纯信号中枢，不持有任何状态，任何节点都可直接 GameBus.signal_name.emit() / connect()
extends Node

# ── 游戏流程 ─────────────────────────────────────────────────
@warning_ignore("unused_signal")
signal game_over_triggered               # DeadLine → GameManager
@warning_ignore("unused_signal")
signal pause_requested                   # UI暂停按钮 → GameManager
@warning_ignore("unused_signal")
signal resume_requested                  # UI继续按钮 → GameManager

# ── 数据更新（GameManager → UI）────────────────────────────
@warning_ignore("unused_signal")
signal score_changed(score: int)
@warning_ignore("unused_signal")
signal queue_changed(indices: Array[int])

# ── 球事件 ───────────────────────────────────────────────────
@warning_ignore("unused_signal")
signal ball_merge_requested(ball_a: Ball, ball_b: Ball)
@warning_ignore("unused_signal")
signal launch_requested
