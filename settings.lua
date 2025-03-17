-- No Nampower v2, no need for settings
local has_pepo_nam = pcall(GetCVar, "NP_QueueCastTimeSpells")
if not has_pepo_nam then
	DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00Pepo Nampower v2|cffffaaaa not present hiding settings.")
	return
end

Nampower = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceDebug-2.0", "AceModuleCore-2.0", "AceConsole-2.0", "AceDB-2.0", "AceHook-2.1")
Nampower:RegisterDB("NampowerSettingsDB")
Nampower:RegisterDefaults("profile", {
	per_character_settings = false,
	show_queued_spell = false,
	queued_spell_posx = 0,
	queued_spell_posy = 0,
	queued_spell_size = 16,
	queued_spell_enable_mouse = true,
})
Nampower.frame = CreateFrame("Frame", "Nampower", UIParent)

function Nampower:HasMinimumVersion(major, minor, patch)
	if GetNampowerVersion then
		local installedMajor, installedMinor, installedPatch = GetNampowerVersion()

		if installedMajor > major then
			return true
		elseif installedMajor == major and installedMinor > minor then
			return true
		elseif installedMajor == major and installedMinor == minor and installedPatch >= patch then
			return true
		end
	end

	return false
end

-- check if they have the latest nampower dll
if not Nampower:HasMinimumVersion(2, 8, 6) then
	DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00Pepo Nampower update available.|cffffcc00  Some settings may be hidden until you update.  Replace your existing nampower.dll with the latest from https://github.com/pepopo978/nampower/releases")
end

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

-- used when turning on per character settings
function Nampower:SavePerCharacterSettings()
	for settingKey, settingData in pairs(Nampower.cmdtable.args) do
		if string.find(settingKey, "NP_") == 1 then
			settingData.set(settingData.get()) -- trigger the set function for each setting with the current value
		end
	end

	for settingKey, settingData in pairs(Nampower.cmdtable.args.queue_windows.args) do
		if string.find(settingKey, "NP_") == 1 then
			settingData.set(settingData.get()) -- trigger the set function for each setting with the current value
		end
	end

	for settingKey, settingData in pairs(Nampower.cmdtable.args.advanced_options.args) do
		if string.find(settingKey, "NP_") == 1 then
			settingData.set(settingData.get()) -- trigger the set function for each setting with the current value
		end
	end
end

function Nampower:ApplySavedSettings()
	for settingKey, settingData in pairs(Nampower.cmdtable.args) do
		-- only apply settings that are prefixed with NP_
		if string.find(settingKey, "NP_") == 1 then
			if Nampower.db.profile[settingKey] then
				settingData.set(Nampower.db.profile[settingKey])
			end
		end
	end

	for settingKey, settingData in pairs(Nampower.cmdtable.args.queue_windows.args) do
		-- only apply settings that are prefixed with NP_
		if string.find(settingKey, "NP_") == 1 then
			if Nampower.db.profile[settingKey] then
				settingData.set(Nampower.db.profile[settingKey])
			end
		end
	end

	for settingKey, settingData in pairs(Nampower.cmdtable.args.advanced_options.args) do
		-- only apply settings that are prefixed with NP_
		if string.find(settingKey, "NP_") == 1 then
			if Nampower.db.profile[settingKey] then
				settingData.set(Nampower.db.profile[settingKey])
			end
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

	-- if per character settings are enabled, apply them
	if Nampower.db.profile.per_character_settings then
		Nampower:ApplySavedSettings()
	end

	toggleEventListener()
end

