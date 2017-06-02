local t = Def.ActorFrame{}

		t[#t+1] = Def.Quad{
			InitCommand=cmd(diffuse,1,1,1,1;zoomto,SCREEN_WIDTH,SCREEN_HEIGHT;Center);
		};

return t