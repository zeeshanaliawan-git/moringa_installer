<%@ page import="java.io.*, java.security.MessageDigest, java.security.NoSuchAlgorithmException, org.json.*, java.text.DecimalFormat, java.text.DecimalFormatSymbols, com.etn.util.Logger, com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.asimina.util.UrlHelper, com.etn.beans.Contexte, com.etn.pages.ImagesGenerator, com.etn.lang.ResultSet.Set, java.text.SimpleDateFormat, java.text.Normalizer, javax.servlet.ServletRequest, java.nio.charset.StandardCharsets, com.etn.asimina.util.ActivityLog, com.etn.pages.PagesGenerator, org.apache.http.HttpRequest, java.util.*, java.util.stream.Stream, java.util.function.Function, java.util.stream.Collectors, com.etn.pages.PagesUtil, com.etn.exception.SimpleException, com.etn.pages.Constant, com.etn.beans.Etn, com.etn.asimina.util.SiteHelper, com.etn.asimina.beans.Language" %>
<%
    Etn.setSeparateur(2, '\001', '\002');
%>
<%!
    SimpleDateFormat _logDf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

    void logDebugInfo(ServletRequest request, int userId, String msg) {

        msg = _logDf.format(new Date()) + "|User=" + userId + "|" + request.getRemoteAddr() + "|" + msg;
        Logger.info(msg);
    }

    String parseNull(Object o) {
        if (o == null) {
            return ("");
        }
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

    long parseLong(Object o) {
        return parseLong(o, 0);
    }

    long parseLong(Object o, long defaultValue) {
        String s = parseNull(o);
        if (s.length() > 0) {
            try {
                return Long.parseLong(s);
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
     // check a set of arrays are of equals size
     */
    boolean areArraysEqualSize(Object[]... arrays) {

        for (int i = 0; (i + 1) <= arrays.length - 1; i++) {

            if (arrays[i].length != arrays[i + 1].length) {
                return false;
            }
        }

        return true;
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

        if (str != null && str.length() > 0) {
            return str.replace("'", "&#39;").replace("\"", "&#34;").replace("<", "&lt;").replace(">", "&gt;");
        }
        else {
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
    String getRsValue(Set rs, String col) {
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
    String getValue(Set rs, String col) {
        return getValue(rs, col, "");
    }

    /***
     // above getValue() function with default value
     */
    String getValue(Set rs, String col, String defaultvalue) {
        if (rs == null && (defaultvalue == null || defaultvalue.trim().length() == 0)) return "";
        if (rs == null) return escapeCoteValue(defaultvalue.trim());
        return escapeCoteValue(parseNull(rs.value(col)));
    }

    JSONObject getJSONObject(Set rs) {
        JSONObject retObj = new JSONObject();
        for (String colName : rs.ColName) {
            retObj.put(colName.toLowerCase(), rs.value(colName));
        }
        return retObj;
    }

    String encodeJSONStringDB(String str) {
        return str.replaceAll("\\\\", "#slash#");
    }

    String decodeJSONStringDB(String str) {
        return str.replaceAll("#slash#", "\\\\");
    }

    /***
     * updated escape cote to preserve slashes (\)
     * which are removed by escape.cote() function
     */
    String escapeCote2(String str) {
        if (str == null || str.trim().length() == 0) {
            return escape.cote(str);
        }

        String retStr = escape.cote(encodeJSONStringDB(str));
        retStr = retStr.replaceAll("#slash#", "#slash##slash#");
        retStr = decodeJSONStringDB(retStr);

        return retStr;
    }

    private static final int ESC_CHAR = (int) '\\';
    private static final String ESC_STR = "\\\\";
    private static final String ESC_PLCHOLDR = "#SLS#";

    /***
     * a function to fix the issue of escape.cote()
     * where it removes \ characters from the string instead of properly escaping it
     * */
    String escapeCote(String str) {
        if (str == null || str.trim().length() == 0) {
            return escape.cote(str);
        }
        else if (str.indexOf(ESC_CHAR) >= 0) {
            //only do the extra replaces if needed, atleast one \ character is present
            String retStr = escape.cote(str.replaceAll(ESC_STR, ESC_PLCHOLDR));
            retStr = retStr.replaceAll(ESC_PLCHOLDR, ESC_STR + ESC_STR);
            return retStr;
        }
        else {
            return escape.cote(str);
        }
    }


    /***
     // to generate <select> input field
     */

    String addSelectControl(String id, String name,
                            Map<String, String> map, String selectedValue,
                            String cssClass, String scripts) {

        if (selectedValue == null) selectedValue = "";
        ArrayList<String> svals = new ArrayList<>();
        svals.add(selectedValue);

        return addSelectControl(id, name, map, svals, cssClass, scripts, false);

    }
    
    String addSelectControl(String id, String name,
                            Map<String, String> map, ArrayList svals,
                            String cssClass, String scripts, boolean multiple){
                                return addSelectControl(id, name, map, svals, cssClass, scripts, multiple, false);
                            }

    String addSelectControl(String id, String name,
                            Map<String, String> map, ArrayList svals,
                            String cssClass, String scripts, boolean multiple, boolean isDisabled) {
        int size = map.size();

        if (svals == null) svals = new ArrayList();
        if (cssClass == null) cssClass = "";
        if (scripts == null) scripts = "";

        String html = "<select name='" + name + "' ";
        if (id.length() > 0) {
            html += " id='" + id + "' ";
        }
        if (cssClass.length() > 0) {
            html += " class='" + cssClass + "' ";
        }
        html += " " + scripts;
        if (multiple) html += " multiple ";
        if (isDisabled) html += " disabled ";
        html += " >";

        for (String key : map.keySet()) {
            String val = map.get(key);
            String selected = "";
            if (svals.contains(key)) selected = " selected='selected' ";
            html += "<option " + selected + " value='" + escapeCoteValue(key) + "'>" + escapeCoteValue(val) + "</option>";
        }
        html += "</select>";
        return html;
    }

    // to generate any html tag
    public String generateHtmlTag(String tagName, String innerHtml,
                                  ArrayList<String> attrNames, ArrayList<String> attrValues) {
        StringBuilder tag = new StringBuilder("<");
        tag.append(tagName).append(" ");
        for (int i = 0; i < attrNames.size(); i++) {
            tag.append(attrNames.get(i))
                    .append("='").append(escapeCoteValue(attrValues.get(i))).append("' ");
        }
        tag.append(">").append(innerHtml).append("</").append(tagName).append('>');

        return tag.toString();
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

    public static String getUUID() {
        return UUID.randomUUID().toString();
    }

    String convertToHex(byte[] data) {

        StringBuffer buf = new StringBuffer();
        for (byte datum : data) {
            int halfbyte = (datum >>> 4) & 0x0F;
            int two_halfs = 0;
            do {
                if ((0 <= halfbyte) && (halfbyte <= 9)) {
                    buf.append((char) ('0' + halfbyte));
                }
                else {
                    buf.append((char) ('a' + (halfbyte - 10)));
                }
                halfbyte = datum & 0x0F;
            } while (two_halfs++ < 1);
        }
        return buf.toString();
    }

    final static int[] UC16Latin1ToAscii7 = {
            'A', 'A', 'A', 'A', 'A', 'A', 'A', 'C',
            'E', 'E', 'E', 'E', 'I', 'I', 'I', 'I',
            'D', 'N', 'O', 'O', 'O', 'O', 'O', 'X',
            '0', 'U', 'U', 'U', 'U', 'Y', 'S', 'Y',
            'a', 'a', 'a', 'a', 'a', 'a', 'a', 'c',
            'e', 'e', 'e', 'e', 'i', 'i', 'i', 'i',
            'o', 'n', 'o', 'o', 'o', 'o', 'o', '/',
            '0', 'u', 'u', 'u', 'u', 'y', 's', 'y'};

    int toAscii7(int c) {
        if (c < 0xc0 || c > 0xff) {
            return (c);
        }

        return (UC16Latin1ToAscii7[c - 0xc0]);
    }

    String ascii7(String s) {
        char[] c = s.toCharArray();
        for (int i = 0; i < c.length; i++) {

            if (c[i] >= 0xc0 && c[i] < 256) {
                c[i] = (char) toAscii7(c[i]);
            }
        }

        return (new String(c));
    }

    String convertUtfToAscii(String s) {
        return ascii7(s);
    }


    String removeAccents(String src) {
		return com.etn.asimina.util.UrlHelper.removeAccents(src);
    }

    String removeSpecialCharacters(String s) {
        if (s == null) return "";
        //replace space by -
        s = s.replace(" ", "-");
        //only allowing - in file name/path so we do here
        //return s.replaceAll("[^A-Za-z0-9-]", "");
        return s.replaceAll("[^\\p{IsAlphabetic}\\p{Digit}-]", "");
    }


    String getFileExtension(String fileName) {
        int i = fileName.lastIndexOf('.');
        if (i > 0) {
            return fileName.substring(i + 1);
        }
        return "";
    }

    String getSafeFileName(String fileName) {

        int dotIndex = fileName.lastIndexOf(".");
        String safeFileName = fileName;
        String fileExtension = "";
        if (dotIndex >= 0) {
            fileExtension = fileName.substring(fileName.lastIndexOf("."));
            safeFileName = fileName.substring(0, fileName.lastIndexOf("."));
        }

        //convert utf (accented) to ascii
        safeFileName = convertUtfToAscii(safeFileName);
        //replace all non-alphanumeric characters with underscore
        safeFileName = safeFileName.replaceAll("[^a-zA-Z0-9- .]", "_")
                .replaceAll("_+", "_")
                .replaceAll("\\.+", ".");

        int maxlength = 280; //300
        int nameLength = safeFileName.length() + fileExtension.length();
        if (nameLength > maxlength) {
            safeFileName = safeFileName.substring(0, safeFileName.length() - (nameLength - maxlength));
        }

        return safeFileName + fileExtension;
    }

    boolean isMediaType(String fileType) {
        return "img".equals(fileType) || "other".equals(fileType) || "video".equals(fileType);
    }

    String MD5(String text) throws NoSuchAlgorithmException, UnsupportedEncodingException {

        MessageDigest md;
        md = MessageDigest.getInstance("MD5");
        byte[] md5hash = new byte[32];
        md.update(text.getBytes(StandardCharsets.UTF_8), 0, text.length());
        md5hash = md.digest();
        return convertToHex(md5hash);
    }

    String convertDateToStandardFormat(String dateStr) {
        return convertDateToStandardFormat(dateStr, "dd/MM/yyyy");
    }

    String convertDateToStandardFormat(String dateStr, String srcFormat) {
        String retDate = dateStr;

        try {

            Date d = new SimpleDateFormat(srcFormat).parse(dateStr);

            retDate = new SimpleDateFormat("yyyy-MM-dd").format(d);
        }
        catch (Exception ex) {
            //return same date
        }

        return retDate;
    }

    String convertDateTimeToStandardFormat(String dateStr, String srcFormat) {
        String retDate = "";
        try {

            Date d = new SimpleDateFormat(srcFormat).parse(dateStr);

            retDate = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(d);
        }
        catch (Exception ex) {
            //return same date
        }

        return retDate;
    }

    String convertArrayToCommaSeperated(Object[] arr) {
        return convertArrayToCommaSeperated(arr, null);
    }

    /**
     * to convert array to comma seperated with a mapper function applied to each array item
     * mapper = null => result returned without applying mapper function
     * mapper function should be String to String
     * Example:  escape.cote() all items
     *      convertArrayToCommaSeperated(arr, escape::cote)
     *  alternate:
     *      convertArrayToCommaSeperated(arr, s -> escape.cote(s))
     */
    String convertArrayToCommaSeperated(Object[] arr, Function<String, String> mapper) {

        Stream<String> stream = Arrays.stream(arr).parallel().map(String::valueOf);
        if (mapper != null) {
            stream = stream.map(mapper);
        }
        return stream.collect(Collectors.joining(","));
    }

    String convertBytesToKilobytes(long sizeInBytes) {

        DecimalFormatSymbols symbols = new DecimalFormatSymbols();
        symbols.setDecimalSeparator('.');
        DecimalFormat nf = new DecimalFormat("#.00", symbols);
        String sizeInKB = nf.format((double) sizeInBytes / (double) 1024.0);
        return sizeInKB;
    }

    java.util.List<com.etn.asimina.beans.Language> getLangs(Contexte Etn, HttpSession session) {
        return SiteHelper.getSiteLangs(Etn,getSiteId(session));
    }

    java.util.List<com.etn.asimina.beans.Language> getLangs(Contexte Etn, String site_id) {
        return SiteHelper.getSiteLangs(Etn,site_id);
    }

    JSONArray getAllTagsJSON(Contexte Etn, String siteId, String CATALOG_DB) {
        return getAllTagsJSON(Etn,siteId,CATALOG_DB,"");
    }

    JSONArray getAllTagsJSON(Contexte Etn, String siteId, String CATALOG_DB,String folderIds) {
        JSONArray tags = new JSONArray();
        String q = "SELECT id, label,folder_id FROM " + CATALOG_DB + ".tags "
                   + " WHERE site_id = " + escape.cote(siteId);
        if(folderIds.length()>0 && !folderIds.contains("all")){
            if(folderIds.endsWith(",")){
                folderIds = folderIds.substring(0,folderIds.length()-1);
            }
            q+= " AND folder_id in ("+folderIds+") ";
        }
        q+= " ORDER BY label";
        Set rs = Etn.execute(q);
        if (rs != null) {
            while (rs.next()) {
                JSONObject tag = new JSONObject();
                tag.put("id", rs.value("id"));

                if(parseNull(rs.value("folder_id")).length() > 0){
                    Set tagFolder = Etn.execute("select * from " + CATALOG_DB + ".tags_folders where id="+escape.cote(rs.value("folder_id")));
                    if(tagFolder.next()){
                        tag.put("label",parseNull(tagFolder.value("name")).replace("$","/")+"/"+parseNull(rs.value("label")));
                    }else{
                        tag.put("label",rs.value("label"));
                    }
                }else{
                    tag.put("label",rs.value("label"));
                }

                tags.put(tag);
            }
        }
        return tags;
    }

    String getMaxFileUploadSize(String key) {

        if ("other".equalsIgnoreCase(key)) {
            return getNumericConfigValue("MAX_FILE_UPLOAD_SIZE_OTHER");
        }
        else if ("video".equalsIgnoreCase(key)) {
            return getNumericConfigValue("MAX_FILE_UPLOAD_SIZE_VIDEO");
        }
        else {
            return getNumericConfigValue("MAX_FILE_UPLOAD_SIZE");
        }

    }

    String getNumericConfigValue(String key) {
        String configValue = parseNull(GlobalParm.getParm(key));
        for (char c : configValue.toCharArray()) {
            if (c < '0' || c > '9') {
                return "";
            }
        }

        return configValue;
    }

    String getInsertQuery(String tableName, Map<String, String> colValueHM) {

        String qPrefix = "INSERT INTO " + tableName + " ( ";
        String qPostFix = " VALUES ( ";

        boolean isFirst = true;
        for (Map.Entry<String, String> entry : colValueHM.entrySet()) {
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

    String getUpdateQuery(String tableName, Map<String, String> colValueHM, String whereClause) {

        String query = "UPDATE " + tableName + " SET ";

        boolean isFirst = true;
        for (Map.Entry<String, String> entry : colValueHM.entrySet()) {
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

    String getSiteId(HttpSession session) {
        return parseNull(session.getAttribute("SELECTED_SITE_ID"));
    }

    boolean isPageUrlUnique(Contexte Etn, String siteId,
                            String langue_code, String variant, String path,
                            String pageId, StringBuffer errorMsg) {
        boolean isUnique = false;

        try {
            String type = "page";
            String url = path;
            if ("logged".equals(variant)) {
                url = variant + "/" + path;
            }
            isUnique = UrlHelper.isUrlUnique(Etn, siteId, langue_code, type, pageId, url, errorMsg);
        }
        catch (Exception ex) {
            Logger.error("Error in isPageUrlUnique()");
            ex.printStackTrace();
        }

        return isUnique;
    }

    boolean isSuperAdmin(Contexte Etn) {

        String q = "SELECT 1 FROM profilperson pp JOIN profil pr ON pp.profil_id = pr.profil_id "
                   + " WHERE pr.profil = 'SUPER_ADMIN' AND pp.person_id = " + escape.cote("" + Etn.getId());
        Set rs = Etn.execute(q);
        return rs != null && rs.next();

    }

    void generateImages(String fileId, Contexte Etn) throws Exception {

        ImagesGenerator imagesGenerator = new ImagesGenerator(Etn);

        imagesGenerator.generateImages(fileId);
        imagesGenerator.generateImages(fileId,"crop");
    }

    String getProdPortalLink(Contexte Etn) {
        Set rs = Etn.execute("Select val from " + GlobalParm.getParm("PROD_PORTAL_DB") + ".config where code = 'SEND_REDIRECT_LINK' ");
        rs.next();
        String v = parseNull(rs.value("val"));
        if (!v.endsWith("/")) v = v + "/";
        return v;
    }

    String capitalizeFirstLetter(String s) {
        if (s == null || s.trim().isEmpty()) {
            return "";
        }
        else {
            return s.substring(0, 1).toUpperCase() + s.substring(1);
        }
    }

    String getFolderTableName(String folderType) {
        switch (folderType) {
            case Constant.FOLDER_TYPE_CONTENTS:
                return "structured_contents_folders";
            case Constant.FOLDER_TYPE_PAGES:
                return "pages_folders";
            default:
                return "stores_folders";
        }
    }

    String getImageURLPrepend(String siteId) {
        String lnk = GlobalParm.getParm("EXTERNAL_LINK");
        if (!lnk.endsWith("/")) lnk += "/";
        return lnk + GlobalParm.getParm("UPLOADS_FOLDER") + siteId + "/img/";
    }

    String getFileURLPrepend() {
        String lnk = GlobalParm.getParm("EXTERNAL_LINK");
        if (!lnk.endsWith("/")) lnk += "/";
        return lnk + GlobalParm.getParm("UPLOADS_FOLDER");
    }

    String getThemeURLPrepend() {
        String lnk = GlobalParm.getParm("EXTERNAL_LINK");
        if (!lnk.endsWith("/")) lnk += "/";
        return lnk + GlobalParm.getParm("THEMES_FOLDER");
    }

    JSONArray getNewProductTemplateJson(String templateType){
        String fileName = "simpleProductJson.json";
        if(templateType.contains("config")){
            fileName = "configurableProductJson.json";
        }

        try{
            String filePath = GlobalParm.getParm("BASE_DIR")+"WEB-INF/templates/"+fileName;
            Reader reader = new FileReader(filePath);

            return new JSONArray(new JSONTokener(reader));
        }catch(FileNotFoundException e){
            e.printStackTrace();
            return new JSONArray();
        }
    }
	
	JSONObject getUserInfo(Contexte Etn) 
	{
		JSONObject jUser = new JSONObject();
		Set rs = Etn.execute("select p.*, l.name as login_id from person p join login l on l.pid = p.person_id where p.person_id = " + escape.cote(""+Etn.getId()));
		rs.next();
		jUser.put("id", Etn.getId());
		jUser.put("first_name", parseNull(rs.value("first_name")));
		jUser.put("last_name", parseNull(rs.value("Last_name")));
		jUser.put("login_id", parseNull(rs.value("login_id")));
		
		return jUser;
	}
%>

