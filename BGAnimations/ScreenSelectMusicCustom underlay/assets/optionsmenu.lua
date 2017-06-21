--//================================================================

local offset = 0;
local maxitems = 7;
local path = nil;
local currentoption = nil;  

local options = { 
    OptionPreferenceRange("Background Brightness", "BGBrightness", 1, 0, 1, 0.01 ),
    OptionPreferenceChoices("Center 1 Player", "Center1Player", false, { false, true }),
    OptionSongModsRange("Music Rate", "MusicRate", 1, 0.5, 2, 0.05),
    OptionPlayerModsChoices("Fail Type", "FailSetting", 'FailType_Immediate', { 'FailType_Immediate', 'FailType_ImmediateContinue','FailType_Off' }, true),
    OptionPreferenceChoices("Timing Window Scale", "TimingWindowScale", 1, {1.5, 1.33, 1.16, 1.0, 0.84, 0.66, 0.5, 0.33, 0.2}),    
    OptionBack();
};

--//================================================================

function OptionsController(self,param)

    if param.Input == "Prev" then
        if currentoption then
            MESSAGEMAN:Broadcast("ChangeProperty", { Player = param.Player, Input = param.Input, Option = currentoption});
        else
            if Global.selection > 1 then
                Global.selection = Global.selection-1;
                if Global.selection < 1 + offset then 
                    offset = offset - 1; 
                    MESSAGEMAN:Broadcast("OffsetChanged", { Direction = "Prev" }); 
                end;
                MESSAGEMAN:Broadcast("OptionsMenu", { Direction = "Prev", silent = false });
            end;
        end;
    end;
    
    if param.Input == "Next" then
        if currentoption then
            MESSAGEMAN:Broadcast("ChangeProperty", { Player = param.Player, Input = param.Input, Option = currentoption});
        else
            if Global.selection < #options then
                Global.selection = Global.selection+1;
                if Global.selection > maxitems + offset then 
                    offset = offset + 1; 
                    MESSAGEMAN:Broadcast("OffsetChanged", { Direction = "Next" }); 
                end;
                MESSAGEMAN:Broadcast("OptionsMenu", { Direction = "Next", silent = false });
            end;
        end;
    end;

    if param.Input == "Cancel" or param.Input == "Back" then
        if currentoption then
            currentoption = nil;
            MESSAGEMAN:Broadcast("Return");
            return;
        else
            Global.level = 1; 
            Global.selection = 7; 
            Global.state = "MainMenu";  
            MESSAGEMAN:Broadcast("StateChanged"); 
            MESSAGEMAN:Broadcast("Return");
        end;
    end;

end;

--//================================================================

function SelectOptions()
    if not currentoption and options[Global.selection].Name ~= "Return" then
        currentoption = options[Global.selection];
        MESSAGEMAN:Broadcast("OptionsSelected");
        return
    elseif options[Global.selection].Name == "Return" then
        Global.level = 1; 
        Global.selection = 7;
        Global.state = "MainMenu";  
        MESSAGEMAN:Broadcast("StateChanged"); 
        MESSAGEMAN:Broadcast("Return");
    else
        currentoption = nil;
        MESSAGEMAN:Broadcast("OptionsSelected");
    end
end;

--//================================================================

local t = PropertyActor()..{
    InitCommand=cmd(diffusealpha,0);
    PropertyChangedMessageCommand=function(self,param)
    end;
    StateChangedMessageCommand=function(self)
        self:stoptweening();
        self:linear(0.1);
        if Global.state == "OptionsMenu" then
            self:diffusealpha(1);
            offset = 0;
        else
            self:diffusealpha(0);
        end;

    end;
};

--//================================================================

local spacing = 16;
local o = Def.ActorFrame{
    InitCommand=cmd(CenterX;y,SCREEN_CENTER_Y-120);
}

