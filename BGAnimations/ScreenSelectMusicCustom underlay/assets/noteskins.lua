local maxitems = 9;
local horz_radius = 1.0;
local vert_radius = 1.3333;
local spacing = 270;
local vert = 72;
local cursorspacing = 30;

local playerchoices = {
	[PLAYER_1] = {
		["Noteskin"] = 1,
		["Selected"] = "",
	},
	[PLAYER_2] = {
		["Noteskin"] = 1,
		["Selected"] = "",
	},
};

local noteskins = {
	[PLAYER_1] = {},
	[PLAYER_2] = {},
};

local coords = {
	[PLAYER_1] = {},
	[PLAYER_2] = {},
};

local gamenote = {
	["dance"] = "Up",
	["kb7"] = "Key",
	["pump"] = "UpLeft",
}

for c=1,maxitems do 

	coords[PLAYER_1][c] = { 
		math.deg(math.sin(c/math.pi))*horz_radius, 
		math.deg(math.cos(c/math.pi))*vert_radius
	};

	coords[PLAYER_2][c] = { 
		math.deg(math.sin(c/math.pi))*horz_radius*-1,
		math.deg(math.cos(c/math.pi))*vert_radius
	};

end;

function NoteskinController(self,param)
	if param.Input == "Prev" then
		Global.confirm[param.Player] = 0;
		MESSAGEMAN:Broadcast("Deselect");
		if playerchoices[param.Player]["Noteskin"] > 1 then
			playerchoices[param.Player]["Noteskin"] = playerchoices[param.Player]["Noteskin"]-1;
			MESSAGEMAN:Broadcast("NoteskinChanged", { Player = param.Player, direction = "Prev"});
		end;
	end;

	if param.Input == "Next" then
		Global.confirm[param.Player] = 0;
		MESSAGEMAN:Broadcast("Deselect");
		if playerchoices[param.Player]["Noteskin"] < #noteskins[param.Player] then
			playerchoices[param.Player]["Noteskin"] = playerchoices[param.Player]["Noteskin"]+1;
			MESSAGEMAN:Broadcast("NoteskinChanged", { Player = param.Player, direction = "Next"});
		end;
	end;

	if param.Input == "Back" or param.Input == "Cancel" and Global.level == 2 then
		Global.level = 1; 
		Global.selection = 6; 
		Global.confirm[PLAYER_1] = 0;
		Global.confirm[PLAYER_2] = 0;
		Global.state = "MainMenu";  
		MESSAGEMAN:Broadcast("StateChanged"); 
		MESSAGEMAN:Broadcast("Return");
	end;

end;

local t = Def.ActorFrame{
	InitCommand=cmd(diffusealpha,0);
	StateChangedMessageCommand=function(self)
		self:stoptweening();
		self:decelerate(0.15);
		if Global.state == "Noteskins" then
			self:diffusealpha(1);
		else
			self:diffusealpha(0);
		end;
	end;
};

--//================================================================

local function GetNoteskins()
	return NOTESKIN:GetNoteSkinNames()
end;

--//================================================================

local function GetButton(nslist, index)
	local game = string.lower(GAMESTATE:GetCurrentGame():GetName());
	return NOTESKIN:LoadActorForNoteSkin(gamenote[game],"Tap Note", nslist[index]);
end;

--//================================================================

local function GetPreferredNoteskin(pn)
	return GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred"):NoteSkin();
end;

local function SetNoteskin(pn, ns)
	GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred"):NoteSkin(ns);
end;

--//================================================================
			
local function NoteskinSelection(pn)
	
	--<Kyzentun> NEWSKIN:get_all_skin_names will fetch all skin names, including ones that don't support the current stepstype.
	--<Kyzentun> get_skin_names_for_stepstype will fetch the ones for a given stepstype.

	Global.noteskins = GetNoteskins();

	local options = GAMESTATE:GetPlayerState(pn):GetPlayerOptionsString("ModsLevel_Preferred");
	local array = GAMESTATE:GetPlayerState(pn):GetPlayerOptionsArray("ModsLevel_Preferred");
	local defaultselection = 1;
	local selection = -1;
	
	for i=1,#Global.noteskins do
		if string.lower(Global.noteskins[i]) == "default" then defaultselection = i; end;
		for a=1,#array do
			if string.lower(array[a]) == string.lower(Global.noteskins[i]) then selection = i end;
		end;
		
	end;
	
	if selection == -1 then selection = defaultselection end;
	return selection
	
