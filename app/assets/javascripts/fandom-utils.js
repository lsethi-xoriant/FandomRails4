function showTagboxAlert(idTextField, unactiveTagsName, allTagsName, newTagMessage) {

  values = $(idTextField).select2("val");

  unactiveTagsSelected = intersect(values, unactiveTagsName);
  if(unactiveTagsSelected.length > 0) {
      var unactiveTagMessageDiv = $(renderTagboxAlertDiv("Attenzione: tag '" + unactiveTagsSelected + "' non attivo/i"));
  }

  existentTagsSelected = intersect(values, allTagsName);
  if(existentTagsSelected.length != values.length) {
      var newTagMessageDiv = $(renderTagboxAlertDiv(newTagMessage));
  }

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

function fillInputWithSlug(srcInputElement, destInputElement) {
  var nameManuallyModified = false;

  srcInputElement.on('input', function() { 
    if (!nameManuallyModified) {
      var text = this.value;
      text = text.toLowerCase();
      text = text.replace(/[^a-zA-Z0-9]+/g,'-').replace(/-+/g,'-').replace(/-$/g,'').replace(/^-/g,'');
      destInputElement.val(text);
    }
  });

  destInputElement.keyup(function() {
    nameManuallyModified = true;
    if (destInputElement.val() == "")
      nameManuallyModified = false;
  });
};

function getButtonHandlerForJsonFieldsName(fieldName) {
  return 'text-boxes-for-' + fieldName + '-fields';  
};

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
        id: 'extra-fields-for-' + fieldName + '-' + counter,
        class: 'row'
    }).appendTo('#' + containerDivId);

    // *** NAME *** //
    jQuery('<div/>', {
        id: 'extra-fields-name-for-' + fieldName + '-' + counter,
        class: 'form-group col-lg-4'
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
        change: function() {
            updateValueElementName($(this), modelName, fieldName, 'value');
            updateValueElementName($(this), modelName, fieldName, 'type');
            updateValueElementName($(this), modelName, fieldName, 'attachment-id');
            updateValueElementName($(this), modelName, fieldName, 'url');
        }
    }).appendTo('#extra-fields-name-for-' + fieldName + '-' + counter);

    // *** TYPE *** //
    jQuery('<div/>', {
        id: 'extra-fields-type-for-' + fieldName + '-' + counter,
        class: 'form-group'
    }).appendTo('#extra-fields-name-for-' + fieldName + '-' + counter);

    jQuery('<label/>', {
        class: 'text-input',
        text: 'Tipo'
    }).appendTo('#extra-fields-type-for-' + fieldName + '-' + counter);

    jQuery('<select/>', {
        id: 'type-for-' + fieldName + '-field-' + counter,
        class: 'form-control',
        change: function() { updateValueElementType($(this), fieldName); }
    }).appendTo('#extra-fields-type-for-' + fieldName + '-' + counter);

    $('#type-for-' + fieldName + '-field-' + counter).append('<option value = "string">STRINGA</option>');
    $('#type-for-' + fieldName + '-field-' + counter).append('<option value = "media">UPLOAD</option>');
    $('#type-for-' + fieldName + '-field-' + counter).append('<option value = "html">HTML</option>');
    //$('#type-for-' + fieldName + '-field-' + counter).append('<option value = "boolean">BOOLEANO</option>');
    //$('#type-for-' + fieldName + '-field-' + counter).append('<option value = "integer">INTERO</option>');
    //$('#type-for-' + fieldName + '-field-' + counter).append('<option value = "date">DATA</option>');

    // *** VALUE *** //
    jQuery('<div/>', {
        id: 'extra-fields-value-for-' + fieldName + '-' + counter,
        class: 'form-group col-lg-6'
    }).appendTo('#extra-fields-for-' + fieldName + '-' + counter);

    jQuery('<label/>', {
        class: 'text-input',
        text: 'Valore'
    }).appendTo('#extra-fields-value-for-' + fieldName + '-' + counter);

    divElement = jQuery('<div/>', {
        id: 'extra-fields-value-div-for-' + fieldName + '-' + counter,
    }).appendTo('#extra-fields-value-for-' + fieldName + '-' + counter);

    jQuery('<input/>', {
        type: 'text', // default
        id: 'value-for-' + fieldName + '-field-' + counter,
        name: 'empty-value',
        class: 'form-control',
        change: function() { removeImage($(this), fieldName); }
    }).appendTo('#extra-fields-value-div-for-' + fieldName + '-' + counter);

    // *** REMOVE *** //
    if(addRemoveButton != false) {
        $('#extra-fields-for-' + fieldName + '-' + counter).append('<label id ="remove-button-label-for-' + fieldName + '-field-' + counter + '" class="col-lg-2">Elimina</label>');
        $('#extra-fields-for-' + fieldName + '-' + counter).append('<a id = "remove-link-for-' + fieldName + '-field-' + counter + '" href="#" class="col-lg-1 btn btn-primary btn-sm">Rimuovi</a>');
    }
};

