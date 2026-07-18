extends Node
## Oyun durumu yöneticisi. Autoload olarak işaretlenmeli.

var player_deck: Array = []  # Array[CardData]
var total_battles: int = 0
var wins: int = 0

signal deck_changed(deck)
signal game_over(battles, wins_count)


func start_new_run():
	player_deck.clear()
	total_battles = 0
	wins = 0

	for _i in range(3):
		player_deck.append(CardGenerator.generate_card())

	deck_changed.emit(player_deck)


func add_card(card):
	player_deck.append(card)
	deck_changed.emit(player_deck)


func remove_card(index: int):
	if index < 0 or index >= player_deck.size():
		return null
	var removed = player_deck[index]
	player_deck.remove_at(index)
	deck_changed.emit(player_deck)

	if player_deck.is_empty():
		game_over.emit(total_battles, wins)

	return removed


func record_battle(won: bool):
	total_battles += 1
	if won:
		wins += 1


func get_deck_power() -> int:
	var total := 0
	for c in player_deck:
		total += CardGenerator.card_power(c)
	return total


func get_winrate() -> float:
	if total_battles == 0:
		return 0.0
	return float(wins) / float(total_battles) * 100.0
