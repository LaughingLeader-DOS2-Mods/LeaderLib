--[[
This script allows tooltips to be re-rendered when shift is pressed or released,
allowing mods to alter how much text/info they provide in a tooltip.

Mods should check tooltip.IsExpanded() when determining which text to write, 
and call tooltip.MarkDirty() when the current tooltip can be changed when the key is pressed or released.
]]

if not TooltipExpander then
	---@see TooltipExpander#MarkDirty
	---@see TooltipExpander#IsExpanded
	TooltipExpander = {}
end

local _last = {
	DefaultTooltipData = nil,
	---@type AnyTooltipRequest
	Request = nil
}

local dirty = false
local rebuildingTooltip = false
TooltipExpander.KeyboardKey = "SplitItemToggle"--Data.Input.SplitItemToggle
TooltipExpander.ControllerKey = "ToggleMap"

TooltipExpander.CallData = {
	---@type integer
	UI = nil,
	---@type table
	Args = nil,
	---@type string
	LastCall = nil
}

---Signals to the expander that pressing or releasing the expand key will cause the current visible tooltip to re-render.
function TooltipExpander.MarkDirty()
	dirty = true
end

---@return boolean
function TooltipExpander.IsDirty()
	return dirty
end

---Whether or not the tooltip should be expanded. Check this when setting up tooltip elements.
---@return boolean
function TooltipExpander.IsExpanded()
	if GameSettings.Settings.Client.AlwaysExpandTooltips then
		return true
	end
	if not Vars.ControllerEnabled then
		return Input.IsPressed(TooltipExpander.KeyboardKey)
	else
		return Input.IsPressed(TooltipExpander.ControllerKey)
	end
end

local function SaveTooltipData(ui, call, ...)
	dirty = false
	if not rebuildingTooltip then
		_last.DefaultTooltipData = nil
		_last.Request = nil
		TooltipExpander.CallData.UI = ui:GetTypeId()
		TooltipExpander.CallData.Args = {...}
		TooltipExpander.CallData.LastCall = call
	end
	rebuildingTooltip = false
end

local calls = {
	"showSkillTooltip",
	"showStatusTooltip",
	"showItemTooltip",
	"showStatTooltip",
	"showAbilityTooltip",
	"showTalentTooltip",
	"showTagTooltip",
	"showCustomStatTooltip",
	"showRuneTooltip",
	"showTooltip",
}

for i,v in pairs(calls) do
	Ext.RegisterUINameCall(v, SaveTooltipData, "Before")
end

local controller_calls = {
	"itemDollOver",
	"overItem",
	"refreshTooltip",
	"requestAbilityTooltip",
	"requestAttributeTooltip",
	"requestSkillTooltip",
	"requestTagTooltip",
	"requestTalentTooltip",
	"runeSlotOver",
	"selectCustomStat",
	"selectedAttribute",
	"setTooltipPanelVisible",
	"setTooltipVisible",
	"SlotHover",
	"slotOver",
	"showTooltip",
}

for i,v in pairs(controller_calls) do
	Ext.RegisterUINameCall(v, function(ui, call, ...)
		if Vars.ControllerEnabled then
			SaveTooltipData(ui, call, ...)
		end
	end, "Before")
end

local function OnHideTooltip(ui, call, ...)
	_last.DefaultTooltipData = nil
	_last.Request = nil
	dirty = false
	if not rebuildingTooltip then
		TooltipExpander.CallData = {}
	end
end

Ext.RegisterUINameCall("hideTooltip", OnHideTooltip, "After")
--playerInfo/summonInfo.as
Ext.RegisterUINameCall("hidetooltip", OnHideTooltip, "After")