for i=0,maxitems+1 do

    o[#o+1] = Def.ActorFrame{
        InitCommand=cmd(y,(i-1) * spacing);
        ReturnMessageCommand=cmd(playcommand,"Refresh");
        OptionsSelectedMessageCommand=cmd(playcommand,"Refresh");
        PropertyChangedMessageCommand=cmd(playcommand,"Refresh");
        OptionsMenuMessageCommand=cmd(playcommand,"Refresh");
        OffsetChangedMessageCommand=function(self,param)
            if param.Direction == "Prev" then i = i+1; end;
            if param.Direction == "Next" then i = i-1; end;
            if i < 0 then i = maxitems+1; end;
            if i > maxitems+1 then i = 0; end;
            self:stoptweening();
            if i > 0 and i < maxitems+1 then
                self:decelerate(0.125);
                self:diffusealpha(1);
            else
                self:diffusealpha(0);
            end;
            self:y((i-1) * spacing);
            self:playcommand("Refresh");
        end;

        -- option name
        Def.BitmapText{
            Font = Fonts.options["Main"];
            Text = options[i] and options[i].Name or "nil";
            InitCommand=cmd(horizalign,left;x,-120;zoom,0.45);
            GainFocusCommand=cmd(stoptweening;linear,0.1;diffuse,HighlightColor();strokecolor,BoostColor(HighlightColor(),0.3));
            LoseFocusCommand=cmd(stoptweening;linear,0.1;diffuse,1,1,1,1;strokecolor,0.35,0.35,0.35,1);
            DisabledCommand=cmd(stoptweening;linear,0.1;diffuse,0.5,0.5,0.5,0.75;strokecolor,0.35,0.35,0.35,1);
            RefreshCommand=function(self)
                local index = i+offset;
                if Global.selection == index then
                    self:playcommand("GainFocus");
                elseif currentoption then
                    self:playcommand("Disabled");
                else
                    self:playcommand("LoseFocus");
                end;
                self:settext(options[index] and options[index].Name or "");
            end;
        },

        -- option value
        Def.BitmapText{
            Font = Fonts.options["Main"];
            InitCommand=cmd(horizalign,right;x,120;zoom,0.45);
            GainFocusCommand=cmd(stoptweening;linear,0.1;diffuse,HighlightColor();strokecolor,BoostColor(HighlightColor(),0.3));
            LoseFocusCommand=cmd(stoptweening;linear,0.1;diffuse,1,1,1,1;strokecolor,0.35,0.35,0.35,1);
            DisabledCommand=cmd(stoptweening;linear,0.1;diffuse,0.5,0.5,0.5,0.75;strokecolor,0.35,0.35,0.35,1);
            RefreshCommand=function(self)
                local index = i+offset;
                if Global.selection == index then
                    self:playcommand("GainFocus");
                elseif currentoption then
                    self:playcommand("Disabled");
                else
                    self:playcommand("LoseFocus");
                end;

                local str;
                local conf = GetConfig({ Option = options[index] });
                if conf ~= nil then
                    if type(conf) == "number" then
                        str = string.format("%.f",conf*100).."%";
                    else
                        str = tostring(conf);
                    end;
                else
                    str = ""
                end

                self:settext(str);
            end;
        },


    }
end;

local cursorspacing = 140;
o[#o+1] = Def.ActorFrame{
    Name = "Cursor";
    OptionsMenuMessageCommand=function(self,param)
        self:stoptweening();
        if not param or (param and not param.silent) then
            self:linear(0.1);
        end;
        self:y((Global.selection-offset-1)*spacing);
    end;
    
    Def.ActorFrame{
        Name = "Normal";
        LoadActor(THEME:GetPathG("","miniarrow"))..{
            InitCommand=cmd(animate,false;x,-cursorspacing;zoom,0.43;diffuse,0.6,0.6,0.6,0.95;shadowlengthy,1);
            ReturnMessageCommand=cmd(stoptweening;linear,0.1;diffuse,0.6,0.6,0.6,0.95);
            OptionsSelectedMessageCommand=cmd(stoptweening;linear,0.1;diffuse,currentoption and {1,1,1,1} or {0.6,0.6,0.6,0.95});
        },  
        LoadActor(THEME:GetPathG("","miniarrow"))..{
            InitCommand=cmd(animate,false;x,cursorspacing;zoom,0.43;zoomx,-0.43;diffuse,0.6,0.6,0.6,0.95;shadowlengthy,1);
            ReturnMessageCommand=cmd(stoptweening;linear,0.1;diffuse,0.6,0.6,0.6,0.95);
            OptionsSelectedMessageCommand=cmd(stoptweening;linear,0.1;diffuse,currentoption and {1,1,1,1} or {0.6,0.6,0.6,0.95});
        },
    },

    Def.ActorFrame{
        Name = "Noteskin";
        InitCommand=cmd(animate,false;x,-cursorspacing;zoom,0.43;diffuse,0.6,0.6,0.6,0.95);
    },

    Def.ActorFrame{
        Name = "Glow";
        LoadActor(THEME:GetPathG("","miniarrow"))..{
            InitCommand=cmd(animate,false;setstate,1;x,-cursorspacing;zoom,0.43;diffusealpha,0;blend,"BlendMode_Add");
            GlowCommand=cmd(stoptweening;diffusealpha,1;decelerate,0.3;diffusealpha,0);
            ChangePropertyMessageCommand=function(self,param)
                if param.Input == "Prev" and SideJoined(param.Player) then
                    self:playcommand("Glow");
                end;
            end;
        },  
        LoadActor(THEME:GetPathG("","miniarrow"))..{
            InitCommand=cmd(animate,false;setstate,1;x,cursorspacing;zoom,0.43;zoomx,-0.43;diffusealpha,0;blend,"BlendMode_Add");
            GlowCommand=cmd(stoptweening;diffusealpha,1;decelerate,0.3;diffusealpha,0);
            ChangePropertyMessageCommand=function(self,param)
                if param.Input == "Next" and SideJoined(param.Player) then
                    self:playcommand("Glow");
                end;
            end;
        },
    },

};

t[#t+1] = o;

return t;