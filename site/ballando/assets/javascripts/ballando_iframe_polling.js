document.domain = "shado.tv";

/*
jQuery(document).ready(function($) {

	$.definePollingEvent('iframeResize', {
		// polling interval, a minimal delay before a next polling cycle
		delay : 300, // msec

		// how often the plugin should check for changes
		// (element removal, adding/removing of elements when
		// event delegation is used)
		//
		// use -1 to disabled automatic updates
		// (do it only if your DOM doesn't change).
		// event delegation still works with this setup, though
		cacheTimeout : 2000, // msec

		// how many elements may be queried in a polling cycle.
		// specifying big numbers and/or providing custom value calculating functions
		// (see below) may result in browser lagging
		aggregateNum : 5,

		// jQuery selector to choose the elements to be polled.
		// This selector is being run each cacheTimeout milliseconds
		elementSelector : 'body',

		// function to determine the value of an element;
		// accepts DOM element as a parameter
		valFn : function(el) {
			return $(el).height();
		}
		// function to determine whether two values are equal or not,
		// gets old value, new value, and DOM element reference as parameters
		//eqFn: function(oldVal, newVal, el) {
		//    return oldVal === newVal;
		//}
	});

	$('body').on('iframeResize', function(e) {
		console.log("A");
		window.parent.containerResize();
	});

});
*/

function checkDocumentHeight(callback){
    var lastHeight = $("body").height(), newHeight, timer;
    (function run(){
        newHeight = $("body").height();
        if( lastHeight != newHeight ) {
            callback();
        }
        lastHeight = newHeight;
        timer = setTimeout(run, 300);
    })();
}

function parentContainerResize(){
	window.parent.containerResize();
}

checkDocumentHeight(parentContainerResize); 