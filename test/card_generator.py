#!/usr/bin/env python3
"""
Card Generator — Creates random character cards.
"""

import random
import sys

# ═══════════════════════════════════════════════════════════════════════
#  TRAIT LISTS — edit, add, or remove as you like
# ═══════════════════════════════════════════════════════════════════════

NAMES = [
    "Kael", "Lyra", "Borin", "Sera", "Dorn", "Faye", "Grimm", "Naya",
    "Torvin", "Elara", "Zeph", "Mira", "Harkun", "Vessa", "Rook", "Ivy",
    "Fen", "Larke", "Orin", "Tessa", "Brom", "Sylas", "Dagny", "Riven",
    "Korvus", "Astra", "Jorak", "Niamh", "Theln", "Ziva",
]

SKILLS = {
    "unity"            : 10,
    "godot"            : 8,
    "unreal engine"    : 5,
    "pygame"           : 6,
    "gamemaker"        : 7,
    "roblox"           : 2,
    "photoshop"        : 9,
    "aseprite"         : 8,
    "gimp"             : 4,
    "blender"          : 9,
    "3d animation"     : 5,
    "2d animation"     : 6,
    "fl studio"        : 7,
    "lmms"             : 3,
    "midi keyboard"    : 4,
    "guitar"           : 3,
}

GAME_JAM_MAX = 10
SKILL_MIN = 25
SKILL_MAX = 100


# ─── Helpers ─────────────────────────────────────────────────────────

def _check_empty(lst, name):
    if not lst:
        print(f"ERROR: '{name}' list is empty! Add some entries first.")
        sys.exit(1)


def _pick_weighted(items, count=1):
    """Pick `count` unique items from a dict {item: weight}. Higher weight = more likely."""
    pool = []
    for item, weight in items.items():
        pool.extend([item] * weight)
    selected = set()
    random.shuffle(pool)
    for item in pool:
        selected.add(item)
        if len(selected) >= count:
            break
    return list(selected)


def _weighted_rand(max_val):
    """Return 1..max_val, biased toward smaller numbers (quadratic falloff)."""
    return 1 + int((max_val - 1) * (random.random() ** 2))


def _skill_level():
    """Generate a skill level (SKILL_MIN..SKILL_MAX), biased toward higher values."""
    return SKILL_MIN + int((SKILL_MAX - SKILL_MIN) * (random.random() ** 0.7))


# ─── Card Generation ────────────────────────────────────────────────

def generate_card():
    """Generate one random card and return as dict."""
    _check_empty(NAMES, "NAMES")
    _check_empty(SKILLS, "SKILLS")

    jam_number = _weighted_rand(GAME_JAM_MAX)
    skill_count = random.randint(1, 3)

    raw_skills = _pick_weighted(SKILLS, skill_count)
    skills = [
        {"name": s, "level": _skill_level()}
        for s in raw_skills
    ]

    return {
        "name": random.choice(NAMES),
        "skills": skills,
        "game_jam": jam_number,
    }


# ─── Battle Utilities ───────────────────────────────────────────────

def compute_battle_stats(card):
    """Derive HP, attack, and defense from a card's skill levels."""
    levels = [s["level"] for s in card["skills"]]
    max_skill = max(levels)
    total = sum(levels)
    count = len(levels)

    # HP: primary skill counts most, extra skills add a smaller bonus
    hp = int(max_skill * 2.0 + (total - max_skill) * 0.6)
    attack = max_skill
    defense = (total - max_skill) // max(1, count - 1) if count > 1 else max_skill // 3

    return {"hp": hp, "max_hp": hp, "attack": attack, "defense": defense}


def card_power(card):
    """Return a numeric power rating for a card."""
    levels = [s["level"] for s in card["skills"]]
    max_skill = max(levels)
    avg_skill = sum(levels) / len(levels)
    return int(max_skill * 1.5 + avg_skill * 1.0 + len(levels) * 5)


