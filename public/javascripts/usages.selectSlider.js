(function($){

//--------------------------------------------------------------------
//  SELECT SLIDER
//--------------------------------------------------------------------

$.fn.selectSlider = function(){

//----------------------------------
//  main loop
//----------------------------------

// return this for jQuery chainability
return this.each(function()
{
	
	//----------------------------------
	//  init
	//----------------------------------
	
	// get and hide the jQuery element for this
	var $this = $(this).hide();
	
	// get the slider settings
	var nosnap = $this.hasClass('nosnap');
	
	//----------------------------------
	//  options
	//----------------------------------
	
	// get all <option> elements
	var options = $this.find('option');
	
	// get the last index in options
	var lastIndex = options.length - 1;
	
	//----------------------------------
	//  jQuery slider
	//----------------------------------
	
	// sliders settings
	var slideSettings = {};
	slideSettings.min = 0;
	slideSettings.max = lastIndex;
	slideSettings.step = 1;
	// specific settings
	if (nosnap) {
		slideSettings.min = parseInt(options.first().attr('value'));
		slideSettings.max = parseInt(options.last().attr('value'));
	}
	
	// listener for slide events
	slideSettings.slide = function(event,ui){
		if (nosnap) {
			nosnapOpt.attr('value', ui.value);
			$this.attr('value', ui.value);
		} else {
			$this.attr('value', $(options[ui.value]).attr('value'))
		}
	};
	
	// creating the jQuery slider component
	var slider = $('<span></span>').slider(slideSettings);
	
	// append it to the DOM after the <select>
	$this.after(slider);
	
	//----------------------------------
	//  options init
	//----------------------------------
	
	// create a <span> step for each <option>
	options.each(function(i,node){
		slider.append(
			$('<span />')
				// adding the content
				.html(!$(node).attr('disabled') ? $(node).html() : "")
				// positionning in the slider
				.css('left', i/lastIndex*100 + '%')
		);
		// sets the current value of the slider if the <option> is selected
		if ($this.attr('value') == $(node).attr('value')) {
			slider.slider('value',
				nosnap ? $this.attr('value') : i
			);
		}
	});
	
	// activate the animation after setting the value
	slider.slider('option','animate',true);
	
	//----------------------------------
	//  nosnap
	//----------------------------------
	
	// if ratio mode
	var nosnapOpt;
	if (nosnap) {
		// remove all options
		$this.html('');
		nosnapOpt = $('<option></option>')
			.html('ratio')
			.attr('value', slider.slider('value'))
			.attr('selected', true)
			.appendTo($this);
	}
	
}); // end of return this.each...
}; // end of function
})(jQuery);