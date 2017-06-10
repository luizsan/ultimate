local player = Var "Player";
local pulse = cmd(stoptweening;zoomx,1.3;zoomy,1.5;decelerate,0.075;zoom,1;sleep,0.725;linear,0.12;zoom,0.5;sleep,0.5;linear,0.15;zoom,0.25);
local fadeout = cmd(stoptweening;diffusealpha,1;sleep,0.8;linear,0.15;diffusealpha,0);

local TNSFrames = {
	TapNoteScore_W1 = 0;
	TapNoteScore_W2 = 1;
	TapNoteScore_W3 = 2;
	TapNoteScore_W4 = 3;
	TapNoteScore_W5 = 4;
	TapNoteScore_Miss = 5;
	TapNoteScore_CheckpointHit = 0;
	TapNoteScore_CheckpointMiss = 5;
}

if PREFSMAN:GetPreference("AllowW1") == "AllowW1_Never" then
	TNSFrames.TapNoteScore_CheckpointHit = 1;
end;

local t = Def.ActorFrame{
	InitCommand=function(self) 
		self:draworder(501); 
		Global.piuscoring[player] = 0;
	end;

	JudgmentMessageCommand=function(self,param) 

		if param.TapNoteScore == "TapNoteScore_HitMine" or param.TapNoteScore == "TapNoteScore_AvoidMine" then return end;
		if param.Player == player and param.TapNoteScore then pulse(self); end;

		if IsGame("pump") and player == param.Player then
			local beat = GAMESTATE:GetSongBeat();
			local value = PIUScoring(player, param, beat);
			Global.piuscoring[player] = Global.piuscoring[player] + value;
			Global.piuscoring[player] = clamp(Global.piuscoring[player],0,math.huge);
		end;

	end;

	LoadActor("Judgment")..{
		OnCommand=cmd(vertalign,bottom;zoom,0.445;animate,false;y,15;diffusealpha,0);
		JudgmentMessageCommand=function(self,param)
		
			if param.TapNoteScore == "TapNoteScore_HitMine" or param.TapNoteScore == "TapNoteScore_AvoidMine" then return end;
			if param.Player == player and param.TapNoteScore and string.find(string.lower(param.TapNoteScore),"mine") == nil then 
				self:stoptweening();
				if TNSFrames[param.TapNoteScore] then self:setstate(TNSFrames[param.TapNoteScore]); end;
				fadeout(self);
			else
				return 
			end;
		end;
	}
};


return t