@tool
extends HBoxContainer

@export var cards: Array = [] : set = _set_cards
@export var show_numbers: bool = true
@export var show_battle_stats: bool = false
@export var battle_stats: Array = [] : set = _set_battle_stats

var card_display_scene: PackedScene = preload("res://scenes/CardDisplay.tscn")

signal card_clicked(index: int, card_data: Dictionary)


func _ready():
	_refresh()


func _set_cards(value: Array):
	cards = value
	if is_node_ready():
		_refresh()


func _set_battle_stats(value: Array):
	battle_stats = value
	if is_node_ready():
		_refresh()


func _refresh():
	for child in get_children():
		child.queue_free()

	if cards.is_empty():
		return

	for i in range(cards.size()):
		var cd = card_display_scene.instantiate()
		cd.display(cards[i], i + 1 if show_numbers else 0)

		if show_battle_stats and i < battle_stats.size() and battle_stats[i]:
			cd.set_battle_stats(battle_stats[i])

		var idx = i
		cd.clicked.connect(func(_cd): card_clicked.emit(idx, _cd))
		add_child(cd)


func set_card_state(index: int, state: int):
	"""Set visual state of card at index (0-based)."""
	if index >= 0 and index < get_child_count():
		get_child(index).set_state(state)


func reset_all_states():
	"""Reset all cards to normal."""
	for i in get_child_count():
		set_card_state(i, 0)


func set_dead(index: int):
	"""Mark card at index as dead."""
	set_card_state(index, 3)  # DEAD enum


func get_card_display(index: int):
	if index >= 0 and index < get_child_count():
		return get_child(index)
	return null
