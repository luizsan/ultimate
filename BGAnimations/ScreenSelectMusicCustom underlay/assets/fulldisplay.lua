local t = Def.ActorFrame{}
local ratio = 1;
local adjust = 0;

--//================================================================

t[#t+1] = Def.Sprite{

	InitCommand=cmd(Center;diffusealpha,0;valign,0);
	OnCommand=cmd(sleep,0.2;playcommand,"MusicWheel");
	MusicWheelMessageCommand=function(self)
		self:stoptweening();
		self:linear(0.2);
		self:diffusealpha(0);
		self:queuecommand("Unload");
		self:sleep(0.2);
		self:queuecommand("Load");
	end;
	
	UnloadMessageCommand=cmd(Load,nil);
	LoadCommand=function(self)

		LoadBackground(self,Global.song);
		
		ratio = self:GetWidth()/self:GetHeight();
		adjust = ((16/9) - ratio)/4;
		
		self:fadeleft(adjust);
		self:faderight(adjust);

		self:stretchto(0,0,SCREEN_HEIGHT*ratio,SCREEN_HEIGHT);
		self:x(SCREEN_CENTER_X);
		self:y(SCREEN_TOP+20);

		self:linear(0.3);
		self:diffuse(1,1,1,1);

		self:cropbottom(0.15);
		self:fadebottom(0.05);

		MESSAGEMAN:Broadcast("UpdateOverlay");
	end;
};

t[#t+1] = LoadActor(THEME:GetPathG("","overlay"))..{
	InitCommand=cmd(valign,0;diffuse,Global.bgcolor;visible,false);
	UpdateOverlayMessageCommand=function(self)
		self:visible(true);
		self:stretchto(0,0,SCREEN_WIDTH,SCREEN_HEIGHT);
		self:x(SCREEN_CENTER_X);
		self:y(SCREEN_TOP+20);
	end;
};

-- layer 1
t[#t+1] = LoadActor(THEME:GetPathG("","bg"))..{
	InitCommand=cmd(FullScreen;diffuse,Global.bgcolor;diffusealpha,0.8;fadetop,0.8);
};

-- layer 2
t[#t+1] = LoadActor(THEME:GetPathG("","bg"))..{
	InitCommand=cmd(FullScreen;diffuse,Global.bgcolor;diffusealpha,0);
	StateChangedMessageCommand=function(self)
		self:stoptweening();
		self:decelerate(0.2);
		if(Global.state == "GroupSelect") then
			self:diffusealpha(0.8);
		else
			self:diffusealpha(0);
		end
	end
};

-- DIM
t[#t+1] = LoadActor(THEME:GetPathG("","glow"))..{
	InitCommand=cmd(y,SCREEN_TOP+48;x,SCREEN_CENTER_X;diffuse,BoostColor(Global.bgcolor,0.45);zoomy,0.3;croptop,0.5;fadetop,0.1;zoomx,1.2;diffusealpha,0);
	MainMenuMessageCommand=cmd(playcommand,"Refresh");
	StateChangedMessageCommand=cmd(playcommand,"Refresh");
	ToggleSelectMessageCommand=cmd(playcommand,"Refresh");
	RefreshCommand=function(self)
		self:stoptweening();
		self:decelerate(0.3);

		if((Global.confirm[PLAYER_1] + Global.confirm[PLAYER_2] >= GAMESTATE:GetNumSidesJoined()) or Global.state == "SelectSteps") and not Global.toggle then
			self:diffusealpha(0.85);
		else
			self:diffusealpha(0);
		end;
	end;
};


return t