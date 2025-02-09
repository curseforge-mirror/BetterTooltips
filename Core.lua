BetterTooltips = LibStub("AceAddon-3.0"):NewAddon("BetterTooltips", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceTimer-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local libS = LibStub("AceSerializer-3.0")
local libC = LibStub("LibCompress")
local lwin = LibStub("LibWindow-1.1")
local libCE = libC:GetAddonEncodeTable()
local LSM = LibStub("LibSharedMedia-3.0")

BetterTooltips_Config = {}
BetterTooltips_Config.stats = true
BetterTooltips_Config.R = 0
BetterTooltips_Config.G = .7
BetterTooltips_Config.B = .7

ReoriginationArray_Weekly = {}
ReoriginationArray_Weekly[1] = 53568
ReoriginationArray_Weekly[2] = 53569
ReoriginationArray_Weekly[3] = 53570

ReoriginationArray_Stacks = {}
ReoriginationArray_Stacks[1] = 53571
ReoriginationArray_Stacks[2] = 53572
ReoriginationArray_Stacks[3] = 53573
ReoriginationArray_Stacks[4] = 53574
ReoriginationArray_Stacks[5] = 53575
ReoriginationArray_Stacks[6] = 53576
ReoriginationArray_Stacks[7] = 53577
ReoriginationArray_Stacks[8] = 53578
ReoriginationArray_Stacks[9] = 53579
ReoriginationArray_Stacks[10] = 53580

stats = {}
stats[9] = "Critical Strike"
stats[18] = "Haste"
stats[26] = "Mastery"
stats[29] = "Versatility"

tertiary_stats = {}
tertiary_stats[21] = "Avoidance"
tertiary_stats[17] = "Leech"
--tertiary_stats[14] = "Speed"

all_stats = {}
all_stats[9] = "Critical Strike"
all_stats[18] = "Haste"
all_stats[26] = "Mastery"
all_stats[29] = "Versatility"
all_stats[21] = "Avoidance"
all_stats[17] = "Leech"
--all_stats[14] = "Speed"


ReoriginationArray_Descriptions = {}
ReoriginationArray_Descriptions[0] = "Reorigination Array Hidden Quest completed for this week."
ReoriginationArray_Descriptions[1] = "Defeat 1 more boss in Uldir this week."
ReoriginationArray_Descriptions[2] = "Defeat 2 more bosses in Uldir this week."
ReoriginationArray_Descriptions[3] = "Defeat 3 more bosses in Uldir this week."

E_CHANCE = 1
E_RPPM = 2
E_NAME = 3
E_ICD = 4
E_AZERITE_POWER = 5
E_SPELLID = 6
E_DESC = 7
E_REFID = 8

-----------------
-- Addon Setup --
-----------------c

local BetterTooltips_Version = "1.0.0"

local configDefaults = {
	randomType = true
}

function BetterTooltips:GetConfig(key)
	if BetterTooltips_Config[key] == nil then
		return configDefaults[key]
	else
		return BetterTooltips_Config[key]
	end
end

function BetterTooltips:SetConfig(key, value)
	if configDefaults[key] == value then
		BetterTooltips_Config[key] = nil
	else
		BetterTooltips_Config[key] = value
	end
end

function BetterTooltips:RestoreDefaults()
	BetterTooltips_Config = {}
	self:UpdateMedia()
	self:UpdateDisplayed()
	LibStub("AceConfigRegistry-3.0"):NotifyChange("BetterTooltips")
end

function GetCurrentColorAsHexDigits()
	return 255 * BetterTooltips_Config.R, 255 * BetterTooltips_Config.G, 255 * BetterTooltips_Config.B
end

function formatWithCurrentColor(string)
	return string.format("|cff%02x%02x%02x"..string.gsub(string, "%%", "%%%%").."|r", GetCurrentColorAsHexDigits())
end

function colorPickerChanged(restore)
	if restore then
		BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B = unpack(ColorPickerFrame.previousValues)
		return
	end

	BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B = ColorPickerFrame:GetColorRGB()

	_G["BetterTooltips_Config.R"] = BetterTooltips_Config.R
	_G["BetterTooltips_Config.G"] = BetterTooltips_Config.G
	_G["BetterTooltips_Config.B"] = BetterTooltips_Config.B
end


SLASH_BetterTooltips1 = "/bettertooltips"
SLASH_BetterTooltips2 = "/btt"
function SlashCmdList.BetterTooltips(msg)
	if msg == "" then 
		print("Better Tooltips")
		statsString = ""
		if BetterTooltips_Config.stats == true then
			statsString = "|cff00ff00Enabled|r"
		else
			statsString = "|cffff0000Disabled|r"
		end

		print("        Stats - "..statsString.." - Enable or disable the showing of stat -> percentage in tooltips. (on|off)")
		print("        Color - Change the color of the text displayed in the tooltips. - "..formatWithCurrentColor(string.format("Current Color", GetCurrentColorAsHexDigits())))
	end

	strings = {}
	stringCount = 1
	for str in string.gmatch(msg, "%S+") do
		strings[stringCount] = str
		stringCount = stringCount + 1
	end

	if strings[1] == "stats" or strings[1] == "Stats" then
		if strings[2] == "off" or strings[2] == "disable" then
			BetterTooltips_Config.stats = false
			print("Better Tooltips - Stat information |cffff0000disabled.|r")
		elseif strings[2] == "on" or strings[2] == "enable" then
			BetterTooltips_Config.stats = true
			print("Better Tooltips - Stat information |cff00ff00enabled.|r")			
		else
			print("Usage: /btt stats (on|off)")
		end

		_G["BetterTooltips_Config.stats"] = BetterTooltips_Config.stats
	end

	if strings[1] == "color" or strings[1] == "Color" then
		ColorPickerFrame:SetColorRGB(BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B)
		ColorPickerFrame.hasOpacity = false
		ColorPickerFrame.previousValues = {BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B}
		ColorPickerFrame.func, ColorPickerFrame.cancelFunc = colorPickerChanged, colorPickerChanged
	   	ColorPickerFrame:Hide(); -- Need to run the OnShow handler.
	   	ColorPickerFrame:Show();

	end

end

SlashCmdList["BetterTooltips"] = SlashCmdList.BetterTooltips

function BetterTooltips:OnInitialize()
	if BetterTooltips_State == nil then
		BetterTooltips_State = {  }
	end
	if BetterTooltips_Config == nil then BetterTooltips_Config = { } end

	local ver = BetterTooltips_Version
	if ver:sub(1,1) == "@" then ver = "dev" end
end

function BetterTooltips:ChatCommand(input)
	LibStub("AceConfigCmd-3.0").HandleCommand(self, "btt", "BetterTooltips", input)
	print(BetterTooltips_Config.randomType)
end

function linkToID(itemLink)
	local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4, Suffix, Unique, LinkLvl, reforging, Name = string.find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
	return tonumber(Id)
end

function itemEnchant(itemLink)
	local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4, Suffix, Unique, LinkLvl, reforging, Name = string.find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
	return tonumber(Enchant)
end

local function ProcessItem(itemLink, tooltip)

	if itemLink == nil then return end

    local id = linkToID(itemLink)

    bonusLine = false

    if BetterTooltips.Items[id] ~= nil then
        item = BetterTooltips.Items[id]
		-- Check each spell possability
		for i=1, 5, 1 do
			-- See if we have info for this item
			if item[i] ~= nil and item[i][E_CHANCE] ~= nil then
				-- Add a spacing line
				if bonusLine == false then
					tooltip:AddLine(" ")
					bonusLine = true
                end
                local strLeft = ""

                -- If we have a spell ID, get the info from the api
                -- otherwise fall back to whatever simc described.
                if item[i][E_SPELLID] ~= nil then
                    strLeft = select(1, GetSpellInfo(item[i][E_SPELLID]))
                else
                    strLeft = item[i][E_NAME]
                end
				local strRight = ""

				-- Check for RPPM
				if item[i][E_RPPM] == 1 then
					strRight = strRight..string.format("RPPM: %.2f (%.2f)", item[i][E_CHANCE], item[i][E_CHANCE] * (1 + UnitSpellHaste("player")/100))
				else
					strRight = strRight..string.format("%.2f%%", item[i][E_CHANCE])
				end
                tooltip:AddDoubleLine(strLeft, strRight, BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B, BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B)
                if item[i][E_ICD] ~= 0 then
                    tooltip:AddDoubleLine(" ", string.format(" %.1f second ICD", item[i][E_ICD] / 1000), BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B, BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B)
                end
			end
		end
	end

	-- Heart of Azeroth
	if id == 158075 then
		tooltip:AddLine(" ")
    
        local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
        if azeriteItemLocation ~= nil then
            local xp, totalLevelXP = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)
            
            tooltip:AddDoubleLine("Rank",C_AzeriteItem.GetPowerLevel(azeriteItemLocation), BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B, BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B)
            tooltip:AddDoubleLine("Progress",string.format("%d/%d (%.2f%%)", xp, totalLevelXP, xp/totalLevelXP*100), BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B, BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B)
        end
	end
