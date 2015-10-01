// Easyadmin call to action forms methods //

function add_fields(link, association, content, resource) {
  switch(resource) {
    case "play":
    case "share":
    case "comment":
    case "like":
    case "upload":
    case "vote":
    case "random":
    case "instantwin":
      if(!window[resource + "_counter"]) {
        window[resource + "_counter"] = true;
        var new_id = new Date().getTime();
        var regexp = new RegExp("new_" + association, "g");
        $("#tmp-" + resource + "-add").prepend(content.replace(regexp, new_id));
      }
      break;
    default:
      var new_id = new Date().getTime();
      var regexp = new RegExp("new_" + association, "g");
      $("#tmp-" + resource + "-add").prepend(content.replace(regexp, new_id));
  }
}

function add_answer_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g");
  $(link).parent().parent().parent().parent().find(".answers-container").prepend(content.replace(regexp, new_id));

  $(".answer-media-type").each(function(i, obj) {
    updateMedia(obj);
  });
}

function remove_fields(link, resource) {
  switch(resource) {
    case "check":
    case "download":
    case "quiz":
    case "versus":
    case "contest":
    case "pin":
      $(link).parent().parent().parent().remove();
      break;
    case "answer_quiz":
      $(link).parent().parent().parent().parent().remove();
      break;
    case "like":
      $(link).parent().parent().parent().remove();
      like_counter = false;
      break;
    case "play":
      $(link).parent().parent().parent().remove();
      play_counter = false;
      break;
    case "comment":
      $(link).parent().parent().parent().remove();
      comment_counter = false;
      break;
    case "share":
      $(link).parent().parent().parent().remove();
      share_counter = false;
      break;
    case "upload":
      $(link).parent().parent().parent().remove();
      upload_counter = false;
      break;
    case "vote":
      $(link).parent().parent().parent().remove();
      vote_counter = false;
      break;
    case "random":
      $(link).parent().parent().parent().remove();
      random_counter = false;
      break;
    case "instantwin":
      $(link).parent().parent().parent().remove();
      instantwin_counter = false;
      break;
    default:
      $(link).closest(".panel-" + resource).remove();
  }
}

// Tagbox alert message //

