(function($j){

//--------------------------------------------------------------------
//  TABBED FORM
//--------------------------------------------------------------------

$j.fn.tabbedForm = function(options)
{

//----------------------------------
//  default settings
//----------------------------------

var settings = {
	// the close button text
	closeText:"Valider",
	infoContainer:null
};

//----------------------------------
//  main loop
//----------------------------------

// return 'this' for jQuery chainability
return this.each(function()
{
	//----------------------------------
	//  init
	//----------------------------------

	// get the jQuery element for this
	var $jthis = $j(this)
		// auto add the 'tabbed' class
		.addClass('tabbed');

	// extends default settings
	if (options) $j.extend(settings, options);

	//----------------------------------
	//  questions
	//----------------------------------

	// get all <.questions> in the form
	var questions = $jthis.find('.question')
		// init of the tabbed behavior
		.tabbedQuestion({closeText:settings.closeText})
		// listen for events
		.bind('clickToOpen',question_clickToOpenHandler)
		.bind('clickToClose',question_clickToCloseHandler);

	// set the default state
	setQuestionState(questions, 'button');

	//----------------------------------
	//  infoContainer
	//----------------------------------

	var defaultInfoContent;
	if (settings.infoContainer)
	{
		// get the actual content of the infoContainer
		var defaultInfoContent = settings.infoContainer.html();
		// hide all <.qinfo> of the questions
		questions.find('.qinfo').hide();
	}

	//----------------------------------
	//  question_clickToOpenHandler
	//----------------------------------

	// event listener
	function question_clickToOpenHandler(e)
	{
		var $jtarget = $j(this);

		// set the 'opened' state to the target
		setQuestionState($jtarget, 'opened');
		// set the 'tabbed' state for all other questions
		setQuestionState(questions.not(this), 'tabbed');

		// hide the submit button when a <.question> is opened
		$jthis.find('input:submit').hide();
		$jthis.find('a.prev-button').hide();

		// update the infoContainer content
		if (settings.infoContainer) {
			var qinfo = $jtarget.find('.qinfo:first');
			switchContent(qinfo.length > 0 ? qinfo.html() : defaultInfoContent);
		}

		// fix : set a min-height to the content, to prevent
		// be sure that the .qbody will be over all buttons
		$jthis.css('min-height', 0);
		$jtarget.find('.qbody').css('min-height',$jthis.height());

		// fix : set a min-height to the form, to prevent
		// the position:absolute css behavior of the <.qbody>
		$jthis.css('min-height', $jtarget.find('.qbody').outerHeight() + 'px');
	}

	//----------------------------------
	//  question_clickToCloseHandler
	//----------------------------------

	// event listener
	function question_clickToCloseHandler(e)
	{
		var $jtarget = $j(this);

		// set the 'button' state for all questions
		setQuestionState(questions, 'button');

		// show the submit button when no question is opened
		$jthis.find('input:submit').show();
		$jthis.find('a.prev-button').show();

		// update the infoContainer content
		if (settings.infoContainer)
			switchContent(defaultInfoContent);

		// removes the form min-height
		$jthis.css('min-height', 0);
		questions.find('.qbody').css('min-height', 0);
	}

	//----------------------------------
	//  setQuestionState
	//----------------------------------

	// helper : set a state to a group of <.question>
	function setQuestionState(questions, state)
	{
		// dispatch the event to the <.question> elements
		switch (state) {
			case 'button' :
			case 'tabbed' :
				questions.trigger('close');
				break;
			case 'opened' :
				questions.trigger('open');
				break;
		}

		// set the right class and remove others
		questions.toggleClass('button', state == 'button');
		questions.toggleClass('tabbed', state == 'tabbed');
		questions.toggleClass('opened', state == 'opened');
	}

	//----------------------------------
	//  switchContent
	//----------------------------------

	// helper : changes the content of the infoContainer with a fade transition
	function switchContent(content)
	{
		settings.infoContainer
			// stop current transition
			.stop()
			// fade out the container
			.fadeTo(200, 0, function() {
				// when complete
				settings.infoContainer
					// update the content
					.html(content)
					// fade in the container
					.fadeTo(200, 1);
			});
	}

}); // end of return this.each...
}; // end of $j.fn.function


//--------------------------------------------------------------------
//  TABBED QUESTION
//--------------------------------------------------------------------

$j.fn.tabbedQuestion = function(options)
{

//----------------------------------
//  default settings
//----------------------------------

var settings = {
	// the close button text
	closeText:"Valider"
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

	// get the jQuery element for this
	var $jthis = $j(this)
		// listen for open/close events
		.bind('open', openHandler)
		.bind('close', closeHandler);

	// extends default settings
	if (options) $j.extend(settings, options);

	//----------------------------------
	//  ansers
	//----------------------------------

	// get all <.answer>
	var ansers = $jthis.find('.answer');

	// get the <.qdesc>
	var qdesc = $jthis.find('.qdesc');

	//----------------------------------
	//  closeBtn
	//----------------------------------

	// create the <.close> button
	var closeBtn = $j('<span/>')
		.addClass('close')
		// label & icon
		.append($j('<span/>').addClass('label').html(settings.closeText))
		.append($j('<span/>').addClass('icon'))
		// added to the DOM into the last anwser
		.appendTo(ansers.first())
		// listen for click events
		.bind('click', close_clickHandler);

	//----------------------------------
	//  qabst
	//----------------------------------

	// create the <.qabst> paragraph
	var qabst = $j('<p/>')
		.addClass('qabst');

	// added to the DOM after the <.qname>
	$jthis.find('.qname').after(qabst);

	// listen for change event of the first multichoice answer
	$jthis.find('.answer.multichoice:first')
		.bind('change', function(e,selected,resume) {
			// set the question 'selected' class
			$jthis.toggleClass('selected', selected);
			// update the <.qabst> content
			qabst.html(resume);
		});

	//----------------------------------
	//  openHandler
	//----------------------------------

	// event listener
	function openHandler(e)
	{
		/*// show content
		qdesc.show();
		ansers.show();
		closeBtn.show();*/

		// hide abstract
		qabst.hide();

		// remove event listener
		$jthis.unbind('click', clickHandler);
	}

	//----------------------------------
	//  closeHandler
	//----------------------------------

	// event listener
	function closeHandler(e)
	{
		/*// hide content
		qdesc.hide();
		ansers.hide();
		closeBtn.hide();*/

		// show the abstract
		qabst.show();

		// add event listener
		$jthis.unbind('click', clickHandler); // bugfix...
		$jthis.bind('click', clickHandler);
	}

	//----------------------------------
	//  clickHandler
	//----------------------------------

	// event listener
	function clickHandler(e)
	{
		e.preventDefault();
		e.stopPropagation();
		// dispath the event
		$jthis.trigger('clickToOpen');
	}

	//----------------------------------
	//  close_clickHandler
	//----------------------------------

	// event listener
	function close_clickHandler(e)
	{
		e.preventDefault();
		e.stopPropagation();
		// dispath the event
		$jthis.trigger('clickToClose');
	}

}); // end of return this.each...
}; // end of $j.fn.function
})(jQuery);