end

function alreadyAdded(str1, tooltip)
	if str1 == nil then
		return false
	end

	for i = 1,30 do
		local frame = _G[tooltip:GetName() .. "TextLeft" .. i]
		local textRight = _G[tooltip:GetName().."TextRight"..i]
		local text
		local right
		if frame then text = frame:GetText() end
		if text and string.find(text, str1, 1, true) then return true end
		if textRight then right = textRight:GetText() end
		if right and string.find(right, str1, 1, true) then return true end
	  end
	  
	  return false
end



function AddReoriginationInfo(tooltip)
	tooltip:AddLine(" ")
	-- Check the status of the reorigination count.
	ReoriginationLevel = 10
	while ReoriginationLevel > 0 and IsQuestFlaggedCompleted(ReoriginationArray_Stacks[ReoriginationLevel]) == false  do
		ReoriginationLevel = ReoriginationLevel - 1
	end

	tooltip:AddDoubleLine("Reorigination Stacks: ", ReoriginationLevel.."/10", BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B, BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B)

	if ReoriginationLevel ~= 10 then
		local WeeklyKills = 3
		while WeeklyKills ~= 0 and IsQuestFlaggedCompleted(ReoriginationArray_Weekly[WeeklyKills]) == false do
			WeeklyKills = WeeklyKills - 1
		end

		-- 0 = Red
		-- 1 or 2 = Yellow
		-- 3 = Green

		colorString = ""
		if WeeklyKills == 0 then
			colorString = "|cffff0000"
		elseif WeeklyKills ~= 3 then
			colorString = "|cffffff00"
		else
			colorString = "|cff00ff00"
		end

		tooltip:AddDoubleLine("Weekly: ", colorString..WeeklyKills.."/3", BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B, BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B)
	else
		tooltip:AddDoubleLine("Weekly", "|cff00ff00Max", BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B, BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B)
	end

	-- Grab the secondary stats to give the benefit
	local stat_values = {}
	for i, v in pairs(stats) do
		stat_values[i] = GetCombatRating(i)
    end
    
	-- find the largest
	largest = 9
	for i,v in pairs(stat_values) do
		if stat_values[largest] < stat_values[i] then
			largest = i
		end
	end

    tooltip:AddDoubleLine("Bonus: ", 75 * ReoriginationLevel.." "..stats[largest], BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B, BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B)
    
    -- Check for Vantus:
    UldirVantus = false
    for i=1, 40, 1 do
        local name = UnitBuff("player", i)
        -- @ todo - localization
        if name ~= nil and string.find(name, "Vantus Rune") then 
            UldirVantus = true
        end
    end

    if UldirVantus == true then
        stat_values[29] = stat_values[29] + 277
        -- Rerun the stat weight calculations with the +277 vers
        largest = 9
        for i,v in pairs(stat_values) do
            if stat_values[largest] < stat_values[i] then
                largest = i
            end
        end

        tooltip:AddDoubleLine("Bonus (Vantus): ", 75 * ReoriginationLevel.." "..stats[largest], BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B, BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B)
        
    end
