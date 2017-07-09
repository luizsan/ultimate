gameplay_pause_count= 0

local pause_buttons= {Start= false, Select= true, Back= false}
local pause_double_tap_time= 0.75
local tap_debounce_time= 0
local pause_press_times= {}
local screen_gameplay= false
local menu_items= {[PLAYER_1]= {}, [PLAYER_2]= {}}
local menu_frames= {}
local menu_choices= {
	"Continue",
	"Retry",
	"Quit",
}
local menu_spacing= 20
local menu_bg_width= SCREEN_WIDTH/4

local elem = {
	[PLAYER_1] = "PlayerP1",
	[PLAYER_2] = "PlayerP2"
}

local current_menu_choice= {}
local menu_is_showing= {}
local enabled_players= {}

local function create_menu_item(pn, x, y, item_name)
	return Def.BitmapText{
		Font = "regen small", 
		Text = string.upper(item_name),
		InitCommand= function(self)
			self:xy(x, y)
			self:strokecolor(0,0,0,0.75)
			self:zoomx(0.6)
			self:zoomy(0.55)
			table.insert(menu_items[pn], self)
			self:playcommand("LoseFocus")
		end,
		LoseFocusCommand= function(self)
			self:stopeffect();
			self:diffuse(1,1,1,1)
		end,
		GainFocusCommand= function(self)
			self:diffuseshift()
			self:effectcolor1(HighlightColor())
			self:effectcolor2(PlayerColor(pn))
			self:effectperiod(2)
		end,
	}
end

