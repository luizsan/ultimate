return Def.BitmapText{
	Font="titillium regular",
	InitCommand=cmd(x,SCREEN_CENTER_X;zoom,0.6;diffuse,color("#80C0FF");shadowlength,1;shadowcolor,0,0,0,0.2),
	OnCommand= function(self)
		self:diffusealpha(0)
		self:decelerate(0.5)
		self:diffusealpha(1)
		-- fancy effect:  Look at the name (which is set by the screen) to set text
		self:settext(
			THEME:GetString("ScreenMapControllers", "Action" .. self:GetName()))
	end,
	OffCommand=cmd(stoptweening;accelerate,0.3;diffusealpha,0;queuecommand,"Hide"),
	HideCommand=cmd(visible,false),
	GainFocusCommand=cmd(diffuseshift;effectcolor2,color("#80C0FF");effectcolor1,color("#FFFFFF")),
	LoseFocusCommand=cmd(stopeffect),
}