end



function GetSpellChanceInfo(rank)

	-- Bonded Souls hack.
	-- Bonded Souls IDs report 288802, but the data is held in 288804.
	if rank == 288802 then
		rank = 288804
	-- combined might is hidden under a different spellid
	elseif rank == 280580 then
		rank = 280848
	end

	if BetterTooltips.SpellData[rank] == nil then return nil end

	str = ""
	str2 = ""

    data = BetterTooltips.SpellData[rank]

	if data[E_CHANCE] ~= nil and data[E_CHANCE] < 100.0 then
		str = select(1, GetSpellInfo(rank))
		if data[E_RPPM] == 1 then
			str2 = "RPPM: "..string.format("%.2f", data[E_CHANCE])

			-- Get haste % to calc "actual" rppm
			local actualRPPM = data[E_CHANCE] * (1 + UnitSpellHaste("player")/100)
			local actualRPPMString = string.format("%.2f", actualRPPM)
			str2 = str2.." ("..actualRPPMString..")"
		else
			str2 = string.format("%.2f%%", data[E_CHANCE])
		end
	end

	itemData = {}
	itemData["proc_name"] = str
    itemData["proc_info"] = str2
    if data[E_ICD] ~= nil and data[E_ICD] ~= 0 then
        itemData["proc_icd"] = string.format("%.1f second ICD", data[E_ICD]/1000)
    else
        itemData["proc_icd"] = ""
    end

	-- 274441 - Barbed Shot has a chance equal to your critical strike chance to grant you 298 Agility for 8 sec.
    if rank == 274441 then
        itemData["proc_name"] = select(1, GetSpellInfo(rank)) 
        itemData["proc_info"] = string.format("%.2f%%", GetCritChance())
	end

	return itemData

