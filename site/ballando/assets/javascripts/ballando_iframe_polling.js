function checkDocumentHeight(myIframeId) {
  var lastHeight = 0;
  (function run(){
    newHeight = $("body").innerHeight();
    if(lastHeight != newHeight) {

      try {
        window.parent.containerHeight(newHeight, myIframeId);
        lastHeight = newHeight;
      } catch(err) {
        lastHeight = 0;
      }
      
    }
    
    timer = setTimeout(run, 300);
  })();
}