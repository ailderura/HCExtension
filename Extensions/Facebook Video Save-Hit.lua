--[[<HCExtension>
@name			Facebook Video [Save-Hit]
@author			Faan
@version		20 Juli 2021 - v1.0
@description	Save-Hit Facebook Video
@rule			fbcdn\.net\/v\/.*_n\.(mp4|webm)
@event 			URLToFileNameConverting
@event	 		RequestHeaderReceived
</HCExtension>]]

require 'Helper'

function RequestHeaderReceived()
	if Hit() == false then
		hc.call_me_for('AnswerHeaderReceived','Save')
	end
end

function Hit()
	-- cache exist and cache size > 0 
	-- #message : add other validation for best performance
	if isExist(hc.cache_file_name) == true and hc.cache_file_size > 0 then
		-- video as range
		if re.find(url, [[^.*(fbcdn\.net\/)v\/(.*)(\/.*)_n\.(mp4|webm)\?.*&bytestart=([0-9]+)&byteend=([0-9]+).*]]) then
			-- get value from previous re.find
			range_url_start = re.substr(5)
			range_url_end = re.substr(6)
			range_url_size = range_url_end - range_url_start + 1
			-- validation cache file size == range from url
			if hc.cache_file_size == range_url_size then
				ProcessHit('fb.hit.200')
				return true
			end
		-- video as norange		
		elseif re.find(url, [[^.*(fbcdn\.net\/)v\/(.*)(\/.*)_n\.(mp4|webm)\?.*]]) then --#
			ProcessHit('fb.hit.206')
			return true
		end
	end
	return false
end

function ProcessHit(log)
	hc.action = 'dont_update'
	hc.monitor_text_color = MonitorColor('blue')
	hc.monitor_string = Monitor(log)
	-- Call BeforeAnswerHeaderSend for manipulation hc.answer_header (cors inject)
	hc.call_me_for('BeforeAnswerHeaderSend','BeforeAnswerHeaderSend')
end

function BeforeAnswerHeaderSend()
	new_answer_header = RewriteAnswerHeader({ --#
		['del_last_modified'] = true,
		['del_server'] = true,	
		['add_cache_control'] = true,
		['add_cors'] = true
	}) --#
	-- cors for facebook #required & important, prevent error when load content from cache
	build_header = 'Access-Control-Allow-Origin: *\r\n'
	build_header = build_header..'timing-allow-origin: *\r\n'		
	-- set hc.answer_header with new_answer_header
	hc.answer_header = re.replace(new_answer_header, [[\r\n\r\n]], '\r\n'..build_header..'\r\n')
	-- #debugging
	-- hc.monitor_string = Monitor('cors.inject')
end

function Save()

	getparams = parseurl(hc.url)
	param_bytestart = getparams['bytestart']
	param_byteend = getparams['byteend']

	if param_bytestart and param_byteend then
		ProcessSave('fb.save.200') --#
	elseif not param_bytestart and not param_byteend then --#
		if isContentRangeStart(hc.answer_header) then --# single video
			ProcessSave('fb.save.206')
		else
			hc.monitor_string = Monitor('fb.skip.206')
			hc.monitor_text_color = MonitorColor('blue')
		end			
	end
end

function ProcessSave(log)
	hc.monitor_string = Monitor(log)
	hc.monitor_text_color = MonitorColor('green')
	hc.action = 'save'
end

function URLToFileNameConverting()
	-- extract url
	getparams = parseurl(hc.url)
	param_bytestart = getparams['bytestart']
	param_byteend = getparams['byteend']	
	-- if exist param bytestart and byteend = range
	if param_bytestart and param_byteend then
		extract_url = re.find(hc.url, [[^.*(fbcdn\.net\/)v\/(.*)(\/.*)_n\.(mp4|webm)\?.*&bytestart=([0-9]+)&byteend=([0-9]+).*]]) --#
		new_file = 'range/'..re.substr(2)..re.substr(3)..re.substr(3)..'_'..re.substr(5)..'-'..re.substr(6) --#
	-- if exist param bytestart and byteend = single
	elseif not param_bytestart and not param_byteend then --#
		extract_url = re.find(hc.url, [[^.*(fbcdn\.net\/)v\/(.*)(\/.*)_n\.(mp4|webm)\?.*]]) --#
		new_file = 'single/'..re.substr(2)..re.substr(3)..re.substr(3)..'.'..re.substr(4) --#
	end
	hc.preform_cache_file_name(hc.cache_path..'_FBVIDEO\\'..hc.prepare_url(new_file))	
end