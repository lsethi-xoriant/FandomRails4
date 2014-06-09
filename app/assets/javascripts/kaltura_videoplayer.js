var videoPlayer;

//link javascript library to include to use kaltura API:
// <script src="http://cdnapi.kaltura.com/p/{PARTNER_ID}/sp/{PARTNER_ID}00/embedIframeJs/uiconf_id/{uiConfId}/partner_id/{PARTNER_ID}"></script>

var partnerid = "1655411"
var uiconfid = "24231962"
var ctaurl = "1_cwovnbxj"

kWidget.embed({
         'targetId': 'cta-video',
         'wid': partnerid,
         'uiconf_id' : uiconfid,
         'entry_id' : ctaurl,
         'flashvars':{ // flashvars allows you to set runtime uiVar configuration overrides. 
              'autoPlay': false
         },
         'params':{ // params allows you to set flash embed params such as wmode, allowFullScreen etc
              'wmode': 'transparent'
         },
         readyCallback: function( playerId ){
			loadStartInteraction();
			window.kdp = $(playerId);
			$(playerId).get(0).addJsListener("playerUpdatePlayhead", "checkInteraction");

         }
 });

function restartVideo(idvideo) {
	kdp.sendnotification("doStop");
  	loadStartInteraction();
}

function restartVideo_nointer(idvideo) {
	kdp.sendnotification("doStop");
}

function continueVideo() {
    kdp.sendnotification("doPlay");
}

function playVideo() {
	if($("div.overlay"))
		$("div.overlay").remove();
    kdp.sendnotification("doPlay");

}

function removePlayLayer() {
	if($("div.overlay"))
		$("div.overlay").remove();	
	kdp.sendnotification("doStop");
}

function pauseVideo() {
    kdp.sendnotification("doPause");
}

function videoPlay() {

	if(!play_pressed){
    	$.ajax({
            type: "POST",
            url: '/quiz/addplay.json',
            data: { "cta_id": ctaid },
            beforeSend: function(jqXHR, settings) {
                jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
            },
            success: function(data) {
            	
            }
        });
        play_pressed = true;
    }
}
  
function checkInteraction(data, id) {
	
	seconds = Math.floor(data);
	$.each(interactions, function(index, inter){
		if(seconds == inter.seconds && !already_anser[index] ){
			already_anser[index] = true;
			pauseVideo();
			switch(inter.resource_type){
				case 'Quiz':
					loadQuiz(inter.resource_id);
					break;
				default:
					continueVideo();
					break;
			}
		}
	});
	//$("#current-video-time").html(seconds);  	
}


