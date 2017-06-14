local spacing = 66;
local skewing = 16;
local gap = 20;
local latest;
local scores = {
	[PLAYER_1] = {},
	[PLAYER_2] = {},
};

--//================================================================

function HighScoreBlockedState()
	if  Global.state == "GroupSelect" or 
		Global.state == "SpeedMods" or 
		Global.state == "Noteskins" or 
		(Global.state == "MainMenu" and Global.confirm[PLAYER_1]+Global.confirm[PLAYER_2] >= GAMESTATE:GetNumSidesJoined()) then
		return true;
	else
		return false;
	end;
end;


--//================================================================

function GetMachineAndPlayerProfile(int, pn)
	if int == 1 then
		return PROFILEMAN:GetMachineProfile()
	else
		return PROFILEMAN:GetProfile(pn)
	end;
end;

--//================================================================

function GetTopScoreForProfile(song,steps,profile)

	local _list = {};
	local _scores = {};
	local _best = nil;

	if steps then 
		_list = profile:GetHighScoreListIfExists(song, steps)

		if _list then 
			_scores = _list:GetHighScores();

			if _scores and #_scores>0 then 
				table.sort(_scores,function(a,b) return SortScoresByDP(a,b) end)
				_best = _scores[1];
				return _best;
			else
				--no scores on the scores list
				return nil
			end
		else
			--no scores list available
			return nil		
		end;
	else
		--invalid steps
		return nil
	end;

end;

--//================================================================

function GetLatestScore(song,steps,profile)

	local machine = PROFILEMAN:GetMachineProfile();

	local machine_list = {}
	local machine_scores = {};

	local profile_list = {};
	local profile_scores = {};

	local final_scores = {};
	local final_latest = nil;


	if steps then 
		machine_list = machine:GetHighScoreListIfExists(song, steps)
		profile_list = profile:GetHighScoreListIfExists(song, steps)

		--ADDING MACHINE SCORES TO FINAL LIST
		if machine_list then 
			machine_scores = machine_list:GetHighScores();

			if machine_scores and #machine_scores>0 then 
				for a=1,#machine_scores do
					table.insert(final_scores, machine_scores[a]);
				end;
			else
				--no scores in the scores list, skipping
			end
		else
			--no scores list available, skipping.
		end;

		--ADDING PROFILE SCORES TO FINAL LIST
		if profile_list then 
			profile_scores = profile_list:GetHighScores();

			if profile_scores and #profile_scores>0 then 
				for b=1,#profile_scores do
					table.insert(final_scores, profile_scores[b]);
				end;
			else
				--no scores in the scores list, skipping
			end
		else
			--no scores list available, skipping.
		end;

		--FINAL LIST DONE, HOW DO IT SORT???? LOL
		if final_scores and #final_scores>0 then
			table.sort(final_scores,function(a,b) return SortScoresByDate(a,b) end) --jk
			return final_scores[1]; --the champion
		else
			--no scores found at all, exiting
			return nil
		end;

	else
		--invalid steps
		return nil
	end;

end;


--//================================================================

function SortScoresByDP(a,b)
	return a:GetPercentDP() > b:GetPercentDP()
end;

--//================================================================

function SortScoresByDate(a,b)
	return tonumber(RawDate(a:GetDate())) > tonumber(RawDate(b:GetDate()))
end;

--//================================================================

local t = Def.ActorFrame{
	MainMenuMessageCommand=cmd(playcommand,"StateChangedMessage");
	MusicWheelMessageCommand=function(self) MESSAGEMAN:Broadcast("GetScores"); end;
	StepsChangedMessageCommand=function(self) MESSAGEMAN:Broadcast("GetScores"); end;
	StateChangedMessageCommand=function(self)
		if HighScoreBlockedState() then
			Global.toggle = false;
			MESSAGEMAN:Broadcast("ToggleSelect", { Toggled = false });
		end;
	end;
};

