themeInfo = {
	Name = "Ultimate",
};

--//================================================================

Navigation = {
	Icon = {
		["Play"] = 1,
		["Home"] = 4,
		["Profiles"] = 2,
		["Reload"] = 3,
		["Options"] = 5,
		["Quit"] = 6,
	},
	Screen = {
		["Play"] = "ScreenProfileLoad",
		["Home"] = "ScreenTitleMenu",
		["Profiles"] = "ScreenOptionsManageProfiles",
		["Reload"] = "ScreenReloadSongs",
		["Options"] = "ScreenOptionsService",
		["Quit"] = "ScreenExit",
	}
}

--//================================================================

function VersionBranch(ver)
	local search = string.find(string.lower(ProductVersion()), string.lower(ver));
	return search == 1
end;

--//================================================================

function GetPreviousScreen()
	if Global.screen == "ScreenSelectMusicCustom" then
		return "ScreenTitleMenu"
	else
		return Global.screen
	end;
end;

--//================================================================

function HoldWeight()
	if Game() == "Pump" then
		if PREFSMAN:GetPreference("AllowW1") == 'AllowW1_Never' then
			return THEME:GetMetric("ScoreKeeperNormal", "PercentScoreWeightW2");
		else
			return THEME:GetMetric("ScoreKeeperNormal", "PercentScoreWeightW1");
		end;
	else
		return 0
	end;
end;

--//================================================================

function Game()
	local game = string.upper(GAMESTATE:GetCurrentGame():GetName());
	local temp1 = string.sub(string.lower(game), 2);
	local text = string.gsub(string.upper(game),string.upper(temp1),temp1);
	return text
end;

--//================================================================

function NavigationAction(index)
	if GAMESTATE:GetNumSidesJoined() == 0 then
		GAMESTATE:JoinPlayer(PLAYER_1);
	end;
	SCREENMAN:SetNewScreen(Navigation.Screen[index]);
end;

--//================================================================

function pnAlign(pn) if pn == PLAYER_1 or pn == 1 then return left elseif pn == PLAYER_2 or pn == 2 then return right else return nil end; end;
function pnSide(pn) if pn == PLAYER_1 or pn == 1 then return -1 elseif pn == PLAYER_2 or pn == 2 then return 1 else return nil end; end;
function pnFade(pn,self,amount) if pn == PLAYER_1 or pn == 1 then self:faderight(amount) elseif pn == PLAYER_2 or pn == 2 then self:fadeleft(amount) end; end;
function pnCrop(pn,self,amount) if pn == PLAYER_1 or pn == 1 then self:cropright(amount) elseif pn == PLAYER_2 or pn == 2 then self:cropleft(amount) end; end;

--//================================================================

function Setup()

	PREFSMAN:SetPreference("PercentScoreWeightCheckpointHit",2);
	PREFSMAN:SetPreference("PercentScoreWeightCheckpointMiss",0);
	PREFSMAN:SetPreference("PercentScoreWeightHeld",0);
	PREFSMAN:SetPreference("PercentScoreWeightHitMine",-2);
	PREFSMAN:SetPreference("PercentScoreWeightLetGo",0);
	PREFSMAN:SetPreference("PercentScoreWeightMiss",0);
	PREFSMAN:SetPreference("PercentScoreWeightW1",3);
	PREFSMAN:SetPreference("PercentScoreWeightW2",2);
	PREFSMAN:SetPreference("PercentScoreWeightW3",1);
	PREFSMAN:SetPreference("PercentScoreWeightW4",0);
	PREFSMAN:SetPreference("PercentScoreWeightW5",0);

	if Game() == "Pump" then
		PREFSMAN:SetPreference("EditorNoteSkinP1","delta-note");
		PREFSMAN:SetPreference("EditorNoteSkinP2","delta-note");
	elseif Game() == "Dance" then
		PREFSMAN:SetPreference("EditorNoteSkinP1","midi-note");
		PREFSMAN:SetPreference("EditorNoteSkinP2","midi-note");
	end;
	
	PREFSMAN:SetPreference("EventMode",true);
	PREFSMAN:SetPreference("MenuTimer",false);
	PREFSMAN:SetPreference("PercentageScoring",true);

