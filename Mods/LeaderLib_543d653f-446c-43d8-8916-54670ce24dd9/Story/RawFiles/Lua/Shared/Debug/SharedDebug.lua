local _ISCLIENT = Ext.IsClient()

--[[ Events.SummonChanged:Subscribe(function (e)
	if Vars.LeaderDebugMode then
		e:Dump()
		-- if type(e.Summon) == "userdata" then
		-- 	if not e.IsItem then
		-- 		fprint(LOGLEVEL.DEFAULT, "[OnSummonChanged:Character(%s)] Summon(%s)[%s] Totem(%s) Owner(%s) IsDying(%s) isItem(false)", _ISCLIENT and "CLIENT" or "SERVER", GameHelpers.Character.GetDisplayName(e.Summon), e.Summon.NetID, not _ISCLIENT and e.Summon.Totem or e.Summon:HasTag("TOTEM"), GameHelpers.Character.GetDisplayName(e.Owner), e.IsDying)
		-- 		--fprint(LOGLEVEL.WARNING, "Dead(%s) Deactivated(%s) CannotDie(%s) DYING(%s)", e.Summon.Dead, e.Summon.Deactivated, e.Summon.CannotDie, e.Summon:GetStatus("DYING") and e.Summon:GetStatus("DYING").Started or "false")
		-- 	else
		-- 		fprint(LOGLEVEL.DEFAULT, "[OnSummonChanged:Item(%s)] Summon(%s) StatsId(%s) Owner(%s) IsDying(%s) IsItem(true)", _ISCLIENT and "CLIENT" or "SERVER",GameHelpers.Character.GetDisplayName(e.Summon), e.Summon.StatsId, GameHelpers.Character.GetDisplayName(e.Owner), e.IsDying)
		-- 	end
		-- else
		-- 	fprint(LOGLEVEL.DEFAULT, "[OnSummonChanged:Character(%s)] Summon(%s) Owner(%s) IsDying(%s) IsItem(false)", _ISCLIENT and "CLIENT" or "SERVER",e.Summon, GameHelpers.Character.GetDisplayName(e.Owner), e.IsDying)
		-- end
		local summons = nil

		if not _ISCLIENT then
			summons = GameHelpers.Character.GetSummons(e.Owner, true, true, {[e.Summon.MyGuid]=true})
		else
			summons = GameHelpers.Character.GetSummons(e.Owner, true, true, {[e.Summon.NetID]=true})
		end
	
		local len = #summons
		if len > 0 then
			fprint(LOGLEVEL.DEFAULT, "Summons(%s)", _ISCLIENT and "CLIENT" or "SERVER")
			fprint(LOGLEVEL.DEFAULT, "========")
			for i=1,len do
				local summon = summons[i]
				fprint(LOGLEVEL.DEFAULT, "[%s] NetID(%s)", GameHelpers.Character.GetDisplayName(summon), GameHelpers.GetNetID(summon))
			end
			fprint(LOGLEVEL.DEFAULT, "========")
		end
	end
end) ]]