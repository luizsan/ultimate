local t = Def.ActorFrame{
    InitCommand=function(self) Global.lockinput = true; end;
    OnCommand=cmd(sleep,2.5;queuecommand,"Unlock");
    UnlockCommand=function(self) 
        Global.lockinput = false; 
        MESSAGEMAN:Broadcast("Unlock");
    end;
    
    MenuUpP1MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", {  Input = "Back", Player = PLAYER_1 }); end; 
    MenuUpP2MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", {  Input = "Back", Player = PLAYER_2 }); end; 
    MenuDownP1MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Input = "Back", Player = PLAYER_1 }); end; 
    MenuDownP2MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Input = "Back", Player = PLAYER_2 }); end; 
    MenuLeftP1MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", {  Input = "Prev", Player = PLAYER_1 }); end;
    MenuLeftP2MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", {  Input = "Prev", Player = PLAYER_2 }); end; 
    MenuRightP1MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Input = "Next", Player = PLAYER_1 }); end; 
    MenuRightP2MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Input = "Next", Player = PLAYER_2 }); end; 
    MouseScrollUpMessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Input = "Prev", Player = master }); end; 
    MouseScrollDownMessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Input = "Next", Player = master  }); end; 
    MenuInputMessageCommand=function(self,param) if not Global.lockinput then InputController(self,param) end; end; 
    CodeMessageCommand=function(self,param) if not Global.lockinput then CodeController(self,param); end; end;
}

function InputController(self,param)
    if param and param.Player and GAMESTATE:IsSideJoined(param.Player) then
        EvaluationController(param)
    end;
end;

function CodeController(self,param)
    if GAMESTATE:IsSideJoined(param.PlayerNumber) then

        if param.Name == "Back" then 
            MESSAGEMAN:Broadcast("MenuInput", {  Input = "Cancel", Player = Global.master }); 
        end;    
            
        if param.Name == "Center" or param.Name == "Start" then 
            --SCREENMAN:SetNewScreen(Branch.AfterEvaluation()); 
        end;

        if param.Name == "PressSelect" and not HighScoreBlockedState() then
            Global.toggle = true;
            MESSAGEMAN:Broadcast("ToggleSelect", { Toggled = true });
        end

        if param.Name == "ReleaseSelect" then
            Global.toggle = false;
            MESSAGEMAN:Broadcast("ToggleSelect", { Toggled = false })
        end

        if param.Name == "Return" then 
            --SCREENMAN:SetNewScreen(SCREENMAN:GetTopScreen():GetNextScreenName()); 
        end;

        MESSAGEMAN:Broadcast("MenuInput", { Input = param.Name, Player = param.PlayerNumber });
    end;

end;

t[#t+1] = LoadActor(THEME:GetPathB("","_assets/fulldisplay"));
t[#t+1] = LoadActor("assets/information");
t[#t+1] = LoadActor("assets/scores");
t[#t+1] = LoadActor("assets/menu");

t[#t+1] = LoadActor(THEME:GetPathB("","_assets/cursteps"));
t[#t+1] = LoadActor(THEME:GetPathB("","_assets/sound"));

return t;