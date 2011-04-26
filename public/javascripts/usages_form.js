/**
 * Classe UsageForm
 */
function UsageForm(selector)
{
				
	//--------------------------------------------------------------------
	//  PROPERTIES
	//--------------------------------------------------------------------
	
	var HTML_SUBUSAGE_CLOSE = "<a class='close'><span class='icon'></span><span class='label'>Valider</span></a>";
	
	var usageState = {
		OPENED : "opened",
		CLOSED : "closed",
		TABBED : "tabbed"
	};
	
	//--------------------------------------------------------------------
	//  PROPERTIES
	//--------------------------------------------------------------------
	
	// l'élément formulaire
	var form = $(selector);
	
	//--------------------------------------------------------------------
	//  BOOTSTRAP
	//--------------------------------------------------------------------
	
	// .usage
	form.find('.usage').each(function(i,node){
		setUsageState($(node), usageState.CLOSED);
	});
	
	// .usage > .usage-content > .subusages
	console.log(form.find('.usage .usage-content .subusages .clear'));
	form.find('.usage .usage-content .subusages .clear')
		.each(function(i,node){$(node).before(
				// création du bouton close et écoute du click
				$(HTML_SUBUSAGE_CLOSE).click(usageClose_clickHandler)
			)
		});
	
	// .usage > .usage-content > .subusages > .subusage
	form.find('.usage .usage-content .subusages .subusage')
		.click(subusage_clickHandler);
	
	setSubusageSelection(form.find('.subusage:has(input:checked)'), true);
	setSubusageSelection(form.find('.subusage:has(:checkbox:not(:checked))'), false);
	
	form.find('.subusage input:checkbox').hide();
	
	//--------------------------------------------------------------------
	//  PRIVATE METHODS : EVENT LISTENERS
	//--------------------------------------------------------------------
	
	//----------------------------------
	//  usage_clickHandler
	//----------------------------------
	
	function usage_clickHandler(e)
	{
		e.stopPropagation();
		openUsage($(this));
	}
	
	//----------------------------------
	//  usageIcon_clickHandler
	//----------------------------------
	
	function usageClose_clickHandler(e)
	{
		e.stopPropagation();
		
		//form.css('min-height', '0px');
		form.find('input:submit').show();
		// ferme tous les usages
		setUsageState(
			form.find('.usage'),
			usageState.CLOSED
		);
	}
	
	//----------------------------------
	//  subusage_clickHandler
	//----------------------------------
	
	function subusage_clickHandler(e)
	{
		e.stopPropagation();
		e.preventDefault();
		
		selectSubusage($(this));
	}
	
	//--------------------------------------------------------------------
	//  PRIVATE METHODS
	//--------------------------------------------------------------------
	
	//----------------------------------
	//  openUsage
	//----------------------------------
	
	function openUsage(usage)
	{
		// ouvre l'usage
		setUsageState(usage, usageState.OPENED);
		// met en tab les autres
		setUsageState(
			form.find('.usage[id!='+usage.attr('id')+']'),
			usageState.TABBED
		);
		//form.css('min-height', usage.find('.usage-content').height());
		//form.css('min-height', usage.find('.usage-content').innerHeight());
		//form.css('min-height', usage.find('.usage-content').outerHeight());
		var u = form.find('.usage');
		var n = u.size();
		var g = parseInt(u.css('margin-bottom'));
		console.log(g);
		usage.find('.usage-content').css('min-height', 
			u.outerHeight() * n + (n-1) * g
		);
		form.find('input:submit').hide();
		//.map(function(){return $(this).text()}).get()
		//console.log(form.find('.usage').outerHeight()*form.find('.usage').size());
	}
	
	//----------------------------------
	//  setUsageState
	//----------------------------------
	
	function setUsageState(usage, state)
	{
		usage
			// suppr des trois classes
			.removeClass(usageState.OPENED)
			.removeClass(usageState.CLOSED)
			.removeClass(usageState.TABBED)
			// suppr des ecouteurs
			.unbind('click')
			// ajout de la bonne classe
			.addClass(state);
		
		usage.find('.usage-content').css('min-height', 0);
		
		// .usage > .usage-icon
		var uicon = usage.find('.usage-icon')
			// suppr des ecouteurs
			.unbind('click');
		
		// définition des écouteurs en fonction
		// de l'état actuel de l'usage.
		switch (state) {
			case usageState.CLOSED:
			case usageState.TABBED:
				usage.click(usage_clickHandler);
				break;
			case usageState.OPENED:
				uicon.click(usageClose_clickHandler);
				break;
		}
	}
	
	//--------------------------------------------------------------------
	//  PRIVATE METHODS : SUBUSAGES
	//--------------------------------------------------------------------
	
	//----------------------------------
	//  selectSubusage
	//----------------------------------
	
	function selectSubusage(subusage)
	{
		// .usage > .usage-content > .subusages > .subusage (=this)
		var usage = subusage.parent().parent().parent();
		
		// si 'ça ne m'interesse pas'
		if (subusage.hasClass('none'))
		{
			// selection (pas de toggle)
			setSubusageSelection(subusage, true);
			// deselection des autres
			setSubusageSelection(
				usage.find('.subusage:not(.none)'),
				false
			);
		}
		// si sous-usage normal
		else
		{
			// inversion de la selection du sous-usage
			setSubusageSelection(subusage, !isSubusageSelected(subusage));
			// (dé)sélection du 'ça ne m'interesse pas'
			setSubusageSelection(
				usage.find('.subusage.none'),
				usage.find('.subusage:not(.none):has(:checkbox:checked)').length == 0
			);
		}
		
		// récup des sous usages selectionnés
		var selectedSubusages = usage.find('.subusage:not(.none):has(:checkbox:checked)');
		if (selectedSubusages.length > 0) 
		{
			usage.toggleClass('selected', true);
			usage.find('.abst').text(
				selectedSubusages.find('label')
					// moyen (hideux) pour récupérer une tableau des text()
					.map(function(){return $(this).text()}).get()
					.join(', ') + "..."
			);
		}
		else
		{
			usage.toggleClass('selected', false);
			usage.find('.abst').text("");
		}
	}
	
	//----------------------------------
	//  setMultipleUsageState
	//----------------------------------
	
	function setSubusageSelection(subusage, selected)
	{
		// ajout/suppression de la classe selected
		subusage.toggleClass('selected', selected);
		// selection/deselection de la checkbox
		subusage.find('input:checkbox').attr('checked', selected);
	}
	
	//----------------------------------
	//  isUsageSelected
	//----------------------------------
	
	function isSubusageSelected(subusage)
	{
		return subusage.find('input:checkbox').attr('checked');
	}
	
}
