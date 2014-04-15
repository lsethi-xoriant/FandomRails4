var videoPlayer;

	OO.ready(function() {
		videoPlayer = OO.Player.create('cta-video',ctaurl, {
			height: 354,
			width: 630,
	    	wmode: 'transparent',
	    	onCreate: function(player){
	    		
	    		loadStartInteraction();
	    		
	    		player.mb.subscribe(OO.EVENTS.PLAYHEAD_TIME_CHANGED, 'inter', checkInteraction);
	    		
	    		player.mb.subscribe(OO.EVENTS.PLAYED, 'inter', videoPlay());

	    	}
	    });
	});


function restartVideo(idvideo) {
	videoPlayer.setEmbedCode(idvideo);
	videoPlayer.stop();
  	loadStartInteraction();
}

function restartVideo_nointer(idvideo) {
	videoPlayer.setEmbedCode(idvideo);
	videoPlayer.stop();
}

function continueVideo() {
    videoPlayer.play();
}

function playVideo() {
	if($("div.overlay"))
		$("div.overlay").remove();
    videoPlayer.play();

}

function removePlayLayer() {
	if($("div.overlay"))
		$("div.overlay").remove();	
	videoPlayer.stop();
}

function pauseVideo() {
    videoPlayer.pause();
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
  
function checkInteraction(event, time) {
	
	seconds = Math.floor(videoPlayer.getPlayheadTime());
	$.each(interactions, function(index, inter){
		if(seconds == inter.seconds && !already_anser[index] ){
			already_anser[index] = true;
			videoPlayer.pause();
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


