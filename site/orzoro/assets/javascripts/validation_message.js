jQuery.extend(jQuery.validator.messages, {
    required: "Campo obbligatorio.",
    remote: "Corregi questo campo.",
    email: "Inserisci un email valida.",
    url: "Inserisci una URL valida.",
    date: "Inserisci una data valida.",
    dateISO: "Inserisci una data valida (ISO).",
    number: "Inserire un numero corretto.",
    digits: "Please enter only digits.",
    creditcard: "Please enter a valid credit card number.",
    equalTo: "Please enter the same value again.",
    accept: "Please enter a value with a valid extension.",
    maxlength: jQuery.validator.format("Please enter no more than {0} characters."),
    minlength: jQuery.validator.format("Please enter at least {0} characters."),
    rangelength: jQuery.validator.format("Please enter a value between {0} and {1} characters long."),
    range: jQuery.validator.format("Please enter a value between {0} and {1}."),
    max: jQuery.validator.format("Please enter a value less than or equal to {0}."),
    min: jQuery.validator.format("Please enter a value greater than or equal to {0}.")
});