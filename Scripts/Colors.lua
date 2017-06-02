--//================================================================

JudgmentColor = {
    ["Superb"]  = color("1.0, 0.4, 0.9, 1"),
    ["Pefect"]  = color("0.2, 0.7, 1.0, 1"),
    ["Great"]   = color("0.1, 1.0, 0.3, 1"),
    ["Good"]    = color("1.0, 0.9, 0.2, 1"),
    ["Bad"]     = color("0.8, 0.2, 0.9, 1"),
    ["Miss"]    = color("1.0, 0.1, 0.1, 1"),
}

--//================================================================

function HighlightColor() 
    return color("0.3,1,0.775,1");
end;

--//================================================================

function PlayerColor(pn,alpha)

    if pn == PLAYER_1 then 
        if alpha then
            return color("0.40,0.85,1,"..alpha) 
        else
            return color("0.40,0.85,1")
        end
    end;

    if pn == PLAYER_2 then 
        if alpha then
            return color("0.20,1,0.40,"..alpha) 
        else
            return color("0.20,1,0.40") 
        end;
    end;
    
    return color("1,1,1")
end

--//================================================================