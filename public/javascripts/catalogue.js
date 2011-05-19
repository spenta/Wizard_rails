// --- Tri par titre caché  > A CONSERVER AVANT L'INITIALISATION DE LA TABLE

$j.fn.dataTableExt.oSort['title-numeric-asc']  = function(a,b) {
	var x = a.match(/title="*(-?[0-9]+)/)[1];
	var y = b.match(/title="*(-?[0-9]+)/)[1];
	x = parseFloat( x );
	y = parseFloat( y );
	return ((x < y) ? -1 : ((x > y) ?  1 : 0));
};

$j.fn.dataTableExt.oSort['title-numeric-desc'] = function(a,b) {
	var x = a.match(/title="*(-?[0-9]+)/)[1];
	var y = b.match(/title="*(-?[0-9]+)/)[1];
	x = parseFloat( x );
	y = parseFloat( y );
	return ((x < y) ?  1 : ((x > y) ? -1 : 0));
};

// --- Filtrage entre valeurs minimales et maximales

// Prix
$j.fn.dataTableExt.afnFiltering.push(
	function( oSettings, aData, iDataIndex ) {
		var priceMin = $j('#price_slider').slider( "values", 0 ) * 1;
		var priceMax = $j('#price_slider').slider( "values", 1 ) * 1;
		var priceRaw = aData[1];
		var priceSplitAfter = priceRaw.split("\=")[3];
		var priceSplit = priceSplitAfter.split(">")[0];
		var price = eval(priceSplit);
		if ( priceMin <= price && price <= priceMax ) { return true; }
		return false;
	}
);

// Specs
$j.fn.dataTableExt.afnFiltering.push(
	function( oSettings, aData, iDataIndex ) {
		var specCheck = 0;
		for (sliderIndex = 1;sliderIndex <= 6;sliderIndex=sliderIndex + 1) {
			var columnIndex = sliderIndex+1;
				var specMin = $j("#slider_" + sliderIndex ).slider( "values", 0 ) * 1;
				var specMax = $j("#slider_" + sliderIndex).slider( "values", 1 ) * 1;
				var specRaw = aData[columnIndex];
				var specSplitAfter = specRaw.split("\=")[1];
				var specSplit = specSplitAfter.split(">")[0];
				var spec = eval(specSplit);
				if ( specMin <= spec && spec <= specMax ) { specCheck = specCheck + 1 }
			}
	  if ( specCheck == 6 ) { return true; }
		return false;
	}
);

