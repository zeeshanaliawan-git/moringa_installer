<%!int getIndex(String[] tab,String col){
	for(int y=0;y<tab.length;y++){
		if(tab[y].equalsIgnoreCase(col)){
			return(y);
		}
	}
	return(-1);
}
%>
<%!String affVertical(String s){
	String s2="";
	for(int i=0;i<s.length();i++){
		s2+=s.charAt(i)+"<br>";
	}
	return(s2);
}%>
<%!String AfficheSelect(java.util.TreeMap h,String name,String pos,String valVide,String event,String val1, String val2){


	// tab = le tableau des valeur
	// name = le nom du select
	// pos = permet de positionner le selected
	// valVide = pour afficher un titre ...
	// event = rajouteur un evenement ou un autre attribut (id,alt ...)
	// val1 = rajout une valeur
	// val2 = libellé


	String d="";

	d+="<select ";
	if(!name.equals("")){
		d+= " name=\""+name+"\" id=\""+name+"\"";
	}
	
	d+= ""+ event+">\n";

	if(! val1.equals("")){
		d+="<option value=\""+val1+"\">"+val2+"\n";
	}

	if(! valVide.equals("")){
		d+="<option ";
		if(pos.equals("")){
			d+=" selected ";
		}
		d+=" value=\"\">"+valVide+"\n";
	}

	
	java.util.Set lesCles = h.keySet() ;
	java.util.Iterator it = lesCles.iterator() ;

	Object o;
	String r="";
	int i=0;
	while (it.hasNext()){
		o = it.next();
		d+="<option ";
		//System.out.println("pos="+pos+"=="+(""+o));
		if(pos.equals(""+(""+o))){
			d+=" selected ";
		}
		
		d+=" value=\""+(""+o)+"\">"+h.get(""+o)+"\n"; 
	    i++;
	  }
	
		

	d+="</select>\n";

return(d);
}
%>
<%!String AfficheSelect(String tab[],String name,String pos,String valVide,String event,String val1, String val2){


	// tab = le tableau des valeur
	// name = le nom du select
	// pos = permet de positionner le selected
	// valVide = pour afficher un titre ...
	// event = rajouteur un evenement ou un autre attribut (id,alt ...)
	// val1 = rajout une valeur
	// val2 = libellé


	String d="";

	d+="<select name=\""+name+"\" "+ event+">\n";

	if(! val1.equals("")){
		d+="<option value=\""+val1+"\">"+val2+"\n";
	}

	if(! valVide.equals("")){
		d+="<option ";
		if(pos.equals("")){
			d+=" selected ";
		}
		d+=" value=\"\">"+valVide+"\n";
	}

		for(int i=1;i < tab.length;i++){
			d+="<option ";

			if(pos.equals(""+tab[i])){
				d+=" selected ";
			}

			d+=" value=\""+tab[i]+"\">"+tab[i]+"\n";
		}

	d+="</select>\n";

return(d);
}
%>