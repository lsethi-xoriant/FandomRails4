document.domain = "shado.tv";

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