extends Control

var deck_scene: PackedScene = preload("res://scenes/Deck.tscn")
var _deck: Node = null

@onready var spawn_btn: Button = $SpawnBtn
@onready var clear_btn: Button = $ClearBtn
@onready var count_label: Label = $CountLabel


func _ready():
	spawn_btn.pressed.connect(_on_spawn)
	clear_btn.pressed.connect(_on_clear)

	_deck = deck_scene.instantiate()
	_deck.position = Vector2(20, 120)
	_deck.card_offset_x = 68
	add_child(_deck)

	_update_count()


func _on_spawn():
	if not _deck: return
	var data = CardGenerator.generate_card()
	_deck.add_card(data)
	_update_count()


func _on_clear():
	if _deck:
		_deck.clear()
	_update_count()


func _update_count():
	count_label.text = "Cards: %d" % _deck.cards.size() if _deck else "0"
