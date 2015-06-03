CKEDITOR.editorConfig = function(config) {

  config.toolbar = 'Mini';

  config.autoParagraph = false;
  config.allowedContent = true;
  config.fillEmptyBlocks = "&#8203;";
  config.removeFormatTags = "b,big,code,del,dfn,em,font,i,ins,kbd,p,q,samp,small,span,strike,strong,sub,sup,tt,u,var";
  config.entities = false;
  // config.basicEntities = false;
  // config.entities_greek = false;
  // config.entities_latin = false;

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

CKEDITOR.on('instanceReady', function( ev ) {
  var blockTags = ['div','h1','h2','h3','h4','h5','h6','p','pre','li','blockquote','ul','ol','table','thead','tbody','tfoot','td','th'];

  for (var i = 0; i < blockTags.length; i++)
  {
    ev.editor.dataProcessor.writer.setRules( blockTags[i], {
      // Indicates that this tag causes indentation on line breaks inside of it.
      indent : true,
      // Inserts a line break before the opening tag.
      breakBeforeOpen : true,
      // Inserts a line break after the opening tag.
      breakAfterOpen : true,
      // Inserts a line break before the closing tag.
      breakBeforeClose : false,
      // Inserts a line break after the closing tag.
      breakAfterClose : true
    });
  }
});