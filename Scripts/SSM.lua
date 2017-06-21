--//================================================================    

function SetSSM()
    if IsRoutine() then
        GAMESTATE:UnjoinPlayer(OtherPlayer[Global.master]);
        GAMESTATE:SetCurrentStyle("single");
    end;

    Global.pnskin[PLAYER_1] = -1;
    Global.pnskin[PLAYER_2] = -1;

    Global.master = GAMESTATE:GetMasterPlayerNumber();
    Global.mastersteps = Global.pncursteps[Global.master];
    Global.selection = SetWheelSelection()
    Global.steps = FilterSteps(Global.song);

    for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
        --if not Global.pncursteps[pn] and SideJoined(pn) then
            local entry = GetEntry(GAMESTATE:GetCurrentSteps(pn), Global.steps);
            if Global.pncursteps[pn] ~= Global.steps[Global.pnsteps[pn]] then
                Global.pnsteps[pn] = entry;
                Global.pncursteps[pn] = Global.steps[Global.pnsteps[pn]];
                GAMESTATE:SetCurrentSteps(pn, Global.pncursteps[pn]);
            end;
        --end
    end;

    FixStyleForSteps(Global.pncursteps[Global.master]);

    MESSAGEMAN:Broadcast("BuildMusicList", { first = true });
    MESSAGEMAN:Broadcast("StepsChanged", { silent = true });
    
    Global.level = 1;
    Global.confirm[PLAYER_1] = 0;
    Global.confirm[PLAYER_2] = 0;

    Global.selection = 4; 
    Global.prevstate = "MainMenu"
    Global.state = "MainMenu"
    Global.blocksteps = true;
    Global.lockinput = true;
    Global.disqualify = false;
    
    MESSAGEMAN:Broadcast("StateChanged");
end;

--//================================================================    

function SetGroups()
    Global.allgroups = SONGMAN:GetSongGroupNames();
    Global.allgroups = FilterGroups(Global.allgroups);

    local pref = GAMESTATE:GetPreferredSong()
    local first = Global.allgroups[1]["Songs"];
    local prefgroup = -1;

    if pref then
        for i=1,#Global.allgroups do
            if Global.allgroups[i]["Name"] == pref:GetGroupName() then prefgroup = i; end;
        end;

        if #FilterSteps(pref) > 0 then
            Global.songlist = Global.allgroups[prefgroup]["Songs"];
            Global.songgroup = pref:GetGroupName();
            Global.song = pref;

        elseif prefgroup > 0 then
            Global.songlist = Global.allgroups[prefgroup]["Songs"];
            Global.songgroup = Global.allgroups[prefgroup]["Name"];
            Global.song = Global.allgroups[prefgroup]["Songs"][1];
        else
            Global.songlist = first;
            Global.songgroup = first[1]:GetGroupName();
            Global.song = first[SetWheelSelection()];

        end;
    else
        Global.songlist = Global.allgroups[1]["Songs"]
        Global.songgroup = Global.allgroups[1]["Name"]
        Global.song = Global.allgroups[1]["Songs"][1]
    end;

    GAMESTATE:SetCurrentSong(Global.song);
    --MESSAGEMAN:Broadcast("SongGroup"); 
end;

--//================================================================

