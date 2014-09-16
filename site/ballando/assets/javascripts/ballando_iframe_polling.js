function setBallandoDomain() {
	String.prototype.endsWith = function(suffix) {
	    return this.indexOf(suffix, this.length - suffix.length) !== -1;
	};
	var index;
	var domains = ["fandomlab.com", "ballando.rai.it", "shado.tv"];
	for (index = 0; index < domains.length; ++index) {
		if (window.location.host.endsWith(domains[index])) {
			console.log("domain set to: " + domains[index]);
	    	document.domain = domains[index];
		}
	}
}
setBallandoDomain();

function checkDocumentHeight(){
  var lastHeight = $("body").innerHeight(), newHeight, timer;
  (function run(){
    newHeight = $("body").innerHeight();
    if(lastHeight != newHeight) {
      window.parent.containerHeight(newHeight);
    }
    lastHeight = newHeight;
    timer = setTimeout(run, 300);
  })();
}

checkDocumentHeight(); 