end

--//================================================================

function SetProfiles()
	--GAMESTATE:ApplyGameCommand("profileid,00000003",PLAYER_1);
	--GAMESTATE:ApplyGameCommand("profileid,00000001",PLAYER_2);
end;

--//================================================================

function ToInit() Setup(); if GAMESTATE:GetCoinMode() == 'CoinMode_Home' then return "ScreenInit" else return "ScreenExit" end; end;
function ToTitleMenu() if GAMESTATE:GetCoinMode() == 'CoinMode_Home' then return "ScreenTitleMenu" else return "ScreenExit" end; end;
function ToSelectMusic() if GAMESTATE:GetCoinMode() == 'CoinMode_Home' then return "ScreenSelectMusicCustom" else return "ScreenExit" end; end;
function ToSelectMusicFromGameplay() 
	if GAMESTATE:GetCoinMode() == 'CoinMode_Home' then 
		local master = GAMESTATE:GetMasterPlayerNumber();
		if IsRoutine() then
			return "ScreenUnjoin" 
		else
			return "ScreenSelectMusicCustom"
		end
	else 
		return "ScreenExit" 
	end; 
end;

Branch = {
	Init = function() return ToInit() end,
	AfterInit  = function() return ToTitleMenu() end,
	NoiseTrigger = function()
		local hour = Hour()
		return hour > 3 and hour < 6 and "ScreenNoise" or "ScreenInit"
	end,
	TitleMenu = function() return ToTitleMenu() end,
	StartGame = function()
		if SONGMAN:GetNumSongs() == 0 and SONGMAN:GetNumAdditionalSongs() == 0 then
			return "ScreenHowToInstallSongs"
		end
		if PROFILEMAN:GetNumLocalProfiles() >= 2 then
			SetProfiles();
			return "ScreenProfileLoad"
		else
			if THEME:GetMetric("Common","AutoSetStyle") == false then
				return "ScreenExit"
			else
				return "ScreenProfileLoad"
			end
		end
	end,
	OptionsEdit = function()
		-- Similar to above, don't let anyone in here with 0 songs.
		if SONGMAN:GetNumSongs() == 0 and SONGMAN:GetNumAdditionalSongs() == 0 then
			return "ScreenHowToInstallSongs"
		end
		return "ScreenOptionsEdit"
	end,
	AfterSelectProfile = function() return ToSelectMusic() end,
	AfterProfileLoad = function() return ToSelectMusic() end,
	AfterProfileSave = function() return ToSelectMusicFromGameplay() end,
	BackOutOfStageInformation = function() return ToSelectMusicFromGameplay() end,
	GameplayScreen = function() return IsRoutine() and "ScreenGameplayShared" or "ScreenGameplay" end,
	AfterGameplay = function() return "ScreenEvaluationCustom" end,
	--AfterEvaluation = function() return "ScreenProfileSave" end
	AfterEvaluation = function() return "ScreenGameplay" end
}

--//================================================================

function LuaError(str)
	lua.ReportScriptError(str);
end;

--//================================================================

function scorecap(n) -- credit http://richard.warburton.it
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
end

--//================================================================

function TextBannerAfterSet(self,param) 
	local Title=self:GetChild("Title"); 
	local Subtitle=self:GetChild("Subtitle"); 
	local Artist=self:GetChild("Artist"); 
	
	if Subtitle:GetText() == "" then 
		(cmd(maxwidth,660;zoom,0.425;shadowlength,1;settext,Title:GetText()))(Title);
		else
		(cmd(maxwidth,660;zoom,0.425;shadowlength,1;settext,Title:GetText().." "..Subtitle:GetText()))(Title);
	end
	(cmd(visible,false))(Subtitle);
	(cmd(visible,false))(Artist);
end