local function _addFormattedTooltip(this, x, y, deferShow)
	-- if this.tf then
	-- 	this.INTRemoveTooltip()
	-- end

	if this.tf == nil then
		this.tf = this.formatTooltip
	end

	--this.tf.visible = false;
	this.tf.scaleX = 1; this.tf.scaleY = 1;
	this.tooltip_mc.tt_mc.x = 0;
	if #this.tooltipCompare_array > 0 then
		this.addCompareTooltip(this.tooltipCompare_array)
	end
	this.tooltip_mc.tt_mc.targetX = 0;
	if #this.tooltipOffHand_array > 0 then
		this.addCompareOffhandTooltip(this.tooltipOffHand_array)
	end
	--this.tooltip_mc.tt_mc.addChild(this.tf);
	--FIX Can't pass arrays (userdata) to flash functions
	this.tf.tooltip_mc.setupTooltip(this.tooltip_array,20)
	this.tf.alpha = 0
	this.tf.tooltip_mc.y = this.tf.tooltip_mc.isEquipped and 0 or this.cEquippedSpacing
	this.tooltip_mc.ttX = x
	this.tooltip_mc.ttY = y
	this.tf.widthOverride = -1
	this.checkTooltipBoundaries(this.getTooltipWidth(),this.getTooltipHeight(), x + this.frameSpacing, y + this.frameSpacing)
	if not this.compareMode or not deferShow then
		this.INTshowTooltip()
	end
end

---@param ui UIObject
---@param propertyName string
---@param req AnyTooltipRequest
---@param method string
local function _TooltipHooks_RenderRebuiltSubTooltip(self, tt, tooltip, ui, propertyName, req, method, ...)
	Game.Tooltip.TooltipHooks._RunNotifyListeners(self, req, ui, method, tooltip, ...)
	local newTooltip = Game.Tooltip.EncodeTooltipArray(tooltip.Data)
	if newTooltip ~= nil then
		Game.Tooltip.ReplaceTooltipArray(ui, propertyName, newTooltip, tt)
	end
end

---@param arrayData TooltipArrayData
---@param ui UIObject
function _TooltipHooks_RebuildTooltip(self, arrayData, ui, method, ...)
	local EncodeTooltipArray = Game.Tooltip.EncodeTooltipArray
	local TooltipData = Game.Tooltip.TooltipData
	local TableFromFlash = Game.Tooltip.TableFromFlash
	local TableToFlash = Game.Tooltip.TableToFlash
	local TooltipHooks = Game.Tooltip.TooltipHooks

	self.IsOpen = true
	
	---@type TooltipItemRequest
	local req = _last.Request.Main
	self.ActiveType = req.Type
	self.Last.Type = req.Type
	self.Last.ArrayData = arrayData

	local arrayId = arrayData.Main
	local compareMain = arrayData.CompareMain
	local compareOff = arrayData.CompareOff
	local checkCompare = req.Type == "Item"

	local mainTooltipData = TableHelpers.Clone(_last.DefaultTooltipData.Main)
	local compare1TooltipData = _last.DefaultTooltipData.Compare1 and TableHelpers.Clone(_last.DefaultTooltipData.Compare1)
	local compare2TooltipData = _last.DefaultTooltipData.Compare2 and TableHelpers.Clone(_last.DefaultTooltipData.Compare2)

	local this = ui:GetRoot()
	local uiType = ui:GetTypeId()

	local mainTooltip = TooltipData:Create(mainTooltipData, uiType, req.UIType)
	TableToFlash(ui, arrayId, EncodeTooltipArray(mainTooltip.Data), this)
	local mainTT = TableFromFlash(ui, arrayId, this)

	_TooltipHooks_RenderRebuiltSubTooltip(self, mainTT, mainTooltip, ui, arrayId, req, method, ...)
	
	--equipmentPanel_c updates each array in separate invokes, so we don't need to setup comparison tooltips
	if checkCompare then
		local reqItem = req.Item
		local mainArray = compareMain and this[compareMain]
		local compareArray = compareOff and this[compareOff]

		if mainArray and compare1TooltipData then
			local compareItem = self:GetCompareItem(ui, reqItem, false)
			if compareItem ~= nil then
				if GameHelpers.IsValidHandle(compareItem.Handle) then
					local compareTooltip = TooltipData:Create(compare1TooltipData, uiType, req.UIType)
					TableToFlash(ui, compareMain, EncodeTooltipArray(compareTooltip.Data), this)
					local compareTT = TableFromFlash(ui, compareMain, this)

					local compareReq = _last.Request.Compare1
					_TooltipHooks_RenderRebuiltSubTooltip(self, compareTT, compareTooltip, ui, compareMain, compareReq, method, ...)
				elseif Vars.DebugMode then
					Ext.PrintError("compareItem.Handle is nil?", Ext.DumpExport(compareItem))
				end
			else
				Ext.PrintError("Tooltip compare render failed: Couldn't find item to compare", method, compareMain)
			end
		end

		if compareArray and compare2TooltipData then
			local compareItem = self:GetCompareItem(ui, reqItem, true)
			if compareItem ~= nil then
				if GameHelpers.IsValidHandle(compareItem.Handle) then
					local compareTooltip = TooltipData:Create(compare2TooltipData, uiType, req.UIType)
					TableToFlash(ui, compareOff, EncodeTooltipArray(compareTooltip.Data), this)
					local compareTT = TableFromFlash(ui, compareOff, this)
					local compareReq = _last.Request.Compare2
					_TooltipHooks_RenderRebuiltSubTooltip(self, compareTT, compareTooltip, ui, compareOff, compareReq, method, ...)		
				elseif Vars.DebugMode then
					Ext.PrintError("compareItem.Handle is nil?", Ext.DumpExport(compareItem))
				end
			else
				Ext.PrintError("Tooltip compare render failed: Couldn't find off-hand item to compare", method, compareOff)
			end
		end
	end

	self.Last.Request = self.NextRequest
	self.NextRequest = nil
	return true
