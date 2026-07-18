#!/usr/bin/env python3
"""
Battle engine — turn-based team combat.
"""

import random
from card_generator import (
    generate_enemy_deck,
    compute_battle_stats,
    card_power,
    print_card,
    _card_width,
)


def _damage(attacker_stats, defender_stats):
    """Calculate damage from attacker to defender."""
    base = int(attacker_stats["attack"] * 0.8 - defender_stats["defense"] * 0.25)
    variance = random.randint(-5, 10)
    return max(3, base + variance)


def _hp_bar(current, maximum, length=12):
    """Return a HP bar string like '██████░░░░ 85/120'."""
    ratio = current / maximum
    filled = int(ratio * length)
    bar = "█" * filled + "░" * (length - filled)
    return f"{bar} {current:>3}/{maximum:<3}"


def _alive(team):
    """Return cards that still have HP > 0."""
    return [c for c in team if c["hp"] > 0]


def _display_battle_state(player_team, enemy_team):
    """Print current status of both teams."""
    print()
    print("  ── Your Team ──────────────────────────────")
    for i, c in enumerate(player_team, start=1):
        if c["hp"] > 0:
            bar = _hp_bar(c["hp"], c["max_hp"])
            print(f"    [{i}] {c['name']:<8}  {bar}  ⚔{c['attack']:>3}  🛡{c['defense']:>3}")
        else:
            print(f"    [{i}] {c['name']:<8}  💀  DEFEATED")
    print()
    print("  ── Enemy Team ─────────────────────────────")
    for i, c in enumerate(enemy_team, start=1):
        if c["hp"] > 0:
            bar = _hp_bar(c["hp"], c["max_hp"])
            print(f"    [{i}] {c['name']:<8}  {bar}  ⚔{c['attack']:>3}  🛡{c['defense']:>3}")
        else:
            print(f"    [{i}] {c['name']:<8}  💀  DEFEATED")
    print()


def _cpu_target(player_team):
    """Pick target: usually lowest HP, sometimes random."""
    alive = [c for c in player_team if c["hp"] > 0]
    if not alive:
        return None
    if random.random() < 0.65:
        return min(alive, key=lambda c: c["hp"])
    return random.choice(alive)


def _pause():
    """Wait for Enter before continuing."""
    input("     [Enter] to continue...")


def run_battle(player_deck):
    """
    Run a full turn-based battle.

    Returns: {"result": "win"|"lose", "enemy_deck": [...]}
    """
    # ── Setup ────────────────────────────────────────
    player_total = sum(card_power(c) for c in player_deck)
    enemy_count = len(player_deck)
    enemy_deck = generate_enemy_deck(player_total, enemy_count)

    def _build_team(deck):
        return [
            {
                "name": c["name"],
                "skills": c["skills"],
                "game_jam": c["game_jam"],
                **compute_battle_stats(c),
            }
            for c in deck
        ]

    player_team = _build_team(player_deck)
    enemy_team = _build_team(enemy_deck)

    print()
    print("╔══════════════════════════════════════════╗")
    print("║            ⚔️  BATTLE  ⚔️                ║")
    print("╚══════════════════════════════════════════╝")

    _display_battle_state(player_team, enemy_team)
    _pause()

    # ── Battle loop ──────────────────────────────────
    round_num = 0
    while True:
        alive_player = _alive(player_team)
        alive_enemy = _alive(enemy_team)
        if not alive_player or not alive_enemy:
            break

        round_num += 1
        print(f"  ═══ ROUND {round_num} ═══")
        print()

        # ── Player turn ──────────────────────────────
        for p in player_team:
            if p["hp"] <= 0:
                continue
            alive_enemy = _alive(enemy_team)
            if not alive_enemy:
                break

            print(f"  🎮 {p['name']}'s turn!")
            print(f"     ⚔️  {p['attack']}  vs  🛡️  ?")

            # Auto-select if only one target
            if len(alive_enemy) == 1:
                target = alive_enemy[0]
                print(f"     → {target['name']} (the only standing enemy)")
            else:
                print("     Targets:")
                for i, e in enumerate(alive_enemy, start=1):
                    e_bar = _hp_bar(e["hp"], e["max_hp"])
                    print(f"       [{i}] {e['name']:<8}  {e_bar}")

                while True:
                    raw = input("     Target [1-{}]: ".format(len(alive_enemy))).strip()
                    if raw == "":
                        idx = 0
                    else:
                        try:
                            idx = int(raw) - 1
                        except ValueError:
                            print("     Enter a number.")
                            continue
                    if 0 <= idx < len(alive_enemy):
                        break
                    print(f"     Pick 1-{len(alive_enemy)}.")

                target = alive_enemy[idx]

            dmg = _damage(p, target)
            target["hp"] = max(0, target["hp"] - dmg)
            print(f"     💥 {p['name']} hits {target['name']} for {dmg} damage!")
            if target["hp"] <= 0:
                print(f"     ☠️  {target['name']} is defeated!")
            print()
            _display_battle_state(player_team, enemy_team)
            _pause()

        # ── Enemy turn ───────────────────────────────
        alive_player = _alive(player_team)
        if not alive_player:
            break

        for e in enemy_team:
            if e["hp"] <= 0:
                continue
            alive_player = _alive(player_team)
            if not alive_player:
                break

            target = _cpu_target(player_team)
            if not target:
                break

            dmg = _damage(e, target)
            target["hp"] = max(0, target["hp"] - dmg)
            print(f"  💀 Enemy {e['name']} hits {target['name']} for {dmg} damage!")
            if target["hp"] <= 0:
                print(f"     ☠️  {target['name']} is defeated!")
            print()
            _display_battle_state(player_team, enemy_team)
            _pause()

    # ── Outcome ──────────────────────────────────────
    alive_player = _alive(player_team)
    alive_enemy = _alive(enemy_team)

    print()
    if alive_player and not alive_enemy:
        print("  🎉  VICTORY!  🎉")
        print()
        return {"result": "win", "enemy_deck": enemy_deck}
    elif alive_enemy and not alive_player:
        print("  💀  DEFEAT!  💀")
        print()
        return {"result": "lose", "enemy_deck": enemy_deck}
    else:
        print("  💀  DRAW — both sides fall!  💀")
        print()
        return {"result": "lose", "enemy_deck": enemy_deck}
