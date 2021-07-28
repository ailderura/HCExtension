--[[<HCExtension>
@name			RandomColor
@author			Faan
@version		Juli 2021 - v1.0
@description	WarnainLogURL
@event			BeforeViewInMonitor
</HCExtension>]]

function BeforeViewInMonitor()
	hc.monitor_text_color = math.random(50,255) * math.random(50,255)
end