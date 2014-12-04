
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
  };
  
  function renderTagboxAlertDiv(str) {
  	return "<div class='alert alert-info' role='alert'>" + str + "</div>";
  };

function addButtonHandlerForJsonFields(modelName, fieldName) {
  	var counter = 1;

	$('#add-button-for-' + fieldName + '-fields').click(function (e) {
		e.preventDefault();

		jQuery('<div/>', {
			id: 'extra-fields-name-for-' + fieldName + '-' + counter,
			class: 'form-group'
		}).appendTo('#text-boxes-for-' + fieldName + '-fields');

		jQuery('<label/>', {
			class: 'text-input',
			text: 'Nome'
		}).appendTo('#extra-fields-name-for-' + fieldName + '-' + counter);

		jQuery('<input/>', {
			type: 'text',
		    id: 'name-for-' + fieldName + '-field-' + counter,
		    name: 'name-for-' + fieldName + '-field-' + counter,
		    class: 'form-control',
		    keyup: function() { updateValueElementName($(this), modelName, fieldName); }
		}).appendTo('#extra-fields-name-for-' + fieldName + '-' + counter);

		jQuery('<div/>', {
			id: 'extra-fields-value-for-' + fieldName + '-' + counter,
			class: 'form-group'
		}).appendTo('#text-boxes-for-' + fieldName + '-fields');

		jQuery('<label/>', {
			class: 'text-input',
			text: 'Valore'
		}).appendTo('#extra-fields-value-for-' + fieldName + '-' + counter);

		jQuery('<input/>', {
			type: 'text',
		    id: 'value-for-' + fieldName + '-field-' + counter,
		    name: 'empty-value',
		    class: 'form-control',
		}).appendTo('#extra-fields-value-for-' + fieldName + '-' + counter);

		$('#extra-fields-value-for-' + fieldName + '-' + counter).append('<br><a id = "remove-link-for-' + fieldName + '-field-' + counter + '" href="#" class="btn btn-primary btn-xs">Rimuovi</a>');

		counter++;
	});

	$('#text-boxes-for-' + fieldName + '-fields').on('click','.btn', function(e){
	  e.preventDefault();
	  id = $(this).attr('id').replace('remove-link-for-' + fieldName + '-field-','');
	  $('#extra-fields-name-for-' + fieldName + '-' + id).remove();
	  $('#extra-fields-value-for-' + fieldName + '-' + id).remove();
	  $(this).remove();
    });

  };

function updateValueElementName(elementName, modelName, fieldName) {
	id = '#value-for-' + fieldName + '-field-' + elementName.attr('id').replace('name-for-' + fieldName + '-field-','');
	relatedValueElement = $(id);
	fieldValue = elementName.val();

	if(fieldValue == "") {
		relatedValueElement.attr('name', 'empty-value');
		return;
	}

	relatedValueElement.attr('name', modelName + '[[' + fieldName + '][' + fieldValue + ']]');
  };