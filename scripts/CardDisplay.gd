extends Panel

@export var card_data: Dictionary = {} : set = _set_card_data

signal clicked(card_data: Dictionary)

enum State { NORMAL, ATTACKING, TARGETABLE, DEAD }

var _state: int = State.NORMAL
var _card_number: int = 0

@onready var portrait_rect: ColorRect = $PortraitRect
@onready var name_label: Label = $NameLabel
@onready var jam_label: Label = $JamLabel
@onready var skills_container: VBoxContainer = $SkillsContainer
@onready var card_number_label: Label = $CardNumberLabel
@onready var battle_overlay: Label = $BattleOverlay
@onready var dead_overlay: ColorRect = $DeadOverlay
@onready var dead_label: Label = $DeadOverlay/DeadLabel


func _ready():
	if Engine.is_editor_hint():
		return
	# Make panel transparent so CardBaseTexture shows through
	var transparent_sb = StyleBoxFlat.new()
	transparent_sb.bg_color = Color.TRANSPARENT
	add_theme_stylebox_override("panel", transparent_sb)
	_setup_fonts()
	mouse_entered.connect(_on_mouse_enter)
	mouse_exited.connect(_on_mouse_exit)
	_refresh()


func _setup_fonts():
	name_label.add_theme_font_size_override("font_size", 11)
	jam_label.add_theme_font_size_override("font_size", 8)
	card_number_label.add_theme_font_size_override("font_size", 8)
	card_number_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	battle_overlay.add_theme_font_size_override("font_size", 9)
	battle_overlay.add_theme_color_override("font_color", Color.WHITE)
	dead_label.add_theme_font_size_override("font_size", 14)
	dead_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))


func _set_card_data(value: Dictionary):
	card_data = value
	_refresh()


func display(card: Dictionary, number: int = 0):
	card_data = card
	_card_number = number
	_refresh()


func set_state(state: int):
	_state = state
	_apply_state()


func _apply_state():
	match _state:
		State.ATTACKING:
			self_modulate = Color.WHITE
			scale = Vector2(1.08, 1.08)
			_add_border(Color(1.0, 0.8, 0.0), 3.0)
			z_index = 10
		State.TARGETABLE:
			self_modulate = Color(0.85, 1.0, 0.85)
			scale = Vector2(1.0, 1.0)
			_add_border(Color(0.3, 1.0, 0.3), 2.0)
			z_index = 5
			mouse_default_cursor_shape = CURSOR_POINTING_HAND
		State.DEAD:
			self_modulate = Color(0.35, 0.35, 0.35)
			scale = Vector2(1.0, 1.0)
			_remove_border()
			z_index = 0
			dead_overlay.show()
			mouse_default_cursor_shape = CURSOR_ARROW
		_: # NORMAL
			self_modulate = Color.WHITE
			scale = Vector2(1.0, 1.0)
			_remove_border()
			z_index = 0
			dead_overlay.hide()
			mouse_default_cursor_shape = CURSOR_ARROW


func _add_border(color: Color, width: float):
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color.TRANSPARENT
	sb.border_color = color
	sb.set("border_width_all", width)
	sb.set("corner_radius_all", 4)
	add_theme_stylebox_override("panel", sb)


func _remove_border():
	remove_theme_stylebox_override("panel")


func _gui_input(event: InputEvent):
	if _state != State.TARGETABLE:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(card_data)
		accept_event()


func _on_mouse_enter():
	if _state == State.TARGETABLE:
		self_modulate = Color(1.0, 1.0, 0.85)
		scale = Vector2(1.06, 1.06)


func _on_mouse_exit():
	_apply_state()


func set_battle_stats(stats: Dictionary):
	if not is_node_ready():
		await ready
	var hp = stats.get("hp", 0)
	var max_hp = stats.get("max_hp", 1)
	var atk = stats.get("attack", 0)
	var def_val = stats.get("defense", 0)
	battle_overlay.text = "HP %d/%d  ATK %d  DEF %d" % [hp, max_hp, atk, def_val]
	battle_overlay.show()


func _refresh():
	if not is_node_ready():
		await ready
	if card_data.is_empty():
		return

	name_label.text = card_data.get("name", "??")
	jam_label.text = "Jam #%d" % card_data.get("game_jam", 0)

	if _card_number > 0:
		card_number_label.text = "#%d" % _card_number
		card_number_label.show()
	else:
		card_number_label.hide()

	# Skills
	for child in skills_container.get_children():
		child.queue_free()

	var skills: Array = card_data.get("skills", [])
	for s in skills:
		var row = HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_FILL

		var sl = Label.new()
		sl.text = s.get("name", "?")
		sl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		sl.add_theme_font_size_override("font_size", 8)

		var bar = ProgressBar.new()
		bar.min_value = 0
		bar.max_value = 100
		bar.value = s.get("level", 0)
		bar.custom_minimum_size.x = 50
		bar.custom_minimum_size.y = 10
		bar.show_percentage = false

		var ll = Label.new()
		ll.text = str(s.get("level", 0))
		ll.custom_minimum_size.x = 22
		ll.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		ll.add_theme_font_size_override("font_size", 8)

		row.add_child(sl)
		row.add_child(bar)
		row.add_child(ll)
		skills_container.add_child(row)

	_apply_state()
