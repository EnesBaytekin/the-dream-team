extends Control

signal battle_ended(result: Dictionary)

const CARD_NORMAL = 0
const CARD_ATTACKING = 1
const CARD_TARGETABLE = 2
const CARD_DEAD = 3

var _player_hand: Node
var _enemy_hand: Node
var _status_label: Label
var _hub_button: Button
var _turn_label: Label

var _player_team: Array = []
var _enemy_team: Array = []
var _enemy_deck: Array = []
var _round: int = 0

var _selected_target_index: int = -1
var _target_selection_active: bool = false


func _ready():
	_player_hand = $PlayerHand
	_enemy_hand = $EnemyHand
	_status_label = $StatusLabel
	_hub_button = $HubButton
	_turn_label = $TurnLabel
	_turn_label.add_theme_font_size_override("font_size", 14)
	_status_label.add_theme_font_size_override("font_size", 10)


func start_battle(player_deck: Array):
	_setup_battle(player_deck)
	_run_battle_loop()


func _setup_battle(player_deck: Array):
	var total_power = 0
	for c in player_deck:
		total_power += CardGenerator.card_power(c)

	_enemy_deck = CardGenerator.generate_enemy_deck(total_power, player_deck.size())

	_player_team = _build_team(player_deck)
	_enemy_team = _build_team(_enemy_deck)
	_round = 0
	_refresh_display()


func _build_team(deck: Array) -> Array:
	var team = []
	for c in deck:
		var stats = CardGenerator.compute_battle_stats(c)
		stats["max_hp"] = stats["hp"]
		team.append(stats)
	return team


func _alive(team: Array) -> Array:
	var alive = []
	for t in team:
		if t.get("hp", 0) > 0:
			alive.append(t)
	return alive


func _alive_count(team: Array) -> int:
	return _alive(team).size()


# ─── Battle Loop ───────────────────────────────────────────────────

func _run_battle_loop():
	_hub_button.hide()
	_set_status("Battle begins!")
	await _pause(0.5)

	while true:
		var alive_player = _alive(_player_team)
		var alive_enemy = _alive(_enemy_team)
		if alive_player.is_empty() or alive_enemy.is_empty():
			break

		_round += 1
		_turn_label.text = "ROUND %d" % _round
		_set_status("")
		await _pause(0.4)

		# ── Player Phase ──
		_turn_label.text = "YOUR TURN"
		_turn_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
		await _pause(0.3)

		for pi in range(_player_team.size()):
			if _player_team[pi]["hp"] <= 0:
				continue
			alive_enemy = _alive(_enemy_team)
			if alive_enemy.is_empty():
				break

			await _player_attack_phase(pi, alive_enemy)

		# ── Enemy Phase ──
		alive_player = _alive(_player_team)
		if alive_player.is_empty():
			break

		_turn_label.text = "ENEMY TURN"
		_turn_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
		await _pause(0.4)

		for ei in range(_enemy_team.size()):
			if _enemy_team[ei]["hp"] <= 0:
				continue
			alive_player = _alive(_player_team)
			if alive_player.is_empty():
				break

			await _enemy_attack_phase(ei, alive_player)

	# ── Outcome ──
	var final_player = _alive(_player_team)
	var final_enemy = _alive(_enemy_team)

	var won = false
	if not final_player.is_empty() and final_enemy.is_empty():
		won = true
		_turn_label.text = "VICTORY!"
		_turn_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0))
		_set_status("You won!")
	elif not final_enemy.is_empty() and final_player.is_empty():
		_turn_label.text = "DEFEATED"
		_turn_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
		_set_status("You lost!")
	else:
		_turn_label.text = "DRAW"
		_set_status("It's a draw!")

	await _pause(0.8)
	_hub_button.show()
	battle_ended.emit({
		"result": "win" if won else "lose",
		"enemy_deck": _enemy_deck,
	})


# ─── Player Attack Phase ───────────────────────────────────────────

