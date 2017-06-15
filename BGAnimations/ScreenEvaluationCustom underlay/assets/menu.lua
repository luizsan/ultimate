local t = Def.ActorFrame{
    InitCommand=cmd(diffusealpha,0);
    UnlockMessageCommand=cmd(stoptweening;linear,0.2;diffusealpha,1);
}

local originY = SCREEN_CENTER_Y + 144;
local selection = 1;
local options = {
    {
        Name = "Continue",
        Action = function(param)
            MESSAGEMAN:Broadcast("FinalDecision");
            SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_BeginFadingOut");
        end;
    },
    {
        Name = "Retry",
        Action = function(param)
            if IsRoutine then
                SCREENMAN:SetNewScreen("ScreenGameplayShared")
            else
                SCREENMAN:SetNewScreen("ScreenGameplay")
            end;
        end;
    },
    {
        Name = "Details",
        Action = function(param)
        end;
    },
    {
        Name = "Screenshot",
        Action = function(param)
            if(PROFILEMAN:ProfileWasLoadedFromMemoryCard(param.Player)) then
                MESSAGEMAN:Broadcast("Screenshot", { Player = param.Player });
                SaveScreenshot(param.Player, true, false)
            else
                MESSAGEMAN:Broadcast("Screenshot", { Player = nil });
                SaveScreenshot(nil, false, false)
            end;
            SCREENMAN:SystemMessage("Screenshot");
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
    if param.Input == "Prev" and SideJoined(param.Player) and selection > 1 then
        selection = selection - 1;
        MESSAGEMAN:Broadcast("EvaluationMenu", { Direction = "Prev", silent = false } );
    end;

    if param.Input == "Next" and SideJoined(param.Player) and selection < #options then
        selection = selection + 1;
        MESSAGEMAN:Broadcast("EvaluationMenu", { Direction = "Next", silent = false } );
    end;

    if param.Input == "Center" or param.Input == "Start" and SideJoined(param.Player) then
        options[selection].Action(param)
    end;

    if param.Input == "Return" then
        SCREENMAN:SetNewScreen("ScreenProfileSave")
    end;
 
end;

local spacing = 18;
local arrowspacing = 72;
for i=1,#options do

    t[#t+1] = Def.ActorFrame{
        --x,SCREEN_CENTER_X + (spacing * (i - (#options/2))) - (spacing * 0.5);
        InitCommand=cmd(x,SCREEN_CENTER_X);
        OnCommand=cmd(playcommand,"EvaluationMenu");
        EvaluationMenuMessageCommand=function(self)
            self:stoptweening();
            self:decelerate(0.125);

            local index = i-selection;
            local alpha = 1 - (math.abs(index) / 2.75);

            self:y(originY + (spacing * (index-1)));
            self:diffusealpha(alpha);

            if(selection == i) then 
                self:playcommand("GainFocus"); 
            else 
                self:playcommand("LoseFocus") 
            end;
        end;

        Def.BitmapText{
            Font = Fonts.eval["Menu"];
            Text = string.upper(options[i].Name);
            InitCommand=cmd(zoom,0.433333);
            GainFocusCommand=cmd(stoptweening;linear,0.1;diffuse,1,1,1,1;strokecolor,0.25,0.25,0.25,1);
            LoseFocusCommand=cmd(stoptweening;linear,0.1;diffuse,HighlightColor();strokecolor,BoostColor(HighlightColor(),0.3));
        }

    };
end;

t[#t+1] = Def.ActorFrame{
    Name = "Cursor";
    InitCommand=cmd(x,SCREEN_CENTER_X;y,originY-spacing+1);
    StateChangedMessageCommand=function(self)
        self:stoptweening();
        self:decelerate(0.2);
        self:diffuse(1,1,1,1);
    end;
    
    Def.ActorFrame{
        Name = "Normal";
        LoadActor(THEME:GetPathG("","miniarrow"))..{
            InitCommand=cmd(animate,false;x,-arrowspacing;zoom,0.43;diffuse,0.6,0.6,0.6,0.95;shadowlengthy,1);
        },  
        LoadActor(THEME:GetPathG("","miniarrow"))..{
            InitCommand=cmd(animate,false;x,arrowspacing;zoom,0.43;zoomx,-0.43;diffuse,0.6,0.6,0.6,0.95;shadowlengthy,1);
        },
    },

    Def.ActorFrame{
        Name = "Glow";
        LoadActor(THEME:GetPathG("","miniarrow"))..{
            InitCommand=cmd(animate,false;setstate,1;x,-arrowspacing;zoom,0.43;diffusealpha,0;blend,"BlendMode_Add");
            GlowCommand=cmd(stoptweening;diffusealpha,1;decelerate,0.3;diffusealpha,0);
            EvaluationMenuMessageCommand=function(self,param)
                if param.Direction == "Prev" then
                    self:playcommand("Glow");
                end;
            end;
        },  
        LoadActor(THEME:GetPathG("","miniarrow"))..{
            InitCommand=cmd(animate,false;setstate,1;x,arrowspacing;zoom,0.43;zoomx,-0.43;diffusealpha,0;blend,"BlendMode_Add");
            GlowCommand=cmd(stoptweening;diffusealpha,1;decelerate,0.3;diffusealpha,0);
            EvaluationMenuMessageCommand=function(self,param)
                if param.Direction == "Next" then
                    self:playcommand("Glow");
                end;
            end;
        },
    },
};


return t;