t[#t+1] = LoadActor(THEME:GetPathG("","bg"))..{
	InitCommand=cmd(diffuse,BoostColor(Global.bgcolor,0.75);diffusealpha,0;FullScreen;fadebottom,0.33333);
	ToggleSelectMessageCommand=function(self)
		self:stoptweening();
		self:decelerate(0.2);
		if Global.toggle then
			self:diffusealpha(0.5);
		else
			self:diffusealpha(0);
		end;
	end;
};

for pn in ivalues(GAMESTATE:GetHumanPlayers()) do 


	t[#t+1] = LoadActor(THEME:GetPathG("","dim"))..{
		Name = "DIM";
		InitCommand=cmd(zoomto,854,SCREEN_HEIGHT;x,SCREEN_CENTER_X+(240*pnSide(pn));y,SCREEN_CENTER_Y-(SCREEN_HEIGHT/8);diffuse,BoostColor(Global.bgcolor,0.666666);diffusealpha,0);
		ToggleSelectMessageCommand=function(self)
			self:stoptweening();
			if pn == PLAYER_1 then
				self:faderight(0.5);
			else
				self:fadeleft(0.5);
			end;

			self:decelerate(0.2);

			if Global.toggle then
				self:diffusealpha(0.875);
			else
				self:diffusealpha(0);
			end;
		end;
	};

	for i=1,3 do

		t[#t+1] = Def.ActorFrame{
			Name = "Highscores List "..pn;
			InitCommand=cmd(x,SCREEN_CENTER_X+((gap*4)*pnSide(pn));y,SCREEN_CENTER_Y-164+(self:GetY()+((i-1)*spacing));diffusealpha,0;draworder,200);
			GetScoresMessageCommand=function(self)
				if Global.toggle then

					local st = Global.steps[Global.pnsteps[pn]];
					local top = nil;
					local last = nil;

					top = GetTopScoreForProfile(Global.song,st,GetMachineAndPlayerProfile(i,pn));
					last = GetLatestScore(Global.song,st,PROFILEMAN:GetProfile(pn));

					if i==3 then
						scores[pn][3] = last;
					else
						scores[pn][i] = top;
					end;

					MESSAGEMAN:Broadcast("UpdateScores");
				end;
			end;
			ToggleSelectMessageCommand=function(self)
				self:stoptweening();
				if Global.toggle and GAMESTATE:IsSideJoined(pn) then
					MESSAGEMAN:Broadcast("GetScores");
					self:decelerate(0.45-((i)/20));
					self:x(SCREEN_CENTER_X+(gap*pnSide(pn))+(i*skewing*pnSide(pn)));
					self:diffusealpha(1);
				else
					self:decelerate(0.15);
					self:x(SCREEN_CENTER_X+((gap*4)*pnSide(pn)));
					self:diffusealpha(0);
				end;
			end;

			Def.Quad{
				Name = "BOX";
				InitCommand=cmd(zoomto,(854/3),spacing-2;horizalign,pnAlign(OtherPlayer[pn]);vertalign,top;y,-10;x,-8*pnSide(pn);playcommand,"UpdateScores");
				UpdateScoresMessageCommand=function(self)
					if pn == PLAYER_1 then
						self:fadeleft(0.8);
					else
						self:faderight(0.8);
					end;

					if scores[pn][i] then
						self:diffuse(0.2,0.2,0.2,0.333333);
						self:diffusebottomedge(BoostColor(PlayerColor(pn,0.5),0.25));
					else
						self:diffuse(0.2,0.2,0.2,0.333333);
						self:diffusebottomedge(0,0,0,0.3);
					end;
				end;
			},

			Def.BitmapText{
				Font = Fonts.highscores["Main"];
				Name = "TITLE";
				InitCommand=cmd(horizalign,pnAlign(OtherPlayer[pn]);strokecolor,0.2,0.2,0.2,0.8;zoomx,0.4;zoomy,0.39;maxwidth,240/self:GetZoomX());
				OnCommand=function(self)
					if i==1 then
						self:settext("Machine Best");
					elseif i==2 then
						local name = PROFILEMAN:GetProfile(pn):GetDisplayName();
						if name == "" then
							self:settext("Profile Best");
						else
							self:settext(name.."\'s Best");
						end;
					elseif i==3 then
						self:settext("Last Score Run");
					else
						self:settext("Invalid case");
					end;
				end;
			},

			Def.BitmapText{
				Font = Fonts.highscores["Grade"];
				Name = "GRADE";
				InitCommand=cmd(strokecolor,0.2,0.2,0.2,0.8;zoomy,0.45;zoomx,0.55;y,36;x,160*pnSide(pn);skewx,-0.15);
				UpdateScoresMessageCommand=function(self)
					if scores[pn][i] then 
						self:settext(FormatGrade(scores[pn][i]:GetGrade()));
						self:diffuse(PlayerColor(pn));
						self:strokecolor(BoostColor(PlayerColor(pn),0.25)); 
					else 
						self:settext("")
						self:diffuse(0.666666,0.666666,0.666666,0.75); 
						self:strokecolor(0.2,0.2,0.2,0.9);
					end;
				end;
			},

			Def.BitmapText{
				Font = Fonts.highscores["Main"];
				Name = "AWARD";
				InitCommand=cmd(strokecolor,0.2,0.2,0.2,0.8;zoom,0.4;y,14;x,160*pnSide(pn));
				UpdateScoresMessageCommand=function(self)
					if scores[pn][i] then 
						self:settext(FormatAward(scores[pn][i]:GetStageAward()));
						self:diffuseshift();
						self:effectcolor1(PlayerColor(pn));
						self:effectcolor2(1,1,1,1);
						self:effectperiod(0.5);
						self:strokecolor(BoostColor(PlayerColor(pn),0.25)); 
					else 
						self:settext("");
						self:stopeffect();
						self:diffuse(0.666666,0.666666,0.666666,0.75); 
						self:strokecolor(0.2,0.2,0.2,0.9);
					end;
				end;
			},

			Def.BitmapText{
				Font = Fonts.highscores["Main"];
				Name = "PERCENTAGE";
				InitCommand=cmd(horizalign,pnAlign(OtherPlayer[pn]);zoom,0.5;y,14);
				UpdateScoresMessageCommand=function(self)
					if scores[pn][i] then 
						self:settext(FormatDP(scores[pn][i]:GetPercentDP()));
						self:diffuse(PlayerColor(pn));
						self:strokecolor(BoostColor(PlayerColor(pn),0.25)); 
					else 
						self:settext("00.00%")
						self:diffuse(0.666666,0.666666,0.666666,0.75); 
						self:strokecolor(0.2,0.2,0.2,0.9);
					end;
				end;
			},

			Def.BitmapText{
				Font = Fonts.highscores["Main"];
				Name = "MAX COMBO";
				InitCommand=cmd(horizalign,pnAlign(OtherPlayer[pn]);strokecolor,0.2,0.2,0.2,0.8;zoom,0.38;y,29);
				UpdateScoresMessageCommand=function(self)
					if scores[pn][i] then
						self:settext("Max Combo: "..scores[pn][i]:GetMaxCombo());
						self:diffuse(BoostColor(PlayerColor(pn),1.25));
						self:strokecolor(BoostColor(PlayerColor(pn),0.25)); 
					else 
						self:settext("")
						self:diffuse(0.5,0.5,0.5,0.75); 
						self:strokecolor(0.2,0.2,0.2,0.9);
					end;
				end;
			},	

			Def.BitmapText{
				Font = Fonts.highscores["Main"];
				Name = "DATE";
				InitCommand=cmd(horizalign,pnAlign(OtherPlayer[pn]);strokecolor,0.2,0.2,0.2,0.8;zoom,0.38;y,43);
				UpdateScoresMessageCommand=function(self)
					if scores[pn][i] then
						self:settext(FormatDate(scores[pn][i]:GetDate()));
						self:diffuse(BoostColor(PlayerColor(pn),1.75));
						self:strokecolor(BoostColor(PlayerColor(pn),0.25)); 
					else 
						self:settext("")
						self:diffuse(0,0,0,0); 
						self:strokecolor(0.2,0.2,0.2,0.9);
					end;
				end;
			},			

		};

	end;

end;


return t;