local function create_menu_frame(pn, x, y)
	local frame= Def.ActorFrame{
		InitCommand= function(self)
			self:playcommand("Hide")
			menu_frames[pn]= self
		end,
		ShowCommand= function(self)
			self:x(SCREENMAN:GetTopScreen():GetChild(elem[pn]):GetX())
			self:y(SCREEN_CENTER_Y - (#menu_choices/2*menu_spacing))
			self:visible(true)
		end,
		HideCommand= function(self)
			self:visible(false)
		end,

		Def.Quad{
			InitCommand= function(self)
				self:setsize(menu_bg_width, menu_spacing)
				self:y(-menu_spacing*2)
				self:vertalign(top)
				self:diffuse{0, 0, 0, 0.75}
				self:playcommand("Hide")
			end,
		},

		LoadFont("regen silver")..{
			InitCommand=cmd(settext,"game paused";zoom,0.33;strokecolor,0.2,0.2,0.2,1;y,-menu_spacing*1.5;diffuse,HighlightColor()),
		},

		Def.Quad{
			InitCommand= function(self)
				self:setsize(menu_bg_width, menu_spacing * (#menu_choices + 1))
				self:y(-menu_spacing)
				self:vertalign(top)
				self:diffuse{0, 0, 0, 0.5}
				self:playcommand("Hide")
			end,
		},
	}
	for i, choice in ipairs(menu_choices) do
		frame[#frame+1]= create_menu_item(pn, 0, (i-1)*menu_spacing, choice)
	end
	return frame
end

local function backout(screen)
	SCREENMAN:SetNewScreen(screen);
end

local function show_menu(pn)
	local eligible = false;
	if IsRoutine() then
		if pn == GAMESTATE:GetMasterPlayerNumber() then
			eligible = true;
		end;
	else
		eligible = true;
	end;

	if eligible then
		menu_frames[pn]:playcommand("Show")
		for i, item in ipairs(menu_items[pn]) do
			item:playcommand("LoseFocus")
		end
		current_menu_choice[pn]= 1
		menu_items[pn][current_menu_choice[pn]]:playcommand("GainFocus")
		menu_is_showing[pn]= true
	end;
end

local function close_menu(pn)
	menu_frames[pn]:playcommand("Hide")
	menu_is_showing[pn]= false
	local stay_paused= false
	for pn, showing in pairs(menu_is_showing) do
		if showing then
			stay_paused= true
		end
	end
	if not stay_paused then
		local fg= screen_gameplay:GetChild("SongForeground")
		if fg then fg:visible(old_fg_visible) end
		MESSAGEMAN:Broadcast("Unpaused")
		screen_gameplay:PauseGame(false)
	end
end

local menu_actions= {
	Start= function(pn)
		local choice_name = menu_choices[current_menu_choice[pn]]
		MESSAGEMAN:Broadcast("Decision")
		if choice_name == "Continue" then
			close_menu(pn)
		elseif choice_name == "Retry" then
			backout("ScreenGameplay")
		elseif choice_name == "Quit" then
			backout(ToSelectMusicFromGameplay())
		end;
	end,
	Left= function(pn)
		if current_menu_choice[pn] > 1 then
			MESSAGEMAN:Broadcast("Choice")
			menu_items[pn][current_menu_choice[pn]]:playcommand("LoseFocus")
			current_menu_choice[pn]= current_menu_choice[pn] - 1
			menu_items[pn][current_menu_choice[pn]]:playcommand("GainFocus")
		end
	end,
	Right= function(pn)

		if current_menu_choice[pn] < #menu_choices then
			MESSAGEMAN:Broadcast("Choice")
			menu_items[pn][current_menu_choice[pn]]:playcommand("LoseFocus")
			current_menu_choice[pn]= current_menu_choice[pn] + 1
			menu_items[pn][current_menu_choice[pn]]:playcommand("GainFocus")
		end
	end,
}
menu_actions.Up= menu_actions.Left
menu_actions.Down= menu_actions.Right
menu_actions.MenuLeft= menu_actions.Left
menu_actions.MenuRight= menu_actions.Right
menu_actions.MenuUp= menu_actions.Up
menu_actions.MenuDown= menu_actions.Down

local down_status= {}

local function other_button_down(button)
	for other_button, down in pairs(down_status) do
		if down and other_button ~= button then
			return true
		end
	end
	return false
end

local function detect_lr_press()
	return down_status.MenuLeft and down_status.MenuRight
end

local function pause_and_show(pn)
	local eligible = false;
	if IsRoutine() then
		if pn == GAMESTATE:GetMasterPlayerNumber() then
			eligible = true;
		end;
	else
		eligible = true;
	end;

	if eligible then
		gameplay_pause_count= gameplay_pause_count + 1
		MESSAGEMAN:Broadcast("Paused")
		screen_gameplay:PauseGame(true)
		local fg= screen_gameplay:GetChild("SongForeground")
		if fg then
			old_fg_visible= fg:GetVisible()
			fg:visible(false)
		end
		local prompt_text= screen_gameplay:GetChild("Debug")
		if prompt_text then
			prompt_text:playcommand("TweenOff")
		end

		show_menu(pn)
	end;

end

local function input(event)
	local pn= event.PlayerNumber
	if not enabled_players[pn] then return end
	local button= event.GameButton
	if not button then return end
	if event.type == "InputEventType_Release" then
		down_status[event.button]= false
		return
	end
	down_status[event.button]= true
	if screen_gameplay:GetName() == "ScreenGameplaySyncMachine" then return end
	local is_paused= screen_gameplay:IsPaused()
	if is_paused then
		if menu_is_showing[pn] then
			if menu_actions[button] then
				menu_actions[button](pn)
				return
			end
		else
			if pause_buttons[button] or detect_lr_press() then
				show_menu(pn)
				return
			end
		end
	else
		button= event.button
		if event.type ~= "InputEventType_FirstPress" then return end
		if detect_lr_press() then
			pause_and_show(pn)
		elseif pause_buttons[button] then
			if GAMESTATE:GetCoinMode() == "CoinMode_Pay" then return end
			if pause_press_times[pn] and not other_button_down(button) then
				local time_since_press= GetTimeSinceStart() - pause_press_times[pn]
				if time_since_press > tap_debounce_time then
					if time_since_press <= pause_double_tap_time then
						pause_and_show(pn)
					else
						pause_press_times[pn]= GetTimeSinceStart()
					end
				end
			else
				pause_press_times[pn]= GetTimeSinceStart()
			end
		else
			pause_press_times[pn]= nil
		end
	end
end

local frame= Def.ActorFrame{
	OnCommand= function(self)
		screen_gameplay = SCREENMAN:GetTopScreen()
		screen_gameplay:AddInputCallback(input)
	end,

	LoadActor(THEME:GetPathG("","bg"))..{
		InitCommand=cmd(FullScreen;diffuse,BoostColor(Global.bgcolor,0.2);diffusealpha,0.85;visible,false),
		PausedMessageCommand=cmd(visible,true),
		UnpausedMessageCommand=cmd(visible,false),
	},

	LoadActor(THEME:GetPathS("Common","cancel"))..{
		DecisionMessageCommand=cmd(play)
	},

	LoadActor(THEME:GetPathS("","Mainmenu"))..{
		ChoiceMessageCommand=cmd(play)
	},
}

for i, pn in ipairs(GAMESTATE:GetEnabledPlayers()) do
	enabled_players[pn]= true
	frame[#frame+1]= create_menu_frame(pn, 0, 0)
end

return frame