function FilterGroups(stringlist)
    local filter = {};
    local numsongs = {};

    for i=1, math.min(#stringlist,SONGMAN:GetNumSongGroups()) do
        local songs = {};
        songs = SONGMAN:GetSongsInGroup(stringlist[i])
        songs = FilterSongList(songs);

        if #songs > 0 then 
            filter[#filter+1] = { 
                ["Name"] = stringlist[i],
                ["Songs"] = songs, 
                ["Count"] = #songs, 
            }; 
        end;

    end;

    return filter;
end;

--//================================================================

function FilterSongList(songlist)
    local filter = {};
    local itemsteps = {};
    
    for i=1,#songlist do
        itemsteps = FilterSteps(songlist[i]);
        if #itemsteps > 0 then
            filter[#filter+1] = songlist[i];
        end;
    end;
    if #filter == 0 then filter = {} end;
    return filter
end;

--//================================================================

function SetWheelSelection()
    local selection = 1;

    if Global.song then
        for i=1,#Global.songlist do
            if Global.song == Global.songlist[i] then
                selection = i;
                break
            end
        end;
        Global.song = Global.songlist[selection];
    else
        Global.song = Global.songlist[1];
    end

    return selection;
end;

--//================================================================

function SetWheelSteps()
    Global.steps = FilterSteps(Global.song);
    for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
        Global.pnsteps[pn] = 1;
        Global.pncursteps[pn] = Global.steps[1];
    end;
end;

--//================================================================

function GetWheelSteps()
    Global.steps = FilterSteps(Global.song);
    for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
        Global.pnsteps[pn] = GetEntry(Global.pncursteps[pn], Global.steps);
        Global.pncursteps[pn] = Global.steps[Global.pnsteps[pn]];
    end;
end;

--//================================================================

function FilterSteps(song)
    local filter = {};
    local steplist = StepsList(song);
    if steplist then
        for i=1,#steplist do
            if steplist[i] and steplist[i]:GetMeter() > 0 then
                filter[#filter+1] = steplist[i]
            end
        end
        table.sort(filter,function(a,b) return SortCharts(a,b) end)
        return filter
    else
        return {};
    end;
end
--//================================================================


function FixStyleForSteps(steps)
    if steps then
        local st = ToEnumShortString(steps:GetStepsType());
        if st == "Double" then 
            GAMESTATE:SetCurrentStyle("single");
        --elseif st == "Routine" then 
        --    GAMESTATE:SetCurrentStyle("single");
        else 
            if GAMESTATE:GetNumSidesJoined() == 2 then
                GAMESTATE:SetCurrentStyle("versus");
            else
                GAMESTATE:SetCurrentStyle("single");
            end;
        end;
    end;
end;

--//================================================================

function SortCharts(a,b)
    local bST = StepsType:Compare(a:GetStepsType(),b:GetStepsType()) < 0
    if a:GetStepsType() == b:GetStepsType() then
        return a:GetMeter() < b:GetMeter()
    else
        return bST
    end;
end

--//================================================================

function SortScoresByDP(a,b)
    return a:GetPercentDP() > b:GetPercentDP()
end;

--//================================================================

function SortScoresByDate(a,b)
    return tonumber(RawDate(a:GetDate())) > tonumber(RawDate(b:GetDate()))
end;

--//================================================================

function StepsList(song)

    if song then
        local allsteps = song:GetAllSteps();
        local steps = {};

        for i=1,#allsteps do
            if EligibleSteps(allsteps[i]) then
                steps[#steps+1] = allsteps[i];
            end;
        end;

        table.sort(steps,function(a,b) return SortCharts(a,b) end)
        return steps;
    else
        return {};
    end

end;

--//================================================================

function EligibleSteps(steps)
    local st = steps:GetStepsType();
    local sides = GAMESTATE:GetNumSidesJoined();

    if not string.find(st, Game()) then return false end;

    local pads_required = {
        ["StepsType_Dance_Double"]      = 2,
        ["StepsType_Dance_Couple"]      = 2,
        ["StepsType_Dance_Routine"]     = 2,
        ["StepsType_Pump_Halfdouble"]   = 2,
        ["StepsType_Pump_Double"]       = 2,
        ["StepsType_Pump_Couple"]       = 2,
        ["StepsType_Pump_Routine"]      = 2,
        ["StepsType_Maniax_Double"]     = 2,
        ["StepsType_Techno_Double4"]    = 2,
        ["StepsType_Techno_Double5"]    = 2,
        ["StepsType_Techno_Double8"]    = 2,
    };

    if pads_required[st] and pads_required[st] == sides then return false end;
    return true;
end;

--//================================================================

function GetFolder(song)

    local path = song:GetSongDir();
    local index;
    local str = path;

    str = string.reverse(str)
    str = string.sub(str, 2)
    str = string.reverse(str)
    str = string.sub(str, 2)

    index = string.find(str,"/")
    str = string.sub(str, index+1)
    
    index = string.find(str,"/")
    str = string.sub(str, index+1)

    return str;

end

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

function TotalNotes(steps,pn)
    local player = pn;
    if not pn then player = Global.master or GAMESTATE:GetMasterPlayerNumber(); end;

    local song = Global.song or GAMESTATE:GetCurrentSong();
        if song then
            local taps = steps:GetRadarValues(player):GetValue('RadarCategory_TapsAndHolds');
            local holds = steps:GetRadarValues(player):GetValue('RadarCategory_Holds');
            local jumps = steps:GetRadarValues(player):GetValue('RadarCategory_Jumps');
            local hands = steps:GetRadarValues(player):GetValue('RadarCategory_Hands');
            local rolls = steps:GetRadarValues(player):GetValue('RadarCategory_Rolls');
            local lifts = steps:GetRadarValues(player):GetValue('RadarCategory_Lifts');

        return (taps+holds+jumps+hands+rolls+lifts)
        end;
end;

--//================================================================

function AvgNotesSec(steps,pn)
    local song = Global.song;
    if song then

        local length = song:GetStepsSeconds()
        --local stream = steps:GetRadarValues(pn):GetValue('RadarCategory_Stream');
        --local avg = math.ceil(((TotalNotes(steps,pn)/length)*stream)*100)/100;
        local total = TotalNotes(steps,pn)
        local avg = math.ceil((TotalNotes(steps,pn)/length)*100)/100;

        return avg;

    end;
end;

--//================================================================

function GetRadar(steps,pn,index)
    if steps then
        if index == 1 then --taps
                return steps:GetRadarValues(pn):GetValue('RadarCategory_TapsAndHolds');
            elseif index == 2 then --jumps
                return steps:GetRadarValues(pn):GetValue('RadarCategory_Jumps');
            elseif index == 3 then --holds
                return steps:GetRadarValues(pn):GetValue('RadarCategory_Holds');
            elseif index == 4 then --hands
                return steps:GetRadarValues(pn):GetValue('RadarCategory_Hands');
            elseif index == 5 then --mines
                return steps:GetRadarValues(pn):GetValue('RadarCategory_Mines');
            elseif index == 6 then --others
                return (steps:GetRadarValues(pn):GetValue('RadarCategory_Rolls') + 
                steps:GetRadarValues(pn):GetValue('RadarCategory_Lifts') + 
                steps:GetRadarValues(pn):GetValue('RadarCategory_Fakes')); 
            else return 0;
        end;
    else
        return 0;
    end;
end;

--//================================================================