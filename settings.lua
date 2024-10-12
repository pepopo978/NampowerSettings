-- No Nampower v2, no need for settings
local has_pepo_nam = pcall(GetCVar, "NP_QueueCastTimeSpells")
if not has_pepo_nam then
	DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00Pepo Nampower v2|cffffaaaa not present hiding settings.")
	return
end

Nampower = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceDebug-2.0", "AceModuleCore-2.0", "AceConsole-2.0", "AceDB-2.0", "AceHook-2.1")
Nampower.frame = CreateFrame("Frame", "Nampower", UIParent)

--NP_QueueCastTimeSpells - Whether to enable spell queuing for spells with a cast time. 0 to disable, 1 to enable. Default is 1.
--
--NP_QueueInstantSpells - Whether to enable spell queuing for instant cast spells tied to gcd. 0 to disable, 1 to enable. Default is 1.
--
--NP_QueueOnSwingSpells - Whether to enable on swing spell queuing. 0 to disable, 1 to enable. Default is 1.
--
--NP_QueueChannelingSpells - Whether to enable channeling spell queuing. 0 to disable, 1 to enable. Default is 1.
--
--NP_QueueTargetingSpells - Whether to enable terrain targeting spell queuing. 0 to disable, 1 to enable. Default is 1.
--
--NP_SpellQueueWindowMs - The window in ms before a cast finishes where the next will get queued. Default is 500.
--
--NP_OnSwingBufferCooldownMs - The cooldown time in ms after an on swing spell before you can queue on swing spells. Default is 500.
--
--NP_ChannelQueueWindowMs - The window in ms before a channel finishes where the next will get queued. Default is 1500.
--
--NP_TargetingQueueWindowMs - The window in ms before a terrain targeting spell finishes where the next will get queued. Default is 500.
--
--NP_MinBufferTimeMs - The minimum buffer delay in ms added to each cast (covered more below). The dynamic buffer adjustments will not go below this value. Default is 55.
--
--NP_NonGcdBufferTimeMs - The buffer delay in ms added AFTER each cast that is not tied to the gcd. Default is 100.
--
--NP_MaxBufferIncreaseMs - The maximum amount of time in ms to increase the buffer by when the server rejects a cast. This prevents getting too long of a buffer if you happen to get a ton of rejections in a row. Default is 30.
--
--NP_RetryServerRejectedSpells - Whether to retry spells that are rejected by the server for these reasons: SPELL_FAILED_ITEM_NOT_READY, SPELL_FAILED_NOT_READY, SPELL_FAILED_SPELL_IN_PROGRESS. 0 to disable, 1 to enable. Default is 1.
--
--NP_QuickcastTargetingSpells - Whether to enable quick casting for ALL spells with terrain targeting. This will cause the spell to instantly cast on your cursor without waiting for you to confirm the targeting circle. Queuing targeting spells will use quickcasting regardless of this value (couldn't get it to work without doing this). 0 to disable, 1 to enable. Default is 0.
--
--NP_ReplaceMatchingNonGcdCategory - Whether to replace any queued non gcd spell when a new non gcd spell with the same StartRecoveryCategory is cast (more explanation below). 0 to disable, 1 to enable. Default is 0.

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
	}
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
