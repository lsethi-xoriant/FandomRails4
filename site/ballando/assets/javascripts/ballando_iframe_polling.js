function checkDocumentHeight(myIframeId) {
  var lastHeight = 0;
  (function run(){
    newHeight = $("body").innerHeight();
    if(lastHeight != newHeight) {
      window.parent.containerHeight(newHeight, myIframeId);
    }
    lastHeight = newHeight;
    timer = setTimeout(run, 300);
  })();
}