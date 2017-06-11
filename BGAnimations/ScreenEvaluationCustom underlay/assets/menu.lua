local t = Def.ActorFrame{
    InitCommand=cmd(diffusealpha,0);
    UnlockMessageCommand=cmd(stoptweening;linear,0.2;diffusealpha,1);
}

local originX = SCREEN_CENTER_X;
local originY = SCREEN_CENTER_Y + 100;
local spacing = 20;

local selection = 1;
local options = {
    {
        Name = "Continue",
        Action = function(param)
            SCREENMAN:GetTopScreen():SetNextScreenName("ScreenProfileSave");
            SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_BeginFadingOut");
        end;
    },
    {
        Name = "Retry",
        Action = function(param)
            SCREENMAN:SetNewScreen("ScreenGameplay")
        end;
    },
    {
        Name = "Screenshot",
        Action = function(param)
            if(PROFILEMAN:ProfileWasLoadedFromMemoryCard(param.Player)) then
                SaveScreenshot(param.Player, true, false)
            else
                SaveScreenshot(nil, false, false)
            end;
            SCREENMAN:SystemMessage("Screenshot")
        end;
    },
    {
        Name = "Quit",
        Action = function(param)
            SCREENMAN:SetNewScreen("ScreenTitleMenu")
        end;
    },
}

function EvaluationController(param)
    if param.Input == "Prev" and GAMESTATE:IsSideJoined(param.Player) and selection > 1 then
        selection = selection - 1;
        MESSAGEMAN:Broadcast("EvaluationMenu", { silent = true } );
    end;

    if param.Input == "Next" and GAMESTATE:IsSideJoined(param.Player) and selection < #options then
        selection = selection + 1;
        MESSAGEMAN:Broadcast("EvaluationMenu", { silent = true } );
    end;

    if param.Input == "Center" or param.Input == "Start" then
        options[selection].Action(param)
    end;

    if param.Input == "Return" then
        SCREENMAN:SetNewScreen("ScreenProfileSave")
    end;
 
end;


for i=1,#options do

    t[#t+1] = Def.ActorFrame{

        LoadFont("neotech")..{
            InitCommand=cmd(x,originX;y,originY + (spacing*(i-1));zoom,0.525;settext,options[i].Name;diffuse,HighlightColor();
                strokecolor,BoostColor(HighlightColor(),0.3);shadowcolor,BoostColor(HighlightColor(),0.125);shadowlengthx,1;shadowlengthy,1);
            OnCommand=function() MESSAGEMAN:Broadcast("EvaluationMenu", { silent = true } ); end;
            EvaluationMenuMessageCommand=function(self)
                if(selection == i) then
                    self:diffuse(1,1,1,1);
                else
                    self:diffuse(HighlightColor())
                end;
            end;
        }

    };


end;

return t;