local gc = Var("GameCommand");
local t = Def.ActorFrame{}
local centered = 52
local item = tonumber(gc:GetName());


t[#t+1] = Def.BitmapText{
		Font = "regen silver";
		Text = string.upper(gc:GetText());
		InitCommand=cmd(zoom,0.7;y,2;horizalign,left;strokecolor,0,0,0,0.75;playcommand,"Disable");
		GainFocusCommand=cmd(stoptweening;decelerate,0.225;diffusealpha,1;x,0-centered);
		LoseFocusCommand=cmd(stoptweening;decelerate,0.225;diffusealpha,0;x,-20-centered);
	};

t[#t+1] = Def.BitmapText{
		Font = "titillium regular";
		Text = "Lorem ipsum dolor sit amet fuck you I'm mad";
		InitCommand=cmd(zoom,0.42;y,23;horizalign,left;strokecolor,0,0,0,0.33);
		GainFocusCommand=cmd(stoptweening;decelerate,0.225;diffusealpha,1;x,0-centered);
		LoseFocusCommand=cmd(stoptweening;decelerate,0.225;diffusealpha,0;x,-20-centered);
	};
	
	
t[#t+1] = LoadActor(THEME:GetPathG("","mainmenu")) .. {
		InitCommand=cmd(zoom,0.75;halign,0.95;y,2;animate,false;playcommand,"Set");
		GainFocusCommand=cmd(stoptweening;decelerate,0.225;diffusealpha,1;x,0-centered);
		LoseFocusCommand=cmd(stoptweening;decelerate,0.225;diffusealpha,0;x,-20-centered);
		SetCommand=function(self)
			if item == 1 then self:setstate(3); 
			elseif item == 2 then self:setstate(2); 
			elseif item == 3 then self:setstate(0); 
			elseif item == 4 then self:setstate(1); 
			end;
			
		end;
};
	



return t;