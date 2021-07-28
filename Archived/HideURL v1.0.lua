--[[ <HCExtension>
@name			HideURL
@author			Faan
@version		Juli 2021 - v1.0
@description 	Hide :443 from Monitor Log
@rule			^https://.*?:443
@event			BeforeViewInMonitor
</HCExtension> ]]

function BeforeViewInMonitor()
	hc.hide_in_active_list = true
	hc.hide_in_monitor = true
end