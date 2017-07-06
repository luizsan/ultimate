local originX = SCREEN_CENTER_X;
local originY = SCREEN_CENTER_Y+82;
local textbanner = 30;
local spacing = 31;
local numcharts = 18;
local panespacing = 296;

local voffset = 0;
local paneLabels = {"Taps","Jumps","Holds","Hands","Mines","Other"};

local t = Def.ActorFrame{
    OnCommand=cmd(stoptweening;diffusealpha,0;sleep,0.5;linear,0.2;diffusealpha,1);
    MusicWheelMessageCommand=function(self,param) if param and param.Direction then voffset = 0; end; end;
    StateChangedMessageCommand=function(self)
        self:stoptweening();
        self:decelerate(0.2);
        if Global.state == "GroupSelect" then
            self:diffusealpha(0);
        else
            self:diffusealpha(1);
        end
    end;
    StepsChangedMessageCommand=function(self,param)
        if param and param.Player then
            local newoffset = 0;
            local newindex = Global.pnsteps[param.Player];

            while newindex > numcharts do
                newoffset = newoffset + 1
                newindex = newindex - numcharts
            end;

            if(newoffset ~= voffset) then
                voffset = newoffset
                self:playcommand("MusicWheel");
            end
        end;
    end;
};

--//================================================================

function StepsController(self,param)
    if param.Player then
        if param.Input == "Prev" and param.Button == "Left" then
            Global.confirm[param.Player] = 0; 
            MESSAGEMAN:Broadcast("Deselect"); 

            Global.pnsteps[param.Player] = Global.pnsteps[param.Player]-1; 
            if Global.pnsteps[param.Player] < 1 then Global.pnsteps[param.Player] = #Global.steps; end;
            Global.pncursteps[param.Player] = Global.steps[Global.pnsteps[param.Player]]; 
            MESSAGEMAN:Broadcast("StepsChanged", { Prev = true , Player = param.Player }); 

        end;

        if param.Input == "Next" and param.Button == "Right" then
            Global.confirm[param.Player] = 0;
            MESSAGEMAN:Broadcast("Deselect"); 

            Global.pnsteps[param.Player] = Global.pnsteps[param.Player]+1; 
            if Global.pnsteps[param.Player] > #Global.steps then Global.pnsteps[param.Player] = 1; end;
            Global.pncursteps[param.Player] = Global.steps[Global.pnsteps[param.Player]];
            MESSAGEMAN:Broadcast("StepsChanged", { Next = true , Player = param.Player }); 
        end;
    end;
        
    if param.Input == "Cancel" or param.Input == "Back" and Global.level == 2 then 
        
        Global.confirm[PLAYER_1] = 0;
        Global.confirm[PLAYER_2] = 0;

        if Global.prevstate == "MusicWheel" then
            Global.level = 2; 
            Global.selection = 2; 
            MESSAGEMAN:Broadcast("MainMenu");
            Global.selection = SetWheelSelection(); 
            Global.state = "MusicWheel";  
        else
            Global.level = 1; 
            Global.selection = 3; 
            Global.state = "MainMenu";  
        end;
        
        MESSAGEMAN:Broadcast("Deselect"); 
        MESSAGEMAN:Broadcast("StateChanged"); 
        MESSAGEMAN:Broadcast("Return");
    end;
end;

--//================================================================

function SelectStep(param)

    if param then Global.confirm[param.Player] = 1; 
        MESSAGEMAN:Broadcast("StepsSelected"); 
        if Global.confirm[PLAYER_1] + Global.confirm[PLAYER_2] >= GAMESTATE:GetNumSidesJoined() then
            Global.level = 1;
            Global.state = "MainMenu";
            Global.selection = 4;
            Global.confirm[PLAYER_1] = 0;
            Global.confirm[PLAYER_2] = 0;
            MESSAGEMAN:Broadcast("StateChanged"); 
            MESSAGEMAN:Broadcast("MainMenu"); 
        end;
    end;
end;

--//================================================================

t[#t+1] = LoadActor(THEME:GetPathG("","dim"))..{
    InitCommand=cmd(diffuse,0.33,0.33,0.33,0.33;y,originY;x,originX;zoomto,640,220;fadeleft,0.33;faderight,0.33;croptop,0.5);
};

