<%@ page import="java.util.UUID, java.util.Map, java.util.HashMap, java.util.List, java.util.ArrayList, com.etn.lang.ResultSet.Set, com.etn.beans.Contexte, org.json.*"%>

<%!
	/*String parseNull(Object o){
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}*/

	int parseInt(Object o){
		return parseInt(o, 0);
	}

	int parseInt(Object o, int defaultValue){
		String s = parseNull(o);
		if(s.length() > 0 ){
			try{
				return Integer.parseInt(s);
			}
			catch(Exception e){
				return defaultValue;
			}
		}
		else{
			return defaultValue;
		}
	}

	double parseDouble(Object o){
		return parseDouble(o, 0.0);
	}

	double parseDouble(Object o, double defaultValue){
		String s = parseNull(o);
		if(s.length() > 0 ){
			try{
				return Double.parseDouble(s);
			}
			catch(Exception e){
				return defaultValue;
			}
		}
		else{
			return defaultValue;
		}
	}

	//return random number between 0 and Integer.MAX_VALUE
    public static int getRandomNumber(){
        return (int)(Math.random() * Integer.MAX_VALUE);
    }

    //return (somewhat) random string of digits of length 32
    public static String getRandomString(){
		String retStr = "";

		while(retStr.length() < 32){
			retStr +=  ("" + getRandomNumber());
		}

		if(retStr.length() > 32 ){
			retStr = retStr.substring(0,32);
		}

		return retStr;

	}

	String convertDateToStandardFormat(String dateStr){
		return convertDateToStandardFormat(dateStr, "dd/MM/yyyy");
	}

	String convertDateToStandardFormat(String dateStr, String srcFormat){
		String retDate = dateStr;

		try{

			java.util.Date d = new java.text.SimpleDateFormat(srcFormat).parse(dateStr);

			retDate = new java.text.SimpleDateFormat("yyyy-MM-dd").format(d);
		}
		catch(Exception ex){
			//return same date
		}

		return retDate;
	}

	String escapeHtml(String str){
		return str.replace("<","&lt;").replace(">","&gt;");
	}

	String convertArrayToCommaSeperated(Object []arr){

		String retVal = "";
		if(arr != null){
			boolean isFirst = true;

			for(Object obj : arr){

				if(!isFirst){
					retVal += ",";
				}
				else{
					isFirst = false;
				}

				retVal += String.valueOf(obj);
			}
		}
		return retVal;
	}


/* FOLDER IMAGE - d�but */
String getFolderPtImage(javax.servlet.http.HttpServletRequest req,String pt_img){
	return(com.etn.beans.app.GlobalParm.getParm("DEVICES_IMG_PATH") + "120x120/"+(pt_img.equals("")?"mob_vide.png":pt_img));
}
String getFolderGdImage(javax.servlet.http.HttpServletRequest req,String gd_img){
	return(com.etn.beans.app.GlobalParm.getParm("DEVICES_IMG_PATH") + "240x240/"+(gd_img.equals("")?"mob_vide_g.png":gd_img));
}

String getFolderNormalImage(javax.servlet.http.HttpServletRequest req,String img){
	return(com.etn.beans.app.GlobalParm.getParm("DEVICES_IMG_PATH") + (img.equals("")?"mob_vide.png":img));
}


String getAccessoriesImage(String imgPath){
	return(com.etn.beans.app.GlobalParm.getParm("ACCESSORIES_IMG_PATH") + (imgPath.equals("") ? "no_image.png" : imgPath));
}
/* FOLDER IMAGE - fin */


/* TECHNO : Liste compatibilite, categorie,trad ihm - d�but  */

String[] getListeTechno(){
	String tab[]= new String[]{"compatibilite_lte_a","compatibilite_lte","compatibilite_hsdpa","compatibilite_hsupa"};
	return(tab);
}
String[] getListeTechnoCategorie(){
	String tab[]= new String[]{"categorie_lte","categorie_hsupa","categorie_hsdpa"};
	return(tab);
}

