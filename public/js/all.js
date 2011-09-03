$(document).ready(function () {

		/////////////////////////////////////////
		//init player
		/////////////////////////////////////////
		$("#jquery_jplayer_1").jPlayer({
				swfPath : "/js",
				supplied : "wav"
			});
		
		/////////////////////////////////////////
		//play wav file
		/////////////////////////////////////////
		$("span").click(function () {
				var block = $(this).html();
				//alert(block);
				$.post("/get-audio", block,
					function (wavfile) {
						//alert("wavFile Loaded: " + wavfile);
						
						$(".download-wav").attr("wavfile", wavfile);
						
						var player = $("#jquery_jplayer_1");
						player.jPlayer("clearMedia");
						player.jPlayer("setMedia", {
								wav : wavfile
							}).jPlayer("play");
					});
			});
		
		/////////////////////////////////////////
		//download wav file
		/////////////////////////////////////////
		var downloadWav = $(".download-wav");
		downloadWav.click(function (e) {
				e.preventDefault();
				window.location.href = '/download/' + downloadWav.attr("wavfile");
			});
		
		/////////////////////////////////////////
		//download beat file
		/////////////////////////////////////////
		var downloadBeat = $(".download-beat");
		downloadBeat.click(function (e) {
				e.preventDefault();
				var beatFile = $(".download-wav").attr("wavFile").replace(".wav",".beat");
				window.location.href = '/download/' + beatFile;
			});
	});
 