t[#t+1] = LoadActor(THEME:GetPathG("","stepspane"))..{
    InitCommand=cmd(animate,false;setstate,1+3;y,originY;x,originX;zoomto,(spacing*numcharts),0.425*self:GetHeight();diffusebottomedge,1,1,1,1);
    StateChangedMessageCommand=function(self) self:stoptweening(); self:linear(0.2); if Global.state ~= "SelectSteps" then self:diffusebottomedge(1,1,1,1); else self:diffusebottomedge(0.5,0.5,0.5,1); end; end;
};
t[#t+1] = LoadActor(THEME:GetPathG("","stepspane"))..{
    InitCommand=cmd(animate,false;setstate,0+3;horizalign,right;y,originY;x,originX-((spacing*numcharts)/2);zoom,0.425;diffusebottomedge,1,1,1,1);
    StateChangedMessageCommand=function(self) self:stoptweening(); self:linear(0.2); if Global.state ~= "SelectSteps" then self:diffusebottomedge(1,1,1,1);  else self:diffusebottomedge(0.5,0.5,0.5,1); end; end;
};
t[#t+1] = LoadActor(THEME:GetPathG("","stepspane"))..{
    InitCommand=cmd(animate,false;setstate,2+3;horizalign,left;y,originY;x,originX+((spacing*numcharts)/2);zoom,0.425;diffusebottomedge,1,1,1,1);
    StateChangedMessageCommand=function(self) self:stoptweening(); self:linear(0.2); if Global.state ~= "SelectSteps" then self:diffusebottomedge(1,1,1,1);  else self:diffusebottomedge(0.5,0.5,0.5,1); end; end;
};


for pn in ivalues(GAMESTATE:GetHumanPlayers()) do

--//==========================================
--//  RADAR VALUES
--//==========================================

local iconspacing = 38;
local iconadjust = 20;


local radaritems = 5;

for num=0,radaritems do

    --// radar item
    t[#t+1] = Def.ActorFrame{
            InitCommand=cmd(y,SCREEN_CENTER_Y+110;x,SCREEN_CENTER_X+(panespacing*pnSide(pn)));
            OnCommand=cmd(visible,SideJoined(pn));

            --// ICONS ==================
            LoadActor(THEME:GetPathG("","radar"))..{
                InitCommand=cmd(zoom,0.4125;animate,false;halign,0.5;valign,0.5;setstate,num;diffuse,PlayerColor(pn);y,12;diffusebottomedge,0.2,0.2,0.2,0.5;diffusealpha,0;);
                OnCommand=cmd(playcommand,"StateChanged");
                StateChangedMessageCommand=function(self)
                    self:stoptweening();
                    self:decelerate(0.15);

                    if Global.state == "SelectSteps" then
                        self:diffusealpha(0.45);
                    else
                        self:diffusealpha(0);
                    end;

                    if pn == PLAYER_1 then
                        self:x((num*iconspacing)+iconadjust);
                    elseif pn == PLAYER_2 then
                        self:x((-radaritems*iconspacing)+(num*iconspacing)-iconadjust);
                    end;

                end;
            };

            --// LABELS ==================
            Def.BitmapText{
                Font = Fonts.radar["Label"];
                InitCommand=cmd(zoomx,0.31;zoomy,0.3;halign,0.5;valign,0.5;diffuse,PlayerColor(pn);strokecolor,0.1,0.1,0.1,1;vertspacing,-30.9;diffusealpha,0);
                OnCommand=cmd(playcommand,"StateChanged");
                StateChangedMessageCommand=function(self)
                    self:stoptweening();
                    self:decelerate(0.15);

                    if Global.state == "SelectSteps" then
                        self:y(32);
                        self:diffusealpha(1);
                    else
                        self:y(28);
                        self:diffusealpha(0);
                    end;

                    if pn == PLAYER_1 then
                        self:x((num*iconspacing)+iconadjust);
                    elseif pn == PLAYER_2 then
                        self:x((-radaritems*iconspacing) + (num*iconspacing)-iconadjust);
                    end;

                    self:settext(string.upper(paneLabels[num+1]));
                end;
            };


            --// NUMBERS ==================
            Def.BitmapText{
                Font = Fonts.radar["Number"];
                InitCommand=cmd(zoomx,0.425;zoomy,0;halign,0.5;valign,0.5;strokecolor,0.15,0.15,0.15,0.75;maxwidth,72;diffusealpha,0);
                OnCommand=cmd(playcommand,"StateChanged");
                StateChangedMessageCommand=function(self)
                    self:stoptweening();
                    self:decelerate(0.15);
                    if Global.state == "SelectSteps" then
                        self:zoomy(0.45);
                        self:diffusealpha(1);
                    else
                        self:zoomy(0);
                        self:diffusealpha(0);
                    end;

                    if pn == PLAYER_1 then
                        self:x((num*iconspacing)+iconadjust);
                    elseif pn == PLAYER_2 then
                        self:x((-radaritems*iconspacing) + (num*iconspacing)-iconadjust);
                    end;
                end;

                StepsChangedMessageCommand=function(self)
                    local value = 0;
                    if GAMESTATE:IsSideJoined(pn) and Global.pncursteps[pn] then
                        value = GetRadar(Global.steps[Global.pnsteps[pn]],pn,num+1);
                    end;
                    self:y(20);
                    self:settext(string.rep("0",3-string.len(value))..value);

                    if value == 0 then
                        self:diffusetopedge(1,0.5,0.5,1);
                        self:diffusebottomedge(0.5,0.5,0.5,1);
                    else
                        self:diffusetopedge(1,1,1,1);
                        self:diffusebottomedge(BoostColor(PlayerColor(pn),1.5));
                    end;
                end;

            };

    };

