--param1:Number, param2:Boolean, param3:String, param4:Boolean = false

function UI.GetArrayIndexStart(ui, arrayName, offset)
	local i = 0
	while i < 9999 do
		local val = ui:GetValue(arrayName, "number", i)
		if val == nil then
			val = ui:GetValue(arrayName, "string", i)
			if val == nil then
				val = ui:GetValue(arrayName, "boolean", i)
			end
		end
		if val == nil then
			return i
		end
		i = i + offset
	end
	return -1
end

function UI.IsInArray(ui, arrayName, id, start, offset)
	local i = start
	while i < 200 do
		local check = ui:GetValue(arrayName,"number", i)
		if check ~= nil and math.tointeger(check) == id then
			return true
		end
		i = i + offset
	end
	return false
end