-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (c) 2026 Ashtonite (Ashtonite365)
-- @name Ashtonite.Call It
-- @version 1.0.6
-- @credits Concept and development with AI assistance (Grok Bot agents)
-- @author Ashtonite365
-- Call It: a points prediction game for live Driftball. Call the next goal, whether a goal comes in the
-- next 30 seconds, or which team reaches the ball next, then watch the call resolve from live match data.
-- Unofficial community spectator camera script for Orion Drift.
-- Licence: GNU GPL v3 only, with the additional terms in NOTICE (keep the author attribution, mark
--   modified versions). See LICENSE and NOTICE. This program comes with ABSOLUTELY NO WARRANTY.
-- Credits: an original script by Ashtonite (Ashtonite365), not based on Scha's or Another Axiom's camera
--   scripts. The OSD drawing approach is borrowed from Ashtonite's own Ashtonite.Core Drone (same author).
-- This product is not affiliated with Another Axiom Inc. or its videogames Gorilla Tag and Orion Drift and is not endorsed or otherwise sponsored by Another Axiom. Portions of the materials contained herein are property of Another Axiom. ©2025 Another Axiom Inc.

metadata = {
	name = "Ashtonite.Call It",
	description = "Bet points on live Driftball calls: next goal, goal in 30 s, next team to the ball, plus your Call It stats on screen (1.0.6)",
	author = "Ashtonite",
	defaultKeybind = "",
}

local BUILD_TAG = "build: v1.0.6"

alwaysTick = true

local V = Vec3.new
local floor, max, min, clamp, ceil = math.floor, math.max, math.min, math.clamp, math.ceil
local format = string.format
local HUGE = math.huge

local START_BALANCE = 200
local MIN_STAKE = 10
local BAILOUT_TO = 50
local MAX_POINTS = 999999999
local MAX_COUNT = 99999999
local STREAK_STEP = 0.1
local STREAK_CAP = 5
local CANCEL_KEEP = 0.5

local LOCK_DELAY = 2
local WINDOW_SECONDS = 30
local REACH_TIMEOUT = 45
local IDLE_VOID = 60
local WINDOW_IDLE_VOID = 3
local POLL_INTERVAL = 0.1
local SCAN_INTERVAL = 2
local MAX_DT = 1

local REACH_CM = 120

local NEAR_CLIP = 1
local FOLLOW_CLIP_WARN = 100
local SIDELINE_FOV = 70
local OVERVIEW_SPOT = V(2100, 0, 1115)
local OVERVIEW_LOOK = V(0, 0, 0)
local OVERVIEW_FOV = 90
local SIDELINE_X = 2100
local SIDELINE_MAX_Y = 1300
local SIDE_Z = { DEFAULT = 400, MIN = 300, MAX = 1115 }

local BALL = {
	REACQUIRE_CM = 800,
	LOST_GRACE = 5,
	LIST_INTERVAL = 0.25,
	ROWS_MAX = 24,
	TYPE_MAX = 1000000,
}

local AUDIO_NUDGE = 0.02

local OSDK = {
	HUD_DEPTH = 10,
	DESIGN_TAN = math.tan(math.rad(52.5)),
	HUD_UNIT = 10 / 120,
	HUD_HALF = 120 * math.tan(math.rad(52.5)),
	LIFE = 0.05,
	BACK_UNITS = 1.5,
	MID_UNITS = 0.75,
	REFRESH = 0.25,
	LINES_H = 1080,
	W = 372,
	PAD = 14,
	Y_TITLE = 12,
	Y_SEP = 36,
	Y_BAL = 46,
	Y_STREAK = 80,
	Y_REC = 104,
	Y_BET = 128,
	Y_BET2 = 152,
	Y_LAST = 176,
	Y_TIMER = 200,
	H = 203,
	H_TIMER = 227,
	GLYPH = 2.5,
	ADV = 14.5,
	TEXT_PX = 3,
	BORDER_PX = 4,
	SEP_PX = 3,
	BIG = 1.4,
	FLASH = 2.5,
	RANK_MAX = 14,
	OPT_MAX = 8,
	BAL_PTS_MAX = 7,
	ERR_MAX = 90,
	GREEN = { 0.3, 1, 0.45 },
	RED = { 1, 0.32, 0.3 },
	GOLD = { 1, 0.8, 0.2 },
	GREY = { 0.62, 0.66, 0.74 },
	SCALE = { DEFAULT = 1, MIN = 0.5, MAX = 2 },
	ALPHA = { DEFAULT = 0.6, MIN = 0, MAX = 1 },
	MARGIN = { DEFAULT = 24, MIN = 0, MAX = 300 },
	ASPECT = { DEFAULT = 16 / 9, MIN = 1.25, MAX = 3.5 },
	HALF_POS = 0.35,
	HALF_ROT = 0.2,
	HALF_FOV = 0.35,
	SNAP_CM = 5000,
	FONT = {
		A = "0602204246 0343", B = "060030413303 03434606", C = "40000646",
		D = "00304145360600", E = "40000646 0333", F = "400006 0333", G = "4000064643 2343",
		H = "0006 4046 0343", I = "1030 2026 1636", J = "40460605", K = "0006 400346", L = "000646",
		M = "0600224046", N = "06004640", O = "0040460600", P = "0600404303",
		Q = "0040460600 2446", R = "0600404303 2346", S = "40100102133344453606",
		T = "0040 2026", U = "00064640", V = "002640", W = "0016233640", X = "0046 4006",
		Y = "002340 2326", Z = "00400646",
		["0"] = "0040460600 0640", ["1"] = "112026 1636", ["2"] = "004043030646",
		["3"] = "00404606 1343", ["4"] = "36300444", ["5"] = "400003434606",
		["6"] = "400006464303", ["7"] = "004016", ["8"] = "0040460600 0343",
		["9"] = "430300404606", ["."] = "1525261615", [","] = "252617", ["-"] = "0343",
		["+"] = "0343 2125", [":"] = "2122 2425", ["/"] = "0640", ["("] = "30121436", [")"] = "10323416",
		["#"] = "1016 3036 0242 0444", ["!"] = "2024 2526", ["?"] = "0110304142332324 2526", ["'"] = "2021",
		["%"] = "0640 0001 4546", [">"] = "004306", ["<"] = "400346", ["_"] = "0646", ["*"] = "2125 0244 0442",
		["="] = "0242 0444", ["["] = "30101636", ["]"] = "10303616",
	},
}

local TIMER = { TICKS_PER_SEC = 10000000, MAX_SECS = 10 * 365 * 86400, FUTURE_SLACK = 5 }

local ARENA_MIN = V(-2271, -3300, -100)
local ARENA_MAX = V(2271, 3300, 1350)
local ARENA_SKIP: { [string]: boolean } = { TKB_Quest_Full = true, TKB_Annex_Demo_Full_2 = true }

local SAVE_KEY = "callit"
local SAVE_VERSION = 1
local RECENT_MAX = 8
local FOLLOW_ID_MAX = 64
local SLOT_MAX = 64

type CallDef = { title: string, teams: boolean, options: { string }, mult: { number }, help: string }
local CALL_GOAL, CALL_WINDOW, CALL_REACH = 1, 2, 3
local CALLS: { CallDef } = {
	{
		title = "Next goal",
		teams = true,
		options = { "", "" },
		mult = { 1.9, 1.9 },
		help = "Which team scores the next goal in this arena. Resolves when a team's score goes up.",
	},
	{
		title = "Goal in the next 30 s?",
		teams = false,
		options = { "Yes", "No" },
		mult = { 2.5, 1.5 },
		help = "Yes wins if either team scores within 30 s of the call going live; No wins if nobody does.",
	},
	{
		title = "Next team to reach the ball",
		teams = true,
		options = { "", "" },
		mult = { 1.9, 1.9 },
		help = "Waits until nobody is near the ball, then the first team to get a head or hand within 1.2 m of it wins. Approximate (there is no touch event).",
	},
}
local CALL_IDS = { "call1", "call2", "call3" }

type StakeTier = { amount: number, kind: string, need: number }
type Title = { id: string, name: string, kind: string, need: number }
type Theme = { id: string, name: string, kind: string, need: number, r: number, g: number, b: number }
local STAKES: { StakeTier } = {
	{ amount = 10, kind = "wins", need = 0 },
	{ amount = 25, kind = "wins", need = 0 },
	{ amount = 50, kind = "wins", need = 0 },
	{ amount = 100, kind = "won", need = 300 },
	{ amount = 250, kind = "won", need = 1500 },
	{ amount = 500, kind = "won", need = 5000 },
}
local STAKE_IDS = { "s1", "s2", "s3", "s4", "s5", "s6" }
local DEFAULT_STAKE = 25
local TITLES: { Title } = {
	{ id = "rookie", name = "Rookie Caller", kind = "wins", need = 0 },
	{ id = "hunch", name = "Hunch Haver", kind = "wins", need = 5 },
	{ id = "sharp", name = "Sharp Eye", kind = "best", need = 3 },
	{ id = "analyst", name = "Armchair Analyst", kind = "wins", need = 25 },
	{ id = "oracle", name = "Drift Oracle", kind = "best", need = 6 },
	{ id = "prophet", name = "Driftball Prophet", kind = "won", need = 5000 },
}
local THEMES: { Theme } = {
	{ id = "classic", name = "Classic", kind = "wins", need = 0, r = 1, g = 1, b = 1 },
	{ id = "ice", name = "Ice", kind = "won", need = 250, r = 0.45, g = 0.9, b = 1 },
	{ id = "neon", name = "Neon", kind = "best", need = 4, r = 1, g = 0.45, b = 0.95 },
	{ id = "gold", name = "Gold", kind = "won", need = 2000, r = 1, g = 0.82, b = 0.3 },
	{ id = "emerald", name = "Emerald", kind = "wins", need = 50, r = 0.35, g = 1, b = 0.55 },
}
local TITLE_AT: { [string]: number } = {}
for i, t in TITLES do
	TITLE_AT[t.id] = i
end
local THEME_AT: { [string]: number } = {}
for i, t in THEMES do
	THEME_AT[t.id] = i
end

local VIEWS = { "Sideline (tracks the ball)", "Arena overview (under the roof)", "Follow another camera", "Hold position (camera stays put)" }
local VIEW_SIDELINE, VIEW_OVERVIEW, VIEW_FOLLOW, VIEW_NONE = 1, 2, 3, 4

