// Sets the width of the specs rating bars to the values loaded in the .html
$j(document).ready(function() {
	for (bar_index = 1 ; bar_index <= 6 ; bar_index = bar_index + 1) {
		var bar_value = eval("bar_length_" + bar_index) ;
		$j("#bar_" + bar_index).css('width',barResize(bar_value) +'%');
	}
});

// Increase the length of the bar so that low scores don't look so crappy
function barResize(valIn) { return ((valIn + 1) / 11) * 100; }

// Resizes the product picture so that it fits in the box without distorsion
$j(document).ready(function() {
	$j( "#picture" ).aeImageResize({ height: 216, width: 326 });
});

$j(document).ready(function() {
	$j( ".thumbnail" ).aeImageResize({ height: 80, width: 120 });
});

$j(document).ready(function() {
	$j( ".retailer_logo" ).aeImageResize({ height: 60, width: 112 });
});

$j(document).ready(function() {
	$j( ".specs_table tbody tr:odd" ).css( "background-color" , "#EFF7FB" );
});

// Zoom popup
$j(document).ready(
  function() {
    $j('#popup').hide();
    $j('#overlay').hide();

    $j('#zoom').click(
      function()
      {
        $j('#popup').toggle();
        $j('#overlay').toggle();
      }
    );

    $j('#popup').click(
      function()
      {
        $j('#popup').toggle();
        $j('#overlay').toggle();
      }
    );
  }
);

