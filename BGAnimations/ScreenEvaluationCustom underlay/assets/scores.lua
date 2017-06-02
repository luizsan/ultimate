local stagestats;
local stageindex;

local pss = {
    [PLAYER_1] = nil,
    [PLAYER_2] = nil,
}

local scores = {
    [PLAYER_1] = nil,
    [PLAYER_2] = nil,
}

local originX = SCREEN_CENTER_X;
local originY = SCREEN_TOP + 64;

local tablestats = {};
local labelstats = {};


local t = Def.ActorFrame{
    InitCommand=function()
        stagestats = STATSMAN:GetCurStageStats()
        stageindex = stagestats:GetStageIndex();
        for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
            if(GAMESTATE:IsSideJoined(pn)) then
                pss[pn] = stagestats:GetPlayerStageStats(pn);
                scores[pn] = FetchStatsForPlayer(pn);
            end
        end
    end
};


function FetchStatsForPlayer(pn)
    local curstats = STATSMAN:GetCurStageStats();
    local playerstats = curstats:GetPlayerStageStats(pn);
    local dp = playerstats:GetActualDancePoints()/playerstats:GetCurrentPossibleDancePoints();
    local stats = {
        { Label = "Percentage",     Enabled = false,    Value = string.format("%.2f",dp*100)                                        }, 
        { Label = "Combo",          Enabled = false,    Value = playerstats:MaxCombo()                                              }, 
        { Label = "Marvelous",      Enabled = false,    Value = playerstats:GetTapNoteScores('TapNoteScore_W1')                     },
        { Label = "Perfect",        Enabled = false,    Value = playerstats:GetTapNoteScores('TapNoteScore_W2')                     }, 
        { Label = "Great",          Enabled = false,    Value = playerstats:GetTapNoteScores('TapNoteScore_W3')                     }, 
        { Label = "Good",           Enabled = false,    Value = playerstats:GetTapNoteScores('TapNoteScore_W4')                     }, 
        { Label = "Bad",            Enabled = false,    Value = playerstats:GetTapNoteScores('TapNoteScore_W5')                     },
        { Label = "Miss",           Enabled = false,    Value = playerstats:GetTapNoteScores('TapNoteScore_Miss')                   }, 
        { Label = "Hold",           Enabled = false,    Value = playerstats:GetTapNoteScores('TapNoteScore_CheckpointHit')          }, 
        { Label = "HoldMiss",       Enabled = false,    Value = playerstats:GetTapNoteScores('TapNoteScore_CheckpointMiss')         }, 
        { Label = "Mines",          Enabled = false,    Value = playerstats:GetTapNoteScores('TapNoteScore_HitMine')                }, 
        { Label = "Avoided",        Enabled = false,    Value = playerstats:GetTapNoteScores('TapNoteScore_AvoidMine')              }, 
        { Label = "None",           Enabled = false,    Value = playerstats:GetHoldNoteScores('HoldNoteScore_None')                 },
        { Label = "LetGo",          Enabled = false,    Value = playerstats:GetHoldNoteScores('HoldNoteScore_LetGo')                }, 
        { Label = "Held",           Enabled = false,    Value = playerstats:GetHoldNoteScores('HoldNoteScore_Held')                 },
        { Label = "MissHold",       Enabled = false,    Value = playerstats:GetHoldNoteScores('HoldNoteScore_MissedHold')           },
    };
    return stats;
end;


for pn in ivalues(GAMESTATE:GetHumanPlayers()) do

    -- grading
    t[#t+1] = Def.ActorFrame{
        InitCommand=cmd(y,originY;x,originX + (210*pnSide(pn)));

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

        Def.BitmapText{
            Name = "PERCENT";
            Font = "regen silver";
            InitCommand=cmd(strokecolor,0.2,0.2,0.2,0.8;zoom,0.5;y,32);
            OnCommand=function(self)
                if pss[pn] then 
                    --self:settext(scores[pn]["Percentage"].Value.."%");
                    self:diffuse(PlayerColor(pn));
                    self:strokecolor(BoostColor(PlayerColor(pn),0.25));
                    self:shadowlength(1); 
                end;
            end;
        }
    }



    -- scores
    t[#t+1] = Def.ActorFrame{
        InitCommand=cmd(y,SCREEN_CENTER_Y;x,SCREEN_CENTER_X + (290*pnSide(pn)));

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

end;

return t;