end

local function RebuildTooltip(pressed)
	local lastDirty = dirty
	if dirty then
		if TooltipExpander.CallData.Args ~= nil then
			--if TooltipExpander.CallData.LastCall == "showTooltip" then
			if Game.Tooltip.TooltipHooks.Last.Type == "Generic" then
				rebuildingTooltip = true
				dirty = false
				local ui = Ext.GetUIByType(Data.UIType.tooltip)
				local text, x, y, width, height, side, allowDelay = table.unpack(TooltipExpander.CallData.Args)

				---@type TooltipGenericRequest
				local request = Game.Tooltip.RequestProcessor.CreateRequest()
				request.Type = "Generic"
				request.Text = text
				request.CallingUIType = TooltipExpander.CallData.UI
				request.X = x
				request.Y = y
				request.Width = width
				request.Height = height
				request.Side = side
				request.AllowDelay = allowDelay

				local this = ui:GetRoot()
				if this and this.tf then
					request.AllowDelay = this.tf.allowDelay
					request.BackgroundType = this.tf.bg_mc and this.tf.bg_mc.visible == true and 0 or 1
				end

				local tooltip = Game.Tooltip.TooltipData:Create(request)
				Game.Tooltip.TooltipHooks:NotifyListeners("Generic", nil, request, tooltip)

				if this and this.tf then
					this.tf.shortDesc = tooltip.Data.Text

					if this.tf.setText then
						this.tf.setText(tooltip.Data.Text,tooltip.Data.BackgroundType or 0)
					else
						Ext.PrintError(this.tf.name)
					end

					this.checkTooltipBoundaries(this.getTooltipWidth(),this.getTooltipHeight(), tooltip.Data.X + this.frameSpacing, tooltip.Data.Y + this.frameSpacing)

					if tooltip.Data.BackgroundType and tooltip.Data.BackgroundType > 0 and tooltip.Data.BackgroundType < 5 then
						ui:ExternalInterfaceCall("keepUIinScreen", true)
					else
						ui:ExternalInterfaceCall("keepUIinScreen", false)
					end
				end
			elseif _last.DefaultTooltipData ~= nil and _last.DefaultTooltipData.Main ~= nil then
				local event = TooltipExpander.CallData.LastCall
				local arrayData = Game.Tooltip.TooltipArrayNames.Default
				local x,y = table.unpack(Game.Tooltip.TooltipHooks.Last.Position)

				rebuildingTooltip = true
				dirty = false

				if _last.Request == nil or _last.Request.Main == nil then
					_last.Request = {
						Main = Game.Tooltip.TooltipHooks.Last.Request
					}
				else
					Game.Tooltip.TooltipHooks.Last.UIType = _last.Request.Main.UIType
				end

				Game.Tooltip.TooltipHooks.Last.Event = event
				
				local ttUI = Ext.UI.GetByType(Data.UIType.tooltip)
				local this = ttUI:GetRoot()
				if _TooltipHooks_RebuildTooltip(Game.Tooltip.TooltipHooks, arrayData, ttUI, event) then
					this.addFormattedTooltip(x, y, false)
					--_addFormattedTooltip(this, x, y, false)
					this.showFormattedTooltipAfterPos(false)
				end
			elseif TooltipExpander.CallData.UI ~= nil then
				local ui = Ext.GetUIByType(TooltipExpander.CallData.UI)
				if ui then
					rebuildingTooltip = true
					dirty = false
					ui:ExternalInterfaceCall("hideTooltip")
					ui:ExternalInterfaceCall(TooltipExpander.CallData.LastCall, table.unpack(TooltipExpander.CallData.Args))
					return
				end
			end
		end
	end
	rebuildingTooltip = false
	return lastDirty ~= dirty
