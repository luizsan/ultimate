return Def.ActorFrame{
    OnCommand=function(self)
        if IsRoutine() then
            GAMESTATE:UnjoinPlayer(OtherPlayer[GAMESTATE:GetMasterPlayerNumber()]);
            GAMESTATE:SetCurrentStyle("single");
        end;
        SCREENMAN:SetNewScreen("ScreenSelectMusicCustom");
    end;
}