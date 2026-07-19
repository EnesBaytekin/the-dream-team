extends Control

signal done(deck: Array)

@onready var status_label: Label = $StatusLabel
@onready var offer_area: Control = $OfferArea
@onready var my_deck: Node = $MyDeck
@onready var skip_btn: Button = $SkipBtn

var _deck_data: Array = []
var _offer_cards: Array = []


func show_trade(won: bool, deck: Array):
	_deck_data = deck.duplicate()
	_offer_cards.clear()

	for c in offer_area.get_children(): c.queue_free()
	skip_btn.hide()
	skip_btn.text = "Continue"
	if skip_btn.pressed.is_connected(_on_skip):
		skip_btn.pressed.disconnect(_on_skip)
	skip_btn.pressed.connect(_on_skip, CONNECT_ONE_SHOT)

	my_deck.cards = _deck_data.duplicate()

	if won:
		await _do_win()
	else:
		await _do_lose()
	skip_btn.show()


func _do_win():
	status_label.text = "YOU WIN! Pick a card to add!"
	for i in range(3):
		var data = CardGenerator.generate_good_card()
		_offer_cards.append(data)
		_add_offer_card(data, i)


func _do_lose():
	status_label.text = "Removing a card..."
	var lost_idx = randi() % _deck_data.size()
	var lost_card = _deck_data[lost_idx]
	_deck_data.remove_at(lost_idx)

	await get_tree().process_frame

	if lost_idx < my_deck._displays.size():
		my_deck._displays[lost_idx].set_state(1)
	await _wait(0.4)

	if lost_idx < my_deck._displays.size():
		var cd = my_deck._displays[lost_idx]
		var tw = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		tw.tween_property(cd, "position:x", cd.position.x + 300, 0.6)
		tw.parallel().tween_property(cd, "modulate", Color(1, 0.2, 0.2, 0), 0.6)
		await tw.finished

	my_deck.cards = _deck_data.duplicate()
	status_label.text = "YOU LOSE! Lost: %s" % lost_card.get("name", "??")
	await _wait(0.3)
	status_label.text = "Pick a replacement card:"

	for i in range(3):
		var data = CardGenerator.generate_bad_card()
		_offer_cards.append(data)
		_add_offer_card(data, i)


func _add_offer_card(data: Dictionary, idx: int):
	var card = preload("res://scenes/Card.tscn").instantiate()
	card.display(data)
	card.set_state(2)
	card.clicked.connect(_on_card_chosen.bind(idx), CONNECT_ONE_SHOT)
	card.position = Vector2(170 * idx + 50, 15)
	offer_area.add_child(card)


func _on_card_chosen(_data: Dictionary, idx: int):
	skip_btn.hide()
	status_label.text = "Adding card..."

	var picked = _offer_cards[idx]

	var card_ui = preload("res://scenes/Card.tscn").instantiate()
	card_ui.display(picked)
	add_child(card_ui)

	var sx = offer_area.position.x + 170 * idx + 50
	card_ui.position = Vector2(sx, 60)
	card_ui.scale = Vector2(0.6, 0.6)

	var tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(card_ui, "position", Vector2(300, 280), 0.5)
	tw.parallel().tween_property(card_ui, "scale", Vector2(0.5, 0.5), 0.5)
	await tw.finished

	card_ui.queue_free()
	_deck_data.append(picked)
	_clear_ui()
	done.emit(_deck_data)


func _on_skip():
	_clear_ui()
	done.emit(_deck_data)


func _clear_ui():
	for c in offer_area.get_children(): c.queue_free()
	skip_btn.hide()
	status_label.text = ""


func _wait(s: float):
	await get_tree().create_timer(s).timeout