end

function AppendStatInfo(frame, frame_text, stat_value, stat_type, stat_name, stat_string)
	
	-- Note, GetItemStats is NOT used here. This function is useful,
	--but it would be nice to add stat info for Gems and Enchants!

	local stat_array = {
		[9] = BetterTooltips.crit_scaling,
		[14] = BetterTooltips.speed_scaling,
		[17] = BetterTooltips.leech_scaling,
		[18] = BetterTooltips.haste_scaling,
		[21] = BetterTooltips.avoidance_scaling,
		[26] = BetterTooltips.mastery_scaling,
		[29] = BetterTooltips.vers_damage_scaling
	}

	rating_coef = stat_array[stat_type][UnitLevel("player")]

	if stat_value == nil then return end

	if stat_type == 26 then
		-- Mastery, special
		mastery = stat_value / rating_coef
		mastery = mastery * select(2, GetMasteryEffect())
		s = string.gsub(frame_text, stat_string.." "..stat_name, string.format("%s %s "..formatWithCurrentColor(string.format("(%.2f%%%%%%%%)", mastery)), stat_string, stat_name))
		s2 = string.gsub(s, stat_name.." by "..stat_string, string.format("%s by %s "..formatWithCurrentColor(string.format("(%.2f%%%%%%%%)", mastery)), stat_name, stat_string, mastery))
		frame:SetText(s2)
	else
		s = string.gsub(frame_text, stat_string.." "..stat_name, string.format("%s %s "..formatWithCurrentColor(string.format("(%.2f%%%%%%%%)", stat_value / rating_coef)), stat_string, stat_name))
		s2 = string.gsub(s, stat_name.." by "..stat_string, string.format("%s by %s "..formatWithCurrentColor(string.format("(%.2f%%%%%%%%)", stat_value / rating_coef)), stat_name, stat_string, stat_value / rating_coef))
		frame:SetText(s2)
	end

end

function IsComboStats(frame, text)
	-- This function covers the following cases:
	-- Increases your Haste, Mastery or Critical Strike by X for 5 seconds
	-- We want to show Haste (%), Mastery (%), or Critical Strike (%)

	-- Check first for all 4.

	local stat_array = {
		[9] = BetterTooltips.crit_scaling,
		[14] = BetterTooltips.speed_scaling,
		[17] = BetterTooltips.leech_scaling,
		[18] = BetterTooltips.haste_scaling,
		[21] = BetterTooltips.avoidance_scaling,
		[26] = BetterTooltips.mastery_scaling,
		[29] = BetterTooltips.vers_damage_scaling
	}

	numberStatsInString = 0
	for k,v in pairs(all_stats) do
		if string.find(text, v) then
			numberStatsInString = numberStatsInString + 1
		end
	end

	if numberStatsInString < 2 then
		return false -- Only 1 stat.
	end

	stat_value = nil
	for k,v in pairs(all_stats) do
		if stat_value == nil then
			stat_value = string.match(text, "and "..v.." by ([,%d]+)[^%%]")
			if stat_value == nil then
				stat_value = string.match(text, "or "..v.." by ([,%d]+)[^%%]")
			end
		end
	end

	if stat_value == nil then return false end

	stat_value = string.gsub(stat_value, ",", "")

	-- Ok, we have a value for each stat, replace the name with the name + stat %
	for k,v in pairs(all_stats) do

		rating_coef = stat_array[k][UnitLevel("player")]

		if k == 26 then
			-- Mastery, special
			mastery = stat_value / rating_coef
			mastery = mastery * select(2, GetMasteryEffect())
			text = string.gsub(text, v, string.format("%s "..formatWithCurrentColor(string.format("(%.2f%%%%%%%%)", tonumber(mastery))), v))
		else
			text = string.gsub(text, v, string.format("%s "..formatWithCurrentColor(string.format("(%.2f%%%%%%%%)", tonumber(stat_value) / rating_coef)), v))
		end

		
	end

	frame:SetText(text)

