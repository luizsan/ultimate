local t = Def.ActorFrame{}
local _volume = 1.0;

--=======================================================================================================================
--SOUND CONTROLLER
--=======================================================================================================================

t[#t+1] = Def.Actor{
	OnCommand=function(self)
		self:sleep(0.535);
		if SCREENMAN:GetTopScreen():GetName() == "ScreenSelectMusicCustom" then 
			self:queuecommand("PreviewStart"); 
		end;
	end;

	OffCommand=function(self) MESSAGEMAN:Broadcast("Volume", { volume = 0 }); end;

	MusicWheelMessageCommand=function(self)
		self:stoptweening(); 
		self:playcommand("Volume", { volume = 1 });
		SOUND:PlayMusicPart(THEME:GetPathS("","_missing"),0.1,0.1);
		self:sleep(0.535); 
		self:queuecommand("PreviewStart");
	end;

	PreviewStartCommand=function(self) 
		local music = Global.song:GetMusicPath();
		local start = 0;
		local length = 0;
		if music then
			start = Global.song:GetSampleStart()
			length = Global.song:GetSampleLength()
			SOUND:PlayMusicPart(music,start,length,1,1,true); 
			self:sleep(length - 1.25);
		end;
			self:queuecommand("Volume") -- zero volume
		MESSAGEMAN:Broadcast("Preview");
	end; 

	FinalDecisionMessageCommand=function(self) 
		for i=1,100 do
			self:finishtweening();
			MESSAGEMAN:Broadcast("Volume", { volume = 1-(i/100) }); 
			self:sleep(0.01);
		end;
	end;

	StateChangedMessageCommand=function(self)
		if Global.state == "GroupSelect" then
			MESSAGEMAN:Broadcast("Volume", { volume = _volume, global = 0.5 }); 
		else
			MESSAGEMAN:Broadcast("Volume", { volume = _volume, global = 1.0 }); 
		end;
	end;

	VolumeMessageCommand=function(self,param)
		local _duration = math.huge;
		if param and param.volume then _volume = param.volume; else _volume = 0; end;
		if param and param.global then Global.volume = param.global end;
		SOUND:DimMusic(_volume * Global.volume, _duration);
	end; 
};
	
t[#t+1] = LoadActor(THEME:GetPathS("","Difficulty"))..{
	StepsChangedMessageCommand=function(self, param) 
		if Global.state == "SelectSteps" then 
			if param and param.Player then 
				self:play(); 
			end;
		end; 
	end;
};	
	
t[#t+1] = LoadActor(THEME:GetPathS("","Confirm"))..{
	FinalDecisionMessageCommand=function(self)
		local scr = SCREENMAN:GetTopScreen()
		if scr and scr:IsTransitioning() then return end;
		self:play();
	end;
};	

t[#t+1] = LoadActor(THEME:GetPathS("","Group"))..{
	FolderChangedMessageCommand=cmd(play);
};	
	
t[#t+1] = LoadActor(THEME:GetPathS("","Select"))..{
	DecisionMessageCommand=cmd(play);
};	
	
t[#t+1] = LoadActor(THEME:GetPathS("","Switch"))..{
	MusicWheelMessageCommand=function(self,param) if param and not param.silent then self:play() end; end;
	SongGroupMessageCommand=cmd(play);
};	
	
t[#t+1] = LoadActor(THEME:GetPathS("","State"))..{
	MainMenuDecisionMessageCommand=cmd(play);
	OptionsListOpenedMessageCommand=cmd(play);
};	

t[#t+1] = LoadActor(THEME:GetPathS("","Steps"))..{
	StepsSelectedMessageCommand=cmd(play);
	SongSelectedMessageCommand=cmd(play);
	SpeedSelectedMessageCommand=cmd(play);
	NoteskinSelectedMessageCommand=cmd(play);
	OptionsListSelectedMessageCommand=function(self,param) if not param or not param.silent then self:play(); end; end;
	OptionsMenuSelectedMessageCommand=function(self,param) if not param or not param.silent then self:play(); end; end;
};	

t[#t+1] = LoadActor(THEME:GetPathS("","Mainmenu"))..{
	MainMenuMessageCommand=function(self,param) if param and param.Direction then self:play(); end; end;
	SpeedMenuMessageCommand=function(self,param) if not param or not param.silent then self:play() end; end;
	SpeedChangedMessageCommand=function(self,param) if not param or not param.silent then self:play(); end; end;
	NoteskinChangedMessageCommand=function(self,param) if not param or not param.silent then self:play(); end; end;
	EvaluationMenuMessageCommand=function(self,param) if not param or not param.silent then self:play(); end; end;
	OptionsMenuChangedMessageCommand=function(self,param) if not param or not param.silent then self:play(); end; end;
	OptionsListChangedMessageCommand=function(self,param) if not param or not param.silent then self:play(); end; end;
	ChangePropertyMessageCommand=function(self,param) if not param or not param.silent then self:play(); end; end;
};	
	
t[#t+1] = LoadActor(THEME:GetPathS("Common","Cancel"))..{
	OptionsListClosedMessageCommand=cmd(play);
	ReturnMessageCommand=function(self,param) 
		self:play();
	end;
};
	
	
return t;