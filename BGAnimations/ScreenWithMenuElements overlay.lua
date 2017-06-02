local debugger = {}
local delta = 0;

local function Update(self,dt)
		Global.debounce = Global.debounce-dt;
		if Global.debounce < 0 then Global.debounce = 0 end;
		
		
		Global.realH = tonumber(PREFSMAN:GetPreference("DisplayHeight"))
		Global.realW = Global.realH*(SCREEN_WIDTH/SCREEN_HEIGHT)

		Global.mouseX = math.floor(INPUTFILTER:GetMouseX())*(Global.realW/DISPLAY:GetDisplayWidth());
		Global.mouseY = math.floor(INPUTFILTER:GetMouseY())*(Global.realH/DISPLAY:GetDisplayHeight());

		debugger = {
			Global.mouseX,
			Global.mouseY,
			Global.selection,
			Global.state,
			Global.level,
			Global.selectionp1,
			Global.selectionp2,
			Global.substatep1,
			Global.substatep2,
		};
		
		delta = dt;
		MESSAGEMAN:Broadcast("Update");
end;

local t = Def.ActorFrame{
    InitCommand=function(self) self:SetUpdateFunction(Update); self:SetUpdateRate(1/20) end;
    LeftClickMessageCommand=function(self) MESSAGEMAN:Broadcast("MouseLeft"); Global.input = "Left Click" end;
    RightClickMessageCommand=function(self) MESSAGEMAN:Broadcast("MouseRight"); Global.input = "Right Click" end;
    MiddleClickMessageCommand=function(self) MESSAGEMAN:Broadcast("MouseMid"); Global.input = "Mid Click" end;
    MouseWheelUpMessageCommand=function(self) 
    	if Global.debounce == 0 then MESSAGEMAN:Broadcast("MouseScrollUp"); Global.input = "MouseWheelUp"; end; 
    	Global.wheel = Global.wheel-1; 
    	Global.debounce=delta/1.75; 
    end;

    MouseWheelDownMessageCommand=function(self) 
    	if Global.debounce == 0 then MESSAGEMAN:Broadcast("MouseScrollDown"); Global.input = "MouseWheelDown" end;
    	Global.wheel = Global.wheel+1; 
    	Global.debounce=delta/1.75; 
    end;
}

--=======================================================================================================================
--NAVIGATION ICONS
--=======================================================================================================================

    local icon_spacing = 27
    local nav_icons = {
        "Play",
        "Home",
        "Profiles",
        "Reload",
        "Options",
        "Quit",
    };

    for i=1,#nav_icons do
        t[#t+1] = LoadActor(THEME:GetPathG("","navigation"))..{
            InitCommand=cmd(x,(SCREEN_CENTER_X+(icon_spacing*i))-(icon_spacing*((#nav_icons+1)/2));zoom,0.425;animate,false;y,SCREEN_BOTTOM-42+4);
            OnCommand=cmd(setstate,Navigation.Icon[nav_icons[i]]-1);
            GainFocusCommand=cmd(diffuse,0.45,0.9,1,1);
            LoseFocusCommand=cmd(diffuse,1,1,1,1);
            DisabledCommand=cmd(diffuse,0.75,0.75,0.75,0.5);
            UpdateMessageCommand=function(self) ButtonHover(self,nav_icons[i],0.4); end;
            MouseLeftMessageCommand=function(self) ButtonLeftClick(self,nav_icons[i],0.4); end;
        };
    end;


--[[

t[#t+1] = LoadActor(THEME:GetPathS("Common","value"))..{ 
	MouseScrollUpMessageCommand=cmd(play);
	MouseScrollDownMessageCommand=cmd(play);
};



t[#t+1] = LoadFont("Common normal")..{ 
	InitCommand=cmd(horizalign,right;vertalign,top;zoom,0.45;x,SCREEN_RIGHT-15;y,50;vertspacing,-2;strokecolor,0,0,0,1); 
	UpdateMessageCommand=cmd(settext,table.concat(debugger,"\n")); 
};

]]--


--DEBUGZORD 
--it works

--[[
t[#t+1] = LoadFont("neotech")..{
	InitCommand=cmd(x,SCREEN_RIGHT-10;y,SCREEN_BOTTOM-10;vertalign,bottom;horizalign,right;zoom,0.4;diffuse,1,0,0,1;strokecolor,0,0,0,0.66);
	UpdateMessageCommand=function(self)


		SCREENMAN:SystemMessage(
			Global.mouseX.."\n"..Global.mouseY..
			"\nScreen width: "..SCREEN_WIDTH.."\nScreen height: "..SCREEN_HEIGHT..
			"\nDisplay width: "..DISPLAY:GetDisplayWidth().."\nDisplay height: "..DISPLAY:GetDisplayHeight()..
			"\nReal Width: "..Global.realW.."\nReal Height: "..Global.realH

		);

		if Global.lockinput == true then
			self:settext("");
		else
			self:settext("");
		end	


	end;
};
]]

return t