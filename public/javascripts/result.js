$j = jQuery.noConflict();
// ----- Toggle pour dérouler les caractéristiques des PC stars -----
$j(document).ready(
    function() {
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

// ----- Tri de la table -----
  $j(document).ready(
      function()
      {
        $j("#extratable").tablesorter(
          {
            headers:
            {
              0: { sorter:false },
              1: { sorter:false }
            },
            textExtraction:
            function(node) {
              var htmlContent = node.innerHTML.split("<")[1];
              var number = htmlContent.split(">")[1];
              return number.length.toString()+number;
            }
          }
          );
      }
      );

