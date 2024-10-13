-- No Nampower v2, no need for settings
local has_pepo_nam = pcall(GetCVar, "NP_QueueCastTimeSpells")
if not has_pepo_nam then
	DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00Pepo Nampower v2|cffffaaaa not present hiding settings.")
	return
end

Nampower = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceDebug-2.0", "AceModuleCore-2.0", "AceConsole-2.0", "AceDB-2.0", "AceHook-2.1")
Nampower:RegisterDB("NampowerSettingsDB")
Nampower:RegisterDefaults("profile", {
	show_queued_spell = false,
	queued_spell_posx = 0,
	queued_spell_posy = 0,
	queued_spell_size = 16,
	queued_spell_enable_mouse = true,
})
Nampower.frame = CreateFrame("Frame", "Nampower", UIParent)

-- setup queued spell frame
Nampower.queued_spell = CreateFrame("Frame", "Queued Spell", UIParent)
Nampower.queued_spell:SetFrameStrata("HIGH")
Nampower.queued_spell.texture = Nampower.queued_spell:CreateTexture(nil, "OVERLAY")
Nampower.queued_spell.texture:SetAllPoints()
Nampower.queued_spell.texture:SetTexCoord(.08, .92, .08, .92)
Nampower.queued_spell.texture:SetTexture("Interface\\Icons\\Spell_Nature_HealingWaveLesser") -- set test texture

-- setup dragging
Nampower.queued_spell:RegisterForDrag("LeftButton")
Nampower.queued_spell:SetMovable(true)

Nampower.queued_spell:SetScript("OnDragStart", function()
	this:StartMoving()
end)

local function saveQueuedSpellPosition()
	Nampower.db.profile.queued_spell_posx = Nampower.queued_spell:GetLeft()
	Nampower.db.profile.queued_spell_posy = Nampower.queued_spell:GetTop()
end

Nampower.queued_spell:SetScript("OnDragStop", function()
	this:StopMovingOrSizing()
	saveQueuedSpellPosition()
end)

local ON_SWING_QUEUED = 0
local ON_SWING_QUEUE_POPPED = 1
local NORMAL_QUEUED = 2
local NORMAL_QUEUE_POPPED = 3
local NON_GCD_QUEUED = 4
local NON_GCD_QUEUE_POPPED = 5

local function spellQueueEvent(eventCode, spellId)
	if eventCode == NORMAL_QUEUED or eventCode == NON_GCD_QUEUED then
		local _, _, texture = SpellInfo(spellId) -- superwow function
		Nampower.queued_spell.texture:SetTexture(texture)
		Nampower.queued_spell:Show()
	elseif eventCode == NORMAL_QUEUE_POPPED or eventCode == NON_GCD_QUEUE_POPPED then
		Nampower.queued_spell:Hide()
	end
end

local function toggleEventListener()
	if Nampower.db.profile.show_queued_spell then
		if SpellInfo then
			Nampower:RegisterEvent("SPELL_QUEUE_EVENT", spellQueueEvent)
		else
			DEFAULT_CHAT_FRAME:AddMessage("Superwow required to display queued spells.")
			if Nampower:IsEventRegistered("SPELL_QUEUE_EVENT") then
				Nampower:UnregisterEvent("SPELL_QUEUE_EVENT")
			end
		end
	else
		if Nampower:IsEventRegistered("SPELL_QUEUE_EVENT") then
			Nampower:UnregisterEvent("SPELL_QUEUE_EVENT")
		end
	end
end

function Nampower:OnEnable()
	Nampower.queued_spell:EnableMouse(Nampower.db.profile.queued_spell_enable_mouse)

	-- set scale
	local x = Nampower.db.profile.queued_spell_posx
	local y = Nampower.db.profile.queued_spell_posy
	local size = Nampower.db.profile.queued_spell_size

	-- set saved position
	Nampower.queued_spell:ClearAllPoints()
	Nampower.queued_spell:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
	Nampower.queued_spell:SetWidth(size)
	Nampower.queued_spell:SetHeight(size)
	Nampower.queued_spell:Hide()

	toggleEventListener()
end

