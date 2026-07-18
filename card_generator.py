#!/usr/bin/env python3
"""
Card Generator — Creates random character cards.
User picks how many cards to generate, prints them to screen.
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
    # skill name       : rarity weight (higher = more common)
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

GAME_JAM_MAX = 10  # maximum game jam number — smaller numbers are more common
SKILL_MIN = 25     # skill level floor — nobody has a skill below this
SKILL_MAX = 100    # skill level ceiling


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
    """Generate a skill proficiency level (SKILL_MIN..SKILL_MAX).
    Biased toward higher values — people listed in a skill tend to be decent at it."""
    return SKILL_MIN + int((SKILL_MAX - SKILL_MIN) * (random.random() ** 0.7))


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


def print_card(card, width, number=None):
    """Print one card as a closed rectangle, padded to `width`."""
    # Gather text lines first
    lines = []
    lines.append(card["name"])
    lines.append(f"  Game Jam #{card['game_jam']}")
    lines.append("")

    # Figure out padding for skill names so bars line up
    max_skill_len = max(len(s["name"]) for s in card["skills"]) if card["skills"] else 0
    for s in card["skills"]:
        filled = s["level"] // 20
        bar = "█" * filled + "░" * (5 - filled)
        lines.append(f"    • {s['name']:<{max_skill_len}}  {bar}  {s['level']:>3}")

    inner = width - 4  # "│ " left + " │" right

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
    """Return the minimum width needed for this card's content."""
    items = [card["name"]]
    items.append(f"  Game Jam #{card['game_jam']}")
    for s in card["skills"]:
        items.append(f"    • {s['name']}  {'█' * 5}  {s['level']:>3}")
    return max(len(l) for l in items) + 6  # borders + padding


# ─── Main ────────────────────────────────────────────────────────────

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