end

function updateStats(frame, text, arr)
	
	-- validate inputs
	if arr == nil then
		return
	end

	for k,v in pairs(arr) do
		for sdata in string.gmatch(text, "([,%d]+) "..v) do
			if sdata ~= nil then
				sdata_raw = sdata
				sdata = string.gsub(sdata, ",", "")
				AppendStatInfo(frame, text, tonumber(sdata), k, v, sdata_raw)
				text = frame:GetText() -- refresh the text string
			end
		end


		for sdata in string.gmatch(text, v.." by ".."([,%d]+[^%%]) ") do
			if sdata ~= nil then
				sdata_raw = sdata
				sdata = string.gsub(sdata, ",", "")
				AppendStatInfo(frame, text, tonumber(sdata), k, v, sdata_raw)
				text = frame:GetText() -- refresh the text string
			end
		end
	end
end

function scanStats(tooltip)

	-- Don't display stat conversion if the user disabled it.
	if BetterTooltips_Config.stats == false then return end

	for i = 1,30 do
		local frame = _G[tooltip:GetName() .. "TextLeft" .. i]
		local text
		local right
		if frame then text = frame:GetText() end
		if text then
			if IsComboStats(frame, text) == false then
				updateStats(frame, text, stats)
				text = frame:GetText() -- get the updated text prior to updating tertiary
				updateStats(frame, text, tertiary_stats)

				
			-- %d critical strike rating (some do this)
				sdata = string.match(text, "([,%d]+) critical strike rating")
				if sdata ~= nil then
					sdata_raw = sdata
					sdata = string.gsub(sdata, ",", "")
					AppendStatInfo(frame, text, tonumber(sdata), 9, "critical strike rating", sdata_raw)
					text = frame:GetText() -- refresh the text string
				end

			end
		end
	end
end

function ProcessOneOffs(rank, tooltip, full)
	
	local extendedAscendanceDescription = "The initial heal is divided evenly across all allies\nwithin 20 yards."

	if rank == 288749 and full == true then
		-- replace the phrase all stats in the profile with the correct stats.
		for i = 2,30 do
			local frame = _G[tooltip:GetName() .. "TextLeft" .. i]
			local text
			if frame then text = frame:GetText() end
			if text then
				local newtext = string.gsub(text, "all stats", "all stats "..formatWithCurrentColor("(Primary Stat and Stamina)"))
				frame:SetText(newtext)
			end
		end

	-- Ancestral Resonance, add non-lust RPPM
	elseif rank == 277666 then
		local englishFaction = UnitFactionGroup("player")
		local lustString = "Lust"
		if englishFaction == "Alliance" then
			lustString = "Heroism"
		elseif englishFaction == "Horde" then
			lustString = "Bloodlust"
		end

		local actualRPPM = 1.0 * (1 + UnitSpellHaste("player")/100)
		local actualRPPMString = string.format("%.2f", actualRPPM)

		-- Append (..lustString..) to the existing item already in the tooltip
		for i = 2,30 do
			local frame = _G[tooltip:GetName() .. "TextLeft" .. i]
			local text
			if frame then text = frame:GetText() end
			if text then
				local newtext = string.gsub(text, "^Ancestral Resonance$", formatWithCurrentColor("Ancestral Resonance ("..lustString..")"))
				frame:SetText(newtext)
			end
		end

		tooltip:AddDoubleLine("Ancestral Resonance (No "..lustString..")", "RPPM: 1.00 ("..actualRPPMString..")", BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B, BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B)
	elseif rank == 114052 and alreadyAdded(extendedAscendanceDescription, tooltip) == false then
		tooltip:AddLine(extendedAscendanceDescription, BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B)
	elseif rank == 280021 and full then
		tooltip:AddLine(" ")
		tooltip:AddLine("Rate of healing is increased by haste.", BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B)
	elseif rank == 292752 then
		local zandalariRacial = {}
		zandalariRacial["Akunda"] = "Additional Healing"
		zandalariRacial["Bwonsamdi"] = "Shadow Damage / Self Heal"
		zandalariRacial["Gonk"] = "5% Move Speed"
		zandalariRacial["Kimbul"] = "Bleed"
		zandalariRacial["Krag'wa"] = "Health and Armor"
		zandalariRacial["Pa'ku"] = "4% Critical Strike"

		
		tooltip:AddLine(" ")
		for k,v in pairs(zandalariRacial) do
			tooltip:AddDoubleLine(k, v, BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B, BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B)
		end
	end
