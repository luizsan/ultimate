function MouseOverElement(elem, range)
	local radius;
	if range == nil then radius = 0.8; else radius = range end;

	if Global.mouseX >= elem:GetX() - (elem:GetWidth()*elem:GetZoomX()*radius) and
	   Global.mouseX <= elem:GetX() + (elem:GetWidth()*elem:GetZoomX()*radius) and
	   Global.mouseY >= elem:GetY() - (elem:GetHeight()*elem:GetZoomY()*radius) and 
	   Global.mouseY <= elem:GetY() + (elem:GetHeight()*elem:GetZoomY()*radius) then
		return true;
	else
		return false;
	end
end;


function ButtonLeftClick(self,ID,range)
	if ButtonHover(self,ID,range) then
		self:stoptweening();
		self:glow(1,1,1,1);
		self:linear(0.2)
		self:glow(1,1,1,0);
		Global.screen = SCREENMAN:GetTopScreen():GetName();
		NavigationAction(ID);
	end;
end;	

function NavigationAction(index)
	if GAMESTATE:GetNumSidesJoined() == 0 then
		GAMESTATE:JoinPlayer(PLAYER_1);
	end;
	SCREENMAN:SetNewScreen(GlobalNavigation.Screen[index]);
end;

function ButtonHover(self,ID,range)
	--if ID == "Reload" and Global.screen == "ScreenSelectMusicCustom" then
	--	self:playcommand("Disabled")
	--	return false;
	--else
		if MouseOverElement(self,range) then
			self:playcommand("GainFocus");
			return true;
		else
			self:playcommand("LoseFocus");
			return false;
		end;
	--end;
end;	
