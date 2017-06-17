local boxsize = 100;
local t = Def.ActorFrame{};

t[#t+1] = Def.ActorFrame{
	InitCommand=cmd(CenterX;y,SCREEN_CENTER_Y+20);

		LoadActor(THEME:GetPathG("","_pattern"))..{
			InitCommand=cmd(zoomto,SCREEN_WIDTH,boxsize;customtexturerect,0,0,(SCREEN_WIDTH/384)*1.5,(boxsize/384)*1.5;texcoordvelocity,0,0.1;diffusealpha,0.075;blend,Blend.Add);
		},
		Def.Quad{
			InitCommand=cmd(zoomto,SCREEN_WIDTH,boxsize;diffuse,0,0,0,0.5;diffusetopedge,0,0,0,0.6);
		},
		Def.Quad{
			InitCommand=cmd(zoomto,SCREEN_WIDTH,boxsize/4;vertalign,top;y,-boxsize/2;diffuse,0,0,0,0.25;fadebottom,1);
		},
		Def.Quad{
			InitCommand=cmd(zoomto,SCREEN_WIDTH,1;y,-(boxsize/2)-1;diffuse,1,1,1,0.15);
		},
		Def.Quad{
			InitCommand=cmd(zoomto,SCREEN_WIDTH,1;y,boxsize/2;diffuse,1,1,1,0.25);
		},
		LoadActor(THEME:GetPathG("","logo"))..{
			InitCommand=cmd(zoom,0.5;y,-(SCREEN_HEIGHT/4));
		},
		Def.BitmapText{
			Font = Fonts.titlemenu["Version"];
			Text = string.upper("ver."..themeInfo.Version);
			InitCommand=cmd(zoom,0.3;horizalign,right;y,(-boxsize/2)-10;strokecolor,0.1,0.1,0.1,0.25;diffusealpha,1/3;x,160);
		},

};

return t;

