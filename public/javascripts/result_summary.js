/**
 *  rs = result_summary
 */

//--------------------------------------------------------------------
//  PROPERTIES
//--------------------------------------------------------------------

//----------------------------------
//  ELEMENTS VISUELS
//----------------------------------

var rs_list;

var rs_nav;
var rs_nav_track;
var rs_nav_trackContent;
var rs_nav_thumb;
var rs_nav_thumbLeft;
var rs_nav_thumbRight;
var rs_nav_thumbCenter;
var rs_nav_min;
var rs_nav_mid;
var rs_nav_max;

//----------------------------------
//  CONFIG
//----------------------------------

// nbr de produits visibles
var rs_visibleProducts = 3;

//----------------------------------
//  VARIABLES
//----------------------------------

// nbr total de produits
var rs_totalProducts = -1;

// id du produit affiché à gauche
var rs_currentProduct = -1;

// valeur max de currentProduct
var rs_currentProductMax = -1;

// largeur des produits dans la scrollbar
var rs_stepWidth = -1;

//--------------------------------------------------------------------
//  METHODS
//--------------------------------------------------------------------

//----------------------------------
//  INIT
//----------------------------------

/**
 *  Initialisation du sommaire des résultats.
 */
function rs_init(listId, navId, visibleProducts) 
{
	// paramètres de la méthode
	rs_list = $(listId);
	rs_nav = $(navId);
	if (visibleProducts && visibleProducts > 0)
		rs_visibleProducts = visibleProducts;
	
	// récupération des éléments visuels
	rs_nav_track = rs_nav.find('.track');
	rs_nav_trackContent = rs_nav.find('.track .content');
	rs_nav_thumb = rs_nav.find('.thumb');
	rs_nav_thumbLeft = rs_nav.find('.thumb .left');
	rs_nav_thumbRight = rs_nav.find('.thumb .right');
	rs_nav_thumbCenter = rs_nav.find('.thumb .center');
	rs_nav_min = rs_nav.find('.min');
	rs_nav_mid = rs_nav.find('.mid');
	rs_nav_max = rs_nav.find('.max');
	
	// récupération des scores des produits
	var scores = rs_list.find('td.product.score');
	
	// nombre de produits
	rs_totalProducts = scores.length;
	
	// currentProduct min et max
	rs_currentProductMax = rs_totalProducts - rs_visibleProducts;
	rs_stepWidth = Math.floor(rs_nav_trackContent.width() / rs_totalProducts);
	
	// initialisations
	rs_initTrack(scores);
	rs_initThumb();
	rs_initArrows();
	rs_initToggle();
	
	// mises à jour
	rs_updateList();
	rs_updateScroll(0);
}

//----------------------------------
//  TRACK
//----------------------------------

/**
 *  Initialise le track.
 */
function rs_initTrack(scores) 
{
	// création du dégradé de la navigation
	rs_nav_trackContent.width(rs_stepWidth * rs_totalProducts);
	var midPositionIsSet = false;
	for (i = 0; i < rs_totalProducts; i++) 
	{
		// création d'une cellule à partir celle du score
		$('<span class="' + $(scores[i]).attr('class') + '"></span>').
			// suppression des classes de la cellule copiée
			removeClass('product').removeClass('score').
			// ajout de styles spécifiques
			css('display','inline-block').
			// définition de la taille
			width(rs_stepWidth+'px').height('100%').
			// ajout au rs_nav_trackContent
			appendTo(rs_nav_trackContent);
		
		// positionnement du mid
		if (!midPositionIsSet) {
			// récupération du score
			var score = parseInt($(scores[i]).find('var').text());
			if (score >= 100) { 
				midPositionIsSet = true;
				// mid hors liste à gauche
				if (i == 0) {
					rs_nav_mid.hide();
					rs_setCurrentProduct(0);
				} 
				// mid positionné dans la liste
				else {
					rs_setCurrentProduct(Math.round(i - rs_visibleProducts/2));
					rs_nav_mid.css('left', (rs_stepWidth * i - rs_nav_mid.width()/2) + 'px');
				}
			}
		}
	}
	// mid hors liste à droite
	if (!midPositionIsSet) {
		rs_nav_mid.hide();
		rs_setCurrentProduct(rs_currentProductMax);
	}
}

