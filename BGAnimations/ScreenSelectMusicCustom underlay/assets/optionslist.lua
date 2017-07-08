local NOTESCONFIG = notefield_prefs_config;
local maxitems = 5;
local currentoption = nil;  
local option_stack = {
    [PLAYER_1] = {},
    [PLAYER_2] = {},
};
local selection_stack = {
    [PLAYER_1] = {},
    [PLAYER_2] = {},
};

local option_tree = { 
    {
        Name = "Speed",
        Options = {
            ConfigRange(NOTESCONFIG, "speed_mod", 250, 1, 9999, 25),
            ConfigChoices(PLAYERCONFIG, "SpeedModifier", 25, { 1, 10, 25, 50, 100 }),
            ConfigChoices(NOTESCONFIG, "speed_type", "maximum", notefield_speed_types),
            ConfigAction("Reset", function() end),
            ConfigExit("Back"),
        },
    },
    ConfigAction("Noteskin", function() end),
    {
        Name = "Transform",
        Options = {
            ConfigRange(NOTESCONFIG, "yoffset", 130, 0, 180, 1),
            {   
                Name = "Zoom", 
                Options = {
                    ConfigRange(NOTESCONFIG, "zoom", 1, -5, 5, 0.05), 
                    ConfigRange(NOTESCONFIG, "zoom_x", 1, -5, 5, 0.05), 
                    ConfigRange(NOTESCONFIG, "zoom_y", 1, -5, 5, 0.05), 
                    ConfigRange(NOTESCONFIG, "zoom_z", 1, -5, 5, 0.05), 
                    ConfigAction("Reset", function() end),
                    ConfigExit("Back"),
                }
            },
            {   
                Name = "Rotation", 
                Options = {
                    ConfigRange(NOTESCONFIG, "rotation_x", 0, -360, 360, 1), 
                    ConfigRange(NOTESCONFIG, "rotation_y", 0, -360, 360, 1), 
                    ConfigRange(NOTESCONFIG, "rotation_z", 0, -360, 360, 1), 
                    ConfigAction("Reset", function() end),
                    ConfigExit("Back"),
                }
            },
            ConfigBool(NOTESCONFIG, "reverse", false),
            ConfigRange(NOTESCONFIG, "fov", 45, 30, 90, 1),
            ConfigAction("Reset", function() end),
            ConfigExit("Back"),
        },
    },
    {
        Name = "Display",
        Options = {
            ConfigBool(NOTESCONFIG, "hidden", false),
            ConfigBool(NOTESCONFIG, "sudden", false),
            --ConfigRange(NOTESCONFIG, "hidden_offset", 0, 0, 0, 0), 
            --ConfigRange(NOTESCONFIG, "sudden_offset", 0, 0, 0, 0), 
            --ConfigRange(NOTESCONFIG, "fade_distance", 0, 0, 0, 0), 
            ConfigBool(NOTESCONFIG, "glow_during_fade", true),
            ConfigAction("Reset", function() end),
            ConfigExit("Back"),
        },
    },
    {
        Name = "Reset",
        Options = {
            ConfigAction("Reset To Default", function() end),
            ConfigExit("Back"),
        }
    },

    ConfigExit("Exit"),
};


function OptionsListController(self,param)
    --
end;

local t = Def.ActorFrame{};

local fontsize = 0.45;
local lineheight = 16;
local spacing = 180;
local sidespacing = 170;

