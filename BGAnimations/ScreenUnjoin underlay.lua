return Def.ActorFrame{

    OnCommand=function(self)

        local master = GAMESTATE:GetMasterPlayerNumber();
        if Global.mastersteps and PureType(Global.mastersteps) == "Routine" then

            if master == PLAYER_1 then
                --GAMESTATE:ResetPlayerOptions(PLAYER_2);
                GAMESTATE:UnjoinPlayer(PLAYER_2);
            elseif master == PLAYER_2 then
                --GAMESTATE:ResetPlayerOptions(PLAYER_1);
                GAMESTATE:UnjoinPlayer(PLAYER_1);
            end;

        end;
        SCREENMAN:SetNewScreen("ScreenSelectMusicCustom")
    end;
}