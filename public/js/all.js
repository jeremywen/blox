$(document).ready(function () {
		$("#jquery_jplayer_1").jPlayer({
				swfPath : "/js",
				supplied : "wav"				
			});
		
		//center player
		$(window).resize(function () {
				
				$('.jp-type-single').css({
						position : 'absolute',
						width : 420,
						left : ($(window).width() - 420) / 2
					});
				
			});
		$(window).resize();
		
		//play wav file
		$("span").click(function () {
				var block = $(this).html();
				//alert(block);
				$.post("/get-audio", block,
					function (wavFile) {
						//alert("wavFile Loaded: " + wavFile);
						var player = $("#jquery_jplayer_1");
						player.jPlayer("clearMedia");
						player.jPlayer("setMedia", {
								wav : wavFile
							}).jPlayer("play");
					});
			});
	});
 