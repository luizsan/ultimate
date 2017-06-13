return Def.ActorFrame{
    OnCommand=function(self)
        GAMESTATE:UnjoinPlayer(OtherPlayer[Global.master]);
        GAMESTATE:SetCurrentStyle("single");
        SCREENMAN:SetNewScreen("ScreenProfileSave");
    end;
}