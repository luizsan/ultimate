local t = Def.ActorFrame{}
local scale = PREFSMAN:GetPreference("TimingWindowScale") or 1.0;
local add = PREFSMAN:GetPreference("TimingWindowAdd") or 0.0;
local timings = {
    { Value = (PREFSMAN:GetPreference("TimingWindowSecondsW1") * scale) + add, Key = "Flawless" },
    { Value = (PREFSMAN:GetPreference("TimingWindowSecondsW2") * scale) + add, Key = "Perfect" },
    { Value = (PREFSMAN:GetPreference("TimingWindowSecondsW3") * scale) + add, Key = "Great" },
    { Value = (PREFSMAN:GetPreference("TimingWindowSecondsW4") * scale) + add, Key = "Good" },
    { Value = (PREFSMAN:GetPreference("TimingWindowSecondsW5") * scale) + add, Key = "Bad" },
}

local maxtiming = math.max(timings[1].Value,timings[2].Value,timings[3].Value,timings[4].Value,timings[5].Value);
local meterwidth = 160;
local meterheight = 14;

local function TickColor(timing)
    for i=1,#timings do
        if timing <= timings[i].Value then 
            return JudgmentColor(timings[i].Key)
        end;
    end;
    return {1,0,0,1}
end;

for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
    if SideJoined(pn) and PLAYERCONFIG:get_data(pn).ShowOffsetMeter then

        local o = Def.ActorFrame{
            OnCommand=function(self)
                local gameplay = SCREENMAN:GetTopScreen();
                local player = gameplay:GetChild("Player"..ToEnumShortString(pn))
                local yoffset = NOTESCONFIG:get_data(pn).reverse * (_screen.h * 0.25);
                local w1 = PLAYERCONFIG:get_data(pn).AllowW1 or false;
                self:x(player:GetX());
                self:y(player:GetY() + yoffset);
            end;
        }

        -- bg
        o[#o+1] = LoadActor(THEME:GetPathG("","glow"))..{
            InitCommand=cmd(zoomto,meterwidth+48,meterheight+8;diffuse,0,0,0,0.6);
        };

        o[#o+1] = Def.Quad{
            InitCommand=cmd(zoomto,meterwidth,meterheight;diffuse,0.1,0.1,0.1,0.9);
        };

        for i=#timings,1,-1 do 

            local k = timings[i].Key;
            local v = timings[i].Value;
            local c = JudgmentColor(k);

            o[#o+1] = Def.Quad{
                InitCommand=cmd(zoomto,(v/maxtiming) * (meterwidth-4),meterheight-4;diffuse,c;diffusealpha,0.1);
                OnCommand=function(self)
                    if k == "Flawless" then
                        self:visible(THEMECONFIG:get_data().AllowW1);
                    end;
                end;
            };  

        end;

        o[#o+1] = Def.ActorFrame{
            InitCommand=cmd(diffusealpha,0);
            JudgmentMessageCommand=function(self,param)
                if param.Player == pn then
                    if param.HoldNoteScore then return end;

                    if param.TapNoteScore == "TapNoteScore_Miss" or
                       param.TapNoteScore == "TapNoteScore_CheckpointMiss" then
                    return
                    end;

                    local tap = param.TapNoteOffset
                    local offset = clamp(tap,-maxtiming,maxtiming);
                    local xpos = (offset/maxtiming) * (meterwidth-4) * 0.5;

                    self:stoptweening();
                    self:playcommand("Pulse", { Color = TickColor(math.abs(offset)) });
                    self:diffusealpha(1);
                    self:decelerate(0.075);
                    self:x(xpos);
                    self:sleep(0.01);
                    self:linear(math.abs(xpos)/20);
                    self:x(0);
                end;
            end;

            Def.Quad{
                InitCommand=cmd(zoomto,7,4;y,meterheight/2;diffuse,0.1,0.1,0.1,0.9);
            },
            Def.Quad{
                InitCommand=cmd(zoomto,7,4;y,-meterheight/2;diffuse,0.1,0.1,0.1,0.9);
            },

            Def.Quad{
                InitCommand=cmd(zoomto,3,meterheight);
            },

        };

        t[#t+1] = o;

    end;
end;


return t;