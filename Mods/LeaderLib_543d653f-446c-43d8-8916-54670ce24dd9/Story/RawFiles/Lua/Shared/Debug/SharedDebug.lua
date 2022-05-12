Events.SummonChanged:Subscribe(function (e)
	if Vars.LeaderDebugMode then
		if type(e.Summon) == "userdata" then
			if not e.IsItem then
				fprint(LOGLEVEL.DEFAULT, "[OnSummonChanged:Character(%s)] Summon(%s) Totem(%s) Owner(%s) IsDying(%s) isItem(false)", isClient and "CLIENT" or "SERVER", GameHelpers.Character.GetDisplayName(e.Summon), not isClient and e.Summon.Totem or e.Summon:HasTag("TOTEM"), GameHelpers.Character.GetDisplayName(e.Owner), e.IsDying)
				--fprint(LOGLEVEL.WARNING, "Dead(%s) Deactivated(%s) CannotDie(%s) DYING(%s)", e.Summon.Dead, e.Summon.Deactivated, e.Summon.CannotDie, e.Summon:GetStatus("DYING") and e.Summon:GetStatus("DYING").Started or "false")
			else
				fprint(LOGLEVEL.DEFAULT, "[OnSummonChanged:Item(%s)] Summon(%s) StatsId(%s) Owner(%s) IsDying(%s) IsItem(true)", isClient and "CLIENT" or "SERVER",GameHelpers.Character.GetDisplayName(e.Summon), e.Summon.StatsId, GameHelpers.Character.GetDisplayName(e.Owner), e.IsDying)
			end
		else
			fprint(LOGLEVEL.DEFAULT, "[OnSummonChanged:Character(%s)] Summon(%s) Owner(%s) IsDying(%s) IsItem(false)", isClient and "CLIENT" or "SERVER",e.Summon, GameHelpers.Character.GetDisplayName(e.Owner), e.IsDying)
		end
	
		fprint(LOGLEVEL.DEFAULT, "Summons(%s)", isClient and "CLIENT" or "SERVER")
		fprint(LOGLEVEL.DEFAULT, "========")
		for summon in GameHelpers.Character.GetSummons(e.Owner, true) do
			fprint(LOGLEVEL.DEFAULT, "[%s] NetID(%s)", GameHelpers.Character.GetDisplayName(summon), GameHelpers.GetNetID(summon))
		end
		fprint(LOGLEVEL.DEFAULT, "========")
	end
end)