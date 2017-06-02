local t = Def.ActorFrame{}
local spacing = 18;
local base = 42;
local modifiers = {1,10,25,50,100,1000};
local modes = {1,2,3};

local playerchoices = {
	[PLAYER_1] = {
		["SubState"] = "",
		["Menu"] = 1, 
		["Modifier"] = 3,
		["Mode"] = 3,
	},
	[PLAYER_2] = {
		["SubState"] = "",
		["Menu"] = 1, 
		["Modifier"] = 3,
		["Mode"] = 3,
	},
};

--//================================================================

local choices = {
	{ name = "Speed", action = function(param)

		local speed = GetSpeedAndMode(param.Player)[1]
		local mode = GetSpeedAndMode(param.Player)[2]

		if param.Input == "Prev" and speed > 1 then
			speed = speed - modifiers[playerchoices[param.Player]["Modifier"]];
			if speed < 1 then speed = 1; end;
			SetPlayerSpeed(param.Player, playerchoices[param.Player]["Mode"], speed)
			MESSAGEMAN:Broadcast("SpeedChanged", { Player = param.Player, decrease = true });
			MESSAGEMAN:Broadcast("SpeedMenu", { silent = true });
		end;

		if param.Input == "Next" and speed < 9999 then
			speed = speed + modifiers[playerchoices[param.Player]["Modifier"]];
			if speed > 9999 then speed = 9999; end;
			SetPlayerSpeed(param.Player, playerchoices[param.Player]["Mode"], speed)
			MESSAGEMAN:Broadcast("SpeedChanged", { Player = param.Player, increase = true });
			MESSAGEMAN:Broadcast("SpeedMenu", { silent = true });
		end;

	end;
	},

	{ name = "Modifier", action = function(param)

		if param.Input == "Prev" and playerchoices[param.Player]["Modifier"] > 1 then
			playerchoices[param.Player]["Modifier"] = playerchoices[param.Player]["Modifier"]-1;
			MESSAGEMAN:Broadcast("SpeedChanged", { Player = param.Player, decrease = true });
			MESSAGEMAN:Broadcast("SpeedMenu", { silent = true });
		end;

		if param.Input == "Next" and playerchoices[param.Player]["Modifier"] < #modifiers then
			playerchoices[param.Player]["Modifier"] = playerchoices[param.Player]["Modifier"]+1;
			MESSAGEMAN:Broadcast("SpeedChanged", { Player = param.Player, increase = true });
			MESSAGEMAN:Broadcast("SpeedMenu", { silent = true });
		end;
	end;
	},

	{ name = "Mode", action = function(param)
		if param.Input == "Prev" then
			playerchoices[param.Player]["Mode"] = playerchoices[param.Player]["Mode"] - 1;
			if playerchoices[param.Player]["Mode"] < 1 then playerchoices[param.Player]["Mode"] = #modes; end;
			SetPlayerSpeed(param.Player, playerchoices[param.Player]["Mode"], GetSpeedAndMode(param.Player)[1])
			MESSAGEMAN:Broadcast("SpeedChanged", { Player = param.Player, decrease = true });
			MESSAGEMAN:Broadcast("SpeedMenu", { silent = true });
		end;

		if param.Input == "Next" then
			playerchoices[param.Player]["Mode"] = playerchoices[param.Player]["Mode"] + 1;
			if playerchoices[param.Player]["Mode"] > #modes then playerchoices[param.Player]["Mode"] = 1 end;
			SetPlayerSpeed(param.Player, playerchoices[param.Player]["Mode"], GetSpeedAndMode(param.Player)[1])
			MESSAGEMAN:Broadcast("SpeedChanged", { Player = param.Player, increase = true });
			MESSAGEMAN:Broadcast("SpeedMenu", { silent = true });
		end;

	end;
	},

	{ name = "Reset", action = function(param)
		SetPlayerSpeed(param.Player, 3, 250)
		playerchoices[param.Player]["Mode"] = 3;
		playerchoices[param.Player]["Modifier"] = 3;
		playerchoices[param.Player]["SubState"] = "Menu";
		MESSAGEMAN:Broadcast("StateChanged"); 
		MESSAGEMAN:Broadcast("SpeedMenu", { silent = true }); 
		MESSAGEMAN:Broadcast("SpeedSelected");
	end;
	},
};

