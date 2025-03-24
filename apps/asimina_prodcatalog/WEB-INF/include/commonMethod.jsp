<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.util.Logger, com.etn.asimina.util.UIHelper, com.etn.beans.Contexte, java.nio.file.*, java.util.HashMap, java.util.List,org.json.JSONObject, com.etn.asimina.beans.Language, com.etn.asimina.util.SiteHelper" %>
<%!

    String parseNull(Object o) {
        if (o == null) return ("");
        String s = o.toString();
        if ("null".equals(s.trim().toLowerCase())) {
            return ("");
        }
        else {
            return (s.trim());
        }
    }

    int parseInt(Object o) {
        return parseInt(o, 0);
    }

    int parseInt(Object o, int defaultValue) {
        String s = parseNull(o);
        if (s.length() > 0) {
            try {
                return Integer.parseInt(s);
            }
            catch (Exception e) {
                return defaultValue;
            }
        }
        else {
            return defaultValue;
        }
    }

    double parseDouble(Object o) {
        return parseDouble(o, 0.0);
    }

    double parseDouble(Object o, double defaultValue) {
        String s = parseNull(o);
        if (s.length() > 0) {
            try {
                return Double.parseDouble(s);
            }
            catch (Exception e) {
                return defaultValue;
            }
        }
        else {
            return defaultValue;
        }
    }

    /***
     // primarily used for output inside <textarea> tag
     // incase the output can have html/xml tags like for ckeditor based fields
     */
    String escapeHtml(String str) {
        return str.replace("<", "&lt;").replace(">", "&gt;");
    }

    /***
     // primarily used for manually building JSON
     */
    public String escapeDblCote(String str) {

        return "\"" + str.replace("\"", "\\\"") + "\"";
    }

    /***
     // primarily used for output inside value='' attribute
     // or any other attribute value of any tag/element
     // example :    <input type='text' value='escapeCoteValue( ... )' />
     */
    public String escapeCoteValue(String str) {
        return UIHelper.escapeCoteValue(str);
    }

    /***
     // 	used to get column value from result set , in code
     //  example :    String colValue = getRsValue("colname");
     //	NOTE:
     //  "NOT" to be mistaken with getValue() function which
     //  for value=' ... ' or any other html attribute
     */
    String getRsValue(com.etn.lang.ResultSet.Set rs, String col) {
        if (rs == null) return "";
        return parseNull(rs.value(col));
    }

    /***
     // primarily used for directly output a result set column value inside value='' attribute
     // or any other attribute value of any tag/element
     // example :    <input type='text' value='getValue( ... )' />
     //	NOTE:
     //  "NOT" to be mistaken with getRsValue() function (see above)
     */
    String getValue(com.etn.lang.ResultSet.Set rs, String col) {
        return getValue(rs, col, "");
    }

    /***
     // above getValue() function with default value
     */
    String getValue(com.etn.lang.ResultSet.Set rs, String col, String defaultvalue) {
        if (rs == null && (defaultvalue == null || defaultvalue.trim().length() == 0)) return "";
        if (rs == null) return escapeCoteValue(defaultvalue.trim());
        return escapeCoteValue(parseNull(rs.value(col)));
    }

    /***
     // to generate <select> input field
     */

    String addSelectControl(String id, String name,
                            java.util.Map<String, String> map, String selectedValue,
                            String cssClass, String scripts) {


        return UIHelper.getSelectControl(id, name, map, selectedValue, cssClass, scripts);

    }

    String addSelectControl(String id, String name,
                            java.util.Map<String, String> map, java.util.ArrayList svals,
                            String cssClass, String scripts, boolean multiple, boolean isDisabled) {
                                return UIHelper.getSelectControl(id, name, map, svals,cssClass,scripts,multiple,isDisabled);
                            }

    String addSelectControl(String id, String name,
                            java.util.Map<String, String> map, java.util.ArrayList svals,
                            String cssClass, String scripts, boolean multiple) {
        return UIHelper.getSelectControl(id, name, map, svals, cssClass, scripts, multiple);
    }

    //return random number between 0 and Integer.MAX_VALUE
    public static int getRandomNumber() {
        return (int) (Math.random() * Integer.MAX_VALUE);
    }

    //return (somewhat) random string of digits of length 32
    public static String getRandomString() {
        String retStr = "";

        while (retStr.length() < 32) {
            retStr += ("" + getRandomNumber());
        }

        if (retStr.length() > 32) {
            retStr = retStr.substring(0, 32);
        }

        return retStr;

    }

    String convertDateToStandardFormat(String dateStr) {
        return convertDateToStandardFormat(dateStr, "dd/MM/yyyy");
    }

    String convertDateToStandardFormat(String dateStr, String srcFormat) {
        String retDate = dateStr;

        try {

            java.util.Date d = new java.text.SimpleDateFormat(srcFormat).parse(dateStr);

            retDate = new java.text.SimpleDateFormat("yyyy-MM-dd").format(d);
        }
        catch (Exception ex) {
            //return same date
        }

        return retDate;
    }

    String convertArrayToCommaSeperated(Object[] arr) {

        String retVal = "";
        if (arr != null) {
            boolean isFirst = true;

            for (Object obj : arr) {

                if (!isFirst) {
                    retVal += ",";
                }
                else {
                    isFirst = false;
                }

                retVal += String.valueOf(obj);
            }
        }
        return retVal;
    }

    boolean areAllArraySizeEqual(Object[]... array) {
        boolean areAllEqual = true;
        Object[] first = array[0];
        if (first == null) {
            return false;
        }
        for (int i = 1; i < array.length; i++) {
            if (array[i] == null || first.length != array[i].length) {
                areAllEqual = false;
                break;
            }
        }

        return areAllEqual;
    }


    /* FOLDER IMAGE - debut */
    String getFolderPtImage(javax.servlet.http.HttpServletRequest req, String pt_img) {
        return (com.etn.beans.app.GlobalParm.getParm("DEVICES_IMG_PATH") + "120x120/" + (pt_img.equals("") ? "mob_vide.png" : pt_img));
    }

    String getFolderGdImage(javax.servlet.http.HttpServletRequest req, String gd_img) {
        return (com.etn.beans.app.GlobalParm.getParm("DEVICES_IMG_PATH") + "240x240/" + (gd_img.equals("") ? "mob_vide_g.png" : gd_img));
    }

    String getFolderNormalImage(javax.servlet.http.HttpServletRequest req, String img) {
        return (com.etn.beans.app.GlobalParm.getParm("DEVICES_IMG_PATH") + (img.equals("") ? "mob_vide.png" : img));
    }


    String getAccessoriesImage(String imgPath) {
        return (com.etn.beans.app.GlobalParm.getParm("ACCESSORIES_IMG_PATH") + (imgPath.equals("") ? "no_image.png" : imgPath));
    }
    /* FOLDER IMAGE - fin */


    /* TECHNO : Liste compatibilite, categorie,trad ihm - debut  */

    String[] getListeTechno() {
        String[] tab = new String[]{"compatibilite_lte_a", "compatibilite_lte", "compatibilite_hsdpa", "compatibilite_hsupa"};
        return (tab);
    }

    String[] getListeTechnoCategorie() {
        String[] tab = new String[]{"categorie_lte", "categorie_hsupa", "categorie_hsdpa"};
        return (tab);
    }

    String sql_getListeTechno() {
        String sql = "";
        for (int i = 0; i < getListeTechno().length; i++) {
            sql += (i == 0 ? "" : ",") + getListeTechno()[i];
        }
        return (sql);

    }

    String sql_getListeTechnoCategorie() {
        String sql = "";
        for (int i = 0; i < getListeTechnoCategorie().length; i++) {
            sql += (i == 0 ? "" : ",") + getListeTechnoCategorie()[i];
        }
        return (sql);
    }

    String casesql_getListeTechnoCategorie() {
        String sql = "";
        for (int i = 0; i < getListeTechnoCategorie().length; i++) {
            sql += (i == 0 ? "" : ",") + getCaseStatement(getListeTechnoCategorie()[i]);
        }
        return (sql);
    }


    String tradTechno(String compatibilite, String categorie, String valeur) {
        String v2 = "";
        if (compatibilite.equalsIgnoreCase("compatibilite_hsdpa")) {
            if (valeur.equalsIgnoreCase("O")) {
                v2 = "3G+";
            }
        }
        if (compatibilite.equalsIgnoreCase("compatibilite_hsupa")) {
            if (valeur.equalsIgnoreCase("O")) {
                v2 = "3G";
            }
        }
        if (compatibilite.equalsIgnoreCase("compatibilite_lte")) {
            if (valeur.equalsIgnoreCase("O")) {
                v2 = "4G";
            }
        }
        if (compatibilite.equalsIgnoreCase("compatibilite_lte_a")) {
            if (valeur.equalsIgnoreCase("O")) {
                v2 = "4G+";
            }
        }
        return (v2);
    }

    /* TECHNO : Liste compatibilite, categorie,trad ihm - fin */

    void concat_valeur(java.util.HashMap<String, String> h, String key, String val, String sepa) {
        if (h.get(key) == null) {
            h.put(key, val);
        }
        else {
            String r = "";
            r = "" + h.get(key);
            r = r + sepa + val;
            h.put(key, r);
        }
    }

    String getCaseStatement(String colName) {
        return "CASE WHEN lang_t." + colName + " IS NULL OR lang_t." + colName + " = ''"
               + " THEN t." + colName
               + "	ELSE lang_t." + colName + " END AS " + colName;
    }

    String getTrimCaseStatement(String colName) {
        return "TRIM(CASE WHEN lang_t." + colName + " IS NULL OR lang_t." + colName + " = ''"
               + " THEN t." + colName
               + "	ELSE lang_t." + colName + " END)+0 AS " + colName;
    }

    String getYesNo(String colName) {
        return "CASE WHEN " + colName + " = 'O' THEN 'Oui' ELSE 'Non' END AS " + colName;
    }

    // class Language{
    // 	int id;
    // 	String name;
    // 	String code;
    // }

    // java.util.ArrayList<Language> getLangs(com.etn.beans.Contexte Etn){
    // 	com.etn.lang.ResultSet.Set rsLang = Etn.execute("select * from `language` order by langue_id");
    // 	java.util.ArrayList<Language> langs = new java.util.ArrayList<Language>();
    // 	while(rsLang.next()){
    // 		Language l = new Language();
    // 		l.id = Integer.parseInt(rsLang.value("langue_id"));
    // 		l.name = rsLang.value("langue");
    // 		l.code = rsLang.value("langue_code");
    // 		langs.add(l);
    // 	}
    // 	return langs;
    // }

    java.util.List<com.etn.asimina.beans.Language> getLangs(com.etn.beans.Contexte Etn, javax.servlet.http.HttpSession session)
    {
        return SiteHelper.getSiteLangs(Etn,getSelectedSiteId(session));
    }

    java.util.List<com.etn.asimina.beans.Language> getLangs(com.etn.beans.Contexte Etn, String siteId)
    {
        return SiteHelper.getSiteLangs(Etn,siteId);
    }


    java.util.List<java.util.List<String>> cartesianProduct(java.util.List<java.util.List<String>> lists) {
        java.util.List<java.util.List<String>> resultLists = new java.util.ArrayList<>();
        if (lists.size() == 0) {
            resultLists.add(new java.util.ArrayList<>());
            return resultLists;
        }
        else {
            java.util.List<String> firstList = lists.get(0);
            java.util.List<java.util.List<String>> remainingLists = cartesianProduct(lists.subList(1, lists.size()));
            for (String condition : firstList) {
                for (java.util.List<String> remainingList : remainingLists) {
                    java.util.ArrayList<String> resultList = new java.util.ArrayList<>();
                    resultList.add(condition);
                    resultList.addAll(remainingList);
                    resultLists.add(resultList);
                }
            }
        }
        return resultLists;
    }

    String getAccessId(com.etn.beans.Contexte Etn) {
        com.etn.lang.ResultSet.Set rs = Etn.execute("select * from login where pid = " + Etn.getId());
        rs.next();

        String accessid = rs.value("access_id");
        if (parseNull(accessid).length() == 0) {
            accessid = java.util.UUID.randomUUID().toString();
            Etn.executeCmd("update login set access_id = " + com.etn.sql.escape.cote(accessid) + " where pid = " + Etn.getId());
        }
        return accessid;
    }

    String getSelectedSiteId(javax.servlet.http.HttpSession session) {
        return parseNull(session.getAttribute("SELECTED_SITE_ID"));
    }

    String getSiteId(javax.servlet.http.HttpSession session) {
        return getSelectedSiteId(session);
    }

    boolean isSuperAdmin(com.etn.beans.Contexte Etn) {

        String q = "SELECT 1 FROM profilperson pp JOIN profil pr ON pp.profil_id = pr.profil_id "
                   + " WHERE pr.profil = 'SUPER_ADMIN' AND pp.person_id = " + com.etn.sql.escape.cote("" + Etn.getId());
        Set rs = Etn.execute(q);
        return (rs != null && rs.next());

    }

    // convenient and clean way to generate INSERT or UPDATE queries
    // e.g: /admin/catalogs/saveproduct.jsp for usage example
    String getInsertQuery(String tableName, java.util.Map<String, String> colValueHM) {

        String qPrefix = "INSERT INTO " + tableName + " ( ";
        String qPostFix = " VALUES ( ";

        boolean isFirst = true;
        for (java.util.Map.Entry<String, String> entry : colValueHM.entrySet()) {
            if (!isFirst) {
                qPrefix += ", ";
                qPostFix += ", ";
            }
            else {
                isFirst = false;
            }

            qPrefix += entry.getKey();
            qPostFix += entry.getValue();

        }

        return qPrefix + " ) \n" + qPostFix + " )";
    }

    String getUpdateQuery(String tableName, java.util.Map<String, String> colValueHM, String whereClause) {

        String query = "UPDATE " + tableName + " SET ";

        boolean isFirst = true;
        for (java.util.Map.Entry<String, String> entry : colValueHM.entrySet()) {
            if (!isFirst) {
                query += ", ";
            }
            else {
                isFirst = false;
            }
            query += entry.getKey() + "=" + entry.getValue();

        }

        return query + " " + whereClause;
    }


