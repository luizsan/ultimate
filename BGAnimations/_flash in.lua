Global.lockinput = true;

local t = Def.ActorFrame{}

		t[#t+1] = Def.Quad{
			InitCommand=cmd(diffuse,1,1,1,1;zoomto,SCREEN_WIDTH,SCREEN_HEIGHT;Center);
			OnCommand=cmd(linear,0.3;diffusealpha,0;sleep,0.2;queuecommand,"Unlock");
			UnlockCommand=function(self) lockinput = false; end;
		};

return t