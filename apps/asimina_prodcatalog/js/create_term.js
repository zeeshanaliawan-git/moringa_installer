/**
 * 
 */



function verif_mob(constructeur,modele){
	$.ajax({
        url: getContextPath()+"js/verif_modele.jsp",
        dataType: "html",
        data: {
      	  constructeur : constructeur,
      	  modele : modele
        },

        success: function( data ) {
          //show(data);
        	alert(data);
        	$("#result_verif_term").html(data)  ;
        }

      });
}