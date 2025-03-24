

/**
 * Table updabtable : alban@etancesys/nicolas@etancesys.com
*/
var cur = null;    // cellule courante
var otext = null;  // text de la cellule courante
var inp;           // input flottant pour la saisie
var updts = ""; // les cellules modifiées
var url_save = "/mshop/stock/save_stock.jsp"; 

function doNothing(){}

function editChange( o )
{
	//alert("ici==>"+o);
	var tab_s = document.getElementById("tab_stock");
	var tag1 = o.tagName;
	var td = o.parentNode;
	var tr = o.parentNode.parentNode;
	var tipo1 = document.getElementById("tipo");
	var b = tab_s.rows[tr.rowIndex].cells[a].innerHTML;
	
	var c = td.cellIndex;//""+tab_s.rows[0].cells[td.cellIndex].innerHTML;
	
	
	var valeur1 = "";
	if(tag1 == "INPUT" || tag1 == "TEXTAREA" ){
		if(tag1 == "INPUT" && o.type == "checkbox"){
			valeur1 = (o.checked?"1":"0");
		}else{
		valeur1 = o.value;
		}
	}else{
			if(tag1 == "SELECT"){
				valeur1 = o[o.selectedIndex].value;
			}
	}
		var d1= "champ="+c+"&valeur="+valeur1+"&cle="+a+"&cle_v="+b+"&tipo="+tipo1[tipo1.selectedIndex].text;
		//alert(d1);
	$.ajax({
		type: "POST",
		url: url_save,
		data: d1,
		dataType: "json",
		context : o,
		contentType: "application/x-www-form-urlencoded;charset=utf-8", 
		success: function(html){       
		var o = $(this).context;
		editChange2(html,o);
			
			},
		error:function (xhr, ajaxOptions, thrownError){ 
	            alert("Err editChange ");
	        }  
		  }); 
}


function editChange2(t,o){
	var tab_s = document.getElementById("tab_stock");
	var tr = o.parentNode.parentNode;
	
	
	var tag1 = o.tagName;
	
	//alert(o);
	//alert(c);
	//td.cellIndex
	//alert(t);
	//alert(t.date_update);
	if( parseInt(t.cmd,10)<=-1){
		alert("Erreur");
		return(false);
	}
	
	
	
	//alert("'"+t.date_update+"'");
	

	
	if(tag1 != "SELECT" && o.type!="checkbox"){
		if( otext.nodeValue != o.value )
	  	{ 
	  var row = cur.parentNode;
	    var datas = row.getAttribute("valeur");
	   
	    s = "_"+cur.cellIndex+"=" ;
	   
	    if( !datas ) datas = s+o.value+";";
	    else 
	     { i = datas.indexOf(s);
	       if( i != -1)
	         datas = datas.substring(0,i)+
	                   datas.substring(datas.indexOf(';',i+1)+1);
	       datas += s+o.value+";"
	     }
	    //alert(datas)
	    row.setAttribute("valeur" , datas);
	    otext.nodeValue = o.value;
	    //document.getElementById("dbg").value += "\n"+datas;
	
	  
	    
	  }
		  var dv = document.getElementById("D1");
			dv.appendChild( cur.replaceChild(otext, o));
			
			
			
			
		    cur.normalize();
			  dv.normalize();
	
	}
	setInfo(tr,t);
	
 /* var dv = document.getElementById("D1");
  dv.appendChild( cur.replaceChild(otext, o));
  cur.normalize();
  dv.normalize();*/
	
	 $("#tab_stock").trigger("update"); 
  return(true);
}



function edit(obj)
{
 if( obj.length != 1 ) return;
 cur = obj[0];
//alert(cur);
 inp = document.getElementById('inp');

 with( cur )
 {
   if(!firstChild) 
     appendChild( document.createTextNode("") );

   otext = replaceChild(inp,firstChild);
   //inp.value = otext.nodeValue;
   inp.value = "";
   inp.focus();
   inp.value = otext.nodeValue;
   if(inp.value!=""){
	   
	    var val1=inp.value;
 	    inp.value = jQuery.trim(val1); 
   }

 }

 cur.normalize();
 inp.focus();

}

function soumet(sbm)
{
  var s = "";

  with(document.getElementById("tb"))
  { for( var i = 0 ; i < rows.length ; i++ )
    { if( v = rows[i].getAttribute("valeur") )
        s +=  rows[i].getAttribute("cle")+":"+v+"\n";
    }
  }
  if( s.length == 0 ) return( false);
  sbm.form.datas.value = s;
  return( true);
}
     
function ajout(o1){
	
	var o = o1.parentNode.parentNode;
//	show(o1);
	var s="";
	var tab = new Array("codesap","marca2","description","terminalARPA","stock_saisie");
	var u ="";
	for(var i=0;i<tab.length;i++){
		var d = document.getElementById(""+tab[i]);
		//alert(d.tagName+"==>"+d.name)
		if(d!=null){
			if(d.tagName == "INPUT"){
				u+=(u==""?"":"&")+tab[i]+"="+d.value;
				if(d.value==""){
					s+="\n"+d.getAttribute("libelle");
				}
			}else{
				if(d.tagName == "SELECT"){
					u+=(u==""?"":"&")+tab[i]+"="+d[d.selectedIndex].value;
				}
			}
		}
	}
	var tipo1 = document.getElementById("tipo");
	u+="&tipo="+tipo1[tipo1.selectedIndex].text;
	
	
	if(s!=""){
		alert("Veuillez renseigner :"+s);
	}else{	
	u+="&s=1"
	//alert("u="+u);
	$.ajax({
		type: "POST",
		url: url_save,
		data: u,
		dataType: "json",
		context : o,
		success: function(html){       
			var o = $(this).context;
			//show(html)	
			//show(html); 	
			//try{
				if(html.cmd > 0 ){
					
					newRow(o);
					getData(o,html);
					//evt1();
					var tab3 = document.getElementById("tab_stock");	
					document.getElementById("nb_ligne_tab").innerHTML = parseInt(tab3.rows.length,10)-2;	
					
				}else{
					if(html.cmd == -2){
						alert(html.cmd_err+" existe déjà");
					}else{
						alert("Erreur insert");
					}
				}
				
				/*}catch(err){
					alert(err.description)
				}*/
			
			},
		error:function (xhr, ajaxOptions, thrownError){ 
	            //alert(xhr.status); 
	            //alert("err ajout1\n"+ xhr.responseText);
					alert("Erreur ajout");
	        }  

		  }); 

	}
}

