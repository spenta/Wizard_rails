(function($j){

//--------------------------------------------------------------------
//  ANSWER MULTICHOICE
//--------------------------------------------------------------------

$j.fn.answerMultichoice = function(options)
{

//----------------------------------
//  default settings
//----------------------------------

// default settings
var settings = {
	addNone:true,
	noneText:"Ça ne m'intéresse pas"
};

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
	var $jthis = $j(this);

	// extends default settings
	if (options) $j.extend(settings, options);

	//----------------------------------
	//  labels
	//----------------------------------

	// get the <label> elements that has a checkbox
	var labels = $jthis.find('label:has(input:checkbox)')
		// convert to labelCheckbox
		.labelCheckbox()
		// add event listener
		.bind('select', label_selectHandler)
		.bind('unselect', label_unselectHandler);

	//----------------------------------
	//  none
	//----------------------------------

	// create the 'none' element
	if (settings.addNone)
	{
		var none =
			$j('<label/>')
				// add the 'name' <span>
				.append(
					$j('<span/>').html(settings.noneText).addClass('name')
				)
				.append(
					$j('<span/>').addClass('icon')
				)
				// set the 'selected' class if needed
				.toggleClass('selected', getSelectedLabels().length <= 0)
				// display it as a choice
				.addClass('checkbox')
				// adds the 'none' specific class
				.addClass('none')
				// listen for click events
				.click(none_clickHandler);

		// append it to the multichoice answer
		labels.last().after(none).after($j('<hr/>'));
	}

	//----------------------------------
	//  label_selectHandler
	//----------------------------------

	// dispatch the event in case some checkbox were already selected.
	triggerChangeEvent();

	//----------------------------------
	//  label_selectHandler
	//----------------------------------

	// event listener
	function label_selectHandler(e, fromUserInteraction)
	{
		if (fromUserInteraction)
		{
			// unselect the 'none' <label>
			if (settings.addNone &&
				getSelectedLabels().length > 0)
				none.toggleClass('selected', false);

			// dispatch the change event
			triggerChangeEvent();
		}
	}

	//----------------------------------
	//  label_unselectHandler
	//----------------------------------

	// event listener
	function label_unselectHandler(e, fromUserInteraction)
	{
		if (fromUserInteraction)
		{
			// select the 'none' <label>
			if (settings.addNone &&
				getSelectedLabels().length <= 0)
				none.toggleClass('selected', true);

			// dispatch the change event
			triggerChangeEvent();
		}
	}

	//----------------------------------
	//  none_clickHandler
	//----------------------------------

	// event listener
	function none_clickHandler(e)
	{
		e.stopPropagation();
		e.preventDefault();
		// set the selection
		none.addClass('selected');
		// unselect all labels
		getSelectedLabels().trigger('unselect');
		// dispatch the change event
		triggerChangeEvent();
	}

	//----------------------------------
	//  getSelectedLabels
	//----------------------------------

	// helper : return all 'selected' <labels> of the answer
	function getSelectedLabels()
	{
		return labels.not('.none').filter('.selected');
	}

	//----------------------------------
	//  triggerChangeEvent
	//----------------------------------

	// helper : return all 'selected' <labels> of the answer
	function triggerChangeEvent()
	{
		// get the <.name> text of each selected label
		var values = getSelectedLabels().find('.name')
			// ugly way to get all texts in an array...
			.map(function(){return $j(this).text()}).get();

		// check if there is some values
		var selected = values.length > 0;

		// dispatch the event
		$jthis.trigger('change', [
			selected,
			selected ? values.join(', ')+'...' : ""
		]);
	}

}); // end of return this.each...
}; // end of function
})(jQuery);

