--[[<HCExtension>
@name			Youtube Restricted Mode
@author			Faan
@version		Juli 2021 - v1.0
@description	Youtube Restrict mode with option button
@rule			youtube\.com
@event			Init
@event			RequestHeaderReceived/Run
@event			Options/Config
</HCExtension>]]

function Init()

	-- read Config
	local read = FileConfig('r')

	if read then

		local s
		local t = {}

		while true do
			s= read:read("*line")
			if s then table.insert(t, s) else break end
		end

		read:close()

		getstatus = re.find(t[1],'status=(.*)',1)
		if getstatus then
			hc_static['status'] = getstatus
		end

	end
end

function Run()

	if hc_static['status'] == 'ON' then
		ON()
	elseif hc_static['status'] == 'OFF' then --#
		OFF()
	end

end

-- on restricted
function ON()
	if re.match(hc.request_header, [[^Cookie]]) then
		hc.request_header = string.gsub(hc.request_header, 'PREF=', 'PREF=f2=8000000&')
	else
		hc.request_header = re.replace(hc.request_header, [[\r\n\r\n\]] , '\r\nCookie: PREF=f2=8000000\r\n\r\n')
	end
end

-- off restricted
function OFF()
	if re.match(hc.request_header, [[^Cookie]]) then
		hc.request_header = string.gsub(hc.request_header, 'f2=8000000', nil)
	end
end

-- UI Setting Interface

function Config()

	require "vcl"

	if Form then
		Form:Free()
		Form=nil
	end

	Form = VCL.Form('Form')
	x,y,w,h= hc.window_pos()
	Form._ = { Caption='Youtube Resticted Config', width=280, height=150, BorderStyle='Fixed3D' }
	Form._ = { left=x+(w-Form.width)/2, top=y+(h-Form.height)/2 }

	RG_25 = VCL.RadioGroup(Form, 'RG_25')
	RG_25._ = { Caption='Option', Top=10, Left=10, Height=100, Width=Form.Width-25, Hint='aaaaaa', ShowHint=true }

	button_ON = VCL.RadioButton(RG_25, 'button_ON')
	button_ON._ = { Caption='ON', Top=RG_25.top+15, Left=80, Width=RG_25.Width-30, Hint='ON', ShowHint=true, Checked=hc_static['status']=='ON' }

	button_OFF = VCL.RadioButton(RG_25, 'button_OFF')
	button_OFF._ = { Caption='OFF', Top=RG_25.top+15, Left=130, Width=RG_25.Width-30, Hint='OFF', ShowHint=true, Checked=hc_static['status']=='OFF' }	

	OkButton = VCL.Button(Form, "OkButton")
	OkButton._ = {onclick = "OkButton_Process", width=100, left=30, caption = "OK", top= Form.clientheight-OkButton.height-25}

	CancelButton = VCL.Button(Form, "CancelButton")
	CancelButton._ = {onclick = "CancelButton_Process", width=100, left=140, top=OkButton.top, caption = "Cancel"}	

	Form:ShowModal()
	Form:Free()
	Form=nil
end

function OkButton_Process(Sender)

	if button_ON.Checked then --#
		hc_static['status'] = 'ON'
	elseif button_OFF.Checked then --#
		hc_static['status'] = 'OFF'
	end

	Form:Close()

	Save_Process()
end

function CancelButton_Process(Sender)
	Form:Close() --#
end

function FileConfig(type)
	return assert(io.open(re.replace(hc.script_name, [[(.*\.).*]], [[\1ini]]), type))
end

function Save_Process()
	local read = FileConfig('w')

	if not read then return end

	read:write('status='..hc_static['status']..'\n')
	read:close()

	hc.put_msg(2 , 'Saved')
end