function newRow(o){
	//try{
	var nbr = 10;	//nombre de ligne maximum

	var tab = document.getElementById("tab_stock");		//Le tableau
	var l = tab.rows.length;							//Le nombre de ligne du tableau
	var tr = tab.getElementsByTagName("TR")[l-1];		//Denière ligne du tableau
	
	//AJOUTE UNE LIGNE
		n = tr.cloneNode(true);
		tr.parentNode.appendChild(n);
		
		var nb = 3;
		var tipo1 = document.getElementById("tipo");
		if( tipo1.selectedIndex == 1 ){
			nb = 5;
		}
		
		for( var c=0; c < nb;c++){
			//alert(n.cells[c].tagName);
			n.cells[c].firstChild.nodeValue = "";  //efface la copie de la valeur des champs ligne -1
		}

		tr.normalize();
		//evt1();
	/*}catch(err){
		alert("Erreur création nouvelle ligne ! \n"+err.description);		
	}*/
	
}

function getResults(postData){
	//alert(postData);
	showProcessing();
	$.post('stock_result.jsp',postData, function(data) {
		//alert(data);
		$('#resultsDiv').html(data);
	});
}
function showProcessing(){
	$('#resultsDiv').html("<center>Carga corriente, Patiente por favor<br><div style='text-align:center;'><img alt='Chargement en cours, veuillez patienter' src='../img/ajax-loader.gif'/></div></center>");
}

function selectTipo(t){
	//getResults(getSearchData());
	var td_marcaA = document.getElementById("td_marca1");
	var td_marcaB = document.getElementById("td_marca2");
	//alert("a="+t.selectedIndex)
	if(t.selectedIndex==0){
		td_marcaA.style.display = "";
		td_marcaB.style.display = "";
		
		for(var i=0;i<11;i++){
			document.getElementById("td_stock"+i).style.display ="";
		}
		
		
	}else{
		td_marcaA.style.display = "none";
		td_marcaB.style.display = "none";
		
		if(t.selectedIndex==3){
			for(var i=0;i<11;i++){
				document.getElementById("td_stock"+i).style.display ="none";
			}
			
		}else{
			td_marcaA.style.display = "none";
			td_marcaB.style.display = "none";
			
			for(var i=0;i<11;i++){
				document.getElementById("td_stock"+i).style.display ="";
			}
		}
	}
	
	
}

function getSearchData(){
	var s1 = document.getElementById("choix1");
	var s2 = document.getElementById("choix2");
	var co = document.getElementById("col1");
	var tipo1 = document.getElementById("tipo");
	
	var data = "";
	data += "referencia="+document.getElementById("referencia").value;
	data += "&descripcion_ref="+document.getElementById("descripcion_ref").value;
	data += "&stock_disponible_portabilidad="+document.getElementById("stock_disponible_portabilidad").value;
	data += "&stock_virtuel="+document.getElementById("stock_virtuel").value;
	data += "&col1="+co[co.selectedIndex].value;//document.getElementById("col1").value
	data += "&signe1="+s1[s1.selectedIndex].value+"";
	data += "&signe2="+s2[s2.selectedIndex].value+"";
	data += "&tipo="+tipo1[tipo1.selectedIndex].text;
	data += "&marca="+document.getElementById("marca").value;
	//alert(data);
	
	return data;
}

function supprC(codesap){
	//alert(""+codesap);
	var tipo1 = document.getElementById("tipo");
	if(confirm("Etes-vous sûr de vouloir supprimer cette ligne ?")){
		$.ajax({
			type: "POST",
			url: url_save,
			data: "codesap="+codesap+"&s=2&tipo="+tipo1[tipo1.selectedIndex].text,
			dataType: "json",
			success: function(html){       
				
					if(html.cmd > 0 ){
						alert("Terminal supprimé");
						getResults(getSearchData());
					}else{
							alert("Erreur suppression");
					}
				},
			error:function (xhr, ajaxOptions, thrownError){ 
						alert("Erreur supprC");
		        }  

			  }); 
	}else{
		alert("Action annulée");
	}
}


function doTri(){
	$("#tab_stock").tablesorter({ headers: { 8: { sorter: false},11: { sorter: false} ,12: { sorter: false} ,13: { sorter: false},14: { sorter: false} } } ); 
}

/**********************/


$(document).ready(function() 
    { 
//alert("ici");
getResults(getSearchData());



$('td[class=m]').live('dblclick', function() {
	   edit($(this));
	 });



$('input[name=c],input[name=c1],select[class=s]').live('click', function()  {
	//alert("coucou2");
	editChange($(this)[0]);
	//show($(this)[0]);
 });  

    }
); 