end

function SpellTooltip(rank, tooltip)
	str = ""
	str2 = ""
	Header = false
	if BetterTooltips.SpellData[rank] ~= nil then
		local str = GetSpellChanceInfo(rank)["proc_name"]
        local str2 = GetSpellChanceInfo(rank)["proc_info"]
        local str3 = GetSpellChanceInfo(rank)["proc_icd"]
		
		-- work around the talent bug (calls OnSetTooltipSpell twice)
        if str2 ~= "" and alreadyAdded(str2, tooltip) then
			return
		elseif str3 ~= "" and alreadyAdded(str3, tooltip) then
			return
		end

		-- Seperator line, only if we're adding information
		-- don't return here so we can bring in reorigination array below (archive has no proc)
		if (str2~= "" or str3~="") then 
			tooltip:AddLine(" ")
			header = true
		end

		if str2 ~= "" then
			tooltip:AddDoubleLine(str, str2, BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B, BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B)
        end
        
        if str3 ~= "" then
            tooltip:AddDoubleLine(" ", str3, BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B, BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B)
        end
	end
	
	-- Archive and Laser Matrix
	if rank == 280555 or rank == 280559 then
		AddReoriginationInfo(tooltip)
	end

	-- Try collecting stats
	scanStats(tooltip)

	-- Add any hand driven information.
	ProcessOneOffs(rank, tooltip, true)

end


function GetAzeriteSpellID(powerID)
	local powerInfo = C_AzeriteEmpoweredItem.GetPowerInfo(powerID)
  	if (powerInfo) then
    	local azeriteSpellID = powerInfo["spellID"]
    	return azeriteSpellID
  	end
end



function ScanForTrait(tooltip, powerName)
	-- AzeriteTooltip replaces the tooltip.
	-- Depending on the order of events (and I have NO idea of the order)
	-- we will get called either first or second, so we need to check for BOTH
	-- forms of the trait.
	-- |cFF00FF00 |T2000853::20:20:0:0:64:64:4:60:4:60|t {Name}|r
	-- is what we're looking for. We will gsub their
	-- \124 characters to \124\124
	local atooltipPattern = "||cFF00FF00%s-||T%d-:20:20:0:0:64:64:4:60:4:60||t%s-"..powerName.."||r"
	for i = 8, tooltip:NumLines() do
		local left = _G[tooltip:GetName().."TextLeft"..i]
		local text = left:GetText()
		if text ~= nil then
			local isATP = gsub(text, "\124", "\124\124"):match("||T%d+") ~= nil
			if text:find(powerName) and isATP == false then
				return true
			elseif gsub(text, "\124", "\124\124"):match(atooltipPattern, 1) then
				return true
			end
		end
    end
end

function AddEnchantInfo(tooltip, itemHeaderAdded, spellID)
	spellData = GetSpellChanceInfo(spellID)
	if spellData ~= nil then
		if itemHeaderAdded == false then
			tooltip:AddLine(" ")
        end
        -- Remove (DND) from some enchant strings.
        tooltip:AddDoubleLine(gsub(spellData["proc_name"], "%(DND%)", ""), spellData["proc_info"], BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B, BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B)
        if spellData["proc_icd"] ~= "" then
            tooltip:AddDoubleLine(" ", spellData["proc_icd"], BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B, BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B)
        end
	end
end

function ProcessItemOneOffs(id, header, tooltip)

	-- Ward of Envelopment
	-- Increased by 7.5% per ally, up to 30%
	if id == 165569 then

		if header == false then
			tooltip:AddLine(" ")
        end

		tooltip:AddLine("Absorption increased by 7.5% per ally, up to 30%.", BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B)
	elseif id == 165928 or id == 165928 or id == 165926 or id == 152632 then
		tooltip:AddLine(" ")
		tooltip:AddDoubleLine("Potion of Replenishment", "35,084", BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B, BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B)
		tooltip:AddDoubleLine("Coastal Mana Potion", "15,557", BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B, BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B)
		tooltip:AddDoubleLine("Coastal Rejuvenation Potion", "11,668", BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B, BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B)
	elseif id == 165567 or id == 165512 then
		tooltip:AddLine(" ")
		tooltip:AddLine("The following instances count as in Zuldazar:\nBattle for Dazar'alor, King's Rest, Atal'Dazar", BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B)	
	end


