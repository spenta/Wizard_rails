(function($j){

//--------------------------------------------------------------------
//  LABEL CHECKBOX
//--------------------------------------------------------------------

$j.fn.labelCheckbox = function()
{

//----------------------------------
//  main loop
//----------------------------------

// return this for jQuery chainability
return this.each(function()
{

	//----------------------------------
	//  init
	//----------------------------------

	// get the jQuery of this
	var $jthis = $j(this)
		.addClass('checkbox')
		// add event listener
		.bind('click', clickHandler)
		.bind('select', selectHandler)
		.bind('unselect', unselectHandler)
		// add child <.icon>
		.append(
			$j('<span/>').addClass('icon')
		);

	//----------------------------------
	//  Checkbox
	//----------------------------------

	// get the <input type="checkbox"> element
	var checkbox = $jthis.find('input:checkbox');
	if (checkbox.length <= 0) return;

	// hide the classic checkbox
	checkbox.hide();

	// update the current style
	update(checkbox.attr('checked'));

	//----------------------------------
	//  clickHandler
	//----------------------------------

	// event listener
	function clickHandler(e)
	{
		e.stopPropagation();
		e.preventDefault();

		// dispatch event
		$jthis.trigger(
			// event type
			!checkbox.attr('checked')?'select':'unselect',
			// from user interaction
			[true]
		);
	};

	//----------------------------------
	//  selectHandler
	//----------------------------------

	// event listener
	function selectHandler(e, fromUserInteraction) {
		update(true);
	}

	//----------------------------------
	//  unselectHandler
	//----------------------------------

	// event listener
	function unselectHandler(e, fromUserInteraction) {
		update(false);
	}

	//----------------------------------
	//  update
	//----------------------------------

	// helper : update the style and the checkbox selection
	function update(selected)
	{
		// toggle the 'selected' class
		$jthis.toggleClass('selected', selected);
		// (un)check the original checkbox
		checkbox.attr('checked', selected);
	}

}); // end of return this.each...
}; // end of function
})(jQuery);

