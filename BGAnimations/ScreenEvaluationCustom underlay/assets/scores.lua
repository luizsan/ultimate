local stagestats;
local stageindex;

local pss = {
    [PLAYER_1] = nil,
    [PLAYER_2] = nil,
}

local stats = {
    [PLAYER_1] = nil,
    [PLAYER_2] = nil,
}

local originX = SCREEN_CENTER_X;
local originY = SCREEN_TOP + 64;

local tablestats = {};
local labelstats = {};


function FetchStatsForPlayer(pn)
    local curstats = STATSMAN:GetCurStageStats();
    local playerstats = curstats:GetPlayerStageStats(pn);
    local dp = playerstats:GetActualDancePoints()/playerstats:GetCurrentPossibleDancePoints();
    local stats = {
        ["Percent"]  = string.format("%.2f",dp*100), 
        ["Score"]    = playerstats:GetScore(), 
        ["Combo"]    = playerstats:MaxCombo(), 
        ["W1"]       = playerstats:GetTapNoteScores('TapNoteScore_W1'),
        ["W2"]       = playerstats:GetTapNoteScores('TapNoteScore_W2'), 
        ["W3"]       = playerstats:GetTapNoteScores('TapNoteScore_W3'), 
        ["W4"]       = playerstats:GetTapNoteScores('TapNoteScore_W4'), 
        ["W5"]       = playerstats:GetTapNoteScores('TapNoteScore_W5'),
        ["Miss"]     = playerstats:GetTapNoteScores('TapNoteScore_Miss'), 
        ["Hold"]     = playerstats:GetTapNoteScores('TapNoteScore_CheckpointHit'),
        ["HoldMiss"] = playerstats:GetTapNoteScores('TapNoteScore_CheckpointMiss'), 
        ["Mines"]    = playerstats:GetTapNoteScores('TapNoteScore_HitMine'), 
        ["Avoided"]  = playerstats:GetTapNoteScores('TapNoteScore_AvoidMine'), 
        ["LetGo"]    = playerstats:GetHoldNoteScores('HoldNoteScore_LetGo'), 
        ["Held"]     = playerstats:GetHoldNoteScores('HoldNoteScore_Held'),
        ["MissHold"] = playerstats:GetHoldNoteScores('HoldNoteScore_MissedHold'),
    };

    if(PREFSMAN:GetPreference("AllowW1") == "AllowW1_Never") then
        stats["W2"] = stats["W2"] + stats["Hold"];
    else
        stats["W1"] = stats["W1"] + stats["Hold"];
    end;

    stats["Miss"] = stats["Miss"] + stats["HoldMiss"];
    stats["Miss"] = stats["Miss"] + stats["MissHold"];

    return stats;
end;

local dance_grade = {
    { Label = "Superb",     Key = "W1",      Color = color("#ffc4dd"),      Enabled = true },
    { Label = "Perfect",    Key = "W2",      Color = color("#6ccfff"),      Enabled = true },
    { Label = "Great",      Key = "W3",      Color = color("#a9ff63"),      Enabled = true },
    { Label = "Good",       Key = "W4",      Color = color("#ffd075"),      Enabled = true },
    { Label = "Bad",        Key = "W5",      Color = color("#ae84cf"),      Enabled = true },
    { Label = "Miss",       Key = "Miss",    Color = color("#ff5252"),      Enabled = true },
    { Label = "OK",         Key = "Held",    Color = color("#aaaaaa"),      Enabled = true },
    { Label = "NG",         Key = "LetGo",   Color = color("#aaaaaa"),      Enabled = true },
    { Label = "Max Combo",  Key = "Combo",   Color = color("#ffffff"),      Enabled = true },
}

if(PREFSMAN:GetPreference("AllowW1") == "AllowW1_Never") then
    dance_grade[1].Enabled = false;
end;

if not ShowHoldJudgments() then
    dance_grade[7].Enabled = false;
    dance_grade[8].Enabled = false;
end;

local labelspacing = 20;
local numberspacing = 80;


local t = Def.ActorFrame{
    InitCommand=function()
        stagestats = STATSMAN:GetCurStageStats()
        stageindex = stagestats:GetStageIndex();
        for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
            if(GAMESTATE:IsSideJoined(pn)) then
                pss[pn] = stagestats:GetPlayerStageStats(pn);
                stats[pn] = FetchStatsForPlayer(pn);
            end
        end
    end
};

