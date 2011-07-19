$j = jQuery.noConflict();

$j(document).ready(
    function() {
      $j('#popup').hide();
      $j('#overlay').hide();
      $j('#wait_1').hide();
      $j('#wait_2').hide();
      $j('#wait_3').hide();
      $j('.retailer_logo').hide();

      $j('.next-button').click(
        function()
        {
          $j('#popup').toggle();
          $j('#overlay').toggle();
          $j('#wait_1').delay(50).fadeIn('slow');
          $j('#wait_2').delay(200).fadeIn('slow');
          $j('#wait_3').delay(300).fadeIn('slow');
          var currentDelay = 300;
          if ($j.browser.msie ) {
            $j('.retailer_logo').show();
          }
          else {
            var retailers = $j('.retailer_logo');
            for (var i=0; i<retailers.length; i++) {
              currentDelay += 50 + 150 * Math.random();
              $j('.retailers .retailer_logo:nth-child('+(i+1).toString()+')').delay(currentDelay).fadeIn('Slow');
            }
          }
        }
      );
    }
);

