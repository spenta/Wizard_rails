// Sets the width of the specs rating bars to the values loaded in the .html
$(document).ready(function() {
	for (bar_index = 1 ; bar_index <= 6 ; bar_index = bar_index + 1) {
		var bar_value = eval("bar_length_" + bar_index) ;
		$("#bar_" + bar_index).css('width',barResize(bar_value) +'%');		
	}
});

// Increase the length of the bar so that low scores don't look so crappy
function barResize(valIn) { return ((valIn + 1) / 11) * 100; }

// Resizes the product picture so that it fits in the box without distorsion
$(document).ready(function() {
	$( "#picture" ).aeImageResize({ height: 216, width: 326 });
});

$(document).ready(function() {
	$( ".thumbnail" ).aeImageResize({ height: 80, width: 100 });
});

$(document).ready(function() {
	$( ".retailer_logo" ).aeImageResize({ height: 80, width: 70 });
});

$(document).ready(function() {
	$( ".specs_table tbody tr:odd" ).css( "background-color" , "#EFF7FB" );
});