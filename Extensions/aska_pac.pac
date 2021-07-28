function FindProxyForURL(url, host) {
	
	if (isPlainHostName(host)) {
		return "DIRECT";
	}
	
	if (shExpMatch(url, "https:*")) {

		var bypass = new Array(
			"*ggpht.com*",
			"*android.clients.google.com*",
			"*play.google.com*"
			);

		for (var i = 0; i < bypass.length; i++){
			var value = bypass[i];
			if (shExpMatch(url, value) ) {
				return DIRECT;
			}
		}

		return "PROXY 192.168.2.10:9669; DIRECT";	
	}
}