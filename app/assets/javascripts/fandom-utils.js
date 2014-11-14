
  function showTagboxAlert(idTextField, unactiveTagsName, allTagsName, newTagMessage) {

  	values = $(idTextField).select2("val");

  	unactiveTagsSelected = intersect(values, unactiveTagsName);
  	if(unactiveTagsSelected.length > 0) {
	  var unactiveTagMessageDiv = $(renderTagboxAlertDiv("Attenzione: tag '" + unactiveTagsSelected + "' non attivo/i"));
	  var unactiveTagMsgHasChanged = true;
  	}

  	existentTagsSelected = intersect(values, allTagsName);
  	if((existentTagsSelected.length != values.length) & !unactiveTagMsgHasChanged) {
  	  var newTagMessageDiv = $(renderTagboxAlertDiv(newTagMessage));
  	}

    var unactiveTagMsgHasChanged = false;
    $(idTextField + "_message").empty().append(unactiveTagMessageDiv, newTagMessageDiv);
  };

  function intersect(a, b) {
    var t;
    if (b.length > a.length) t = b, b = a, a = t; // indexOf to loop over shorter
    return a.filter(function (e) {
        if (b.indexOf(e) !== -1) return true;
    });
  }
  
  function renderTagboxAlertDiv(str) {
  	return "<div class='alert alert-info' role='alert'>" + str + "</div>";
  }