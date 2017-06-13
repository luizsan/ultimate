local function Update(self,dt)
    Global.realH = tonumber(PREFSMAN:GetPreference("DisplayHeight"))
    Global.realW = Global.realH*(SCREEN_WIDTH/SCREEN_HEIGHT)
    Global.mouseX = math.floor(INPUTFILTER:GetMouseX())*(Global.realW/DISPLAY:GetDisplayWidth());
    Global.mouseY = math.floor(INPUTFILTER:GetMouseY())*(Global.realH/DISPLAY:GetDisplayHeight());
    Global.debounce = Global.debounce - dt;
    if Global.debounce < 0 then Global.debounce = 0 end;
    Global.delta = dt;
    MESSAGEMAN:Broadcast("Update");
end;

local t = Def.ActorFrame{
    InitCommand=function(self) self:SetUpdateFunction(Update); end;
}

--=======================================================================================================================
--NAVIGATION ICONS
--=======================================================================================================================

--[[
local icon_spacing = 27
for i=1,#Navigation do
    t[#t+1] = LoadActor(THEME:GetPathG("","navigation"))..{
        InitCommand=cmd(x,(SCREEN_CENTER_X+(icon_spacing*i))-(icon_spacing*((#Navigation+1)/2));zoom,0.425;animate,false;y,SCREEN_BOTTOM-42+4);
        OnCommand=cmd(setstate,Navigation[i].Icon-1);
        GainFocusCommand=cmd(diffuse,0.45,0.9,1,1);
        LoseFocusCommand=cmd(diffuse,1,1,1,1);
        DisabledCommand=cmd(diffuse,0.75,0.75,0.75,0.5);
        UpdateMessageCommand=function(self) ButtonHover(self,0.4); end;
        MouseLeftMessageCommand=function(self) MouseDown(self,0.4,Navigation[i].Screen); end;
    };
end;
]]

return t