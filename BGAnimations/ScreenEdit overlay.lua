local function Update(self,dt)
	MESSAGEMAN:Broadcast("Update");
end;

local t = Def.ActorFrame {
	InitCommand=function(self) 
		self:SetUpdateFunction(Update); 
		self:SetUpdateRate(1) 
	end;
};

local notecount = 0;
local hits = 0;
local misses = 0;
local all_dp = 0;
local cur_dp = 0;

local song = GAMESTATE:GetCurrentSong();
local oldbeat = 0;

local TNS_weights = {
	["TapNoteScore_CheckpointMiss"] = THEME:GetMetric("ScoreKeeperNormal", "PercentScoreWeightCheckpointMiss"),
	["TapNoteScore_CheckpointHit"] = THEME:GetMetric("ScoreKeeperNormal", "PercentScoreWeightCheckpointHit"),
	["TapNoteScore_W1"] = THEME:GetMetric("ScoreKeeperNormal", "PercentScoreWeightW1"),
	["TapNoteScore_W2"] = THEME:GetMetric("ScoreKeeperNormal", "PercentScoreWeightW2"),
	["TapNoteScore_W3"] = THEME:GetMetric("ScoreKeeperNormal", "PercentScoreWeightW3"),
	["TapNoteScore_W4"] = THEME:GetMetric("ScoreKeeperNormal", "PercentScoreWeightW4"),
	["TapNoteScore_W5"] = THEME:GetMetric("ScoreKeeperNormal", "PercentScoreWeightW5"),
	["TapNoteScore_Miss"] = THEME:GetMetric("ScoreKeeperNormal", "PercentScoreWeightMiss"),
	["TapNoteScore_HitMine"] = THEME:GetMetric("ScoreKeeperNormal", "PercentScoreWeightHitMine"),
	["TapNoteScore_None"] = 0,
};

local HNS_weights = {
	["HoldNoteScore_None"] = 0,
	["HoldNoteScore_Held"] = THEME:GetMetric("ScoreKeeperNormal", "PercentScoreWeightHeld"),
	["HoldNoteScore_MissedHold"] = THEME:GetMetric("ScoreKeeperNormal", "PercentScoreWeightMissedHold"),
	["HoldNoteScore_LetGo"] = THEME:GetMetric("ScoreKeeperNormal", "PercentScoreWeightLetGo"),
};

local function TNSToCombo(tns)
	local multiplier = { 1, 1 };
	local curbeat = GAMESTATE:GetSongBeat();
	local master = GAMESTATE:GetMasterPlayerNumber();
	local timing = GAMESTATE:GetCurrentSteps(master):GetTimingData(true);
	local combos = timing:GetCombos(true);

	if timing and combos and #combos > 1 then
		for i=1,#combos do
			local beat = combos[i][1];
			local limit = math.huge;

			if i+1 <= #combos then 
				limit = combos[i+1][1]; 
			end;

			if(curbeat >= beat and curbeat < limit) then
				multiplier = { combos[i][2], combos[i][3] };
			end;
		end;
	end;

	if tns == "TapNoteScore_Miss" or tns == "TapNoteScore_CheckpointMiss" then
		misses = misses + multiplier[2];
		hits = 0;
	elseif tns == "TapNoteScore_W5" then
		misses = 0;
		hits = 0;
	elseif tns == ComboMaintain() then
		hits = 0;
	elseif tns == ComboContinue() then
		hits = hits + multiplier[1];
		misses = 0;
	else
		hits = hits + multiplier[1];
		misses = 0;
	end;
end;

local function ValueOrNil(val)
	if val < 1 then return nil; end;
	return val;
end;

local function ResetTrackers()
	notecount = 0;
	hits = 0;
	misses = 0;
	all_dp = 0;
	cur_dp = 0;
	oldbeat = GAMESTATE:GetSongBeat();
end;

t[#t+1] = Def.BitmapText{
	Font = Fonts.editor["Main"];
	InitCommand=cmd(diffuse,1,1,1,1;strokecolor,0.1,0.1,0.1,1;zoom,0.75;x,SCREEN_LEFT+8;y,SCREEN_TOP+8;horizalign,left;vertalign,top;zoom,0.575);
	UpdateMessageCommand=function(self)
		if SCREENMAN:GetTopScreen():GetScreenType() == "ScreenType_Gameplay" then
			self:visible(true);
			if GAMESTATE:GetSongBeat() < oldbeat then
				ResetTrackers();
			end;
		else
			ResetTrackers();
			self:visible(false);
		end;

		self:settext("Note count: "..notecount);
		
	end;

	JudgmentMessageCommand=function(self, param)
		if param.TapNoteScore and param.TapNoteScore ~= "TapNoteScore_None" then 
			notecount = notecount + 1; 

			local maximum_value;
			if(PREFSMAN:GetPreference("AllowW1") == "AllowW1_Never") then
				maximum_value = TNS_weights["TapNoteScore_W2"];
			else
				maximum_value = TNS_weights["TapNoteScore_W1"];
			end;

			all_dp = all_dp + maximum_value;
			cur_dp = cur_dp + TNS_weights[param.TapNoteScore];

			TNSToCombo(param.TapNoteScore);
		end

		if param.HoldNoteScore and param.HoldNoteScore ~= "HoldNoteScore_None" then 
			notecount = notecount - 1; 
			all_dp = all_dp + HNS_weights["HoldNoteScore_Held"];
			cur_dp = cur_dp + HNS_weights[param.HoldNoteScore];
		end;	

		self:settext("Note count: "..notecount);

		local comboparams = { 
			Combo = ValueOrNil(hits),
			Misses = ValueOrNil(misses),
			Player = GAMESTATE:GetMasterPlayerNumber(), 
			currentDP = cur_dp, 
			possibleDP = all_dp 
		};

		local comboActor = SCREENMAN:GetTopScreen():GetChild("Player"):GetChild("Combo");
		comboActor:playcommand("Judgment", param);
		comboActor:playcommand("Combo", comboparams );
	end;
};


return t;
