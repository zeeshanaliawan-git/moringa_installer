<%-- Reviewed By Awais --%>
<%!
	String parseNull(Object o){
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

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

	/***
	// primarily used for output inside <textarea> tag
	// incase the output can have html/xml tags like for ckeditor based fields
	*/
	String escapeHtml(String str){
		return str.replace("<","&lt;").replace(">","&gt;");
	}

	/***
	// primarily used for manually building JSON
	*/
	public String escapeDblCote(String str){

	    return "\"" + str.replace("\"","\\\"") +"\"";
    }

    /***
    // primarily used for output inside value='' attribute
    // or any other attribute value of any tag/element
    // example :    <input type='text' value='escapeCoteValue( ... )' />
    */
    public String escapeCoteValue(String str){

		if(str != null && str.length() > 0 ){
			return str.replace("'","&#39;").replace("\"","&#34;").replace("<","&lt;").replace(">","&gt;");
		}
		else{
			return str;
		}
	}

	/***
	// 	used to get column value from result set , in code
	//  example :    String colValue = getRsValue("colname");
	//	NOTE:
	//  "NOT" to be mistaken with getValue() function which
	//  for value=' ... ' or any other html attribute
	*/
	String getRsValue(com.etn.lang.ResultSet.Set rs, String col)
	{
		if(rs == null) return "";
		return parseNull(rs.value(col));
	}

	/***
    // primarily used for directly output a result set column value inside value='' attribute
    // or any other attribute value of any tag/element
    // example :    <input type='text' value='getValue( ... )' />
    //	NOTE:
	//  "NOT" to be mistaken with getRsValue() function (see above)
    */
	String getValue(com.etn.lang.ResultSet.Set rs, String col)
	{
		return getValue(rs, col, "");
	}

	/***
    // above getValue() function with default value
    */
	String getValue(com.etn.lang.ResultSet.Set rs, String col, String defaultvalue)
	{
		if(rs == null && (defaultvalue == null || defaultvalue.trim().length() == 0)) return "";
		if(rs == null) return escapeCoteValue(defaultvalue.trim());
		return escapeCoteValue(parseNull(rs.value(col)));
	}

	/***
    // to generate <select> input field
    */

	String addSelectControl(String id, String name,
			java.util.Map<String,String> map, String selectedValue,
			String cssClass, String scripts)
	{

		if(selectedValue == null) selectedValue = "";
		java.util.ArrayList svals = new java.util.ArrayList();
		svals.add(selectedValue);

		return addSelectControl(id, name, map, svals, cssClass, scripts, false);

	}


	String addSelectControl(String id, String name,
			java.util.Map<String,String> map, java.util.ArrayList svals,
			String cssClass, String scripts, boolean multiple)
	{
		int size = map.size();

		if( svals == null ) svals = new java.util.ArrayList();
		if( cssClass == null) cssClass = "";
		if(scripts == null) scripts= "";

		String html = "<select name='" + name + "' ";
		if(id.length() > 0)
			html += " id='" + id + "' ";
		if(cssClass.length() > 0)
			html += " class='"+cssClass+"' ";
		html += " " + scripts ;
		if(multiple) html += " multiple ";
		html += " >";

		for(String key : map.keySet())
		{
			String val = map.get(key);
			String selected = "";
			if(svals.contains(key)) selected = " selected='selected' ";
			html += "<option "+selected+" value='" + escapeCoteValue(key) + "'>"+escapeCoteValue(val)+"</option>";
		}
		html += "</select>";
		return html;
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

	java.util.List<com.etn.asimina.beans.Language> getLangs(com.etn.beans.Contexte Etn, javax.servlet.http.HttpSession session){
		return com.etn.asimina.util.SiteHelper.getSiteLangs(Etn,getSelectedSiteId(session));
	}

	java.util.List<com.etn.asimina.beans.Language> getLangs(com.etn.beans.Contexte Etn, String site_id){
		return com.etn.asimina.util.SiteHelper.getSiteLangs(Etn,site_id);
	}

	java.util.List<java.util.List<String>> cartesianProduct(java.util.List<java.util.List<String>> lists){
	    java.util.List<java.util.List<String>> resultLists = new java.util.ArrayList<java.util.List<String>>();
	    if (lists.size() == 0) {
	        resultLists.add(new java.util.ArrayList<String>());
	        return resultLists;
	    } else {
	        java.util.List<String> firstList = lists.get(0);
	        java.util.List<java.util.List<String>> remainingLists = cartesianProduct(lists.subList(1, lists.size()));
	        for (String condition : firstList) {
	            for (java.util.List<String> remainingList : remainingLists) {
	                java.util.ArrayList<String> resultList = new java.util.ArrayList<String>();
	                resultList.add(condition);
	                resultList.addAll(remainingList);
	                resultLists.add(resultList);
	            }
	        }
	    }
	    return resultLists;
	}

	String getAccessId(com.etn.beans.Contexte Etn)
	{
		Set rs = Etn.execute("select * from login where pid = " + escape.cote(""+Etn.getId()));//change
		rs.next();

		String accessid = rs.value("access_id");
		if(parseNull(accessid).length() == 0)
		{
			accessid = java.util.UUID.randomUUID().toString();
			Etn.executeCmd("update login set access_id = "+com.etn.sql.escape.cote(accessid)+" where pid = " + escape.cote(""+Etn.getId()));//change
		}
		return accessid;
	}

	String getSelectedSiteId(javax.servlet.http.HttpSession session)
	{
       	return parseNull(session.getAttribute("SELECTED_SITE_ID"));
	}

%>

