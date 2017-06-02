local t = Def.ActorFrame{}
--=======================================================================================================================
--SOUND CONTROLLER
--=======================================================================================================================
	t[#t+1] = Def.Actor{
		OnCommand=cmd(sleep,0.535;queuecommand,"PreviewStart");
		MusicWheelMessageCommand=function(self)
			self:stoptweening(); 
			SOUND:PlayMusicPart(THEME:GetPathS("","_missing"),0.1,0.1);
			self:sleep(0.535); 
			self:queuecommand("PreviewStart");
		end;
		
		PreviewStartCommand=function(self) 
			MESSAGEMAN:Broadcast("Preview");
			SOUND:PlayMusicPart(Global.song:GetMusicPath(),Global.song:GetSampleStart(),Global.song:GetSampleLength(),1,1); 
		end; 

		FinalDecisionMessageCommand=function(self) 
			for i=1,100 do
				self:finishtweening();
				MESSAGEMAN:Broadcast("Volume", {volume=1-(i/100)}); 
				self:sleep(0.01);
			end;
		end;

		StateChangedMessageCommand=function(self)
			if Global.state == "GroupSelect" then
				MESSAGEMAN:Broadcast("Volume", {volume=0.5}); 
			else
				MESSAGEMAN:Broadcast("Volume", {volume=1.0}); 
			end;
		end;

		VolumeMessageCommand=function(self,param)
			local _volume = 0;
			local _duration = math.huge;

			if param and param.volume then _volume = param.volume end;
			if param and param.duration then _duration = param.duration end;

			SOUND:DimMusic(_volume,_duration);
		end; 

};
	
t[#t+1] = LoadActor(THEME:GetPathS("","SSM_Difficulty"))..{
	StepsChangedMessageCommand=function(self) if Global.state == "SelectSteps" then self:play(); end; end;
};	
	
t[#t+1] = LoadActor(THEME:GetPathS("","SSM_Confirm"))..{
	FinalDecisionMessageCommand=cmd(play);
};	

t[#t+1] = LoadActor(THEME:GetPathS("","SSM_Group"))..{
	FolderChangedMessageCommand=cmd(play);
};	
	
	
t[#t+1] = LoadActor(THEME:GetPathS("","SSM_Select"))..{
	DecisionMessageCommand=cmd(play);
};	
	
t[#t+1] = LoadActor(THEME:GetPathS("","SSM_Switch"))..{
	MusicWheelMessageCommand=function(self,param) if param and not param.silent then self:play() end; end;
	SongGroupMessageCommand=cmd(play);
};	
	
t[#t+1] = LoadActor(THEME:GetPathS("","SSM_State"))..{
	MainMenuDecisionMessageCommand=cmd(play);
};	

t[#t+1] = LoadActor(THEME:GetPathS("","SSM_Steps"))..{
	StepsSelectedMessageCommand=cmd(play);
	SongSelectedMessageCommand=cmd(play);
	SpeedSelectedMessageCommand=cmd(play);
	NoteskinSelectedMessageCommand=cmd(play);
};	

t[#t+1] = LoadActor(THEME:GetPathS("","SSM_Mainmenu"))..{
	MainMenuMessageCommand=function(self,param) if param and param.Direction then self:play(); end; end;
	SpeedMenuMessageCommand=function(self,param) if not param or not param.silent then self:play() end; end;
	SpeedChangedMessageCommand=function(self,param) if not param or not param.silent then self:play(); end; end;
	NoteskinChangedMessageCommand=function(self,param) if not param or not param.silent then self:play(); end; end;
};	
	
t[#t+1] = LoadActor(THEME:GetPathS("Common","Cancel"))..{
	ReturnMessageCommand=function(self,param) 
		self:play();
	end;
};
	
	
return t;