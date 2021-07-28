Element.prototype.remove = function() {
	this.parentElement.removeChild(this);
}
NodeList.prototype.remove = HTMLCollection.prototype.remove = function() {
	for(var i = this.length - 1; i >= 0; i--) {
		if(this[i] && this[i].parentElement) {
			this[i].parentElement.removeChild(this[i]);
		}
	}
}

function WaitElDisplayDo(selector, callback, checkFrequencyInMs, timeoutInMs) {
	var startTimeInMs = Date.now();
	(function loopSearch() {
		if (document.querySelector(selector) != null) {
			callback();
			return;
		}
		else {
			setTimeout(function () {
				if (timeoutInMs && Date.now() - startTimeInMs > timeoutInMs)
					return;
				loopSearch();
			}, checkFrequencyInMs);
		}
	})();
}

WaitElDisplayDo("#masthead-ad",function(){
	document.getElementById("masthead-ad").remove(); 
},1000,9000);

document.addEventListener("DOMContentLoaded", function() {
	//remove tag by id
	setTimeout(function(){ 
		document.getElementById("masthead-ad").remove(); 
			
	}, 3000);
	
}); 