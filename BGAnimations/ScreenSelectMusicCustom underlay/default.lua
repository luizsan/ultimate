local t = Def.ActorFrame{
	InitCommand=function(self) 
		SetGroups(); 
		SetSSM(); 
	end;

	OnCommand=cmd(sleep,0.1;queuecommand,"Unlock");
	UnlockCommand=function(self) 
		Global.lockinput = false; 
	end;
	
	MenuUpP1MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", {  Input = "Back", Player = PLAYER_1 }); end; 
	MenuUpP2MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", {  Input = "Back", Player = PLAYER_2 }); end; 
	MenuDownP1MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Input = "Back", Player = PLAYER_1  }); end; 
	MenuDownP2MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Input = "Back", Player = PLAYER_2  }); end; 
	MenuLeftP1MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", {  Input = "Prev", Player = PLAYER_1  }); end;
	MenuLeftP2MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", {  Input = "Prev", Player = PLAYER_2 }); end; 
	MenuRightP1MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Input = "Next", Player = PLAYER_1  }); end; 
	MenuRightP2MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Input = "Next", Player = PLAYER_2  }); end; 
	MouseScrollUpMessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Input = "Prev", Player = master }); end; 
	MouseScrollDownMessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Input = "Next", Player = master  }); end; 
	MenuInputMessageCommand=function(self,param) if not Global.lockinput then InputController(self,param) end; end;	
	CodeMessageCommand=function(self,param) if not Global.lockinput then CodeController(self,param); end; end;
}

--//================================================================	

function InputController(self,param)
	if param and param.Player and GAMESTATE:IsSideJoined(param.Player) then
		if Global.state == "MainMenu" then MainMenuController(self,param) end;
		if Global.state == "GroupSelect" then GroupController(self,param) end;
		if Global.state == "MusicWheel" then WheelController(self,param) end;
		if Global.state == "SelectSteps" then StepsController(self,param) end;
		if Global.state == "SpeedMods" then SpeedController(self,param); end;
		if Global.state == "Noteskins" then NoteskinController(self,param); end;
	end;
end;

--//================================================================	

function CodeController(self,param)
	if GAMESTATE:IsSideJoined(param.PlayerNumber) then

		if param.Name == "Back" then 
			MESSAGEMAN:Broadcast("MenuInput", {  Input = "Cancel", Player = Global.master }); 
		end;	
			
		if param.Name == "Center" or param.Name == "Start" then 
			MainMenuDecision({Player = param.PlayerNumber});
		end;

		if param.Name == "PressSelect" and not HighScoreBlockedState() then
			Global.toggle = true;
			MESSAGEMAN:Broadcast("ToggleSelect", { Toggled = true });
		end

		if param.Name == "ReleaseSelect" then
			Global.toggle = false;
			MESSAGEMAN:Broadcast("ToggleSelect", { Toggled = false })
		end

		if param.Name == "Return" and Global.level == 1 then 
			SCREENMAN:SetNewScreen(SCREENMAN:GetTopScreen():GetPrevScreenName()); 
		end;

		MESSAGEMAN:Broadcast("MenuInput", { Input = param.Name, Player = param.PlayerNumber });
	end;
end;

--//================================================================	

--the order is important, do not change
t[#t+1] = LoadActor("assets/sound");
t[#t+1] = LoadActor("assets/fulldisplay");
t[#t+1] = LoadActor("assets/highscores");




t[#t+1] = LoadActor("assets/groupselect");
t[#t+1] = LoadActor("assets/notefield");

if VersionBranch("5.0") then 
	t[#t+1] = LoadActor("assets/noteskin");
	t[#t+1] = LoadActor("assets/speedmods");
else 
	t[#t+1] = LoadActor("assets/newskin");
	t[#t+1] = LoadActor("assets/speedprefs");
end;



t[#t+1] = LoadActor("assets/bannerwheel");
t[#t+1] = LoadActor("assets/cursteps");
t[#t+1] = LoadActor("assets/information");
t[#t+1] = LoadActor("assets/stepslist");
t[#t+1] = LoadActor("assets/mainmenu");	
t[#t+1] = LoadActor("assets/transition");

--[[
--BPM DISPLAY
t[#t+1] = LoadActor(THEME:GetPathG("","hex"))..{
	InitCommand=cmd(animate,false;Center;diffuseshift;effectcolor1,1,1,1,1;effectcolor2,1,1,1,0;zoom,0.5);
	MusicWheelMessageCommand=cmd(effectperiod,1);
	
	PreviewMessageCommand=function(self)
		local timing = Global.song:GetTimingData();
		local beat = timing:GetBeatFromElapsedTime(Global.song:GetSampleStart())
		local bpm = timing:GetBPMAtBeat(beat)
	
		self:effectoffset(-0.52);
		self:effectperiod(60/bpm);
	
	end;
}
]]

return t