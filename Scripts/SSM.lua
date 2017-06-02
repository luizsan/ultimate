--//================================================================    

function SetSSM()
    
    Global.prevstate = "MainMenu"
    Global.pnskin[PLAYER_1] = -1;
    Global.pnskin[PLAYER_2] = -1;

    Global.master = GAMESTATE:GetMasterPlayerNumber();
    Global.selection = SetWheelSelection()

    MESSAGEMAN:Broadcast("BuildMusicList",{ first = true });
    
    for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
        Global.pnsteps[pn] = GetEntry(GAMESTATE:GetCurrentSteps(pn));
        Global.pncursteps[pn] = Global.steps[Global.pnsteps[pn]];
        MESSAGEMAN:Broadcast("StepsChanged");
    end;

    Global.level = 1;
    Global.confirm[PLAYER_1] = 0;
    Global.confirm[PLAYER_2] = 0;

    Global.selection = 4; 
    Global.state = "MainMenu"
    Global.blocksteps = true;
    Global.lockinput = true;
    Global.steps = FilterSteps(Global.song);

    MESSAGEMAN:Broadcast("StateChanged");

end;

--//================================================================    

function SetGroups()
    Global.allgroups = SONGMAN:GetSongGroupNames();
    Global.allgroups = FilterGroups(Global.allgroups);

    local pref = GAMESTATE:GetPreferredSong();
    local first = SONGMAN:GetSongsInGroup(Global.allgroups[1]["Name"]);

    if #FilterSteps(pref)>0 then
        Global.song = pref;
        Global.songgroup = pref:GetGroupName();
    else
        Global.songgroup = first[1]:GetGroupName();
        Global.song = first[SetWheelSelection()];
    end;

    GAMESTATE:SetCurrentSong(Global.song);

    Global.songlist = SONGMAN:GetSongsInGroup(Global.songgroup)
    Global.songlist = FilterSongList(Global.songlist);
    --MESSAGEMAN:Broadcast("SongGroup"); 
end;

--//================================================================

function FilterGroups(stringlist)
    local filter = {};
    local numsongs = {};

    for i=1,#stringlist do
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
    
    Global.songlist = FilterSongList(SONGMAN:GetSongsInGroup(Global.songgroup));
        for i=1,#Global.songlist do
            if Global.song then
                if Global.song == Global.songlist[i] then
                    selection = i;
                    break
                end;
            end
        end;

    Global.song = Global.songlist[selection]
    return selection;
end;

--//================================================================

function FilterSteps(song)
    local filter = {};
    local steplist = StepsList(song);
    if steplist then
        for i=1,#steplist do
            if steplist[i] then
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
        local singles = {};
        local solos = {};
        local doubles = {};
        local halfdoubles = {};
        
        local routines = {};
        local steps = {};
        
        singles = song:GetStepsByStepsType("StepsType_"..Game().."_Single");
        
        if Game() ~= "Kb7" then
            doubles = song:GetStepsByStepsType("StepsType_"..Game().."_Double");
            routines = song:GetStepsByStepsType("StepsType_"..Game().."_Routine");
        end;
        
        if Game() == "Dance" then
            solos = song:GetStepsByStepsType("StepsType_Dance_Solo");
        elseif Game() == "Pump" then
            halfdoubles = song:GetStepsByStepsType("StepsType_Pump_Halfdouble");
        end;

        for s=1,#singles do
            steps[#steps+1] = singles[s];
        end 

        if GAMESTATE:GetNumSidesJoined()~=2 and Game() ~= "Kb7" then
            for d=1,#doubles do
                steps[#steps+1] = doubles[d];
            end;
            for c=1,#solos do
                steps[#steps+1] = solos[c];
            end
            for h=1,#halfdoubles do
                steps[#steps+1] = halfdoubles[h];
            end;
            for r=1,#routines do
                steps[#steps+1] = routines[r];
            end;
        end;
    
        table.sort(steps,function(a,b) return SortCharts(a,b) end)
        return steps;
    else
        return {};
    end

end;

--//================================================================

function GetEntry(steps)
    local entry;
    local steplist = FilterSteps(Global.song);
    local value = 1;
        if steps then
            for entry=1,#steplist do
                if steplist[entry] == steps then
                    return entry;
                end;
            end;
        else
            return 1;
        end;
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

function TotalNotes(steps,pn)
    local song = Global.song;
        if song then
            local taps = steps:GetRadarValues(pn):GetValue('RadarCategory_TapsAndHolds');
            local holds = steps:GetRadarValues(pn):GetValue('RadarCategory_Holds');
            local jumps = steps:GetRadarValues(pn):GetValue('RadarCategory_Jumps');
            local hands = steps:GetRadarValues(pn):GetValue('RadarCategory_Hands');
            local rolls = steps:GetRadarValues(pn):GetValue('RadarCategory_Rolls');
            local lifts = steps:GetRadarValues(pn):GetValue('RadarCategory_Lifts');

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