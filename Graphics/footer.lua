local t = Def.ActorFrame{}

t[#t+1] = LoadActor(THEME:GetPathG("","border"))..{
	InitCommand=cmd(vertalign,top;y,-38;zoom,0.445;diffuse,0.8,0.8,0.8,1);
};

--draw them regardless if the player is joined or not
for pn in ivalues({PLAYER_1,PLAYER_2}) do
	
	t[#t+1] = LoadActor(THEME:GetPathG("","profileslot"))..{
		InitCommand=cmd(vertalign,bottom;horizalign,left;y,-1;x,317*pnSide(pn);zoomy,0.445;zoomx,-0.445*pnSide(pn);playcommand,"Refresh");
	};

	--minilabel
	t[#t+1] = LoadFont("regen silver")..{
		InitCommand=cmd(vertalign,bottom;y,-26;x,279*pnSide(pn);horizalign,pnAlign(OtherPlayer[pn]);zoom,0.28;diffuse,PlayerColor(pn));
		OnCommand=cmd(playcommand,"Refresh");
		PlayerJoinedMessageCommand=cmd(playcommand,"Refresh");
		RefreshCommand=function(self)
			if pn == PLAYER_1 then
				self:settext("P1");
			elseif pn == PLAYER_2 then
				self:settext("P2");
			end;

			if SideJoined(pn) then
				if IsRoutine() and Global.master ~= pn then
					self:diffusealpha(0.33); 
				else
					self:diffusealpha(1)
				end;
			else 
				self:diffusealpha(0.33); 
			end;

		end;
	};
end;



for pn in ivalues(GAMESTATE:GetHumanPlayers()) do

--player name
t[#t+1] = LoadFont("neotech")..{
	InitCommand=cmd(vertalign,bottom;y,-34;x,147*pnSide(pn);horizalign,pnAlign(OtherPlayer[pn]);zoom,0.444;strokecolor,0.15,0.15,0.15,0.4;settext,"Absent");
	OnCommand=cmd(playcommand,"Refresh");
	PlayerJoinedMessageCommand=cmd(playcommand,"Refresh");
	RefreshCommand=function(self)
		if SideJoined(pn) then
			if IsRoutine() and Global.master ~= pn then
				self:settext("");
			else
				local name = PROFILEMAN:GetProfile(pn):GetDisplayName();
				if name == "" then
					self:diffusealpha(0.33);
					self:settext("No Profile");
				else
					self:diffusealpha(1)
					self:settext(name);
				end;
			end;
		else 
			self:diffusealpha(0.33); 
			self:settext("");
		end
	end;
};


--highlight
t[#t+1] = LoadActor(THEME:GetPathG("","profileslot"))..{
	InitCommand=cmd(vertalign,bottom;horizalign,left;y,-1;x,317*pnSide(pn);zoomy,0.445;zoomx,-0.445*pnSide(pn);blend,Blend.Add;diffuse,PlayerColor(pn);diffusealpha,0);
	FocusCommand=function(self)
		if Global.confirm[pn] == 1 then
			self:stoptweening();
			self:decelerate(0.25);
			self:diffuse(PlayerColor(pn));
			self:diffusealpha(1);
		else
			self:stoptweening();
			self:decelerate(0.25);
			self:diffusealpha(0);
		end;
	end;

	MainMenuMessageCommand=cmd(playcommand,"Focus");
	StateChangedMessageCommand=cmd(playcommand,"Focus");
	NoteskinSelectedMessageCommand=cmd(playcommand,"Focus");
	StepsSelectedMessageCommand=cmd(playcommand,"Focus");
	DeselectMessageCommand=cmd(playcommand,"Focus");
	DecisionMessageCommand=cmd(playcommand,"Focus");
	FinalDecisionMessageCommand=cmd(playcommand,"Focus");

};

end;


return t