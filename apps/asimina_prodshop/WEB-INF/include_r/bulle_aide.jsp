<%!String creer_div(String str,String nom){
	String b = "";
	b="<div id=\""+nom+"\" class=\"infohisto\"  ";
	b+=" style=\"display: none;position: absolute;z-index: 100;padding: 2px;\">";
	b+=""+str+"";
	b+="</div>";
	b+="<iframe frameborder=\"no\"  class=\"infohisto2\" id=\"ifr_"+nom+"\" style=\"overflow:auto;display:none;width:450px;\" frameborder='0' border='0'  src='vide.htm'  ></iframe>";
	return(b);
}

String bulle_aide(String str,String nom){
	String b = "";
	b = "<img id=\"aide3noprint\" src=\"/gizmo/public/img2/aide.png\" border=\"0\" style=\"cursor: pointer;vertical-align: top;\" onmouseout=\"CacheDiv('"+nom+"',event);\" onmouseover=\"bougeDiv('"+nom+"',event);\">";
	b+="<div id=\""+nom+"\" class=\"infohisto\"  ";
	b+=" style=\"display: none;position: absolute;z-index: 100;padding: 2px;\">";
	b+=""+str+"";
	b+="</div>";
	b+="<iframe frameborder=\"no\"  class=\"infohisto2\" id=\"ifr_"+nom+"\" style=\"overflow:auto;display:none;width:450px;\" frameborder='0' border='0'  src='vide.htm'  ></iframe>";
	return(b);
}

String bulle_aide(String str,String nom,String html,String texte){
	String b = "";
	b+="<div id=\""+nom+"\" class=\"infohisto\"  ";
	b+=" style=\"display: none;position: absolute;z-index: 100;padding: 2px;\">";
	b+=""+str+"";
	b+="</div>";
	b+= "<a "+html+" onblur=\"CacheDiv('"+nom+"',event);\" onmouseover=\"bougeDiv('"+nom+"',event);\">"+texte;
	b+= "</a>";
	b+="<iframe frameborder=\"no\"  class=\"infohisto2\" id=\"ifr_"+nom+"\" style=\"overflow:auto;display:none;width:450px;\" frameborder='0' border='0'  src='vide.htm'  ></iframe>";
	return(b);
}


String bulle_aide_fichier2(String nom){
	  String b = "";
	  b+="<div id=\""+nom+"\" class=\"infohisto\"  ";
	  b+=" style=\"display: none;position:absolute;z-index: 100;padding: 2px;\">";//position: absolute;
	  b+="</div>";
	  //b+= "</div>";
	  b+="<iframe frameborder=\"no\"  class=\"infohisto2\" id=\"ifr_"+nom+"\" style=\"left:25%;top:420px;overflow:auto;display:none;width:600px;height:300px;\" frameborder='0' border='0'  src='vide.htm'  ></iframe>";
	  return(b);
	}

	String bulle_aide_fichier3(String str,String nom,String html,String texte,String fichier){
		String b = "";
		b+="<div id='"+nom+"' class=\"infohisto\"  ";
		b+=" style=\"display: none;position:absolute;z-index: 100;padding: 2px;\">";//position: absolute;
		b+=""+str+"";
		b+="</div>";  
		b+= "<input class='infooff' type='button' value=\""+texte+"\" "+html+" onblur=\"CacheDiv('"+nom+"',event);className='infooff';\" onclick=\"appel_fichier('"+nom+"','"+fichier+"');bougeDiv2('"+nom+"',event);className='infoclic';\">";
		//b+= "</div>";
		b+="<iframe frameborder=\"no\"  class=\"infohisto2\" id=\"ifr_"+nom+"\" style=\"overflow:auto;display:none;width:250px;\" frameborder='0' border='0'  src='vide.htm'  ></iframe>";
		return(b);
	}
	
String bulle_aide_fichier4(String str,String nom,String html,String texte,String fichier){
	String b = "";
	b+="<div id='"+nom+"' class=\"infohisto\"  ";
	b+=" style=\"display: none;position:absolute;z-index: 100;padding: 2px;\">";//position: absolute;
	b+=""+str+"";
	b+="</div>";  
	b+= "<img src='img2/cadeau.png' title='cliquer pour afficher les compensations' value=\""+texte+"\" "+html+"  onclick=\"appel_fichier('"+nom+"','"+fichier+"');parent.compensation('"+nom+"');bougeDiv('"+nom+"',event);\">";
	//b+= "</div>";
	b+="<iframe frameborder=\"no\"  class=\"infohisto2\" id=\"ifr_"+nom+"\" style=\"top:120px;overflow:auto;display:none;width:400px;\" frameborder='0' border='0'  src='vide_fid.htm'></iframe>";
	return(b);
}


String bulle_aide_fichier5(String str,String nom,String html,String texte,String f){
	String b = "";
	b+="<div id='"+nom+"' class=\"infohisto\"  ";
	b+=" style=\"display: none;position:absolute;z-index: 100;padding: 2px;\">";//position: absolute;
	b+=""+str+"";
	b+="</div>";  
	b+= "<input type='button' value=\""+texte+"\" "+html+" onblur=\"CacheDiv('"+nom+"',event);\" onclick=\"affiche_info('"+nom+"','"+f+"');\">";
	//b+= "</div>";
	b+="<iframe frameborder=\"no\"  class=\"infohisto2\" id=\"ifr_"+nom+"\" style=\"left:100px;top:120px;overflow:auto;display:none;width:400px;\" frameborder='0' border='0'  src='vide_fid.htm'></iframe>";
	return(b);
}

String bulle_aide_javascript(String str,String nom,String html,String texte,String f_javascript,String evt1,String evt2){
        String b = "";
        b+="<div id='"+nom+"' class=\"infohisto\"  ";
        b+=" style=\"display: none;position:absolute;z-index: 100;padding: 2px;\">";//position: absolute;
        b+=""+str+"";
        b+="</div>";
        b+= "<input type='button' value=\""+texte+"\" "+html+" "+(evt1.equals("")?"":"CacheDiv('"+nom+"',event);")+" "+evt2+"=\"bulle_aide_javascript('"+nom+"','"+f_javascript+"');\">";
        //b+= "</div>";
        b+="<iframe frameborder=\"no\"  class=\"infohisto2\" id=\"ifr_"+nom+"\" style=\"left:100px;top:120px;overflow:auto;display:none;width:400px;\" frameborder='0' border='0'  src='vide_fid.htm'></iframe>";
        return(b);
}



String bulle_aide_fichier(String str,String nom,String html,String texte,String fichier){
	String b = "";
	b+="<div id='"+nom+"' class=\"infohisto\"  ";
	b+=" style=\"display: none;position:absolute;z-index: 100;padding: 2px;\">";//position: absolute;
	b+=""+str+"";
	b+="</div>";  
	b+= "<input type='button' value=\""+texte+"\" "+html+" onblur=\"CacheDiv('"+nom+"',event);\" onclick=\"appel_fichier('"+nom+"','"+fichier+"');bougeDiv('"+nom+"',event);\">";
	//b+= "</div>";
	b+="<iframe frameborder=\"no\"  class=\"infohisto2\" id=\"ifr_"+nom+"\" style=\"right:5%;top:60px;overflow:auto;display:none;width:400px;\" frameborder='0' border='0'  src='vide.htm'  ></iframe>";
	return(b);
}

%>
