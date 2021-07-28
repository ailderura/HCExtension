--[[<HCExtension>
@name			HideURL
@author			Faan
@version		18 Juli 2021 - v1.1
@description	Hide URL
@event			Init
@event 			BeforeViewInMonitor
</HCExtension>]]

--|=== Integrate File
--| -----------------
--| - Init.lua
--| 
--|=== Change Log :
--| ---------------
--| * v1.0 - Juli 2021
--| - Created
--| * v1.1 - 18 Juli 2021
--| - Change to New Method
--| - optimize code

local VarInit = hc.get_global('DataGlobal')

function BeforeViewInMonitor()
	if re.match(hc.url, VarInit['HideListVarGlobal']) then
		hc.hide_in_active_list = true
		hc.hide_in_monitor = true
	end
end