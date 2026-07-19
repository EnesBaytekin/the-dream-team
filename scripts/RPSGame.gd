extends Control

signal game_ended(result: Dictionary)

@onready var player_hand: Node = $PlayerHand
@onready var enemy_hand: Node = $EnemyHand
@onready var result_label: Label = $ResultLabel
@onready var rock_btn: Button = $RockBtn
@onready var paper_btn: Button = $PaperBtn
@onready var scissors_btn: Button = $ScissorsBtn

var _player_choice: int = -1
var _cpu_choice: int = -1
var _playing: bool = false


func _ready():
	rock_btn.pressed.connect(_on_choice.bind(0))
	paper_btn.pressed.connect(_on_choice.bind(1))
	scissors_btn.pressed.connect(_on_choice.bind(2))
	_set_buttons_enabled(true)


func _set_buttons_enabled(val: bool):
	rock_btn.disabled = not val
	paper_btn.disabled = not val
	scissors_btn.disabled = not val


func _on_choice(choice: int):
	if _playing: return
	_playing = true
	_set_buttons_enabled(false)
	_player_choice = choice
	_cpu_choice = randi() % 3
	result_label.text = "..."

	# Ready animation (placeholder)
	player_hand.set_state(1)  # READY
	enemy_hand.set_state(1)   # READY
	await _wait(0.5)

	# Show choices
	player_hand.play_choice(_player_choice)
	enemy_hand.play_choice(_cpu_choice)
	await _wait(0.3)

	# Calculate result
	var outcome = _rps_outcome(_player_choice, _cpu_choice)
	var won = outcome == "win"
	var lost = outcome == "lose"

	if outcome == "draw":
		result_label.text = "DRAW!"
		await _wait(0.5)
		_playing = false
		_set_buttons_enabled(true)
		player_hand.set_state(0)
		enemy_hand.set_state(0)
		result_label.text = "Try again!"
		return

	result_label.text = "YOU WIN!" if won else "YOU LOSE!"
	await _wait(0.8)

	_playing = false
	_set_buttons_enabled(true)
	player_hand.set_state(0)
	enemy_hand.set_state(0)

	game_ended.emit({
		"result": "win" if won else "lose",
		"player_choice": _player_choice,
		"cpu_choice": _cpu_choice,
	})


func _rps_outcome(p: int, c: int) -> String:
	if p == c: return "draw"
	if (p == 0 and c == 2) or (p == 1 and c == 0) or (p == 2 and c == 1):
		return "win"
	return "lose"


func _wait(s: float):
	await get_tree().create_timer(s).timeout
