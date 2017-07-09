local steps_item_space= _screen.h*.05
local steps_item_width= steps_item_space * .75
local steps_type_item_space= _screen.h*.06

local steps_display= setmetatable({disable_wrapping= true}, item_scroller_mt)
local function steps_transform(self, item_index, num_items)
	self.container:xy((item_index-.5) * steps_item_space, 15)
end
local function stype_transform(self, item_index, num_items)
	self.container:y((item_index-1) * steps_type_item_space)
end
local stype_item_mt= edit_pick_menu_steps_display_item(
	stype_transform, Def.BitmapText{
		Font = Fonts.edit["Steps"], InitCommand= function(self)
			self:zoom(.5):horizalign(left):shadowlength(1)
		end,
		SetCommand= function(self, param)
			self:settext(THEME:GetString("LongStepsType", ToEnumShortString(param.stype)))
		end,
																 },
	steps_transform, Def.BitmapText{
		Font = Fonts.edit["Steps"], InitCommand= function(self)
			self:zoom(.5):shadowlength(1)
		end,
		SetCommand= function(self, param)
			self:settext(param.steps:GetMeter())
				:diffuse(GameColor.Difficulty[param.steps:GetDifficulty()])
			width_limit_text(self, steps_item_width, .5)
		end,
})

local picker_width= _screen.w * .5
local spacer= _screen.h * .05
local jacket_size= _screen.h * .2
local jacket_x= _screen.w - spacer - (jacket_size / 2)
local jacket_y= _screen.h * .2
local banner_width= _screen.w - picker_width - jacket_size - (spacer * 3)
local banner_height= _screen.h * .2
local banner_x= jacket_x - spacer - (jacket_size / 2) - (banner_width / 2)
local banner_y= jacket_y
local bpm_x= jacket_x + (jacket_size / 2)
local bpm_y= jacket_y + (jacket_size / 2) + (spacer / 2)
local length_x= bpm_x
local length_y= bpm_y + (spacer / 2)
local title_x= banner_x - (banner_width / 2)
local title_y= bpm_y
local artist_x= title_x
local artist_y= length_y
local steps_display_x= title_x
local steps_display_y= title_y + (spacer * 1.5)
local steps_display_items= (_screen.h - steps_display_y) / steps_type_item_space

local menu_params= {
	name= "menu", x= (_screen.cx*0.5) + 16, y= _screen.h*.15, width= (_screen.cx) - 32,
	translation_section= "ScreenEditMenu",
	menu_sounds= {
		pop = THEME:GetPathS("Common", "Cancel"),
		push = THEME:GetPathS("", "Steps"),
		act = THEME:GetPathS("", "Steps"),
		move = THEME:GetPathS("", "Switch"),
		move_up = THEME:GetPathS("", "Switch"),
		move_down = THEME:GetPathS("", "Switch"),
		inc = THEME:GetPathS("", "Switch"),
		dec = THEME:GetPathS("", "Switch"),
	},
	num_displays= 1, el_height= 20, display_params= {
		no_status= true,
		height= _screen.h*.75, el_zoom= 0.6,
		item_mt= cons_option_item_mt, item_params= {
			text_commands= {
				Font= Fonts.edit["Menu"], OnCommand= function(self)
					self:diffusealpha(0):linear(0.1):diffusealpha(1):shadowlength(1)
				end,
			},
			text_width= .7,
			value_text_commands= {
				Font= Fonts.edit["Menu"], OnCommand= function(self)
					self:diffusealpha(0):linear(0.1):diffusealpha(1)
				end,
			},
			value_image_commands= {
				OnCommand= function(self)
					self:diffusealpha(0):linear(0.1):diffusealpha(1)
				end,
			},
			value_width= .25,
			type_images= {
				bool= THEME:GetPathG("", "NestyMenu icons/bool"),
				choice= THEME:GetPathG("", "NestyMenu icons/bool"),
				menu= THEME:GetPathG("", "NestyMenu icons/menu"),
			},
		},
	},
}

local frame= Def.ActorFrame{
	edit_menu_selection_changedMessageCommand=
		edit_pick_menu_update_steps_display_info(steps_display),
	edit_pick_menu_actor(menu_params),
	Def.Sprite{
		Name= "jacket", InitCommand= function(self)
			self:xy(jacket_x, jacket_y)
		end,
		edit_menu_selection_changedMessageCommand= function(self, params)
			if params.group then
				self:visible(false)
			elseif params.song then
				if params.song:HasJacket() then
					self:visible(true)
					self:LoadBanner(params.song:GetJacketPath())
					scale_to_fit(self, jacket_size, jacket_size)
				else
					self:visible(false)
				end
			end
		end,
	},
	Def.Sprite{
		Name= "banner", InitCommand= function(self)
			self:xy(banner_x, banner_y)
		end,
		edit_menu_selection_changedMessageCommand= function(self, params)
			if params.group then
				local path= SONGMAN:GetSongGroupBannerPath(params.group)
				if #path > 0 then
					self:visible(true)
					self:LoadBanner(path)
					scale_to_fit(self, banner_width, banner_height)
				else
					self:visible(false)
				end
			elseif params.song then
				if params.song:HasBanner() then
					self:visible(true)
					self:LoadBanner(params.song:GetBannerPath())
					scale_to_fit(self, banner_width, banner_height)
				else
					self:visible(false)
				end
			end
		end,
	},
	Def.BitmapText{
		Name= "length", Font= Fonts.edit["Steps"], InitCommand= function(self)
			self:xy(length_x, length_y):horizalign(right):zoom(.5):shadowlength(1)
		end,
		edit_menu_selection_changedMessageCommand= function(self, params)
			if params.group then
				self:visible(false)
			elseif params.song then
				self:settext(SecondsToMSS(params.song:MusicLengthSeconds()))
				self:visible(true)
			end
		end,
	},
	Def.BitmapText{
		Name= "bpm", Font = Fonts.edit["Steps"], InitCommand= function(self)
			self:xy(bpm_x, bpm_y):horizalign(right):zoom(.5):shadowlength(1)
		end,
		edit_menu_selection_changedMessageCommand= function(self, params)
			if params.group then
				self:visible(false)
			elseif params.song then
				local display_bpm= params.song:GetDisplayBpms()
				if display_bpm[1] == display_bpm[2] then
					self:settextf("%d BPM", display_bpm[1])
				else
					self:settextf("%d - %d BPM", math.round(display_bpm[1]), math.round(display_bpm[2]))
				end
				self:visible(true)
			end
		end,
	},
	Def.BitmapText{
 		Name= "title", Font = Fonts.edit["Steps"], InitCommand= function(self)
			self:xy(title_x, title_y):horizalign(left):zoom(.5):shadowlength(1)
		end,
		edit_menu_selection_changedMessageCommand= function(self, params)
			if params.group then
				self:visible(false)
			elseif params.song then
				self:settext(params.song:GetDisplayMainTitle(),params.song:GetTranslitMainTitle())
				self:visible(true)
			end
		end,
	},
	Def.BitmapText{
 		Name= "artist", Font = Fonts.edit["Steps"], InitCommand= function(self)
			self:xy(artist_x, artist_y):horizalign(left):zoom(.5):shadowlength(1)
		end,
		edit_menu_selection_changedMessageCommand= function(self, params)
			if params.group then
				self:visible(false)
			elseif params.song then
				self:settext(params.song:GetDisplayArtist(),params.song:GetTranslitArtist())
				self:visible(true)
			end
		end,
	},
	steps_display:create_actors("steps_display", steps_display_items, stype_item_mt, steps_display_x, steps_display_y),
}

return frame
