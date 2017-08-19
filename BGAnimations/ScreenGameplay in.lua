local t = Def.ActorFrame{
	OnCommand=function(self)
		self:sleep(0.25);
		self:linear(0.5);
		self:diffusealpha(0);
	end;
};

t[#t+1] = LoadActor(THEME:GetPathB("ScreenWithMenuElements", "background"));

--[[
t[#t+1] = Def.Sprite {
	InitCommand=cmd(Center;diffusealpha,1);
	BeginCommand=cmd(LoadFromCurrentSongBackground);
	OnCommand=function(self)
		if PREFSMAN:GetPreference("StretchBackgrounds") then
			self:SetSize(SCREEN_WIDTH,SCREEN_HEIGHT)
		else
			self:scale_or_crop_background()
		end
		self:linear(1)
		self:diffusealpha(0)
	end;
};
]]
return t;