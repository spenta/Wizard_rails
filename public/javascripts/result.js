// ----- Toggle pour dérouler les caractéristiques des PC stars -----
		$(document).ready(
			function() {
				$("#Collapsable").hide();
				$("#HideButton").hide();

				$('#ExpandButton,#HideButton').click( 
					function() 
						{
							$('#Collapsable').toggle();  
							$('#ExpandButton').toggle();
							$('#HideButton').toggle();
						}
					);
				}
			);
		
// ----- Tri de la table -----
		$(document).ready(
			function() 
				{ 
        			$("#extratable").tablesorter(
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