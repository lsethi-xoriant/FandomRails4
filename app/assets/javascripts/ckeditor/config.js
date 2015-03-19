CKEDITOR.editorConfig = function(config) {

  config.toolbar = 'Mini';

  config.autoParagraph = false;
  config.allowedContent = true;
  config.fillEmptyBlocks = "&#8203;";
  config.removeFormatTags = "b,big,code,del,dfn,em,font,i,ins,kbd,p,q,samp,small,span,strike,strong,sub,sup,tt,u,var";

  config.toolbar_Mini =
    [
      { name: 'document', items : [ 'Source' ] },
      { name: 'clipboard', items : [ 'Cut','Copy','Paste','PasteText','PasteFromWord','-','Undo','Redo' ] },
      { name: 'links', items : [ 'Link','Unlink','Anchor' ] },
      '/',
      { name: 'basicstyles', items : [ 'Bold','Italic','Underline','Strike','Subscript','Superscript','-','RemoveFormat' ] },
      { name: 'paragraph', items : [ 'NumberedList','BulletedList','-','Outdent','Indent','-','Blockquote','CreateDiv',
      '-','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock','-','BidiLtr','BidiRtl' ] },
      '/',
      { name: 'styles', items : [ 'Styles','Format','Font','FontSize' ] },
      { name: 'colors', items : [ 'TextColor' ] },
    ];

}

CKEDITOR.dtd.$removeEmpty['span'] = false;
CKEDITOR.dtd.$removeEmpty['i'] = false;