String sql_getListeTechno(){
	String sql="";
	for(int i=0;i<getListeTechno().length;i++){
		sql += (i==0 ? "" : ",") + getListeTechno()[i];
	}
	return(sql);

}
String sql_getListeTechnoCategorie(){
	String sql="";
	for(int i=0;i<getListeTechnoCategorie().length;i++){
		sql += (i==0?"":",")+ getListeTechnoCategorie()[i];
	}
	return(sql);
}

String casesql_getListeTechnoCategorie(){
	String sql="";
	for(int i=0;i<getListeTechnoCategorie().length;i++){
		sql += (i==0?"":",")+ getCaseStatement(getListeTechnoCategorie()[i]);
	}
	return(sql);
}


String tradTechno(String compatibilite,String categorie,String valeur){
	String v2="";
	if(compatibilite.equalsIgnoreCase("compatibilite_hsdpa")){
		if(valeur.equalsIgnoreCase("O")){
			v2 = "3G+";
		}
	}
	if(compatibilite.equalsIgnoreCase("compatibilite_hsupa")){
		if(valeur.equalsIgnoreCase("O")){
			v2 = "3G";
		}
	}
	if(compatibilite.equalsIgnoreCase("compatibilite_lte")){
		if(valeur.equalsIgnoreCase("O")){
			v2 = "4G";
		}
	}
	if(compatibilite.equalsIgnoreCase("compatibilite_lte_a")){
		if(valeur.equalsIgnoreCase("O")){
			v2 = "4G+";
		}
	}
	return(v2);
}

/* TECHNO : Liste compatibilite, categorie,trad ihm - fin */

void concat_valeur(java.util.HashMap h,String key,String val,String sepa){
	if(h.get(key)==null){
		h.put(key,val);
	}else{
		String r = "";
		r = ""+h.get(key);
		r= r + sepa + val;
		h.put(key,r);
	}
}

String getCaseStatement(String colName){
	return "CASE WHEN lang_t." + colName + " IS NULL OR lang_t." + colName + " = ''"
		+ " THEN t." + colName
		+ "	ELSE lang_t." + colName + " END AS " + colName;
}

String getTrimCaseStatement(String colName){
	return "TRIM(CASE WHEN lang_t." + colName + " IS NULL OR lang_t." + colName + " = ''"
		+ " THEN t." + colName
		+ "	ELSE lang_t." + colName + " END)+0 AS " + colName;
}

String getYesNo(String colName){
	return "CASE WHEN " + colName + " = 'O' THEN 'Oui' ELSE 'Non' END AS " + colName;
}

List <com.etn.asimina.beans.Language> getLangs(Contexte Etn,HttpSession session){
	return getLangs(Etn,getSelectedSiteId(session));
}

List <com.etn.asimina.beans.Language> getLangs(Contexte Etn,String siteId){
	return com.etn.asimina.util.SiteHelper.getSiteLangs(Etn,siteId);
}

String getSelectedSiteId(javax.servlet.http.HttpSession session) {
	return parseNull(session.getAttribute("SELECTED_SITE_ID"));
}

public List<List<String>> cartesianProduct(List<List<String>> lists){
    List<List<String>> resultLists = new ArrayList<List<String>>();
    if (lists.size() == 0) {
        resultLists.add(new ArrayList<String>());
        return resultLists;
    } else {
        List<String> firstList = lists.get(0);
        List<List<String>> remainingLists = cartesianProduct(lists.subList(1, lists.size()));
        for (String condition : firstList) {
            for (List<String> remainingList : remainingLists) {
                ArrayList<String> resultList = new ArrayList<String>();
                resultList.add(condition);
                resultList.addAll(remainingList);
                resultLists.add(resultList);
            }
        }
    }
    return resultLists;
}

%>