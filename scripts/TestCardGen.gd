extends Control

var card_scene: PackedScene = preload("res://scenes/Card.tscn")
var cards_on_screen: Array = []
var _last_clicked: Node = null

@onready var container: Control = $CardContainer
@onready var count_label: Label = $CountLabel
@onready var spawn_btn: Button = $SpawnBtn
@onready var clear_btn: Button = $ClearBtn
@onready var state_btns: Array = [$NormalBtn, $SelectedBtn, $PickableBtn, $DefeatedBtn]


func _ready():
	spawn_btn.pressed.connect(_on_spawn)
	clear_btn.pressed.connect(_on_clear)
	for i in range(state_btns.size()):
		state_btns[i].pressed.connect(_set_all_state.bind(i))
	_update_count()


func _input(event: InputEvent):
	if event is InputEventKey and event.pressed and event.alt_pressed and event.keycode == KEY_ENTER:
		var mode = DisplayServer.WINDOW_MODE_FULLSCREEN if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_WINDOWED
		DisplayServer.window_set_mode(mode)


func _on_spawn():
	var data = CardGenerator.generate_card()
	var card = card_scene.instantiate()
	card.display(data)
	card.set_state(0)

	# 6 columns max, 96px wide card + 4px gap = 100px, fits in 640px viewport
	var col = cards_on_screen.size() % 6
	var row = floori(cards_on_screen.size() / 6)
	card.position = Vector2(col * 100 + 20, row * 130 + 20)

	container.add_child(card)
	cards_on_screen.append(card)
	_update_count()


func _set_all_state(state: int):
	for c in cards_on_screen:
		if is_instance_valid(c):
			c.set_state(state)


func _on_clear():
	for c in cards_on_screen:
		if is_instance_valid(c):
			c.queue_free()
	cards_on_screen.clear()
	_update_count()


func _update_count():
	count_label.text = "Cards: %d" % cards_on_screen.size()
