--[[<HCExtension>
@name			Facebook [Init]
@author			Faan
@version		20 Juli 2021 - v1.0
@description	Facebook Manipulation answer_body
@rule			facebook\.com
@event	 		BeforeRequestHeaderSend
</HCExtension>]]

--|=== Integrate File
--| -----------------
--| - _Helper.lua
--| - Init.lua
--| 
--|=== Change Log :
--| --------------------
--| * v1.0 - 20 Juli 2021
--| - Created

require '_Helper'

local VarInit = hc.get_global('DataGlobal')

function BeforeRequestHeaderSend()
	-- if url contain in regexlist
	-- #message : add more path for manipulation data answer_body
	if re.find(hc.url,[[.........]]) then
		-- manipulation header Accept-Encoding value for the answer_body can be readed
		hc.request_header = re.replace(hc.request_header, [[[Aa]ccept\-[Ee]ncoding:\s\K[^\r\n]+]], 'gzip, deflate')
		-- Call BeforeAnswerBodySend for manipualtion answer_body
		hc.call_me_for('BeforeAnswerBodySend', 'BeforeAnswerBodySend')	
	end
end

function BeforeAnswerBodySend()
	VideoSingleURL() --#
	VideoQuality()
	VideoBuffer()
	VideoAutoPlayOFF()
	DarkMode()
	UserAgentFBLite()
	RemoveAds()
end

function VideoSingleURL()
end

function VideoQuality()
end

function VideoBuffer()
end

function VideoAutoPlayOFF()
end

function DarkMode()
end

function UserAgentFBLite()
end

function RemoveAds()
end