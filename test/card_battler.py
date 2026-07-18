#!/usr/bin/env python3
"""
Card Battler — collect cards, battle opponents, build the ultimate deck.
Turn-based combat with scaling enemies.
"""

import sys
import random
from card_generator import generate_card, _card_width, print_card as _print_raw
from battle import run_battle


def _deck_width(deck, minimum=38):
    w = minimum
    for c in deck:
        cw = _card_width(c)
        if cw > w:
            w = cw
    return w


def _show_deck(deck):
    """Print all cards in the deck."""
    print()
    if not deck:
        print("  📭 Your deck is empty.")
        return
    w = _deck_width(deck)
    for i, card in enumerate(deck, start=1):
        _print_raw(card, w, number=i)


def main():
    deck = [generate_card() for _ in range(3)]
    total_battles = 0
    wins = 0

    print()
    print("╔══════════════════════════════════════════╗")
    print("║      ⚔️  CARD BATTLER  🃏                ║")
    print("╠══════════════════════════════════════════╣")
    print("║  Battle opponents, collect cards!        ║")
    print("║  Win  → take one of their cards          ║")
    print("║  Lose → give one of your cards away      ║")
    print("║  0 cards → game over                     ║")
    print("╚══════════════════════════════════════════╝")

    _show_deck(deck)

    while True:
        print()
        cmd = input("  [f]ight  [s]how deck  [q]uit > ").strip().lower()

        if cmd == "q":
            print()
            print(f"  🃏 Run stats: {total_battles} battle(s), {wins} win(s)")
            print(f"  Final deck: {len(deck)} card(s)")
            print("  See you!\n")
            break

        if cmd == "s":
            _show_deck(deck)
            continue

        if cmd != "f":
            print("  ❓ Type f, s, or q.")
            continue

        if not deck:
            print("  ❌ Your deck is empty — game over! Start a new run.")
            again = input("  New run? (y/n): ").strip().lower()
            if again == "y":
                deck = [generate_card() for _ in range(3)]
                total_battles = 0
                wins = 0
                _show_deck(deck)
            continue

        # ── Start battle ─────────────────────────────
        result = run_battle(deck)
        total_battles += 1

        if result["result"] == "win":
            wins += 1
            # Take a random card from the enemy deck
            if result["enemy_deck"]:
                prize = random.choice(result["enemy_deck"])
                deck.append(prize)
                print(f"  🏆  You gained: {prize['name']}!")
                w = max(38, _card_width(prize))
                _print_raw(prize, w, number=len(deck))
            else:
                print("  (Enemy had no cards to take!)")

        else:  # lose
            if deck:
                print("  You must give away one of your cards.")
                print("  Choose a card to relinquish:")
                for i, c in enumerate(deck, start=1):
                    skill_summary = ", ".join(f"{s['name']} ({s['level']})" for s in c["skills"])
                    print(f"    [{i}] {c['name']}  (Jam #{c['game_jam']})  {skill_summary}")
                while True:
                    pick = input("  Give away # (Enter = first card): ").strip()
                    if pick == "":
                        idx = 0
                    else:
                        try:
                            idx = int(pick) - 1
                        except ValueError:
                            print("  Enter a number.")
                            continue
                    if 0 <= idx < len(deck):
                        lost = deck.pop(idx)
                        print(f"  ❌ Lost: {lost['name']}")
                        break
                    else:
                        print(f"  Pick 1-{len(deck)}.")
            else:
                print("  (Nothing to lose!)")

        # ── Post-battle check ───────────────────────
        _show_deck(deck)

        if not deck:
            print()
            print("  ╔════════════════════════════════════╗")
            print("  ║        💀  GAME OVER  💀           ║")
            print("  ╠════════════════════════════════════╣")
            print(f"  ║  Battles: {total_battles:<3}                       ║")
            print(f"  ║  Wins:    {wins:<3}                       ║")
            print(f"  ║  Winrate: {wins/max(1,total_battles)*100:.0f}%                        ║")
            print("  ╚════════════════════════════════════╝")
            print()
            again = input("  New run? (y/n): ").strip().lower()
            if again == "y":
                deck = [generate_card() for _ in range(3)]
                total_battles = 0
                wins = 0
                print()
                print("  🆕  Fresh start — 3 new cards!")
                _show_deck(deck)
            else:
                print("  See you!\n")
                break


if __name__ == "__main__":
    main()
