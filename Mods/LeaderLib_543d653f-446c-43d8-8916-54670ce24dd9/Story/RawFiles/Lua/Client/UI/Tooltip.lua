local function EnableTooltipOverride()
	Ext.AddPathOverride("Public/Game/GUI/tooltip.swf", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/tooltip.swf")
	Ext.Print("[LeaderLib] Enabled tooltip override.")
end

--Ext.RegisterListener("ModuleLoading", EnableTooltipOverride)
--Ext.RegisterListener("ModuleLoadStarted", EnableTooltipOverride)
--Ext.RegisterListener("ModuleResume", EnableTooltipOverride)
--Ext.RegisterListener("SessionLoaded", EnableTooltipOverride)
--Ext.RegisterListener("SessionLoading", EnableTooltipOverride)