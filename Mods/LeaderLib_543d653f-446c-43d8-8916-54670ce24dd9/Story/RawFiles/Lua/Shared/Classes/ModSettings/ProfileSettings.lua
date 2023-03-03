local SettingsData = Classes.ModSettingsClasses.SettingsData

---@class ProfileSettings
local ProfileSettings = {
	Type = "ProfileSettings",
	ID = "",
	---@type SettingsData
	Settings = nil
}

ProfileSettings.__index = ProfileSettings

---@param id string
---@param uuid Guid The ModuleUUID
---@param settings SettingsData|nil
function ProfileSettings:Create(id, uuid, settings)
    local this =
    {
		ID = id,
		Settings = settings or SettingsData:Create()
	}
	this.Settings.ModuleUUID = uuid
	setmetatable(this, self)
    return this
end

Classes.ModSettingsClasses.ProfileSettings = ProfileSettings