--//================================================================

function OptionsController(self,param)

    if param.Input == "Cancel" or param.Input == "Back" then
        Global.level = 1; 
        Global.selection = 7; 
        Global.state = "MainMenu";  
        MESSAGEMAN:Broadcast("StateChanged"); 
        MESSAGEMAN:Broadcast("Return");
    end;

end;

--//================================================================

function SelectOptions()
    Global.level = 1; 
    Global.selection = 7;
    Global.state = "MainMenu";  
    MESSAGEMAN:Broadcast("StateChanged"); 
    MESSAGEMAN:Broadcast("Return");
end;

--//================================================================
