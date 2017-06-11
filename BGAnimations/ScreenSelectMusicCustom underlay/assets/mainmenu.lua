local t = Def.ActorFrame{
	OnCommand=cmd(stoptweening;diffusealpha,0;sleep,0.2;linear,0.15;diffusealpha,1);
}

local originY = SCREEN_TOP+52;
local spacing = 79;
local vert = 14

local menutable = {
	{ name = "Group", state = "GroupSelect", enabled = true },
	{ name = "Song", state = "MusicWheel", enabled = true },
	{ name = "Steps", state = "SelectSteps", enabled = true },
	{ name = "Ready!", state = "MainMenu", enabled = true },
	{ name = "Speed", state = "SpeedMods", enabled = true },
	{ name = "Noteskin", state = "Noteskins", enabled = true },
	{ name = "Options", state = "OptionSelect", enabled = false },
};

--//================================================================

function MainMenuController(self,param)
	Global.blocksteps = true;

	if param.Input == "Prev" then 
	 	Global.selection = Global.selection-1;
		while Global.selection < 1 or not menutable[Global.selection].enabled do
			if Global.selection < 1 then
				Global.selection = #menutable;
			end;
			if not menutable[Global.selection].enabled then
				Global.selection = Global.selection-1;
			end;
		end;
		Global.confirm[PLAYER_1] = 0;
		Global.confirm[PLAYER_2] = 0;
		MESSAGEMAN:Broadcast("MainMenu",{Direction=param.Input}); 
	end

	if param.Input == "Next" then
	 	Global.selection = Global.selection+1; 
		while Global.selection > #menutable or not menutable[Global.selection].enabled do
			if Global.selection > #menutable then
				Global.selection = 1;
			end;
			if not menutable[Global.selection].enabled then
				Global.selection = Global.selection+1;
			end;
		end;
		Global.confirm[PLAYER_1] = 0;
		Global.confirm[PLAYER_2] = 0;
		MESSAGEMAN:Broadcast("MainMenu",{Direction=param.Input}); 
	end;

	if param.Input == "Back" then
	 	if Global.confirm[param.Player] > 0 then
	 		MESSAGEMAN:Broadcast("Return");
	 	end;
		Global.confirm[param.Player] = 0;
	 	MESSAGEMAN:Broadcast("MainMenu"); 

	end;

end;

--//================================================================

function ReadyDecision(param)

		GAMESTATE:SetCurrentSong(Global.song);
		GAMESTATE:SetPreferredSong(Global.song);

		Global.master = GAMESTATE:GetMasterPlayerNumber();
		Global.mastersteps = Global.pncursteps[Global.master];


		if GAMESTATE:GetNumSidesJoined() == 1 then 

			if PureType(Global.mastersteps) == "Routine" then
				Global.blockjoin = false;
				GAMESTATE:JoinPlayer(OtherPlayer[Global.master]);

				GAMESTATE:SetCurrentSteps(PLAYER_1,Global.mastersteps);
				GAMESTATE:SetCurrentSteps(PLAYER_2,Global.mastersteps);
				GAMESTATE:SetCurrentStyle("routine");
				Global.blockjoin = true;
			else
				GAMESTATE:SetCurrentSteps(Global.master,Global.mastersteps);
			end;
		else

			-- apply same failtype for both players
			local fail = GAMESTATE:GetPlayerState(Global.master):GetPlayerOptions("ModsLevel_Current"):FailSetting();
			GAMESTATE:GetPlayerState(OtherPlayer[Global.master]):GetPlayerOptions("ModsLevel_Current"):FailSetting(fail);

			GAMESTATE:SetCurrentSteps(PLAYER_1,Global.pncursteps[PLAYER_1]);
			GAMESTATE:SetCurrentSteps(PLAYER_2,Global.pncursteps[PLAYER_2]);

		end

	SCREENMAN:SetNewScreen("ScreenStageInformation");

end;

--//================================================================

