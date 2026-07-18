extends MarginContainer

enum State { NORMAL, SELECTED, PICKABLE, DEFEATED }

@export var card_data: Dictionary = {} : set = _set_card_data

var _state: int = State.NORMAL
var _base_y: float = 0.0
var _tween: Tween = null
var _target_y: float = INF

@onready var user_pp: TextureRect = $Control/UserPP
@onready var user_name: Label = $Control/UserName
@onready var jam_count: Label = $Control/JamCount
@onready var skill_labels: Array = [$Control/Skill1, $Control/Skill2, $Control/Skill3]
@onready var select_highlight: ColorRect = $Control/SelectHighlight
@onready var defeated_overlay: ColorRect = $Control/DefeatedOverlay


func _ready():
	_base_y = position.y
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_unhover)
	_apply_state()


func _set_card_data(value: Dictionary):
	card_data = value
	_refresh()


func display(data: Dictionary):
	card_data = data
	_refresh()


func set_state(s: int):
	_state = s
	if is_inside_tree():
		_apply_state()


func get_state() -> int:
	return _state


func _smooth_move(target_y: float):
	if is_equal_approx(position.y, target_y) or is_equal_approx(_target_y, target_y):
		return
	_target_y = target_y
	if _tween:
		_tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	_tween.tween_property(self, "position:y", target_y, 0.1)
	_tween.finished.connect(func(): _target_y = INF, CONNECT_ONE_SHOT)


func _apply_state():
	if not is_inside_tree():
		return
	match _state:
		State.NORMAL:
			mouse_filter = MOUSE_FILTER_IGNORE
			_smooth_move(_base_y)
			_remove_border()
			select_highlight.hide()
			defeated_overlay.hide()

		State.SELECTED:
			mouse_filter = MOUSE_FILTER_IGNORE
			_smooth_move(_base_y - 6)
			_add_border(Color(1, 1, 1), 2)
			select_highlight.hide()
			defeated_overlay.hide()

		State.PICKABLE:
			mouse_filter = MOUSE_FILTER_STOP
			_smooth_move(_base_y)
			_remove_border()
			select_highlight.hide()
			defeated_overlay.hide()

		State.DEFEATED:
			mouse_filter = MOUSE_FILTER_IGNORE
			_smooth_move(_base_y)
			_remove_border()
			select_highlight.hide()
			defeated_overlay.show()


func _add_border(color: Color, width: float):
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color.TRANSPARENT
	sb.border_color = color
	sb.set("border_width_all", width)
	add_theme_stylebox_override("panel", sb)


func _remove_border():
	remove_theme_stylebox_override("panel")


func _on_hover():
	if _state == State.PICKABLE:
		_smooth_move(_base_y - 6)
		select_highlight.color = Color(1, 1, 1, 0.2)
		select_highlight.show()


func _on_unhover():
	if _state == State.PICKABLE:
		_smooth_move(_base_y)
		select_highlight.hide()


func _refresh():
	if not is_node_ready():
		await ready
	if card_data.is_empty():
		return

	user_name.text = card_data.get("name", "??")
	var jam_number = card_data.get("game_jam", 0)
	var jam_suffix = "th"
	match jam_number%10:
		1: jam_suffix = "st"
		2: jam_suffix = "nd"
		3: jam_suffix = "rd"
	jam_count.text = ("%d" % jam_number) + jam_suffix + " jam"

	var skills: Array = card_data.get("skills", [])
	for i in range(skill_labels.size()):
		if i < skills.size():
			var s = skills[i]
			skill_labels[i].text = "* %s" % s.get("name", "?")
			skill_labels[i].show()
		else:
			skill_labels[i].hide()

	_apply_state()