/*	String getSelectedSiteId(com.etn.beans.Contexte Etn, String sessionid)
	{
		String selectedsiteid = "";
		com.etn.lang.ResultSet.Set rs = Etn.execute("select coalesce(selected_site_id,'') as selected_site_id from "+com.etn.beans.app.GlobalParm.getParm("COMMONS_DB")+".user_sessions where catalog_session_id = " + com.etn.sql.escape.cote(sessionid));
		if(rs.next()) selectedsiteid = rs.value("selected_site_id");
		return selectedsiteid;
	}*/

    void copyPaymentAndDeliveryMethods(com.etn.beans.Contexte Etn, String siteid) {
        com.etn.lang.ResultSet.Set rs1 = Etn.execute("select * from delivery_methods where site_id = " + com.etn.sql.escape.cote(siteid));
        //no delivery methods found so add from default table
        if (rs1.rs.Rows == 0) {
            com.etn.lang.ResultSet.Set rs = Etn.execute("select * from all_delivery_methods ");
            while (rs.next()) {
                Etn.executeCmd("insert into delivery_methods (site_id, method, displayName, helpText) values (" + com.etn.sql.escape.cote(siteid) + "," + com.etn.sql.escape.cote(parseNull(rs.value("method"))) + "," + com.etn.sql.escape.cote(parseNull(rs.value("displayName"))) + "," + com.etn.sql.escape.cote(parseNull(rs.value("helpText"))) + ") ");
            }
        }

        rs1 = Etn.execute("select * from payment_methods where site_id = " + com.etn.sql.escape.cote(siteid));
        //no payment methods found so add from default table
        if (rs1.rs.Rows == 0) {
            com.etn.lang.ResultSet.Set rs = Etn.execute("select * from all_payment_methods ");
            while (rs.next()) {
                Etn.executeCmd("insert into payment_methods (site_id, method, displayName, helpText, subText) values (" + com.etn.sql.escape.cote(siteid) + "," + com.etn.sql.escape.cote(parseNull(rs.value("method"))) + "," + com.etn.sql.escape.cote(parseNull(rs.value("displayName"))) + "," + com.etn.sql.escape.cote(parseNull(rs.value("helpText"))) + "," + com.etn.sql.escape.cote(parseNull(rs.value("subText"))) + ") ");
            }
        }
    }

    boolean isEcommerceEnabled(com.etn.beans.Contexte Etn, String siteid) {
        boolean isEnabled = false;
        com.etn.lang.ResultSet.Set rs = Etn.execute("select * from " + com.etn.beans.app.GlobalParm.getParm("PORTAL_DB") + ".sites where id = " + com.etn.sql.escape.cote(siteid));
        if (rs.next()) {
            isEnabled = "1".equals(rs.value("enable_ecommerce"));
        }
        return isEnabled;
    }

    /**
     *
     * @author Ali Adnan
     *
     * Just a wrapper Exception class to identify that it was thrown manually
     * to show custom error message before exiting
     */
    public static class SimpleException extends Throwable {

        Throwable ex = null;

        public SimpleException(String message) {
            super(message);
        }

        public SimpleException(String message, Throwable ex) {
            super(message);
            this.ex = ex;
        }

        public void print() {
            System.out.println(this.getMessage());
            if (ex != null) {
                ex.printStackTrace();
            }
        }

    }

    String removeAccents(String src) {
		return com.etn.asimina.util.UrlHelper.removeAccents(src);
    }


    String getFileExtension(String fileName) {
        int i = fileName.lastIndexOf('.');
        if (i > 0) {
            return fileName.substring(i + 1);
        }
        return "";
    }

    String removeSpecialCharactersFromImageName(String s) {
        return s.replace("/", "").replace(" ", "-").replace("'", "").replace("\"", "").replace("|", "").replace("#", "").replace("(", "").replace(")", "").replace("[", "").replace("]", "").replace(":", "").replace(";", "").replace("=", "").replace("!", "").replace("@", "").replace("$", "").replace("%", "").replace("^", "").replace("&", "").replace("*", "").replace("?", "").replace("--", "-");
    }


    String getAsiminaFileName(String newFileName, String originalFileName) {
        if (newFileName != null && newFileName.length() > 0) {
            String extension = getFileExtension(originalFileName);
            return removeSpecialCharactersFromImageName(com.etn.asimina.util.UrlHelper.removeAccents(newFileName).toLowerCase()) + ("".equals(extension) ? "" : ".") + extension;
        }
        return originalFileName;
    }


    /**
     * Addd by ABJ to convert queries to JSONArray
     */

    String toProperCase(String s) {
        return s.substring(0, 1).toUpperCase() + s.substring(1).toLowerCase();
    }

    String toCamelCase(String name) {
        String[] parts = name.split("_");

        String camelCase = null;

        for (String part : parts) {
            if (camelCase == null) {
                camelCase = part.toLowerCase();
            }
            else {
                camelCase = camelCase + toProperCase(part);
            }
        }
        return camelCase;
    }

    org.json.JSONObject toJSONObject(com.etn.lang.ResultSet.Set rs) {
        String[] colNames = rs.ColName;
        org.json.JSONObject data = new org.json.JSONObject();
        for (String colName : colNames) {
            data.put(toCamelCase(colName), rs.value(colName));
        }
        return data;
    }

    org.json.JSONArray toJSONArray(com.etn.beans.Contexte Etn, String query) {
        org.json.JSONArray data = new org.json.JSONArray();

        com.etn.lang.ResultSet.Set rs = Etn.execute(query);
        if (rs != null) {
            while (rs.next()) {
                data.put(toJSONObject(rs));
            }
        }
        return data;
    }

    void deleteDirectoryWithContent(String pathStr) throws java.io.IOException {
        Path directoryPath = Paths.get(pathStr);
        if (Files.exists(directoryPath)) {
            deleteDirectoryWithContent(directoryPath);
        }
    }

    //recursive function to delete non-empty directory
    void deleteDirectoryWithContent(Path path) throws java.io.IOException {
        if (Files.isDirectory(path, LinkOption.NOFOLLOW_LINKS)) {
            DirectoryStream<Path> entries = null;
            try {
                entries = Files.newDirectoryStream(path);
                for (Path entry : entries) {
                    deleteDirectoryWithContent(entry);
                }
            }
            finally {
                if (entries != null) {
                    entries.close();
                }
            }
        }
        Files.delete(path);

    }

    HashMap<String, String> getProductPrefixPathMap(Contexte Etn, String siteId, String catalogId, String folderId) {
        HashMap<String, String> prefixPathHM = new HashMap<>();

        String q = "SELECT cd.langue_id, cd.folder_name "
                   + " FROM catalogs c "
                   + " JOIN catalog_descriptions cd ON c.id = cd.catalog_id "
                   + " WHERE c.site_id = " + escape.cote(siteId)
                   + " AND c.id = " + escape.cote(catalogId);
        Set rs = Etn.execute(q);
        while (rs.next()) {
            String folderName = parseNull(rs.value("folder_name"));
            if (folderName.length() > 0) {
                prefixPathHM.put(rs.value("langue_id"), folderName);
            }
        }

        if (parseInt(folderId) > 0) {
            q = "SELECT fv.langue_id, fv.concat_path "
                + " FROM products_folders_lang_path fv "
                + " WHERE fv.site_id  = " + escape.cote(siteId)
                + " AND fv.folder_id = " + escape.cote(folderId);
            rs = Etn.execute(q);
            while (rs.next()) {
                String concatPath = parseNull(rs.value("concat_path"));
                if (concatPath.length() > 0) {
                    String langId = rs.value("langue_id");
                    if (prefixPathHM.containsKey(langId)) {
                        prefixPathHM.put(langId, prefixPathHM.get(langId) + "/" + concatPath);
                    }
                    else {
                        prefixPathHM.put(langId, concatPath);
                    }
                }
            }
        }
        return prefixPathHM;
    }

    JSONObject getJSONObject(Set rs) {
        JSONObject retObj = new JSONObject();
        for (String colName : rs.ColName) {
            retObj.put(colName.toLowerCase(), rs.value(colName));
        }
        return retObj;
    }

    String getLanguageTabs(List<Language> languages){
		boolean active = true;
		String tabs ="<ul class='nav nav-tabs' role='tablist'>";
        for(Language lang:languages){
            tabs+="<li class='nav-item langtab'>"+
                    "<a class='nav-link";
			if(active){
				tabs+=" active";
			}
			tabs+="' href='#' data-toggle='tab' data-lang-id='"+lang.getLanguageId()+"' onclick='selecttab(\"lang"+lang.getLanguageId()+"show\")'>"+
				lang.getLanguage()+"</a></li>";
            active = false;
		}
        tabs+="</ul>";
        return tabs;
	}

    String getLanguageTextArea(List<Language> languages, Set rs)
    {
        String textArea ="";
        boolean active = true;
        for(Language lang: languages){
            textArea+="<textarea id='lang_"+lang.getLanguageId()+"_description' name='lang_"+lang.getLanguageId()+"_description' class='form-control lang"+lang.getLanguageId()+"show' ";
            if(!active){
                textArea+="style='display: none;'";
            }
            textArea+=">"+getRsValue(rs, "lang_"+lang.getLanguageId()+"_description")+"</textarea>";
            active = false;
        }
        return textArea;
    }
	
	void trashFolder(com.etn.beans.Contexte Etn, String folderId)
	{
		Set rs = Etn.execute("select id from products_folders where parent_folder_id = "+escape.cote(folderId));
		while(rs.next())
		{
			trashFolder(Etn, rs.value("id"));
		}
		Etn.executeCmd("UPDATE products SET is_deleted=1,updated_on=now(),updated_by="+escape.cote(""+Etn.getId())+" WHERE folder_id = "+escape.cote(folderId));		
		Etn.executeCmd("UPDATE products_folders SET is_deleted=1,updated_on=now(),updated_by="+escape.cote(""+Etn.getId())+" WHERE id = "+ escape.cote(folderId));
	}
	
%>