local labels = Def.ActorFrame{
    InitCommand=cmd(y,SCREEN_CENTER_Y - 108);
}

local numbers = Def.ActorFrame{
    InitCommand=cmd(y,SCREEN_CENTER_Y - 108);
}

for n=1,#dance_grade do

    labels[#labels+1] = Def.ActorFrame{
    InitCommand=cmd(x,SCREEN_CENTER_X;y,labelspacing * (n-1);zoom,0.475);
    OnCommand=cmd(diffusealpha,0;sleep,n/10;linear,0.3;diffusealpha,1);

        Def.Quad{
            InitCommand=cmd(zoomto,360,36;diffuse,BoostColor(dance_grade[n].Color,0.25);diffusealpha,0.75;fadeleft,0.5;faderight,0.5);
        },

        Def.BitmapText{
            Font = "regen small";
            OnCommand=function(self)
                self:settext(string.upper(dance_grade[n].Label));
                self:diffuse(BoostColor(dance_grade[n].Color, 0.8));
                self:diffusetopedge(BoostColor(dance_grade[n].Color, 1.5));
                self:strokecolor(BoostColor(dance_grade[n].Color, 0.2));
                self:shadowlengthy(1.5);
            end;
        },
    }

end;


for pn in ivalues(GAMESTATE:GetHumanPlayers()) do

    for n=1,#dance_grade do
        numbers[#numbers+1] = Def.ActorFrame{
        InitCommand=cmd(x,SCREEN_CENTER_X;y,labelspacing * (n-1));
        OnCommand=cmd(diffusealpha,0;sleep,n/10;linear,0.3;diffusealpha,1);

            Def.RollingNumbers{
                Font = "regen strong";
                InitCommand=cmd(zoom,0.475;x,numberspacing*pnSide(pn);horizalign,pnAlign(OtherPlayer[pn]);strokecolor,0.175,0.175,0.175,0.5);
                OnCommand=function(self)
                    self:set_chars_wide(4);
                    self:set_leading_attribute{Diffuse= color("#777777FF")};
                    self:set_number_attribute{Diffuse= color("#FFFFFFFF")};
                    self:set_approach_seconds(1.75);

                    if dance_grade[n].Enabled then
                        self:target_number(stats[pn][dance_grade[n].Key]);
                    else
                        self:set_number_attribute{Diffuse= color("#777777FF")};
                        self:target_number(0);
                    end;
                end;
            }
        }

    end;

    -- grading
    t[#t+1] = Def.ActorFrame{
        InitCommand=cmd(y,originY+80;x,originX + (210*pnSide(pn)));

        Def.BitmapText{
            Name = "GRADE";
            Font = "bebas neue";
            InitCommand=cmd(strokecolor,0.2,0.2,0.2,0.8;zoomy,0.55;zoomx,0.65;skewx,-0.15);
            OnCommand=function(self)
                if pss[pn] then 
                    self:settext(FormatGrade(pss[pn]:GetGrade()));
                    self:diffuse(PlayerColor(pn));
                    self:strokecolor(BoostColor(PlayerColor(pn),0.25)); 
                end;
            end;
        },
        Def.BitmapText{
            Name = "AWARD";
            Font = "neotech";
            InitCommand=cmd(strokecolor,0.2,0.2,0.2,0.8;zoom,0.4;y,24);
            OnCommand=function(self)
                if pss[pn] then 
                    self:settext(FormatAward(pss[pn]:GetStageAward()));
                    self:diffuseshift();
                    self:effectcolor1(PlayerColor(pn));
                    self:effectcolor2(1,1,1,1);
                    self:effectperiod(0.5);
                    self:strokecolor(BoostColor(PlayerColor(pn),0.25)); 
                end;
            end;
        },
    }

    -- accuracy
    t[#t+1] = Def.ActorFrame{
        InitCommand=cmd(y,originY+128;x,originX + (210*pnSide(pn)));

        Def.BitmapText{
            Name = "PERCENT LABEL";
            Font = "neotech";
            InitCommand=cmd(strokecolor,0.2,0.2,0.2,0.8;zoom,0.4;y,16;shadowlength,1;settext,"Accuracy");
        },

        Def.BitmapText{
            Name = "PERCENT";
            Font = "neotech";
            InitCommand=cmd(strokecolor,0.2,0.2,0.2,0.8;zoom,0.6;shadowlength,1);
            OnCommand=function(self)
                if pss[pn] then 
                    self:settext(stats[pn]["Percent"].."%");
                    self:diffuse(PlayerColor(pn));
                    self:strokecolor(BoostColor(PlayerColor(pn),0.25));
                    self:shadowlength(1); 
                end;
            end;
        }
    }


    -- score
    t[#t+1] = Def.ActorFrame{
        InitCommand=cmd(y,originY+170;x,originX + (210*pnSide(pn)));

        Def.BitmapText{
            Name = "SCORE LABEL";
            Font = "neotech";
            InitCommand=cmd(strokecolor,0.2,0.2,0.2,0.8;zoom,0.4;y,16;shadowlength,1;settext,"Score");
        },

        Def.BitmapText{
            Name = "SCORE";
            Font = "neotech";
            InitCommand=cmd(strokecolor,0.2,0.2,0.2,0.8;zoom,0.475;shadowlength,1);
            OnCommand=function(self)
                if pss[pn] then 
                    self:settext(commify(stats[pn]["Score"], "."));
                    self:diffuse(PlayerColor(pn));
                    self:strokecolor(BoostColor(PlayerColor(pn),0.25));
                    self:shadowlength(1); 
                end;
            end;
        }
    }


