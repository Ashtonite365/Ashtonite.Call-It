# Ashtonite.Call It

Unofficial community points betting minigame for the Orion Drift Spectator camera. Watch a live Driftball match and
bet points on what happens next.

> **Disclaimer:** This product is not affiliated with Another Axiom Inc. or its videogames Gorilla Tag and Orion Drift and is not endorsed or otherwise sponsored by Another Axiom. Portions of the materials contained herein are property of Another Axiom. ©2025 Another Axiom Inc.

**Current version: 1.0.6**

See [CHANGELOG.md](CHANGELOG.md).

## Install

1. [Download Ashtonite.Call It.luau](https://github.com/Ashtonite365/Ashtonite.Call-It/raw/main/Ashtonite.Call%20It.luau)

   Current version: **1.0.6**
2. Put that file in `Documents\Another-Axiom\A2\Cameras\Behaviors`
3. In Spectator, open Cameras (`F2`), **Reload All**, and pick **Ashtonite.Call It** from the camera list

The build tag next to the card title (`build: v1.0.6`) shows which build you have installed.

## How it works

You start with **200 points**. Pick a stake, then make a call on the match in the nearest running Driftball arena
(or the arena you picked). Points are just for fun: there's no real money involved.

| Call | Options | Pays |
| --- | --- | --- |
| Next goal | either team | x1.9 |
| Goal in the next 30 s? | Yes / No | Yes x2.5, No x1.5 |
| Next team to reach the ball | either team | x1.9 |

- One call at a time. A call locks in after 2 seconds, then resolves from live match data.
- "Next team to reach the ball" waits until nobody is near the ball, then the first team to get a head or hand within
  1.2 m of it wins (45 s limit). It's approximate, because the game has no touch event.
- A win streak adds a bonus to your winnings: +10% per win in a row, up to +50%.
- Cancelling a pending call gives back half the stake. Calls that can't be decided fairly (a goal during lock-in, a
  score reset, a server switch, the match stopping, both teams at once) are voided and refunded in full.
- Drop below 10 points with no call pending and you can claim a bailout back up to 50.
- Stakes of 10, 25 and 50 are open from the start; 100, 250 and 500 unlock as you win points. Titles and card colours
  unlock too (see the **Unlocks** section of the card).

## What's on screen

- **ImGui card** (when Call It is the active camera): balance, streak, best and bonus, record, the match score, the open
  calls with their payouts, your pending call with its countdown, recent results, a timer, unlocks and settings.
- **OSD panel** in the top-right of the view: your balance, streak and bonus, best streak, title, record (W / L / void),
  open bet with countdown, last result, and the timer while it runs. You can turn it off or change its size, background
  opacity, margin and screen aspect in **Settings**.
- **Arena & Ball** picker: follow the nearest running match (Auto) or pick an arena; follow a ball automatically or pick
  one, and set a preferred ball type.
- **Camera views** (Settings): Sideline (tracks the ball, adjustable height), Arena overview (under the roof), Follow
  another camera (by camera id, default `anotheraxiom.freecam`) and Hold position.
- **Timer**: Start / Stop (and Reset timer when stopped). Start and Stop also save your config.

## Controls

Call It reads keys and buttons only while it's the active camera.

Keyboard (turn off with **Keyboard hotkeys** in Settings):

- `1` / `2`: next goal (first team / second team)
- `3` / `4`: goal in the next 30 s (Yes / No)
- `5` / `6`: next team to reach the ball (first team / second team)
- `-` / `=`: lower / raise the stake

The number pad works too (`1` to `6`, `-` and `+`).

Gamepad (turn off with **Gamepad controls** in Settings):

- D-pad up / down: pick a call
- D-pad left / right: pick a side
- A: lock it in
- LB / RB: lower / raise the stake

You can also just click the buttons on the card.

## Saving

Progress and settings save with **Save**, **Save & Quit**, and the timer's **Start** / **Stop**. Saving only works while
Call It is the active camera. A call that's still pending when you save is stored as refunded. Calls keep resolving if
you switch to another camera.

## Credits

- Author: **Ashtonite (Ashtonite365)**
- Call It is an original script. It isn't based on Scha's Drone Camera or on Another Axiom's camera scripts. The OSD
  drawing approach is borrowed from Ashtonite's own [Ashtonite.Core Drone](https://github.com/Ashtonite365/Ashtonite-Core-Drone).
- Concept and development with AI assistance (Grok Bot agents).

Older versions: [`archive/`](archive/).

## Licence

Copyright (c) 2026 Ashtonite (Ashtonite365).

Ashtonite.Call It is free software under the **GNU General Public License v3.0 only** (`GPL-3.0-only`, see
[LICENSE](LICENSE)), with the additional terms in [NOTICE](NOTICE):

- You can use, study, change and share it.
- If you share it or a modified version, you must share the full source under the same licence, keep the credit to
  Ashtonite (Ashtonite365) and the NOTICE, and mark your version as modified. Nobody may turn it into a closed-source script.
- It comes with no warranty.

The GPL grants no rights in Another Axiom material. Use of Orion Drift game material is subject to Another Axiom's
[Fan Content & Mod Policy](https://oriondriftvr.com/asset-kit) (non-commercial, community use only).
