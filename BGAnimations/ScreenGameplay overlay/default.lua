local paused = false;
local missfail = THEMECONFIG:get_data("ProfileSlot_Invalid").FailMissCombo;

local function Update(self,dt)
    MESSAGEMAN:Broadcast("Update");
end;

local t = Def.ActorFrame{
	InitCommand=cmd(SetUpdateFunction,Update);
	OnCommand=function() Global.disqualified = false; end;
	PausedMessageCommand=function() Global.disqualified = true; paused = true; end;
	UnpausedMessageCommand=function() paused = false; end;
	LifeChangedMessageCommand=function(self,param) end;
	ComboChangedMessageCommand=function(self,param) 
		if not missfail or FailCombo() < 1 then return end;

        local curstats = STATSMAN:GetCurStageStats();
        local pss = curstats:GetPlayerStageStats(param.Player);
        local misscombo = pss:GetCurrentMissCombo();

        if SideJoined(OtherPlayer[param.Player]) then
        	local otherpn = OtherPlayer[param.Player];
        	local otherstats = curstats:GetPlayerStageStats(otherpn);
        	local othermiss = otherstats:GetCurrentMissCombo();
        	misscombo = math.min(misscombo,othermiss);
        end;

        if misscombo >= FailCombo() then
        	for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
        		STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):FailPlayer();
        	end;
        	SCREENMAN:SetNewScreen("ScreenEvaluationCustom");
        end;

	end;
}

t[#t+1] = LoadActor("assets/decorations");

for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
	if SideJoined(pn) then

		t[#t+1] = LoadActor("assets/lifebar")..{
			OnCommand=cmd(playcommand, "Build", { Player = pn });
		}

	end;
end;

t[#t+1] = LoadActor("assets/progress");

t[#t+1] = Def.BitmapText{
	Font = Fonts.gameplay["Main"];
	Text = "Stage "..CapDigits(GAMESTATE:GetCurrentStageIndex()+1,0,2);
	InitCommand=cmd(zoom,0.45;strokecolor,0.15,0.15,0.15,0.8;CenterX;y,SCREEN_BOTTOM-12;vertalign,bottom);
};

t[#t+1] = LoadActor("assets/offset");
t[#t+1] = LoadActor("assets/pause");
t[#t+1] = LoadActor("assets/newfield");

return t;