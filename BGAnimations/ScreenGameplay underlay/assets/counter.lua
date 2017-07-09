local t = Def.ActorFrame{}
local function LabelColor(value)
    local c = JudgmentColor(value) or {1,1,1,1};
    return {c[1],c[2],c[3],1}
end;

local redir_tns = {
    TapNoteScore_W1 = "TapNoteScore_W1",
    TapNoteScore_W2 = "TapNoteScore_W2",
    TapNoteScore_W3 = "TapNoteScore_W3",
    TapNoteScore_W4 = "TapNoteScore_W4",
    TapNoteScore_W5 = "TapNoteScore_W5",
    TapNoteScore_Miss = "TapNoteScore_Miss",
    TapNoteScore_CheckpointHit = RedirCheckpointTNS(),
    TapNoteScore_CheckpointMiss = "TapNoteScore_Miss",
}

local redir_hns = {
    HoldNoteScore_Held = "HoldNoteScore_Held",
    HoldNoteScore_LetGo = "HoldNoteScore_LetGo",
    HoldNoteScore_MissedHold = "TapNoteScore_Miss",
}

for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
    if SideJoined(pn) and PLAYERCONFIG:get_data(pn).ShowJudgmentList then

        local p = Def.ActorFrame{
            InitCommand=cmd(x,_screen.cx + (((_screen.w * 0.5) - 12) * pnSide(pn));y,SCREEN_BOTTOM-44);
        };

        local spacing = 12;
        local labels = JudgmentLabels();
        if not ShowHoldJudgments() then
            table.remove(labels, #labels);
            table.remove(labels, #labels);
        end;

        if not THEMECONFIG:get_data().AllowW1 then
            table.remove(labels, 1);
        end;

        p[#p+1] = Def.Quad{
            InitCommand=cmd(horizalign,pnAlign(pn);vertalign,bottom;diffuse,BoostColor(PlayerColor(pn,0.8),0.05);zoomto,64,spacing * (#labels+2));
        };

        for i=1,#labels do

            local numjudge = 0;
            p[#p+1] = Def.ActorFrame{
                InitCommand=cmd(vertalign,bottom;horizalign,pnAlign(pn);y,((#labels-i+2)*-spacing);x,20 * -pnSide(pn));
                UpdateMessageCommand=function(self)
                    local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn);
                    local value;
                    if string.find(labels[i].Key,"HoldNoteScore_") then 
                        value = pss:GetHoldNoteScores(labels[i].Key);
                    else
                        value = pss:GetTapNoteScores(labels[i].Key);
                    end;

                    if labels[i].Key == RedirCheckpointTNS() then
                        value = value + pss:GetTapNoteScores("TapNoteScore_CheckpointHit");
                    elseif labels[i].Key == "TapNoteScore_Miss" then
                        value = value + pss:GetTapNoteScores("TapNoteScore_CheckpointMiss") + pss:GetHoldNoteScores("HoldNoteScore_MissedHold");
                    end;

                    self:GetChild(labels[i].Key):settext(value);
                end;

                -- judgment
                Def.BitmapText{
                    Font = Fonts.counter["Main"];
                    Text = labels[i].Lite;
                    InitCommand=cmd(zoomx,0.5;zoomy,0.4;diffuse,LabelColor(labels[i].Value);horizalign,pnAlign(pn);x,-12 * -pnSide(pn);maxwidth,24);
                },

                -- value
                Def.BitmapText{
                    Font = Fonts.counter["Main"];
                    Text = numjudge;
                    Name = labels[i].Key;
                    InitCommand=cmd(zoom,0.4;diffuse,BoostColor(LabelColor(labels[i].Value),2);horizalign,pnAlign(pn);x,8* -pnSide(pn));
                },

            };

        end;

        --grade
        p[#p+1] = Def.ActorFrame{
            InitCommand=cmd(vertalign,bottom;horizalign,pnAlign(pn);y,(1*-spacing)+2;x,(spacing+4) * -pnSide(pn));
            UpdateMessageCommand=function(self)
                local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn);
                local grade;

                if IsGame("pump") then
                    grade = PIUGrading(pn);
                    grade = FormatGradePIU(grade)
                else
                    local curdp = pss:GetActualDancePoints();
                    local maxdp = pss:GetCurrentPossibleDancePoints();
                    local dp = curdp / clamp(maxdp,1,maxdp);
                    grade = GetGradeFromPercent(dp, false)
                    grade = FormatGrade(grade)
                end;

                self:GetChild("Grade"):settext(grade);
            end;

            -- value
            Def.BitmapText{
                Font = Fonts.counter["Main"];
                Text = numjudge;
                Name = "Grade";
                InitCommand=cmd(zoom,0.4;horizalign,pnAlign(pn);x,-8 * -pnSide(pn));
            },
        };




        t[#t+1] = p;
    end;
end;

return t;