local t = Def.ActorFrame{
    OnCommand=function(self)
        for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
            local field = find_pactor_in_gameplay(SCREENMAN:GetTopScreen(), pn);
            field:stoptweening();
        end;

        if IsRoutine() then
            find_pactor_in_gameplay(SCREENMAN:GetTopScreen(), OtherPlayer[Global.master]):hibernate(math.huge);
        end;
    end;
}

t[#t+1] = notefield_mods_actor();
t[#t+1] = notefield_prefs_actor();

return t;