local L = {}
L.SAVE = Icon.Save .. " Save"
L.QUIT = Icon.SignOutAlt .. " Save & Quit"
L.RESUME = Icon.Play .. " Resume"
L.RESET = Icon.Undo .. " Reset progress"
L.RESET_YES = Icon.Check .. " Yes, reset everything"
L.RESET_NO = Icon.Times .. " Cancel"
L.RESET_ASK = "Reset balance, streaks, stats and unlocks? (Takes effect in this session; press Save to make it permanent.)"
L.BANK = Icon.Coins .. " Bank"
L.STAKE = "Stake"
L.CALLS = Icon.Bullseye .. " Open calls"
L.YOURS = Icon.HourglassHalf .. " Your call"
L.NO_CALL = "No call pending. Pick one above."
L.RECENT = Icon.Clock .. " Recent results"
L.NO_RECENT = "Nothing yet this session."
L.UNLOCKS = Icon.Trophy .. " Unlocks"
L.TITLE = "Title"
L.THEME = "Card colour"
L.SETTINGS = Icon.Cog .. " Settings"
L.VIEW = "Camera view"
L.FOLLOW_ID = "Camera id to follow"
L.FOLLOW_APPLY = "Apply"
L.ARENA = "Arena"
L.AUTO = "Auto (nearest running match)"
L.ARENA_LOCKED = "The arena is locked while a call is pending."
L.ARENA_TIP = "Auto follows the nearest running Driftball match. A manual pick stays until you change it (Save keeps it)."
L.REACH_OFF = "Not available here: the game reports no team rosters, so a reach can't be credited to a team."
L.MATCH = Icon.Futbol .. " Match"
L.ARENA_BALL = Icon.Crosshairs .. " Arena & Ball"
L.BALLS = "Ball to follow"
L.BALL_AUTO = "Auto (preferred type, else the ball nearest the centre)"
L.BALL_CLEAR = "Clear preferred type"
L.BALL_LOCKED = "Ball choice is locked while a reach call is pending."
L.BALL_NONE = "No ball in this arena right now."
L.SIDE_Z = "Sideline height (cm)"
L.SIDE_Z_RESET = "R##sideZ"
L.TIMER = Icon.Stopwatch .. " Timer"
L.TIMER_START = Icon.Play .. " Start"
L.TIMER_STOP = Icon.Stop .. " Stop"
L.TIMER_RESET = Icon.Undo .. " Reset timer"
L.TIMER_NOTE = "Start and Stop save the config (your progress too). Stop freezes the time; Start continues it."
L.TIMER_INACTIVE = "Timer unchanged: Call It must be the active camera (Start/Stop save the active camera's config)."
L.TIMER_NOCLOCK = "Timer unchanged: the wall clock (DateTime) is not available."
L.OSD = Icon.Desktop .. " On-screen stats (OSD)"
L.OSD_ON = "Show your Call It stats in the top-right of the view"
L.OSD_SCALE = "OSD size"
L.OSD_SCALE_RESET = "R##osdScale"
L.OSD_SCALE_TIP = "Reset to 1.00"
L.OSD_ALPHA = "OSD background opacity"
L.OSD_ALPHA_RESET = "R##osdAlpha"
L.OSD_ALPHA_TIP = "Reset to 0.60 (the text itself is always opaque: WorldDraw lines have no transparency)"
L.OSD_MARGIN = "OSD margin (px at 1080p)"
L.OSD_MARGIN_RESET = "R##osdMargin"
L.OSD_MARGIN_TIP = "Reset to 24"
L.OSD_ASPECT = "Screen aspect (width / height)"
L.OSD_ASPECT_RESET = "R##osdAspect"
L.OSD_ASPECT_TIP = "Reset to 16:9 (1.78). There is no API for the window size: set your screen's ratio (21:9 = 2.33, 16:10 = 1.60)."
L.OSD_NOTE = "Shows your balance, streak and bonus, best streak, title, record, open bet with countdown, last result, and the timer while it runs."
L.HOTKEYS = Icon.Keyboard .. " Keyboard hotkeys"
L.GAMEPAD = Icon.Gamepad .. " Gamepad controls"
L.HELP_KEYS = "Keys: 1/2 next goal, 3/4 goal in 30 s (yes/no), 5/6 next team to the ball. - and = change the stake."
L.HELP_PAD = "Gamepad: D-pad up/down picks a call, left/right picks a side, A locks it in, LB/RB change the stake."
L.HELP_CARD = "Call It needs to be the active camera to show this card and to save. Calls keep resolving if you switch cameras."
L.DISCLAIMER = "This product is not affiliated with Another Axiom Inc. or its videogames Gorilla Tag and Orion Drift and is not endorsed or otherwise sponsored by Another Axiom. Portions of the materials contained herein are property of Another Axiom. ©2025 Another Axiom Inc."
L.LOCKED = Icon.Lock .. " "
L.OPEN = Icon.Check .. " "
L.FOCUS = "> "

local COL = {}
COL.WIN = LinearColor.new(0.35, 1, 0.45, 1)
COL.LOSS = LinearColor.new(1, 0.4, 0.35, 1)
COL.VOID = LinearColor.new(0.7, 0.7, 0.7, 1)
COL.INFO = LinearColor.new(1, 0.85, 0.35, 1)
COL.WARN = LinearColor.new(1, 0.6, 0.2, 1)

type Progress = {
	balance: number,
	streak: number,
	best: number,
	wins: number,
	losses: number,
	voids: number,
	won: number,
	bailouts: number,
}
type Prefs = {
	stake: number,
	title: string,
	theme: string,
	hotkeys: boolean,
	gamepad: boolean,
	view: number,
	followId: string,
	arena: string,
	sideZ: number,
	ballType: number,
	osd: boolean,
	osdScale: number,
	osdAlpha: number,
	osdMargin: number,
	osdAspect: number,
}
type Bet = {
	call: number,
	pick: number,
	stake: number,
	mult: number,
	liveAt: number,
	deadline: number,
	armed: boolean,
	slot: string,
	label: string,
}

local function newProgress(): Progress
	return { balance = START_BALANCE, streak = 0, best = 0, wins = 0, losses = 0, voids = 0, won = 0, bailouts = 0 }
end
local function newPrefs(): Prefs
	return {
		stake = DEFAULT_STAKE,
		title = "rookie",
		theme = "classic",
		hotkeys = true,
		gamepad = true,
		view = VIEW_SIDELINE,
		followId = "anotheraxiom.freecam",
		arena = "",
		sideZ = SIDE_Z.DEFAULT,
		ballType = -1,
		osd = true,
		osdScale = OSDK.SCALE.DEFAULT,
		osdAlpha = OSDK.ALPHA.DEFAULT,
		osdMargin = OSDK.MARGIN.DEFAULT,
		osdAspect = OSDK.ASPECT.DEFAULT,
	}
end

local P: Progress = newProgress()
local prefs: Prefs = newPrefs()
local pending: Bet? = nil
local now = 0
local pollClock, scanClock = 0, SCAN_INTERVAL
local idle = 0
local paused = false
local unsaved = false
local confirmReset = false
local lastSaved: { [string]: any }? = nil
local statusMsg = ""

local serverName, serverKnown = "", false
local arena: ModuleStateSpectatorLuaApi? = nil
local arenaSlot = ""
local arenaPos: Vec3 = V(0, 0, 0)
local arenaRot: Quat = Quat.identity
local arenaChoices: { string } = {}
local arenaLabels: { string } = {}
local arenaMissing = false
local matchReadOk = true
local running = false
local teamCount = 0
local score0, score1, scoreKnown = 0, 0, false
local teamName = { "Team 1", "Team 2" }
local teamOf: { [number]: number } = {}
local rosterSize = 0
local shownName = { "Team 1", "Team 2" }
local lastGoal = ""

local stakeOpen: { boolean } = {}
local titleOpen: { boolean } = {}
local themeOpen: { boolean } = {}

local wasActive = false
local viewApplied = false
local following = false
local followApplied = false
local followMsg = ""
local followTarget: SpectatorCamera? = nil
local followClip = 0
local followEdit = prefs.followId
local audioFlip = 0
local holdPos: Vec3 = V(0, 0, 0)

type BallRow = { index: number, btype: number, size: number, pos: Vec3 }
local B = {
	sel = false,
	selIndex = 0,
	selType = 0,
	selPos = V(0, 0, 0),
	lost = false,
	lostAt = 0,
	lostShown = -1,
	autoIndex = -1,
	autoType = -1,
	curIndex = -1,
	curType = -1,
	rows = {} :: { BallRow },
	nextList = 0,
	guiSeen = -1,
}
local T = { on = false, start = 0, acc = 0, shown = -1 }

local SM = { init = false, pos = V(0, 0, 0), rot = Quat.identity, fov = 90 }

type OsdText = { s: string, segs: { number }, w: number }
local OSD = {}
local O = {
	nextRefresh = 0,
	flashAt = -100,
	flashCol = { 1, 1, 1 } :: { number },
	flashRow = 0,
	lastKind = 0,
	lastAmt = 0,
	lastGen = 0,
	lastCol = { 0.62, 0.66, 0.74 } :: { number },
	k = {
		title = "\0",
		bal = -1,
		streak = -1,
		best = -1,
		w = -1,
		l = -1,
		v = -1,
		call = -1,
		opt = "\0",
		stake = -1,
		mult = -1,
		secs = -3,
		lock = false,
		armed = false,
		last = -1,
		timer = "\0",
	},
	bgA = -1,
	bg = LinearColor.new(0, 0, 0, 0),
	org = V(0, 0, 0),
	f = V(1, 0, 0),
	r = V(0, 1, 0),
	u = V(0, 0, 1),
	hs = 1,
	hx = 1,
	hy = 1,
	c = 1,
	x0 = 0,
	y0 = 0,
	q = 1,
	t = {
		title = { s = "\0", segs = {}, w = 0 } :: OsdText,
		rank = { s = "\0", segs = {}, w = 0 } :: OsdText,
		balL = { s = "\0", segs = {}, w = 0 } :: OsdText,
		bal = { s = "\0", segs = {}, w = 0 } :: OsdText,
		streak = { s = "\0", segs = {}, w = 0 } :: OsdText,
		best = { s = "\0", segs = {}, w = 0 } :: OsdText,
		recL = { s = "\0", segs = {}, w = 0 } :: OsdText,
		rec = { s = "\0", segs = {}, w = 0 } :: OsdText,
		betL = { s = "\0", segs = {}, w = 0 } :: OsdText,
		betS = { s = "\0", segs = {}, w = 0 } :: OsdText,
		bet = { s = "\0", segs = {}, w = 0 } :: OsdText,
		lastL = { s = "\0", segs = {}, w = 0 } :: OsdText,
		last = { s = "\0", segs = {}, w = 0 } :: OsdText,
		timerL = { s = "\0", segs = {}, w = 0 } :: OsdText,
		timer = { s = "\0", segs = {}, w = 0 } :: OsdText,
	},
}
function OSD.flash(col: { number }, row: number)
	O.flashAt, O.flashCol, O.flashRow = now, col, row
end
function OSD.result(kind: number, amount: number)
	O.lastKind, O.lastAmt, O.lastGen = kind, amount, O.lastGen + 1
	if kind == 1 then
		OSD.flash(OSDK.GREEN, OSDK.Y_LAST)
		if P.streak == 3 or P.streak % 5 == 0 then
			OSD.flash(OSDK.GOLD, OSDK.Y_STREAK)
		end
	elseif kind == 2 then
		OSD.flash(OSDK.RED, OSDK.Y_LAST)
	end
	O.nextRefresh = 0
end
local typingUntil = -1
local focusCall, focusOpt = 1, 1

type Line = { text: string, colour: LinearColor }
local recent: { Line } = {}
local dirty = true
local view = {
	header = "",
	accent = LinearColor.new(1, 1, 1, 1),
	balance = "",
	streak = "",
	record = "",
	match = "",
	arenaLine = "",
	closed = nil :: string?,
	cantAfford = false,
	stakeLabel = {} :: { string },
	stakeTip = {} :: { string },
	callTitle = {} :: { string },
	opt = { {}, {}, {} } :: { { string } },
	pendingLine = "",
	pendingStatus = "",
	cancelLabel = "",
	bailout = false,
	bailoutLabel = "",
	unlockCount = "",
	unlockLines = {} :: { Line },
	titlePreview = "",
	themePreview = "",
	arenaPreview = "",
	saveLine = "",
	followWarn = "",
	reachOff = false,
	ballLine = "",
	ballPref = "",
	ballRow = {} :: { string },
	ballTypeBtn = {} :: { string },
	timer = "00:00:00",
	timerState = "",
}
local ROW_IDS: { string } = {}
for i = 1, BALL.ROWS_MAX do
	ROW_IDS[i] = format("ballrow%d", i)
end
local shownSecs, shownLocking, shownArmed = -2, false, false

local function finite(v: any): boolean
	return type(v) == "number" and v == v and v > -HUGE and v < HUGE
end
local function readInt(v: any, lo: number, hi: number, default: number): number
	if not finite(v) then
		return default
	end
	return clamp(floor(v), lo, hi)