def generate_enemy_deck(target_power, target_count):
    """Create an enemy deck whose total power is around 95% of target_power."""
    if target_power < 10:
        target_power = 100  # fallback for very weak decks

    # Scale to be slightly stronger — player's strategic targeting is a big advantage
    target_power = int(target_power * random.uniform(1.05, 1.20))
    power_per_card = target_power / max(1, target_count)

    names = random.sample(NAMES, min(target_count, len(NAMES)))

    enemy_cards = []
    for i, name in enumerate(names):
        skill_count = random.randint(1, 2)  # enemies tend to have fewer skills
        skill_names = _pick_weighted(SKILLS, skill_count)

        # Estimate skill levels to hit target power
        # power ≈ L * 2.5 + count * 5  → L ≈ (power_per_card - count*5) / 2.5
        raw_l = (power_per_card - skill_count * 5) / 2.5
        base_l = max(SKILL_MIN, min(SKILL_MAX, int(raw_l)))

        levels = []
        for _ in range(skill_count):
            lv = base_l + random.randint(-10, 10)
            lv = max(SKILL_MIN, min(SKILL_MAX, lv))
            levels.append(lv)

        enemy_cards.append({
            "name": name,
            "skills": [{"name": sn, "level": lv} for sn, lv in zip(skill_names, levels)],
            "game_jam": _weighted_rand(GAME_JAM_MAX),
        })

    # Scale as a group to hit the target total power
    total = sum(card_power(c) for c in enemy_cards)
    if total > 0:
        ratio = target_power / total
        for card in enemy_cards:
            for skill in card["skills"]:
                adj = max(SKILL_MIN, min(SKILL_MAX, int(skill["level"] * ratio)))
                skill["level"] = adj

    return enemy_cards


# ─── Display ────────────────────────────────────────────────────────

def print_card(card, width, number=None):
    """Print one card as a closed rectangle, padded to `width`."""
    lines = []
    lines.append(card["name"])
    lines.append(f"  Game Jam #{card['game_jam']}")
    lines.append("")

    max_skill_len = max(len(s["name"]) for s in card["skills"]) if card["skills"] else 0
    for s in card["skills"]:
        filled = s["level"] // 20
        bar = "█" * filled + "░" * (5 - filled)
        lines.append(f"    • {s['name']:<{max_skill_len}}  {bar}  {s['level']:>3}")

    inner = width - 4

    top = "┌" + "─" * (width - 2) + "┐"
    bottom = "└" + "─" * (width - 2) + "┘"

    number_label = f"  #{number}" if number else ""
    title_line = f"│ {lines[0]}{number_label}" + " " * (inner - len(lines[0]) - len(number_label)) + " │"

    print()
    print(top)
    print(title_line)
    divider = "├" + "─" * (width - 2) + "┤"
    print(divider)
    for l in lines[1:]:
        line_text = l.ljust(inner)
        print(f"│ {line_text} │")
    print(bottom)


def _card_width(card):
    """Return the minimum width needed for this card."""
    items = [card["name"]]
    items.append(f"  Game Jam #{card['game_jam']}")
    for s in card["skills"]:
        items.append(f"    • {s['name']}  {'█' * 5}  {s['level']:>3}")
    return max(len(l) for l in items) + 6


# ─── Main (standalone) ─────────────────────────────────────────────

def main():
    print("╔══════════════════════════════════════════╗")
    print("║       🃏  CARD GENERATOR  🃏             ║")
    print("╚══════════════════════════════════════════╝")
    print("  Press Enter for a new card, or type q to quit.")
    print()

    card_count = 0
    while True:
        cmd = input().strip().lower()
        if cmd == "q":
            print()
            print(f"  Total cards shown: {card_count}")
            print("  See you! 🃏")
            break
        card_count += 1
        card = generate_card()
        width = max(36, _card_width(card))
        print_card(card, width, number=card_count)


if __name__ == "__main__":
    main()
