// ----- Toggle pour dérouler les caractéristiques des PC stars -----
		$(document).ready(
			function() {
				$("#ExpandButton").html("<tr><td colspan='8' class='toggle'><a href='#'>&#62; Pourquoi recommandons-nous ces PC ? Cliquez ici &#60;</a></td></tr>");
				$("#HideButton").html("<td colspan='8' class='toggle'><a href='#'>&#62; Cacher le d&eacute;tail des notes &#60;</a></td></tr>");
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