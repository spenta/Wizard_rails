$j = jQuery.noConflict();

$j(document).ready(
    function() {
        $j('#popup').hide();
        $j('#overlay').hide();
        $j('#wait_1').hide();
        $j('#wait_2').hide();
        $j('#wait_3').hide();

        $j('.next-button').click(
            function()
            {
                $j('#popup').toggle();
                $j('#overlay').toggle();
                $j('#wait_1').delay(600).fadeIn('slow');
                $j('#wait_2').delay(1800).fadeIn('slow');
                $j('#wait_3').delay(2400).fadeIn('slow');
            }
            );
    }
    );

