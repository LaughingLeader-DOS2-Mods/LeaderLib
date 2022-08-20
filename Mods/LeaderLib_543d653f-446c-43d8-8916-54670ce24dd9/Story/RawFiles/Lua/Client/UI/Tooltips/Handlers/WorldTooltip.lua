local canGetTooltipItem = Ext.GetPickingState ~= nil and not Vars.IsEditorMode

local function InvokeWorldTooltipCallbacks(ui, text, x, y, isFromItem, item)
	local textResult = text
	---@type SubscribableEventInvokeResult<OnWorldTooltipEventArgs>
	local result = Events.OnWorldTooltip:Invoke({
		UI = ui,
		Text = text,
		X = x,
		Y = y,
		IsFromItem = isFromItem,
		Item = item
	})
	textResult = result.Args.Text
	if result.Results then
		for i=1,#result.Results do
			local text = result.Results[i]
			if not StringHelpers.IsNullOrEmpty(text) then
				textResult = text
			end
		end
	end
	return textResult
end

function TooltipHandler.OnTooltipAligned(ui, event, b)
	local main = ui:GetRoot()
	if main and main.tf and main.tf.newBG_mc then
		local text = main.tf.shortDesc
		local param2 = main.tf.newBG_mc.visible and 1 or 0
		if canGetTooltipItem then
			local cursorData = Ext.GetPickingState()
			if cursorData and cursorData.HoverItem then
				local item = GameHelpers.GetItem(cursorData.HoverItem)
				if item then
					local textResult = InvokeWorldTooltipCallbacks(ui, text, main.tf.x, main.tf.y, true, item)
					if textResult ~= text then
						main.tf.shortDesc = textResult
						main.tf.setText(textResult, param2)
					end
				end
			end
		else
			local textResult = InvokeWorldTooltipCallbacks(ui, text, main.tf.x, main.tf.y, false, nil)
			if textResult ~= text then
				main.tf.shortDesc = textResult
				main.tf.setText(textResult, param2)
			end
		end
	end
end

-- Called after addTooltip, so main.tf should be set up.
Ext.RegisterUITypeCall(Data.UIType.tooltip, "keepUIinScreen", TooltipHandler.OnTooltipAligned)

function TooltipHandler.OnWorldTooltipUpdated(ui, event)
	local main = ui:GetRoot()
	if main then
		--public function setTooltip(param1:uint, param2:Number, param3:Number, param4:Number, param5:String, param6:Number, param7:Boolean, param8:uint = 16777215, param9:uint = 0
		--this.setTooltip(val2,val3,val4,val5,val6,this.worldTooltip_array[val2++],this.worldTooltip_array[val2++]);
		for i=0,#main.worldTooltip_array-1,6 do
			local doubleHandle = main.worldTooltip_array[i]
			if doubleHandle then
				local x = main.worldTooltip_array[i+1]
				local y = main.worldTooltip_array[i+2]
				local text = main.worldTooltip_array[i+3]
				--local sortHelper = main.worldTooltip_array[i+4]
				local isItem = main.worldTooltip_array[i+5]
				if isItem then
					local handle = Ext.UI.DoubleToHandle(doubleHandle)
					local item = GameHelpers.GetItem(handle)
					if item then
						local textResult = InvokeWorldTooltipCallbacks(ui, text, x, y, true, item)
						if textResult ~= text then
							main.worldTooltip_array[i+3] = textResult
						end
					end
				else
					local textResult = InvokeWorldTooltipCallbacks(ui, text, x, y, false)
					if textResult ~= text then
						main.worldTooltip_array[i+3] = textResult
					end
				end
			end
		end
	end
end

Ext.RegisterUITypeInvokeListener(Data.UIType.worldTooltip, "updateTooltips", TooltipHandler.OnWorldTooltipUpdated)