--//================================================================

function SpeedController(self,param)
	if playerchoices[param.Player]["SubState"] == "Menu" then

		if param.Input == "Prev" and GAMESTATE:IsSideJoined(param.Player) and playerchoices[param.Player]["Menu"] > 1 then
			playerchoices[param.Player]["Menu"] = playerchoices[param.Player]["Menu"] - 1;
			MESSAGEMAN:Broadcast("SpeedMenu");
		end;

		if param.Input == "Next" and GAMESTATE:IsSideJoined(param.Player) and playerchoices[param.Player]["Menu"] < #choices then
			playerchoices[param.Player]["Menu"] = playerchoices[param.Player]["Menu"] + 1;
			MESSAGEMAN:Broadcast("SpeedMenu");
		end;

	elseif playerchoices[param.Player]["SubState"] == "Speed" then
		choices[1].action(param); 
	elseif playerchoices[param.Player]["SubState"] == "Modifier" then
		choices[2].action(param); 
	elseif playerchoices[param.Player]["SubState"] == "Mode" then
		choices[3].action(param); 
	end;

	if param.Input == "Cancel" or param.Input == "Back" then
		if playerchoices[param.Player]["SubState"] == "Menu" then 
			Global.level = 1; 
			Global.selection = 5; 
			Global.state = "MainMenu";  
			playerchoices[PLAYER_1]["SubState"] = "";
			playerchoices[PLAYER_2]["SubState"] = "";
			MESSAGEMAN:Broadcast("StateChanged"); 
		else
 			playerchoices[param.Player]["SubState"] = "Menu";
 			MESSAGEMAN:Broadcast("SpeedMenu", { silent = true }); 
 			MESSAGEMAN:Broadcast("StateChanged"); 
		end;
		MESSAGEMAN:Broadcast("Return");
	end;

	--SCREENMAN:SystemMessage(GetSpeedAndMode(param.Player)[1]);
end;

--//================================================================

function SelectSpeed(param)
	if playerchoices[param.Player]["Menu"] == 4 then
		choices[4].action(param); 
		return;
	end;

	if playerchoices[param.Player]["SubState"] == "Menu" then
		playerchoices[param.Player]["SubState"] = choices[playerchoices[param.Player]["Menu"]].name;
		MESSAGEMAN:Broadcast("SpeedMenu", { silent = true }); 
		MESSAGEMAN:Broadcast("SpeedSelected"); 
		MESSAGEMAN:Broadcast("StateChanged");  
	end;

end;

--//================================================================	

function SetPlayerSpeed(pn, mode, speed)
	local prf_options = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred")
	local stg_options = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Stage")
	local sng_options = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Song")
	local cur_options = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Current")

	pref = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred");
	if mode == 1 or mode == "X" then
		prf_options:XMod(speed/100)
		stg_options:XMod(speed/100)
		sng_options:XMod(speed/100)
		cur_options:XMod(speed/100)
	elseif mode == 2 or mode == "C" then
		prf_options:CMod(speed)
		stg_options:CMod(speed)
		sng_options:CMod(speed)
		cur_options:CMod(speed)
	elseif mode == 3 or mode == "M" then
		prf_options:MMod(speed)
		stg_options:MMod(speed)
		sng_options:MMod(speed)
		cur_options:MMod(speed)
	end
end;


--//================================================================

function GetSpeedAndMode(pn)
	--local options= GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred")
	local options= GAMESTATE:GetPlayerState(pn):GetCurrentPlayerOptions()
	local speed = nil
	local mode = nil
	if options:MaxScrollBPM() > 0 then
		mode = "M"
		speed = math.round(options:MaxScrollBPM())
	elseif options:TimeSpacing() > 0 then
		mode = "C"
		speed = math.round(options:ScrollBPM())
	else
		mode = "X"
		speed = math.round(options:ScrollSpeed() * 100)
	end
	return { speed, mode }
end

--//================================================================

