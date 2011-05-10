$j = jQuery.noConflict();

$j(document).ready(
    function() {
        $j('#popup').hide();
        $j('#overlay').hide();

        $j('.next-button').click(
            function()
            {
                $j('#popup').toggle();
                $j('#overlay').toggle();
            }
            );
    }
    );