end
function OSD.readNum(v: any, r: { DEFAULT: number, MIN: number, MAX: number }): number
	if not finite(v) then
		return r.DEFAULT
	end
	return clamp(v, r.MIN, r.MAX)
end
local function readBool(v: any, default: boolean): boolean
	if type(v) == "boolean" then
		return v
	end
	return default
end

local function commas(n: number): string
	local s = format("%d", floor(n))
	local k = 0
	repeat
		s, k = string.gsub(s, "^(-?%d+)(%d%d%d)", "%1,%2")
	until k == 0
	return s
end

local function isDriftball(slot: string): boolean
	return string.sub(slot, 1, 4) == "TKB_" and #slot > 4 and not ARENA_SKIP[slot]
end

local function addPoints(delta: number)
	P.balance = clamp(floor(P.balance + delta), 0, MAX_POINTS)
end

local function bump(n: number): number
	return min(n + 1, MAX_COUNT)
end

local function reached(kind: string, need: number): boolean
	if kind == "wins" then
		return P.wins >= need
	elseif kind == "best" then
		return P.best >= need
	end
	return P.won >= need
end
local function goalText(kind: string, need: number): string
	if kind == "wins" then
		return format("%s winning calls", commas(need))
	elseif kind == "best" then
		return format("a best streak of %d", need)
	end
	return format("%s pts won", commas(need))
end

local function bonusFor(streak: number): number
	return min(streak, STREAK_CAP) * STREAK_STEP
end
local function profitFor(stake: number, mult: number, streak: number): number
	return floor(stake * (mult - 1) * (1 + bonusFor(streak)) + 1e-6)
end

local function pushRecent(text: string, colour: LinearColor)
	table.insert(recent, 1, { text = text, colour = colour })
	while #recent > RECENT_MAX do
		table.remove(recent)
	end
	dirty = true
end

local function refreshUnlocks(announce: boolean)
	for i, s in STAKES do
		local open = reached(s.kind, s.need)
		if announce and open and not stakeOpen[i] then
			pushRecent(format("Unlocked: %s pt stake", commas(s.amount)), COL.INFO)
			OSD.flash(OSDK.GOLD, OSDK.Y_TITLE)
		end
		stakeOpen[i] = open
	end
	for i, t in TITLES do
		local open = reached(t.kind, t.need)
		if announce and open and not titleOpen[i] then
			pushRecent(format("Unlocked title: %s", t.name), COL.INFO)
			OSD.flash(OSDK.GOLD, OSDK.Y_TITLE)
		end
		titleOpen[i] = open
	end
	for i, t in THEMES do
		local open = reached(t.kind, t.need)
		if announce and open and not themeOpen[i] then
			pushRecent(format("Unlocked card colour: %s", t.name), COL.INFO)
			OSD.flash(OSDK.GOLD, OSDK.Y_TITLE)
		end
		themeOpen[i] = open
	end
end

local function fixPrefs()
	local stakeOk = false
	for i, s in STAKES do
		if s.amount == prefs.stake and stakeOpen[i] then
			stakeOk = true
		end
	end
	if not stakeOk then
		prefs.stake = DEFAULT_STAKE
	end
	local ti = TITLE_AT[prefs.title]
	if ti == nil or not titleOpen[ti] then
		prefs.title = "rookie"
	end
	local th = THEME_AT[prefs.theme]
	if th == nil or not themeOpen[th] then
		prefs.theme = "classic"
	end
end

local Clock = {}

function Clock.now(): number?
	local ok, t = pcall(function(): number
		return DateTime.getCurrentTime().ticks
	end)
	if ok and finite(t) and t > 0 then
		return floor(t / TIMER.TICKS_PER_SEC)
	end
	return nil
end

function Clock.load(d: any)
	T.on, T.start, T.acc, T.shown = false, 0, 0, -1
	if type(d) ~= "table" then
		return
	end
	local acc = if finite(d.timerAcc) and d.timerAcc >= 0 and d.timerAcc <= TIMER.MAX_SECS then floor(d.timerAcc) else 0
	if d.timerOn ~= true then
		T.acc = acc
		return
	end
	local nowS = Clock.now()
	local st = d.timerStart
	if nowS == nil or type(st) ~= "string" or #st > 15 or string.match(st, "^%d+$") == nil then
		return
	end
	local start = tonumber(st)
	if start == nil or start > nowS + TIMER.FUTURE_SLACK or nowS - start > TIMER.MAX_SECS then
		return
	end
	T.on, T.start, T.acc = true, start, acc
end

