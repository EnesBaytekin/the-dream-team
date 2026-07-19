extends Node

const NAMES := [
	"Kael", "Lyra", "Borin", "Sera", "Dorn", "Faye", "Grimm", "Naya",
	"Torvin", "Elara", "Zeph", "Mira", "Harkun", "Vessa", "Rook", "Ivy",
	"Fen", "Larke", "Orin", "Tessa", "Brom", "Sylas", "Dagny", "Riven",
	"Korvus", "Astra", "Jorak", "Niamh", "Theln", "Ziva",
]

const SKILLS := {
	"unity": 10, "godot": 8, "unreal engine": 5,
	"pygame": 6, "gamemaker": 7, "roblox": 2,
	"photoshop": 9, "aseprite": 8, "gimp": 4,
	"blender": 9, "3d animation": 5, "2d animation": 6,
	"fl studio": 7, "lmms": 3, "midi keyboard": 4, "guitar": 3,
}

const GAME_JAM_MAX := 10
const SKILL_MIN := 2
const SKILL_MAX := 10


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
	return SKILL_MIN + int((SKILL_MAX - SKILL_MIN) * pow(randf(), 0.6))


# Scale 2-10 level to 1-100 for battle calculations
static func _scale_for_battle(level: int) -> int:
	return clampi(int(float(level - SKILL_MIN) / float(SKILL_MAX - SKILL_MIN) * 95.0 + 5.0), 1, 100)


static func _card_battle_levels(card: Dictionary) -> Array:
	var scaled = []
	for s in card["skills"]:
		scaled.append(_scale_for_battle(s["level"]))
	return scaled


static func compute_battle_stats(card: Dictionary) -> Dictionary:
	var levels = _card_battle_levels(card)
	var max_skill = levels.max()
	var total = 0
	for lv in levels: total += lv
	var count = levels.size()
	var hp = int(max_skill * 2.0 + float(total - max_skill) * 0.6)
	var atk = max_skill
	var def_val = (total - max_skill) / max(1, count - 1) if count > 1 else max_skill / 3
	return {"hp": hp, "max_hp": hp, "attack": atk, "defense": def_val, "card": card, "name": card["name"]}


static func card_power(card: Dictionary) -> int:
	var levels = _card_battle_levels(card)
	var max_skill = levels.max()
	var total = 0
	for lv in levels: total += lv
	var avg = float(total) / float(levels.size())
	return int(float(max_skill) * 1.5 + avg * 1.0 + float(levels.size()) * 5.0)


static func generate_enemy_deck(target_power: int, target_count: int) -> Array:
	if target_power < 10: target_power = 100
	target_power = int(float(target_power) * randf_range(1.05, 1.20))
	var pool = NAMES.duplicate()
	pool.shuffle()
	var picked_names = pool.slice(0, min(target_count, pool.size()))
	var cards = []
	for name in picked_names:
		var skill_count = randi_range(1, 2)
		var skill_names = _pick_weighted(SKILLS, skill_count)
		var skills = []
		for sn in skill_names:
			var lv = randi_range(SKILL_MIN, SKILL_MAX)
			skills.append({"name": sn, "level": lv})
		cards.append({"name": name, "skills": skills, "game_jam": _weighted_rand(GAME_JAM_MAX)})
	var total = 0
	for c in cards: total += card_power(c)
	if total > 0:
		var ratio = float(target_power) / float(total)
		for c in cards:
			for s in c["skills"]: s["level"] = clampi(int(float(s["level"]) * ratio), SKILL_MIN, SKILL_MAX)
	return cards


static func generate_card() -> Dictionary:
	var jam = _weighted_rand(GAME_JAM_MAX)
	var skill_count = randi_range(1, 3)
	var picked = _pick_weighted(SKILLS, skill_count)

	var skills = []
	for s in picked:
		skills.append({"name": s, "level": _skill_level()})

	return {
		"name": NAMES[randi() % NAMES.size()],
		"skills": skills,
		"game_jam": jam,
	}


static func generate_bad_card() -> Dictionary:
	# Jam: higher numbers (less experienced)
	var jam = _weighted_rand(GAME_JAM_MAX)
	# Skill count: 1-2, biased toward 1
	var skill_count = 1 if randf() < 0.65 else 2
	var picked = _pick_weighted(SKILLS, skill_count)
	var skills = []
	for s in picked:
		# Level: 1-4, biased toward 1-2
		var lv = 1 + int(pow(randf(), 1.5) * 4.0)
		skills.append({"name": s, "level": clampi(lv, 1, 4)})
	return {
		"name": NAMES[randi() % NAMES.size()],
		"skills": skills,
		"game_jam": clampi(jam, 6, GAME_JAM_MAX),
	}


static func generate_good_card() -> Dictionary:
	# Jam: lower numbers (more experienced)
	var jam = _weighted_rand(GAME_JAM_MAX)
	# Skill count: 2-3, biased toward 3
	var skill_count = 3 if randf() < 0.6 else 2
	var picked = _pick_weighted(SKILLS, skill_count)
	var skills = []
	for s in picked:
		# Level: 6-10, biased toward higher
		var lv = 6 + int(pow(randf(), 0.6) * 5.0)
		skills.append({"name": s, "level": clampi(lv, 6, 10)})
	return {
		"name": NAMES[randi() % NAMES.size()],
		"skills": skills,
		"game_jam": clampi(jam, 1, 5),
	}
