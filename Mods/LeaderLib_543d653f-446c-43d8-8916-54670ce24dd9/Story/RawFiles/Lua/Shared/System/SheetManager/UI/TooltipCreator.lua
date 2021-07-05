local customSelection = {
	"selectAbilityCustom",
	"selectStatCustom",
	"selectTalentCustom",
	"selectStatCustom",
	"selectSecStatCustom",
}

local pointRemoved = {
	"minAbilityCustom",
	"minTalentCustom",
	"minStatCustom",
	"minSecStatCustom",
}

local pointAdded = {
	"plusAbilityCustom",
	"plusTalentCustom",
	"plusStatCustom",
	"plusSecStatCustom",
}

local showTooltip = {
	"showAbilityTooltipCustom",
	"showTalentTooltipCustom",
	"showStatTooltipCustom",
}

local lastIconId = 7777
local isVisible = false
local lastTooltipX = nil
local lastTooltipY = nil

local function CreateTooltip(requestedUI, call, id)
	local ui = Ext.GetUIByType(Data.UIType.tooltip)
	if ui then
		local this = ui:GetRoot()
		if this and this.tooltip_array then
			local resolved = false
			--[[
			if call == "showAbilityTooltipCustom" then
				local data = AbilityManager.GetCustomAbility(id)
				this.tooltip_array[0] = Game.Tooltip.TooltipItemTypes.StatName
				this.tooltip_array[1] = data.DisplayName or ""
				this.tooltip_array[2] = Game.Tooltip.TooltipItemTypes.AbilityDescription
				this.tooltip_array[3] = data.IconId
				this.tooltip_array[4] = data.Description or ""
				this.tooltip_array[5] = ""
				this.tooltip_array[6] = ""
				this.tooltip_array[7] = ""

				Game.Tooltip.PrepareIcon(ui, string.format("tt_ability_%i", data.IconId), data.Icon, data.IconWidth or 128, data.IconHeight or 128)
				resolved = true
			elseif call == "showTalentTooltipCustom" then
				local data = TalentManager.GetCustomTalent(id)
				this.tooltip_array[0] = Game.Tooltip.TooltipItemTypes.TalentTitle
				this.tooltip_array[1] = data.DisplayName or ""
				this.tooltip_array[2] = Game.Tooltip.TooltipItemTypes.TalentDescription
				this.tooltip_array[3] = data.IconId
				this.tooltip_array[4] = data.Description or ""
				this.tooltip_array[5] = ""
				this.tooltip_array[6] = ""
				this.tooltip_array[7] = ""

				if data.Icon then
					Game.Tooltip.PrepareIcon(ui, string.format("tt_talent_%i", data.IconId), data.Icon, data.IconWidth or 128, data.IconHeight or 128)
				end
				resolved = true
			elseif call == "showStatTooltipCustom" then
				-- this.tooltip_array[0] = Game.Tooltip.TooltipItemTypes.StatName
				-- this.tooltip_array[1] = displayName or ""
				-- this.tooltip_array[2] = Game.Tooltip.TooltipItemTypes.StatsDescription
				-- this.tooltip_array[3] = iconId
				-- this.tooltip_array[4] = description or ""
				-- this.tooltip_array[5] = ""
				-- this.tooltip_array[6] = ""
				-- this.tooltip_array[7] = ""

				-- Game.Tooltip.PrepareIcon(ui, string.format("tt_ability_%i", iconId), icon, iconWidth or 128, iconHeight or 128)
				-- resolved = true
			end
			]]

			if not resolved then
				this.tooltip_array[0] = Game.Tooltip.TooltipItemTypes.StatName
				this.tooltip_array[1] = string.format("%s_%s", call, id)
				this.tooltip_array[2] = Game.Tooltip.TooltipItemTypes.StatsDescription
				this.tooltip_array[3] = "Testing"
			end

			isVisible = true

			local tf = this.formatTooltip
			if tf then
				lastTooltipX = tf.x
				lastTooltipY = tf.y
			end
			ui:ExternalInterfaceCall("setAnchor","left","mouse","left")
			ui:Invoke("addFormattedTooltip",0,0,true)
			local tf = this.formatTooltip or this.tf
			if tf then
				tf.x = 50
				tf.y = 90
			end
		end
	end
end

local function HideTooltip(ui, call)
	lastIconId = 7777
	if isVisible then
		isVisible = false
		local ui = Ext.GetUIByType(Data.UIType.tooltip)
		if ui then
			ui:Invoke("removeTooltip")
			if lastTooltipX and lastTooltipY then
				local this = ui:GetRoot()
				local tf = this.formatTooltip
				if tf then
					tf.x = lastTooltipX
					tf.y = lastTooltipY
					lastTooltipX = nil
					lastTooltipY = nil
				end
			end
		end
	end
end

Ext.RegisterUINameCall("hideTooltip", HideTooltip, "Before")

for _,v in pairs(showTooltip) do
	Ext.RegisterUITypeCall(Data.UIType.characterCreation, v, CreateTooltip, "Before")
	Ext.RegisterUITypeCall(Data.UIType.characterSheet, v, CreateTooltip, "Before")
	-- Ext.RegisterUITypeCall(Data.UIType.statsPanel_c, v, CreateTooltip, "Before")
	-- Ext.RegisterUITypeCall(Data.UIType.characterCreation_c, v, CreateTooltip, "Before")
end