local function loadFrom(src: any): boolean
	P = newProgress()
	prefs = newPrefs()
	local d = if type(src) == "table" then src[SAVE_KEY] else nil
	local ok = type(d) == "table"
	if ok then
		P.balance = readInt(d.balance, 0, MAX_POINTS, START_BALANCE)
		P.wins = readInt(d.wins, 0, MAX_COUNT, 0)
		P.losses = readInt(d.losses, 0, MAX_COUNT, 0)
		P.voids = readInt(d.voids, 0, MAX_COUNT, 0)
		P.won = readInt(d.won, 0, MAX_POINTS, 0)
		P.bailouts = readInt(d.bailouts, 0, MAX_COUNT, 0)
		P.streak = min(readInt(d.streak, 0, MAX_COUNT, 0), P.wins)
		P.best = clamp(readInt(d.best, 0, MAX_COUNT, 0), P.streak, P.wins)
		prefs.stake = readInt(d.stake, 0, MAX_POINTS, DEFAULT_STAKE)
		if type(d.title) == "string" and TITLE_AT[d.title] ~= nil then
			prefs.title = d.title
		end
		if type(d.theme) == "string" and THEME_AT[d.theme] ~= nil then
			prefs.theme = d.theme
		end
		prefs.hotkeys = readBool(d.hotkeys, true)
		prefs.gamepad = readBool(d.gamepad, true)
		prefs.view = readInt(d.view, 1, #VIEWS, VIEW_SIDELINE)
		if type(d.followId) == "string" and #d.followId > 0 and #d.followId <= FOLLOW_ID_MAX then
			prefs.followId = d.followId
		end
		if type(d.arena) == "string" and #d.arena <= SLOT_MAX and isDriftball(d.arena) then
			prefs.arena = d.arena
		end
		if finite(d.sideZ) then
			prefs.sideZ = clamp(floor(d.sideZ + 0.5), SIDE_Z.MIN, SIDE_Z.MAX)
		end
		local bt = d.ballType
		prefs.ballType = if finite(bt) and bt >= -1 and bt <= BALL.TYPE_MAX then floor(bt) else -1
		prefs.osd = readBool(d.osd, true)
		prefs.osdScale = OSD.readNum(d.osdScale, OSDK.SCALE)
		prefs.osdAlpha = OSD.readNum(d.osdAlpha, OSDK.ALPHA)
		prefs.osdMargin = floor(OSD.readNum(d.osdMargin, OSDK.MARGIN) + 0.5)
		prefs.osdAspect = OSD.readNum(d.osdAspect, OSDK.ASPECT)
	end
	Clock.load(if ok then d else nil)
	refreshUnlocks(false)
	fixPrefs()
	followEdit = prefs.followId
	return ok
end

local function snapshot(): { [string]: any }
	local refund = if pending then pending.stake else 0
	return {
		v = SAVE_VERSION,
		balance = min(P.balance + refund, MAX_POINTS),
		streak = P.streak,
		best = P.best,
		wins = P.wins,
		losses = P.losses,
		voids = P.voids,
		won = P.won,
		bailouts = P.bailouts,
		stake = prefs.stake,
		title = prefs.title,
		theme = prefs.theme,
		hotkeys = prefs.hotkeys,
		gamepad = prefs.gamepad,
		view = prefs.view,
		followId = prefs.followId,
		arena = prefs.arena,
		sideZ = prefs.sideZ,
		ballType = prefs.ballType,
		osd = prefs.osd,
		osdScale = prefs.osdScale,
		osdAlpha = prefs.osdAlpha,
		osdMargin = prefs.osdMargin,
		osdAspect = prefs.osdAspect,
		timerOn = T.on,
		timerStart = if T.on then format("%d", T.start) else "",
		timerAcc = T.acc,
	}
end

local function doSave(): boolean
	if not camera.isActive then
		statusMsg = "Not saved: Call It must be the active camera to save."
		dirty = true
		return false
	end
	if type(config) ~= "table" then
		statusMsg = "Not saved: settings storage is not available right now."
		dirty = true
		return false
	end
	local snap = snapshot()
	config[SAVE_KEY] = snap
	local ok = saveConfig()
	if ok then
		lastSaved = table.clone(snap)
		unsaved = false
		statusMsg = if pending then "Saved (the pending call is saved as refunded)." else "Saved."
	else
		statusMsg = "Save failed. Try again."
	end
	dirty = true
	return ok
end

function Clock.elapsed(nowS: number?): number
	local e = T.acc
	if T.on and nowS ~= nil then
		e += max(0, nowS - T.start)
	end
	return clamp(e, 0, TIMER.MAX_SECS)
end

local function timerStart()
	if T.on then
		return
	end
	if not camera.isActive then
		statusMsg = L.TIMER_INACTIVE
		dirty = true
		return
	end
	local nowS = Clock.now()
	if nowS == nil then
		statusMsg = L.TIMER_NOCLOCK
		dirty = true
		return
	end
	T.on, T.start, T.shown = true, nowS, -1
	if doSave() then
		statusMsg = "Timer started (saved, together with your progress)."
	end
	dirty = true
end

local function timerStop()
	if not T.on then
		return
	end
	if not camera.isActive then
		statusMsg = L.TIMER_INACTIVE
		dirty = true
		return
	end
	local nowS = Clock.now()
	if nowS == nil then
		statusMsg = L.TIMER_NOCLOCK
		dirty = true
		return
	end
	T.acc = Clock.elapsed(nowS)
	T.on, T.start, T.shown = false, 0, -1
	if doSave() then
		statusMsg = "Timer stopped (saved, together with your progress)."
	end
	dirty = true
end

function Clock.reset()
	if T.on or T.acc == 0 then
		return
	end
	T.acc, T.shown = 0, -1
	unsaved = true
	dirty = true
end

function Clock.refresh()
	local e = floor(Clock.elapsed(if T.on then Clock.now() else nil))
	if e ~= T.shown then
		T.shown = e
		view.timer = format("%02d:%02d:%02d", floor(e / 3600), floor(e / 60) % 60, e % 60)
	end
end

local function settle(outcome: string, note: string)
	local b = pending
	if b == nil then
		return
	end
	pending = nil
	idle = 0
	if outcome == "win" then
		local profit = profitFor(b.stake, b.mult, P.streak)
		addPoints(b.stake + profit)
		P.wins = bump(P.wins)
		P.won = min(P.won + profit, MAX_POINTS)
		P.streak = min(P.streak + 1, MAX_COUNT)
		P.best = max(P.best, P.streak)
		pushRecent(format("WIN +%s  %s", commas(profit), b.label), COL.WIN)
		OSD.result(1, profit)
		refreshUnlocks(true)
	elseif outcome == "lose" then
		P.losses = bump(P.losses)
		P.streak = 0
		pushRecent(format("LOSS -%s  %s", commas(b.stake), b.label), COL.LOSS)
		OSD.result(2, b.stake)
	else
		addPoints(b.stake)
		P.voids = bump(P.voids)
		pushRecent(format("VOID (refund %s)  %s: %s", commas(b.stake), b.label, note), COL.VOID)
		OSD.result(3, b.stake)
	end
	unsaved = true
	dirty = true
end

local function openReason(): string?
	if paused then
		return "Session ended. Press Resume to play again."
	elseif arenaMissing then
		return "Your chosen arena isn't on this server right now. Pick another arena or Auto in Settings."
	elseif arena == nil then
		return "No Driftball arena found on this server."
	elseif not matchReadOk then
		return "Can't read this arena's match data right now."
	elseif teamCount < 2 then
		return "Waiting for two teams."
	elseif not running then
		return "Waiting for the match to be running."
	elseif not scoreKnown then
		return "Reading the score..."
	elseif pending ~= nil then
		return "One call at a time. Wait for your result."
	end
	return nil
end

local function placeBet(call: number, pick: number): boolean
	if openReason() ~= nil or CALLS[call] == nil or (pick ~= 1 and pick ~= 2) then
		return false
	end
	if call == CALL_REACH and rosterSize == 0 then
		return false
	end
	local stake = prefs.stake
	if stake < MIN_STAKE or P.balance < stake then
		return false
	end
	local def = CALLS[call]
	local optName = if def.teams then shownName[pick] else def.options[pick]
	local mult = def.mult[pick]
	addPoints(-stake)
	local liveAt = now + LOCK_DELAY
	pending = {
		call = call,
		pick = pick,
		stake = stake,
		mult = mult,
		liveAt = liveAt,
		deadline = if call == CALL_WINDOW then liveAt + WINDOW_SECONDS elseif call == CALL_REACH then liveAt + REACH_TIMEOUT else HUGE,
		armed = false,
		slot = arenaSlot,
		label = format("%s: %s (x%.1f)", def.title, optName, mult),
	}
	idle = 0
	unsaved = true
	dirty = true
	return true
end

local function cancelBet()
	local b = pending
	if b == nil then
		return
	end
	local back = floor(b.stake * CANCEL_KEEP)
	pending = nil
	addPoints(back)
	P.voids = bump(P.voids)
	pushRecent(format("CANCELLED (refund %s)  %s", commas(back), b.label), COL.VOID)
	unsaved = true
	dirty = true
end

local function claimBailout()
	if pending ~= nil or P.balance >= MIN_STAKE then
		return
	end
	local gain = BAILOUT_TO - P.balance
	addPoints(gain)
	P.bailouts = bump(P.bailouts)
	pushRecent(format("Bailout +%s", commas(gain)), COL.INFO)
	unsaved = true
	dirty = true
end

local function setStake(amount: number)
	for i, s in STAKES do
		if s.amount == amount and stakeOpen[i] and prefs.stake ~= amount then
			prefs.stake = amount
			unsaved = true
			dirty = true
		end
	end
end
local function stepStake(dir: number)
	local cur = 1
	for i, s in STAKES do
		if s.amount == prefs.stake then
			cur = i
		end
	end
	local i = cur + dir
	while STAKES[i] ~= nil and not stakeOpen[i] do
		i += dir
	end
	if STAKES[i] ~= nil then
		setStake(STAKES[i].amount)
	end
end

local function resetProgress()
	P = newProgress()
	pending = nil
	idle = 0
	prefs.stake, prefs.title, prefs.theme = DEFAULT_STAKE, "rookie", "classic"
	table.clear(recent)
	refreshUnlocks(false)
	fixPrefs()
	pushRecent("Progress reset. Press Save to keep it.", COL.INFO)
	confirmReset = false
	unsaved = true
	dirty = true
end

local function inArena(p: Vec3): boolean
	local l = arenaRot:inverse():rotateVector(p - arenaPos)
	return l.x >= ARENA_MIN.x and l.x <= ARENA_MAX.x and l.y >= ARENA_MIN.y and l.y <= ARENA_MAX.y and l.z >= ARENA_MIN.z and l.z <= ARENA_MAX.z
end

local Ball = {}

function Ball.current(index: number, btype: number)
	if index ~= B.curIndex or btype ~= B.curType then
		B.curIndex, B.curType = index, btype
		dirty = true
	end
end

function Ball.track(frame: ReplayFrame): Vec3?
	if arena == nil then
		Ball.current(-1, -1)
		return nil
	end
	local balls = frame.balls
	if B.sel then
		local exact: Vec3? = nil
		local near: ReplayBall? = nil
		local nearD = BALL.REACQUIRE_CM * BALL.REACQUIRE_CM
		for _, b in balls do
			local p = b.transform.position
			if b.type == B.selType and inArena(p) then
				if b.index == B.selIndex then
					exact = p
					break
				end
				local d = (p - B.selPos):squaredLength()
				if d <= nearD then
					near, nearD = b, d
				end
			end
		end
		local pos = exact
		if pos == nil and near ~= nil then
			B.selIndex = near.index
			pos = near.transform.position
			dirty = true
		end
		if pos ~= nil then
			B.selPos = pos
			if B.lost then
				B.lost = false
				dirty = true
			end
			Ball.current(B.selIndex, B.selType)
			return pos
		end
		if not B.lost then
			B.lost, B.lostAt, B.lostShown = true, now, -1
			dirty = true
		end
		if now - B.lostAt < BALL.LOST_GRACE then
			return nil
		end
		B.sel, B.lost = false, false
		B.autoIndex, B.autoType = -1, -1
		pushRecent("The ball you picked was lost for 5 s: back to Auto.", COL.INFO)
	end
	local want = prefs.ballType
	local hasWant = false
	if want >= 0 then
		for _, b in balls do
			if b.type == want and inArena(b.transform.position) then
				hasWant = true
				break
			end
		end
	end
	local best: ReplayBall? = nil
	local bestD = HUGE
	for _, b in balls do
		local p = b.transform.position
		if (not hasWant or b.type == want) and inArena(p) then
			if b.index == B.autoIndex and b.type == B.autoType then
				best = b
				break
			end
			local d = (p - arenaPos):squaredLength()
			if d < bestD then
				best, bestD = b, d
			end
		end
	end
	if best == nil then
		B.autoIndex, B.autoType = -1, -1
		Ball.current(-1, -1)
		return nil
	end
	B.autoIndex, B.autoType = best.index, best.type
	Ball.current(best.index, best.type)
	return best.transform.position
end

function Ball.scanRows(frame: ReplayFrame)
	local n = 0
	local changed = false
	if arena ~= nil then
		for _, b in frame.balls do
			local p = b.transform.position
			if n < BALL.ROWS_MAX and inArena(p) then
				n += 1
				local row = B.rows[n]
				if row == nil then
					row = { index = b.index, btype = b.type, size = b.size, pos = p }
					B.rows[n] = row
					changed = true
				elseif row.index ~= b.index or row.btype ~= b.type or row.size ~= b.size then
					row.index, row.btype, row.size = b.index, b.type, b.size
					changed = true
				end
				row.pos = p
			end
		end
	end
	for i = #B.rows, n + 1, -1 do
		B.rows[i] = nil
		changed = true
	end
	if changed then
		dirty = true
	end
end

function Ball.pick(i: number)
	local r = B.rows[i]
	if r == nil or (pending ~= nil and pending.call == CALL_REACH) then
		return
	end
	B.sel, B.lost = true, false
	B.selIndex, B.selType, B.selPos = r.index, r.btype, r.pos
	Ball.current(r.index, r.btype)
	dirty = true
end

function Ball.auto()
	if not B.sel or (pending ~= nil and pending.call == CALL_REACH) then
		return
	end
	B.sel, B.lost, B.autoIndex, B.autoType = false, false, -1, -1
	dirty = true
end

function Ball.setType(t: number)
	if pending ~= nil and pending.call == CALL_REACH then
		return
	end
	local v = if finite(t) then clamp(floor(t), -1, BALL.TYPE_MAX) else -1
	if v ~= prefs.ballType then
		prefs.ballType = v
		B.autoIndex, B.autoType = -1, -1
		unsaved = true
		dirty = true
	end
end

type MatchRead = {
	running: boolean,
	n: number,
	names: { string },
	roster: { [number]: number },
	count: number,
	s0: number,
	s1: number,
}
local function rawMatch(slot: string): MatchRead
	local data = SpectatorGamemodes.getGamemodeData(slot)
	local teams = data.teams
	local out: MatchRead = {
		running = data.isGameRunning == true,
		n = #teams,
		names = { "Team 1", "Team 2" },
		roster = {},
		count = 0,
		s0 = 0,
		s1 = 0,
	}
	for i = 1, min(#teams, 2) do
		local t = teams[i]
		local nm = t.teamColor.teamName
		if type(nm) == "string" and #nm > 0 then
			out.names[i] = nm
		end
		for _, p in t.players do
			out.roster[p.playerId] = i
			out.count += 1
		end
	end
	if #teams >= 2 then
		out.s0, out.s1 = teams[1].score, teams[2].score
	end
	return out
end

local function setArena(gm: ModuleStateSpectatorLuaApi?, slot: string, pos: Vec3?, rot: Quat?)
	arena = gm
	if pos ~= nil and rot ~= nil then
		arenaPos, arenaRot = pos, rot
	end
	if slot ~= arenaSlot then
		arenaSlot = slot
		scoreKnown = false
		lastGoal = ""
		teamCount = 0
		teamOf = {}
		rosterSize = 0
		matchReadOk = true
		B.sel, B.lost, B.autoIndex, B.autoType, B.curIndex, B.curType = false, false, -1, -1, -1, -1
		table.clear(B.rows)
		dirty = true
	end
end

type ArenaRead = { gm: ModuleStateSpectatorLuaApi, slot: string, pos: Vec3, rot: Quat, dist: number }
local function rawArenas(camPos: Vec3): { ArenaRead }
	local out: { ArenaRead } = {}
	for _, gm in SpectatorGamemodes.listGamemodes() do
		local slot = gm:getSlotId()
		if isDriftball(slot) then
			local pos = gm.transform.position
			local d = (pos - camPos):length()
			if not gm:getIsGameRunning() then
				d += 1e9
			end
			table.insert(out, { gm = gm, slot = slot, pos = pos, rot = gm.transform.rotation, dist = d })
		end
	end
	return out
end

local function scanArenas()
	local okCam, camPos = pcall(function(): Vec3
		return camera:getSmoothedPosition()
	end)
	local ok, list = pcall(rawArenas, if okCam then camPos else arenaPos)
	if not ok or type(list) ~= "table" then
		setArena(nil, "", nil, nil)
		return
	end
	local lockSlot = if pending then pending.slot else prefs.arena
	local keep: ArenaRead? = nil
	local best: ArenaRead? = nil
	local seen: { [string]: boolean } = {}
	local slots: { string } = {}
	for _, a in list do
		if not seen[a.slot] then
			seen[a.slot] = true
			table.insert(slots, a.slot)
			if a.slot == lockSlot then
				keep = a
			end
			if best == nil or a.dist < best.dist then
				best = a
			end
		end
	end
	local changed = #slots ~= #arenaChoices
	for i, slot in slots do
		if arenaChoices[i] ~= slot then
			changed = true
		end
	end
	if changed then
		arenaChoices = slots
		arenaLabels = {}
		for i, slot in slots do
			arenaLabels[i] = format("%s##%s", string.sub(slot, 5), slot)
		end
		dirty = true
	end
	if pending ~= nil and keep == nil then
		settle("void", "the arena is gone (left the match or switched server)")
	end
	local missing = lockSlot ~= "" and keep == nil
	if missing ~= arenaMissing then
		arenaMissing = missing
		dirty = true
	end
	local pickA = if lockSlot ~= "" then keep else best
	if pickA ~= nil then
		setArena(pickA.gm, pickA.slot, pickA.pos, pickA.rot)
	else
		setArena(nil, "", nil, nil)
	end
end

local function onGoal(t0: boolean, t1: boolean)
	lastGoal = if t0 and t1 then "both teams" elseif t0 then shownName[1] else shownName[2]
	dirty = true
	local b = pending
	if b == nil then
		return
	end
	if now < b.liveAt then
		settle("void", "goal while the call was locking in")
	elseif b.call == CALL_GOAL then
		if t0 and t1 then
			settle("void", "both scores changed at once")
		elseif (t0 and b.pick == 1) or (t1 and b.pick == 2) then
			settle("win", "")
		else
			settle("lose", "")
		end
	elseif b.call == CALL_WINDOW then
		settle(if b.pick == 1 then "win" else "lose", "")
	else
		settle("void", "a goal was scored before a clear reach")
	end
end

local function readMatch()
	if arena == nil or arenaSlot == "" then
		return
	end
	local ok, r = pcall(rawMatch, arenaSlot)
	if not ok or type(r) ~= "table" then
		if matchReadOk then
			matchReadOk = false
			running, teamCount, scoreKnown = false, 0, false
			dirty = true
		end
		return
	end
	if not matchReadOk then
		matchReadOk = true
		dirty = true
	end
	if r.running ~= running or r.n ~= teamCount or r.names[1] ~= teamName[1] or r.names[2] ~= teamName[2] or r.count ~= rosterSize then
		dirty = true
	end
	running, teamCount, teamName[1], teamName[2], rosterSize = r.running, r.n, r.names[1], r.names[2], r.count
	teamOf = r.roster
	if dirty then
		for i = 1, 2 do
			local nm = string.match(teamName[i], "^[Tt]eam:%s*(.+)$") or teamName[i]
			shownName[i] = nm
		end
	end
	local s0, s1 = r.s0, r.s1
	if teamCount < 2 or not finite(s0) or not finite(s1) then
		return
	end
	if not scoreKnown then
		score0, score1, scoreKnown = s0, s1, true
		dirty = true
		return
	end
	local d0, d1 = s0 - score0, s1 - score1
	if d0 == 0 and d1 == 0 then
		return
	end
	score0, score1 = s0, s1
	dirty = true
	if d0 < 0 or d1 < 0 then
		if pending ~= nil then
			settle("void", "the score was reset (new match)")
		end
	else
		onGoal(d0 > 0, d1 > 0)
	end
end

local function poll(elapsed: number)
	scanClock += elapsed
	local okSrv, srv = pcall(Network.getCurrentServer)
	if okSrv and type(srv) == "string" and srv ~= serverName then
		if serverKnown and pending ~= nil then
			settle("void", "the spectator switched server")
		end
		serverName, serverKnown = srv, true
		setArena(nil, "", nil, nil)
		scanClock = SCAN_INTERVAL
		dirty = true
	end
	if scanClock >= SCAN_INTERVAL then
		scanClock = 0
		scanArenas()
	end
	readMatch()
	local b = pending
	if b ~= nil then
		if running and arena ~= nil then
			idle = 0
		else
			idle += elapsed
			if b.call == CALL_WINDOW and now >= b.liveAt and idle >= WINDOW_IDLE_VOID then
				settle("void", "the match stopped during the window")
			elseif idle >= IDLE_VOID then
				settle("void", "the match stopped")
			end
		end
	end
end

local liveFrame: ReplayFrame? = nil
local liveBall: Vec3? = nil
local ballFound = false
local function fetchLive()
	local ok, f = pcall(getGameData)
	if ok and f then
		liveFrame = f
		local okBall, ball = pcall(Ball.track, f)
		liveBall = if okBall and arena ~= nil then ball else nil
	else
		liveFrame, liveBall = nil, nil
	end
	local found = liveBall ~= nil
	if found ~= ballFound then
		ballFound = found
		dirty = true
	end
end

local function checkReach(b: Bet)
	local f, ball = liveFrame, liveBall
	if f == nil or ball == nil then
		return
	end
	local r2 = REACH_CM * REACH_CM
	local near1, near2 = false, false
	for _, p in f.players do
		local team = teamOf[p.playerId]
		if team ~= nil then
			if
				(p.head.position - ball):squaredLength() <= r2
				or (p.leftHand.position - ball):squaredLength() <= r2
				or (p.rightHand.position - ball):squaredLength() <= r2
			then
				if team == 1 then
					near1 = true
				else
					near2 = true
				end
			end
		end
	end
	if not b.armed then
		if not near1 and not near2 then
			b.armed = true
		end
		return
	end
	if near1 and near2 then
		settle("void", "both teams reached the ball together")
	elseif near1 or near2 then
		local team = if near1 then 1 else 2
		settle(if team == b.pick then "win" else "lose", "")
	end
end

local function rebuildPendingStatus()
	local b = pending
	if b == nil then
		view.pendingStatus = ""
		return
	end
	if now < b.liveAt then
		view.pendingStatus = "Locking in..."
	elseif b.call == CALL_WINDOW then
		view.pendingStatus = format("Live: %d s left", max(shownSecs, 0))
	elseif b.call == CALL_REACH then
		view.pendingStatus = if b.armed
			then format("Live: first team to the ball (%d s left)", max(shownSecs, 0))
			else format("Live: waiting for the ball to be free (%d s left)", max(shownSecs, 0))
	else
		view.pendingStatus = "Live: waiting for the next goal"
	end
end

local function rebuildView()
	dirty = false
	local th = THEMES[THEME_AT[prefs.theme] or 1]
	view.accent = LinearColor.new(th.r, th.g, th.b, 1)
	local title = TITLES[TITLE_AT[prefs.title] or 1]
	view.header = format("%s Call It  |  %s", Icon.Bullseye, title.name)
	view.balance = format("Balance: %s pts", commas(P.balance))
	view.streak = format("Streak: %d  |  Best: %d  |  Bonus +%d%%", P.streak, P.best, floor(bonusFor(P.streak) * 100 + 0.5))
	view.record = format("Record: %s W / %s L / %s void  |  Won %s pts  |  Bailouts %s", commas(P.wins), commas(P.losses), commas(P.voids), commas(P.won), commas(P.bailouts))
	if prefs.arena ~= "" then
		local name = string.sub(prefs.arena, 5)
		view.arenaLine = if arenaMissing
			then format("Arena: %s (manual, not on this server)", name)
			else format("Arena: %s (manual)", name)
	elseif arena ~= nil then
		view.arenaLine = format("Arena: %s (auto: nearest running match)", string.sub(arenaSlot, 5))
	else
		view.arenaLine = "Arena: none (auto)"
	end
	if arena == nil then
		view.match = if serverKnown and serverName == "" then "Not connected to a server." else "No Driftball match to show."
	elseif not matchReadOk then
		view.match = "Match data unavailable right now."
	elseif teamCount < 2 then
		view.match = "Waiting for teams."
	else
		local state = if running then "Live" else "Stopped"
		local sc = if scoreKnown then format("%s %d - %d %s", shownName[1], score0, score1, shownName[2]) else "score unknown"
		view.match = format("%s: %s", state, sc)
		if lastGoal ~= "" then
			view.match = format("%s  |  last goal: %s", view.match, lastGoal)
		end
	end
	view.closed = openReason()
	view.cantAfford = P.balance < prefs.stake
	for i, s in STAKES do
		if not stakeOpen[i] then
			view.stakeLabel[i] = format("%s%s", L.LOCKED, commas(s.amount))
			view.stakeTip[i] = format("Unlocks at %s", goalText(s.kind, s.need))
		elseif s.amount == prefs.stake then
			view.stakeLabel[i] = format("[%s]", commas(s.amount))
			view.stakeTip[i] = "Current stake"
		else
			view.stakeLabel[i] = commas(s.amount)
			view.stakeTip[i] = "Use this stake"
		end
	end
	for c, def in CALLS do
		view.callTitle[c] = if c == focusCall then format("%s%s", L.FOCUS, def.title) else def.title
		for o = 1, 2 do
			local name = if def.teams then shownName[o] else def.options[o]
			local win = profitFor(prefs.stake, def.mult[o], P.streak)
			local mark = if c == focusCall and o == focusOpt then L.FOCUS else ""
			view.opt[c][o] = format("%sBet %s  x%.1f  (+%s)", mark, name, def.mult[o], commas(win))
		end
	end
	local b = pending
	if b ~= nil then
		local profit = profitFor(b.stake, b.mult, P.streak)
		view.pendingLine = format("%s  |  stake %s, win +%s", b.label, commas(b.stake), commas(profit))
		view.cancelLabel = format("Cancel call (refund %s)", commas(floor(b.stake * CANCEL_KEEP)))
	end
	rebuildPendingStatus()
	view.bailout = b == nil and P.balance < MIN_STAKE
	view.bailoutLabel = format("Claim bailout (+%s)", commas(BAILOUT_TO - P.balance))
	local open, total = 0, 0
	table.clear(view.unlockLines)
	local function add(isOpen: boolean, text: string)
		total += 1
		if isOpen then
			open += 1
		end
		table.insert(view.unlockLines, { text = text, colour = if isOpen then COL.WIN else COL.VOID })
	end
	for i, s in STAKES do
		if s.need > 0 then
			add(stakeOpen[i], format("%sStake %s  (%s)", if stakeOpen[i] then L.OPEN else L.LOCKED, commas(s.amount), goalText(s.kind, s.need)))
		end
	end
	for i, t in TITLES do
		if t.need > 0 then
			add(titleOpen[i], format("%sTitle: %s  (%s)", if titleOpen[i] then L.OPEN else L.LOCKED, t.name, goalText(t.kind, t.need)))
		end
	end
	for i, t in THEMES do
		if t.need > 0 then
			add(themeOpen[i], format("%sCard colour: %s  (%s)", if themeOpen[i] then L.OPEN else L.LOCKED, t.name, goalText(t.kind, t.need)))
		end
	end
	view.unlockCount = format("%d of %d unlocked", open, total)
	view.titlePreview = title.name
	view.themePreview = th.name
	view.arenaPreview = if prefs.arena == "" then L.AUTO else string.sub(prefs.arena, 5)
	view.reachOff = rosterSize == 0
	if B.curIndex >= 0 and not B.lost then
		view.ballLine = format(
			"Following ball #%g (type %g), %s",
			B.curIndex,
			B.curType,
			if B.sel then "your pick" else "Auto"
		)
	elseif B.sel and B.lost then
		view.ballLine = format(
			"Your pick, ball #%g (type %g): lost, still searching (%d s, then Auto)",
			B.selIndex,
			B.selType,
			max(B.lostShown, 0)
		)
	else
		view.ballLine = L.BALL_NONE
	end
	view.ballPref = if prefs.ballType >= 0
		then format("Auto prefers type %g (saved with Save).", prefs.ballType)
		else "Auto has no preferred type: it follows the ball nearest the centre."
	for i, r in B.rows do
		local isCur = r.index == B.curIndex and r.btype == B.curType
		view.ballRow[i] = format(
			"Ball #%g   type %g   size %.2f%s",
			r.index,
			r.btype,
			r.size,
			if isCur then (if B.sel then "   <- following (your pick)" else "   <- following (Auto)") else ""
		)
		view.ballTypeBtn[i] = format("Always follow type %g", r.btype)
	end
	for i = #view.ballRow, #B.rows + 1, -1 do
		view.ballRow[i] = nil
		view.ballTypeBtn[i] = nil
	end
	view.timerState = if T.on then "running" elseif T.acc > 0 then "stopped" else "not started"
	view.followWarn = if followClip > 0
		then format(
			"The camera you are following hides everything closer than %d m (that camera's own setting). "
				.. "The official Sideline Camera does this in its top-down 'pick a ball' view: click a ball in it, "
				.. "or use Call It's Sideline or Arena overview view.",
			followClip
		)
		else ""
	local msg = statusMsg
	if unsaved then
		msg = if msg == "" then "Unsaved changes. Press Save to keep them." else format("%s  Unsaved changes.", msg)
	end
	view.saveLine = msg
end

local function applyFollow()
	followApplied = true
	local ok, target = pcall(getCameraById, prefs.followId)
	if ok and target and target ~= camera then
		camera:followCamera(target)
		following = true
		followTarget = target
		followMsg = format("Following %s.", prefs.followId)
	else
		if following then
			camera:followCamera(nil)
			following = false
		end
		followTarget = nil
		followMsg = format("Camera not found: %s", prefs.followId)
	end
	dirty = true
end

local function stopFollow()
	if following then
		camera:followCamera(nil)
		following = false
	end
	followTarget = nil
	followApplied = false
	if followClip ~= 0 then
		followClip = 0
		dirty = true
	end
end

local function readFollowClip()
	local t = followTarget
	local m = 0
	if t ~= nil then
		local ok, near = pcall(function(): number
			return t.nearClippingPlane
		end)
		if ok and finite(near) and near > FOLLOW_CLIP_WARN then
			m = max(1, floor(near / 100 + 0.5))
		end
	end
	if m ~= followClip then
		followClip = m
		dirty = true
	end
end

local function keepClean()
	if camera.positionSmoothing ~= 0 then
		camera.positionSmoothing = 0
	end
	if camera.rotationSmoothing ~= 0 then
		camera.rotationSmoothing = 0
	end
	if camera.fieldOfViewSmoothing ~= 0 then
		camera.fieldOfViewSmoothing = 0
	end
	if camera.nearClippingPlane ~= NEAR_CLIP then
		camera.nearClippingPlane = NEAR_CLIP
	end
	if camera.hideNearestHead then
		camera.hideNearestHead = false
	end
end

local function audioNudge(base: Vec3)
	audioFlip = 1 - audioFlip
	camera.rotation = camera.rotation
	camera.position = if audioFlip == 1 then base + camera.rotation:getForwardVector() * AUDIO_NUDGE else base
end

function OSD.ease(dt: number, half: number): number
	return 1 - 0.5 ^ (dt / half)
end

local function driveCamera(dt: number)
	local v = prefs.view
	if v == VIEW_FOLLOW then
		if not followApplied then
			applyFollow()
		end
		if not following then
			keepClean()
		end
		return
	end
	stopFollow()
	keepClean()
	if not SM.init then
		SM.init, SM.pos, SM.rot, SM.fov = true, camera.position, camera.rotation, camera.fieldOfView
	end
	if v == VIEW_NONE then
		if not viewApplied then
			viewApplied = true
			holdPos, SM.rot, SM.fov = SM.pos, camera.rotation, camera.fieldOfView
		end
		SM.pos = holdPos
		audioNudge(holdPos)
		return
	end
	if arena == nil then
		return
	end
	viewApplied = true
	local up = arenaRot:getUpVector()
	local base: Vec3, target: Vec3, fovT: number
	if v == VIEW_OVERVIEW then
		base = arenaPos + arenaRot:rotateVector(OVERVIEW_SPOT)
		target, fovT = arenaPos + arenaRot:rotateVector(OVERVIEW_LOOK), OVERVIEW_FOV
	else
		target = liveBall or (if B.sel then B.selPos else arenaPos + up * 300)
		local l = arenaRot:inverse():rotateVector(target - arenaPos)
		local spot = V(SIDELINE_X, clamp(l.y * 0.75, -SIDELINE_MAX_Y, SIDELINE_MAX_Y), prefs.sideZ)
		base, fovT = arenaPos + arenaRot:rotateVector(spot), SIDELINE_FOV
	end
	camera.position = base
	camera:lookAt(target, up)
	local rotT = camera.rotation
	if (base - SM.pos):length() > OSDK.SNAP_CM then
		SM.pos, SM.rot, SM.fov = base, rotT, fovT
	else
		SM.pos = SM.pos + (base - SM.pos) * OSD.ease(dt, OSDK.HALF_POS)
		SM.rot = Quat.slerp(SM.rot, rotT, OSD.ease(dt, OSDK.HALF_ROT))
		SM.fov += (fovT - SM.fov) * OSD.ease(dt, OSDK.HALF_FOV)
	end
	camera.rotation = SM.rot
	if camera.fieldOfView ~= SM.fov then
		camera.fieldOfView = SM.fov
	end
	audioNudge(SM.pos)
end

OSD.font = {} :: { [number]: { number } }
for ch: string, def: string in OSDK.FONT :: { [string]: string } do
	local segs: { number } = {}
	for stroke in string.gmatch(def, "%d+") do
		for i = 1, #stroke - 3, 2 do
			for k = 0, 3 do
				table.insert(segs, tonumber(string.sub(stroke, i + k, i + k)) :: number)
			end
		end
	end
	OSD.font[string.byte(ch)] = segs
end

function OSD.setText(t: OsdText, s: string)
	if s == t.s then
		return
	end
	t.s = s
	local segs = t.segs
	table.clear(segs)
	local n, x, G = 0, 0, OSDK.GLYPH
	for i = 1, #s do
		local b = string.byte(s, i)
		if b < 128 or b >= 192 then
			if b >= 97 and b <= 122 then
				b -= 32
			end
			local g = OSD.font[b]
			if g == nil and b ~= 32 then
				g = OSD.font[63]
			end
			if g ~= nil then
				for k = 1, #g, 4 do
					segs[n + 1], segs[n + 2], segs[n + 3], segs[n + 4] = x + g[k] * G, g[k + 1] * G, x + g[k + 2] * G, g[k + 3] * G
					n += 4
				end
			end
			x += OSDK.ADV
		end
	end
	t.w = max(0, x - (OSDK.ADV - 4 * G))
end

function OSD.secs(pre: string, n: number, post: string): string
	if n < 60 then
		return format("%s%d%s", pre, n, post)
	end
	return format("%s%d:%02d%s", pre, floor(n / 60), n % 60, post)
end

function OSD.clip(s: string, maxc: number): string
	local c = 0
	for i = 1, #s do
		local b = string.byte(s, i)
		if b < 128 or b >= 192 then
			c += 1
			if c > maxc then
				return string.sub(s, 1, i - 1)
			end
		end
	end
	return s
end

function OSD.col(r: number, g: number, b: number, a: number): LinearColor
	return LinearColor.new(r, g, b, 1 - math.sqrt(1 - clamp(a, 0, 1)))
end

OSD.setText(O.t.title, "CALL IT")
OSD.setText(O.t.balL, "BALANCE")
OSD.setText(O.t.recL, "RECORD")
OSD.setText(O.t.betL, "BET")
OSD.setText(O.t.lastL, "LAST")
OSD.setText(O.t.timerL, "TIMER")

function OSD.refresh()
	local k, t = O.k, O.t
	local ti = TITLES[TITLE_AT[prefs.title] or 1]
	if ti.name ~= k.title then
		k.title = ti.name
		OSD.setText(t.rank, OSD.clip(ti.name, OSDK.RANK_MAX))
	end
	if P.balance ~= k.bal then
		k.bal = P.balance
		local s = commas(P.balance)
		OSD.setText(t.bal, if #s <= OSDK.BAL_PTS_MAX then format("%s PTS", s) else s)
	end
	if P.streak ~= k.streak then
		k.streak = P.streak
		local pct = floor(bonusFor(P.streak) * 100 + 0.5)
		OSD.setText(t.streak, if pct > 0 then format("STREAK %d  +%d%%", P.streak, pct) else format("STREAK %d", P.streak))
	end
	if P.best ~= k.best then
		k.best = P.best
		OSD.setText(t.best, format("BEST %d", P.best))
	end
	if P.wins ~= k.w or P.losses ~= k.l or P.voids ~= k.v then
		k.w, k.l, k.v = P.wins, P.losses, P.voids
		OSD.setText(t.rec, format("%d W  %d L  %d V", P.wins, P.losses, P.voids))
	end
	local b = pending
	if b == nil then
		if k.call ~= 0 then
			k.call, k.opt = 0, "\0"
			OSD.setText(t.betS, "NONE")
			OSD.setText(t.bet, "")
		end
	else
		local def = CALLS[b.call]
		local opt = if def.teams then shownName[b.pick] or "?" else def.options[b.pick] or "?"
		if opt ~= k.opt or b.stake ~= k.stake or b.mult ~= k.mult or b.call ~= k.call then
			k.opt, k.stake, k.mult = opt, b.stake, b.mult
			OSD.setText(t.bet, format("%s X%.1f  %s PTS", OSD.clip(opt, OSDK.OPT_MAX), b.mult, commas(b.stake)))
		end
		if b.call ~= k.call or shownSecs ~= k.secs or shownLocking ~= k.lock or b.armed ~= k.armed then
			k.call, k.secs, k.lock, k.armed = b.call, shownSecs, shownLocking, b.armed
			local secs = max(shownSecs, 0)
			OSD.setText(t.betS, if shownLocking then "LOCKING"
				elseif b.call == CALL_GOAL then "NEXT GOAL"
				elseif b.call == CALL_REACH and not b.armed then OSD.secs("WAIT ", secs, "")
				else OSD.secs("", secs, " LEFT"))
		end
	end
	if O.lastGen ~= k.last then
		k.last = O.lastGen
		local c = O.lastCol
		if O.lastKind == 1 then
			OSD.setText(t.last, format("WIN +%s", commas(O.lastAmt)))
			c[1], c[2], c[3] = OSDK.GREEN[1], OSDK.GREEN[2], OSDK.GREEN[3]
		elseif O.lastKind == 2 then
			OSD.setText(t.last, format("LOSS -%s", commas(O.lastAmt)))
			c[1], c[2], c[3] = OSDK.RED[1], OSDK.RED[2], OSDK.RED[3]
		elseif O.lastKind == 3 then
			OSD.setText(t.last, format("VOID  REFUND %s", commas(O.lastAmt)))
			c[1], c[2], c[3] = OSDK.GREY[1], OSDK.GREY[2], OSDK.GREY[3]
		else
			OSD.setText(t.last, "-")
			c[1], c[2], c[3] = OSDK.GREY[1], OSDK.GREY[2], OSDK.GREY[3]
		end
	end
	if T.on and view.timer ~= k.timer then
		k.timer = view.timer
		OSD.setText(t.timer, view.timer)
	end
end

function OSD.frame()
	local rot = camera.rotation
	O.org, O.f, O.r, O.u = camera.position, rot:getForwardVector(), rot:getRightVector(), rot:getUpVector()
	local fov = camera:getSmoothedFieldOfView()
	if not finite(fov) then
		fov = camera.fieldOfView
	end
	O.hs = math.tan(math.rad(clamp(fov, 1, 170)) / 2) / OSDK.DESIGN_TAN * OSDK.HUD_UNIT
	O.hx, O.hy = OSDK.HUD_HALF, OSDK.HUD_HALF / prefs.osdAspect
	O.c = O.hy / (OSDK.LINES_H / 2)
end

function OSD.hudLine(x1: number, y1: number, x2: number, y2: number, width: number, r: number, g: number, b: number, depth: number?)
	local d = depth or OSDK.HUD_DEPTH
	local k = O.hs * d / OSDK.HUD_DEPTH
	local base = O.org + O.f * d
	WorldDraw.drawLine(base + O.r * (x1 * k) - O.u * (y1 * k), base + O.r * (x2 * k) - O.u * (y2 * k), r, g, b, width * O.hs, OSDK.LIFE)
end

function OSD.hudPoint(x: number, y: number, d: number): Vec3
	local k = O.hs * d / OSDK.HUD_DEPTH
	return O.org + O.f * d + O.r * (x * k) - O.u * (y * k)
end

function OSD.line(x1: number, y1: number, x2: number, y2: number, r: number, g: number, b: number, wpx: number)
	local q = O.q
	OSD.hudLine(O.x0 + x1 * q, O.y0 + y1 * q, O.x0 + x2 * q, O.y0 + y2 * q, wpx * q, r, g, b)
end

function OSD.quad(x1: number, y1: number, x2: number, y2: number, c: LinearColor, back: number)
	local q, d = O.q, OSDK.HUD_DEPTH + back * O.hs
	local ax, ay, bx, by = O.x0 + x1 * q, O.y0 + y1 * q, O.x0 + x2 * q, O.y0 + y2 * q
	local p1, p2, p3, p4 = OSD.hudPoint(ax, ay, d), OSD.hudPoint(bx, ay, d), OSD.hudPoint(bx, by, d), OSD.hudPoint(ax, by, d)
	WorldDraw.drawTriangle(p1, p2, p3, c, OSDK.LIFE)
	WorldDraw.drawTriangle(p1, p3, p4, c, OSDK.LIFE)
	WorldDraw.drawTriangle(p1, p3, p2, c, OSDK.LIFE)
	WorldDraw.drawTriangle(p1, p4, p3, c, OSDK.LIFE)
end

function OSD.text(t: OsdText, x: number, y: number, r: number, g: number, b: number, z: number)
	local segs, w = t.segs, OSDK.TEXT_PX * z
	for k = 1, #segs, 4 do
		OSD.line(x + segs[k] * z, y + segs[k + 1] * z, x + segs[k + 2] * z, y + segs[k + 3] * z, r, g, b, w)
	end
end

function OSD.draw()
	local W, mpx = OSDK.W, prefs.osdMargin
	local h = if T.on then OSDK.H_TIMER else OSDK.H
	local wpx = OSDK.LINES_H * O.hx / O.hy
	local s = max(min(prefs.osdScale, (OSDK.LINES_H - 2 * mpx) / h, (wpx - 2 * mpx) / W), 0.05)
	O.q = s * O.c
	O.x0 = O.hx - (mpx + W * s) * O.c
	O.y0 = -O.hy + mpx * O.c
	local t = O.t
	local th = THEMES[THEME_AT[prefs.theme] or 1]
	local ar, ag, ab = th.r, th.g, th.b
	local lr, lg, lb = OSDK.GREY[1], OSDK.GREY[2], OSDK.GREY[3]
	local x1, x2 = OSDK.PAD, W - OSDK.PAD
	if O.bgA ~= prefs.osdAlpha then
		O.bgA = prefs.osdAlpha
		O.bg = OSD.col(0.02, 0.03, 0.06, O.bgA)
	end
	if O.bgA > 0 then
		OSD.quad(0, 0, W, h, O.bg, OSDK.BACK_UNITS)
	end
	local br, bg, bb = ar, ag, ab
	local fl = now - O.flashAt
	if fl >= 0 and fl < OSDK.FLASH then
		local fc = O.flashCol
		local a = (0.16 + 0.14 * math.abs(math.sin(fl * 6))) * (1 - fl / OSDK.FLASH)
		OSD.quad(OSDK.BORDER_PX, O.flashRow - 6, W - OSDK.BORDER_PX, O.flashRow + 21, OSD.col(fc[1], fc[2], fc[3], a), OSDK.MID_UNITS)
		if floor(fl * 3) % 2 == 0 then
			br, bg, bb = fc[1], fc[2], fc[3]
		end
	end
	local bw = OSDK.BORDER_PX
	OSD.line(0, 0, W, 0, br, bg, bb, bw)
	OSD.line(W, 0, W, h, br, bg, bb, bw)
	OSD.line(W, h, 0, h, br, bg, bb, bw)
	OSD.line(0, h, 0, 0, br, bg, bb, bw)
	OSD.text(t.title, x1, OSDK.Y_TITLE, ar, ag, ab, 1)
	OSD.text(t.rank, x2 - t.rank.w, OSDK.Y_TITLE, ar, ag, ab, 1)
	OSD.line(x1, OSDK.Y_SEP, x2, OSDK.Y_SEP, ar, ag, ab, OSDK.SEP_PX)
	OSD.text(t.balL, x1, OSDK.Y_BAL + 6, lr, lg, lb, 1)
	OSD.text(t.bal, x2 - t.bal.w * OSDK.BIG, OSDK.Y_BAL, 1, 1, 1, OSDK.BIG)
	OSD.text(t.streak, x1, OSDK.Y_STREAK, 1, 1, 1, 1)
	OSD.text(t.best, x2 - t.best.w, OSDK.Y_STREAK, lr, lg, lb, 1)
	OSD.text(t.recL, x1, OSDK.Y_REC, lr, lg, lb, 1)
	OSD.text(t.rec, x2 - t.rec.w, OSDK.Y_REC, 1, 1, 1, 1)
	OSD.text(t.betL, x1, OSDK.Y_BET, lr, lg, lb, 1)
	if pending ~= nil then
		OSD.text(t.betS, x2 - t.betS.w, OSDK.Y_BET, ar, ag, ab, 1)
		OSD.text(t.bet, x1, OSDK.Y_BET2, 1, 1, 1, 1)
	else
		OSD.text(t.betS, x2 - t.betS.w, OSDK.Y_BET, lr, lg, lb, 1)
	end
	local c = O.lastCol
	OSD.text(t.lastL, x1, OSDK.Y_LAST, lr, lg, lb, 1)
	OSD.text(t.last, x2 - t.last.w, OSDK.Y_LAST, c[1], c[2], c[3], 1)
	if T.on then
		OSD.text(t.timerL, x1, OSDK.Y_TIMER, lr, lg, lb, 1)
		OSD.text(t.timer, x2 - t.timer.w, OSDK.Y_TIMER, 1, 1, 1, 1)
	end
end

function OSD.update(active: boolean): boolean
	local show = (active or camera.isFollowed == true) and not (prefs.view == VIEW_FOLLOW and following)
	if show and prefs.osd then
		if now >= O.nextRefresh then
			O.nextRefresh = now + OSDK.REFRESH
			OSD.refresh()
		end
		WorldDraw.clear()
		OSD.frame()
		OSD.draw()
	end
	return true
end

local NUM_KEYS = { Input.Key.One, Input.Key.Two, Input.Key.Three, Input.Key.Four, Input.Key.Five, Input.Key.Six }
local PAD_KEYS = {
	Input.Key.NumPadOne,
	Input.Key.NumPadTwo,
	Input.Key.NumPadThree,
	Input.Key.NumPadFour,
	Input.Key.NumPadFive,
	Input.Key.NumPadSix,
}

local function setFocus(c: number, o: number)
	if c ~= focusCall or o ~= focusOpt then
		focusCall, focusOpt = c, o
		dirty = true
	end
end

local function readInputs()
	if prefs.hotkeys and now >= typingUntil then
		for k = 1, 6 do
			if Input.getKeyDown(NUM_KEYS[k]) or Input.getKeyDown(PAD_KEYS[k]) then
				local c, o = floor((k + 1) / 2), 2 - k % 2
				setFocus(c, o)
				placeBet(c, o)
			end
		end
		if Input.getKeyDown(Input.Key.Hyphen) or Input.getKeyDown(Input.Key.Subtract) then
			stepStake(-1)
		end
		if Input.getKeyDown(Input.Key.Equals) or Input.getKeyDown(Input.Key.Add) then
			stepStake(1)
		end
	end
	if prefs.gamepad then
		if Input.getKeyDown(Input.Gamepad.DPad_Up) then
			setFocus((focusCall - 2) % #CALLS + 1, focusOpt)
		end
		if Input.getKeyDown(Input.Gamepad.DPad_Down) then
			setFocus(focusCall % #CALLS + 1, focusOpt)
		end
		if Input.getKeyDown(Input.Gamepad.DPad_Left) then
			setFocus(focusCall, 1)
		end
		if Input.getKeyDown(Input.Gamepad.DPad_Right) then
			setFocus(focusCall, 2)
		end
		if Input.getKeyDown(Input.Gamepad.FaceButton_Bottom) then
			placeBet(focusCall, focusOpt)
		end
		if Input.getKeyDown(Input.Gamepad.LeftShoulder) then
			stepStake(-1)
		end
		if Input.getKeyDown(Input.Gamepad.RightShoulder) then
			stepStake(1)
		end
	end
end

loadFrom(config)

function tick(dt: number)
	local step = if finite(dt) then clamp(dt, 0, MAX_DT) else 0
	now += step
	pollClock += step
	if pollClock >= POLL_INTERVAL then
		local elapsed = pollClock
		pollClock = 0
		poll(elapsed)
		readFollowClip()
		Clock.refresh()
	end
	local active = camera.isActive == true
	local b = pending
	local needLive = (b ~= nil and b.call == CALL_REACH and now >= b.liveAt) or (active and arena ~= nil)
	if needLive then
		fetchLive()
	else
		liveFrame, liveBall = nil, nil
	end
	if B.lost then
		local left = ceil(BALL.LOST_GRACE - (now - B.lostAt))
		if left ~= B.lostShown then
			B.lostShown = left
			dirty = true
		end
	end
	if now >= B.nextList and now - B.guiSeen < 0.5 then
		B.nextList = now + BALL.LIST_INTERVAL
		local f = liveFrame
		if f == nil then
			local ok, g = pcall(getGameData)
			f = if ok then g else nil
		end
		if f ~= nil then
			pcall(Ball.scanRows, f)
		end
	end
	if b ~= nil then
		if now >= b.deadline then
			if b.call == CALL_WINDOW then
				settle(if b.pick == 2 then "win" else "lose", "")
			else
				settle("void", "no clear reach in time")
			end
		elseif b.call == CALL_REACH and now >= b.liveAt then
			checkReach(b)
		end
	end
	local p = pending
	if p ~= nil then
		local secs = if p.deadline < HUGE then ceil(p.deadline - now) else -1
		local locking = now < p.liveAt
		if secs ~= shownSecs or locking ~= shownLocking or p.armed ~= shownArmed then
			shownSecs, shownLocking, shownArmed = secs, locking, p.armed
			rebuildPendingStatus()
		end
	end
	if active ~= wasActive then
		wasActive = active
		viewApplied = false
		if active then
			followApplied = false
		else
			stopFollow()
		end
	end
	if active then
		if not paused then
			readInputs()
		end
		driveCamera(step)
	end
	pcall(OSD.update, active)
end

function onTransitionBegin(transitionInfo: Transition)
	keepClean()
	viewApplied = false
end

function onConfigChanged()
	local d = if type(config) == "table" then config[SAVE_KEY] else nil
	local mine = lastSaved
	if mine ~= nil and type(d) == "table" then
		local same = true
		for k, v in mine do
			if d[k] ~= v then
				same = false
			end
		end
		for k in d do
			if mine[k] == nil then
				same = false
			end
		end
		if same then
			return
		end
	end
	pending = nil
	idle = 0
	loadFrom(config)
	unsaved = false
	statusMsg = "Config changed outside the game: progress reloaded."
	pushRecent("Progress reloaded from config.", COL.INFO)
end

local function uiHeader()
	Gui.textColored(view.accent, view.header)
	Gui.sameLine()
	Gui.textDisabled(BUILD_TAG)
	Gui.separatorText(L.BANK)
	Gui.textColored(view.accent, view.balance)
	Gui.text(view.streak)
	Gui.textDisabled(view.record)
end

local function uiMatch()
	Gui.separatorText(L.MATCH)
	Gui.text(view.match)
end

local function uiStakes()
	Gui.text(L.STAKE)
	for i, s in STAKES do
		Gui.sameLine()
		Gui.pushId(STAKE_IDS[i])
		if stakeOpen[i] then
			if Gui.smallButton(view.stakeLabel[i]) then
				setStake(s.amount)
			end
		else
			Gui.textDisabled(view.stakeLabel[i])
		end
		Gui.setItemTooltip(view.stakeTip[i])
		Gui.popId()
	end
end

local function uiCalls()
	Gui.separatorText(L.CALLS)
	uiStakes()
	local reason = view.closed
	if reason ~= nil then
		Gui.textColored(COL.WARN, reason)
	end
	local blocked = reason ~= nil or view.cantAfford
	if reason == nil and view.cantAfford then
		Gui.textColored(COL.WARN, "Not enough points for this stake. Pick a smaller one.")
	end
	for c, def in CALLS do
		Gui.pushId(CALL_IDS[c])
		Gui.text(view.callTitle[c])
		Gui.setItemTooltip(def.help)
		local off = blocked or (c == CALL_REACH and view.reachOff)
		if off then
			Gui.beginDisabled()
		end
		for o = 1, 2 do
			if o > 1 then
				Gui.sameLine()
			end
			if Gui.button(view.opt[c][o]) then
				setFocus(c, o)
				placeBet(c, o)
			end
		end
		if off then
			Gui.endDisabled()
		end
		if c == CALL_REACH and view.reachOff then
			Gui.textDisabled(L.REACH_OFF)
		end
		Gui.popId()
	end
end

local function uiPending()
	Gui.separatorText(L.YOURS)
	if pending ~= nil then
		Gui.textColored(view.accent, view.pendingLine)
		Gui.text(view.pendingStatus)
		if Gui.smallButton(view.cancelLabel) then
			cancelBet()
		end
		Gui.setItemTooltip("Gives back half the stake. Goals during lock-in, resets and server switches refund in full automatically.")
	else
		Gui.textDisabled(L.NO_CALL)
	end
	if view.bailout then
		if Gui.button(view.bailoutLabel) then
			claimBailout()
		end
	end
end

local function uiArenaBall()
	if not Gui.collapsingHeader(L.ARENA_BALL) then
		return
	end
	Gui.text(view.arenaLine)
	if pending ~= nil then
		Gui.beginDisabled()
	end
	local arenaOpen = Gui.beginCombo(L.ARENA, view.arenaPreview)
	if not arenaOpen then
		Gui.setItemTooltip(if pending ~= nil then L.ARENA_LOCKED else L.ARENA_TIP)
	else
		if Gui.selectable(L.AUTO, prefs.arena == "") and prefs.arena ~= "" then
			prefs.arena = ""
			scanClock = SCAN_INTERVAL
			unsaved = true
			dirty = true
		end
		for i, slot in arenaChoices do
			if Gui.selectable(arenaLabels[i], prefs.arena == slot) and prefs.arena ~= slot then
				prefs.arena = slot
				scanClock = SCAN_INTERVAL
				unsaved = true
				dirty = true
			end
		end
		Gui.endCombo()
	end
	if pending ~= nil then
		Gui.endDisabled()
	end
	Gui.separatorText(L.BALLS)
	Gui.text(view.ballLine)
	Gui.textDisabled(view.ballPref)
	local locked = pending ~= nil and pending.call == CALL_REACH
	if locked then
		Gui.textDisabled(L.BALL_LOCKED)
		Gui.beginDisabled()
	end
	if Gui.selectable(L.BALL_AUTO, not B.sel) then
		Ball.auto()
	end
	for i, r in B.rows do
		local label = view.ballRow[i]
		local tlabel = view.ballTypeBtn[i]
		if label ~= nil and tlabel ~= nil then
			Gui.pushId(ROW_IDS[i])
			if Gui.selectable(label, B.sel and r.index == B.selIndex and r.btype == B.selType) then
				Ball.pick(i)
			end
			Gui.sameLine()
			if Gui.smallButton(tlabel) then
				Ball.setType(r.btype)
			end
			Gui.popId()
		end
	end
	if prefs.ballType >= 0 and Gui.smallButton(L.BALL_CLEAR) then
		Ball.setType(-1)
	end
	if locked then
		Gui.endDisabled()
	end
end

local function uiTimer()
	Gui.separatorText(L.TIMER)
	Gui.text(view.timer)
	Gui.sameLine()
	Gui.textDisabled(view.timerState)
	if T.on then
		if Gui.button(L.TIMER_STOP) then
			timerStop()
		end
	else
		if Gui.button(L.TIMER_START) then
			timerStart()
		end
		if T.acc > 0 then
			Gui.sameLine()
			if Gui.button(L.TIMER_RESET) then
				Clock.reset()
			end
		end
	end
	Gui.textDisabled(L.TIMER_NOTE)
end

local function uiRecent()
	Gui.separatorText(L.RECENT)
	if #recent == 0 then
		Gui.textDisabled(L.NO_RECENT)
	end
	for _, line in recent do
		Gui.textColored(line.colour, line.text)
	end
end

local function uiUnlocks()
	if not Gui.collapsingHeader(L.UNLOCKS) then
		return
	end
	Gui.text(view.unlockCount)
	if Gui.beginCombo(L.TITLE, view.titlePreview) then
		for i, t in TITLES do
			if titleOpen[i] and Gui.selectable(t.name, prefs.title == t.id) and prefs.title ~= t.id then
				prefs.title = t.id
				unsaved = true
				dirty = true
			end
		end
		Gui.endCombo()
	end
	if Gui.beginCombo(L.THEME, view.themePreview) then
		for i, t in THEMES do
			if themeOpen[i] and Gui.selectable(t.name, prefs.theme == t.id) and prefs.theme ~= t.id then
				prefs.theme = t.id
				unsaved = true
				dirty = true
			end
		end
		Gui.endCombo()
	end
	for _, line in view.unlockLines do
		Gui.textColored(line.colour, line.text)
	end
end

local function uiOsdSettings()
	Gui.separatorText(L.OSD)
	local on = Gui.checkbox(L.OSD_ON, prefs.osd)
	if on ~= prefs.osd then
		prefs.osd = on
		unsaved = true
		dirty = true
	end
	if not prefs.osd then
		return
	end
	local v = Gui.sliderFloat(L.OSD_SCALE, prefs.osdScale, OSDK.SCALE.MIN, OSDK.SCALE.MAX)
	if finite(v) and v ~= prefs.osdScale then
		prefs.osdScale = clamp(floor(v * 100 + 0.5) / 100, OSDK.SCALE.MIN, OSDK.SCALE.MAX)
		unsaved = true
	end
	Gui.sameLine()
	if Gui.button(L.OSD_SCALE_RESET) and prefs.osdScale ~= OSDK.SCALE.DEFAULT then
		prefs.osdScale = OSDK.SCALE.DEFAULT
		unsaved = true
	end
	Gui.setItemTooltip(L.OSD_SCALE_TIP)
	v = Gui.sliderFloat(L.OSD_ALPHA, prefs.osdAlpha, OSDK.ALPHA.MIN, OSDK.ALPHA.MAX)
	if finite(v) and v ~= prefs.osdAlpha then
		prefs.osdAlpha = clamp(floor(v * 100 + 0.5) / 100, OSDK.ALPHA.MIN, OSDK.ALPHA.MAX)
		unsaved = true
	end
	Gui.sameLine()
	if Gui.button(L.OSD_ALPHA_RESET) and prefs.osdAlpha ~= OSDK.ALPHA.DEFAULT then
		prefs.osdAlpha = OSDK.ALPHA.DEFAULT
		unsaved = true
	end
	Gui.setItemTooltip(L.OSD_ALPHA_TIP)
	v = Gui.sliderFloat(L.OSD_MARGIN, prefs.osdMargin, OSDK.MARGIN.MIN, OSDK.MARGIN.MAX)
	if finite(v) and v ~= prefs.osdMargin then
		prefs.osdMargin = clamp(floor(v + 0.5), OSDK.MARGIN.MIN, OSDK.MARGIN.MAX)
		unsaved = true
	end
	Gui.sameLine()
	if Gui.button(L.OSD_MARGIN_RESET) and prefs.osdMargin ~= OSDK.MARGIN.DEFAULT then
		prefs.osdMargin = OSDK.MARGIN.DEFAULT
		unsaved = true
	end
	Gui.setItemTooltip(L.OSD_MARGIN_TIP)
	v = Gui.sliderFloat(L.OSD_ASPECT, prefs.osdAspect, OSDK.ASPECT.MIN, OSDK.ASPECT.MAX)
	if finite(v) and v ~= prefs.osdAspect then
		prefs.osdAspect = clamp(floor(v * 100 + 0.5) / 100, OSDK.ASPECT.MIN, OSDK.ASPECT.MAX)
		unsaved = true
	end
	Gui.sameLine()
	if Gui.button(L.OSD_ASPECT_RESET) and prefs.osdAspect ~= OSDK.ASPECT.DEFAULT then
		prefs.osdAspect = OSDK.ASPECT.DEFAULT
		unsaved = true
	end
	Gui.setItemTooltip(L.OSD_ASPECT_TIP)
	Gui.textDisabled(L.OSD_NOTE)
end

local function uiSettings()
	if not Gui.collapsingHeader(L.SETTINGS) then
		return
	end
	if Gui.beginCombo(L.VIEW, VIEWS[prefs.view]) then
		for i, name in VIEWS do
			if Gui.selectable(name, prefs.view == i) and prefs.view ~= i then
				prefs.view = i
				viewApplied = false
				followApplied = false
				unsaved = true
				dirty = true
			end
		end
		Gui.endCombo()
	end
	local z = Gui.sliderFloat(L.SIDE_Z, prefs.sideZ, SIDE_Z.MIN, SIDE_Z.MAX)
	if finite(z) and floor(z + 0.5) ~= prefs.sideZ then
		prefs.sideZ = clamp(floor(z + 0.5), SIDE_Z.MIN, SIDE_Z.MAX)
		unsaved = true
	end
	Gui.sameLine()
	if Gui.button(L.SIDE_Z_RESET) and prefs.sideZ ~= SIDE_Z.DEFAULT then
		prefs.sideZ = SIDE_Z.DEFAULT
		unsaved = true
	end
	Gui.setItemTooltip("Reset to 400 cm")
	uiOsdSettings()
	if prefs.view == VIEW_FOLLOW then
		followEdit = Gui.inputText(L.FOLLOW_ID, followEdit)
		if Gui.isItemActive() then
			typingUntil = now + 0.25
		end
		Gui.sameLine()
		if Gui.button(L.FOLLOW_APPLY) and #followEdit > 0 and #followEdit <= FOLLOW_ID_MAX then
			prefs.followId = followEdit
			followApplied = false
			unsaved = true
			dirty = true
		end
		if followMsg ~= "" then
			Gui.textDisabled(followMsg)
		end
		if view.followWarn ~= "" then
			Gui.textColored(COL.WARN, view.followWarn)
		end
	end
	local hk = Gui.checkbox(L.HOTKEYS, prefs.hotkeys)
	if hk ~= prefs.hotkeys then
		prefs.hotkeys = hk
		unsaved = true
		dirty = true
	end
	Gui.textDisabled(L.HELP_KEYS)
	local gp = Gui.checkbox(L.GAMEPAD, prefs.gamepad)
	if gp ~= prefs.gamepad then
		prefs.gamepad = gp
		unsaved = true
		dirty = true
	end
	Gui.textDisabled(L.HELP_PAD)
	Gui.textWrapped(L.HELP_CARD)
end

local function uiFooter()
	Gui.separator()
	if Gui.button(L.SAVE) then
		doSave()
	end
	Gui.sameLine()
	if paused then
		if Gui.button(L.RESUME) then
			paused = false
			statusMsg = ""
			dirty = true
		end
	elseif Gui.button(L.QUIT) then
		if pending ~= nil then
			settle("void", "session ended")
		end
		doSave()
		paused = true
		dirty = true
	end
	Gui.sameLine()
	if Gui.button(L.RESET) then
		confirmReset = true
	end
	if confirmReset then
		Gui.textColored(COL.WARN, L.RESET_ASK)
		if Gui.button(L.RESET_YES) then
			resetProgress()
		end
		Gui.sameLine()
		if Gui.button(L.RESET_NO) then
			confirmReset = false
		end
	end
	if view.saveLine ~= "" then
		Gui.textDisabled(view.saveLine)
	end
	Gui.textWrapped(L.DISCLAIMER)
end

function onGui()
	B.guiSeen = now
	if dirty then
		rebuildView()
	end
	uiHeader()
	uiMatch()
	uiCalls()
	uiPending()
	uiArenaBall()
	uiRecent()
	uiTimer()
	uiUnlocks()
	uiSettings()
	uiFooter()
end
