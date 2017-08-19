local t = Def.ActorFrame{
    OnCommand=function(self)
        for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
            local field = find_pactor_in_gameplay(SCREENMAN:GetTopScreen(), pn);
            --[[
                field:addy(-128);
                field:sleep(0.5);
                field:decelerate(0.3);
                field:addy(128);
            ]]
        end;

        if IsRoutine() then
            find_pactor_in_gameplay(SCREENMAN:GetTopScreen(), OtherPlayer[Global.master]):hibernate(math.huge);
        end;
    end;
}

t[#t+1] = notefield_mods_actor();
t[#t+1] = notefield_prefs_actor();

return t;
