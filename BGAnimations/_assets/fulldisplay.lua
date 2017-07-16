local t = Def.ActorFrame{};

local ratio = 1;
local adjust = 0;

--//================================================================

t[#t+1] = Def.Sprite{

	InitCommand=cmd(Center;diffusealpha,0;valign,0);

	OnCommand=function(self)
		self:sleep(0.2);

		local scr = SCREENMAN:GetTopScreen():GetName();
		if scr == "ScreenSelectMusicCustom" then self:playcommand("MusicWheel");
		elseif scr == "ScreenEvaluationCustom" then self:playcommand("Eval"); 
		end;
	end;

	OffCommand=cmd(stoptweening;linear,0.5;diffuse,1,1,1,0);

	MusicWheelMessageCommand=function(self)
		self:stoptweening();
		self:linear(0.2);
		self:diffusealpha(0);
		self:queuecommand("Unload");
		self:sleep(0.2);
		self:queuecommand("Load");
	end;

	EvalCommand=function(self)

        LoadBackground(self,Global.song);
        self:stoptweening();
        self:diffuse(0.2,0.2,0.2,0);
        self:cropbottom(0.15);
        self:fadebottom(0.05);

        ratio = self:GetWidth()/self:GetHeight();
        adjust = ((16/9) - ratio)/4;
        
        self:fadeleft(adjust);
        self:faderight(adjust);

        self:stretchto(0,0,SCREEN_HEIGHT*ratio,SCREEN_HEIGHT);
        self:x(SCREEN_CENTER_X);
        self:y(SCREEN_TOP+20);

        self:linear(0.3);
        self:diffuse(0.2,0.2,0.2,0.8);


        MESSAGEMAN:Broadcast("UpdateOverlay");
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
		if 	Global.state == "GroupSelect" or
			Global.state == "SelectSteps" then
			--Global.state == "OptionsMenu" then
			self:diffusealpha(0.85);
		else
			self:diffusealpha(0);
		end
	end
};

return t