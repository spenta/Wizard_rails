/**
 *  rb = result_biglist;
 */

//--------------------------------------------------------------------
//  PROPERTIES
//--------------------------------------------------------------------

//----------------------------------
//  ELEMENTS VISUELS
//----------------------------------

var rb;
var rb_table;
var rb_toggleOn;
var rb_toggleOff;

//----------------------------------
//  CONFIG
//----------------------------------

//--------------------------------------------------------------------
//  METHODS
//--------------------------------------------------------------------

//----------------------------------
//  INIT
//----------------------------------

/**
 *  Initialisation.
 */
function rb_init(selector) 
{
	rb = $(selector);
	rb_table = rb.find('table');
	rb_toggleOn = rb.find('.toggle .on');
	rb_toggleOff = rb.find('.toggle .off');
	
	// initialisation
	rb_initTableTooltips();
	rb_initTableSorting();
	
	// écouteurs
	rb_toggleOn.click(rb_showTable);
	rb_toggleOff.click(rb_hideTable);
	
	// masque le tableau
	rb_hideTable();
}

//----------------------------------
//  TABLE : TOOLTIPS
//----------------------------------

/**
 *  Initialisation du tableau.
 */
function rb_initTableTooltips()
{
	if (!$().qtip) { alert("Plugin jQuery manquant : Qtip"); return; }
	
	rb_table.find('tr.product.star td.label .icon').qtip({
	   content:'Pour ce que vous voulez faire, c&acute;est le meilleur ordinateur dans sa gamme de prix !',
	   show:{ delay:0, effect:{type:'fade',length:0}, ready:false},
	   hide:{ delay:0, effect:{type:'none'}},
	   style:{name:'dark'}
	});
	
	$('#biglist tr.product.gooddeal td.label .icon').qtip({
	   content:'Tr&egrave;s bon rapport performance-prix pour vos besoins !',
	   show:{ delay:0, effect:{type:'fade',length:0}, ready:false},
	   hide:{ delay:0, effect:{type:'none'}},
	   style:{name:'dark'}
	});
}

//----------------------------------
//  TABLE : SORTING
//----------------------------------

/**
 *  Initialisation du tableau.
 */
function rb_initTableSorting()
{
	if (!$().tablesorter) { alert("Plugin jQuery manquant : TableSorter"); return; }
	
	$.tablesorter.addWidget({ 
		// give the widget a id 
		id: "repeatHeaders", 
		// format is called when the on init and when a sorting has finished 
		format: function(table) { 
			// cache and collect all TH headers 
			if(!this.headers) { 
				var h = this.headers = [];  
				$("thead th",table).each(function() {
					h.push(
						$("<div/>").append(
							$(this).clone()
								.removeClass('header')
								.removeClass('headerSortUp')
								.removeClass('headerSortDown')
						).html()
					); 
				}); 
			} 
			// remove appended headers by classname. 
			$("tr.header.repeated",table).remove();
			// loop all tr elements and insert a copy of the "headers"     
			for(var i=0; i < table.tBodies[0].rows.length; i++) { 
				// insert a copy of the table head every 10th row 
				if((i%11) == 10) {
					$("tbody tr:eq(" + i + ")",table).before(
						$("<tr></tr>")
							.addClass("header")
							.addClass("repeated")
							.html(this.headers.join(""))
					);     
				} 
			} 
		} 
	}); 
	
	// création des configurations du tri du tableau
	var headersList = rb_table.find('tr th');
	var headersConf = {};
	for (i=0; i<headersList.length; i++) 
	{
		// pour la colonne thumbs+infos
		if (i == 1) {
			headersConf[i] = {sorter:false};
		} 
		// pour la colonne prix
		else
		if (i == 8) {
			// pas de config
		} 
		// pour toutes les autres
		else {
			//headersConf[i] = {lockedOrder:1};
		}
	}
	
	// activation du tri du tableau
	rb_table.tablesorter(
	{
		// empèche le tri sur la colonne 'infos'
		headers:headersConf,
		// tri par défaut sur le score
		sortList:[[3,1]],
		widgets: ['zebra','repeatHeaders'] ,
		// extraction des valeur de tri
		textExtraction:function(node) 
		{
			// convertion en jquery
			node = $(node);
			// pour les colonnes label (star/gooddeal)
			if (node.hasClass('label')) {
				// retour des valeurs (start=2, gooddeal=1, sinon=0)
				if (node.parent().hasClass('star')) return 2;
				if (node.parent().hasClass('gooddeal')) return 1;
				else return 0;
			}
			// pour les autres colonnes : contenu du champs <var> ou tout
			return $(node).find('var').text() || $(node).text();
		}
	});
}

//----------------------------------
//  TOGGLE
//----------------------------------

/**
 *  Affiche le tableau.
 */
function rb_showTable()
{
	// tableau
	rb_table.show();
	// boutons
	rb_toggleOn.hide();
	rb_toggleOff.show();
	return false;
}

/**
 *  Masque le tableau.
 */
function rb_hideTable()
{
	// tableau
	rb_table.hide();
	// boutons
	rb_toggleOn.show();
	rb_toggleOff.hide();
	return false;
}
			

