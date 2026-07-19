extends Control

signal fight_requested(player_cards: Array)

@onready var fight_btn = $FightBtn
@onready var new_run_btn = $NewRunBtn
@onready var status_label = $StatusLabel
@onready var eval_btn = $EvalBtn

var deck: Node
var _deck_data: Array = []


func _ready():
	var d = preload("res://scenes/Deck.tscn").instantiate()
	d.position = Vector2(0, 35)
	d.card_offset_x = 108
	add_child(d)
	deck = d

	fight_btn.pressed.connect(_on_fight)
	new_run_btn.pressed.connect(_start_new_run)
	eval_btn.pressed.connect(_on_evaluate)
	_start_new_run()


func _start_new_run():
	_deck_data.clear()
	for i in range(3):
		_deck_data.append(CardGenerator.generate_card())
	deck.cards = _deck_data.duplicate()
	_update_status()


func _update_status():
	status_label.text = "Cards: %d" % _deck_data.size()


func _on_fight():
	if _deck_data.is_empty(): return
	fight_requested.emit(_deck_data)


func on_rps_ended(new_deck: Array):
	_deck_data = new_deck
	deck.cards = _deck_data.duplicate()
	_update_status()


func _on_evaluate():
	if _deck_data.is_empty():
		status_label.text = "No cards to evaluate!"
		return
	var total_levels = 0
	var count = 0
	var all_skills = {}
	var max_card = null
	var max_power = 0
	for c in _deck_data:
		for s in c["skills"]:
			total_levels += s["level"]
			count += 1
			all_skills[s["name"]] = true
		var pwr = CardGenerator.card_power(c)
		if pwr > max_power:
			max_power = pwr
			max_card = c
	var avg = float(total_levels) / maxi(1, count)
	var variety = all_skills.keys().size()
	var score = int(avg * 5.0 + variety * 3.0 + _deck_data.size() * 10.0)
	var best_name = max_card.get("name", "?") if max_card else "?"
	status_label.text = "Score: %d | Avg: %.1f | Skills: %d | Best: %s | Cards: %d" % [score, avg, variety, best_name, _deck_data.size()]
