local gc = Var("GameCommand");
local t = Def.ActorFrame {};


t[#t+1] = Def.Quad{
		InitCommand=cmd(y,44;zoomto,100,1;fadeleft,0.5;faderight,0.5;diffuse,HighlightColor());
		GainFocusCommand=cmd(stoptweening;linear,0.25;diffusealpha,1);
		LoseFocusCommand=cmd(stoptweening;linear,0.2;diffusealpha,0);
};

t[#t+1] = Def.BitmapText{
        Font = "titillium regular";
		InitCommand=cmd(zoom,0.41;y,29;strokecolor,0,0,0,0.25;settext,gc:GetText());
		GainFocusCommand=cmd(stoptweening;linear,0.25;diffuse,HighlightColor();strokecolor,BoostColor(HighlightColor(),0.3));
		LoseFocusCommand=cmd(stoptweening;linear,0.25;diffuse,1,1,1,1;strokecolor,0,0,0,0.25);
};
	



return t