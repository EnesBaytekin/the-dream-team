#!/usr/bin/env python3
"""
Rock-Paper-Scissors card collector game.
Win → get a random card. Lose → discard one of your cards.
Your deck grows as you take risks.
"""

import sys
import random
from card_generator import generate_card, _card_width, print_card as _print_raw


# ─── RPS choices ─────────────────────────────────────────────────────

CHOICES = ["rock", "paper", "scissors"]

BEATS = {
    "rock": "scissors",
    "scissors": "paper",
    "paper": "rock",
}


def _rps_outcome(player, cpu):
    if player == cpu:
        return "draw"
    if BEATS[player] == cpu:
        return "win"
    return "lose"


# ─── Display helpers ─────────────────────────────────────────────────

def _deck_width(deck, minimum=38):
    """Return the widest card width across the deck."""
    w = minimum
    for c in deck:
        cw = _card_width(c)
        if cw > w:
            w = cw
    return w


def _show_deck(deck, width):
    """Print all cards in the deck as full card boxes."""
    print()
    print(f"  ── Your Deck ({len(deck)} card{'s' if len(deck) != 1 else ''}) ──")
    print()
    if not deck:
        print("    (empty)")
    else:
        w = _deck_width(deck, width)
        for i, card in enumerate(deck, start=1):
            _print_raw(card, w, number=i)


# ─── Main game loop ──────────────────────────────────────────────────

def main():
    deck = [generate_card() for _ in range(3)]
    width = 38

    print()
    print("╔══════════════════════════════════════════╗")
    print("║   ✊ RPS CARD COLLECTOR  🃏              ║")
    print("╠══════════════════════════════════════════╣")
    print("║  Win  → you get a random card            ║")
    print("║  Lose → you discard one of your cards    ║")
    print("║  Draw → nothing happens                  ║")
    print("╚══════════════════════════════════════════╝")

    _show_deck(deck, width)

    while True:
        print()
        cmd = input("  [r/p/s or 1/2/3] [q]uit > ").strip().lower()

        if cmd == "q":
            print()
            print(f"  🃏 Final deck size: {len(deck)}")
            print("  See you!\n")
            break

        if cmd in ("r", "rock", "1"):
            player = "rock"
        elif cmd in ("p", "paper", "2"):
            player = "paper"
        elif cmd in ("s", "scissors", "3"):
            player = "scissors"
        else:
            print("  ❓ Type r, p, s, or q.")
            continue

        cpu = random.choice(CHOICES)
        outcome = _rps_outcome(player, cpu)

        print(f"\n  You: {player:<8}  vs  CPU: {cpu}")
        print()

        if outcome == "win":
            print("  🎉  YOU WIN!  🎉  New card earned!")
            new_card = generate_card()
            deck.append(new_card)
            w = max(width, _card_width(new_card))
            _print_raw(new_card, w, number=len(deck))

        elif outcome == "lose":
            print("  💀  YOU LOSE!  💀  Drop a card.")
            if deck:
                print("  Which card to discard? (Enter = first card)")
                for i, c in enumerate(deck, start=1):
                    skill_list = ", ".join(f"{s['name']} ({s['level']})" for s in c["skills"])
                    print(f"    [{i}] {c['name']}  (Jam #{c['game_jam']})  {skill_list}")
                while True:
                    pick = input("  Discard #: ").strip()
                    if pick == "":
                        idx = 0
                    else:
                        try:
                            idx = int(pick) - 1
                        except ValueError:
                            print("  Enter a number, or press Enter for the first card.")
                            continue
                    if 0 <= idx < len(deck):
                        dropped = deck.pop(idx)
                        print(f"  ❌ Discarded: {dropped['name']}")
                        break
                    else:
                        print(f"  Number 1-{len(deck)} please.")
            else:
                print("  (Empty deck — nothing to lose!)")

        else:
            print("  🤝  DRAW  🤝  Nothing happens.")

        _show_deck(deck, width)


if __name__ == "__main__":
    main()