Nampower.cmdtable = {
	type = "group",
	handler = Nampower,
	args = {
		queue_cast_time_spells = {
			type = "toggle",
			name = "Queue Cast Time Spells",
			desc = "Whether to enable spell queuing for spells with a cast time",
			order = 1,
			get = function()
				return GetCVar("NP_QueueCastTimeSpells") == "1"
			end,
			set = function(v)
				if v == true then
					SetCVar("NP_QueueCastTimeSpells", "1")
				else
					SetCVar("NP_QueueCastTimeSpells", "0")
				end
			end,
		},
		queue_instant_spells = {
			type = "toggle",
			name = "Queue Instant Spells",
			desc = "Whether to enable spell queuing for instant cast spells tied to gcd",
			order = 2,
			get = function()
				return GetCVar("NP_QueueInstantSpells") == "1"
			end,
			set = function(v)
				if v == true then
					SetCVar("NP_QueueInstantSpells", "1")
				else
					SetCVar("NP_QueueInstantSpells", "0")
				end
			end,
		},
		queue_on_swing_spells = {
			type = "toggle",
			name = "Queue On Swing Spells",
			desc = "Whether to enable on swing spell queuing",
			order = 3,
			get = function()
				return GetCVar("NP_QueueOnSwingSpells") == "1"
			end,
			set = function(v)
				if v == true then
					SetCVar("NP_QueueOnSwingSpells", "1")
				else
					SetCVar("NP_QueueOnSwingSpells", "0")
				end
			end,
		},
		queue_channeling_spells = {
			type = "toggle",
			name = "Queue Channeling Spells",
			desc = "Whether to enable channeling spell queuing",
			order = 4,
			get = function()
				return GetCVar("NP_QueueChannelingSpells") == "1"
			end,
			set = function(v)
				if v == true then
					SetCVar("NP_QueueChannelingSpells", "1")
				else
					SetCVar("NP_QueueChannelingSpells", "0")
				end
			end,
		},
		queue_targeting_spells = {
			type = "toggle",
			name = "Queue Targeting Spells",
			desc = "Whether to enable terrain targeting spell queuing",
			order = 5,
			get = function()
				return GetCVar("NP_QueueTargetingSpells") == "1"
			end,
			set = function(v)
				if v == true then
					SetCVar("NP_QueueTargetingSpells", "1")
				else
					SetCVar("NP_QueueTargetingSpells", "0")
				end
			end,
		},
		spacer = {
			type = "header",
			name = " ",
			order = 11,
		},
		spell_queue_window_ms = {
			type = "range",
			name = "Spell Queue Window (ms)",
			desc = "The window in ms before a cast finishes where the next will get queued",
			order = 21,
			min = 0,
			max = 5000,
			step = 50,
			get = function()
				return GetCVar("NP_SpellQueueWindowMs")
			end,
			set = function(v)
				SetCVar("NP_SpellQueueWindowMs", v)
			end,
		},
		on_swing_buffer_cooldown_ms = {
			type = "range",
			name = "On Swing Buffer Cooldown (ms)",
			desc = "The cooldown time in ms after an on swing spell before you can queue on swing spells",
			order = 22,
			min = 0,
			max = 5000,
			step = 50,
			get = function()
				return GetCVar("NP_OnSwingBufferCooldownMs")
			end,
			set = function(v)
				SetCVar("NP_OnSwingBufferCooldownMs", v)
			end,
		},
		channel_queue_window_ms = {
			type = "range",
			name = "Channel Queue Window (ms)",
			desc = "The window in ms before a channel finishes where the next will get queued",
			order = 23,
			min = 0,
			max = 5000,
			step = 50,
			get = function()
				return GetCVar("NP_ChannelQueueWindowMs")
			end,
			set = function(v)
				SetCVar("NP_ChannelQueueWindowMs", v)
			end,
		},
		targeting_queue_window_ms = {
			type = "range",
			name = "Targeting Queue Window (ms)",
			desc = "The window in ms before a terrain targeting spell finishes where the next will get queued",
			order = 24,
			min = 0,
			max = 5000,
			step = 50,
			get = function()
				return GetCVar("NP_TargetingQueueWindowMs")
			end,
			set = function(v)
				SetCVar("NP_TargetingQueueWindowMs", v)
			end,
		},
		spacer2 = {
			type = "header",
			name = " ",
			order = 30,
		},
		min_buffer_time_ms = {
			type = "range",
			name = "Minimum Buffer Time (ms)",
			desc = "The minimum buffer delay in ms added to each cast",
			order = 31,
			min = 0,
			max = 300,
			step = 1,
			get = function()
				return GetCVar("NP_MinBufferTimeMs")
			end,
			set = function(v)
				SetCVar("NP_MinBufferTimeMs", v)
			end,
		},
		non_gcd_buffer_time_ms = {
			type = "range",
			name = "Non GCD Buffer Time (ms)",
			desc = "The buffer delay in ms added AFTER each cast that is not tied to the gcd",
			order = 32,
			min = 0,
			max = 300,
			step = 1,
			get = function()
				return GetCVar("NP_NonGcdBufferTimeMs")
			end,
			set = function(v)
				SetCVar("NP_NonGcdBufferTimeMs", v)
			end,
		},
		max_buffer_increase_ms = {
			type = "range",
			name = "Max Buffer Increase (ms)",
			desc = "The maximum amount of time in ms to increase the buffer by when the server rejects a cast",
			order = 33,
			min = 0,
			max = 100,
			step = 5,
			get = function()
				return GetCVar("NP_MaxBufferIncreaseMs")
			end,
			set = function(v)
				SetCVar("NP_MaxBufferIncreaseMs", v)
			end,
		},
		spacer3 = {
			type = "header",
			name = " ",
			order = 40,
		},
		retry_server_rejected_spells = {
			type = "toggle",
			name = "Retry Server Rejected Spells",
			desc = "Whether to retry spells that are rejected by the server for these reasons: SPELL_FAILED_ITEM_NOT_READY, SPELL_FAILED_NOT_READY, SPELL_FAILED_SPELL_IN_PROGRESS",
			order = 41,
			get = function()
				return GetCVar("NP_RetryServerRejectedSpells") == "1"
			end,
			set = function(v)
				if v == true then
					SetCVar("NP_RetryServerRejectedSpells", "1")
				else
					SetCVar("NP_RetryServerRejectedSpells", "0")
				end
			end,
		},
		quickcast_targeting_spells = {
			type = "toggle",
			name = "Quickcast Targeting Spells",
			desc = "Whether to enable quick casting for ALL spells with terrain targeting",
			order = 42,
			get = function()
				return GetCVar("NP_QuickcastTargetingSpells") == "1"
			end,
			set = function(v)
				if v == true then
					SetCVar("NP_QuickcastTargetingSpells", "1")
				else
					SetCVar("NP_QuickcastTargetingSpells", "0")
				end
			end,
		},
		replace_matching_non_gcd_category = {
			type = "toggle",
			name = "Replace Matching Non GCD Category",
			desc = "Whether to replace any queued non gcd spell when a new non gcd spell with the same StartRecoveryCategory is cast",
			order = 43,
			get = function()
				return GetCVar("NP_ReplaceMatchingNonGcdCategory") == "1"
			end,
			set = function(v)
				if v == true then
					SetCVar("NP_ReplaceMatchingNonGcdCategory", "1")
				else
					SetCVar("NP_ReplaceMatchingNonGcdCategory", "0")
				end
			end,
		},
		spacer4 = {
			type = "header",
			name = " ",
			order = 50,
		},
		queued_spell_options = {
			type = "group",
			name = "Queued Spell Display Options",
			desc = "Options for displaying an icon for the queued spell",
			order = 51,
			args = {
				enabled = {
					type = "toggle",
					name = "Display queued spell icon",
					desc = "Whether to display an icon of the queued spell",
					order = 1,
					get = function()
						return Nampower.db.profile.show_queued_spell
					end,
					set = function(v)
						Nampower.db.profile.show_queued_spell = v
						toggleEventListener()
					end,
				},
				size = {
					type = "range",
					name = "Icon size",
					desc = "Change the spell icon size",
					order = 2,
					min = 8,
					max = 48,
					step = 1,
					get = function()
						return Nampower.db.profile.queued_spell_size
					end,
					set = function(v)
						Nampower.db.profile.queued_spell_size = v
						Nampower.queued_spell:SetWidth(v)
						Nampower.queued_spell:SetHeight(v)
					end,
				},
				draggable = {
					type = "toggle",
					name = "Allow dragging",
					desc = "Whether to allow interaction with the queued spell icon so you can move it around",
					order = 3,
					get = function()
						return Nampower.db.profile.queued_spell_enable_mouse
					end,
					set = function(v)
						Nampower.db.profile.queued_spell_enable_mouse = v
						Nampower.queued_spell:EnableMouse(v)
					end,
				},
				reset_position = {
					type = "execute",
					name = "Reset Position",
					desc = "Reset the position of the queued spell icon",
					order = 4,
					func = function()
						local scale = Nampower.queued_spell:GetEffectiveScale()
						Nampower.queued_spell:ClearAllPoints()
						Nampower.queued_spell:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", 500 / scale, 500 / scale)
						saveQueuedSpellPosition()
					end,
				},
				test = {
					type = "execute",
					name = "Show/Hide for positioning",
					desc = "Test the queued spell icon and position it to your liking",
					order = 5,
					func = function()
						if Nampower.queued_spell:IsVisible() then
							Nampower.queued_spell:Hide()
						else
							Nampower.queued_spell:Show()
						end
					end,
				},
			},
		},
	},
}

local deuce = Nampower:NewModule("Nampower Options Menu")
deuce.hasFuBar = IsAddOnLoaded("FuBar") and FuBar
deuce.consoleCmd = not deuce.hasFuBar

NampowerOptions = AceLibrary("AceAddon-2.0"):new("AceDB-2.0", "FuBarPlugin-2.0")
NampowerOptions.name = "FuBar - Nampower"
NampowerOptions.hasIcon = "Interface\\Icons\\inv_misc_book_04"
NampowerOptions.defaultMinimapPosition = 180
NampowerOptions.independentProfile = true
NampowerOptions.hideWithoutStandby = false

NampowerOptions.OnMenuRequest = Nampower.cmdtable
local args = AceLibrary("FuBarPlugin-2.0"):GetAceOptionsDataTable(NampowerOptions)
for k, v in pairs(args) do
	if NampowerOptions.OnMenuRequest.args[k] == nil then
		NampowerOptions.OnMenuRequest.args[k] = v
	end
end
