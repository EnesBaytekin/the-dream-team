extends MarginContainer

enum State { NORMAL, SELECTED, PICKABLE, DEFEATED }

@export var card_data: Dictionary = {} : set = _set_card_data

signal clicked(card_data: Dictionary)

var _state: int = State.NORMAL
var _base_y: float = 0.0
var _tween: Tween = null
var _target_y: float = INF

@onready var user_pp: TextureRect = $Control/UserPP
@onready var user_name: Label = $Control/UserName
@onready var jam_count: Label = $Control/JamCount
@onready var skills_container: VBoxContainer = $Control/Skills
@onready var hover_overlay: ColorRect = $Control/HoverOverlay
@onready var defeated_overlay: ColorRect = $Control/DefeatedOverlay
@onready var hp_label: Label = $Control/HPLabel

var _border_pieces: Array = []
var _battle_hp: int = -1
var _battle_max_hp: int = -1
var _skill_rows: Array = []


func _ready():
	_base_y = position.y
	_create_border()
	for i in range(3):
		var row = HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_FILL
		var nl = Label.new()
		nl.add_theme_font_size_override("font_size", 8)
		nl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nl.add_theme_font_override("font", load("res://assets/Mojang-Regular.ttf"))
		var vl = Label.new()
		vl.add_theme_font_size_override("font_size", 8)
		vl.add_theme_font_override("font", load("res://assets/Mojang-Regular.ttf"))
		vl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		vl.custom_minimum_size.x = 12
		row.add_child(nl)
		row.add_child(vl)
		skills_container.add_child(row)
		_skill_rows.append(row)
	skills_container.add_theme_constant_override("separation", 0)
	skills_container.add_theme_constant_override("h_separation", 0)
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_unhover)
	_apply_state()


func _create_border():
	var control = $Control
	var pieces = [[0, 0, 96, 1], [0, 119, 96, 120], [0, 0, 1, 120], [95, 0, 96, 120]]
	for p in pieces:
		var rect = ColorRect.new()
		rect.color = Color.WHITE
		rect.mouse_filter = MOUSE_FILTER_IGNORE
		rect.position = Vector2(p[0], p[1])
		rect.size = Vector2(p[2] - p[0], p[3] - p[1])
		rect.hide()
		control.add_child(rect)
		_border_pieces.append(rect)


func _set_card_data(value: Dictionary):
	card_data = value
	_refresh()


func display(data: Dictionary):
	card_data = data
	_battle_hp = -1
	_refresh()


func set_battle_stats(hp: int, max_hp: int, atk: int, def_val: int):
	_battle_hp = hp
	_battle_max_hp = max_hp
	hp_label.text = "%d/%d" % [hp, max_hp]
	hp_label.show()


func set_state(s: int):
	_state = s
	if is_inside_tree(): _apply_state()


func get_state() -> int: return _state


func _smooth_move(target_y: float):
	if is_equal_approx(position.y, target_y) or is_equal_approx(_target_y, target_y): return
	_target_y = target_y
	if _tween: _tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	_tween.tween_property(self, "position:y", target_y, 0.1)
	_tween.finished.connect(func(): _target_y = INF, CONNECT_ONE_SHOT)


func _show_border():
	for b in _border_pieces: b.show()
func _hide_border():
	for b in _border_pieces: b.hide()


func _apply_state():
	if not is_inside_tree(): return
	match _state:
		State.NORMAL:
			mouse_filter = MOUSE_FILTER_IGNORE
			_smooth_move(_base_y); hover_overlay.hide(); _hide_border(); defeated_overlay.hide()
		State.SELECTED:
			mouse_filter = MOUSE_FILTER_IGNORE
			_smooth_move(_base_y - 6); hover_overlay.hide(); _show_border(); defeated_overlay.hide()
		State.PICKABLE:
			mouse_filter = MOUSE_FILTER_STOP
			_smooth_move(_base_y); hover_overlay.hide(); _hide_border(); defeated_overlay.hide()
		State.DEFEATED:
			mouse_filter = MOUSE_FILTER_IGNORE
			_smooth_move(_base_y); hover_overlay.hide(); _hide_border(); defeated_overlay.show()


func _gui_input(event: InputEvent):
	if _state == State.PICKABLE and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(card_data); accept_event()


func _on_hover():
	if _state == State.PICKABLE:
		_smooth_move(_base_y - 6); hover_overlay.show()


func _on_unhover():
	if _state == State.PICKABLE:
		_smooth_move(_base_y); hover_overlay.hide()


func _refresh():
	if not is_node_ready(): await ready
	if card_data.is_empty(): return
	user_name.text = card_data.get("name", "??")
	var jn = card_data.get("game_jam", 0)
	var js = "th"
	match jn % 10:
		1: js = "st"
		2: js = "nd"
		3: js = "rd"
	jam_count.text = ("%d" % jn) + js + " jam"
	var skills: Array = card_data.get("skills", [])
	for i in range(3):
		if i < skills.size():
			var s = skills[i]
			_skill_rows[i].show()
			_skill_rows[i].get_child(0).text = "   "+s.get("name", "?")
			_skill_rows[i].get_child(1).text = str(s.get("level", 0))
		else:
			_skill_rows[i].hide()
	_apply_state()