//----------------------------------
//  THUMB
//----------------------------------

/**
 *  Initialise le thumb.
 */
function rs_initThumb() 
{
	
	// ajustement de la taille
	rs_nav_thumb.width(rs_stepWidth * rs_visibleProducts);
	rs_nav_thumbCenter.width(rs_nav_thumb.width() - rs_nav_thumbLeft.outerWidth(true) - rs_nav_thumbRight.outerWidth(true));
	
	// activation du drag
	rs_nav_thumb.draggable({
		addClasses:false, axis:'x',
		containment:rs_nav_trackContent,
		drag:rs_nav_thumb_onDrag
	});
}

/**
 *  Ecoute l'évènement de drag du thumb.
 */
function rs_nav_thumb_onDrag(e) 
{
	// position du thumb
	var left = rs_nav_thumb.position().left;
	// identifiant du produit ciblé
	rs_setCurrentProduct(Math.round(left / rs_stepWidth), true);
}

//----------------------------------
//  ARROWS
//----------------------------------

/**
 *  Initialise les flèches de la navigation.
 */
function rs_initArrows()
{
	// event listeners : flèches
	rs_nav.find('.arrow.prev').click(rs_prevProduct);
	rs_nav.find('.arrow.next').click(rs_nextProduct);
}

/**
 *  Déplace la liste vers la gauche.
 */
function rs_prevProduct() 
{
	rs_setCurrentProduct(rs_currentProduct-1, true, true);
	return false;
}

/**
 *  Déplace la liste vers la droite.
 */
function rs_nextProduct() 
{
	rs_setCurrentProduct(rs_currentProduct + 1, true, true);
	return false;
}

//----------------------------------
//  CURRENT PRODUCT
//----------------------------------

/**
 *  Change la valeur du current product dans les limites.
 */
function rs_setCurrentProduct(value, updateList, updateScroll) 
{
	if (value < 0) value = 0;
	if (value > rs_currentProductMax) value = rs_currentProductMax;
	if (value == rs_currentProduct) return;
	
	rs_currentProduct = value
	
	// mises à jour
	if (updateList) rs_updateList();
	if (updateScroll) rs_updateScroll();
}

//----------------------------------
//  UPDATES
//----------------------------------

/**
 *  Met à jour la liste de produits.
 */
function rs_updateList() 
{
	var min = rs_currentProduct;
	var max = min + rs_visibleProducts;
	for (i = 0; i < rs_totalProducts; i++) {
		if (i >= min && i < max)
			rs_list.find('td.product.p' + i).show();
		else
			rs_list.find('td.product.p' + i).hide();
	}
}

/**
 *  Met à jour la barre de navigation
 */
function rs_updateScroll(duration) 
{
	if (duration == null) duration = 100;
	rs_nav_thumb.animate({
		left:rs_currentProduct * rs_stepWidth
	}, duration);
}

//----------------------------------
//  TOGGLE DETAILS
//----------------------------------

/**
 *  Initialisation des flèches du toggle.
 */
function rs_initToggle()
{
	// event listeners : toggle
	rs_list.find('.toggle .on').click(rs_showDetails);
	rs_list.find('.toggle .off').click(rs_hideDetails);
	rs_hideDetails();
}

/**
 *  Affiche les détails
 */
function rs_showDetails()
{
	// affiche la ligne
	rs_list.find('tr.spec').show();
	// affiche/masque les boutons
	rs_list.find('.toggle .on').hide();
	rs_list.find('.toggle .off').show();
	return false;
}

/**
 *  Masque les détails
 */
function rs_hideDetails()
{
	// affiche la ligne
	rs_list.find('tr.spec').hide();
	// affiche/masque les boutons
	rs_list.find('.toggle .on').show();
	rs_list.find('.toggle .off').hide();
	return false;
}
			