function MainMenuDecision(param)
	--level 1
	if Global.level == 1 then
		if Global.selection ~= 4 then MESSAGEMAN:Broadcast("MainMenuDecision"); end;
		if Global.selection == 1 then MainMenuFolders(); return; end;
		if Global.selection == 2 then MainMenuSongs(); return; end;
		if Global.selection == 3 then MainMenuSteps(); return; end;
		if Global.selection == 4 then MainMenuReady(param); return; end;
		if Global.selection == 5 then MainMenuSpeeds(); return; end;
		if Global.selection == 6 then MainMenuNoteskins(); return; end;
	--level 2
	elseif Global.level == 2 then
		if Global.state == "GroupSelect" then SelectFolder(); return; end;	
		if Global.state == "MusicWheel" then SelectSong(); return end;
		if Global.state == "SelectSteps" then SelectStep(param); return; end;
		if Global.state == "SpeedMods" then	SelectSpeed(param); return; end;
		if Global.state == "Noteskins" then SelectNoteskin(param); return; end;
	end;
end;	

--//================================================================

function MainMenuReady(param)
	if Global.confirm[PLAYER_1] + Global.confirm[PLAYER_2] >= GAMESTATE:GetNumSidesJoined() then
		Global.confirm[PLAYER_1] = 999;
		Global.confirm[PLAYER_2] = 999;
		Global.lockinput = true;
		MESSAGEMAN:Broadcast("FinalDecision");
		return;
	else
		Global.toggle = false;
		Global.confirm[param.Player] = 1;
		GAMESTATE:SetPreferredSong(Global.song);
		MESSAGEMAN:Broadcast("ToggleSelect");
		MESSAGEMAN:Broadcast("MainMenu");
		MESSAGEMAN:Broadcast("Decision");
		return;
	end;
end;	

--//================================================================	

function MainMenuFolders()
	Global.level = 2;
	Global.state = "GroupSelect";
	Global.selection = SetGroupSelection()
	MESSAGEMAN:Broadcast("StateChanged"); 
end;
		
--//================================================================
		
function MainMenuSongs()
	Global.level = 2;
	Global.state = "MusicWheel";
	MESSAGEMAN:Broadcast("StateChanged"); 
	Global.selection = SetWheelSelection()
end;

--//================================================================

function MainMenuSteps()
	Global.prevstate = "MainMenu"
	Global.level = 2;
	Global.state = "SelectSteps";
	MESSAGEMAN:Broadcast("StateChanged");
	Global.selection = 1;
end;

--//================================================================

function MainMenuSpeeds()
	Global.prevstate = "MainMenu"
	Global.level = 2;
	Global.state = "SpeedMods";
	MESSAGEMAN:Broadcast("StateChanged");
	MESSAGEMAN:Broadcast("SpeedMenu", { silent = true });

end;

--//================================================================

function MainMenuNoteskins()
	Global.prevstate = "MainMenu"
	Global.level = 2;
	Global.state = "Noteskins";
	MESSAGEMAN:Broadcast("StateChanged");
	MESSAGEMAN:Broadcast("ResetNoteskin", { silent = true });
	MESSAGEMAN:Broadcast("NoteskinChanged", { silent = true }); 

end;

--//================================================================

