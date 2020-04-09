---@class TranslatedString
local TranslatedString = {
	Handle = "",
	Content = "",
	Value = ""
}
TranslatedString.__index = TranslatedString

function TranslatedString:Create(handle,content)
    local this =
    {
		Handle = handle,
		Content = content
	}
	setmetatable(this, self)
	if this.Handle ~= "" and this.Handle ~= nil then
		if Ext.Version() >= 43 then
			this.Value = Ext.GetTranslatedString(this.Handle, this.Content)
		else
			this.Value = this.Content
		end
	end
    return this
end

function TranslatedString:Update()
	if self.Handle ~= "" and self.Handle ~= nil then
		if Ext.Version() >= 43 then
			self.Value = Ext.GetTranslatedString(self.Handle, self.Content)
		else
			self.Value = self.Content
		end
	else
		self.Value = self.Content
	end
	return self.Value
end

LeaderLib.Classes["TranslatedString"] = TranslatedString