end;

t[#t+1] = labels;
t[#t+1] = numbers;










--[[

    -- scores
    t[#t+1] = Def.ActorFrame{
        InitCommand=cmd(y,SCREEN_CENTER_Y+9999;x,SCREEN_CENTER_X + (290*pnSide(pn)));

        -- working area
        Def.Quad{
            --InitCommand=cmd(zoomto,160,180;diffuse,1,0,0,0.3;horizalign,pnAlign(pn))
        },

        -- meter & st
        Def.ActorFrame{
            InitCommand=cmd(y,-90);

            LoadActor(THEME:GetPathG("","separator"))..{
                InitCommand=cmd(x,6 * pnSide(pn);y,10;zoom,0.6;diffuse,0.2,0.2,0.2,1;shadowlengthy,-1;shadowcolor,1,1,1,0.2);
            },

            Def.BitmapText{
                Font = "regen silver";
                InitCommand=cmd(diffuse,PlayerColor(pn);zoom,0.35;shadowlengthy,2;strokecolor,BoostColor(PlayerColor(pn),0.25);horizalign,pnAlign(pn);x,8 * -pnSide(pn));
                OnCommand=function(self)
                    local steptype = string.upper(PureType(GAMESTATE:GetCurrentSteps(GAMESTATE:GetMasterPlayerNumber())));
                    local stepmeter = GAMESTATE:GetCurrentSteps(GAMESTATE:GetMasterPlayerNumber()):GetMeter();
                    self:settext(steptype.." "..stepmeter);
                end;
            },

            Def.BitmapText{
                Font = "neotech";
                InitCommand=cmd(horizalign,left;zoom,0.4;y,16;strokecolor,0.2,0.2,0.2,1;diffuse,PlayerColor(pn);strokecolor,BoostColor(PlayerColor(pn),0.25);horizalign,pnAlign(pn);x,8 * -pnSide(pn));
                OnCommand=function(self)
                    local maker = Global.pncursteps[pn]:GetAuthorCredit();
                    maker = FilterStepmaker(maker);
                    if tostring(maker)=="" then
                        self:settext("");
                        self:diffuse(0.7,0.7,0.7,0.8);
                    else
                        self:settext("Steps by "..maker);
                        self:diffuse(1,1,1,1);
                    end 
                end;
            },
        },

        --labels
        Def.BitmapText{
            Font = "regen silver";
            InitCommand=cmd(zoom,0.5;horizalign,pnAlign(pn);strokecolor,BoostColor(PlayerColor(pn),0.15));
            OnCommand=function(self)
                --BuildStatTable();
                --self:settext(string.upper(table.concat(labelstats,"\n")));
            end;
        },

        --numbers
        Def.BitmapText{
            Font = "regen small";
            InitCommand=cmd(zoom,0.5;x,160 * -pnSide(pn);horizalign,pnAlign(OtherPlayer[pn]);strokecolor,BoostColor(PlayerColor(pn),0.15));
            OnCommand=function(self)
                --BuildStatTable();
                --self:settext(string.upper(table.concat(tablestats,"\n")));
            end;
        }

    }

]]



return t;