$(document).ready(function () {
		/////////////////////////////////////////
		//center player
		/////////////////////////////////////////
		$(window).resize(function () {
				
				$('.jp-type-single').css({
						position : 'absolute',
						width : 480,
						left : ($(window).width() - 480) / 2
					});
				
			});
		$(window).resize();
		
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
					function (wavFile) {
						//alert("wavFile Loaded: " + wavFile);
						
						$(".download-wav").attr("wavFile", wavFile);
						
						var player = $("#jquery_jplayer_1");
						player.jPlayer("clearMedia");
						player.jPlayer("setMedia", {
								wav : wavFile
							}).jPlayer("play");
					});
			});
		
		/////////////////////////////////////////
		//download wav file
		/////////////////////////////////////////
		var downloadWav = $(".download-wav");
		downloadWav.click(function (e) {
				e.preventDefault();
				window.location.href = '/download/' + download.attr("wavFile");
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
 