function showTagboxAlert(idTextField, unactiveElementsName, allElementsName, newElementMessage) {

  values = $(idTextField).select2("val");

  unactiveTagsSelected = intersect(values, unactiveElementsName);
  if(unactiveTagsSelected.length > 0) {
    var unactiveElementMessageDiv = $(renderTagboxAlertDiv("Attenzione: '" + unactiveTagsSelected + "' non attivo/a"));
  }

  existentTagsSelected = intersect(values, allElementsName);
  if(existentTagsSelected.length != values.length) {
    var newElementMessageDiv = $(renderTagboxAlertDiv(newElementMessage));
  }

  $(idTextField + "_message").empty().append(unactiveElementMessageDiv, newElementMessageDiv);
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

// Slug automatic compilation //

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

// Input replacement //

function substituteValue(inputElement, oldValue, newValue) {
  inputElement.on('input', function() { 
    var text = this.value;
    text = text.replace(oldValue, newValue);
    inputElement.val(text);
  });
};

// Extra fields //

// Adds the "add json field" button and the click handler
function addButtonHandlerForJsonFields(modelName, fieldName) {
  var elementRemoved = 0;

  $('#add-button-for-' + fieldName + '-fields').click(function (e) {
    e.preventDefault();
    var counter = $('#text-boxes-for-' + fieldName + '-fields').children().length + 1 + elementRemoved;
      addFieldElements(modelName, fieldName, counter, true);
  });

  $('#text-boxes-for-' + fieldName + '-fields').on('click','.btn', function(e) {
    e.preventDefault();
    $(this).parent().remove();
    elementRemoved++;
  });
};

// Adds all the field dom elements (divs, labels and inputs)
function addFieldElements(modelName, fieldName, counter, addRemoveButton) {
  var containerDivId = getButtonHandlerForJsonFieldsName(fieldName);

  jQuery('<div/>', {
    id: 'extra-fields-for-' + fieldName + '-' + counter,
    class: 'row'
  }).prependTo('#' + containerDivId);

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

  $('#type-for-' + fieldName + '-field-' + counter)
    .append('<option value = "string">STRINGA</option>', '<option value = "media">UPLOAD</option>', '<option value = "html">HTML</option>', 
      '<option value = "boolean">BOOLEANO</option>', '<option value = "date">DATA</option>');
  
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

  jQuery('<input/>', { id: 'value-for-' + fieldName + '-field-' + counter, class: 'form-control' })
    .appendTo('#extra-fields-value-div-for-' + fieldName + '-' + counter);

  buildValueElement('value-for-' + fieldName + '-field-' + counter, 'string');

  // *** REMOVE *** //
  if(addRemoveButton != false) {
    $('#extra-fields-for-' + fieldName + '-' + counter).append('<label id="remove-button-label-for-' + fieldName + '-field-' + counter + '" class="col-lg-2">Elimina</label>');
    $('#extra-fields-for-' + fieldName + '-' + counter).append('<a id="remove-link-for-' + fieldName + '-field-' + counter + '" href="#" class="col-lg-1 btn btn-primary btn-sm">Rimuovi</a>');
  }
};

// Sets dom value element name following Rails conventions according to input name
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

// Sets dom value element type according to input type and adds image visualization if selected type is "media"
function updateValueElementType(elementName, fieldName) {
  identifier = elementName.attr('id').replace('type-for-' + fieldName + '-field-','');
  id = 'value-for-' + fieldName + '-field-' + identifier;
  relatedValueElement = $("#" + id);
  selectedType = elementName.val();
  if(selectedType == 'media') {
    $('#extra-fields-value-div-for-' + fieldName + '-' + identifier).children('img').show();
  }
  else {
    $('#extra-fields-value-div-for-' + fieldName + '-' + identifier).children('img').hide();
    $('#attachment-id-for-' + fieldName + '-field-' + identifier).remove();
    $('#url-for-' + fieldName + '-field-' + identifier).remove();
  }
  buildValueElement(id, selectedType);
};

function buildValueElement(elementId, selectedType) {

  oldElement = $("#" + elementId);
  oldElementName = oldElement.attr("name");
  oldElementValue = oldElement.val();
  inputClass = "form-control";

  if(selectedType == "html") {
    newElement = jQuery('<textarea/>', {
      id: elementId,
      name: oldElementName
    });
    newElement.val(oldElementValue);
    oldElement.replaceWith(newElement);
    CKEDITOR.replace(elementId);

    CKEDITOR.instances[elementId].on("instanceReady", function() {                    
      this.document.on("keyup", function() {
        $("#" + elementId).val(CKEDITOR.instances[elementId].getData());
      });
    });
  }
  else {
    if(selectedType == "string" || selectedType == "date")
      type = "text";
    if(selectedType == "media")
      type = "file";
    if(selectedType == "boolean") {
      type = "checkbox";
      inputClass = "";
    }

    newElement = jQuery('<input/>', {
      type: type,
      id: elementId,
      name: oldElementName,
      class: inputClass,
      change: function() { 
        removeImage($(this), elementId.substr(elementId.indexOf("value-for-") + 10, elementId.indexOf("-field-") - 10)); 
      }
    });
    if(oldElement.attr("type") != "checkbox" && oldElement.attr("type") != "media" && oldElement.attr("type") != "date") {
      newElement.val(oldElementValue);
    }
    if(selectedType == "boolean") {
      newElement.val("false");
      newElement.change(function() {
        newElement.val(newElement.prop('checked'));
      });
    }
    if(selectedType == "date") {
      newElement.datetimepicker();
      newElement.val(null);
    }

    var instance = CKEDITOR.instances[elementId];
    if(instance) {
      CKEDITOR.remove(instance);
    }
    oldElement.replaceWith(newElement);
    $("#cke_" + elementId).remove();
  };
};

// Removes image visualization
function removeImage(elementName, fieldName) {
  identifier = elementName.attr('id').replace('value-for-' + fieldName + '-field-','');
  $('#extra-fields-value-div-for-' + fieldName +  '-' + identifier).children('img').remove();
};

function getButtonHandlerForJsonFieldsName(fieldName) {
  return 'text-boxes-for-' + fieldName + '-fields';  
};

function populateTextboxWithJsonField(json_field, formName, modelName, fieldName) {
  var index = 0;
  // addMandatoryFieldsElements(mandatory_fields, modelName, fieldName);
  Object.keys(json_field).forEach(function (key) {
    var value = json_field[key];
    index++;
    addFieldElements(modelName, fieldName, index, true);
    $('#name-for-' + fieldName + '-field-' + index).val(key);
    updateValueElementName($('#name-for-' + fieldName + '-field-' + index), modelName, fieldName, 'value');
    updateValueElementName($('#name-for-' + fieldName + '-field-' + index), modelName, fieldName, 'type');

    var valueElement = $('#value-for-' + fieldName + '-field-' + index);

    if (typeof value == 'string') {
      $('#type-for-' + fieldName + '-field-' + index).val('string');
      $('#value-for-' + fieldName + '-field-' + index).attr('type', 'text');
      valueElement.val(value);
    }
    else if (value.type == 'media') {
      $('#type-for-' + fieldName + '-field-' + index).val('media');
      valueElement.attr('type', 'file');

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
    else if (value.type == 'html') {
      $('#type-for-' + fieldName + '-field-' + index).val('html');
      valueElement.attr('type', 'text');
      valueElement.val(value.value);
      buildValueElement('value-for-' + fieldName + '-field-' + index, 'html');
    }
    else if (value.type == 'bool') {
      $('#type-for-' + fieldName + '-field-' + index).val('boolean');
      valueElement.attr('type', 'checkbox');
      valueElement.attr('checked', value.value == true);
      valueElement.attr('class', '');
      valueElement.val(value.value);
      valueElement.change(function() {
        valueElement.val(valueElement.prop('checked'));
      });
    }
    else if (value.type == 'date') {
      $('#type-for-' + fieldName + '-field-' + index).val('date');
      valueElement.attr('type', 'text');
      valueElement.val(value.value);
      valueElement.datetimepicker();
    }
  });
  addButtonHandlerForJsonFields(modelName, fieldName);
};

function initializeTextboxWithJsonField(json_field, formName, modelName, fieldName) {
  if(json_field != null) // for cloning
    populateTextboxWithJsonField(json_field, formName, modelName, fieldName);
  else {
    // addMandatoryFieldsElements(mandatory_fields, modelName, fieldName);
    addButtonHandlerForJsonFields(modelName, fieldName);
  }
};

// function addMandatoryFieldsElements(mandatory_fields, modelName, fieldName) {
//   if (mandatory_fields == null)
//     return;

//   mandatory_fields.forEach(function(mandatory_field) {
//     addFieldElements(modelName, fieldName, mandatory_field, false);
//     $('#name-for-' + fieldName + '-field-' + mandatory_field).val(mandatory_field).attr('readonly', true);
//     updateValueElementName($("#name-for-" + fieldName + "-field-" + mandatory_field), modelName, fieldName, 'value');
//     $('#value-for-' + fieldName + '-field-' + mandatory_field).val(null);
//   });
// };

// Interaction call to actions //

function addButtonHandlerForInteractionCallToActionFields(fieldName, linkedCta, conditionNames, ctaList, unactiveCtaList) {
  var elementRemoved = 0;
  $('#add-button-for-' + fieldName + '-fields').click(function(e) {
    e.preventDefault();
    var counter = $('#text-boxes-for-' + fieldName + '-fields').children().length + 1 + elementRemoved;
      addInteractionCallToActionFieldElements(fieldName, conditionNames, ctaList, unactiveCtaList, null, counter, true);
  });

  $('#text-boxes-for-' + fieldName + '-fields').on('click','.btn', function(e) {
    e.preventDefault();
    $(this).parent().remove();
    elementRemoved++;
  });

  if(linkedCta != null) {
    cnt = 1;
    linkedCta.forEach(function(ictaCondition) {
      addInteractionCallToActionFieldElements(fieldName, conditionNames, ctaList, unactiveCtaList, ictaCondition, cnt, true)
      cnt += 1;
    });
  };
};

function addInteractionCallToActionFieldElements(fieldName, conditionNames, ctaList, unactiveCtaList, ictaCondition, counter, addRemoveButton) {
  attributeIndex = fieldName.substring(fieldName.indexOf("-") + 1, fieldName.length);
  allCtaList = ctaList.concat(unactiveCtaList);

  jQuery('<div/>', {
    id: 'extra-fields-for-' + fieldName + '-' + counter,
    class: 'row'
  }).appendTo('#text-boxes-for-' + fieldName + '-fields');

  // *** CONDITION NAME SELECTOR *** //
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

  conditionNames.forEach(function(conditionName) {
    $('#condition-for-' + fieldName + '-field-' + counter).append('<option value = "' + conditionName + '">' + conditionName + '</option>');
  });

  // *** PARAMETERS INPUT *** //
  jQuery('<div/>', {
    id: 'extra-fields-parameters-for-' + fieldName + '-' + counter,
    class: 'form-group col-lg-3'
  }).appendTo('#extra-fields-for-' + fieldName + '-' + counter);

  jQuery('<label/>', {
    class: 'text-input',
    text: 'Parametri'
  }).appendTo('#extra-fields-parameters-for-' + fieldName + '-' + counter);

  parametersInput = jQuery('<input/>', {
    type: 'text',
    id: 'parameters-for-' + fieldName + '-field-' + counter,
    name: 'call_to_action[interactions_attributes][' + attributeIndex + '][resource_attributes][linked_cta][' + counter + '][parameters]',
    class: 'form-control col-lg-3'
  }).appendTo('#extra-fields-parameters-for-' + fieldName + '-' + counter);

  // *** CALL TO ACTION INPUT *** //
  jQuery('<div/>', {
    id: 'extra-fields-cta-id-for-' + fieldName + '-' + counter,
    class: 'form-group col-lg-3'
  }).appendTo('#extra-fields-for-' + fieldName + '-' + counter);

  jQuery('<label/>', {
    class: 'text-input',
    text: 'Call to action'
  }).appendTo('#extra-fields-cta-id-for-' + fieldName + '-' + counter);

  ctaIdInput = jQuery('<input/>', {
    type: 'text',
    id: 'cta-id-for-' + fieldName + '-field-' + counter,
    name: 'call_to_action[interactions_attributes][' + attributeIndex + '][resource_attributes][linked_cta][' + counter + '][cta_id]',
    class: 'form-control col-lg-3'
  }).appendTo('#extra-fields-cta-id-for-' + fieldName + '-' + counter);

  message = jQuery('<p/>', {
    id: 'cta-id-for-' + fieldName + '-field-' + counter + '_message'
  }).appendTo('#extra-fields-cta-id-for-' + fieldName + '-' + counter);

  // *** VALUES *** //
  if(ictaCondition != null) {
    conditionSelect.val(ictaCondition[0]);
    parametersInput.val(ictaCondition[1]);
    for(var i = 0; i < allCtaList.length; i++) {
      if(allCtaList[i].id == ictaCondition[2]) {
        ctaIdInput.val(allCtaList[i].id);
      };
    };
  };

  $('#cta-id-for-' + fieldName + '-field-' + counter).select2({ 
    maximumSelectionSize: 1, 
    createSearchChoice: function() { return null; },
    formatSelection: function(item) { return item.text; },
    formatNoMatches: function(term) { return "Nessuna Call to Action trovata"; },
    formatSelectionTooBig: function(limit) { return "Puoi selezionare una sola Call to Action"; },
    placeholder: "", 
    tags: ctaList.concat(unactiveCtaList), 
    tokenSeparators: [","] 
  });

  unactiveCtaNameList = []
  ctaNameList = []
  for(var i = 0; i < unactiveCtaList.length; i++) {
    unactiveCtaNameList = unactiveCtaNameList.concat(unactiveCtaList[i].name)
  }
  for(var i = 0; i < ctaList.length; i++) {
    ctaNameList = ctaNameList.concat(ctaList[i].text)
  }

  // $('#cta-id-for-' + fieldName + '-field-' + counter).on("change", function(e) {
  //   showTagboxAlert('#cta-id-for-' + fieldName + '-field-' + counter, unactiveCtaNameList, ctaNameList, "");
  // });

  // *** REMOVE *** //
  if(addRemoveButton != false) {
    $('#extra-fields-for-' + fieldName + '-' + counter).append('<br/><a id = "remove-link-for-' + fieldName + '-field-' + counter + '" href="#" class="col-lg-1 btn btn-primary btn-xs">Rimuovi</a>');
  }
};