Nampower.cmdtable = {
	type = "group",
	handler = Nampower,
	args = {
		per_character_settings = {
			type = "toggle",
			name = "Enable Per Character Settings",
			desc = "Whether to use per character settings for all of the NP_ settings.  This will cause settings saved in your character's NampowerSettings.lua to override any global settings in Config.wtf.",
			order = 1,
			get = function()
				return Nampower.db.profile.per_character_settings
			end,
			set = function(v)
				if v ~= Nampower.db.profile.per_character_settings then
					Nampower.db.profile.per_character_settings = v
					if v == true then
						Nampower:SavePerCharacterSettings()
					end
				end
			end,
		},
		NP_QueueCastTimeSpells = {
			type = "toggle",
			name = "Queue Cast Time Spells",
			desc = "Whether to enable spell queuing for spells with a cast time",
			order = 5,
			get = function()
				return GetCVar("NP_QueueCastTimeSpells") == "1"
			end,
			set = function(v)
				Nampower.db.profile.NP_QueueCastTimeSpells = v
				if v == true then
					SetCVar("NP_QueueCastTimeSpells", "1")
				else
					SetCVar("NP_QueueCastTimeSpells", "0")
				end
			end,
		},
		NP_QueueInstantSpells = {
			type = "toggle",
			name = "Queue Instant Spells",
			desc = "Whether to enable spell queuing for instant cast spells tied to gcd",
			order = 10,
			get = function()
				return GetCVar("NP_QueueInstantSpells") == "1"
			end,
			set = function(v)
				Nampower.db.profile.NP_QueueInstantSpells = v
				if v == true then
					SetCVar("NP_QueueInstantSpells", "1")
				else
					SetCVar("NP_QueueInstantSpells", "0")
				end
			end,
		},
		NP_QueueOnSwingSpells = {
			type = "toggle",
			name = "Queue On Swing Spells",
			desc = "Whether to enable on swing spell queuing",
			order = 15,
			get = function()
				return GetCVar("NP_QueueOnSwingSpells") == "1"
			end,
			set = function(v)
				Nampower.db.profile.NP_QueueOnSwingSpells = v
				if v == true then
					SetCVar("NP_QueueOnSwingSpells", "1")
				else
					SetCVar("NP_QueueOnSwingSpells", "0")
				end
			end,
		},
		NP_QueueChannelingSpells = {
			type = "toggle",
			name = "Queue Channeling Spells",
			desc = "Whether to enable channeling spell queuing",
			order = 20,
			get = function()
				return GetCVar("NP_QueueChannelingSpells") == "1"
			end,
			set = function(v)
				Nampower.db.profile.NP_QueueChannelingSpells = v
				if v == true then
					SetCVar("NP_QueueChannelingSpells", "1")
				else
					SetCVar("NP_QueueChannelingSpells", "0")
				end
			end,
		},
		NP_QueueTargetingSpells = {
			type = "toggle",
			name = "Queue Targeting Spells",
			desc = "Whether to enable terrain targeting spell queuing",
			order = 25,
			get = function()
				return GetCVar("NP_QueueTargetingSpells") == "1"
			end,
			set = function(v)
				Nampower.db.profile.NP_QueueTargetingSpells = v
				if v == true then
					SetCVar("NP_QueueTargetingSpells", "1")
				else
					SetCVar("NP_QueueTargetingSpells", "0")
				end
			end,
		},
		NP_QueueSpellsOnCooldown = {
			type = "toggle",
			name = "Queue Spells Coming Off Cooldown",
			desc = "Whether to enable spell queuing for spells coming off cooldown",
			order = 30,
			get = function()
				return GetCVar("NP_QueueSpellsOnCooldown") == "1"
			end,
			set = function(v)
				Nampower.db.profile.NP_QueueSpellsOnCooldown = v
				if v == true then
					SetCVar("NP_QueueSpellsOnCooldown", "1")
				else
					SetCVar("NP_QueueSpellsOnCooldown", "0")
				end
			end,
		},
		spacera = {
			type = "header",
			name = " ",
			order = 31,
		},
		queue_windows = {
			type = "group",
			name = "Queue Windows",
			desc = "How much time in ms you have before a cast ends to queue different types of spells",
			order = 40,
			args = {
				NP_SpellQueueWindowMs = {
					type = "range",
					name = "Spell Queue Window (ms)",
					desc = "The window in ms before a cast finishes where the next will get queued",
					order = 40,
					min = 0,
					max = 5000,
					step = 50,
					get = function()
						return GetCVar("NP_SpellQueueWindowMs")
					end,
					set = function(v)
						Nampower.db.profile.NP_SpellQueueWindowMs = v
						SetCVar("NP_SpellQueueWindowMs", v)
					end,
				},
				NP_OnSwingBufferCooldownMs = {
					type = "range",
					name = "On Swing Buffer Cooldown (ms)",
					desc = "The cooldown time in ms after an on swing spell before you can queue on swing spells",
					order = 45,
					min = 0,
					max = 5000,
					step = 50,
					get = function()
						return GetCVar("NP_OnSwingBufferCooldownMs")
					end,
					set = function(v)
						Nampower.db.profile.NP_OnSwingBufferCooldownMs = v
						SetCVar("NP_OnSwingBufferCooldownMs", v)
					end,
				},
				NP_ChannelQueueWindowMs = {
					type = "range",
					name = "Channel Queue Window (ms)",
					desc = "The window in ms before a channel finishes where the next will get queued",
					order = 50,
					min = 0,
					max = 5000,
					step = 50,
					get = function()
						return GetCVar("NP_ChannelQueueWindowMs")
					end,
					set = function(v)
						Nampower.db.profile.NP_ChannelQueueWindowMs = v
						SetCVar("NP_ChannelQueueWindowMs", v)
					end,
				},
				NP_TargetingQueueWindowMs = {
					type = "range",
					name = "Targeting Queue Window (ms)",
					desc = "The window in ms before a terrain targeting spell finishes where the next will get queued",
					order = 55,
					min = 0,
					max = 5000,
					step = 50,
					get = function()
						return GetCVar("NP_TargetingQueueWindowMs")
					end,
					set = function(v)
						Nampower.db.profile.NP_TargetingQueueWindowMs = v
						SetCVar("NP_TargetingQueueWindowMs", v)
					end,
				},
				NP_CooldownQueueWindowMs = {
					type = "range",
					name = "Cooldown Queue Window (ms)",
					desc = "The window in ms before a spell coming off cooldown finishes where the next will get queued",
					order = 60,
					min = 0,
					max = 5000,
					step = 50,
					get = function()
						return GetCVar("NP_CooldownQueueWindowMs")
					end,
					set = function(v)
						Nampower.db.profile.NP_CooldownQueueWindowMs = v
						SetCVar("NP_CooldownQueueWindowMs", v)
					end,
				}
			},
		},
		spacerb = {
			type = "header",
			name = " ",
			order = 50,
		},
		advanced_options = {
			type = "group",
			name = "Advanced options",
			desc = "Collection of various advanced options",
			order = 60,
			args = {
				NP_DoubleCastToEndChannelEarly = {
					type = "toggle",
					name = "Double Cast to End Channel Early",
					desc = "Whether to allow double casting a spell within 350ms to end channeling on the next tick.  Takes into account your ChannelLatencyReductionPercentage.",
					order = 33,
					get = function()
						return GetCVar("NP_DoubleCastToEndChannelEarly") == "1"
					end,
					set = function(v)
						Nampower.db.profile.NP_DoubleCastToEndChannelEarly = v
						if v == true then
							SetCVar("NP_DoubleCastToEndChannelEarly", "1")
						else
							SetCVar("NP_DoubleCastToEndChannelEarly", "0")
						end
					end,
				},
				NP_InterruptChannelsOutsideQueueWindow = {
					type = "toggle",
					name = "Interrupt Channels Outside Queue Window",
					desc = "Whether to allow interrupting channels (the original client behavior) when trying to cast a spell outside the channeling queue window",
					order = 70,
					get = function()
						return GetCVar("NP_InterruptChannelsOutsideQueueWindow") == "1"
					end,
					set = function(v)
						Nampower.db.profile.NP_InterruptChannelsOutsideQueueWindow = v
						if v == true then
							SetCVar("NP_InterruptChannelsOutsideQueueWindow", "1")
						else
							SetCVar("NP_InterruptChannelsOutsideQueueWindow", "0")
						end
					end,
				},
				NP_RetryServerRejectedSpells = {
					type = "toggle",
					name = "Retry Server Rejected Spells",
					desc = "Whether to retry spells that are rejected by the server for these reasons: SPELL_FAILED_ITEM_NOT_READY, SPELL_FAILED_NOT_READY, SPELL_FAILED_SPELL_IN_PROGRESS",
					order = 100,
					get = function()
						return GetCVar("NP_RetryServerRejectedSpells") == "1"
					end,
					set = function(v)
						Nampower.db.profile.NP_RetryServerRejectedSpells = v
						if v == true then
							SetCVar("NP_RetryServerRejectedSpells", "1")
						else
							SetCVar("NP_RetryServerRejectedSpells", "0")
						end
					end,
				},
				NP_QuickcastTargetingSpells = {
					type = "toggle",
					name = "Quickcast Targeting Spells",
					desc = "Whether to enable quick casting for ALL spells with terrain targeting",
					order = 105,
					get = function()
						return GetCVar("NP_QuickcastTargetingSpells") == "1"
					end,
					set = function(v)
						Nampower.db.profile.NP_QuickcastTargetingSpells = v
						if v == true then
							SetCVar("NP_QuickcastTargetingSpells", "1")
						else
							SetCVar("NP_QuickcastTargetingSpells", "0")
						end
					end,
				},
				NP_ReplaceMatchingNonGcdCategory = {
					type = "toggle",
					name = "Replace Matching Non GCD Category",
					desc = "Whether to replace any queued non gcd spell when a new non gcd spell with the same StartRecoveryCategory is cast",
					order = 110,
					get = function()
						return GetCVar("NP_ReplaceMatchingNonGcdCategory") == "1"
					end,
					set = function(v)
						Nampower.db.profile.NP_ReplaceMatchingNonGcdCategory = v
						if v == true then
							SetCVar("NP_ReplaceMatchingNonGcdCategory", "1")
						else
							SetCVar("NP_ReplaceMatchingNonGcdCategory", "0")
						end
					end,
				},
				NP_OptimizeBufferUsingPacketTimings = {
					type = "toggle",
					name = "Optimize Buffer Using Packet Timings",
					desc = "Whether to attempt to optimize your buffer using your latency and server packet timings",
					order = 115,
					get = function()
						return GetCVar("NP_OptimizeBufferUsingPacketTimings") == "1"
					end,
					set = function(v)
						Nampower.db.profile.NP_OptimizeBufferUsingPacketTimings = v
						if v == true then
							SetCVar("NP_OptimizeBufferUsingPacketTimings", "1")
						else
							SetCVar("NP_OptimizeBufferUsingPacketTimings", "0")
						end
					end,
				},
				NP_MinBufferTimeMs = {
					type = "range",
					name = "Minimum Buffer Time (ms)",
					desc = "The minimum buffer delay in ms added to each cast",
					order = 80,
					min = 0,
					max = 300,
					step = 1,
					get = function()
						return GetCVar("NP_MinBufferTimeMs")
					end,
					set = function(v)
						Nampower.db.profile.NP_MinBufferTimeMs = v
						SetCVar("NP_MinBufferTimeMs", v)
					end,
				},
				NP_NonGcdBufferTimeMs = {
					type = "range",
					name = "Non GCD Buffer Time (ms)",
					desc = "The buffer delay in ms added AFTER each cast that is not tied to the gcd",
					order = 85,
					min = 0,
					max = 300,
					step = 1,
					get = function()
						return GetCVar("NP_NonGcdBufferTimeMs")
					end,
					set = function(v)
						Nampower.db.profile.NP_NonGcdBufferTimeMs = v
						SetCVar("NP_NonGcdBufferTimeMs", v)
					end,
				},
				NP_MaxBufferIncreaseMs = {
					type = "range",
					name = "Max Buffer Increase (ms)",
					desc = "The maximum amount of time in ms to increase the buffer by when the server rejects a cast",
					order = 90,
					min = 0,
					max = 100,
					step = 5,
					get = function()
						return GetCVar("NP_MaxBufferIncreaseMs")
					end,
					set = function(v)
						Nampower.db.profile.NP_MaxBufferIncreaseMs = v
						SetCVar("NP_MaxBufferIncreaseMs", v)
					end,
				},
				NP_ChannelLatencyReductionPercentage = {
					type = "range",
					name = "Channel Latency Reduction (%)",
					desc = "The percentage of your latency to subtract from the end of a channel duration to optimize cast time while hopefully not losing any ticks",
					order = 125,
					min = 0,
					max = 100,
					step = 1,
					get = function()
						return GetCVar("NP_ChannelLatencyReductionPercentage")
					end,
					set = function(v)
						Nampower.db.profile.NP_ChannelLatencyReductionPercentage = v
						SetCVar("NP_ChannelLatencyReductionPercentage", v)
					end,
				}
			},
		},
		spacerc = {
			type = "header",
			name = " ",
			order = 70,
		},
		queued_spell_options = {
			type = "group",
			name = "Queued Spell Display Options",
			desc = "Options for displaying an icon for the queued spell",
			order = 80,
			args = {
				enabled = {
					type = "toggle",
					name = "Display queued spell icon",
					desc = "Whether to display an icon of the queued spell",
					order = 5,
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
					order = 10,
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
					order = 15,
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
					order = 20,
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
					order = 25,
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
		spacer6 = {
			type = "header",
			name = " ",
			order = 90,
		},
		NP_PreventRightClickTargetChange = {
			type = "toggle",
			name = "Prevent Right Click Target Change",
			desc = "Whether to prevent right-clicking from changing your current target when in combat.  If you don't have a target right click will still change your target even with this on.  This is mainly to prevent accidentally changing targets in combat when trying to adjust your camera.",
			order = 100,
			get = function()
				return GetCVar("NP_PreventRightClickTargetChange") == "1"
			end,
			set = function(v)
				Nampower.db.profile.NP_PreventRightClickTargetChange = v
				if v == true then
					SetCVar("NP_PreventRightClickTargetChange", "1")
				else
					SetCVar("NP_PreventRightClickTargetChange", "0")
				end
			end,
		},
	},
}

if Nampower:HasMinimumVersion(2, 8, 6) then
	Nampower.cmdtable.args.NP_NameplateDistance = {
		type = "range",
		name = "Nameplate Distance",
		desc = "The distance in yards to show nameplates",
		order = 110,
		min = 5,
		max = 200,
		step = 1,
		get = function()
			return GetCVar("NP_NameplateDistance")
		end,
		set = function(v)
			Nampower.db.profile.NP_NameplateDistance = v
			SetCVar("NP_NameplateDistance", v)
		end,
	}
end

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
