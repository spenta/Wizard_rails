var $j = jQuery.noConflict();
$j(document).ready(
    function() {
      $j("#ExpandButton").html("<tr><td colspan='8' class='toggle'><a href='#'>&#62; Pourquoi recommandons-nous ces PC ? Cliquez ici &#60;</a></td></tr>");
      $j("#HideButton").html("<td colspan='8' class='toggle'><a href='#'>&#62; Cacher le d&eacute;tail des notes &#60;</a></td></tr>");
      $j("#Collapsable").hide();
      $j("#HideButton").hide();

      $j('#ExpandButton,#HideButton').click( 
        function() 
        {
          $j('#Collapsable').toggle();  
          $j('#ExpandButton').toggle();
          $j('#HideButton').toggle();
        }
        );
    }
    );

  $j(document).ready(
      function() 
      { 
        $j("#extratable").tablesorter(
          {
            headers: 
        {
          0: { sorter:false },
          1: { sorter:false }
        }
          }
          ); 
      } 
      ); 