end;

--//================================================================

function SelectNoteskin(param)

	Global.confirm[param.Player] = 1;
	n = noteskins[param.Player][playerchoices[param.Player]["Noteskin"]];
	SetNoteskin(param.Player, n)
	MESSAGEMAN:Broadcast("NoteskinSelected");

	if Global.confirm[PLAYER_1] + Global.confirm[PLAYER_2] >= GAMESTATE:GetNumSidesJoined() then
		Global.level = 1; 
		Global.selection = 6; 
		Global.confirm[PLAYER_1] = 0;
		Global.confirm[PLAYER_2] = 0;
		Global.state = "MainMenu";  
		MESSAGEMAN:Broadcast("StateChanged"); 
		MESSAGEMAN:Broadcast("MainMenu");
	end;

end;

--//================================================================

for pn in ivalues(GAMESTATE:GetHumanPlayers()) do

	t[#t+1] = Def.ActorFrame{
		InitCommand=cmd(x,SCREEN_CENTER_X+spacing*pnSide(pn);y,SCREEN_CENTER_Y-vert);
		OnCommand=cmd(visible,SideJoined(pn));
		StepsChangedMessageCommand=function(self) MESSAGEMAN:Broadcast("ResetNoteskin", {silent=true}); end;
		ResetNoteskinMessageCommand=function(self,param)
			if GAMESTATE:IsSideJoined(pn) and Global.pncursteps[pn] then
				noteskins[pn] = GetNoteskins();
				pref = GetPreferredNoteskin(pn);

				for note=1,#noteskins[pn] do
					if noteskins[pn][note] == pref then
						playerchoices[pn]["Noteskin"] = note;
					end;
				end;

				local _silent;
				if param and param.silent then _silent = param.silent else _silent = true; end;
				MESSAGEMAN:Broadcast("NoteskinChanged", { silent = _silent, Player = pn })
			end;
		end;

		LoadActor(THEME:GetPathG("","glow"))..{
			InitCommand=cmd(diffuse,BoostColor(Global.bgcolor,0.7);diffusealpha,0.8);
		},

		Def.ActorFrame{
			Name = "Cursor";
			InitCommand=cmd(x,28*-pnSide(pn));
			StateChangedMessageCommand=function(self)
				self:stoptweening();
				self:decelerate(0.2);
				self:diffuse(1,1,1,1);
			end;
			
			Def.ActorFrame{
				Name = "Normal";
				LoadActor(THEME:GetPathG("","miniarrow"))..{
					InitCommand=cmd(animate,false;x,-cursorspacing;zoom,0.43;diffuse,0.6,0.6,0.6,0.95;shadowlengthy,1);
				},	
				LoadActor(THEME:GetPathG("","miniarrow"))..{
					InitCommand=cmd(animate,false;x,cursorspacing;zoom,0.43;zoomx,-0.43;diffuse,0.6,0.6,0.6,0.95;shadowlengthy,1);
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
					NoteskinChangedMessageCommand=function(self,param)
						if param.direction == "Prev" and pn == param.Player then
							self:playcommand("Glow");
						end;
					end;
				},	
				LoadActor(THEME:GetPathG("","miniarrow"))..{
					InitCommand=cmd(animate,false;setstate,1;x,cursorspacing;zoom,0.43;zoomx,-0.43;diffusealpha,0;blend,"BlendMode_Add");
					GlowCommand=cmd(stoptweening;diffusealpha,1;decelerate,0.3;diffusealpha,0);
					NoteskinChangedMessageCommand=function(self,param)
						if param.direction == "Next" and pn == param.Player then
							self:playcommand("Glow");
						end;
					end;
				},
			},

		};

	};

	local k = Def.ActorFrame{};

	for i=1,maxitems do

		k[#k+1] = Def.ActorFrame{
			Name="Item"..i;
			InitCommand=cmd(Center);
			OnCommand=cmd(visible,SideJoined(pn));
			NoteskinChangedMessageCommand=function(self,param)
				if param.Player == pn then
					local offset = playerchoices[pn]["Noteskin"];

					if param and param.direction == "Prev" then i = i-1; end;
					if param and param.direction == "Next" then i = i+1; end;
					
					self:stoptweening();
					if i < 1 then i = maxitems;
					elseif i > maxitems then i = 1;
					else self:decelerate(0.15); end;
					
					if i==1 or i==maxitems then 
						self:diffusealpha(0);
					elseif i==2 or i==maxitems-1 then 
						self:diffusealpha(0.5);
					else
						self:diffusealpha(1);
					end;

					self:x((SCREEN_CENTER_X+(spacing-24)*pnSide(pn))+coords[pn][i][1]);
					self:y((SCREEN_CENTER_Y)-vert+coords[pn][i][2]);

					MESSAGEMAN:Broadcast("UpdateNoteskins", {Player = pn});
				end;
			end;

			Def.BitmapText{
				Font = Fonts.noteskins["Main"];
				Text = "Label"..i;
				InitCommand=cmd(zoom,0.425;horizalign,pnAlign(pn));
				UpdateNoteskinsMessageCommand=function(self,param)
					if param.Player == pn then
						local cap = math.ceil(maxitems/2);
						if (cap-i+playerchoices[pn]["Noteskin"]) >= 1 and (cap-i+playerchoices[pn]["Noteskin"]) <= #noteskins[pn] then
							if noteskins[pn][cap-i+playerchoices[pn]["Noteskin"]] then
								self:settext(noteskins[pn][cap-i+playerchoices[pn]["Noteskin"]]);
								if i==5 then 
									self:diffuse(BoostColor(PlayerColor(pn),1.25));
								else
									self:diffuse(BoostColor(PlayerColor(pn),0.75));
								end;
								self:strokecolor(BoostColor(PlayerColor(pn),0.25));
							end;
						else
							self:settext("*");
							self:diffuse(0.6,0.6,0.6,0.8);
							self:strokecolor(0.2,0.2,0.2,0.8);
						end;
					end;
				end;
			};




		};

	end;

	t[#t+1] = k;


	local s = Def.ActorFrame{}
	local ns = GetNoteskins();
	local game = string.lower(GAMESTATE:GetCurrentGame():GetName());
	for j=1,#ns do

		local actor = GetButton(ns,j);
		s[#s+1] = actor..{
			Name = ns[j];
			InitCommand=cmd(zoomy,0.5;zoomx,0.5*-pnSide(pn);x,SCREEN_CENTER_X + ((spacing - 30)*pnSide(pn));y,SCREEN_CENTER_Y-vert;shadowlengthy,1.5);
			OnCommand=cmd(visible,SideJoined(pn));
			NoteskinChangedMessageCommand=function(self,param)

				local sel = noteskins[pn][playerchoices[pn]["Noteskin"]];
				local ind = playerchoices[pn]["Noteskin"];
				local offset = j-ind;

				self:stoptweening();
				self:effectclock("bgm");

				if not param.silent then
					self:decelerate(0.125);
				end

				if(ns[j] == sel) then
					self:zoomy(0.5);
					self:zoomx(0.5*-pnSide(pn));
					self:y(SCREEN_CENTER_Y-vert);
					self:diffusealpha(1);
					self:draworder(1);
				else
					self:zoomy(0.35);
					self:zoomx(0.35*-pnSide(pn));
					self:y(SCREEN_CENTER_Y-vert + (offset*30));
					self:diffusealpha(0.5 - (math.abs(offset)/5));
					self:draworder(0);
				end;		
			end;

		};

	end;

	t[#t+1] = s;

end;


return t
