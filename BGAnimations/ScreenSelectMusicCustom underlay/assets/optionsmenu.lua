--//================================================================

local maxitems = 5;
local currentoption = nil;  
local option_stack = {};
local selection_stack = {};
local option_tree = { 

    {
        Name = "Display",
        Options = {
            ConfigRange(THEMECONFIG, "BGBrightness", 100, 0, 100, 5),
            ConfigBool(THEMECONFIG, "DefaultBG", false),
            ConfigBool(THEMECONFIG, "CenterPlayer", false),
            ConfigExit("Back"),
        },
    },

    {
        Name = "Song",
        Options = {
            ConfigRange(THEMECONFIG, "MusicRate", 1, 0.5, 2, 0.05),
            ConfigChoices(THEMECONFIG, "FailType", "delayed", { "immediate", "delayed", "off" }),
            ConfigBool(THEMECONFIG, "FailMissCombo", true),
            ConfigExit("Back"),
        },
    },

    {
        Name = "Judgment",
        Options = {
            ConfigBool(THEMECONFIG, "AllowW1"),
            ConfigRange(THEMECONFIG, "TimingDifficulty", 4, 1, 9, 1),
            ConfigRange(THEMECONFIG, "LifeDifficulty", 4, 1, 7, 1),
            ConfigExit("Back"),
        },
    },
    ConfigReset("Reset"),
    ConfigExit("Exit"),

};

table.insert(option_stack, option_tree);

--//================================================================

