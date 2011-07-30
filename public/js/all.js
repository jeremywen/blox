$(document).ready(function () {
		/////////////////////////////////////////
		//init player
		/////////////////////////////////////////
		$("#jquery_jplayer_1").jPlayer({
				swfPath : "/js",
				supplied : "wav"
			});
		
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
		var download = $(".download-wav");
		download.click(function (e) {
				e.preventDefault();
				window.location.href = '/download/'+download.attr("wavFile");
			});
	});
 