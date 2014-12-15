
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


function getButtonHandlerForJsonFieldsName(fieldName) {
    return  'text-boxes-for-' + fieldName + '-fields';	
}

function addButtonHandlerForJsonFields(modelName, fieldName) {
	var elementRemoved = 0;

	$('#add-button-for-' + fieldName + '-fields').click(function (e) {
		e.preventDefault();
		var counter = $('#text-boxes-for-' + fieldName + '-fields').children().length + 1 + elementRemoved;
		addFieldElements(modelName, fieldName, counter, true);
	});

	$('#text-boxes-for-' + fieldName + '-fields').on('click','.btn', function(e){
	  e.preventDefault();
	  $(this).parent().remove();
	  elementRemoved++;
    });
  };

function addFieldElements(modelName, fieldName, counter, addRemoveButton) {
  	var containerDivId = getButtonHandlerForJsonFieldsName(fieldName);

  		jQuery('<div/>', {
  			id: 'extra-fields-for-' + fieldName + '-' + counter
  		}).appendTo('#' + containerDivId);

  		jQuery('<div/>', {
			id: 'extra-fields-name-for-' + fieldName + '-' + counter,
			class: 'form-group col-lg-5'
		}).appendTo('#extra-fields-for-' + fieldName + '-' + counter);

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
			class: 'form-group col-lg-5'
		}).appendTo('#extra-fields-for-' + fieldName + '-' + counter);

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

		if(addRemoveButton != false) {
			$('#extra-fields-for-' + fieldName + '-' + counter).append('<label id ="remove-button-label-for-' + fieldName + '-field-' + counter + '" class="col-lg-2">Elimina</label>');
			$('#extra-fields-for-' + fieldName + '-' + counter).append('<a id = "remove-link-for-' + fieldName + '-field-' + counter + '" href="#" class="col-lg-1 btn btn-primary btn-xs">Rimuovi</a>');
  		}
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
  
function populateTextboxWithJsonField(json_field, mandatory_fields, formName, modelName, fieldName) {
	var index = 0;
	addMandatoryFieldsElements(mandatory_fields, modelName, fieldName);

	Object.keys(json_field).forEach(function (key) { 
		var value = json_field[key];
	  	if (mandatory_fields != null && mandatory_fields.indexOf(key) >= 0) {
	    	$('#value-for-' + fieldName + '-field-' + key).val(value);
	    }
	    else {
	        index++;
	  		addFieldElements(modelName, fieldName, index, true);
	        $('#name-for-' + fieldName + '-field-' + index).val(key);
	        updateValueElementName($("#name-for-" + fieldName + "-field-" + index), modelName, fieldName);
	        $('#value-for-' + fieldName + '-field-' + index).val(value);
	    }
	});
    addButtonHandlerForJsonFields(modelName, fieldName);
    
    $('#' + formName).submit(function (){
        if($('input[name^=' + modelName + '\\[\\[' + fieldName + '\\]]').length == 0)
        	$('#text-boxes-for-' + fieldName + '-fields').append('<input type="hidden" id="value-for-' + fieldName + '-field-0" name="' + modelName + '[' + fieldName + ']" value="{}">');
    });
};

function initializeTextbox(mandatory_fields, formName, modelName, fieldName) {
	addMandatoryFieldsElements(mandatory_fields, modelName, fieldName);
    addButtonHandlerForJsonFields(modelName, fieldName);
    
    $('#' + formName).submit(function (){
        if($('input[name^=' + modelName + '\\[\\[' + fieldName + '\\]]').length == 0)
        	$('#text-boxes-for-' + fieldName + '-fields').append('<input type="hidden" id="value-for-' + fieldName + '-field-0" name="' + modelName + '[' + fieldName + ']" value="{}">');
    });
};

function addMandatoryFieldsElements(mandatory_fields, modelName, fieldName) {
	if (mandatory_fields == null)
		return;

	mandatory_fields.forEach(function(mandatory_field) {
			addFieldElements(modelName, fieldName, mandatory_field, false);
	        $('#name-for-' + fieldName + '-field-' + mandatory_field).val(mandatory_field).attr('readonly', true);
	        updateValueElementName($("#name-for-" + fieldName + "-field-" + mandatory_field), modelName, fieldName);
	        $('#value-for-' + fieldName + '-field-' + mandatory_field).val(null);
	});
};