end


function OnTooltip_Item(self, tooltip)
	local isUldirItem = false
	local itemHeaderAdded = false

	local name,link = self:GetItem()

	if link == nil then
		sn,sid = self:GetSpell()
		if sid ~= nil and sid ~= 0 then
			AddEnchantInfo(tooltip, itemHeaderAdded, sid)
		end
		return
	end

	ProcessItem(link, tooltip)

	-- Azerite check
	if C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(linkToID(link)) then
        local tierInfo = C_AzeriteEmpoweredItem.GetAllTierInfoByItemID(link, select(3, UnitClass("player")))
        for i=1,4,1 do
            if tierInfo[i] ~= nil then
                for k,v in pairs(tierInfo[i]["azeritePowerIDs"]) do
                    if ScanForTrait(self, select(1, GetSpellInfo(GetAzeriteSpellID(v)))) then
						local spellInfo = GetSpellChanceInfo(GetAzeriteSpellID(v))
						if spellInfo ~= nil then
							-- If we have strings
							if spellInfo["proc_name"] ~= nil and string.len(spellInfo["proc_name"]) > 0 then
								if itemHeaderAdded == false then
									tooltip:AddLine(" ")
									itemHeaderAdded = true
								end
								tooltip:AddDoubleLine(spellInfo["proc_name"], spellInfo["proc_info"], BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B, BetterTooltips_Config.R, BetterTooltips_Config.G, BetterTooltips_Config.B)
								ProcessOneOffs(GetAzeriteSpellID(v), tooltip, false)
							end
						end
					end

					-- Check for Laser Matrix or Archive
					if i == 1 and (v == 485 or v == 483) then
						isUldirItem = true
					end
				end
			end
		end
	end

	if isUldirItem then
		-- Laser matrix or Archive...
		AddReoriginationInfo(tooltip)
	end


	-- Weapon Enchant
	if itemEnchant(link) ~= nil and itemEnchant(link) ~= 0 then
		if BetterTooltips.EnchantData[itemEnchant(link)] ~= nil then
			AddEnchantInfo(tooltip, itemHeaderAdded, BetterTooltips.EnchantData[itemEnchant(link)])
		end
    end

	-- Logic for looking at weapon enchants items
	if BetterTooltips.BackupData[linkToID(link)] ~= nil then
		AddEnchantInfo(tooltip, itemHeaderAdded, BetterTooltips.EnchantData[BetterTooltips.BackupData[linkToID(link)]])
	end

	-- collect stat data
	scanStats(tooltip)

	-- Add any custom tooltip data
	ProcessItemOneOffs(linkToID(link), itemHeaderAdded, tooltip)

	tooltip:Show()
end

function OnTooltipSpell(self, tooltip)
	-- Case for linked spell
	local name,rank,id = self:GetSpell()
	if rank ~= nil then
		SpellTooltip(rank, tooltip)
	end
	tooltip:Show()
end


function BetterTooltips:OnEnable()
	
	--if _G["BetterTooltips_Config.stats"] == nil then BetterTooltips_Config.stats = true else BetterTooltips_Config.stats = _G["BetterTooltips_Config.stats"] end
	--if _G["BetterTooltips_Config.R"] == nil then BetterTooltips_Config.R = 0.0 else BetterTooltips_Config.R = _G["BetterTooltips_Config.R"] end
	--if _G["BetterTooltips_Config.G"] == nil then BetterTooltips_Config.G = .7 else BetterTooltips_Config.G = _G["BetterTooltips_Config.G"] end
	--if _G["BetterTooltips_Config.B"] == nil then BetterTooltips_Config.B = .7 else BetterTooltips_Config.B = _G["BetterTooltips_Config.B"] end

	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(...)
		if tooltip == GameTooltip or tooltip == ItemRefTooltip or tooltip == ShoppingTooltip1 or tooltip == ShoppingTooltip2 then
			OnTooltip_Item(..., tooltip)
		end
	end)
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, function(...)
		if tooltip == GameTooltip or tooltip == ItemRefTooltip then
			OnTooltipSpell(..., tooltip)
		end
	end)
end

function BetterTooltips:AfterEnable()

end