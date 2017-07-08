local t = MenuInputActor()..{
	InitCommand=function(self) 
		ResetState();
		SetGroups(); 
		SetSSM(); 
	end;

	OnCommand=cmd(sleep,1;queuecommand,"Unlock");
	PlayerJoinedMessageCommand=function() 
		GAMESTATE:SetCurrentStyle("versus");
		SCREENMAN:SetNewScreen("ScreenSelectMusicCustom");
	end;
	MenuInputMessageCommand=function(self,param) 
		if param and param.Player and SideJoined(param.Player) and not Global.lockinput then
			InputController(self,param);
			MainController(self,param);
		end;
	end;	
}

--//================================================================	

function InputController(self,param)
	if Global.oplist[param.Player] then
		OptionsListController(self,param);
	else
		if Global.state == "MainMenu" then MainMenuController(self,param) end;
		if Global.state == "GroupSelect" then GroupController(self,param) end;
		if Global.state == "MusicWheel" then WheelController(self,param) end;
		if Global.state == "SelectSteps" then StepsController(self,param) end;
		if Global.state == "SpeedMods" then SpeedController(self,param); end;
		if Global.state == "Noteskins" then NoteskinController(self,param); end;
		if Global.state == "OptionsMenu" then OptionsMenuController(self,param); end;
	end;
end;

--//================================================================	

function MainController(self,param)
	if param.Input == "Options" and not Global.oplist[param.Player] then
		InputController(self, { Player = param.Player, Input = "Next", Button = "Right" })
		Global.oplist[param.Player] = true
		MESSAGEMAN:Broadcast("OptionsListOpened", param);
	end;

	if param.Input == "PressSelect" then
		if not Global.oplist[param.Player] then
			Global.oplist[param.Player] = true
			MESSAGEMAN:Broadcast("OptionsListOpened", param);
			return;
		else
			Global.oplist[param.Player] = false;
			MESSAGEMAN:Broadcast("Return", param);
			MESSAGEMAN:Broadcast("OptionsListClosed", param);
			return;
		end
	end;

	if param.Input == "Center" or param.Input == "Start" then 
		if Global.oplist[param.Player] then
			SelectOptionsList(param);
		else
			MainMenuDecision({ Player = param.Player });
		end;
	end;

	--[[
	if param.Input == "PressSelect" and not HighScoreBlockedState() then
		Global.toggle = true;
		MESSAGEMAN:Broadcast("ToggleSelect", { Toggled = true });
	end

	if param.Input == "ReleaseSelect" then
		Global.toggle = false;
		MESSAGEMAN:Broadcast("ToggleSelect", { Toggled = false })
	end
	]]

	if param.Input == "Return" and Global.level == 1 then 
		if not Global.oplist[param.Player] then
			Global.blockjoin = false;
			SCREENMAN:SetNewScreen(SCREENMAN:GetTopScreen():GetPrevScreenName()); 
		else
			OptionsListController(self,param);
		end;
	end;
end;

--//================================================================	

t[#t+1] = LoadActor(THEME:GetPathB("","_assets/sound"));
t[#t+1] = LoadActor(THEME:GetPathB("","_assets/fulldisplay"));

if VersionBranch("5.0") then 
	t[#t+1] = LoadActor("assets/noteskin");
	t[#t+1] = LoadActor("assets/speedmods");
else 
	t[#t+1] = LoadActor("assets/notefield");
	t[#t+1] = LoadActor("assets/newskin");
	t[#t+1] = LoadActor("assets/speedprefs");
end;

t[#t+1] = LoadActor("assets/highscores");
t[#t+1] = LoadActor("assets/groupselect");
t[#t+1] = LoadActor("assets/bannerwheel");
t[#t+1] = LoadActor("assets/information");
t[#t+1] = LoadActor("assets/stepslist");
t[#t+1] = LoadActor("assets/optionsmenu");
t[#t+1] = LoadActor("assets/optionslist");
t[#t+1] = LoadActor("assets/mainmenu");	

t[#t+1] = LoadActor(THEME:GetPathB("","_assets/cursteps"));
t[#t+1] = LoadActor(THEME:GetPathB("","_assets/transition"));

--//================================================================

return t