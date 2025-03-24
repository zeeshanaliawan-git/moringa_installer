function disabledAll(){
	$("input[type=text]:not(#d1,#d2),select:not(select[id=liste_requete])").attr("disabled",true).attr("title","Non disponible pour la requête sélectionné").css("border","1px solid red");
	//$("input[id=liste_requete]").attr("disabled",false);
	
	
}             

function getFieldEnabled(nom){
	var n = new Array();
	nom = nom.toLowerCase();
	if(nom.indexOf("a -")!=-1){// informe extendido
		n= new Array("displayName","MOTIVO_ULTIMO_ESTADO");

	}
	if(nom.indexOf("b -")!=-1){// informe extendido new
		n= new Array("displayName");

	}
	
	if(nom.indexOf("c -")!=-1){// informe extendido new
		n= new Array("displayName");

	}
	
	if(nom.indexOf("f4")!=-1){
			//n= new Array("FECHA_ULTIMO_ESTADO");
	}
	
	if(nom.indexOf("g -")!=-1){// informe facturacion
		n= new Array("NUMERO_ORDEN","Id_Pedido_Guizmo","NOMBRE","APELLIDOS","DOCUMENTO_DE_IDENTIDAD");
	}
	return(n);
}


function enabled1(t){
	disabledAll();
	var n = getFieldEnabled(t[t.selectedIndex].text);
	for(var z=0;z<n.length;z++){
		//alert(n[z])
		$("input[id="+n[z]+"],select[id="+n[z]+"]").attr("disabled",false).css("border","1px solid blue").attr("title","");
	}
}