function updateValueElementName(elementName, modelName, fieldName, inputBoxKind) {
    id = '#' + inputBoxKind + '-for-' + fieldName + '-field-' + elementName.attr('id').replace('name-for-' + fieldName + '-field-','');
    relatedValueElement = $(id);
    fieldValue = elementName.val();

    if(fieldValue == "") {
        relatedValueElement.attr('name', 'empty-value');
        return;
    }

    relatedValueElement.attr('name', modelName + '[[' + fieldName + '][' + fieldValue + '][' + inputBoxKind + ']]');
};

function updateValueElementType(elementName, fieldName) {
    identifier = elementName.attr('id').replace('type-for-' + fieldName + '-field-','');
    id = '#value-for-' + fieldName + '-field-' + identifier;
    relatedValueElement = $(id);
    selectedType = elementName.val();
    if (selectedType == 'media') {
        //relatedValueElement.jqte({status:false});
        $('#extra-fields-value-div-for-' + fieldName + '-' + identifier).children('img').show();
        relatedValueElement.attr('type', 'text');
        relatedValueElement.attr('type', 'file');
    }
    if (selectedType == 'string') {
        //relatedValueElement.jqte({status:false});
        $('#extra-fields-value-div-for-' + fieldName + '-' + identifier).children('img').hide();
        $('#attachment-id-for-' + fieldName + '-field-' + identifier).remove();
        $('#url-for-' + fieldName + '-field-' + identifier).remove();
        relatedValueElement.attr('type', 'text');
    }
    if (selectedType == 'html') {
      relatedValueElement.attr('type', 'text');
      //relatedValueElement.jqte();
      //relatedValueElement.jqte({status:true});
    }

};

function removeImage(elementName, fieldName) {
    identifier = elementName.attr('id').replace('value-for-' + fieldName + '-field-','');
    $('#extra-fields-value-div-for-' + fieldName +  '-' + identifier).children('img').remove();
};

function populateTextboxWithJsonField(json_field, mandatory_fields, formName, modelName, fieldName) {
    var index = 0;
    mandatory_fields = null; // we don't need them
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
            updateValueElementName($('#name-for-' + fieldName + '-field-' + index), modelName, fieldName, 'value');
            updateValueElementName($('#name-for-' + fieldName + '-field-' + index), modelName, fieldName, 'type');
            if (typeof value == 'string') {
                $('#type-for-' + fieldName + '-field-' + index).val('string');
                $('#value-for-' + fieldName + '-field-' + index).attr('type', 'text');
                $('#value-for-' + fieldName + '-field-' + index).val(value);
            }
            else
            if (value.type == 'media')  {
                $('#type-for-' + fieldName + '-field-' + index).val('media');
                $('#value-for-' + fieldName + '-field-' + index).attr('type', 'file');

                old_attachment_id_input = jQuery('<input/>', {
                  id : 'attachment-id-for-' + fieldName + '-field-' + index,
                  name : modelName + '[[' + fieldName + '][' + fieldValue + '][attachment_id]]',
                  style : 'display: none;'
                }).val(value.attachment_id);

                old_url_input = jQuery('<input/>', {
                  id : 'url-for-' + fieldName + '-field-' + index,
                  name : modelName + '[[' + fieldName + '][' + fieldValue + '][url]]',
                  style : 'display: none;'
                }).val(value.url);

                $('#extra-fields-value-div-for-' + fieldName + '-' + index).append(old_attachment_id_input).append(old_url_input);

                jQuery('<img/>', {
                    src: value.url,
                    heigth: '30%',
                    width: '30%'
                }).prependTo('#extra-fields-value-div-for-' + fieldName + '-' + index);
            }
            else { // html
                $('#type-for-' + fieldName + '-field-' + index).val('html');
                $('#value-for-' + fieldName + '-field-' + index).attr('type', 'text');
                $('#value-for-' + fieldName + '-field-' + index).val(value.value);
                //$('#value-for-' + fieldName + '-field-' + index).jqte();
                //$('#value-for-' + fieldName + '-field-' + index).jqteVal(value.value);
            }
        }
    });
    addButtonHandlerForJsonFields(modelName, fieldName);
};

function initializeTextboxWithJsonField(json_field, mandatory_fields, formName, modelName, fieldName) {
    if(json_field != null) // for cloning
        populateTextboxWithJsonField(json_field, mandatory_fields, formName, modelName, fieldName);
    else {
        addMandatoryFieldsElements(mandatory_fields, modelName, fieldName);
        addButtonHandlerForJsonFields(modelName, fieldName);
    }
};