end

--[[ Ext.Events.UICall:Subscribe(function (e)
	if rebuildingTooltip and e.When == "Before" then
		if e.Function == "hideTooltip" then
			e:PreventAction()
		end
	end
end) ]]

function TooltipExpander.OnKeyPressed(pressed)
	return RebuildTooltip(pressed)
end

local tooltipTypeToElement = {
	Ability = "AbilityDescription",
	CustomStat = "StatsDescription",
	Item = "ItemDescription",
	Rune = "ItemDescription",
	Skill = "SkillDescription",
	Stat = "StatsDescription",
	Status = "StatusDescription",
	Tag = "TagDescription",
	Talent = "TalentDescription",
}
TooltipExpander.TooltipTypeToElement = tooltipTypeToElement

---@param request TooltipRequest
---@param tooltip TooltipData
function TooltipExpander.AppendHelpText(request, tooltip)
	local canShowText = not GameSettings.Settings.Client.AlwaysExpandTooltips and (not Vars.ControllerEnabled or Vars.DebugMode)
	if canShowText and TooltipExpander.IsDirty() then
		local keyText = not Vars.ControllerEnabled and LocalizedText.Input.Shift.Value or LocalizedText.Input.Select.Value
		if request.Type == "Generic" then
			local format = "<br><br><p align='center'><font color='#44CC00'>%s</font></p>"
			if TooltipExpander.IsExpanded() then
				tooltip.Data.Text = tooltip.Data.Text .. string.format(format, LocalizedText.Tooltip.ExpanderActive:ReplacePlaceholders(keyText))
			else
				tooltip.Data.Text = tooltip.Data.Text .. string.format(format, LocalizedText.Tooltip.ExpanderInactive:ReplacePlaceholders(keyText))
			end
		else
			local elementType = tooltipTypeToElement[request.Type]
			local element = tooltip:GetLastElement(elementType)
			--Create a description tooltip element if one doesn't exist
			if element == nil then
				local spec = Game.Tooltip.TooltipSpecs[elementType]
				if spec then
					element = {}
					for _,field in pairs(spec) do
						local fieldName = field[1]
						local t = field[2]
						if t == "string" then
							element[fieldName] = ""
						elseif t == "number" then
							element[fieldName] = 0
						elseif t == "boolean" then
							element[fieldName] = false
						end
					end
				end
			end
			if element then
				local target = element.Label or element.Description
				if target then
					local nextText = target
					local format = "<font color='#44CC00'>%s</font>"
					if not string.find(nextText, "<br>", #nextText-5, true) then
						format = "<br>"..format
					end
					if TooltipExpander.IsExpanded() then
						nextText = nextText .. string.format(format, LocalizedText.Tooltip.ExpanderActive:ReplacePlaceholders(keyText))
					else
						nextText = nextText .. string.format(format, LocalizedText.Tooltip.ExpanderInactive:ReplacePlaceholders(keyText))
					end
					if element.Label then
						element.Label = nextText
					elseif element.Description then
						element.Description = nextText
					end
				end
			end
		end
	end
end


local tooltipCustomIcons = {}
Ext.Events.SessionLoaded:Subscribe(function()
	---Simple variable a mod can check to see if this is a LeaderLib tooltip.
	Game.Tooltip.TooltipData.IsExtended = true

	---Whether or not the tooltip should be expanded. Check this when setting up tooltip elements.
	---@return boolean
	Game.Tooltip.TooltipData.IsExpanded = function(self)
		return TooltipExpander.IsExpanded()
	end

	---Signals to the tooltip expander that pressing or releasing the expand key will cause the current visible tooltip to re-render.
	Game.Tooltip.TooltipData.MarkDirty = function(self)
		return TooltipExpander.MarkDirty()
	end

	Game.Tooltip.PrepareIcon = function(ui, id, icon, w, h)
		ui:SetCustomIcon(id, icon, w, h)
		tooltipCustomIcons[#tooltipCustomIcons+1] = id
	end

	Game.Tooltip.RegisterBeforeNotifyListener(function (request, ui, method, tooltip)
		if _last.Request == nil then
			_last.Request = {}
		end
		
		if not rebuildingTooltip then
			if not TooltipExpander.IsExpanded() then
				if _last.DefaultTooltipData == nil then
					_last.DefaultTooltipData = {}
				end
				local lastExpanded = _last.DefaultTooltipData
				if not lastExpanded.Main then
					lastExpanded.Main = TableHelpers.Clone(tooltip.Data)
					_last.Request.Main = TableHelpers.Clone(request, true)
				elseif not lastExpanded.Compare1 then
					lastExpanded.Compare1 = TableHelpers.Clone(tooltip.Data)
					_last.Request.Compare1 = TableHelpers.Clone(request, true)
				elseif not lastExpanded.Compare2 then
					lastExpanded.Compare2 = TableHelpers.Clone(tooltip.Data)
					_last.Request.Compare2 = TableHelpers.Clone(request, true)
				end
			end
			if not _last.Request.Main then
				_last.Request.Main = TableHelpers.Clone(request, true)
			elseif not _last.Request.Compare1 then
				_last.Request.Compare1 = TableHelpers.Clone(request, true)
			elseif not _last.Request.Compare2 then
				_last.Request.Compare2 = TableHelpers.Clone(request, true)
			end
		end
	end)

	Game.Tooltip.Register.Global(function (request, tooltip, ...)
		if Vars.DebugMode and Vars.LeaderDebugMode then
			local text = "local tooltip = " .. Lib.serpent.dump({
				_Type = request.Type,
				Request = request,
				Tooltip = tooltip,
				Params = {...},
			}, {SimplifyUserdata=true})
			GameHelpers.IO.SaveFile("Dumps/LastTooltip.lua", text)
			GameHelpers.IO.SaveFile(string.format("Dumps/Tooltips/%s_%sTooltip.lua", Ext.MonotonicTime(), request.Type), text)
		end
		TooltipExpander.AppendHelpText(request, tooltip)
	end)
end)

Ext.RegisterUINameCall("hideTooltip", function (ui, call, ...)
	local tt = Ext.GetUIByType(Data.UIType.tooltip)
	if tt then
		if #tooltipCustomIcons > 0 then
			for _,v in pairs(tooltipCustomIcons) do
				tt:ClearCustomIcon(v)
			end
			tooltipCustomIcons = {}
		end
	end
end, "After")