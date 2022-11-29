--This fixes an issue where if the experience tooltip was open when the reward UI opens, it prevents being able to click on things.

Ext.RegisterUITypeInvokeListener(Data.UIType.reward, "setTitle", function(ui, event)
	local hotbar = Ext.UI.GetByType(Data.UIType.hotBar)
	if hotbar then
		local this = hotbar:GetRoot()
		this.hotbar_mc.expBar_mc.mouseEnabled = false
		this.hotbar_mc.expBar_mc.mouseChildren = false
		hotbar:ExternalInterfaceCall("hideTooltip")
	end
end)

Ext.RegisterUITypeCall(Data.UIType.reward, "acceptClicked", function(ui, event)
	local hotbar = Ext.UI.GetByType(Data.UIType.hotBar)
	if hotbar then
		local this = hotbar:GetRoot()
		this.hotbar_mc.expBar_mc.mouseEnabled = true
		this.hotbar_mc.expBar_mc.mouseChildren = true
	end
end)