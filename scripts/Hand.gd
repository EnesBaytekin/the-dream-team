extends Control

enum State { IDLE, READY, ROCK, PAPER, SCISSORS }
enum Side { PLAYER, ENEMY }

@export var side: int = Side.PLAYER

var _state: int = State.IDLE
var _base_y: float = 0.0

const ROCK_TEX = preload("res://assets/rock.png")
const SCISSORS_TEX = preload("res://assets/scissors.png")
const PAPER_TEX = preload("res://assets/paper.png")

@onready var tex: TextureRect = $Tex


func _ready():
	_base_y = position.y
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if side == Side.ENEMY:
		tex.flip_h = true
	_apply_state()


func set_state(s: int):
	_state = s
	_apply_state()


func get_state() -> int:
	return _state


func play_choice(choice: int):
	set_state(choice + 2)


func _apply_state():
	match _state:
		State.IDLE:
			tex.texture = ROCK_TEX
			tex.modulate = Color.WHITE
		State.READY:
			tex.texture = ROCK_TEX
			tex.modulate = Color.WHITE
		State.ROCK:
			tex.texture = ROCK_TEX
			tex.modulate = Color.WHITE
		State.PAPER:
			tex.texture = PAPER_TEX
			tex.modulate = Color.WHITE
		State.SCISSORS:
			tex.texture = SCISSORS_TEX
			tex.modulate = Color.WHITE


func play_ready_animation() -> Signal:
	set_state(State.READY)
	var tw = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	var up_y = _base_y - 40
	var down_y = _base_y
	for i in range(3):
		tw.tween_property(self, "position:y", up_y, 0.12)
		tw.tween_property(self, "position:y", down_y, 0.12)
	return tw.finished
