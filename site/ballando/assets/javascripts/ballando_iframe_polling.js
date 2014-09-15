document.domain = "shado.tv";

function checkDocumentHeight(){
  var lastHeight = $("body").height(), newHeight, timer;
  (function run(){
    newHeight = $("body").height();
    if(lastHeight != newHeight) {
      window.parent.containerHeight(newHeight);
    }
    lastHeight = newHeight;
    timer = setTimeout(run, 300);
  })();
}

checkDocumentHeight(); 