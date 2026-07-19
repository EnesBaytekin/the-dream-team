extends Control

var hub: Node
var rps: Node
var trade: Node
var _deck_cache: Array = []


func _ready():
	var hs = preload("res://scenes/Hub.tscn")
	hub = hs.instantiate()
	add_child(hub)

	var rs = preload("res://scenes/RPSGame.tscn")
	rps = rs.instantiate()
	add_child(rps)

	var ts = preload("res://scenes/TradeScreen.tscn")
	trade = ts.instantiate()
	add_child(trade)

	hub.fight_requested.connect(_on_fight)
	rps.game_ended.connect(_on_rps_ended)
	trade.done.connect(_on_trade_done)

	rps.hide()
	trade.hide()


func _on_fight(player_cards: Array):
	_deck_cache = player_cards.duplicate()
	hub.hide()
	rps.show()


func _on_rps_ended(result: Dictionary):
	rps.hide()
	var won = result["result"] == "win"
	trade.show()
	trade.show_trade(won, _deck_cache)


func _on_trade_done(deck: Array):
	_deck_cache = deck
	trade.hide()
	hub.show()
	hub.on_rps_ended(_deck_cache)
