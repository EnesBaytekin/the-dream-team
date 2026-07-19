extends Control

enum State { IDLE, READY, ROCK, PAPER, SCISSORS }
enum Side { PLAYER, ENEMY }

@export var side: int = Side.PLAYER

var _state: int = State.IDLE

@onready var label: Label = $Label
@onready var bg: ColorRect = $Bg


func _ready():
	_apply_state()


func set_state(s: int):
	_state = s
	_apply_state()


func get_state() -> int:
	return _state


func play_choice(choice: int):
	set_state(choice + 2)


func _apply_state():
	var t = ""
	var c = Color(0.3, 0.3, 0.3, 0.3)
	match _state:
		State.IDLE: t = "Hand"; c = Color(0.3, 0.3, 0.3, 0.3)
		State.READY: t = "..."; c = Color(0.8, 0.8, 0.2, 0.3)
		State.ROCK: t = "ROCK"; c = Color(0.8, 0.3, 0.3, 0.3)
		State.PAPER: t = "PAPER"; c = Color(0.3, 0.8, 0.3, 0.3)
		State.SCISSORS: t = "SCISSORS"; c = Color(0.3, 0.3, 0.8, 0.3)
	label.text = t
	bg.color = c
