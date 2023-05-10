local isClient = Ext.IsClient()

MessageBox = {}

---@private
function MessageBox:FireEvent(id, isConfirmed, character)
	if isClient then
		if not character then
			character = Client:GetCharacter()
		end
		Ext.Net.PostMessageToServer("LeaderLib_MessageBoxEvent", Common.JsonStringify({ID=id, IsConfirmed=isConfirmed, NetID=character.NetID}))
	end
	InvokeListenerCallbacks(Listeners.MessageBoxEvent.All, id, isConfirmed, character)
	InvokeListenerCallbacks(Listeners.MessageBoxEvent[id], id, isConfirmed, character)
end

local self = MessageBox

---@param id MessageBoxEventID|MessageBoxEventID[]|MessageBoxEventListener
---@param callback MessageBoxEventListener|nil
function MessageBox:RegisterListener(id, callback)
	local t = type(id)
	if t == "string" then
		if StringHelpers.Equals(id, "all", true) then
			id = "All"
		end
		---@diagnostic disable-next-line
		RegisterListener("MessageBoxEvent", id, callback)
	elseif t == "function" then
		---@diagnostic disable-next-line
		RegisterListener("MessageBoxEvent", "All", callback)
	elseif t == "table" then
		for _,v in pairs(id) do
			self:RegisterListener(v, callback)
		end
	end
end

if not isClient then
	Ext.RegisterNetListener("LeaderLib_MessageBoxEvent", function(cmd, payload)
		local data = Common.JsonParse(payload)
		if data then
			MessageBox:FireEvent(data.ID, data.IsConfirmed, GameHelpers.GetCharacter(data.NetID))
		end
	end)
end

if isClient then

	---@alias MessageBoxEventID string|"CharacterCreationConfirm"|"CharacterCreationCancel"

	local ButtonConfirmations = {
		CharacterCreationCancel = {
			IsActive = function(this) 
				local text_mc = this.popup_mc.title_txt
				return text_mc and StringHelpers.Equals(text_mc.htmlText, LocalizedText.MessageBox.CancelChangesTitle.Value, true, true) end,
			Yes = 1
		},
		CharacterCreationConfirm = {
			IsActive = function(this)
				local text_mc = nil
				if Vars.ControllerEnabled then
					text_mc = this.popup_mc.text_txt
				else
					text_mc = this.popup_mc.text_mc.text_txt
				end
				return text_mc and StringHelpers.Equals(text_mc.htmlText, LocalizedText.MessageBox.HasPointsDescription.Value, true, true)
			end,
			Yes = 1
		}
	}

	local function MessageBoxButtonPressed(wrapper, e, ui, call, buttonId, currentDeviceId)
		local this = ui:GetRoot()
		for id,data in pairs(ButtonConfirmations) do
			if data.IsActive(this) then
				MessageBox:FireEvent(id, buttonId == data.Yes)
				return
			end
		end
	end

	Ext.Events.SessionLoaded:Subscribe(function()
		---@class MessageBoxWrapper:LeaderLibUIWrapper
		MessageBox.UI = Classes.UIWrapper:CreateFromType(Data.UIType.msgBox, {ControllerID = Data.UIType.msgBox_c, IsControllerSupported = true})
		MessageBox.UI.Register:Call("ButtonPressed", MessageBoxButtonPressed, "After", "All")
	end)
end

MessageBox:RegisterListener("All", function(event, isConfirmed, player)
	fprint(LOGLEVEL.DEFAULT, "[MessageBox:MessageBoxEvent(%s)] event(%s) player(%s) isConfirmed(%s)", Ext.IsServer() and "SERVER" or "CLIENT", event, player.DisplayName, isConfirmed)
end)
