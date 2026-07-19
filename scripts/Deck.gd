extends Control

## Deck — bir kart destesini yan yana cizer.
## Kartlar Deck'in konumuna gore offset'lenerek yerlesir.

signal card_clicked(index: int, card_data: Dictionary)

@export var cards: Array = [] : set = _set_cards
@export var card_offset_x: int = 66
@export var show_numbers: bool = true

var card_scene: PackedScene = preload("res://scenes/Card.tscn")
var _displays: Array = []


func _set_cards(value: Array):
	cards = value
	_rebuild()


func _rebuild():
	for c in _displays:
		if is_instance_valid(c): c.queue_free()
	_displays.clear()
	if cards.is_empty(): return

	var total_w = cards.size() * 96 + (cards.size() - 1) * (card_offset_x - 96)
	var start_x = (size.x - total_w) / 2

	for i in range(cards.size()):
		var card = card_scene.instantiate()
		card.display(cards[i])
		card.position = Vector2(start_x + i * card_offset_x, 0)
		card.clicked.connect(_on_card_clicked)
		add_child(card)
		_displays.append(card)


func _on_card_clicked(data: Dictionary):
	for i in range(_displays.size()):
		if is_instance_valid(_displays[i]) and _displays[i].card_data == data:
			card_clicked.emit(i, data)
			return


func get_card(index: int):
	if index >= 0 and index < _displays.size():
		return _displays[index]
	return null


func set_card_state(index: int, state: int):
	var c = get_card(index)
	if c: c.set_state(state)


func set_all_states(state: int):
	for c in _displays:
		if is_instance_valid(c): c.set_state(state)


func reset_states():
	for c in _displays:
		if is_instance_valid(c) and c.get_state() != 3:
			c.set_state(0)


func add_card(data: Dictionary):
	cards.append(data)
	_rebuild()


func remove_card(index: int):
	if index >= 0 and index < cards.size():
		cards.remove_at(index)
		_rebuild()


func clear():
	for c in _displays:
		if is_instance_valid(c): c.queue_free()
	_displays.clear()
	cards.clear()