local function GetModeNumber(string)
	if string == "X" then return 1
	elseif string == "C" then return 2
	else return 3
	end
end

--//================================================================

local function GetModeString(int)
	if int == 1 then
		return "Multiple"
	elseif int == 2 then
		return "Constant"
	elseif int == 3 then
		return "Maximum"
	else
		return "None"
	end
end

--//================================================================

for pn in ivalues(GAMESTATE:GetHumanPlayers()) do

	t[#t+1] = Def.ActorFrame{
		InitCommand=cmd(y,SCREEN_CENTER_Y-140;x,SCREEN_CENTER_X+(240*pnSide(pn));diffusealpha,0);
		OnCommand=function(self)
			if GAMESTATE:IsSideJoined(pn) then
				playerchoices[pn]["Mode"] = GetModeNumber(GetSpeedAndMode(pn)[2]);
			end;
		end;
		SpeedMenuMessageCommand=function(self)
			for opt=1,#choices do
				if playerchoices[pn]["Menu"] == opt then
					self:GetChild(choices[opt].name):playcommand("GainFocus");
					self:GetChild("Cursor"):stoptweening();
					self:GetChild("Cursor"):decelerate(0.075);
					self:GetChild("Cursor"):y(self:GetChild(choices[opt].name):GetY()+1);
				else
					if playerchoices[pn]["SubState"] ~= "Menu" then
						self:GetChild(choices[opt].name):playcommand("Disable");
					else
						self:GetChild(choices[opt].name):playcommand("LoseFocus");
					end;
				end;
			end;
		end;

		StateChangedMessageCommand=function(self)
			self:stoptweening();
			self:decelerate(0.175);
			if Global.state == "SpeedMods" then
				if playerchoices[pn]["SubState"] == "" then
					playerchoices[pn]["SubState"] = "Menu";
				end;
				self:x(SCREEN_CENTER_X+(200*pnSide(pn)));
				self:diffusealpha(1);
			else
				playerchoices[pn]["Menu"] = 1;
				self:x(SCREEN_CENTER_X+(240*pnSide(pn)));
				self:diffusealpha(0);
			end;
		end;

		LoadActor(THEME:GetPathG("","panel"))..{
			InitCommand=cmd(zoom,0.45;y,-32;vertalign,top);
		},

		LoadFont("neotech")..{
			Text="Select Speed";
			InitCommand=cmd(zoom,0.425;diffuse,0.666,0.666,0.666,1;strokecolor,0.15,0.15,0.15,0.5;y,-2);
		},

		LoadFont("regen silver")..{
			Name = choices[1].name;
			InitCommand=cmd(zoom,0.575;diffuse,PlayerColor(pn);strokecolor,BoostColor(PlayerColor(pn),0.25);y,(base/2)-2);
			GainFocusCommand=cmd(diffuseshift;effectcolor1,BoostColor(PlayerColor(pn),2);effectcolor2,BoostColor(PlayerColor(pn),1.5);effectperiod,0.25;strokecolor,BoostColor(PlayerColor(pn),0.3));
			LoseFocusCommand=cmd(diffuse,PlayerColor(pn);strokecolor,BoostColor(PlayerColor(pn),0.25);stopeffect);
			DisableCommand=cmd(diffuse,BoostColor(PlayerColor(pn),0.5);strokecolor,BoostColor(PlayerColor(pn),0.2);stopeffect);
			SpeedMenuMessageCommand=function(self) 
				self:settext(FormatSpeed(GetSpeedAndMode(pn)[1],GetSpeedAndMode(pn)[2])); 
			end;
		},

		LoadFont("neotech")..{
			Name = choices[2].name;
			InitCommand=cmd(zoom,0.425;diffuse,PlayerColor(pn);strokecolor,BoostColor(PlayerColor(pn),0.25);y,base);
			GainFocusCommand=cmd(diffuseshift;effectcolor1,BoostColor(PlayerColor(pn),2);effectcolor2,BoostColor(PlayerColor(pn),1.5);effectperiod,0.25;strokecolor,BoostColor(PlayerColor(pn),0.3));
			LoseFocusCommand=cmd(diffuse,PlayerColor(pn);strokecolor,BoostColor(PlayerColor(pn),0.25);stopeffect);
			DisableCommand=cmd(diffuse,BoostColor(PlayerColor(pn),0.5);strokecolor,BoostColor(PlayerColor(pn),0.2);stopeffect);
			SpeedMenuMessageCommand=function(self)
				self:settext("Modifier: "..modifiers[playerchoices[pn]["Modifier"]]); 
			end;
		},

		LoadFont("neotech")..{
			Name = choices[3].name;
			InitCommand=cmd(zoom,0.425;diffuse,PlayerColor(pn);strokecolor,BoostColor(PlayerColor(pn),0.25);y,base+spacing);
			GainFocusCommand=cmd(diffuseshift;effectcolor1,BoostColor(PlayerColor(pn),2);effectcolor2,BoostColor(PlayerColor(pn),1.5);effectperiod,0.25;strokecolor,BoostColor(PlayerColor(pn),0.3));
			LoseFocusCommand=cmd(diffuse,PlayerColor(pn);strokecolor,BoostColor(PlayerColor(pn),0.25);stopeffect);
			DisableCommand=cmd(diffuse,BoostColor(PlayerColor(pn),0.5);strokecolor,BoostColor(PlayerColor(pn),0.2);stopeffect);
			SpeedMenuMessageCommand=function(self)
				self:settext("Mode: "..GetModeString(playerchoices[pn]["Mode"])); 
			end;
		},

		LoadFont("neotech")..{
			Text="Reset";
			Name = choices[4].name;
			InitCommand=cmd(zoom,0.425;diffuse,PlayerColor(pn);strokecolor,BoostColor(PlayerColor(pn),0.25);y,base+(spacing*2));
			GainFocusCommand=cmd(diffuseshift;effectcolor1,BoostColor(PlayerColor(pn),2);effectcolor2,BoostColor(PlayerColor(pn),1.5);effectperiod,0.25;strokecolor,BoostColor(PlayerColor(pn),0.3));
			LoseFocusCommand=cmd(diffuse,PlayerColor(pn);strokecolor,BoostColor(PlayerColor(pn),0.25);stopeffect);
			DisableCommand=cmd(diffuse,BoostColor(PlayerColor(pn),0.5);strokecolor,BoostColor(PlayerColor(pn),0.2);stopeffect);
		},

		Def.ActorFrame{
			Name = "Cursor";
			StateChangedMessageCommand=function(self)
				self:stoptweening();
				self:decelerate(0.2);
				if playerchoices[pn]["SubState"] == "Menu" or playerchoices[pn]["SubState"] == "" then
					self:diffuse(0.6,0.6,0.6,0.95);
				else
					self:diffuse(1,1,1,1);
				end;
			end;
			
			Def.ActorFrame{
			Name = "Normal";
				LoadActor(THEME:GetPathG("","miniarrow"))..{
					InitCommand=cmd(animate,false;x,-56;zoom,0.43);
				},	
				LoadActor(THEME:GetPathG("","miniarrow"))..{
					InitCommand=cmd(animate,false;x,56;zoom,0.43;zoomx,-0.43);
				},
			},

			Def.ActorFrame{
			Name = "Glow";
				LoadActor(THEME:GetPathG("","miniarrow"))..{
					InitCommand=cmd(animate,false;setstate,1;x,-56;zoom,0.43;diffusealpha,0;blend,"BlendMode_Add");
					SpeedChangedMessageCommand=function(self,param)
						if param.decrease and pn == param.Player then
							self:stoptweening();
							self:diffusealpha(1);
							self:decelerate(0.3);
							self:diffusealpha(0);
						end;
					end;
				},	
				LoadActor(THEME:GetPathG("","miniarrow"))..{
					InitCommand=cmd(animate,false;setstate,1;x,56;zoom,0.43;zoomx,-0.43;diffusealpha,0;blend,"BlendMode_Add");
					SpeedChangedMessageCommand=function(self,param)
						if param.increase and pn == param.Player then
							self:stoptweening();
							self:diffusealpha(1);
							self:decelerate(0.3);
							self:diffusealpha(0);
						end;
					end;
				},
			},

		},


	};

end;

return t;