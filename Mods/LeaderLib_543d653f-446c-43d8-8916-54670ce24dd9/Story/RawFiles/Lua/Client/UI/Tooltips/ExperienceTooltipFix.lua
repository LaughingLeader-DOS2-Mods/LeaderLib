Ext.RegisterUITypeInvokeListener(Data.UIType.reward, "setTitle", function(ui, event)
	local hotbar = Ext.GetUIByType(Data.UIType.hotBar)
	if hotbar then
		local this = hotbar:GetRoot()
		this.hotbar_mc.expBar_mc.mouseEnabled = false
		this.hotbar_mc.expBar_mc.mouseChildren = false
		hotbar:ExternalInterfaceCall("hideTooltip")
	end
end)

Ext.RegisterUITypeCall(Data.UIType.reward, "acceptClicked", function(ui, event)
	local hotbar = Ext.GetUIByType(Data.UIType.hotBar)
	if hotbar then
		local this = hotbar:GetRoot()
		this.hotbar_mc.expBar_mc.mouseEnabled = true
		this.hotbar_mc.expBar_mc.mouseChildren = true
	end
end)