end;


--//==========================================
--//  CURSOR
--//==========================================


t[#t+1] = Def.ActorFrame{
    InitCommand=cmd(playcommand,"StepsChanged");
    OnCommand=cmd(visible,SideJoined(pn));
    StateChangedMessageCommand=cmd(playcommand,"StepsChanged");
    StepsChangedMessageCommand=function(self)
        if GAMESTATE:IsSideJoined(pn) then
            local index = 1;
            self:stoptweening();
            self:decelerate(0.15);

            if Global.pnsteps[pn] then
                index = Global.pnsteps[pn];
                if index > numcharts then
                    index = index % numcharts
                end
            end;

            self:x((originX)+(spacing*(index-1))-((numcharts/2)*spacing)+(spacing/2));
            self:y(originY);
        end;
    end;

    LoadActor(THEME:GetPathG("","cursor"))..{
        InitCommand=cmd(spin;effectmagnitude,0,0,720;animate,false;zoom,0.475;rotationy,20;rotationx,-50;x,-1;blend,Blend.Add;diffusealpha,0;);
        StateChangedMessageCommand=function(self,param) 
            self:stoptweening(); 
            
            if param and (param.Prev or param.Next) and param.Player == pn then
                self:linear(0.2);
            end;

            if Global.state ~= "SelectSteps" or not GAMESTATE:IsSideJoined(pn) then 
                self:diffusealpha(0); 
            else 
                self:diffusealpha(1); 
            end; 

        end;
        OnCommand=function(self)
            if pn == PLAYER_1 then 
                self:setstate(1); 
            elseif pn == PLAYER_2 then 
                self:setstate(3); 
            end;    
        end;
    };

    LoadActor(THEME:GetPathG("","label"))..{
        InitCommand=cmd(animate,false;zoom,0.36;diffusealpha,0);
        OnCommand=cmd(playcommand,"StepsChanged");
        StateChangedMessageCommand=cmd(playcommand,"StepsChanged");
        StepsChangedMessageCommand=function(self,param)
            if GAMESTATE:IsSideJoined(pn) then

                local index = 1;
                self:stoptweening();
                
                if param and (param.Prev or param.Next) and param.Player == pn then
                    self:decelerate(0.275);
                end;

                if Global.state ~= "SelectSteps" or not GAMESTATE:IsSideJoined(pn) then 
                    self:diffusealpha(0) 
                else 
                    self:diffusealpha(1);
                end;
                
                if pn == PLAYER_1 then 
                    self:setstate(0); 
                    self:x(-12);
                    self:y(-11);
                elseif pn == PLAYER_2 then 
                    self:setstate(1); 
                    self:x(11);
                    self:y(12);
                end; 
            end;
        end;
    };

};

end;
    
for i=1,numcharts do


    t[#t+1] = Def.BitmapText{
        Font = Fonts.stepslist["Main"];
        InitCommand=cmd(zoom,0.5;diffuse,1,1,1,0;strokecolor,0,0,0,0.25;y,originY;x,(originX)+(spacing*(i-1))-((numcharts/2)*spacing)+(spacing/2)-1);
        OnCommand=cmd(playcommand,"MusicWheel");
        MusicWheelMessageCommand=function(self,param)
            
            self:stoptweening();
            self:decelerate(0.175);
            
            if param and param.Direction then voffset = 0; end;

            local tint;
            local offset = voffset * numcharts;
            local steps = Global.steps[i + offset];

            self:diffuse(1,1,1,1);
            self:strokecolor(0,0,0,0.25);

            if steps then

                local tint = StepsColor(steps);
                self:diffuse(tint);
                self:diffusetopedge(BoostColor(tint,9));
                self:strokecolor(BoostColor(tint,0.25));

                if TotalNotes(steps) == 0 then
                    self:settext("00");
                else
                    self:settext(FormatMeter(steps:GetMeter()));
                end

            else    
                self:settext("00");
                self:diffusealpha(0.1);
            end;

            self:x((originX)+(spacing*(i-1))-((numcharts/2)*spacing)+(spacing/2)-1);
        end;
    };



    t[#t+1] = LoadActor(THEME:GetPathG("","separator"))..{
        OnCommand=cmd(diffuse,0.1,0.1,0.1,0.9;y,originY+0.5;zoom,0.25;queuecommand,"MusicWheel");
        MusicWheelMessageCommand=function(self)
        self:x((originX)+(spacing*(i-1))-((numcharts/2)*spacing)+(spacing/2)+14);
        if i<numcharts then self:visible(true) else self:visible(false); end;
        end;
    };

end;



return t