for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
    if SideJoined(pn) then

        local scroller_actor = Def.ActorFrame{
            -- name
            Def.BitmapText{
                Name = "Name";
                Font = Fonts.options["Main"];
                InitCommand=cmd(horizalign,pnAlign(OtherPlayer[pn]);zoom,fontsize;skewx,-0.12);
                OnCommand=cmd(playcommand,"LoseFocus");
                GainFocusCommand=cmd(stoptweening;decelerate,0.15;diffuse,HighlightColor();strokecolor,BoostColor(HighlightColor(),0.2));
                LoseFocusCommand=cmd(stoptweening;decelerate,0.15;diffuse,PlayerColor(pn);strokecolor,BoostColor(PlayerColor(pn),0.4));
                DisabledCommand=cmd(stoptweening;decelerate,0.15;diffuse,0.6,0.6,0.6,0.5;strokecolor,0.2,0.2,0.2,0.8);
            },
            -- value
            Def.BitmapText{
                Name = "Value";
                Font = Fonts.options["Main"];
                InitCommand=cmd(visible,false;horizalign,pnAlign(OtherPlayer[pn]);zoom,fontsize);
                OnCommand=cmd(playcommand,"LoseFocus");
                GainFocusCommand=cmd(stoptweening;decelerate,0.15;diffuse,HighlightColor();strokecolor,BoostColor(HighlightColor(),0.2));
                LoseFocusCommand=cmd(stoptweening;decelerate,0.15;diffuse,PlayerColor(pn);strokecolor,BoostColor(PlayerColor(pn),0.4));
                DisabledCommand=cmd(stoptweening;decelerate,0.15;diffuse,0.6,0.6,0.6,0.5;strokecolor,0.2,0.2,0.2,0.8);
            },  
        }

        table.insert(option_stack[pn], option_tree);
        local scroller = setmetatable({disable_wrapping = true}, item_scroller_mt)
        local scroller_item = OptionScrollerItem(lineheight,scroller_actor);
        scroller_item.__index.transform = function(self, item_index, num_items, is_focus)
            self.container:stoptweening();
            self.container:x(item_index * 2 * pnSide(pn));
            self.container:y(item_index * self.spacing);
            self.prev_index = item_index;
        end;


        t[#t+1] = Def.ActorFrame{
            InitCommand=cmd(diffusealpha,0;x,pnSide(pn)*32);
            OptionsListOpenedMessageCommand=function(self,param)
                if param.Player == pn then
                    self:stoptweening():decelerate(0.45):diffusealpha(1):x(pnSide(pn));
                end;
            end;
            OptionsListClosedMessageCommand=function(self,param)
                if param.Player == pn then
                    self:stoptweening():decelerate(0.4):diffusealpha(0):x(pnSide(pn)*32);
                end;
            end;
            OnCommand=function(self)
                scroller:set_info_set(GetCurrentStackInfo(option_stack[pn]), 1); 
            end;

            -- fade quad
            Def.Quad{
                InitCommand=cmd(skewx,-0.1;zoomto,_screen.h*(16/9)*-pnSide(pn),_screen.h;horizalign,right;diffuse,BoostColor(Global.bgcolor,0.5);diffusealpha,0.75;Center;faderight,1/4);
            },

            -- color quad
            Def.Quad{
                InitCommand=cmd(skewx,-0.5;zoomto,_screen.h*(16/9)*-pnSide(pn),_screen.h;horizalign,right;diffuse,BoostColor(PlayerColor(pn,0.75),0.9);diffusebottomedge,PlayerColor(pn,0);Center;faderight,1/2);
            },

            Def.ActorFrame{
                InitCommand=cmd(x,SCREEN_CENTER_X + (pnSide(pn)*(spacing+16));y,SCREEN_CENTER_Y-136);

                -- title
                Def.BitmapText{
                    Font = Fonts.options["Main"];
                    Text = "Player Options";
                    InitCommand=cmd(zoom,0.375;horizalign,pnAlign(OtherPlayer[pn]);strokecolor,0.2,0.2,0.2,0.8;diffusealpha,0);
                    OptionsListOpenedMessageCommand=function(self,param)
                        if param and param.Player == pn then
                            self:stoptweening();
                            self:decelerate(0.2);
                            self:diffusealpha(0.75);
                        end;
                    end;
                    OptionsListClosedMessageCommand=function(self,param)
                        if param and param.Player == pn then
                            self:stoptweening();
                            self:accelerate(0.3);
                            self:diffusealpha(0);
                        end;
                    end;
                },

                -- main scroller
                scroller:create_actors("OptionsList", 8, scroller_item, 0, 0)..{
                    InitCommand=cmd(y,4;x,16*pnSide(pn);diffusealpha,0);
                    OptionsListOpenedMessageCommand=function(self,param)
                        if param and param.Player == pn then
                            self:stoptweening();
                            self:decelerate(0.3);
                            self:diffusealpha(1);
                            self:x(0);
                        end;
                    end;

                    OptionsListClosedMessageCommand=function(self,param)
                        if param and param.Player == pn then
                            self:stoptweening();
                            self:accelerate(0.2);
                            self:diffusealpha(0);
                            self:x(16*pnSide(pn));
                        end;
                    end;

                    OnCommand=function(self) 
                        scroller:set_info_set(GetCurrentStackInfo(option_stack[pn]), 1); 
                    end;
                },
            }

        }



    end;
end;

return t;