function addMandatoryFieldsElements(mandatory_fields, modelName, fieldName) {
    if (mandatory_fields == null)
        return;

    mandatory_fields.forEach(function(mandatory_field) {
        addFieldElements(modelName, fieldName, mandatory_field, false);
        $('#name-for-' + fieldName + '-field-' + mandatory_field).val(mandatory_field).attr('readonly', true);
        updateValueElementName($("#name-for-" + fieldName + "-field-" + mandatory_field), modelName, fieldName, 'value');
        $('#value-for-' + fieldName + '-field-' + mandatory_field).val(null);
    });
};

function addButtonHandlerForInteractionCallToActionFields(fieldName, linkedCta) {
  var elementRemoved = 0;
  $('#add-button-for-' + fieldName + '-fields').click(function(e) {
    e.preventDefault();
    var counter = $('#text-boxes-for-' + fieldName + '-fields').children().length + 1 + elementRemoved;
      addInteractionCallToActionFieldElements(fieldName, null, counter, true);
  });

  $('#text-boxes-for-' + fieldName + '-fields').on('click','.btn', function(e) {
    e.preventDefault();
    $(this).parent().remove();
    elementRemoved++;
  });

  if(linkedCta != null) {
    cnt = 1;
    linkedCta.forEach(function(ctaId) {
      addInteractionCallToActionFieldElements(fieldName, ctaId, cnt, true)
      cnt += 1;
    });
  };

};

function addInteractionCallToActionFieldElements(fieldName, icta, counter, addRemoveButton) {
  attributeIndex = fieldName.substring(fieldName.indexOf("-") + 1, fieldName.length)

  jQuery('<div/>', {
    id: 'extra-fields-for-' + fieldName + '-' + counter,
    class: 'row'
  }).appendTo('#text-boxes-for-' + fieldName + '-fields');

  // *** CONDITION *** //
  jQuery('<div/>', {
    id: 'extra-fields-condition-for-' + fieldName + '-' + counter,
    class: 'form-group col-lg-3'
  }).appendTo('#extra-fields-for-' + fieldName + '-' + counter);

  jQuery('<label/>', {
    class: 'text-input',
    text: 'Condition'
  }).appendTo('#extra-fields-condition-for-' + fieldName + '-' + counter);

  conditionSelect = jQuery('<select/>', {
    id: 'condition-for-' + fieldName + '-field-' + counter,
    name: 'call_to_action[interactions_attributes][' + attributeIndex + '][resource_attributes][linked_cta][' + counter + '][condition]',
    class: 'form-control'
  }).appendTo('#extra-fields-condition-for-' + fieldName + '-' + counter);

  $('#condition-for-' + fieldName + '-field-' + counter).append('<option value = "A">A</option>');
  $('#condition-for-' + fieldName + '-field-' + counter).append('<option value = "B">B</option>');
  $('#condition-for-' + fieldName + '-field-' + counter).append('<option value = "C">C</option>');
  $('#condition-for-' + fieldName + '-field-' + counter).append('<option value = "D">D</option>');

  // *** CALL TO ACTION ID *** //
  jQuery('<div/>', {
    id: 'extra-fields-cta-id-for-' + fieldName + '-' + counter,
    class: 'form-group col-lg-3'
  }).appendTo('#extra-fields-for-' + fieldName + '-' + counter);

  jQuery('<label/>', {
    class: 'text-input',
    text: 'ID CTA'
  }).appendTo('#extra-fields-cta-id-for-' + fieldName + '-' + counter);

  ctaIdInput = jQuery('<input/>', {
    type: 'text',
    id: 'cta-id-for-' + fieldName + '-field-' + counter,
    name: 'call_to_action[interactions_attributes][' + attributeIndex + '][resource_attributes][linked_cta][' + counter + '][cta_id]',
    class: 'form-control col-lg-3'
  }).appendTo('#extra-fields-cta-id-for-' + fieldName + '-' + counter);

  if(icta != null) {
    ctaIdInput.val(icta[0]);
    conditionSelect.val(icta[1]);
  }

  // *** REMOVE *** //
  if(addRemoveButton != false) {
    $('#extra-fields-for-' + fieldName + '-' + counter).append('<label id ="remove-button-label-for-' + fieldName + '-field-' + counter + '" class="col-lg-6">Elimina</label>');
    $('#extra-fields-for-' + fieldName + '-' + counter).append('<a id = "remove-link-for-' + fieldName + '-field-' + counter + '" href="#" class="col-lg-1 btn btn-primary btn-xs">Rimuovi</a>');
  }

};