function OptionsController(self,param)

    if param.Input == "Prev" then
        if currentoption then
            MESSAGEMAN:Broadcast("ChangeProperty", { Player = nil, Input = param.Input, Option = currentoption });
            MESSAGEMAN:Broadcast("OptionsMenu", { Player = param.Player, Direction = "Prev", silent = true });
            THEMECONFIG:save("ProfileSlot_Invalid");
            return;
        else
            Global.selection = Global.selection-1;
            if Global.selection < 1 then Global.selection = #option_stack[#option_stack] end;
            if Global.selection > #option_stack[#option_stack] then Global.selection = 1 end;
            MESSAGEMAN:Broadcast("OptionsMenu", { Player = param.Player, Direction = "Prev", silent = false });
            return;
        end;
    end;
    
    if param.Input == "Next" then
        if currentoption then
            MESSAGEMAN:Broadcast("ChangeProperty", { Player = nil, Input = param.Input, Option = currentoption });
            MESSAGEMAN:Broadcast("OptionsMenu", { Player = param.Player, Direction = "Next", silent = true });
            THEMECONFIG:save("ProfileSlot_Invalid");
            return;
        else
            Global.selection = Global.selection+1;
            if Global.selection > #option_stack[#option_stack] then Global.selection = 1 end;
            if Global.selection < 1 then Global.selection = #option_stack[#option_stack] end;
            MESSAGEMAN:Broadcast("OptionsMenu", { Player = param.Player, Direction = "Next", silent = false });
            return;
        end;
    end;

    if param.Input == "Cancel" or param.Input == "Back" then

        if currentoption then
            Global.selection = GetEntry(currentoption, option_stack[#option_stack]);
            currentoption = nil;
            MESSAGEMAN:Broadcast("Return");
            MESSAGEMAN:Broadcast("OptionsMenu", { silent = true });
            return;

        elseif #option_stack > 1 then

            Global.selection = selection_stack[#selection_stack];
            table.remove(selection_stack, #selection_stack);
            table.remove(option_stack, #option_stack);
            MESSAGEMAN:Broadcast("Return");
            MESSAGEMAN:Broadcast("OptionsMenu", { silent = true });
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


    if currentoption ~= nil then

        currentoption = nil;
        MESSAGEMAN:Broadcast("OptionsSelected");
        MESSAGEMAN:Broadcast("OptionsMenu", { silent = true });

    else

        local topstack = option_stack[#option_stack][Global.selection];

        if topstack.Options and #topstack.Options > 0 then 
            table.insert(selection_stack, Global.selection);
            table.insert(option_stack, topstack.Options);
            Global.selection = 1;
            MESSAGEMAN:Broadcast("OptionsSelected");
            MESSAGEMAN:Broadcast("OptionsMenu", { silent = true });
            return;

        elseif topstack.Type then

            if topstack.Type == "reset" then
                ResetThemeSettings();
                MESSAGEMAN:Broadcast("OptionsSelected");
                MESSAGEMAN:Broadcast("OptionsMenu", { silent = true });
                THEMECONFIG:save("ProfileSlot_Invalid");

            elseif topstack.Type == "bool" then
                MESSAGEMAN:Broadcast("ChangeProperty", { Input = "Next", Option = topstack, silent = true });
                MESSAGEMAN:Broadcast("OptionsSelected");
                MESSAGEMAN:Broadcast("OptionsMenu", { silent = true });
                THEMECONFIG:save("ProfileSlot_Invalid");
            else
                currentoption = topstack;
                MESSAGEMAN:Broadcast("OptionsSelected");
                MESSAGEMAN:Broadcast("OptionsMenu", { silent = true });
                return;
            end

        else

            if #option_stack > 1 then

                Global.selection = selection_stack[#selection_stack];
                table.remove(selection_stack, #selection_stack);
                table.remove(option_stack, #option_stack);
                MESSAGEMAN:Broadcast("Return");
                MESSAGEMAN:Broadcast("OptionsMenu", { silent = true });
                return;
            else
                Global.level = 1; 
                Global.selection = 7; 
                Global.state = "MainMenu";  
                MESSAGEMAN:Broadcast("StateChanged"); 
                MESSAGEMAN:Broadcast("Return");
                return;
            end

        end;

    end
end;

--//================================================================


-- panel
local window_w = 320;
local window_h = 164;

local itemspacing = 16;
local sidespacing = window_w/2-24;

local scroll_index = 1;
local item_mt = {
    __index = {
        prev_index = -1;
        move_time = 0.15;
        spacing = itemspacing;
        create_actors = function(self, params)
            self.name = params.name;
            local sidespacing = (window_w/2) - 24;
            local fontsize = 0.475;
            return Def.ActorFrame{
                Name = name;
                InitCommand=function(subself)
                    self.container = subself;
                end;

                -- name
                Def.BitmapText{
                    Name = "Name";
                    Font = Fonts.options["Main"];
                    InitCommand=cmd(horizalign,left;x,-sidespacing;zoom,fontsize;strokecolor,0.2,0.2,0.2,1);
                    GainFocusCommand=cmd(stoptweening;decelerate,0.15;diffuse,HighlightColor();strokecolor,BoostColor(HighlightColor(),0.2));
                    LoseFocusCommand=cmd(stoptweening;decelerate,0.15;diffuse,1,1,1,1;strokecolor,0.2,0.2,0.2,0.8);
                    DisabledCommand=cmd(stoptweening;decelerate,0.15;diffuse,0.6,0.6,0.6,0.5;strokecolor,0.2,0.2,0.2,0.8);
                },
                -- value
                Def.BitmapText{
                    Name = "Value";
                    Font = Fonts.options["Main"];
                    InitCommand=cmd(horizalign,right;x,sidespacing;zoom,fontsize;strokecolor,0.2,0.2,0.2,1);
                    GainFocusCommand=cmd(stoptweening;decelerate,0.15;diffuse,HighlightColor();strokecolor,BoostColor(HighlightColor(),0.2));
                    LoseFocusCommand=cmd(stoptweening;decelerate,0.15;diffuse,1,1,1,1;strokecolor,0.2,0.2,0.2,0.8);
                    DisabledCommand=cmd(stoptweening;decelerate,0.15;diffuse,0.6,0.6,0.6,0.5;strokecolor,0.2,0.2,0.2,0.8);
                },  
            }
        end;

        transform = function(self, item_index, num_items, is_focus)
            self.container:stoptweening();

            if math.abs(item_index - self.prev_index) > 1 then
                if item_index == 1 and self.prev_index == num_items then
                    self.container:y(0);
                    self.container:diffusealpha(0);
                    self.container:decelerate(self.move_time);
                    self.container:diffusealpha(1);
                    self.container:y(1 * self.spacing);
                elseif item_index == num_items and self.prev_index == 1 then 
                    self.container:y(num_items * self.spacing);
                    self.container:diffusealpha(0);
                    self.container:decelerate(self.move_time);
                    self.container:y(item_index * self.spacing);
                    self.container:diffusealpha(1);
                else
                    self.container:diffusealpha(0);
                    self.container:y(item_index * self.spacing);
                    self.container:decelerate(self.move_time*2);
                    self.container:diffusealpha(1);
                end
            else
                self.container:decelerate(self.move_time);
                self.container:diffusealpha(1);
                self.container:y(item_index * self.spacing);
            end;
            self.prev_index = item_index;
        end;

        set = function(self, info)
            if info and info.Name then
                self.container:GetChild("Name"):settext(info.Name);
            else
                self.container:GetChild("Name"):settext("");
            end;
            if info and info.Value then
                self.container:GetChild("Value"):settext(info.Value);
            else
                self.container:GetChild("Value"):settext("");
            end;
        end;
    }
}

local scroller = setmetatable({disable_wrapping = true}, item_scroller_mt)

--//================================================================

local function GetCurrentStackInfo()
    local infotable = {};
    local cur = option_stack[#option_stack];

    for i=1,#cur do

        local info = {}
        info.Name = cur[i].Name; 
        if cur[i].Type and cur[i].Type ~= "reset" then
            local optiondata = { 
                Option = cur[i],
                Config = THEMECONFIG,
            }
            info.Value = GetConfig(optiondata);
        else
            info.Value = "";
        end;

        info = FormatOptionConfigs(info.Name, info.Value);
        table.insert(infotable, info);
    end
    return infotable;
end

--//================================================================

local function ScrollerFocus(s, index)
    local focused = s:get_items_by_info_index(index)[1];
    for i=1,#s.items do
        if s.items[i] == focused then
            s.items[i].container:playcommand("GainFocus");
        else
            s.items[i].container:playcommand(currentoption ~= nil and "Disabled" or "LoseFocus");
        end;
    end;
    return focused;
end;

--//================================================================

local t = PropertyActor()..{
    InitCommand=cmd(CenterX;y,SCREEN_CENTER_Y-96;diffusealpha,0;zoom,0.8);
    StateChangedMessageCommand=function(self)
        self:playcommand("Refresh");
        self:stoptweening();
        self:linear(0.1);
        if Global.state == "OptionsMenu" then
            self:diffusealpha(1);
            self:zoom(1)
            offset = 0;
        else
            self:diffusealpha(0);
            self:zoom(0.8);
        end;
    end;

    OnCommand=cmd(playcommand,"Refresh");
    ReturnMessageCommand=cmd(playcommand,"Refresh");
    OptionsMenuMessageCommand=cmd(playcommand,"Refresh");
    OptionsSelectedMessageCommand=cmd(playcommand,"Refresh");
    PropertyChangedMessageCommand=cmd(playcommand,"Refresh");
    OptionsMenuMessageCommand=function(self,param)
        scroller:scroll_to_pos(Global.selection);
        MESSAGEMAN:Broadcast("ScrollerCursor", { Focused = ScrollerFocus(scroller,Global.selection) });
    end;

    RefreshCommand=function()
        scroller:set_info_set(GetCurrentStackInfo(), 1);
    end;
};

--//================================================================

t[#t+1] = Def.ActorFrame{
    InitCommand=cmd(y,(window_h/2) - 32);

    -- shadow
    LoadActor(THEME:GetPathG("","dim"))..{
        InitCommand=cmd(zoomto,window_w+4,72;y,window_h/2+2;diffuse,0,0,0,0.75;valign,0.75;croptop,0.75;fadeleft,0.15;faderight,0.15);
    },

    -- black outline
    Def.Quad{ InitCommand=cmd(zoomto,window_w+4,window_h+4;diffuse,0,0,0,0.75); },

    -- fill
    Def.Quad{ InitCommand=cmd(zoomto,window_w,window_h;diffuse,0.18,0.18,0.18,0.85;diffusebottomedge,0,0.15,0.25,0.9); },

    -- checker
    LoadActor(THEME:GetPathG("","checker"))..{
        InitCommand=cmd(zoomto,window_w,window_h;customtexturerect,0,0,window_w/4,window_h/4;diffuse,0,0,0,0.15);
    },

    --lines
    Def.Quad{ InitCommand=cmd(x,-window_w/2-0.5;zoomto,1,window_h+2;diffuse,0.5,0.5,0.5,0.5); },  
    Def.Quad{ InitCommand=cmd(x,window_w/2+0.5;zoomto,1,window_h+2;diffuse,0.5,0.5,0.5,0.5); },  
    Def.Quad{ InitCommand=cmd(y,-window_h/2-0.5;zoomto,window_w,1;diffuse,0.5,0.5,0.5,0.5); },  
    Def.Quad{ InitCommand=cmd(y,window_h/2+0.5;zoomto,window_w,1;diffuse,0.5,0.5,0.5,0.5); },  

    -- glow
    LoadActor(THEME:GetPathG("","glow"))..{
        InitCommand=cmd(zoomto,window_w*1.5,window_h*1.5;y,window_h/2;diffuse,BoostColor(HighlightColor(),0.5);diffusealpha,0.4;cropbottom,0.5;cropleft,0.165;cropright,0.165;diffusetopedge,0,0,0,0;blend,Blend.Add);
    },
    -- description area
    Def.Quad{ InitCommand=cmd(y,window_h/2;zoomto,window_w,32;diffuse,HighlightColor();diffusealpha,0.1;blend,Blend.Add;vertalign,bottom); },  
    Def.Quad{ InitCommand=cmd(y,-window_h/2;zoomto,window_w,30;diffuse,0.1,0.1,0.1,0.5;vertalign,top); },  

    -- title
    Def.BitmapText{
        Font = Fonts.options["Main"];
        Text = "Game Options";
        InitCommand=cmd(y,-window_h/2+10;vertalign,top;zoom,0.6;strokecolor,0.125,0.125,0.125,0.5);
    },
}

--//================================================================


local cursorzoom = 0.4;
local cursorspacing = (window_w+4) / 2;

t[#t+1] = Def.ActorFrame{
    StateChangedMessageCommand=cmd(y,itemspacing;visible,Global.state == "OptionsMenu");
    ScrollerCursorMessageCommand=function(self,param)
        self:stoptweening();
        self:decelerate(0.15)
        if param and param.Focused then
            local target = param.Focused;
            self:y(target.prev_index * itemspacing);
        end;
    end;


    Def.Quad{
        InitCommand=cmd(diffuse,HighlightColor();fadeleft,0.1;faderight,0.1;diffusealpha,0);
        OnCommand=cmd(zoomto,window_w*0.95,1);
        ReturnMessageCommand=cmd(stoptweening;decelerate,0.15;diffusealpha,0);
        OptionsSelectedMessageCommand=function(self,param)
            self:stoptweening();
            self:decelerate(0.15);
            if currentoption ~= nil then
                self:diffusealpha(0.25);
            else
                self:diffusealpha(0);
            end;
        end;
    },


    Def.ActorFrame{
        Name = "Normal";
        ReturnMessageCommand=cmd(playcommand,"Refresh");
        OptionsSelectedMessageCommand=cmd(playcommand,"Refresh");
        RefreshCommand=function(self)
            self:stoptweening();
            self:decelerate(0.2);
            if currentoption == nil then
                self:diffuse(0.6,0.6,0.6,0.95);
            else
                self:diffuse(0.8,0.8,0.8,1);
            end;
        end;

        LoadActor(THEME:GetPathG("","miniarrow"))..{
            InitCommand=cmd(animate,false;x,-cursorspacing;zoom,cursorzoom;shadowlengthy,1);
        },  
        LoadActor(THEME:GetPathG("","miniarrow"))..{
            InitCommand=cmd(animate,false;x,cursorspacing;zoom,cursorzoom;zoomx,-cursorzoom;shadowlengthy,1);
        },
    },

    Def.ActorFrame{
        Name = "Glow";
        LoadActor(THEME:GetPathG("","miniarrow"))..{
            InitCommand=cmd(animate,false;setstate,1;x,-cursorspacing;zoom,cursorzoom;diffusealpha,0;blend,"BlendMode_Add");
            GlowCommand=cmd(stoptweening;diffusealpha,1;sleep,0.1;decelerate,0.2;diffusealpha,0);
            OptionsMenuMessageCommand=function(self,param)
                if param and param.Direction == "Prev" and currentoption then
                    self:playcommand("Glow");
                end;
            end;
        },  
        LoadActor(THEME:GetPathG("","miniarrow"))..{
            InitCommand=cmd(animate,false;setstate,1;x,cursorspacing;zoom,cursorzoom;zoomx,-cursorzoom;diffusealpha,0;blend,"BlendMode_Add");
            GlowCommand=cmd(stoptweening;diffusealpha,1;sleep,0.1;decelerate,0.2;diffusealpha,0);
            OptionsMenuMessageCommand=function(self,param)
                if param and param.Direction == "Next" and currentoption then
                    self:playcommand("Glow");
                end;
            end;
        },
    },
};


t[#t+1] = scroller:create_actors("OptionsMenu", 5, item_mt, 0, 0);

return t;