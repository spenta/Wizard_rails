// --- Tri par titre caché  > A CONSERVER AVANT L'INITIALISATION DE LA TABLE

jQuery.fn.dataTableExt.oSort['title-numeric-asc']  = function(a,b) {
	var x = a.match(/title="*(-?[0-9]+)/)[1];
	var y = b.match(/title="*(-?[0-9]+)/)[1];
	x = parseFloat( x );
	y = parseFloat( y );
	return ((x < y) ? -1 : ((x > y) ?  1 : 0));
};

jQuery.fn.dataTableExt.oSort['title-numeric-desc'] = function(a,b) {
	var x = a.match(/title="*(-?[0-9]+)/)[1];
	var y = b.match(/title="*(-?[0-9]+)/)[1];
	x = parseFloat( x );
	y = parseFloat( y );
	return ((x < y) ?  1 : ((x > y) ? -1 : 0));
};
	
// --- Filtrage entre valeurs minimales et maximales
	
// Prix
$.fn.dataTableExt.afnFiltering.push(
	function( oSettings, aData, iDataIndex ) {
		// Extraction du prix
		var priceMin = $('#price_slider').slider( "values", 0 ) * 1;
		var priceMax = $('#price_slider').slider( "values", 1 ) * 1;
		var priceRaw = aData[1];
		var priceSplitAfter = priceRaw.split("\"></span>")[0];
		var price = priceSplitAfter.split("title=\"")[1] * 1;	
		// Logique de filtrage du prix
		if ( priceMin <= price && price <= priceMax ) { return true; }
		return false;
	}
);
	
// Specs
$.fn.dataTableExt.afnFiltering.push(
	function( oSettings, aData, iDataIndex ) {		
		
		var specCheck = 0;
		// Boucle pour voir si chaque caractéristique d'un produit (extraite de aData) est bien entre les fourchettes.
		for (sliderIndex = 1;sliderIndex <= 6;sliderIndex=sliderIndex + 1) {
			var columnIndex = sliderIndex+1; // Les deux premières colonnes de la liste correspondent au nom et au prix
				var specMin = $("#slider_" + sliderIndex ).slider( "values", 0 ) * 1;
				var specMax = $("#slider_" + sliderIndex).slider( "values", 1 ) * 1;
				var specRaw = aData[columnIndex];
				var specSplitAfter = specRaw.split("\"></span>")[0];
				var spec = specSplitAfter.split("title=\"")[1] * 1;	
				if ( specMin <= spec && spec <= specMax ) { specCheck = specCheck + 1 }
			}
			// On vérifie que les 6 conditions sont validées
			if ( specCheck == 6 ) { return true; }
			// Sinon on filtre
			return false;
	}
);



