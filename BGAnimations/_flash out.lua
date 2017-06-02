local t = Def.ActorFrame{}

		t[#t+1] = Def.Quad{
			InitCommand=cmd(diffuse,1,1,1,0;zoomto,SCREEN_WIDTH,SCREEN_HEIGHT;Center);
			OnCommand=cmd(linear,0.3;diffusealpha,1;sleep,0.2);
		};

return t