func _player_attack_phase(player_idx: int, alive_enemy: Array):
	var attacker = _player_team[player_idx]

	# Highlight current attacking card
	_player_hand.reset_all_states()
	_player_hand.set_card_state(player_idx, CARD_ATTACKING)
	_enemy_hand.reset_all_states()

	# Make alive enemies targetable
	for ei in range(_enemy_team.size()):
		if _enemy_team[ei]["hp"] > 0:
			_enemy_hand.set_card_state(ei, CARD_TARGETABLE)

	_set_status("%s — Pick a target!" % attacker["name"])
	await _pause(0.2)

	# Wait for target selection
	var target_idx = await _await_target_selection()
	if target_idx < 0 or target_idx >= _enemy_team.size():
		return

	var defender = _enemy_team[target_idx]

	# Execute attack
	_execute_attack(attacker, defender)

	# Flash the defender
	var def_card = _enemy_hand.get_card_display(target_idx)
	if def_card:
		def_card.self_modulate = Color(1.0, 0.3, 0.3)
		await _pause(0.15)
		def_card.self_modulate = Color.WHITE

	# Message
	if defender["hp"] <= 0:
		_set_status("%s defeated %s!" % [attacker["name"], defender["name"]])
		_enemy_hand.set_card_state(target_idx, CARD_DEAD)
	else:
		_set_status("%s hits %s!" % [attacker["name"], defender["name"]])

	# Reset all highlights after attack
	_player_hand.reset_all_states()
	_enemy_hand.reset_all_states()

	# Update HP display
	_refresh_display()
	await _pause(0.3)


# ─── Enemy Attack Phase ────────────────────────────────────────────

func _enemy_attack_phase(enemy_idx: int, alive_player: Array):
	var attacker = _enemy_team[enemy_idx]

	# Highlight current enemy attacker
	_enemy_hand.reset_all_states()
	_enemy_hand.set_card_state(enemy_idx, CARD_ATTACKING)

	# Pick target
	var target_dict = _cpu_target(alive_player)
	if target_dict.is_empty():
		return

	# Find target index
	var target_idx = -1
	for i in range(_player_team.size()):
		if _player_team[i] == target_dict:
			target_idx = i
			break
	if target_idx < 0:
		return

	var defender = _player_team[target_idx]

	_set_status("Enemy %s attacks!" % attacker["name"])
	await _pause(0.3)

	# Execute attack
	_execute_attack(attacker, defender)

	# Flash the defender
	var def_card = _player_hand.get_card_display(target_idx)
	if def_card:
		def_card.self_modulate = Color(1.0, 0.3, 0.3)
		await _pause(0.15)
		def_card.self_modulate = Color.WHITE

	# Message
	if defender["hp"] <= 0:
		_set_status("%s defeated %s!" % [attacker["name"], defender["name"]])
		_player_hand.set_card_state(target_idx, CARD_DEAD)
	else:
		_set_status("Enemy %s hits %s!" % [attacker["name"], defender["name"]])

	# Reset
	_enemy_hand.reset_all_states()
	_refresh_display()
	await _pause(0.4)


# ─── Combat ────────────────────────────────────────────────────────

func _execute_attack(attacker: Dictionary, defender: Dictionary):
	var base = int(float(attacker["attack"]) * 0.8 - float(defender["defense"]) * 0.25)
	var variance = randi_range(-5, 10)
	var dmg = maxi(3, base + variance)
	defender["hp"] = maxi(0, defender["hp"] - dmg)


func _cpu_target(alive_player: Array) -> Dictionary:
	if alive_player.is_empty():
		return {}
	if randf() < 0.65:
		var lowest = alive_player[0]
		for t in alive_player:
			if t["hp"] < lowest["hp"]:
				lowest = t
		return lowest
	return alive_player[randi() % alive_player.size()]


# ─── Target Selection ──────────────────────────────────────────────

func _await_target_selection() -> int:
	_selected_target_index = -1
	_target_selection_active = true

	_enemy_hand.card_clicked.connect(_on_target_selected, CONNECT_ONE_SHOT)

	while _selected_target_index < 0:
		await get_tree().process_frame

	_target_selection_active = false
	return _selected_target_index


func _on_target_selected(index: int, _card_data: Dictionary):
	if _target_selection_active:
		_selected_target_index = index


# ─── Display ───────────────────────────────────────────────────────

func _refresh_display():
	_player_hand.cards = _player_team.map(func(s): return s.get("card", {}))
	_player_hand.battle_stats = _player_team
	_player_hand.show_battle_stats = true

	_enemy_hand.cards = _enemy_team.map(func(s): return s.get("card", {}))
	_enemy_hand.battle_stats = _enemy_team
	_enemy_hand.show_battle_stats = true

	# Restore state for dead cards
	for i in range(_player_team.size()):
		if _player_team[i]["hp"] <= 0:
			_player_hand.set_card_state(i, CARD_DEAD)
	for i in range(_enemy_team.size()):
		if _enemy_team[i]["hp"] <= 0:
			_enemy_hand.set_card_state(i, CARD_DEAD)


func _set_status(text: String):
	if _status_label:
		_status_label.text = text


func _pause(seconds: float):
	await get_tree().create_timer(seconds).timeout
