extends Control

var hub_ui: Node
var battle_scene: PackedScene = preload("res://scenes/Battle.tscn")


func _ready():
	# All Hub UI under one container so we can hide/show it
	hub_ui = Control.new()
	hub_ui.name = "HubUI"
	add_child(hub_ui)

	var title = Label.new()
	title.name = "Title"
	title.text = "CARD BATTLER"
	title.add_theme_font_size_override("font_size", 18)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 10)
	title.size = Vector2(960, 30)
	hub_ui.add_child(title)

	var deck_hand = preload("res://scenes/CardHand.tscn").instantiate()
	deck_hand.name = "DeckHand"
	deck_hand.position = Vector2(0, 50)
	deck_hand.size = Vector2(960, 280)
	deck_hand.show_numbers = true
	hub_ui.add_child(deck_hand)

	var stats_label = Label.new()
	stats_label.name = "StatsLabel"
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.position = Vector2(0, 380)
	stats_label.size = Vector2(960, 20)
	stats_label.add_theme_font_size_override("font_size", 10)
	hub_ui.add_child(stats_label)

	var fight_button = Button.new()
	fight_button.name = "FightButton"
	fight_button.text = "FIGHT"
	fight_button.position = Vector2(350, 420)
	fight_button.size = Vector2(140, 40)
	fight_button.add_theme_font_size_override("font_size", 14)
	fight_button.pressed.connect(_on_fight_pressed)
	hub_ui.add_child(fight_button)

	var quit_button = Button.new()
	quit_button.name = "QuitButton"
	quit_button.text = "Quit"
	quit_button.position = Vector2(510, 420)
	quit_button.size = Vector2(100, 40)
	quit_button.pressed.connect(_on_quit_pressed)
	hub_ui.add_child(quit_button)

	_refresh_deck()
	GameManager.deck_changed.connect(_on_deck_changed)
	GameManager.game_over.connect(_on_game_over)


func _refresh_deck():
	var deck_hand = hub_ui.get_node_or_null("DeckHand")
	var stats_label = hub_ui.get_node_or_null("StatsLabel")
	if not deck_hand or not stats_label:
		return

	deck_hand.cards = GameManager.player_deck
	deck_hand.show_numbers = true
	deck_hand.show_battle_stats = false

	var p = GameManager.get_deck_power()
	stats_label.text = "Deck: %d  |  Power: %d  |  Battles: %d (W: %d)" % [
		GameManager.player_deck.size(), p,
		GameManager.total_battles, GameManager.wins,
	]


func _on_deck_changed(_deck):
	_refresh_deck()


func _on_game_over(battles, wins_count):
	get_tree().change_scene_to_file("res://scenes/GameOver.tscn")


func _on_fight_pressed():
	if GameManager.player_deck.is_empty():
		return

	# Hide hub UI, show battle
	hub_ui.hide()
	var battle = battle_scene.instantiate()
	add_child(battle)
	battle.start_battle(GameManager.player_deck)
	battle.battle_ended.connect(_on_battle_ended.bind(battle))


func _on_battle_ended(result: Dictionary, battle):
	var won = result.get("result") == "win"
	var enemy_deck: Array = result.get("enemy_deck", [])

	GameManager.record_battle(won)

	if won:
		if not enemy_deck.is_empty():
			var prize: Dictionary = enemy_deck[randi() % enemy_deck.size()]
			GameManager.add_card(prize)
	else:
		_show_discard_prompt()

	battle.queue_free()
	hub_ui.show()
	_refresh_deck()


func _show_discard_prompt():
	if GameManager.player_deck.is_empty():
		return

	var lost = GameManager.remove_card(0)
	if lost:
		var stats_label = hub_ui.get_node_or_null("StatsLabel")
		if stats_label:
			stats_label.text = "Lost: %s" % lost.get("name", "??")


func _on_quit_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
