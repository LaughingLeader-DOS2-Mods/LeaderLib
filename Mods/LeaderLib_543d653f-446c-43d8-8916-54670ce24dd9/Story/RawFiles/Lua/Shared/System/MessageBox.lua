local isClient = Ext.IsClient()

MessageBox = {}

---@private
function MessageBox:FireEvent(id, isConfirmed, character)
	if isClient then
		if not character then
			character = Client:GetCharacter()
		end
		Ext.PostMessageToServer("LeaderLib_MessageBoxEvent", Ext.JsonStringify({ID=id, IsConfirmed=isConfirmed, NetID=character.NetID}))
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
		RegisterListener("MessageBoxEvent", id, callback)
	elseif t == "function" then
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
			MessageBox:FireEvent(data.ID, data.IsConfirmed, Ext.GetCharacter(data.NetID))
		end
	end)
end

if isClient then

	---@alias MessageBoxEventID string|'"CharacterCreationConfirm"'|'"CharacterCreationCancel"'

	local ButtonConfirmations = {
		CharacterCreationCancel = {
			IsActive = function(this) return StringHelpers.Equals(this.popup_mc.title_txt.htmlText, LocalizedText.MessageBox.CancelChangesTitle.Value, true, true) end,
			Yes = 1
		},
		CharacterCreationConfirm = {
			IsActive = function(this) return StringHelpers.Equals(this.popup_mc.text_mc.text_txt.htmlText, LocalizedText.MessageBox.HasPointsDescription.Value, true, true) end,
			Yes = 1
		}
	}

	local function MessageBoxButtonPressed(wrapper, ui, call, buttonId, currentDeviceId)
		local this = ui:GetRoot()
		for id,data in pairs(ButtonConfirmations) do
			if data.IsActive(this) then
				MessageBox:FireEvent(id, buttonId == data.Yes)
				return
			end
		end
	end

	Ext.RegisterListener("SessionLoaded", function()
		---@class MessageBoxWrapper:LeaderLibUIWrapper
		MessageBox.UI = Classes.UIWrapper:CreateFromType(Data.UIType.msgBox, {ControllerID = Data.UIType.msgBox_c, IsControllerSupported = true})
		MessageBox.UI:RegisterCallListener("ButtonPressed", MessageBoxButtonPressed, "After", "All")
	end)
end

MessageBox:RegisterListener("All", function(event, isConfirmed, player)
	fprint(LOGLEVEL.DEFAULT, "[MessageBox:MessageBoxEvent(%s)] event(%s) player(%s) isConfirmed(%s)", Ext.IsServer() and "SERVER" or "CLIENT", event, player.DisplayName, isConfirmed)
end)