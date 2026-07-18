extends Node

const NAMES = [
	"Kael", "Lyra", "Borin", "Sera", "Dorn", "Faye", "Grimm", "Naya",
	"Torvin", "Elara", "Zeph", "Mira", "Harkun", "Vessa", "Rook", "Ivy",
	"Fen", "Larke", "Orin", "Tessa", "Brom", "Sylas", "Dagny", "Riven",
	"Korvus", "Astra", "Jorak", "Niamh", "Theln", "Ziva",
]

const SKILLS = {
	"unity": 10, "godot": 8, "unreal engine": 5,
	"pygame": 6, "gamemaker": 7, "roblox": 2,
	"photoshop": 9, "aseprite": 8, "gimp": 4,
	"blender": 9, "3d animation": 5, "2d animation": 6,
	"fl studio": 7, "lmms": 3, "midi keyboard": 4, "guitar": 3,
}

const GAME_JAM_MAX = 10
const SKILL_MIN = 25
const SKILL_MAX = 100


static func _pick_weighted(items: Dictionary, count: int) -> Array:
	var pool = []
	for key in items:
		for _i in range(items[key]):
			pool.append(key)
	pool.shuffle()
	var selected = []
	var seen = {}
	for item in pool:
		if item in seen:
			continue
		seen[item] = true
		selected.append(item)
		if selected.size() >= count:
			break
	return selected


static func _weighted_rand(max_val: float) -> int:
	return 1 + int((max_val - 1.0) * pow(randf(), 2.0))


static func _skill_level() -> int:
	return SKILL_MIN + int((SKILL_MAX - SKILL_MIN) * pow(randf(), 0.7))


static func generate_card() -> Dictionary:
	var jam = _weighted_rand(GAME_JAM_MAX)
	var skill_count = randi_range(1, 3)
	var picked = _pick_weighted(SKILLS, skill_count)

	var skills = []
	for s in picked:
		skills.append({ "name": s, "level": _skill_level() })

	return {
		"name": NAMES[randi() % NAMES.size()],
		"skills": skills,
		"game_jam": jam,
	}


static func compute_battle_stats(card: Dictionary) -> Dictionary:
	var levels = []
	for s in card["skills"]:
		levels.append(s["level"])

	var max_skill = levels.max()
	var total = 0
	for lv in levels:
		total += lv
	var count = levels.size()

	var hp = int(max_skill * 2.0 + float(total - max_skill) * 0.6)
	var atk = max_skill
	var def_val = (total - max_skill) / max(1, count - 1) if count > 1 else max_skill / 3

	return {
		"card": card,
		"name": card["name"],
		"hp": hp,
		"max_hp": hp,
		"attack": atk,
		"defense": def_val,
	}


static func card_power(card: Dictionary) -> int:
	var levels = []
	for s in card["skills"]:
		levels.append(s["level"])

	var max_skill = levels.max()
	var total = 0
	for lv in levels:
		total += lv
	var avg = float(total) / float(levels.size())
	return int(float(max_skill) * 1.5 + avg * 1.0 + float(levels.size()) * 5.0)


static func generate_enemy_deck(target_power: int, target_count: int) -> Array:
	if target_power < 10:
		target_power = 100

	target_power = int(float(target_power) * randf_range(1.05, 1.20))
	var power_per_card = float(target_power) / float(max(1, target_count))

	var pool = NAMES.duplicate()
	pool.shuffle()
	var picked_names = pool.slice(0, min(target_count, pool.size()))

	var cards = []
	for name in picked_names:
		var skill_count = randi_range(1, 2)
		var skill_names = _pick_weighted(SKILLS, skill_count)

		var raw_l = (power_per_card - float(skill_count) * 5.0) / 2.5
		var base_l = clampi(int(raw_l), SKILL_MIN, SKILL_MAX)

		var skills = []
		for sn in skill_names:
			var lv = clampi(base_l + randi_range(-10, 10), SKILL_MIN, SKILL_MAX)
			skills.append({ "name": sn, "level": lv })

		cards.append({
			"name": name,
			"skills": skills,
			"game_jam": _weighted_rand(GAME_JAM_MAX),
		})

	var total = 0
	for c in cards:
		total += card_power(c)
	if total > 0:
		var ratio = float(target_power) / float(total)
		for c in cards:
			for s in c["skills"]:
				s["level"] = clampi(int(float(s["level"]) * ratio), SKILL_MIN, SKILL_MAX)

	return cards