for i=1,#menutable do
	
	t[#t+1] = LoadActor(THEME:GetPathG("","menuslot"))..{
		InitCommand=cmd(animate,false;zoom,0.388;setstate,0;y,originY;draworder,1;playcommand,"MainMenu");
		StateChangedMessageCommand=cmd(playcommand,"MainMenu");
		MainMenuMessageCommand=function(self)
			self:stoptweening();

			local state = 1;

			if i==1 or i==#menutable then self:x(SCREEN_CENTER_X+(i*spacing)-(spacing*(math.ceil(#menutable/2))));
			else self:x(SCREEN_CENTER_X+(i*spacing)-(spacing*(math.ceil(#menutable/2))));
			end;	

			if i~=1 and i~=#menutable then state = 2; end;
			if i==(math.ceil(#menutable/2)) then state = 3; end;
			if i==#menutable then self:zoomx(-0.388); end;

			if not menutable[i].enabled then
				self:diffuse(0.9,0.25,0.25,1);
			end;

			self:setstate(state);
			--self:diffusebottomedge(0.75,0.9,1,0.9);
		end;
	};
	
	--highlight
	t[#t+1] = LoadActor(THEME:GetPathG("","menuslot"))..{
			InitCommand=cmd(animate,false;zoom,0.388;setstate,0;y,originY;draworder,2;playcommand,"MainMenu");	
			StateChangedMessageCommand=cmd(playcommand,"MainMenu");
			MainMenuMessageCommand=function(self)

				self:stoptweening();
				local state = 1; 

				if i==1 or i==7 then self:x(SCREEN_CENTER_X+(i*spacing)-(spacing*(math.ceil(#menutable/2))));
				else self:x(SCREEN_CENTER_X+(i*spacing)-(spacing*(math.ceil(#menutable/2))));
				end;

				
				if i==#menutable then self:zoomx(-0.388); end;
				if i~=1 and i~=#menutable then state = 2; end;
				if i==math.ceil(#menutable/2) and Global.confirm[PLAYER_1] + Global.confirm[PLAYER_2] >= GAMESTATE:GetNumSidesJoined() then state = 3; end;

				self:setstate(state+4);
				
					if Global.level == 1 then 

						if Global.selection == i then
							self:visible(true);
						else
							self:visible(false);
						end

					else 

						if i == 1 and Global.state == "GroupSelect" then self:visible(true);
						elseif i == 2 and Global.state == "MusicWheel" then self:visible(true);
						elseif i == 3 and Global.state == "SelectSteps" then self:visible(true);
						elseif i == 5 and Global.state == "SpeedMods" then self:visible(true);
						elseif i == 6 and Global.state == "Noteskins" then self:visible(true);

						else
							self:visible(false)
						end

					end;
			end;
		
	};
	
	
	t[#t+1] = LoadFont("neotech")..{
			InitCommand=cmd(zoomx,0.42;zoomy,0.41;y,originY-1;strokecolor,0.15,0.15,0.15,0.8;draworder,3;playcommand,"MainMenu");
			OnCommand=cmd(settext,menutable[i].name);
			StateChangedMessageCommand=cmd(playcommand,"MainMenu");
			MainMenuMessageCommand=function(self) 

				self:stoptweening();		
				self:stopeffect();	
			
				if i==1 then self:x(SCREEN_CENTER_X+(i*spacing)-(spacing*(math.ceil(#menutable/2)))+2);
				elseif i==#menutable then self:x(SCREEN_CENTER_X+(i*spacing)-(spacing*(math.ceil(#menutable/2)))-3);
				else self:x(SCREEN_CENTER_X+(i*spacing)-(spacing*(math.ceil(#menutable/2))));
				end;
			
				--self:decelerate(0.2);
				
				if Global.level == 1 then 
					if Global.selection == i then 
						if i==4 and Global.confirm[PLAYER_1]+Global.confirm[PLAYER_2] >= GAMESTATE:GetNumSidesJoined() then
							self:diffuse(1,1,1,1)
							self:diffuseshift();
							self:effectcolor1(0.85,0.75,0,1);
							self:effectcolor2(0.65,0.5,0,1);
							self:strokecolor(0.8,0.6,0,0.2);
						else
							self:diffuse(BoostColor(HighlightColor(),0.75));
							self:strokecolor(0.75,0.95,1,0.8);		
						end;
					else 
						self:diffuse(1,1,1,1)
						self:strokecolor(0.15,0.15,0.15,0.8);
					end; 
					
					
				elseif Global.level == 2 then

					if Global.state == menutable[i].state then
						if i==4 then
							self:diffuse(1,1,1,1)
							self:diffuseshift();
							self:effectcolor1(0.85,0.75,0,1);
							self:effectcolor2(0.65,0.5,0,1);
							self:strokecolor(0.8,0.6,0,0.2);
						else
							self:diffuse(BoostColor(HighlightColor(),0.75));
							self:strokecolor(0.75,0.95,1,0.8);		
						end;
					else
						self:diffuse(1,1,1,0.33)
						self:strokecolor(0.15,0.15,0.15,0.8);
					end;

				end;

				
				if not menutable[i].enabled then self:diffuse(0.75,0.25,0.25,0.66); end;
				
			end;
	};
	

	
end;



t[#t+1] = LoadActor(THEME:GetPathG("","holes"))..{
	InitCommand=cmd(zoom,0.475;x,SCREEN_CENTER_X-284;y,originY+6);
};
t[#t+1] = LoadActor(THEME:GetPathG("","holes"))..{
	InitCommand=cmd(zoom,0.475;x,SCREEN_CENTER_X+283;y,originY+6;zoomx,-0.475);
};


-- group
t[#t+1] = LoadFont("regen strong")..{
		InitCommand=cmd(horizalign,left;x,SCREEN_CENTER_X-266;y,SCREEN_TOP+72;zoom,0.322;diffuse,0.75,0.75,0.75,1;strokecolor,0.175,0.175,0.175,0.95);
		StateChangedMessageCommand=function(self)
			local g = string.gsub(Global.songgroup, "~", "-");
			local attr = { Length = -1; Diffuse = color("#FFFFFFAA"); };
			local prefix = "group: ";
			self:settext(string.upper(prefix .. g));
			self:AddAttribute(string.len(prefix), attr);
			self:diffusealpha(0.75);
		end;

		ToggleSelectMessageCommand=function(self)
			self:stoptweening();
			self:decelerate(0.15);
			if Global.toggle then
				self:zoomy(0);
			else
				self:zoomy(0.322);
			end;
		end;

};

-- song index
t[#t+1] = LoadFont("regen strong")..{
		InitCommand=cmd(horizalign,right;x,SCREEN_CENTER_X+266;y,SCREEN_TOP+72;zoom,0.322;diffuse,0.75,0.75,0.75,1;strokecolor,0.175,0.175,0.175,1;diffusealpha,2/3);
		BuildMusicListMessageCommand=cmd(playcommand,"Refresh");
		MusicWheelMessageCommand=cmd(playcommand,"Refresh");
		RefreshCommand=function(self)
			local b = #Global.songlist;
			local a = string.format("%0"..string.len(b).."d",Global.selection);
			local len = string.len(b)
			local attr = { Length = len; Diffuse = color("#FFFFFFAA"); };
			self:settext(string.upper(a.."  /  "..b.."  songs"));
			self:AddAttribute(0, attr);
			self:AddAttribute(len + 5, attr);
		end;

		ToggleSelectMessageCommand=function(self)
			self:stoptweening();
			self:decelerate(0.15);
			if Global.toggle then
				self:zoomy(0);
			else
				self:zoomy(0.322);
			end;
		end;
};



-- READY
t[#t+1] = LoadFont("neotech")..{
	InitCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_TOP+78;zoom,0.425;textglowmode,"TextGlowMode_Inner";strokecolor,0.3,0.3,0.3,1;diffusealpha,0;bob;effectmagnitude,0,2,0;effectperiod,1.75);
	OnCommand=cmd(settext,"All players ready! Press &START; button to play!";playcommand,"MainMenu");
	CodeMessageCommand=cmd(playcommand,"MainMenu");
	MainMenuMessageCommand=function(self)
	
	self:stoptweening();
	self:decelerate(0.125);
	
	local status = false;
	if Global.confirm[PLAYER_1] + Global.confirm[PLAYER_2] >= GAMESTATE:GetNumSidesJoined() then status = true end;
	
		if status == true and not Global.toggle then
			self:zoomy(0.425);
			self:diffusealpha(1);
		else
			self:zoomy(0);
			self:diffusealpha(0);
		end
	
	end;
};

-- HIGHSCORES
t[#t+1] = LoadFont("neotech")..{
	InitCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_TOP+78;zoom,0.425;textglowmode,"TextGlowMode_Inner";strokecolor,0.3,0.3,0.3,1;diffusealpha,0;bob;effectmagnitude,0,2,0;effectperiod,1.75);
	OnCommand=cmd(settext,"Press &SELECT; to show High Scores");
	CodeMessageCommand=cmd(playcommand,"StateChanged");
	StateChangedMessageCommand=function(self)
		self:stoptweening();
		self:decelerate(0.125);
		if Global.state == "SelectSteps" and not Global.toggle then
			self:zoomy(0.425);
			self:diffusealpha(1);
		else
			self:zoomy(0);
			self:diffusealpha(0);
		end;
	end;
}

--[[
-- STAGE
t[#t+1] = LoadFont("regen small")..{
	InitCommand=cmd(horizalign,right;zoomx,0.306;zoomy,0.3;strokecolor,0.2,0.2,0.2,1;x,SCREEN_CENTER_X+100;y,originY-20;diffusealpha,0.5);
	OnCommand=function(self)
		self:settext("STAGE "..GAMESTATE:GetCurrentStageIndex()+1);
	end;
}
	
-- GAMEMODE
t[#t+1] = LoadFont("regen small")..{
	InitCommand=cmd(horizalign,left;zoomx,0.31;zoomy,0.3;strokecolor,0.2,0.2,0.2,1;x,SCREEN_CENTER_X-100;y,originY-20;diffusealpha,0.5);
	OnCommand=function(self)
		self:settext("GAME: "..string.upper(Game()));
	end;
}

]]--



return t