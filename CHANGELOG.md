# Changelog

## 1.0.6

First public release.

Added
- Three calls on live Driftball: Next goal (x1.9 per team), Goal in the next 30 s? (Yes x2.5 / No x1.5) and Next team
  to reach the ball (x1.9 per team; waits for a free ball, 1.2 m reach, 45 s limit). One call at a time, with a 2 s
  lock-in
- Points bank: 200 to start, stakes of 10 / 25 / 50 plus 100 / 250 / 500 unlocked by points won, a win streak bonus
  (+10% per win, up to +50%), half refund on cancel, full refund on voided calls, and a bailout to 50 when you run dry
- Unlockable titles and card colours
- ImGui card with bank, match score, open calls, your pending call, recent results, unlocks and settings
- Top-right OSD panel: balance, streak and bonus, best streak, title, record, open bet with countdown, last result and
  the timer while it runs. Settings for size, background opacity, margin and screen aspect
- Arena & Ball picker: Auto (nearest running match) or a chosen arena; Auto or a chosen ball, plus a preferred ball type
- Camera views: Sideline (tracks the ball, adjustable height), Arena overview, Follow another camera and Hold position
- Timer with Start / Stop / Reset; Start and Stop save the config
- Keyboard hotkeys (1 to 6, - and =, number pad too) and gamepad controls (D-pad, A, LB / RB), each with an on/off switch
- Save, Save & Quit and Reset progress (with confirmation)
- Build tag shown on the card (`build: v1.0.6`)

Licence
- Licensed under GPL-3.0-only with NOTICE additional terms (keep the author attribution, mark modified versions)
