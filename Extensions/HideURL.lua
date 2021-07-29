--[[<HCExtension>
@name			HideURL
@author			Faan
@version		18 Juli 2021 - v1.2
@description	Hide URL
@event			Init
@event 			BeforeViewInMonitor
</HCExtension>]]

function Init()
	hc_static.HideListVarGlobal = [[:5228|:443|^.*gwarnet\.com|watson\.telemetry\.microsoft\.com|ldmnq\.com|\/.*_204|facebook\.com\/(ajax\/|api\/graphql\/)|google\.[a-z]+\/complete\/search]]
	-- |_204|edge\-chat|\.*gwarnet\.com|\/youtubei\/v1\/log_event|facebook.com/api/graphql/|google.com/chrome-sync|facebook\.com\/ajax\/|data\.bilibili.com/log/|gstatic.com	
end

function BeforeViewInMonitor()
	if re.match(hc.url, hc_static.HideListVarGlobal) then
		hc.hide_in_active_list = true
		hc.hide_in_monitor = true
	end
end