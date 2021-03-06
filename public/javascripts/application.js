var CharacterCounter = {
	max: null,
    remaining: null,
    obj: null,
    start: function() {
	    // NOTE: Called externally, so must use "CharacterCounter" instead of "this".
	    CharacterCounter.update();
    },
    update: function() {
        this.remaining = this.max - $(this.obj).val().length;
        if (this.remaining > this.max) {
            $(this.obj).val($(this.obj).val().substring(0, this.max));
        }
        $(".remaining").text(this.remaining + " characters remaining");
    },
};

function showAdminActions() {
  $(this).children(".admin-actions").slideDown();
}

function hideAdminActions() { 
  $(this).children(".admin-actions").slideUp();
}

jQuery(function() {
	
    $('.countcharacters').each(function() {
        $(this).focus(function() {
            var c = $(this).attr("class");
            CharacterCounter.max = parseInt(c.match(/limit_[0-9]{1,}_/)[0].match(/[0-9]{1,}/)[0]);
            CharacterCounter.obj = this;
            intervalCount = setInterval(CharacterCounter.start, 500);
        }).blur(function() {
            CharacterCounter.start();
            clearInterval(intervalCount);
        });
    });
 
   $(".hover-menu").hoverIntent({
     sensitivity: 1,           // number = sensitivity threshold (must be 1 or higher)
     interval: 300,             // number = milliseconds for onMouseOver polling interval
     over: showAdminActions,   // function = onMouseOver callback (required)
     timeout: 300,             // number = milliseconds delay before onMouseOut
     out: hideAdminActions     // function = onMouseOut callback (required)
   });

	$("a.zoom").fancybox({
		'overlayOpacity': 0.5,
		'overlayColor':	  '#666'
	});
  
  $(document).keydown(function(e){
    if ((e.keyCode == 32)||(e.keyCode == 13)) { // spacebar or enter key
      var ftm = $("#fancy_title_main");
      if(ftm.is(":visible")) {
        var ftm_links = ftm.find("a[href]");
        ftm_links.each(function() {
          if(! $(this).attr("href").match(/twitter/)) { // open the first non-twitter link
            $(this).click();
            return false;
          }
        });
      }
    }
  });
    
});