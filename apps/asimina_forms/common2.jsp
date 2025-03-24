<%@ page import="java.lang.StringBuffer" %>
<%@ page import="java.util.*"%>
<%@ page import="org.json.*"%>
<%@ page import="com.etn.beans.app.GlobalParm"%>
<%@ page import="com.etn.asimina.util.UIHelper"%>
<%@ page import="com.etn.asimina.authentication.*"%>
<%@ page import="com.etn.asimina.data.LanguageFactory, com.etn.asimina.beans.Language" %>
<%@ page import="java.net.HttpURLConnection, java.net.URL, java.io.InputStream, java.io.BufferedReader, java.io.InputStreamReader " %>

<%@ include file="lib_msg.jsp" %>
<%!
    public final String BLUE = "#0101FD";
    public final String ORANGE = "#FF6600";

    /** for semfree engine. */
    public final String SEMAPHORE = com.etn.beans.app.GlobalParm.getParm("SEMAPHORE");

    /** For CSV daily report. */
    public final char TYPE_DAILY = 'D';

    /** For CSV general report. */
    public final char TYPE_GENERAL = 'G';

    /** For CSV terminal delivery report. */
    public final char TYPE_TERMINAL_DELIVERY = 'T';

    /** For CSV portability cancellation request report. */
    public final char TYPE_PORTABILITY_CANCELLATION = 'P';

    /** Column name for reports. */
    public final String REPORTS_COLUMN_NAME = "record";

    /** Role user "plataforma", agente. */
    public final String ROLE_AGENT = "agente";

    /** Role user "coordinador", agente. */
    public final String ROLE_COORD = "coordinador";

    /** Role user "admin". */
    public final String ROLE_ADMIN = "admin2";

    // Estado Guizmo
    public final String NUEVA_SOLICITUD_SIM = "NuevaSolicitudSim62";
    public final String CANCELADO_A_POSTERIORI = "CanceladoAPosteriori42";
//    public final String CANCELADO_CLIENTE = "Cancelacion";
    public final String FALTAN_DATOS = "FaltanDatos45";
    public final String DATA_CHECK = "DataCheck";

    public final String ALTA_PROCES_LABEL = "ALTA";
    public final String PORTA_PROCES_LABEL = "PORTA";
    public final String PORTA_PROCES_PREFIX = "portabilidad";

    public final String ALTA_NUEVA_PREFIX = "alta nueva contrato";
    public final String ALTA_NUEVA_VALOR_PREFIX = "alta nueva contrato valor";
    public final String ALTA_NUEVA_PREMIUM_PREFIX = "alta nueva premium";

    public final String PORTA_PREFIX = "portabilidad";
    public final String PORTA_CONTRATO = "portabilidad contrato";
    public final String PORTA_VALOR = "portabilidad valor";
    public final String PORTA_CONTRATO_VALOR = "portabilidad contrato valor";
    public final String PORTA_PREMIUM = "portabilidad premium";


    public final String SIN_MOTIVO = "SIN_MOTIVO";

%>

<%!

    public String formManupulationButton(String formId,String lineId,String fieldId,String elementType,String langId,String defaultLangId,String elementIsDeletable,String elementDbColumnName)
    {
        String html="";
        html+="<div class=\"field-edit\">";
        html+="<button line-form-id=\"" + formId + "\" line-id=\"" + lineId + "\" line-field-id=\"" + fieldId + "\" field-type=\"" + elementType + "\" field-label=\"" + elementType + "\" lang-id=\"" + langId + "\" class=\"btn btn-sm btn-primary mr-1 mb-0 btn-modal add_field_to_form\" data-toggle=\"modal\" data-target=\"#add_field_to_form\"> edit field </button>";
        if(defaultLangId.equals(langId) && elementIsDeletable.equals("1")){
            html+="<button line-form-id=\"" + formId + "\" line-id=\"" + lineId + "\" line-field-id=\"" + fieldId + "\" line-col-name=\"" + elementDbColumnName + "\" lang-id=\"" + langId + "\" class=\"btn btn-sm btn-danger mr-1 mb-0\" onclick='deleteElement(this)'> delete </button>";
        }
        html+="</div> <div class=\"field-edit-bgnd\"> &nbsp; </div>";
        return html;
        
    }

    public String returnStyleCss(String elementContainerBackgroundColor, boolean hidden){
        String styleCss = "style=\"";
        if(hidden)
            styleCss += "display: none;";
        if(elementContainerBackgroundColor.length() > 0)
            styleCss += "background-color:" + elementContainerBackgroundColor + ";";
        styleCss += "\"";
        return styleCss;
    }

    public String buildTextArea(String elementDisabled, String dataFilterAttrs, String elementDbColumnName, String triggerClasses, String elementValue,String section,String elementRuleField, boolean required) {
        String textArea="<textarea " + elementDisabled + dataFilterAttrs + "  id=\"" + elementDbColumnName + "\" name=\"" + elementDbColumnName + "\" class=\"form-control  " + triggerClasses + "\" value=\"" + elementValue + "\" style=\"width:100%; height: 120px;\"";
        if(required) textArea+=" required ";
        if(section.equals("rule_section") && elementRuleField.equals("1")) textArea+=" onchange=\"applyRuleFields(this);\" ";

        textArea+=">" + elementValue + "</textarea>";
        return textArea;
    }

    public String buildLabel(String elementClass,String elementFontWeight,String elementFontSize,String elementColor,String elementLabel,boolean required){
        String label = "<label class=\"";
        label+= " "+elementClass+" ";
        label+="control-label col-form-label\" style=\"font-weight:" + elementFontWeight + ";font-size: " + elementFontSize + ";color:" + elementColor + "\">" + elementLabel;
        if(required) 
            label+=" <span style=\"color: red;\">*</span>";
        label+="</label>";
        return label;
    }    

    public String getErrorMessageHtml(String elementErrorMsg, String errorField ,com.etn.beans.Contexte etn, javax.servlet.http.HttpServletRequest request){
        String errorMessageHtml = "<div style=\"display: none;\" class=\"error_msgs invalid-feedback\">";
        if(elementErrorMsg.length() > 0)
            errorMessageHtml += elementErrorMsg;
        else
            errorMessageHtml += libelle_msg(etn, request, errorField);
        errorMessageHtml += "</div>";
        return errorMessageHtml;
    }

    public String buildHiddenField(String name, String id, String value)
    {
        String html="<input type=\"hidden\" name=\"" +name+"\" id=\"" + id + "\" value=\"";
        if(value.length() > 0) html+=value;
        html+="\" />";
        return html;
    }

    public String buildHorizontalRuler(String elementResizableColClass)
    {
        String html="";
        html+="<div class=\"col-sm-" + elementResizableColClass + "\">";
        html+="<hr style=\"border-width: 1px; border-style: inset; clear: both;\" />";
        html+="</div>";
        return html;
    }

    public String buildCheckBox(JSONArray optionTxtArray,JSONArray optionValArray, String elementDbColumnName,boolean isInLine, boolean ruleField)
    {
        String html="";
        try{
            for(int i=0; i < optionTxtArray.length(); i++){
                html+="<div class=\"mt-2 form-check ";
                if(isInLine) html+=" form-check-inline ";
                html+="\" >";
                html+="<input class=\"form-check-input\" type=\"checkbox\" id=\""+elementDbColumnName+Integer.toString(i)+"\" name=\""+elementDbColumnName+"\"";
                if(ruleField) html+=" onchange=\"applyRuleFields(this);\" ";
                html+=" /><label class=\"form-check-label\" for=\""+elementDbColumnName+Integer.toString(i)+"\" >"+optionValArray.get(i).toString()+"</label>";
                html+="</div>";
            }
        } catch(JSONException e){ 
            e.printStackTrace();
        }
        return html;
    }

    public String buildRadioButton(JSONArray optionTxtArray,JSONArray optionValArray, String elementDbColumnName,boolean isInLine, boolean ruleField)
    {
        String html="";
        try{
            for(int i=0; i < optionTxtArray.length(); i++){
                html+="<div class=\"mt-2 form-check ";
                if(isInLine) html+=" form-check-inline ";
                html+="\" >";
                html+="<input class=\"form-check-input\" type=\"radio\" id=\""+elementDbColumnName+Integer.toString(i)+"\" name=\""+elementDbColumnName+"\"";
                if(ruleField) html+=" onchange=\"applyRuleFields(this);\" ";
                html+=" /><label class=\"form-check-label\" for=\""+elementDbColumnName+Integer.toString(i)+"\" >"+optionValArray.get(i).toString()+"</label>";
                html+="</div>";
            }
        } catch(JSONException e){ 
            e.printStackTrace();
        }
        return html;
    }

    /*public String buildHyperlink(String )
    {

        return "";
    }*/

    public String buildFileUpload(String dataFilterAttrs, String elementDbColumnName, String elementMaxLength, String elementPlaceholder,String elementValue,  String triggerClasses, String fileExtension, boolean disabled,boolean required, boolean ruleField){

        String html = "";
        html+="<input autocomplete=\"off\" " + dataFilterAttrs + " style=\"min-width: 100%;\" name=\"" + elementDbColumnName + "\" id=\"" + elementDbColumnName + "\" accept=\"" + fileExtension + "\" type=\"file\" maxlength=\"" + elementMaxLength + "\" placeholder=\"" + elementPlaceholder + "\" value=\"" + elementValue + "\" ";
        if(disabled) html+= " disabled ";
        if(required) html+=" required=\"required\"";
        if(ruleField) html+=" onchange=\"applyRuleFields(this);\" ";
        String fileParams = fileExtension.replace("."," ");
        html+=" onchange=\"setFileName('" + elementDbColumnName + "','" +fileParams+ "')\" class=\"form-control\"/>";

        html+="<label>"+fileParams+"</label>";
        return html;
    }

    public String buildDropDown(JSONArray optionValArray, JSONArray optionTxtArray, String dataFilterAttrs, String elementDbColumnName, String triggerClasses, boolean required, boolean rule_field,boolean disabled)
    {
        String html = "";
        try{
            
            html +="<select ";
            
            if (disabled) html+=" disabled ";
            if(required) html+=" required=\"required\"";
            if(rule_field) html+=" onchange=\"applyRuleFields(this);\" ";

            html+=dataFilterAttrs + " id=\"" + elementDbColumnName + "\" name=\"" + elementDbColumnName + "\" class=\"form-control  form-select" + triggerClasses + "\"";
            html+=" >";

            for(int i=0; i < optionTxtArray.length(); i++){
                if(optionValArray.get(i).toString().equals("---select---"))
                    html+="<option value=\"\" ";
                else
                    html+="<option value=\"" + optionValArray.get(i).toString() + "\" ";
                html+=">" + optionTxtArray.get(i).toString() + "</option>";
            }

            html+="</select>";

        } catch (JSONException e) {
            e.printStackTrace();
        }
        return html;
    }

    public String buildInputField(String elementType,String dataFilterAttrs,String elementStyle,String elementDbColumnName,String elementMaxLength,String elementPlaceholder,String elementValue,String triggerClasses, boolean required, boolean disabled){ 
        
        String html = "";
        html += "<input type=\""+elementType+"\" autocomplete=\"off\" "+dataFilterAttrs+" style=\""+elementStyle+"\" name=\""+elementDbColumnName+"\" maxlength=\""+elementMaxLength+"\" placeholder=\""+elementPlaceholder+"\" value=\""+elementValue+"\" id=\""+elementDbColumnName+"\" class=\""+elementType+" "+triggerClasses+"\" ";
        if(disabled) html+=" disabled ";
        if(required) html+="required=\"required\" "; 
        html+=" />";
        return html;
    }

    public String parseNull(String s)
    {
        if (s == null) return ("");
        if (s.equals("null")) return ("");
        return (s.trim());
    }

    public int parseNullInt(String s)
    {
        if (s == null) return 0;
        if (s.equals("null")) return 0;
        if (s.equals("")) return 0;
        return Integer.parseInt(s);
    }

    public double parseNullDouble(String s)
    {
        if (s == null) return 0;
        if (s.equals("null")) return 0;
        if (s.equals("")) return 0;
        return Double.parseDouble(s);
    }

    String replaceQoute(String str)
    {
        if(str == null || str.trim().length() == 0) return "";

        str = str.trim();
        String tmp = com.etn.sql.escape.cote(str).trim();
        if(tmp.startsWith("'")) tmp = tmp.substring(1);
        if(tmp.endsWith("'")) tmp = tmp.substring(0, tmp.length() - 1);
        return tmp;
    }

	public String escapeCoteValue(String str)
	{
		return com.etn.asimina.util.UIHelper.escapeCoteValue(str);
	}

    private String buildDate(Date date, String adjustDays){

      Calendar cal = new GregorianCalendar();
      cal.setTime(date);
      cal.add(Calendar.DATE, parseNullInt(adjustDays));

      int day = cal.get(java.util.Calendar.DAY_OF_MONTH);
      int month = cal.get(java.util.Calendar.MONTH) + 1;
      int year = cal.get(java.util.Calendar.YEAR);

      return (day <=9 ? "0"+day: day) + "/"  +(month <=9 ? "0"+month: month)  + "/" + year;
    }

    private String buildDateFormat(String date, String format) throws Exception {

        Date d = new java.text.SimpleDateFormat("dd/MM/yyyy").parse(date);
        if(format.equals("d/m/Y")){

            date = new java.text.SimpleDateFormat("dd/MM/yyyy").format(d);

        } else if(format.equals("m/d/Y")){

            date = new java.text.SimpleDateFormat("MM/dd/yyyy").format(d);

        }

        return date;
    }

    private String buildDateFr(String date){

        if(date.length() > 0){

            String token[] = date.split("/");
            return token[2] + "-" + token[1] + "-" + token[0];
        }

        return "";
    }

    private String buildDateTimeFr(String datetime){

        if(datetime.length() > 0){

            String token[] = datetime.split(" ");
            String date = "";

            if(token.length == 2) {

                date = token[0];

                String dateToken[] = date.split("/");
                String datetimeFinal = dateToken[0] + "-" + dateToken[1] + "-" + dateToken[2] + " ";

                datetimeFinal += token[1];
                return datetimeFinal;
            }
        }

        return "";
    }

    private String buildDateTimeDb(String datetime){

        if(datetime.length() > 0){

            String token[] = datetime.split(" ");
            String date = "";

            if(token.length == 2) {

                date = token[0];

                String dateToken[] = date.split("/");
                String datetimeFinal = dateToken[2] + "-" + dateToken[1] + "-" + dateToken[0] + " ";

                datetimeFinal += token[1];
                return datetimeFinal;
            }
        }

        return "";
    }
    
    private String loadDynamicsFieldsBoosted4(Set selectedRuleRs, String labelElementId, String elementFieldType, String elementDbColumnName, String elementFileExtension, String elementLabel, String elementFontWeight, String elementFontSize, String elementColor, String elementPlaceholder, String elementName, String elementValue, String elementMaxLength, String elementRequired, String elementRuleField, String elementAddNoOfDays, String elementStartTime, String elementEndTime, String elementTimeSlice, String elementDefaultTimeValue, String elementByDefaultField, String elementAutocompleteCharAfter, String elementTriggerAutocompleteQuery, String elementRegularExpression, int elementGroupOfFields, String elementTrigger, String elementLabelName, String elementId, String elementType, String elementOptionsClass, String elementOptionOthers, String elementOptionQuery, String elementOptionQueryValue, String elementResizableColClass, String elementOptions, Map selectedValueMap, String section, String defaultValueFlag, String formId, String ruleId, String fieldId, String processName, String tableId, String elementImageWidth, String elementImageHeight, String elementImageAlt, String elementImageMobileUrl, String elementHyperlinkCheckbox, String elementErrorMsg, String elementHrefTarget, String elementImgHrefUrl, String elementButtonId, String elementContainerBackgroundColor, String elementTextAlign, String elementTextBorder, String elementSiteKey, String elementTheme, String elementRecaptchaDataSize, com.etn.beans.Contexte etn, javax.servlet.http.HttpServletRequest request, String callingFrom, String lineId, String labelDisplay, int elementMinRange, int elementMaxRange, int elementStepRange, String elementImgUrl, String elementDefaultCountryCode, String elementAllowCountryCode, String elementAllowNationalMode, String elementLocalCountryName, String elementHiddenField, String langId, String elementIsDeletable, String elementCustomClasses, String elementCustomCss, String elementDateFormat, String elementFileBrowserValue, String siteId, String elementAutoFormatTelNo) {

        StringBuffer html = new StringBuffer();
        Date date = null;
        String _clss = "";
        String dataFilterAttrs = "data-noe-html-form-id='demand_form' data-noe-fname='" + elementDbColumnName + "' data-noe-form-id='" + formId + "' data-noe-rule-id='" + ruleId + "' data-noe-field-id='" + fieldId + "'";
        String triggerClasses = "";
        String errorMessageHtml = "";
        System.out.println("getLangs size ====="+getLangs(etn,siteId).size());
        String defaultLangId = getLangs(etn,siteId).get(0).getLanguageId();

        if(elementTrigger.length() > 2)
            triggerClasses = getCssClassesForTriggers(elementTrigger);

        /*&& elementAddNoOfDays.length()>0*/
        if((elementType.equals("textdate") || elementType.equals("textdatetime")) && elementValue.equalsIgnoreCase("today") ) {

            date = new Date();
        } else if(!elementValue.equalsIgnoreCase("today") && (elementType.equals("textdate") || elementType.equals("textdatetime"))){

          if(elementValue.length()>0){

            String d2[] = elementValue.split("/");
//            date = new Date(d2[1] + "/" + d2[2] + "/" + d2[0]);
          }
        }

//        if(fieldType.equals("datetime") && fieldByDefaultValue.contains("today") && adjustDays.length)

        if(null!=date){

          elementValue = buildDate(date, elementAddNoOfDays);
          if(elementDefaultTimeValue.length()>0) elementValue += " " + elementDefaultTimeValue;
          _clss = "date";
        }

        String hiddenTypeCallingFrom = "texthidden";

        if(elementType.equals("texthidden") && callingFrom.equals("frontendcall")) {

            elementType = "hidden";
            hiddenTypeCallingFrom = "hidden";
        }

        String styleCss = "style=\"";
        if(elementHiddenField.equals("1"))
            styleCss += "display: none; ";
        else
            styleCss += "";

        if(elementContainerBackgroundColor.length() > 0)
            styleCss += "background-color: " + elementContainerBackgroundColor + "; ";

        styleCss += "\"";

        String elementDisabled = "";
        if(lineId.length() == 0)
            elementDisabled = " disabled ";

        if(elementType.equals("textfield") || elementType.equals("multextfield") || elementType.equals("autocomplete") || elementType.equals("email") || elementType.equals("number") || elementType.equals("texttextarea") || elementType.equals(hiddenTypeCallingFrom) || elementType.equals("fileupload") || elementType.equals("textdate") || elementType.equals("textdatetime") || elementType.equals("password") || elementType.equals("range") || elementType.equals("tel")){

            errorMessageHtml = "<div style=\"display: none;\" class=\"error_msgs invalid-feedback\">";

            if(elementErrorMsg.length() > 0)
                errorMessageHtml += elementErrorMsg;
            else
                errorMessageHtml += libelle_msg(etn, request, "You must fill the value");

            errorMessageHtml += "</div>";

            if(!elementType.equals(hiddenTypeCallingFrom) || callingFrom.equals("backendcall")){

                html.append("<div " + styleCss + " class=\"col " + elementDbColumnName +" "+elementCustomClasses);
                if(lineId.length() > 0) html.append(" activeField ");
                html.append("\"> ");

                if(labelDisplay.equalsIgnoreCase("tal"))
                    html.append("<div class=\"row\">");
                else if(labelDisplay.equalsIgnoreCase("lal"))
                    html.append("<div class=\"form-group row\">");

                if(callingFrom.equals("backendcall")){

                    html.append("<div class=\"field-edit\">");
                    html.append("<button line-form-id=\"" + formId + "\" line-id=\"" + lineId + "\" line-field-id=\"" + fieldId + "\" field-type=\"" + elementType + "\" field-label=\"" + elementType + "\" lang-id=\"" + langId + "\" class=\"btn btn-sm btn-primary mr-1 mb-0 btn-modal add_field_to_form\" data-toggle=\"modal\" data-target=\"#add_field_to_form\"> edit field </span>");

                    if(defaultLangId.equals(langId) && elementIsDeletable.equals("1")){

                        html.append("<button line-form-id=\"" + formId + "\" line-id=\"" + lineId + "\" line-field-id=\"" + fieldId + "\" line-col-name=\"" + elementDbColumnName + "\" lang-id=\"" + langId + "\" class=\"btn btn-sm btn-danger mr-1 mb-0\" onclick='deleteElement(this)'> delete </span></button>");
                    }

                    html.append("</div>");

                    html.append("<div class=\"field-edit-bgnd\"> &nbsp; </div>");
                }

                html.append("<label class=\"");

                if(labelDisplay.equalsIgnoreCase("tal"))
                    html.append("col-sm-9 ");
                else if(labelDisplay.equalsIgnoreCase("lal")){

                    html.append("col-sm-3 ");

                }

                html.append("control-label col-form-label\" style=\"font-weight:" + elementFontWeight + "; font-size: " + elementFontSize + "; color: " + elementColor + "\">" + elementLabel);

                if(elementRequired.equals("1")) html.append(" <span style=\"color: red;\">*</span>");

                html.append("</label>");

                if(labelDisplay.equalsIgnoreCase("tal")) {

                    if(elementType.equals("range") && callingFrom.equals("backendcall")){


                        html.append("<div class=\"col-sm-10 ");

                    } else if( elementType.equals("range") && callingFrom.equals("frontendcall"))
                        html.append("<div class=\"col-sm-11 ");
                    else
                        html.append("<div class=\"col-sm-12 ");

                } else if(labelDisplay.equalsIgnoreCase("lal")){
                    if(elementType.equals("range")){

                        if(callingFrom.equals("backendcall")){
                            html.append("<div class=\"col-sm-7");
                        }else if(callingFrom.equals("frontendcall"))
                            html.append("<div class=\"col-sm-8");
                    }
                    else
                        html.append("<div class=\"col-sm-9 ");
                }

                if(elementType.equals("range"))
                    html.append(" js-focus-visible mt-2");

                html.append("\">");

            }

            if(!defaultValueFlag.equals("1")) elementValue = "";

            if(null != selectedValueMap && null != selectedValueMap.get(labelElementId))
                elementValue = selectedValueMap.get(labelElementId).toString();

            if(elementType.equals("texttextarea")){

                html.append("<textarea " + elementDisabled + dataFilterAttrs + "  id=\"" + elementDbColumnName + "\" name=\"" + elementDbColumnName + "\" class=\"form-control  " + triggerClasses + "\" value=\"" + elementValue + "\" style=\"width:100%; height: 120px;\"");

                if(elementRequired.equals("1")) html.append(" required=\"required\"");
                if(section.equals("rule_section") && elementRuleField.equals("1")) html.append(" onchange=\"applyRuleFields(this);\" ");

                html.append(">" + elementValue + "</textarea>");
                html.append(errorMessageHtml);

            }else{

                if(elementType.equals("textdatetime")){

                    html.append("<input type=\"hidden\" name=\"" + elementDbColumnName + "_start_time\" id=\"" + elementDbColumnName + "_start_time\" value=\"");

                    if(elementStartTime.length() > 0) html.append(elementStartTime);

                    html.append("\" />");

                    html.append("<input type=\"hidden\" name=\"" + elementDbColumnName + "_end_time\" id=\"" + elementDbColumnName + "_end_time\" value=\"");

                    if(elementEndTime.length() > 0) html.append(elementEndTime);

                    html.append("\" />");

                    html.append("<input type=\"hidden\" name=\"" + elementDbColumnName + "_time_slice\"  id=\"" + elementDbColumnName + "_time_slice\" value=\"");

                    if(elementTimeSlice.length() > 0) html.append(elementTimeSlice);

                    html.append("\" />");
                }

                if(elementType.equals("multextfield")){

                    if(elementValue.length() > 0){

                        String multfToken[] = elementValue.split(",");
                        String multfInnerToken[] = null;

                        for(int i=0; i < multfToken.length; i++){

                            multfInnerToken = multfToken[i].split(";");

                            html.append("<div>");
                            for(int j=0; j < multfInnerToken.length; j++){

                                html.append("<input readonly " + dataFilterAttrs + " style=\"height: 34px; padding: 6px 12px; font-size: 14px; line-height: 1.42; color: #555; background-color: #fff;\" type=\"" + elementType + "\" maxlength=\"" + elementMaxLength + "\" placeholder=\"" + elementPlaceholder + "\" value=\"" + multfInnerToken[j] + "\"");

                                if(elementRequired.equals("1")) html.append(" required=\"required\"");
                                if(section.equals("rule_section") && elementRuleField.equals("1")) html.append(" onchange=\"applyRuleFields(this);\" ");

                                html.append(" pattern=\"" + elementRegularExpression + "\" id=\"" + elementDbColumnName + "\" name=\"" + elementDbColumnName + "\" class=\" " + triggerClasses + " " + elementType + "\" />");
                            }

                            html.append("<span onclick=\"edit_multitextfield(this,'" + elementGroupOfFields + "')\" class=\"glyphicon glyphicon-pencil multi-edit-btn\" style=\"margin-top: 3px; cursor: pointer;\"></span>");

                            html.append("<span onclick=\"delete_multitextfield(this)\" class=\"glyphicon glyphicon-remove multi-edit-btn\" style=\"margin-top: 3px; cursor: pointer;\"></span>");

                            if(i != multfToken.length-1) html.append("<br/>");
                            html.append("</div>");
                       }
                    }

                    for(int k=0; k < elementGroupOfFields; k++){

                        html.append("<input " + dataFilterAttrs + " style=\"height: 34px; padding: 6px 12px; font-size: 14px; line-height: 1.42; color: #555; background-color: #fff;\" type=\"" + elementType + "\" maxlength=\"" + elementMaxLength + "\" placeholder=\"" + elementPlaceholder + "\" ");

                        if(elementRequired.equals("1")) html.append(" required=\"required\"");
                        if(section.equals("rule_section") && elementRuleField.equals("1")) html.append(" onchange=\"applyRuleFields(this);\" ");

                        html.append(" pattern=\"" + elementRegularExpression + "\" id=\"" + elementDbColumnName + "\" class=\" " + triggerClasses + " " + elementType + "\" />");
                    }

                    html.append("<span onclick=\"add_mutlitextfied(this,'" + elementGroupOfFields + "','" + elementDbColumnName + "')\" style=\"margin-left: 5px; margin-top: 3px; cursor: pointer;\" class=\"glyphicon glyphicon-plus multi-edit-btn\"></span>");

                    html.append(errorMessageHtml);

                } else {

                    if(elementType.equals("fileupload") && processName.equals("")) html.append("<label class=\"custom-file\" style=\"padding: 5px 10px; margin: 2px; background: #CCC; display: inline-block;\">");

                    html.append("<input autocomplete=\"off\" " + elementDisabled + dataFilterAttrs + " style=\"min-width: 100%; ");

                    if(elementType.equals("fileupload")) html.append("position: fixed; top: -1000px;");

                    html.append("\" name=\"" + elementDbColumnName + "\"");

                    if(elementType.equals("fileupload")) {
                        
                        if(elementFileExtension.length() > 0 && elementFileExtension.contains(",")){

                            String extensionToken[] = elementFileExtension.split(",");
                            String extensionAccepts = "";
                            for(int a=0; a<extensionToken.length; a++){

                                extensionAccepts += "." + extensionToken[a].trim() + ",";
                            }

                            if(extensionAccepts.length() > 0){
                             
                                extensionAccepts = extensionAccepts.substring(0, extensionAccepts.length()-1);
                                html.append(" accept=\"" + extensionAccepts + "\" ");
                            }
                        }
                    }

                    html.append(" type=\"");
                    if(elementType.equals("fileupload")) html.append("file");
                    else html.append(elementType);

                    if(elementType.equals("range") && elementValue.length() == 0 || elementValue.equals("0"))
                        elementValue = elementMinRange+"";

                    html.append("\" maxlength=\"" + elementMaxLength + "\" placeholder=\"" + elementPlaceholder + "\" value=\"" + elementValue + "\"");

                    if(elementRequired.equals("1")) html.append(" required=\"required\"");
                    if(section.equals("rule_section") && elementRuleField.equals("1")) html.append(" onchange=\"applyRuleFields(this);\" ");
                    String iconName="";
                    if(elementType.equals("fileupload")) 
                    { 
                        String query3="select DISTINCT icon FROM supported_files where LOCATE(extension,"+escape.cote(elementFileExtension)+")>0";
                        //System.out.println(query3);
                        com.etn.lang.ResultSet.Set results3 = etn.execute(query3);
                        
                        if(results3.next())
                        {
                            // find out more than one rows are there to set default icon
                            if(results3.rs.Rows>1)
                            {
                            //System.out.println("more than one row found");
                                iconName="Upload.png";
                            }
                            else 
                            {
                                //System.out.println("one row found");
                                iconName=results3.value("icon");
                            }

                            //System.out.println("------------------------------------------"+results3.rs.Rows+"---------------");
                            //System.out.println("------------------------------------------"+results3.value("icon")+"------------------------------------------");
                        }
                        html.append(" onchange=\"setFileName('" + elementDbColumnName + "','" + elementFileExtension.replaceAll("\\s+","") + "')\" ");
                    }

                    if(elementType.equals("textfield")) html.append(" pattern=\"" + elementRegularExpression + "\" ");
                    else if(elementType.equals("autocomplete")) html.append(" data-noe-auto-char='" + elementAutocompleteCharAfter + "' ");

                    if(elementType.equals("range")){

                        html.append("min=\"" + elementMinRange + "\" max=\"" + elementMaxRange + "\" step=\"" + elementStepRange + "\" onchange=\"customRange(this)\"" );
                    }

                    if(elementType.equals("tel")){

                        if(elementDefaultCountryCode.length() == 0)
                            elementDefaultCountryCode = "auto";

                        if(elementAllowNationalMode.equals("1"))
                            elementAllowNationalMode = "true";
                        else if(elementAllowNationalMode.equals("0"))
                            elementAllowNationalMode = "false";

                        if(!elementAllowCountryCode.contains(elementDefaultCountryCode) && elementAllowCountryCode.length() > 0)
                            elementAllowCountryCode += "," + elementDefaultCountryCode;

                        html.append(" auto-format-tel-no=\""+("1".equals(elementAutoFormatTelNo)?"true":"")+"\" default-country-code=\"" + elementDefaultCountryCode + "\" allow-country-code=\"" + elementAllowCountryCode + "\" allow-national-mode=\"" + elementAllowNationalMode + "\" local-country-name=\"" + elementLocalCountryName + "\" ");
                    }

                    html.append("id=\"" + elementDbColumnName + "\" class=\" " + triggerClasses + " " + elementType);

                    if(elementType.equals("range"))
                        html.append(" custom-range");
                    else
                        html.append(" form-control");

                    if(elementType.equals("autocomplete")) html.append(" noe_auto_complete ");

                    html.append("\"");

                    if(elementType.equals("textdate") || elementType.equals("textdatetime")) 
                        html.append(" readonly date-format=\"" + elementDateFormat + "\" ");



                    html.append("/>");

                    if(elementType.equals("fileupload")) {

                        if(processName.equals("")){

                            if(elementPlaceholder.length() == 0)
                                elementPlaceholder = libelle_msg(etn, request, " ");

                            html.append("<span class='custom-file-label "+ elementDbColumnName +"' >" + elementPlaceholder + "</span> <span>");
                            html.append("<button type='button' id='custom-file-button"+ elementDbColumnName +"' value='test' align='right' style=' position: absolute;right: 8px;top: 7px;z-index: 1000;border: none;background: white;color: black;display: none;' class onclick=\"removeFileSelection('" + elementDbColumnName + "',' ')\" ><img src=\""+request.getContextPath()+"/img/icons/x.png\" alt=\"X\"></button> </label>");
                            html.append("<label> " + elementFileExtension + "</label>");
                            html.append("</span>");

                            if(elementFileBrowserValue.length() == 0)
                                elementFileBrowserValue = libelle_msg(etn, request, "Browser");
                                
                            html.append("<style>.custom-file-label."+ elementDbColumnName +"::after{content:\" \"; background-image: url("+request.getContextPath()+"/img/icons/"+iconName+"); background-size: 25px; background-repeat: no-repeat; background-position: center; width: 50px; background-color: transparent; border: none;}</style>");
                        }
                        html.append("<div id=\"files_list_" + elementDbColumnName + "\">");

                        if(elementValue.length() > 0){

    //                        String tsp[] = elementValue.split(";");

  //                          for(int z=0; z<tsp.length; z++){

                                String img = elementValue;
                                String extension = "";

                                if(img.length() > 0 && !img.contains(";base64,")){
        
                                    img = GlobalParm.getParm("FORM_UPLOADS_PATH") + formId + "/" + tableId + "/" + elementValue;
                                    extension = parseNull(img.substring(img.lastIndexOf(".")));
                                }

                                if(extension.length() > 0 && (extension.equals(".jpg") || extension.equals(".jpeg") || extension.equals(".png"))){

                                    html.append("<a href=\"" + img + "\" target='_blank' class=\"avatar rounded-circle overflow-hidden\"> <img class=\"\" style=\"max-height:60px; max-width:60px\" alt=\"" + elementValue + "\" src=\"" + img + "\" /> </a> <br/>");
    
                                } else {

                                    html.append("<a href=\"" + img + "\" target='_blank' > " + elementValue + " </a> <br/>");
                                }
/*
                                if(processName.equals("")){

                                    html.append("<span id=\"removefilenamespn_files_" +  z + "\" style=\"margin-left: 5px; font-weight: bold; color: red; cursor: pointer;\" onclick=\"removeFileSelection('" + elementDbColumnName + "','" + elementFileExtension + "')\">X</span><br/>");
                                }
                            }
*/
                        }

                        html.append("</div>");

                    }

                    if(elementType.equals("textdate") || elementType.equals("textdatetime")){
                        html.append("<a style=\"position: absolute; right: 30px; top: 8px; cursor: pointer;\"><img src=\""+request.getContextPath()+"/img/cal.png\" alt /></a>");
                    }

                    html.append(errorMessageHtml);
                }

            }

            if( callingFrom.equals("backendcall")){

//                if(callingFrom.equals("backendcall"))
                    html.append("</div>");

                if(elementType.equals("range")){

                    html.append("<label id=\"customRange" + elementDbColumnName + "\" class=\"col-");
                    if(callingFrom.equals("backendcall"))
                        html.append("2");
                    else
                        html.append("1");
    /*                    if(labelDisplay.equalsIgnoreCase("lal") || callingFrom.equals("backendcall"))
                        html.append("1 ");
                    else if(labelDisplay.equalsIgnoreCase("tal"))
                        html.append("3 ");
    */
                    html.append(" col-form-label text-right\">" + elementValue + "</label>");
//                    if(callingFrom.equals("backendcall"))
  //                      html.append("</div>");

                }

  //              if(callingFrom.equals("backendcall"))
                    html.append("</div>");
         
            }

            if(!elementType.equals(hiddenTypeCallingFrom) || callingFrom.equals("backendcall"))
                html.append("</div>");

            if(!elementType.equals(hiddenTypeCallingFrom) && !callingFrom.equals("backendcall")){
                 
                 if(elementType.equals("range")){

                    html.append("<label id=\"customRange" + elementDbColumnName + "\" class=\"col-1");
                    html.append(" col-form-label text-right\">" + elementValue + "</label>");


                }    

                html.append("</div>");
                html.append("</div>");
            }

        } else if(elementType.equals("imgupload")){

            String imagePath = GlobalParm.getParm("FORM_UPLOADS_PATH") + "images/";

            if(callingFrom.equals("backendcall")){

                html.append("<div " + styleCss + " class=\"col " + elementDbColumnName+" "+elementCustomClasses);
                if(lineId.length() > 0) html.append(" activeField ");

                if(callingFrom.equals("backendcall"))
                    html.append("\" > <div class=\"row form-group\">");
                else{

                    html.append("\"> ");

                    if(labelDisplay.equalsIgnoreCase("tal"))
                        html.append("<div class=\"row\">");
                    else if(labelDisplay.equalsIgnoreCase("lal"))
                        html.append("<div class=\"form-group row\">");
                }

                if(callingFrom.equals("backendcall")){

                    html.append("<div class=\"field-edit\">");
                    html.append("<button line-form-id=\"" + formId + "\" line-id=\"" + lineId + "\" line-field-id=\"" + fieldId + "\" field-type=\"" + elementType + "\" field-label=\"" + elementType + "\" lang-id=\"" + langId + "\" class=\"btn btn-sm btn-primary mr-1 mb-0 btn-modal add_field_to_form\" data-toggle=\"modal\" data-target=\"#add_field_to_form\"> edit field </span>");

                    if(defaultLangId.equals(langId) && elementIsDeletable.equals("1")){

                        html.append("<button line-form-id=\"" + formId + "\" line-id=\"" + lineId + "\" line-field-id=\"" + fieldId + "\" line-col-name=\"" + elementDbColumnName + "\" lang-id=\"" + langId + "\" class=\"btn btn-sm btn-danger mr-1 mb-0\" onclick='deleteElement(this)'> delete </span></button>");
                    }

                    html.append("</div>");

                    html.append("<div class=\"field-edit-bgnd\"> &nbsp; </div>");
                }

                html.append("<label class=\"");

                if(labelDisplay.equalsIgnoreCase("tal"))
                    html.append("col-sm-9 ");
                else if(labelDisplay.equalsIgnoreCase("lal"))
                    html.append("col-sm-3 ");

                html.append("control-label col-form-label\" style=\"font-weight:" + elementFontWeight + "; font-size: " + elementFontSize + "; color: " + elementColor + "\">" + elementLabel);

                if(elementRequired.equals("1")) html.append(" <span style=\"color: red;\">*</span>");

                html.append("</label>");

                if(labelDisplay.equalsIgnoreCase("tal"))
                    html.append("<div class=\"col-sm-12\">");
                else if(labelDisplay.equalsIgnoreCase("lal"))
                    html.append("<div class=\"col-sm-9\">");
            }

            html.append("<div style=\"background-color: " + elementColor + "\" class=\"display-desktop col activeField mt-2\">");
            html.append("<a target='" + elementHrefTarget + "' href='");

            if(elementImgHrefUrl.length() > 0) {
                if(elementImgHrefUrl.contains("http") || elementImgHrefUrl.contains("https"))
                    html.append(elementImgHrefUrl);
                else
                    html.append("https://"+elementImgHrefUrl);
            }
            else html.append("#");

            html.append("'> <img  title='" + elementImageAlt + "' src='" + imagePath + elementImgUrl + "' style='width: " + elementImageWidth + " height: " + elementImageHeight + "' > </a>");
            html.append("</div>");

            if(elementImageMobileUrl.length() > 0){

                html.append("<div style=\"background-color: " + elementColor + "\" class=\"display-mobile col-sm-" + elementResizableColClass + "\">");
                html.append("<center> <img title='" + elementImageAlt + "' src='" + imagePath + elementImageMobileUrl + "' style='width: " + elementImageWidth + " height: " + elementImageHeight + "' > </center>");
                html.append("</div>");
            }

            if(callingFrom.equals("backendcall")){

                html.append("</div>");
                html.append("</div>");
                html.append("</div>");
            }

        } else if(elementType.equals("hyperlink")){

            errorMessageHtml = "<div style=\"display: none;\" class=\"error_msgs invalid-feedback\">";

            if(elementErrorMsg.length() > 0)
                errorMessageHtml += elementErrorMsg;
            else
                errorMessageHtml += libelle_msg(etn, request, "You must select the checkbox");

            errorMessageHtml += "</div>";

            html.append("<div " + styleCss + " class=\"col " + elementDbColumnName+" "+elementCustomClasses);
            if(lineId.length() > 0) html.append(" activeField ");

            html.append("\"> <div class=\"row\">");
            html.append("<label class=\"col-sm-");

           if(labelDisplay.equalsIgnoreCase("tal"))
                html.append("9");
            else if(labelDisplay.equalsIgnoreCase("lal"))
                html.append("3");

            html.append(" control-label col-form-label\">" + elementLabel);
            if(elementRequired.equals("1")) html.append(" <span style=\"color: red;\">*</span>");
            html.append("</label>");

            if(callingFrom.equals("backendcall")){

                html.append("<div class=\"field-edit\">");
                html.append("<button line-form-id=\"" + formId + "\" line-id=\"" + lineId + "\" line-field-id=\"" + fieldId + "\" field-type=\"" + elementType + "\" field-label=\"" + elementType + "\" lang-id=\"" + langId + "\" class=\"btn btn-sm btn-primary mr-1 mb-0 btn-modal add_field_to_form\" data-toggle=\"modal\" data-target=\"#add_field_to_form\"> edit field </span>");

                if(defaultLangId.equals(langId) && elementIsDeletable.equals("1")){

                    html.append("<button line-form-id=\"" + formId + "\" line-id=\"" + lineId + "\" line-field-id=\"" + fieldId + "\" line-col-name=\"" + elementDbColumnName + "\" lang-id=\"" + langId + "\" class=\"btn btn-sm btn-danger mr-1 mb-0\" onclick='deleteElement(this)'> delete </span></button>");
                }

                html.append("</div><div class=\"field-edit-bgnd\"> &nbsp; </div>");
            }

            if(labelDisplay.equalsIgnoreCase("tal"))
                html.append("<div class=\"col-sm-12\">");
            else if(labelDisplay.equalsIgnoreCase("lal"))
                html.append("<div class=\"col-sm-9\">");

                html.append("<div class=\"");
                
                if(labelDisplay.equalsIgnoreCase("lal"))
                    html.append("mt-2");
                
                html.append("\"><label class=\"js-focus-visible custom-control custom-checkbox\">");

                if(elementHyperlinkCheckbox.equals("1")) {

                    html.append("<input name=\"" + elementDbColumnName + "\"" + dataFilterAttrs + " type=\"checkbox\" ");

                    if(elementRequired.equals("1"))
                        html.append("required=\"required\"");

                    html.append(" class=\"custom-control-input\"");
                    html.append("/>");
                }

                html.append("<span class=\"");

                if(elementHyperlinkCheckbox.equals("1"))
                    html.append(" custom-control-label ");

                html.append("\"> <a class=\"\" target=\"" + elementHrefTarget + "\" " + dataFilterAttrs + " href=\"");

                if(elementImgHrefUrl.length() > 0) {
                    if(elementImgHrefUrl.contains("http") || elementImgHrefUrl.contains("https"))
                        html.append(elementImgHrefUrl);
                    else
                        html.append("https://"+elementImgHrefUrl);
                }
                else html.append("#");

                html.append("\" style=\"font-weight: " + elementFontWeight + "; font-size: " + elementFontSize + "; color: " + elementColor + ";\">");
                html.append(elementValue+"</a>");

                html.append("</span>");
                html.append("</label>");
                html.append("</div>");



            html.append(errorMessageHtml);
            html.append("</div></div></div>");

        } else if(elementType.equals("button")){

            html.append("<div " + styleCss + " class=\"col " + elementDbColumnName + " "+elementCustomClasses);
            if(lineId.length() > 0) html.append(" activeField ");
            html.append("\"> <div class=\"row form-group\">");

            html.append("<label class=\"col-sm-3 col-form-label\">&nbsp;</label>");

            if(callingFrom.equals("backendcall")){

                html.append("<div class=\"field-edit\">");
                html.append("<button line-form-id=\"" + formId + "\" line-id=\"" + lineId + "\" line-field-id=\"" + fieldId + "\" field-type=\"" + elementType + "\" field-label=\"" + elementType + "\" lang-id=\"" + langId + "\" class=\"btn btn-sm btn-primary mr-1 mb-0 btn-modal add_field_to_form\" data-toggle=\"modal\" data-target=\"#add_field_to_form\"> edit field </span>");

                if(defaultLangId.equals(langId) && elementIsDeletable.equals("1")){

                    html.append("<button line-form-id=\"" + formId + "\" line-id=\"" + lineId + "\" line-field-id=\"" + fieldId + "\" line-col-name=\"" + elementDbColumnName + "\" lang-id=\"" + langId + "\" class=\"btn btn-sm btn-danger mr-1 mb-0\" onclick='deleteElement(this)'> delete </span></button>");
                }

                html.append("</div> <div class=\"field-edit-bgnd\"> &nbsp; </div>");
            }

            if(labelDisplay.equalsIgnoreCase("tal"))
                html.append("<div class=\"col-sm-12\">");
            else if(labelDisplay.equalsIgnoreCase("lal"))
                html.append("<div class=\"col-sm-9\">");

            html.append("<input " + dataFilterAttrs + " style=\"min-width: 100%;\" id=\"" + elementButtonId + "\" name=\"" + elementButtonId.toLowerCase() + "\" type=\"" + elementType + "\" value=\"" + elementValue + "\" class=\"btn btn-secondary  " + triggerClasses + " " + elementType + "\" />");
            html.append("</div></div></div>");

        } else if(elementType.equalsIgnoreCase("label")){

            if(elementTextAlign.length() == 0) elementTextAlign = "left";

            html.append("<div " + styleCss + " class=\"col " + elementDbColumnName +" "+elementCustomClasses);
            if(lineId.length() > 0) html.append(" activeField ");

            if(callingFrom.equals("backendcall"))
                html.append(" m-2\"> <div class=\"row p-2\">");
            else
                html.append("\"> <div class=\"row\">");

            html.append("<label class=\"col-sm-9\"></label>");

            if(callingFrom.equals("backendcall")){

                html.append("<div class=\"field-edit\">");
                html.append("<button line-form-id=\"" + formId + "\" line-id=\"" + lineId + "\" line-field-id=\"" + fieldId + "\" field-type=\"" + elementType + "\" field-label=\"" + elementType + "\" lang-id=\"" + langId + "\" class=\"btn btn-sm btn-primary mr-1 mb-0 btn-modal add_field_to_form\" data-toggle=\"modal\" data-target=\"#add_field_to_form\"> edit field </span>");

                if(defaultLangId.equals(langId) && elementIsDeletable.equals("1")){

                    html.append("<button line-form-id=\"" + formId + "\" line-id=\"" + lineId + "\" line-field-id=\"" + fieldId + "\" line-col-name=\"" + elementDbColumnName + "\" lang-id=\"" + langId + "\" class=\"btn btn-sm btn-danger mr-1 mb-0\" onclick='deleteElement(this)'> delete </span></button>");
                }

                html.append("</div> <div class=\"field-edit-bgnd\"> &nbsp; </div>");
            }

            html.append("<div class=\"col-sm-12\">");
            html.append("<legend class=\"\" style=\"font-weight: " + elementFontWeight + "; font-size: " + elementFontSize + "; color: " + elementColor + ";\">" + elementLabelName + "</legend>");
            html.append("</div></div></div>");

/*


<div style="padding: 5px;" class="col-sm-12"><div class="form-group"><label class="col-sm-2 control-label" style="font-weight:400; font-size: 14px; color: #333333">Last Name <span style="color: red;">*</span></label><div class="col-sm-8"><input data-noe-html-form-id="demand_form" data-noe-fname="last_name" data-noe-form-id="ac0de344-f5f5-481d-ad79-4f8443ecacdb" data-noe-rule-id="" data-noe-field-id="d28b9f8e-673f-4cec-b32f-ceab9459ad36" style="min-width: 100%; " name="last_name" type="textfield" maxlength="" placeholder="Last Name" value="" required="required" pattern="" id="last_name" class="form-control  textfield"><div style="font-size:8pt; color:red; margin: 5px; display: none;" class="error_msgs">You must fill the value</div></div></div></div>

*/

        }  else if(elementType.equals("hr_line")){

            html.append("<div class=\"col-sm-" + elementResizableColClass + "\">");
            html.append("<hr style=\"border-width: 1px; border-style: inset; clear: both;\" />");
            html.append("</div>");

        } else if(elementType.equals("textrecaptcha")){

            errorMessageHtml = "<div style=\"display: none;\" class=\"error_msgs invalid-feedback\">";

            if(elementErrorMsg.length() > 0)
                errorMessageHtml += elementErrorMsg;
            else
                errorMessageHtml += libelle_msg(etn, request, "reCAPTCHA is mandatory");

            errorMessageHtml += "</div>";

            html.append("<div " + styleCss + " class=\"col " + elementDbColumnName +" "+elementCustomClasses);
            if(lineId.length() > 0) html.append(" activeField ");
            html.append("\"> <div class=\"row form-group\">");

            html.append("<label class=\"col-sm-3\"></label>");

            if(callingFrom.equals("backendcall")){

                html.append("<div class=\"field-edit\">");
                html.append("<button line-form-id=\"" + formId + "\" line-id=\"" + lineId + "\" line-field-id=\"" + fieldId + "\" field-type=\"" + elementType + "\" field-label=\"" + elementType + "\" lang-id=\"" + langId + "\" class=\"btn btn-sm btn-primary mr-1 mb-0 btn-modal add_field_to_form\" data-toggle=\"modal\" data-target=\"#add_field_to_form\"> edit field </span>");

                if(defaultLangId.equals(langId) && elementIsDeletable.equals("1")){

                    html.append("<button line-form-id=\"" + formId + "\" line-id=\"" + lineId + "\" line-field-id=\"" + fieldId + "\" line-col-name=\"" + elementDbColumnName + "\" lang-id=\"" + langId + "\" class=\"btn btn-sm btn-danger mr-1 mb-0\" onclick='deleteElement(this)'> delete </span></button>");
                }

                html.append("</div> <div class=\"field-edit-bgnd\"> &nbsp; </div>");
            }

            if(labelDisplay.equalsIgnoreCase("tal"))
                html.append("<div class=\"col-sm-12\">");
            else if(labelDisplay.equalsIgnoreCase("lal"))
                html.append("<div class=\"col-sm-9\">");

            html.append("<div class=\"g-recaptcha\" data-size=\"" + elementRecaptchaDataSize + "\" data-theme=\"" + elementTheme + "\" data-sitekey=\"" + elementSiteKey + "\"></div>");
            html.append(errorMessageHtml);
            html.append("</div></div></div>");

        } else if(elementType.equals("dropdown") || elementType.equals("radio") || elementType.equals("checkbox")){

            html.append("<div " + styleCss + " class=\"col " + elementDbColumnName +" "+elementCustomClasses);
            if(lineId.length() > 0) html.append(" activeField ");
            html.append("\"> ");

            if(labelDisplay.equalsIgnoreCase("tal"))
                html.append("<div class=\"row\">");
            else if(labelDisplay.equalsIgnoreCase("lal"))
                html.append("<div class=\"form-group row\">");

            html.append("<label class=\"");

            if(labelDisplay.equalsIgnoreCase("tal"))
                html.append("col-sm-9 ");
            else if(labelDisplay.equalsIgnoreCase("lal"))
                html.append("col-sm-3 ");

            html.append("control-label col-form-label\" style=\"font-weight:" + elementFontWeight + "; font-size: " + elementFontSize + "; color: " + elementColor + "\" >" + elementLabel);
            if(elementRequired.equals("1")) html.append(" <span style=\"color: red;\">*</span>");
            html.append("</label>");

            if(callingFrom.equals("backendcall")){

                html.append("<div class=\"field-edit\">");

                html.append("<button line-form-id=\"" + formId + "\" line-id=\"" + lineId + "\" line-field-id=\"" + fieldId + "\" field-type=\"" + elementType + "\" field-label=\"" + elementType + "\" lang-id=\"" + langId + "\" class=\"btn btn-sm btn-primary mr-1 mb-0 btn-modal add_field_to_form\" data-toggle=\"modal\" data-target=\"#add_field_to_form\"> edit field </span>");

                if(defaultLangId.equals(langId) && elementIsDeletable.equals("1")){

                    html.append("<button line-form-id=\"" + formId + "\" line-id=\"" + lineId + "\" line-field-id=\"" + fieldId + "\" line-col-name=\"" + elementDbColumnName + "\" lang-id=\"" + langId + "\" class=\"btn btn-sm btn-danger mr-1 mb-0\" onclick='deleteElement(this)'> delete </span></button>");
                }

                html.append("</div> <div class=\"field-edit-bgnd\"> &nbsp; </div>");
            }


            errorMessageHtml = "<div style=\"display: none;\" class=\"error_msgs invalid-feedback\">";

            if(elementErrorMsg.length() > 0)
                errorMessageHtml += elementErrorMsg;
            else
                errorMessageHtml += libelle_msg(etn, request, "Select an option");

            errorMessageHtml += "</div>";


            if(!elementOptions.equals("null") && elementOptions.length() > 0){

                try{

                    JSONObject optionsJson = new JSONObject(elementOptions);

                    if(optionsJson.length() > 0){

                        JSONArray optionTxtArray = optionsJson.getJSONArray("txt");
                        JSONArray optionValArray = optionsJson.getJSONArray("val");

                        String[] multipleValueToken = null;
                        String[] elementValueToken = elementValue.split(";");

                        if(labelDisplay.equalsIgnoreCase("tal"))
                            html.append("<div class=\"col-sm-12 ");
                        else if(labelDisplay.equalsIgnoreCase("lal"))
                            html.append("<div class=\"col-sm-9 ");

                        if(elementRequired.equals("1"))
                            html.append("req_fields");

                        if(elementOptionsClass.length() > 0)
                            html.append(" " + elementOptionsClass);

                        html.append("\"");

                        if(elementOptionsClass.length() > 0 && labelDisplay.equalsIgnoreCase("lal"))
                            html.append(" style=\"margin: 0;\"");

                        html.append(">");

                        String optionSelected = "";
                        boolean optionSelectedFlag = true;

                        if(elementType.equals("dropdown")){

                            boolean unCreatedOptionFormFLag = true;

                            html.append("<select " + elementDisabled + dataFilterAttrs + " id=\"" + elementDbColumnName + "\" name=\"" + elementDbColumnName + "\" class=\"form-control  " + triggerClasses + "\"");

                            if(elementRequired.equals("1")) html.append(" required=\"required\"");
                            if(section.equals("rule_section") && elementRuleField.equals("1")) html.append(" onchange=\"applyRuleFields(this);\" ");

                            html.append(" >");

                            for(int i=0; i < optionTxtArray.length(); i++){

                                optionSelected = "";
                                optionSelectedFlag = true;

                                if(optionValArray.get(i).toString().equals("---select---"))
                                    html.append("<option value=\"\" ");
                                else
                                    html.append("<option value=\"" + optionValArray.get(i).toString() + "\" ");

                                if(null != selectedRuleRs){
                                    while(selectedRuleRs.next() && optionSelectedFlag){
                                        if(selectedRuleRs.value(elementDbColumnName).equals(optionValArray.get(i).toString()))
                                            optionSelected = "selected=\"selected\"";
                                        else{

                                            optionSelected = "";
                                            optionSelectedFlag = false;
                                        }
                                    }

                                    selectedRuleRs.moveFirst();
                                    selectedRuleRs.next();
                                }

                                if(optionValArray.get(i).toString().equals(elementValue)){

                                    html.append(" selected=\"selected\" ");
                                }
                                else if(null != selectedValueMap && null != selectedValueMap.get(elementDbColumnName) &&
                                        selectedValueMap.get(elementDbColumnName).toString().equals(optionValArray.get(i).toString()))
                                    html.append(" selected=\"selected\" ");
                                else if(null != selectedRuleRs &&
                                            parseNull(selectedRuleRs.value(elementDbColumnName)).equals(optionValArray.get(i).toString()) && optionSelectedFlag)
                                    html.append(" selected=\"selected\" ");
                                else if(null != elementValueToken && elementValueToken.length > 0){
                                    for(int z=0; z < elementValueToken.length; z++){
                                        if(optionTxtArray.get(i).toString().equals(elementValueToken[z])){

                                            html.append(" selected=\"selected\"");
                                            unCreatedOptionFormFLag = false;
                                        }
                                    }
                                }

                                html.append(">" + optionTxtArray.get(i).toString() + "</option>");
                            }

    //                        if(unCreatedOptionFormFLag && elementValueToken.length == 1 && elementValue.length() > 0)
      //                          html.append("<option selected value=\"" + elementValue +  "\">" + elementValue + "</option>");

                            html.append("</select>");
                            html.append(errorMessageHtml);

                        } else {

                            errorMessageHtml = "<div style=\"display: none;\" class=\"error_msgs invalid-feedback\">";

                            if(elementErrorMsg.length() > 0)
                                errorMessageHtml += elementErrorMsg;
                            else
                                errorMessageHtml += libelle_msg(etn, request, "Select an option");

                            errorMessageHtml += "</div>";

                            for(int i=0; i < optionTxtArray.length(); i++){

                                optionSelected = "";
                                optionSelectedFlag = true;

                                html.append("<div class=\"mt-2");

                                if(elementOptionsClass.length() > 0)
                                    html.append(" ml-2 ");

                                html.append("\"> <label class=\"js-focus-visible custom-control custom-" + elementType + "\">");
                                html.append("<input " + elementDisabled + dataFilterAttrs + " type=\"" + elementType + "\" id=\"" + elementDbColumnName + "\" name=\"" + elementDbColumnName + "\" class=\"custom-control-input  " + triggerClasses + "\" value=\"" + optionValArray.get(i).toString() + "\"");

                                if(elementRequired.equals("1")) html.append(" required=\"required\"");
                                if(section.equals("rule_section") && elementRuleField.equals("1")) html.append(" onchange=\"applyRuleFields(this);\" ");

                                if(null != selectedRuleRs){
                                    while(selectedRuleRs.next() && optionSelectedFlag){
                                        if(selectedRuleRs.value(elementDbColumnName).equals(optionValArray.get(i).toString()))
                                            optionSelected = "selected=\"selected\"";
                                        else{

                                            optionSelected = "";
                                            optionSelectedFlag = false;
                                        }
                                    }

                                    selectedRuleRs.moveFirst();
                                    selectedRuleRs.next();
                                }

                                if(optionValArray.get(i).toString().equalsIgnoreCase(elementValue)){

                                    html.append(" checked=\"checked\"");
                                }
                                else if(null != selectedValueMap && null != selectedValueMap.get(elementDbColumnName)){

                                    if(selectedValueMap.get(elementDbColumnName).toString().contains(",")){

                                        multipleValueToken = selectedValueMap.get(elementDbColumnName).toString().split(",");
                                        for(int j=0; j < multipleValueToken.length; j++){

                                            if(multipleValueToken[j].equals(optionValArray.get(i).toString()))
                                                html.append(" checked=\"checked\" ");
                                            else if(null != selectedRuleRs && parseNull(selectedRuleRs.value(elementDbColumnName)).equals(optionValArray.get(i).toString()))
                                                html.append(" checked=\"checked\" ");
                                        }
                                    }else if(selectedValueMap.get(elementDbColumnName).equals(optionValArray.get(i).toString())){

                                        html.append(" checked=\"checked\" ");
                                    } else if(null != selectedRuleRs && parseNull(selectedRuleRs.value(elementDbColumnName)).equals(optionValArray.get(i).toString()))
                                        html.append(" checked=\"checked\" ");

                                } else if(null != selectedRuleRs && parseNull(selectedRuleRs.value(elementDbColumnName)).equals(optionValArray.get(i).toString())
                                                && optionSelectedFlag)
                                    html.append(" checked=\"checked\" ");
                                else if(null != elementValueToken && elementValueToken.length > 0){
                                    for(int z=0; z < elementValueToken.length; z++){
                                        if(optionTxtArray.get(i).toString().equals(elementValueToken[z]))
                                            html.append(" checked=\"checked\"");
                                    }
                                }

                                html.append(" />");
                                html.append("<span class=\"custom-control-label\">" + optionTxtArray.get(i).toString() + "</span> </label>");

                                html.append("</div>");
                            }

                            if(elementOptionOthers.length() > 0 && elementOptionOthers.equals("1")){

                                html.append("<div class=\"mt-2\"");

                                html.append("> <label class=\"js-focus-visible custom-control custom-" + elementType + "\"> <input " + elementDisabled + dataFilterAttrs + " type=\"" + elementType + "\" id=\"" + elementDbColumnName + "\" name=\"" + elementDbColumnName + "\" class=\"custom-control-input  " + triggerClasses + "\" value=\"others\"");

                                if(elementRequired.equals("1")) html.append(" required=\"required\"");

                                html.append(" />");
                                html.append("<span class=\"custom-control-label\">" + libelle_msg(etn, request, "Others") + "</span> </label>");

                                html.append("</div>");
                            }

                            html.append(errorMessageHtml);
                        }
						html.append("</div>");

                    }

                }catch(JSONException je){
                    je.printStackTrace();
                }catch(Exception e){
                    e.printStackTrace();
                }

            }

//            if(callingFrom.equals("backendcall")){

                html.append("</div>");
                html.append("</div>");
//            }

        }/* else if(elementType.equals("multitextfield")){

        html.append("<div class=\"col-sm-6\">");
        html.append("<div class=\"form-group\">");

        html.append("<label class=\"col-sm-4 control-label\">" + elementLabelName);
        if(elementRequired.equals("1")) html.append(" <span style=\"color: red;\">*</span>");
        html.append("</label>");

        html.append("<div style=\"margin-top: 10px;\" class=\"col-sm-6 __multitext_field_" + elementDbColumnName + "\">");

        String groupFieldsHtml = "";
        String addMoreFields = "<span onclick=\"add_mutlitextfied(this,'S')\" style=\"position: absolute; margin-left: 5px; margin-top: 3px; cursor: pointer;\" class=\"glyphicon glyphicon-plus multi-edit-btn\"></span>";

        for(int i=0; i<groupFields; i++){

        groupFieldsHtml += "<input style=\"width: 40%;display:inline-block;\" type=\"textfield\" value=\"" + elementValue + "\"";

        if(elementRequired.equals("1")) groupFieldsHtml += " required=\"required\"";

        groupFieldsHtml += "id=\"" + elementLabelName.replaceAll(" ","_").toLowerCase() + "\" class=\"form-control " + elementType + "\" /> ";

        }

        groupFieldsHtml += "<span onclick=\"add_mutlitextfied(this,'" + groupFields + "')\" style=\"margin-left: 5px; margin-top: 3px; cursor: pointer;\" class=\"glyphicon glyphicon-plus multi-edit-btn\"></span>";

        html.append(groupFieldsHtml);
        html.append("</div>");
        html.append("<input type=\"hidden\" name=\"group_fields\" value=\"" + groupFields + "\" />");
        html.append("<input type=\"hidden\" name=\"db_column_name\" value=\"" + elementDbColumnName + "\" />");
        html.append("<input type=\"hidden\" name=\"" + elementDbColumnName + "\" value=\"\" />");
        html.append("</div>");
        html.append("</div>");

        }*/

/*
        if(elementCustomCss.length() > 0 && defaultLangId.equals(langId)){

            html.append("<style type=\"text/css\">");
            html.append(elementCustomCss);
            html.append("</style>");
        }
*/

        return html.toString();
    }

    private String loadDynamicsFieldsBoosted5(Set selectedRuleRs, String labelElementId, String elementFieldType, String elementDbColumnName, String elementFileExtension, String elementLabel, String elementFontWeight, String elementFontSize, String elementColor, String elementPlaceholder, String elementName, String elementValue, String elementMaxLength, String elementRequired, String elementRuleField, String elementAddNoOfDays, String elementStartTime, String elementEndTime, String elementTimeSlice, String elementDefaultTimeValue, String elementByDefaultField, String elementAutocompleteCharAfter, String elementTriggerAutocompleteQuery, String elementRegularExpression, int elementGroupOfFields, String elementTrigger, String elementLabelName, String elementId, String elementType, String elementOptionsClass, String elementOptionOthers, String elementOptionQuery, String elementOptionQueryValue, String elementResizableColClass, String elementOptions, Map selectedValueMap, String section, String defaultValueFlag, String formId, String ruleId, String fieldId, String processName, String tableId, String elementImageWidth, String elementImageHeight, String elementImageAlt, String elementImageMobileUrl, String elementHyperlinkCheckbox, String elementErrorMsg, String elementHrefTarget, String elementImgHrefUrl, String elementButtonId, String elementContainerBackgroundColor, String elementTextAlign, String elementTextBorder, String elementSiteKey, String elementTheme, String elementRecaptchaDataSize, com.etn.beans.Contexte etn, javax.servlet.http.HttpServletRequest request, String callingFrom, String lineId, String labelDisplay, int elementMinRange, int elementMaxRange, int elementStepRange, String elementImgUrl, String elementDefaultCountryCode, String elementAllowCountryCode, String elementAllowNationalMode, String elementLocalCountryName, String elementHiddenField, String langId, String elementIsDeletable, String elementCustomClasses, String elementCustomCss, String elementDateFormat, String elementFileBrowserValue, String boostedVersion, String siteId, String elementAutoFormatTelNo) {
        
        String _clss = "";
        String dataFilterAttrs = "data-noe-html-form-id='demand_form' data-noe-fname='" + elementDbColumnName + "' data-noe-form-id='" + formId + "' data-noe-rule-id='" + ruleId + "' data-noe-field-id='" + fieldId + "'";
        String triggerClasses = "";
        String errorMessageHtml = "";
        String defaultLangId = getLangs(etn,siteId).get(0).getLanguageId();
        String isElementHeading = "tal";
        String isElement="lal";

        StringBuffer html = new StringBuffer();

        Date date = null;

        

        if(elementTrigger.length() > 2)
            triggerClasses = getCssClassesForTriggers(elementTrigger);
        
        
        if((elementType.equalsIgnoreCase("textdate") || elementType.equalsIgnoreCase("textdatetime")) && elementValue.equalsIgnoreCase("today") ) {
            date = new Date();
        }

        if(date != null){
          elementValue = buildDate(date, elementAddNoOfDays);
          if(elementDefaultTimeValue.length()>0) elementValue += " " + elementDefaultTimeValue;
        }

        String hiddenTypeCallingFrom = "texthidden";

        if(elementType.equalsIgnoreCase(hiddenTypeCallingFrom) && callingFrom.equalsIgnoreCase("frontendcall")) {
            elementType = "hidden";
            hiddenTypeCallingFrom = "hidden";
        }

        String styleCss = returnStyleCss(elementContainerBackgroundColor,elementHiddenField.equals("1"));

        String elementDisabled = "";
        if(lineId.length() == 0)
            elementDisabled = " disabled ";

        

        if(elementType.equals("textfield") || elementType.equals("multextfield") || elementType.equals("autocomplete") || elementType.equals("email") || elementType.equals("number") || elementType.equals("texttextarea") || elementType.equals(hiddenTypeCallingFrom) || elementType.equals("fileupload") || elementType.equals("textdate") || elementType.equals("textdatetime") || elementType.equals("password") || elementType.equals("range") || elementType.equals("tel")){

            errorMessageHtml = getErrorMessageHtml(elementErrorMsg,"You must fill the value", etn, request);
            
            if(!elementType.equals(hiddenTypeCallingFrom) || callingFrom.equals("backendcall")){
                
                html.append("<div " + styleCss + " class=\"col " + elementDbColumnName +" "+elementCustomClasses);
                if(lineId.length() > 0) html.append(" activeField ");
                html.append("\"> ");

                if(labelDisplay.equalsIgnoreCase(isElementHeading))
                    html.append("<div class=\"row\">");
                else if(labelDisplay.equalsIgnoreCase(isElement))
                    html.append("<div class=\"form-group row\">");

                if(callingFrom.equals("backendcall")){
                    html.append(formManupulationButton(formId,lineId,fieldId,elementType,langId,defaultLangId,elementIsDeletable,elementDbColumnName));
                }
                
                
                if(labelDisplay.equalsIgnoreCase(isElementHeading))
                    html.append(buildLabel("col-sm-9", elementFontWeight, elementFontSize, elementColor, elementLabel, elementRequired.equals("1")));
                else if(labelDisplay.equalsIgnoreCase(isElement)){
                    html.append(buildLabel("col-sm-3", elementFontWeight, elementFontSize, elementColor, elementLabel, elementRequired.equals("1")));
                }

                if(labelDisplay.equalsIgnoreCase(isElementHeading)) {
                    
                    if(elementType.equals("range") && callingFrom.equals("backendcall")){
                        html.append("<div class=\"col-sm-10 ");
                    } else if( elementType.equals("range") && callingFrom.equals("frontendcall"))
                        html.append("<div class=\"col-sm-11 ");
                    else
                        if(elementType.equals("textdate") || elementType.equals("textdatetime")) html.append("<div class=\"col-sm-12 position-relative ");
                        else html.append("<div class=\"col-sm-12 ");

                } else if(labelDisplay.equalsIgnoreCase(isElement)){
                    if(elementType.equals("range")){

                        if(callingFrom.equals("backendcall")){
                            html.append("<div class=\"col-sm-7");
                        }else if(callingFrom.equals("frontendcall"))
                            html.append("<div class=\"col-sm-8");
                    }
                    else
                        html.append("<div class=\"col-sm-9 ");
                }

                if(elementType.equals("range"))
                    html.append(" js-focus-visible mt-2");

                html.append("\">");
            }

            //if(!defaultValueFlag.equals("1")) elementValue = "";
            if(null != selectedValueMap && null != selectedValueMap.get(labelElementId)){
            
                elementValue = selectedValueMap.get(labelElementId).toString();
            }

            if(elementType.equals("texttextarea")){

                html.append(buildTextArea(elementDisabled,dataFilterAttrs,elementDbColumnName,triggerClasses,elementValue,section,elementRuleField,elementRequired.equals("1")));
                html.append(errorMessageHtml);

            }else{

                if(elementType.equals("textdatetime")){
                    html.append(buildHiddenField(elementDbColumnName+"_start_time",elementDbColumnName+"_start_time",elementStartTime));
                    html.append(buildHiddenField(elementDbColumnName + "_end_time", elementDbColumnName + "_end_time",elementEndTime));
                    html.append(buildHiddenField(elementDbColumnName + "_time_slice", elementDbColumnName + "_time_slice",elementTimeSlice));
                }

                if(elementType.equals("multextfield")){

                    /*if(elementValue.length() > 0){

                        String multfToken[] = elementValue.split(",");
                        String multfInnerToken[] = null;

                        for(int i=0; i < multfToken.length; i++){

                            multfInnerToken = multfToken[i].split(";");

                            html.append("<div>");
                            for(int j=0; j < multfInnerToken.length; j++){

                                html.append("<input readonly " + dataFilterAttrs + " style=\"height: 34px; padding: 6px 12px; font-size: 14px; line-height: 1.42; color: #555; background-color: #fff;\" type=\"" + elementType + "\" maxlength=\"" + elementMaxLength + "\" placeholder=\"" + elementPlaceholder + "\" value=\"" + multfInnerToken[j] + "\"");

                                if(elementRequired.equals("1")) html.append(" required=\"required\"");
                                if(section.equals("rule_section") && elementRuleField.equals("1")) html.append(" onchange=\"applyRuleFields(this);\" ");

                                html.append(" pattern=\"" + elementRegularExpression + "\" id=\"" + elementDbColumnName + "\" name=\"" + elementDbColumnName + "\" class=\" " + triggerClasses + " " + elementType + "\" />");
                            }

                            html.append("<span onclick=\"edit_multitextfield(this,'" + elementGroupOfFields + "')\" class=\"glyphicon glyphicon-pencil multi-edit-btn\" style=\"margin-top: 3px; cursor: pointer;\"></span>");

                            html.append("<span onclick=\"delete_multitextfield(this)\" class=\"glyphicon glyphicon-remove multi-edit-btn\" style=\"margin-top: 3px; cursor: pointer;\"></span>");

                            if(i != multfToken.length-1) html.append("<br/>");
                            html.append("</div>");
                       }
                    }

                    for(int k=0; k < elementGroupOfFields; k++){

                        html.append("<input " + dataFilterAttrs + " style=\"height: 34px; padding: 6px 12px; font-size: 14px; line-height: 1.42; color: #555; background-color: #fff;\" type=\"" + elementType + "\" maxlength=\"" + elementMaxLength + "\" placeholder=\"" + elementPlaceholder + "\" ");

                        if(elementRequired.equals("1")) html.append(" required=\"required\"");
                        if(section.equals("rule_section") && elementRuleField.equals("1")) html.append(" onchange=\"applyRuleFields(this);\" ");

                        html.append(" pattern=\"" + elementRegularExpression + "\" id=\"" + elementDbColumnName + "\" class=\" " + triggerClasses + " " + elementType + "\" />");
                    }

                    html.append("<span onclick=\"add_mutlitextfied(this,'" + elementGroupOfFields + "','" + elementDbColumnName + "')\" style=\"margin-left: 5px; margin-top: 3px; cursor: pointer;\" class=\"glyphicon glyphicon-plus multi-edit-btn\"></span>");

                    html.append(errorMessageHtml);*/

                } else {
                    String fileExtension ="";
                    triggerClasses += " form-control ";

                    if(elementType.equals("fileupload") && processName.equals("")) {
                        if(elementFileExtension.length() > 0 && elementFileExtension.contains(",")){
                            fileExtension = "."+elementFileExtension.replace(' ','.');
                            dataFilterAttrs += " accept=\'" + fileExtension + "\' onchange=\"setFileName('" + elementDbColumnName + "','" +fileExtension+ "')\"";
                            elementType = "file";
                        }   
                    }
                    
                    else if (elementType.equals("range"))
                    {
                        dataFilterAttrs+=" min=\'" + elementMinRange + "\' max=\'" + elementMaxRange + "\' step=\'" + elementStepRange + "\' onchange=\'customRange(this)\'" ;
                        triggerClasses = triggerClasses.replace("form-control","form-range");
                        if(elementType.equals("range") && elementValue.length() == 0 || elementValue.equals("0"))
                            elementValue = elementMinRange+"";
                    }

                    else if(elementType.equals("textfield")) dataFilterAttrs+=" pattern=\"" + elementRegularExpression + "\" ";
                    else if(elementType.equals("autocomplete")) 
                    {
                        dataFilterAttrs+=" data-noe-auto-char='" + elementAutocompleteCharAfter + "' ";
                        triggerClasses += " noe_auto_complete ";
                    }
                    else if(elementType.equals("textdate") || elementType.equals("textdatetime")) dataFilterAttrs+=" readonly date-format=\"" + elementDateFormat + "\" ";
                    else if(elementType.equals("tel")){
                        if(elementDefaultCountryCode.length() == 0)
                            elementDefaultCountryCode = "auto";

                        if(elementAllowNationalMode.equals("1"))
                            elementAllowNationalMode = "true";
                        else if(elementAllowNationalMode.equals("0"))
                            elementAllowNationalMode = "false";

                        if(!elementAllowCountryCode.contains(elementDefaultCountryCode) && elementAllowCountryCode.length() > 0)
                            elementAllowCountryCode += "," + elementDefaultCountryCode;

                        dataFilterAttrs+=" default-country-code=\"" + elementDefaultCountryCode + "\" allow-country-code=\"" + elementAllowCountryCode + "\" allow-national-mode=\"" + elementAllowNationalMode + "\" local-country-name=\"" + elementLocalCountryName + "\" ";
                    }
    
                    html.append(buildInputField(elementType,dataFilterAttrs,"min-width: 100%;",elementDbColumnName,elementMaxLength,elementPlaceholder,elementValue,triggerClasses, elementRequired.equals("1"), elementDisabled.equals(" disabled ")));

                    if(elementType.equals("textdate") || elementType.equals("textdatetime")){
                        html.append("<a style=\"position: absolute; right: 20px; top: 10px; cursor: pointer;\"><img src=\""+request.getContextPath()+"/img/cal.png\" alt /></a>");
                    }

                    html.append(errorMessageHtml);

                    if(elementType.equals("file"))  html.append("<label>"+elementFileExtension+"</label>");
                }
            }
            if(callingFrom.equals("backendcall")){
                html.append("</div>");
                
                if(elementType.equals("range")){
                    html.append("<label id=\"customRange" + elementDbColumnName + "\" class=\"col-");
                    if(callingFrom.equals("backendcall"))
                        html.append("2");
                    else
                        html.append("1");
                    html.append(" col-form-label text-right\">" + elementValue + "</label>");
                }
                html.append("</div>");
            }
            
            if(!elementType.equals(hiddenTypeCallingFrom) || callingFrom.equals("backendcall"))
                html.append("</div>");

            if(!elementType.equals(hiddenTypeCallingFrom) && !callingFrom.equals("backendcall")){
                 
                if(elementType.equals("range")){
                    html.append("<label id=\"customRange" + elementDbColumnName + "\" class=\"col-1");
                    html.append(" col-form-label text-right\">" + elementValue + "</label>");
                }

                html.append("</div>");
                html.append("</div>");
            }

        } else if(elementType.equals("imgupload")){

            String imagePath = GlobalParm.getParm("FORM_UPLOADS_PATH") + "images/";

            if(callingFrom.equals("backendcall")){

                html.append("<div " + styleCss + " class=\"col " + elementDbColumnName+" "+elementCustomClasses);
                if(lineId.length() > 0) html.append(" activeField ");

                if(callingFrom.equals("backendcall"))
                    html.append("\" > <div class=\"row form-group\">");
                else{

                    html.append("\"> ");

                    if(labelDisplay.equalsIgnoreCase(isElementHeading))
                        html.append("<div class=\"row\">");
                    else if(labelDisplay.equalsIgnoreCase(isElement))
                        html.append("<div class=\"form-group row\">");
                }

                if(callingFrom.equals("backendcall")){

                    html.append("<div class=\"field-edit\">");
                    html.append("<button line-form-id=\"" + formId + "\" line-id=\"" + lineId + "\" line-field-id=\"" + fieldId + "\" field-type=\"" + elementType + "\" field-label=\"" + elementType + "\" lang-id=\"" + langId + "\" class=\"btn btn-sm btn-primary mr-1 mb-0 btn-modal add_field_to_form\" data-toggle=\"modal\" data-target=\"#add_field_to_form\"> edit field </button>");

                    if(defaultLangId.equals(langId) && elementIsDeletable.equals("1")){
                        html.append("<button line-form-id=\"" + formId + "\" line-id=\"" + lineId + "\" line-field-id=\"" + fieldId + "\" line-col-name=\"" + elementDbColumnName + "\" lang-id=\"" + langId + "\" class=\"btn btn-sm btn-danger mr-1 mb-0\" onclick='deleteElement(this)'> delete </span></button>");
                    }

                    html.append("</div>");
                    html.append("<div class=\"field-edit-bgnd\">&nbsp;</div>");
                }

                html.append("<label class=\"");

                if(labelDisplay.equalsIgnoreCase(isElementHeading))
                    html.append("col-sm-9 ");
                else if(labelDisplay.equalsIgnoreCase(isElement))
                    html.append("col-sm-3 ");

                html.append("control-label col-form-label\" style=\"font-weight:" + elementFontWeight + "; font-size: " + elementFontSize + "; color: " + elementColor + "\">" + elementLabel);

                if(elementRequired.equals("1")) html.append(" <span style=\"color: red;\">*</span>");

                html.append("</label>");

                if(labelDisplay.equalsIgnoreCase(isElementHeading))
                    html.append("<div class=\"col-sm-12\">");
                else if(labelDisplay.equalsIgnoreCase(isElement))
                    html.append("<div class=\"col-sm-9\">");
            }

            html.append("<div style=\"background-color: " + elementColor + "\" class=\"display-desktop col activeField mt-2\">");
            html.append("<a target='" + elementHrefTarget + "' href='");

            if(elementImgHrefUrl.length() > 0) {
                if(elementImgHrefUrl.contains("http") || elementImgHrefUrl.contains("https"))
                    html.append(elementImgHrefUrl);
                else
                    html.append("https://"+elementImgHrefUrl);
            }
            else html.append("#");

            html.append("'> <img  title='" + elementImageAlt + "' src='" + imagePath + elementImgUrl + "' style='width: " + elementImageWidth + " height: " + elementImageHeight + "' > </a>");
            html.append("</div>");

            if(elementImageMobileUrl.length() > 0){
                html.append("<div style=\"background-color: " + elementColor + "\" class=\"display-mobile col-sm-" + elementResizableColClass + "\">");
                html.append("<center> <img title='" + elementImageAlt + "' src='" + imagePath + elementImageMobileUrl + "' style='width: " + elementImageWidth + " height: " + elementImageHeight + "' > </center>");
                html.append("</div>");
            }

            if(callingFrom.equals("backendcall")){
                html.append("</div>");
                html.append("</div>");
                html.append("</div>");
            }

        } else if(elementType.equals("hyperlink")){
            errorMessageHtml = getErrorMessageHtml(elementErrorMsg,"You must select the checkbox" ,etn, request);
            
            html.append("<div " + styleCss + " class=\"col " + elementDbColumnName+" "+elementCustomClasses);
            
            if(lineId.length() > 0) html.append(" activeField ");

            html.append("\"><div class=\"row\">");
            
            if(callingFrom.equals("backendcall")){
                html.append(formManupulationButton(formId,lineId,fieldId,elementType,langId,defaultLangId,elementIsDeletable,elementDbColumnName));
            }
            
            if(labelDisplay.equalsIgnoreCase("tal"))
                html.append(buildLabel("col-sm-9", elementFontWeight, elementFontSize, elementColor, elementLabel, elementRequired.equals("1")));
            else if(labelDisplay.equalsIgnoreCase("lal"))
                html.append(buildLabel("col-sm-3", elementFontWeight, elementFontSize, elementColor, elementLabel, elementRequired.equals("1")));

            if(labelDisplay.equalsIgnoreCase("tal"))
                html.append("<div class=\"col-sm-12\">");
            else if(labelDisplay.equalsIgnoreCase("lal"))
                html.append("<div class=\"col-sm-9\">");
                
            triggerClasses+=" form-check-input ";
            
            if(elementHyperlinkCheckbox.equals("1")){
                html.append("<div class=\"mt-2 form-check\">");
                html.append(buildInputField("checkbox",dataFilterAttrs,"",elementDbColumnName,elementMaxLength,elementPlaceholder,elementValue,triggerClasses, elementRequired.equals("1"), elementDisabled.equals(" disabled ")));
                html.append("<label class=\"js-focus-visible form-check-label\" for=\""+elementDbColumnName+"\" >"+elementValue+"</label>");
            }
            
            
            
            html.append("<a class=\"");
            if(elementHyperlinkCheckbox.equals("1"))
                html.append("ms-2");
            html.append("\" target=\"" + elementHrefTarget + "\" " + dataFilterAttrs + " href=\"");

            if(elementImgHrefUrl.length() > 1) {
                if(elementImgHrefUrl.contains("http") || elementImgHrefUrl.contains("https"))
                    html.append(elementImgHrefUrl);
                else
                    html.append("https://"+elementImgHrefUrl);
            }
            else html.append("#");

            html.append("\" style=\"font-weight: " + elementFontWeight + "; font-size: " + elementFontSize + "; color: " + elementColor + ";\">");
            if(elementHyperlinkCheckbox.equals("1"))
                html.append("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\" class=\"feather feather-info\"><circle cx=\"12\" cy=\"12\" r=\"10\"></circle><line x1=\"12\" y1=\"16\" x2=\"12\" y2=\"12\"></line><line x1=\"12\" y1=\"8\" x2=\"12.01\" y2=\"8\"></line></svg>");
            else
                html.append(elementValue);
            html.append("</a>");
            
            if(elementHyperlinkCheckbox.equals("1"))
                html.append("</div>");

            html.append(errorMessageHtml);
            html.append("</div></div></div>");

        } else if(elementType.equals("button")){
            html.append("<div " + styleCss + " class=\"col " + elementDbColumnName + " "+elementCustomClasses);
            if(lineId.length() > 0) html.append(" activeField ");
            
            html.append("\"> <div class=\"row form-group\">");

            html.append("<label class=\"col-sm-3 col-form-label\">&nbsp;</label>");

            if(callingFrom.equals("backendcall")){
                html.append(formManupulationButton(formId,lineId,fieldId,elementType,langId,defaultLangId,elementIsDeletable,elementDbColumnName));
            }

            if(labelDisplay.equalsIgnoreCase(isElementHeading))
                if(elementType.equals("textdate") || elementType.equals("textdatetime")) html.append("<div class=\"col-sm-12 position-relative\">");
                else html.append("<div class=\"col-sm-12\">");
            else if(labelDisplay.equalsIgnoreCase(isElement))
                if(elementType.equals("textdate") || elementType.equals("textdatetime")) html.append("<div class=\"col-sm-9 position-relative\">");
                else html.append("<div class=\"col-sm-9\">");

            html.append(buildInputField(elementType,dataFilterAttrs,"min-width: 100%;",elementDbColumnName,elementMaxLength,elementPlaceholder,elementValue," btn btn-secondary "+triggerClasses, elementRequired.equals("1"), elementDisabled.equals(" disabled ")));
            html.append("</div></div></div>");

        } else if(elementType.equalsIgnoreCase("label")){

            if(elementTextAlign.length() == 0) elementTextAlign = "left";

            html.append("<div " + styleCss + " class=\"col " + elementDbColumnName +" "+elementCustomClasses);
            if(lineId.length() > 0) html.append(" activeField ");
            html.append("\"> <div class=\"row\">");
            html.append("<label class=\"col-sm-9\"></label>");

            if(callingFrom.equals("backendcall")){
                html.append(formManupulationButton(formId,lineId,fieldId,elementType,langId,defaultLangId,elementIsDeletable,elementDbColumnName));
            }

            html.append("<div class=\"col-sm-12\">");
            html.append("<legend class=\"my-2\" style=\"font-weight: " + elementFontWeight + "; font-size: " + elementFontSize + "; color: " + elementColor + ";\">" + elementLabelName + "</legend>");
            html.append("</div></div></div>");

        }  else if(elementType.equals("hr_line")){
            html.append(buildHorizontalRuler(elementResizableColClass));

        } else if(elementType.equals("textrecaptcha")){
            
            errorMessageHtml = getErrorMessageHtml(elementErrorMsg, "reCAPTCHA is mandatory", etn, request);
            html.append("<div " + styleCss + " class=\"col " + elementDbColumnName +" "+elementCustomClasses);
            if(lineId.length() > 0) html.append(" activeField ");
            html.append("\"> <div class=\"row form-group\">");
            
            if(callingFrom.equals("backendcall")){
                html.append(formManupulationButton(formId,lineId,fieldId,elementType,langId,defaultLangId,elementIsDeletable,elementDbColumnName));
            }            

            if(labelDisplay.equalsIgnoreCase(isElementHeading))
                html.append("<div class=\"col-sm-12\">");
            else if(labelDisplay.equalsIgnoreCase(isElement))
                html.append("<div class=\"col-sm-9\">");

            html.append("<div class=\"g-recaptcha\" data-size=\"" + elementRecaptchaDataSize + "\" data-theme=\"" + elementTheme + "\" data-sitekey=\"" + elementSiteKey + "\"></div>");
            html.append(errorMessageHtml);
            html.append("</div></div></div>");

        } else if(elementType.equals("dropdown") || elementType.equals("radio") || elementType.equals("checkbox")){

            html.append("<div " + styleCss + " class=\"col " + elementDbColumnName +" "+elementCustomClasses);
            if(lineId.length() > 0) html.append(" activeField ");
            html.append("\"> ");

            if(labelDisplay.equalsIgnoreCase(isElementHeading))
                html.append("<div class=\"row\">");
            else if(labelDisplay.equalsIgnoreCase(isElement))
                html.append("<div class=\"form-group row\">");

            if(labelDisplay.equalsIgnoreCase(isElementHeading))
                html.append(buildLabel("col-sm-9", elementFontWeight, elementFontSize, elementColor, elementLabel, elementRequired.equals("1")));
            else if(labelDisplay.equalsIgnoreCase(isElement))
                html.append(buildLabel("col-sm-3", elementFontWeight, elementFontSize, elementColor, elementLabel, elementRequired.equals("1")));


            if(callingFrom.equals("backendcall")){
                html.append(formManupulationButton(formId,lineId,fieldId,elementType,langId,defaultLangId,elementIsDeletable,elementDbColumnName));
            }

            errorMessageHtml = getErrorMessageHtml(elementErrorMsg, "Select an Option", etn, request);

            if(!elementOptions.equals("null") && elementOptions.length() > 0){

                try{

                    JSONObject optionsJson = new JSONObject(elementOptions);
                    if(optionsJson.length() > 0){

                        JSONArray optionTxtArray = optionsJson.getJSONArray("txt");
                        JSONArray optionValArray = optionsJson.getJSONArray("val");

                        String[] multipleValueToken = null;
                        String[] elementValueToken = elementValue.split(";");

                        if(labelDisplay.equalsIgnoreCase(isElementHeading))
                            html.append("<div class=\"col-sm-12 ");
                        else if(labelDisplay.equalsIgnoreCase(isElement))
                            html.append("<div class=\"col-sm-9 ");

                        if(elementRequired.equals("1"))
                            html.append("req_fields");

                        if(elementOptionsClass.length() > 0)
                            html.append(" " + elementOptionsClass);

                        html.append("\"");

                        if(elementOptionsClass.length() > 0 && labelDisplay.equalsIgnoreCase(isElement))
                            html.append(" style=\"margin: 0;\"");

                        html.append(">");

                        if(elementType.equals("dropdown")){

                            boolean unCreatedOptionFormFLag = true;
                            html.append(buildDropDown(optionValArray,optionTxtArray,dataFilterAttrs,elementDbColumnName,triggerClasses,elementRequired.equals("1"), section.equals("rule_section") && elementRuleField.equals("1"), elementDisabled.equals(" disabled ")));
                            
                            html.append(errorMessageHtml);
                        } else {
                            errorMessageHtml = getErrorMessageHtml(elementErrorMsg, "Select an option", etn, request);
                            
                            if(elementType.equals("radio"))
                                html.append(buildRadioButton(optionTxtArray,optionValArray,elementDbColumnName,elementOptionsClass.contains("form-check-inline"), section.equals("rule_section") && elementRuleField.equals("1")));
                            else
                                html.append(buildCheckBox(optionTxtArray,optionValArray,elementDbColumnName,elementOptionsClass.contains("form-check-inline") ,section.equals("rule_section") && elementRuleField.equals("1")));
                            html.append(errorMessageHtml);
                        }
						html.append("</div>");
                    }
                }catch(JSONException je){
                    je.printStackTrace();
                }catch(Exception e){
                    e.printStackTrace();
                }
            }
            html.append("</div>");
            html.append("</div>");
        }
        return html.toString();
    }


    String loadDynamicsSection(com.etn.beans.Contexte etn, javax.servlet.http.HttpServletRequest request, Set rs, Set selectedRuleRs, Map selectedValueMap, Map possibleElementValues, String section, String defaultValueFlag, String formId, String ruleId, String callingFrom, String lineId, String langId)
    {

        String html = "";
        int groupFields = 0;
        int counter = 0;
        int innerCount = 1;
        String fieldId = "";
        String labelElementId = "";
        String elementFieldType = "";
        String elementDbColumnName = "";
        String elementFileExtension = "";
        String elementLabel = "";
        String elementFontWeight = "";
        String elementFontSize = "";
        String elementColor = "";
        String elementPlaceholder = "";
        String elementName = "";
        String elementValue = "";
        String elementMaxLength = "";
        String elementRequired = "";
        String elementRuleField = "";
        String elementAddNoOfDays = "";
        String elementStartTime = "";
        String elementEndTime = "";
        String elementTimeSlice = "";
        String elementDefaultTimeValue = "";
        String elementByDefaultField = "";
        String elementHyperlinkCheckbox = "";
        String elementAutocompleteCharAfter = "";
        String elementTriggerAutocompleteQuery = "";
        String elementRegularExpression = "";
        int elementGroupOfFields = 1;
        String elementTrigger = "";
        String elementLabelName = "";
        String elementId = "";
        String elementType = "";
        String elementOptionsClass = "";
        String elementOptionOthers = "";
        String elementOptionQuery = "";
        String elementOptionQueryValue = "";
        String elementResizableColClass = "12";
        String elementOptions = "";
        String optionJson = "";
        String elementImageWidth = "";
        String elementImageHeight = "";
        String elementImageAlt = "";
        String elementImageMobileUrl = "";
        String elementErrorMsg = "";
        String elementHrefTarget = "";
        String elementImgHrefUrl = "";
        String elementButtonId = "";
        String elementContainerBackgroundColor = "";
        String elementTextAlign = "";
        String elementTextBorder = "";
        String elementSiteKey = "";
        String elementTheme = "";
        String elementRecaptchaDataSize = "";
        String defaultValue = "";
        String queryValues = "";
        String processName = "";
        String tableId = "";
        String labelDisplay = "";
        int elementMinRange = 0;
        int elementMaxRange = 0;
        int elementStepRange = 0;
        String elementImgUrl = "";
        String elementDefaultCountryCode = "";
        String elementAllowCountryCode = "";
        String elementAllowNationalMode = "";
        String elementLocalCountryName = "";
        String elementAutoFormatTelNo = "";
        String elementHiddenField = "";
        String elementIsDeletable = "";
        String elementCustomClasses = "";
        String elementCustomCss = "";
        String elementDateFormat = "";
        String elementFileBrowserValue = "";

        Set processRs = etn.execute("SELECT * FROM process_forms_unpublished WHERE form_id = " + escape.cote(formId));

        if(processRs.next()){

            labelDisplay = parseNull(processRs.value("label_display"));
        }

        while(rs.next()){

            processName = libelle_msg(etn, request, parseNull(rs.value("process_name")));
            tableId = parseNull(rs.value(0));
            fieldId = parseNull(rs.value("_etn_field_id"));
            labelElementId = parseNull(rs.value("_etn_label_id"));
            elementFieldType = parseNull(rs.value("_etn_field_type"));
            elementDbColumnName = parseNull(rs.value("_etn_db_column_name"));
            elementFileExtension = parseNull(rs.value("_etn_file_extension"));
            elementLabel = parseNull(rs.value("_etn_label"));
            elementFontWeight = parseNull(rs.value("_etn_font_weight"));
            elementFontSize = parseNull(rs.value("_etn_font_size"));
            elementColor = parseNull(rs.value("_etn_color"));
            elementPlaceholder = parseNull(rs.value("_etn_placeholder"));
            elementName = parseNull(rs.value("_etn_field_name"));
            elementType = parseNull(rs.value("_etn_type"));
            defaultValue = parseNull(rs.value("default_value"));

            if("" != elementDbColumnName && null != rs.value(elementDbColumnName.replaceAll(" ", "_").toLowerCase()))
                elementValue = parseNull(rs.value(elementDbColumnName.replaceAll(" ", "_").toLowerCase()));
            else
                elementValue = parseNull(rs.value("_etn_value"));

            if(elementType.equals("texthidden") && defaultValue.length() > 0)
                elementValue = defaultValue;

            if(null != request.getParameterMap().get(elementDbColumnName)){

                elementValue = request.getParameterMap().get(elementDbColumnName)[0];
            }

            elementMaxLength = parseNull(rs.value("_etn_maxlength"));
            elementRequired = parseNull(rs.value("_etn_required"));
            elementRuleField = parseNull(rs.value("_etn_rule_field"));
            elementAddNoOfDays = parseNull(rs.value("_etn_add_no_of_days"));
            elementStartTime = parseNull(rs.value("_etn_start_time"));
            elementEndTime = parseNull(rs.value("_etn_end_time"));
            elementTimeSlice = parseNull(rs.value("_etn_time_slice"));
            elementDefaultTimeValue = parseNull(rs.value("_etn_default_time_value"));
            elementByDefaultField = parseNull(rs.value("by_default_field"));
            elementHyperlinkCheckbox = parseNull(rs.value("_etn_href_chckbx"));
            elementAutocompleteCharAfter = parseNull(rs.value("_etn_autocomplete_char_after"));
            elementTriggerAutocompleteQuery = parseNull(rs.value("_etn_element_autocomplete_query"));
            elementRegularExpression = parseNull(rs.value("_etn_regx_exp"));
            elementGroupOfFields = parseNullInt(rs.value("_etn_group_of_fields"));
            elementTrigger = parseNull(rs.value("_etn_element_trigger"));
            elementLabelName = parseNull(rs.value("_etn_label_name"));
            elementId = parseNull(rs.value("_etn_id"));
            elementOptionsClass = parseNull(rs.value("_etn_element_option_class"));
            elementOptionOthers = parseNull(rs.value("_etn_element_option_others"));
            elementOptionQuery = parseNull(rs.value("_etn_element_option_query"));
            elementOptionQueryValue = parseNull(rs.value("_etn_element_option_query_value"));

            elementResizableColClass = parseNull(rs.value("_etn_resizable_col_class"));
            if(elementResizableColClass.length() == 0)
                elementResizableColClass = "12";

            elementOptions = parseNull(rs.value("_etn_options"));
            elementImageWidth = parseNull(rs.value("_etn_img_width")) + ";";
            elementImageHeight = parseNull(rs.value("_etn_img_height")) + ";";
            elementImageAlt = parseNull(rs.value("_etn_img_alt"));
            elementImageMobileUrl = parseNull(rs.value("_etn_img_murl"));
            elementErrorMsg = parseNull(rs.value("_etn_err_msg"));
            elementHrefTarget = parseNull(rs.value("_etn_href_target"));
            elementImgHrefUrl = parseNull(rs.value("_etn_img_href_url"));
            elementButtonId = parseNull(rs.value("_etn_btn_id"));
            elementContainerBackgroundColor = parseNull(rs.value("_etn_container_bkcolor"));
            elementTextAlign = parseNull(rs.value("_etn_text_align"));
            elementTextBorder = parseNull(rs.value("_etn_text_border"));
            elementSiteKey = parseNull(rs.value("_etn_site_key"));
            elementTheme = parseNull(rs.value("_etn_theme"));
            elementRecaptchaDataSize = parseNull(rs.value("_etn_recaptcha_data_size"));
            elementMinRange = parseNullInt(rs.value("_etn_min_range"));
            elementMaxRange = parseNullInt(rs.value("_etn_max_range"));
            elementStepRange = parseNullInt(rs.value("_etn_step_range"));
            elementImgUrl = parseNull(rs.value("_etn_img_url"));
            elementDefaultCountryCode = parseNull(rs.value("_etn_default_country_code"));
            elementAllowCountryCode = parseNull(rs.value("_etn_allow_country_code"));
            elementAllowNationalMode = parseNull(rs.value("_etn_allow_national_mode"));
            elementLocalCountryName = parseNull(rs.value("_etn_local_country_name"));
            elementAutoFormatTelNo = parseNull(rs.value("_etn_auto_format_tel_number"));
            elementHiddenField = parseNull(rs.value("_etn_hidden_field"));
            elementIsDeletable = parseNull(rs.value("_etn_is_deletable"));
            elementCustomClasses = parseNull(rs.value("_etn_custom_classes"));
            elementCustomCss = parseNull(rs.value("_etn_custom_css"));
            elementDateFormat = parseNull(rs.value("_etn_date_format"));
            elementFileBrowserValue = parseNull(rs.value("_etn_file_browser_val"));

            if(null != elementOptionQueryValue && elementOptionQueryValue.length() > 0){
                if(null != etn){
                    if(elementOptionQueryValue.toLowerCase().startsWith("select ")){

                        Set queryRs = etn.execute(elementOptionQueryValue);

                        queryValues = "";
                        while(null != queryRs && queryRs.next()){
                            queryValues += "\"" + queryRs.value(0) + "\",";
                        }

                        if(queryValues.length() > 0){

                            queryValues = queryValues.substring(0, queryValues.length()-1);
                            elementOptions = "{\"val\":[" + queryValues + "], \"txt\":[" + queryValues + "]}";
                        }
                    } else {

                        String[] pairToken = elementOptionQueryValue.split(",");
                        String[] pairArr = null;
                        String pairValue = "";
                        String pairText = "";

                        for(String pair : pairToken){

                            pairArr = pair.split(";");
                            pairValue += "\"" + pairArr[0].trim() + "\",";
                            pairText += "\"" + pairArr[1].trim() + "\",";

                        }

                        if(pairValue.length() > 0 && pairText.length() > 0){

                            pairValue = pairValue.substring(0, pairValue.length()-1);
                            pairText = pairText.substring(0, pairText.length()-1);
                            elementOptions = "{\"val\":[" + pairValue + "], \"txt\":[" + pairText + "]}";
                        }
                    }
                }
            }

            if( null != possibleElementValues){

                String values = "";
                List<String> listOptions = null;
                for ( Object key : possibleElementValues.keySet() ) {

                    if(elementDbColumnName.equalsIgnoreCase(key.toString()) ){

                        listOptions = (ArrayList) possibleElementValues.get(key.toString());

                        for(String val: listOptions){
                            values += "\"" + val + "\",";
                        }

                        values = values.substring(0, values.length()-1);
                        elementOptions = "{\"val\":[" + values + "], \"txt\":[" + values + "]}";
                    }
                }
            }

            if(counter%2==0){
            innerCount = 1;
            
            }
            else innerCount ++;

            if(lineId.length() == 0) lineId = parseNull(rs.value("_etn_line_id"));
            String boostedVersion = getBoostedVersion(etn,formId);
            System.out.println("----------------------------------------------------");
			System.out.println("----------------------------------------------------");
            System.out.println("boosted version: " + boostedVersion);
			System.out.println("----------------------------------------------------");
			System.out.println("----------------------------------------------------");
			
            if(boostedVersion.equalsIgnoreCase("5.x"))
                html += loadDynamicsFieldsBoosted5(selectedRuleRs, labelElementId, elementFieldType, elementDbColumnName, elementFileExtension, elementLabel, elementFontWeight, elementFontSize, elementColor, elementPlaceholder, elementName, elementValue, elementMaxLength, elementRequired, elementRuleField, elementAddNoOfDays, elementStartTime, elementEndTime, elementTimeSlice, elementDefaultTimeValue, elementByDefaultField, elementAutocompleteCharAfter, elementTriggerAutocompleteQuery, elementRegularExpression, elementGroupOfFields, elementTrigger, elementLabelName, elementId, elementType, elementOptionsClass, elementOptionOthers, elementOptionQuery, elementOptionQueryValue, elementResizableColClass, elementOptions, selectedValueMap, section, defaultValueFlag, formId, ruleId, fieldId, processName, tableId, elementImageWidth, elementImageHeight, elementImageAlt, elementImageMobileUrl, elementHyperlinkCheckbox, elementErrorMsg, elementHrefTarget, elementImgHrefUrl, elementButtonId, elementContainerBackgroundColor, elementTextAlign, elementTextBorder, elementSiteKey, elementTheme, elementRecaptchaDataSize, etn, request, callingFrom, lineId, labelDisplay, elementMinRange, elementMaxRange, elementStepRange, elementImgUrl, elementDefaultCountryCode, elementAllowCountryCode, elementAllowNationalMode, elementLocalCountryName, elementHiddenField, langId, elementIsDeletable, elementCustomClasses, elementCustomCss, elementDateFormat, elementFileBrowserValue, boostedVersion,parseNull(processRs.value("site_id")), elementAutoFormatTelNo);
            else
                html += loadDynamicsFieldsBoosted4(selectedRuleRs,  labelElementId,  elementFieldType,  elementDbColumnName,  elementFileExtension,  elementLabel,  elementFontWeight,  elementFontSize,  elementColor,  elementPlaceholder,  elementName,  elementValue,  elementMaxLength,  elementRequired,  elementRuleField,  elementAddNoOfDays,  elementStartTime,  elementEndTime,  elementTimeSlice,  elementDefaultTimeValue,  elementByDefaultField,  elementAutocompleteCharAfter,  elementTriggerAutocompleteQuery,  elementRegularExpression,  elementGroupOfFields,  elementTrigger,  elementLabelName,  elementId,  elementType,  elementOptionsClass,  elementOptionOthers,  elementOptionQuery,  elementOptionQueryValue,  elementResizableColClass,  elementOptions,  selectedValueMap,  section,  defaultValueFlag,  formId,  ruleId,  fieldId,  processName,  tableId,  elementImageWidth,  elementImageHeight,  elementImageAlt,  elementImageMobileUrl,  elementHyperlinkCheckbox, elementErrorMsg, elementHrefTarget, elementImgHrefUrl, elementButtonId,  elementContainerBackgroundColor, elementTextAlign,  elementTextBorder, elementSiteKey, elementTheme, elementRecaptchaDataSize, etn, request, callingFrom, lineId, labelDisplay, elementMinRange,  elementMaxRange, elementStepRange, elementImgUrl, elementDefaultCountryCode, elementAllowCountryCode,  elementAllowNationalMode, elementLocalCountryName, elementHiddenField, langId, elementIsDeletable, elementCustomClasses, elementCustomCss, elementDateFormat, elementFileBrowserValue,parseNull(processRs.value("site_id")), elementAutoFormatTelNo);
            counter++;
        }

        return html;
    }


    java.util.Map<String, String> getElementTriggerJs(String json)
    {

        java.util.Map<String, String> js = new java.util.LinkedHashMap<String, String>();
        try{

            JSONObject elementTriggerObject = new JSONObject(json);

            if(elementTriggerObject.length() > 2){

                JSONArray elementTriggerEventArray = elementTriggerObject.getJSONArray("event");
                JSONArray elementTriggerJsArray = elementTriggerObject.getJSONArray("js");
                String _event = "";
                String _js = "";

                for(int i=0; i < elementTriggerJsArray.length(); i++){

                    _event = elementTriggerEventArray.get(i).toString();
                    _js = elementTriggerJsArray.get(i).toString();

                    if(_event.length() > 0 && _js.length() > 0)
                        js.put(_event, _js);
                }
            }
        }catch(JSONException je){
            je.printStackTrace();
        }catch(Exception e){
            e.printStackTrace();
        }

        return js;
    }

    java.util.Map<String, java.util.List<String>> getElementTriggerQueries(String json)
    {
        java.util.Map<String, List<String>> js = new java.util.LinkedHashMap<String, List<String>>();

        try{

            JSONObject elementTriggerObject = new JSONObject(json);
            JSONArray elementTriggerEventArray = elementTriggerObject.getJSONArray("event");
            JSONArray elementTriggerQueryArray = elementTriggerObject.getJSONArray("query");
            String _event = "";
            List<String> _qry = new ArrayList<String>();
            String queryToken[] = null;

            for(int i=0; i < elementTriggerQueryArray.length(); i++){

                _event = elementTriggerEventArray.get(i).toString();
//                _qry = null;

                if(elementTriggerQueryArray.length() > 0) {

                    queryToken = elementTriggerQueryArray.get(i).toString().split("!@##@!");

                    for(int j=0; j < queryToken.length; j++){

                        _qry.add(queryToken[j]);
                    }
                }
//                if(elementTriggerQueryArray.length() > 0) _qry = (List<String>)elementTriggerQueryArray.get(i).toString();

                if(_event.length() > 0 && _qry != null && !_qry.isEmpty() && _qry.size() > 0)
                {
                    js.put(_event, _qry);
                }
            }

        }catch(JSONException je){
            je.printStackTrace();
        }catch(Exception e){
            e.printStackTrace();
        }

        return js;
    }

    String getCssClassesForTriggers(String json)
    {
        String cssCls = "";

        if(json.length() > 0){

            try{

                JSONObject elementTriggerObject = new JSONObject(json);
				if(elementTriggerObject == null || elementTriggerObject.has("event") == false) return "";
                JSONArray elementTriggerEventArray = elementTriggerObject.getJSONArray("event");

                if(null != elementTriggerEventArray){

                    for(int i=0; i < elementTriggerEventArray.length(); i++){
                        if(!elementTriggerEventArray.get(i).toString().equalsIgnoreCase(""))
                            cssCls += " noe_" + elementTriggerEventArray.get(i).toString() + " ";
                    }
                }

            }catch(JSONException je){
                je.printStackTrace();
            }catch(Exception e){
                e.printStackTrace();
            }
        }

        return cssCls;
    }

    String getJsTriggersCode(com.etn.beans.Contexte Etn, String formid, String ruleid)
    {
        return getJsTriggersCode(Etn, formid, ruleid, "demand_form");
    }

    String getJsTriggersCode(com.etn.beans.Contexte Etn, String formid, String ruleid, String htmlformid)
    {
        String _code = "";
        ruleid = parseNull(ruleid);
        formid = parseNull(formid);
        Map<String, String> fields = new LinkedHashMap<String, String>();
        String type = "";
        String value = "";

        Set rs = Etn.execute("select btn_id, db_column_name, element_trigger, type, field_id, name from process_form_fields_unpublished where coalesce(element_trigger,'') <> '' and (rule_field = 1 or always_visible = 1 or field_type = 'hs' or field_type = 'fts') and form_id = " + escape.cote(formid));

        while(rs.next())
        {
            type = parseNull(rs.value("type"));
            value = parseNull(rs.value("element_trigger"));

            if(type.equalsIgnoreCase("button"))
                fields.put(rs.value("btn_id"), value);
            else if(type.equalsIgnoreCase("imgupload") || type.equalsIgnoreCase("hyperlink"))
                fields.put(rs.value("field_id"), value);
            else
                fields.put(rs.value("db_column_name"), value);

        }

        //if any field is found in mapping then overwrite its element_trigger in the map as it has more preference
        if(ruleid.length() > 0) rs = Etn.execute("select pf.btn_id, pf.db_column_name, pf.type, pf.field_id, pf.name, p.element_trigger from process_rule_fields p, process_forms_unpublished f, process_form_fields_unpublished pf where coalesce(p.element_trigger,'') <> '' and f.form_id = "+ escape.cote(formid) + " and f.form_id = pf.form_id and pf.field_id = p.field_id and p.rule_id = " + escape.cote(ruleid));

        while(rs.next())
        {
            type = parseNull(rs.value("type"));
            value = parseNull(rs.value("element_trigger"));

            if(type.equalsIgnoreCase("button"))
                fields.put(rs.value("btn_id"), value);
            else if(type.equalsIgnoreCase("imgupload") || type.equalsIgnoreCase("hyperlink"))
                fields.put(rs.value("field_id"), value);
            else
                fields.put(rs.value("db_column_name"), value);
        }

        for(String field : fields.keySet())
        {
            Map<String, String> elementJs = getElementTriggerJs(fields.get(field));
            if(elementJs != null)
            {
                for(String _event : elementJs.keySet())
                {
                    if(parseNull(_event).length() == 0) continue;

                    String js = elementJs.get(_event);
                    if(parseNull(js).length() == 0 ) continue;

                    if(_event.equalsIgnoreCase("onblur")) _event = "blur";
                    else if(_event.equalsIgnoreCase("onclick")) _event = "click";
                    else if(_event.equalsIgnoreCase("onchange")) _event = "change";
                    else if(_event.equalsIgnoreCase("onkeypress")) _event = "keypress";
                    else if(_event.equalsIgnoreCase("onkeydown")) _event = "keydown";
                    else if(_event.equalsIgnoreCase("onkeyup")) _event = "keyup";

                    js = js.replaceAll("&quot;", "\"");
                    js = js.replaceAll("##ENTER##","\n").replace("##ENTERr##","\r");

                    _code += "\n\n$(\"#"+htmlformid+" :input[name="+field.toLowerCase()+"]\")." + _event + "(function(){"+js+"});\n\n";
                    System.out.println(_code);
                }
            }
        }

        return _code;

    }

    private static final int ESC_CHAR = (int) '\\';
    private static final String ESC_STR = "\\\\";
    private static final String ESC_PLCHOLDR = "#SLS#";
    /***
     * a function to fix the issue of escape.cote()
     * where it removes \ characters from the string instead of properly escaping it
     */
    String elementTriggerCote(String str) {
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

  public static String elementTriggerCote2(String paramString) {

    if (paramString == null) {
      return paramString;
    }

    int i = paramString.length();
    char[] arrayOfChar = new char[i + i];
    int j;
    int k;
    for (k = j = 0; j < i; j++)
    {
      arrayOfChar[(k++)] = (char)paramString.charAt(j);
    }

    if (k != j) {
      return new String(arrayOfChar, 0, k);
    }

    return "'" + paramString.replaceAll("'","''") + "'";
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

    //return random number between 0 and Integer.MAX_VALUE
    public static int getRandomNumber(){
        return (int)(Math.random() * Integer.MAX_VALUE);
    }

    String getBoostedVersion(com.etn.beans.Contexte etn, String formId)
    {
        String qry = "Select COALESCE(st.form_boosted_version,'4.x') as boosted_version FROM "+parseNull(GlobalParm.getParm("PORTAL_DB"))+".sites st where id = (Select pf.site_id from process_forms pf where form_id = "+ escape.cote(formId)+")";        
        Set rs  = etn.execute(qry);
        if (rs.next()) {
            if(parseNull(rs.value("boosted_version")).equalsIgnoreCase("5.x"))
                return "5.x";
        }
        return "4.x";
    }

    String getSelectedSiteId(javax.servlet.http.HttpSession session)
    {
        if(session.getAttribute("SELECTED_SITE_ID") == null) return "";
        return (String)session.getAttribute("SELECTED_SITE_ID");
    }

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

    String getRsValue(com.etn.lang.ResultSet.Set rs, String col)
    {
        if(rs == null) return "";
        return parseNull(rs.value(col));
    }

    String addSelectControl(String id, String name,
            java.util.Map<String,String> map, String selectedValue,
            String cssClass, String scripts)
    {


        return UIHelper.getSelectControl(id,name,map,selectedValue,cssClass,scripts);

    }


    String addSelectControl(String id, String name,
            java.util.Map<String,String> map, java.util.ArrayList svals,
            String cssClass, String scripts, boolean multiple)
    {
        return UIHelper.getSelectControl(id,name,map,svals,cssClass,scripts,multiple);
    }

    java.util.List<com.etn.asimina.beans.Language> getLangs(com.etn.beans.Contexte Etn, javax.servlet.http.HttpSession session){
		return com.etn.asimina.util.SiteHelper.getSiteLangs(Etn,getSelectedSiteId(session));
	}

    java.util.List<com.etn.asimina.beans.Language> getLangs(com.etn.beans.Contexte Etn, String siteId){
		return com.etn.asimina.util.SiteHelper.getSiteLangs(Etn,siteId);
	}

    String encodeJSONStringDB(String str){
        return str.replaceAll("\\\\", "#slash#");
    }

    String decodeJSONStringDB(String str){
        return str.replaceAll("#slash#","\\\\");
    }

    /***
    * updated escape cote to preserve slashes (\)
    * which are removed by escape.cote() function
    */
    String escapeCote2(String str){
        if(str == null || str.trim().length() == 0){
            return escape.cote(str);
        }

        String retStr = escape.cote(encodeJSONStringDB(str));
        retStr = retStr.replaceAll("#slash#","#slash##slash#");
        retStr = decodeJSONStringDB(retStr);

        return retStr;
    }

    com.etn.lang.ResultSet.Set getFormFields(com.etn.beans.Contexte etn, String formId, String lineId, String langId){

        String query = "SELECT pff.id as _etn_id, pffd.langue_id as langid, pff.field_id as _etn_field_id, pff.label_id as _etn_label_id, pff.form_id as _etn_form_id, pff.field_type as _etn_field_type, db_column_name as _etn_db_column_name, file_extension as _etn_file_extension,'' as _etn_file_icon, pffd.label as _etn_label, font_weight as _etn_font_weight, font_size as _etn_font_size, color as _etn_color, pffd.placeholder as _etn_placeholder, name as _etn_field_name, pffd.value as _etn_value, maxlength as _etn_maxlength, regx_exp as _etn_regx_exp, pff.required as _etn_required, rule_field as _etn_rule_field, pff.add_no_of_days as _etn_add_no_of_days, pff.start_time as _etn_start_time, pff.end_time as _etn_end_time, pff.time_slice as _etn_time_slice, pff.default_time_value as _etn_default_time_value, autocomplete_char_after as _etn_autocomplete_char_after, element_autocomplete_query as _etn_element_autocomplete_query, pff.element_trigger as _etn_element_trigger, pffd.label as _etn_label_name, element_option_class as _etn_element_option_class, element_option_others as _etn_element_option_others, pff.element_option_query as _etn_element_option_query, pffd.option_query as _etn_element_option_query_value, pff.group_of_fields as _etn_group_of_fields, pff.type as _etn_type, resizable_col_class as _etn_resizable_col_class, pffd.options as _etn_options, pff.img_width as _etn_img_width, pff.img_height as _etn_img_height, pff.img_alt as _etn_img_alt, pff.img_murl as _etn_img_murl, pff.href_chckbx as _etn_href_chckbx, pffd.err_msg as _etn_err_msg, pff.href_target as _etn_href_target, pff.img_href_url as _etn_img_href_url, pff.site_key as _etn_site_key, pff.theme as _etn_theme, pff.recaptcha_data_size as _etn_recaptcha_data_size, btn_id as _etn_btn_id, container_bkcolor as _etn_container_bkcolor, text_align as _etn_text_align, text_border as _etn_text_border, custom_css as _etn_custom_css, min_range as _etn_min_range, max_range as _etn_max_range, step_range as _etn_step_range, pff.img_url as _etn_img_url, default_country_code as _etn_default_country_code, allow_country_code as _etn_allow_country_code, allow_national_mode as _etn_allow_national_mode, local_country_name as _etn_local_country_name, auto_format_tel_number as _etn_auto_format_tel_number, pff.hidden as _etn_hidden_field, pff.custom_classes as _etn_custom_classes, pff.date_format as _etn_date_format, pff.file_browser_val as _etn_file_browser_val FROM process_form_fields_unpublished pff, process_form_field_descriptions_unpublished pffd WHERE pff.form_id = pffd.form_id AND pff.field_id = pffd.field_id AND pff.form_id = " + escape.cote(formId) + " AND line_id = " + escape.cote(lineId) + " AND pff.field_type IN (" + escape.cote("fs") + ", \"\") AND pff.always_visible = " + escape.cote("1") + " AND pffd.langue_id = " + escape.cote(langId) + " GROUP BY 1,2 ORDER BY pff.seq_order, pff.id;";
        com.etn.lang.ResultSet.Set results = etn.execute(query);
        return  results;
    }

    com.etn.lang.ResultSet.Set getForm(com.etn.beans.Contexte etn, String formId, String langId){

        String query = "SELECT * FROM process_forms_unpublished pf, process_form_descriptions_unpublished pfd WHERE pf.form_id = pfd.form_id AND langue_id = " + escape.cote(langId) + " AND pf.form_id = " + escape.cote(formId);
        
        return etn.execute(query);
    }

    String getFormHtml(com.etn.beans.Contexte etn, javax.servlet.http.HttpServletRequest request, String formId, String langId, String ruleId, String isPreview, String isAdmin){
      
      
      String formSuccessMsg = "Form is created.";
      String formSubmitBtnLbl = "Enregistrer";
      String formCancelBtnLbl = "Annuler";
      String formClass = "";
      String formEnctype = "multipart/form-data charset=utf-8";
      String formAutoComplete = "off";
      String formMethod = "post";
      String redirectUrl = "";
      String formSubmitBtnAlign = "r";
      String formWidth = "12";
      
      Set _rsLang = etn.execute("select * from language where langue_id = "+escape.cote(langId));
      _rsLang.next();

      Set formRs = getForm(etn, formId, langId);
      if(formRs.next()){

        formSuccessMsg = parseNull(formRs.value("success_msg"));
        if(parseNull(formRs.value("submit_btn_lbl")).length() > 0) formSubmitBtnLbl = parseNull(formRs.value("submit_btn_lbl"));
        if(parseNull(formRs.value("cancel_btn_lbl")).length() > 0) formCancelBtnLbl = parseNull(formRs.value("cancel_btn_lbl"));

        formClass = parseNull(formRs.value("form_class"));

        if(parseNull(formRs.value("form_enctype")).length() > 0)
          formEnctype = parseNull(formRs.value("form_enctype"));

        formAutoComplete = parseNull(formRs.value("form_autocomplete"));
        formMethod = parseNull(formRs.value("form_method"));
        redirectUrl = parseNull(formRs.value("redirect_url"));
        formSubmitBtnAlign = parseNull(formRs.value("btn_align"));

        if(formSubmitBtnAlign.equalsIgnoreCase("r"))
          formSubmitBtnAlign = "right";
        else if(formSubmitBtnAlign.equalsIgnoreCase("l"))
          formSubmitBtnAlign = "left";
        else if(formSubmitBtnAlign.equalsIgnoreCase("c"))
          formSubmitBtnAlign = "center";

        if(formRs.value("form_width").length() > 0)
          formWidth = formRs.value("form_width");
      }

      StringBuffer formHtml = new StringBuffer();

      formHtml.append("<div class=\"container mt-4 mb-4\" >");
      formHtml.append("\n\n\t<form id=\"demand_form\" method=\"" + formMethod + "\" enctype=\"" + formEnctype + "\" autocomplete=\"" + formAutoComplete + "\" class=\"" + formClass + " col-" + formWidth + "\">");
      formHtml.append("\n\n\t\t<input type=\"hidden\" id=\"appcontext\" value=\"" + request.getContextPath() + "/\" />");
      formHtml.append("\n\t\t<input type=\"hidden\" name=\"form_id\" id=\"form_id\" value=\"" + formId + "\" />");
      formHtml.append("\n\t\t<input type=\"hidden\" name=\"rule_id\" id=\"rule_id\" value=\"" + ruleId + "\" />");
      formHtml.append("\n\t\t<input type=\"hidden\" name=\"mid\" id=\"mid\" value=\"\" />");
      formHtml.append("\n\t\t<input type=\"hidden\" name=\"menu_lang\" id=\"menu_lang\" value=\"\" />");
      formHtml.append("\n\t\t<input type=\"hidden\" name=\"portalurl\" id=\"portalurl\" value=\"\" />");
      formHtml.append("\n\t\t<input type=\"hidden\" id=\"success_msg\" value=\"" + formSuccessMsg + "\" />");
      formHtml.append("\n\t\t<input type=\"hidden\" name=\"redirect_url\" id=\"redirect_url\" value=\"" + redirectUrl + "\">");
      formHtml.append("\n\t\t<input type=\"hidden\" name=\"rule_status\" id=\"rule_status\" value=\"\">");
      formHtml.append("\n\t\t<input type=\"hidden\" name=\"is_admin\" id=\"is_admin\" value=\"" + isAdmin + "\">");
      formHtml.append("\n\t\t<input type=\"hidden\" name=\"_flang\" id=\"_flang\" value=\"" + parseNull(_rsLang.value("langue_code")) + "\">");
      formHtml.append("\n\t\t<input type=\"hidden\" name=\"_ftyp\" id=\"_ftyp\" value=\"" + parseNull(formRs.value("type")) + "\">");
      formHtml.append("\n\t\t<input type=\"hidden\" id=\"_imagefilemaxsize\" value=\"" + parseNull(GlobalParm.getParm("client_image_max_size")) + "\">");
      formHtml.append("\n\t\t<input type=\"hidden\" id=\"_imagequality\" value=\"" + parseNull(GlobalParm.getParm("client_image_quality")) + "\">");
	  
	  formHtml.append("\n\t\t<input type=\"hidden\" id=\"largeFileMsg\" value=\"" + escapeCoteValue(libelle_msg(etn, request, "File is too large. Choose another file.")) + "\">");
	  formHtml.append("\n\t\t<input type=\"hidden\" id=\"largeImageMsg\" value=\"" + escapeCoteValue(libelle_msg(etn, request, "Image is too large. Choose another image.")) + "\">");
      
      if(parseNull(formRs.value("type")).equals("sign_up") || parseNull(formRs.value("type")).equals("forgot_password"))
        formHtml.append("\n\t\t<input type=\"hidden\" name=\"_fsnew\" id=\"_fsnew\" value=\"" + 1 + "\">");

      Set lineRs = etn.execute("SELECT * FROM process_form_lines_unpublished WHERE form_id = " + escape.cote(formId) + " ORDER BY CAST(line_seq as UNSIGNED);");

      String lineId = "";
      Set rs = null;

      while(lineRs.next()){

        lineId = parseNull(lineRs.value("id"));

        rs = getFormFields(etn, formId, lineId, langId);

        formHtml.append("\n\n\t\t<div id=\"" + parseNull(lineRs.value("line_id")) + "\" class=\"col-sm-" + parseNull(lineRs.value("line_width")) + " " + parseNull(lineRs.value("line_class")) + "\">");
        formHtml.append("\n\n\t\t\t<div class=\"row dynamic_line_fields\">");

        if(rs.rs.Rows > 0) {
          formHtml.append("\n\n\t\t\t\t" + loadDynamicsSection(etn, request, rs, null, null, null, "", "1", formId, ruleId, "frontendcall", lineId, langId));
        }
        else formHtml.append("");

        formHtml.append("\n\t\t\t</div>");
        formHtml.append("\n\t\t</div>");
      }

      formHtml.append("\n\n\t\t<div id=\"noe_js_script\"> </div>");

      if(isPreview.length() == 0 && !isPreview.equals("1")){

        formHtml.append("\n\n\t\t<div class=\"col-sm-12\" style=\"text-align: " + formSubmitBtnAlign + "; margin-top: 30px;\">");
        formHtml.append("\n\t\t\t<input type=\"reset\" value=\"" + formCancelBtnLbl + "\"  class=\"btn btn-secondary btn-lg reset\" />");
        formHtml.append("\n\t\t\t<input type=\"button\" value=\"" + formSubmitBtnLbl + "\" onclick=\"register_demand(this)\" class=\"btn btn-primary btn-lg submit\"/>");
        formHtml.append("\n\t\t</div>");

      }

        formHtml.append("\n\t\t<input type=\"hidden\" name=\"form_token\" id=\"form_token\" value=\"\">");
        formHtml.append("\n\t\t<div class=\"modal fade\" id=\"submitbtnmodal\" tabindex=\"-1\" role=\"dialog\" aria-labelledby=\"Submit modal\" aria-hidden=\"true\">");
        formHtml.append("\n\n\t\t\t<div class=\"modal-dialog modal-dialog-centered\" role=\"document\">");
        formHtml.append("\n\t\t\t\t<div class=\"modal-content\">");
        formHtml.append("\n\t\t\t\t\t<div class=\"modal-header\">");
        formHtml.append("\n\t\t\t\t\t\t<h5 class=\"modal-title\" id=\"submit_title\"></h5>");
        formHtml.append("\n\t\t\t\t\t\t<button type=\"button\" class=\"close\" data-bs-dismiss=\"modal\" data-dismiss=\"modal\"></button>");
        formHtml.append("\n\t\t\t\t\t</div>");
        formHtml.append("\n\t\t\t\t\t<div class=\"modal-body\" id=\"submit_btn_msg\"></div>");
        formHtml.append("\n\t\t\t\t\t\t<div class=\"modal-footer\">");
        formHtml.append("\n\t\t\t\t\t\t<button type=\"button\" class=\"btn btn-secondary\" data-bs-dismiss=\"modal\" data-dismiss=\"modal\">" + libelle_msg(etn, request, "Close") + "</button>");
        formHtml.append("\n\t\t\t\t\t</div>");
        formHtml.append("\n\t\t\t\t</div>");
        formHtml.append("\n\t\t\t</div>");
        formHtml.append("\n\t\t</div>");

        formHtml.append("\n\t</form>");
        formHtml.append("\n</div>");

      return formHtml.toString();
    }

    JSONObject getDataObject(com.etn.beans.Contexte etn, javax.servlet.http.HttpServletRequest request, String formId, String langId, String lang, String ruleId, String isPreview) throws JSONException {
        
        return getDataObject(etn, request, formId, langId, lang, ruleId, isPreview, "0");
    }

    JSONObject getDataObject(com.etn.beans.Contexte etn, javax.servlet.http.HttpServletRequest request, String formId, String langId, String lang, String ruleId, String isPreview, String isAdmin) throws JSONException {

        JSONObject data = new JSONObject();
        
        data.put("cssFiles", getCssFiles(etn, request, formId,isPreview, isAdmin));
        data.put("jsFiles", getJsFiles(etn, request, lang,formId,isPreview, isAdmin));
        data.put("metaData", getMetaData(etn, formId, langId));
        data.put("bodyCss", getBodyCss(etn, formId, langId));
        data.put("bodyJs", getBodyJs(etn, formId, langId));
        data.put("formHtml", getFormHtml(etn, request, formId, langId, ruleId, isPreview, isAdmin));

        return data;
    }

    private JSONArray getCssFiles(com.etn.beans.Contexte etn, javax.servlet.http.HttpServletRequest request, String formId) throws JSONException {
        
        String boostedVersion = getBoostedVersion(etn,formId);
        JSONArray cssFiles = new JSONArray();
        cssFiles.put(request.getContextPath() + "/css/flatpickr.min.css");
        cssFiles.put(request.getContextPath() + "/css/my.css");
        cssFiles.put(request.getContextPath() + "/css/intlTelInput.min.css");
        return cssFiles;
    }

    private JSONArray getCssFiles(com.etn.beans.Contexte etn, javax.servlet.http.HttpServletRequest request, String formId,String isPreview, String isAdmin) throws JSONException {
        JSONArray cssFiles = getCssFiles(etn,request,formId);
        String boostedFileLocation = request.getContextPath() + "/css/boosted.min.css";
        String boostedVersion = getBoostedVersion(etn,formId);
        if(!isPreview.equals("1") && isAdmin.equals("0")){
            if(boostedVersion.equalsIgnoreCase("4.x"))
                cssFiles.put(boostedFileLocation); 
            return cssFiles;
        }

        if (boostedVersion.equalsIgnoreCase("5.x"))
            boostedFileLocation = boostedFileLocation.replace("/boosted.min","/boosted5.min"); 
        cssFiles.put(boostedFileLocation); 
        return cssFiles;
    }

    private JSONArray getJsFiles(com.etn.beans.Contexte etn,javax.servlet.http.HttpServletRequest request, String lang,String formId,String isPreview, String isAdmin) throws JSONException {

        JSONArray jsFiles = getJsFiles(etn,request,lang,formId,isPreview.equals("1"));
        String boostedVersion = getBoostedVersion(etn,formId);
        String boostedFileLocation = request.getContextPath() + "/js/boosted.min413.js";
        if(!isPreview.equals("1") && isAdmin.equals("0")){
            if (boostedVersion.equalsIgnoreCase("4.x"))
                jsFiles.put(boostedFileLocation); 
            return jsFiles;
        }
        
        if (boostedVersion.equalsIgnoreCase("5.x"))
            boostedFileLocation = boostedFileLocation.replace("/boosted.min413","/boosted5.min"); 
        jsFiles.put(boostedFileLocation); 
        return jsFiles;
    }

    private JSONArray getJsFiles(com.etn.beans.Contexte etn,javax.servlet.http.HttpServletRequest request, String lang,String formId,boolean isPreview) throws JSONException {

        
        JSONArray jsFiles = new JSONArray();
        if(isPreview)
            jsFiles.put(request.getContextPath() + "/js/jquery.min.js");
            
        jsFiles.put(request.getContextPath() + "/js/flatpickr.min.js");
        jsFiles.put("https://www.google.com/recaptcha/api.js?hl="+lang);
        jsFiles.put(request.getContextPath() + "/js/intlTelInput.min.js");
        jsFiles.put(request.getContextPath() + "/js/html_form_template.js");
        jsFiles.put(request.getContextPath() + "/js/triggers.js");
        jsFiles.put(request.getContextPath() + "/js/forms.js");
        return jsFiles;
    }

    private JSONArray getMetaData(com.etn.beans.Contexte etn, String formId, String langId) throws JSONException {

        JSONArray metaData = new JSONArray();

        String formVairant = "";
        Set formRs = getForm(etn, formId, langId);

        if(formRs.next()){

            formVairant = parseNull(formRs.value("variant"));
        }

        String pagePath = "";
        Set rsFormDescription  = etn.execute("Select * from process_form_descriptions_unpublished where langue_id = " + escape.cote(langId) + " and form_id = " + escape.cote(formId));

        if(rsFormDescription.next()) {

            if(formVairant.equalsIgnoreCase("logged"))
              pagePath = formVairant + "/";

            pagePath += parseNull(rsFormDescription.value("page_path"));
        }

        if(pagePath.length() > 0) {

            pagePath += ".html";
            metaData.put("<meta name=\"etn:eleurl\" content=\"" + pagePath.replaceAll("\"","&quot;") + "\">");
        }

        return metaData;

    }

    private String getBodyCss(com.etn.beans.Contexte etn, String formId, String langId){

        StringBuffer bodyCss = new StringBuffer();
        Set lineRs = etn.execute("SELECT * FROM process_form_lines_unpublished WHERE form_id = " + escape.cote(formId) + " ORDER BY CAST(line_seq as UNSIGNED);");

        String lineId = "";
        Set rs = null;

        while(lineRs.next()){

            lineId = parseNull(lineRs.value("id"));

            rs = getFormFields(etn, formId, lineId, langId);

            while(rs.next()){

                bodyCss.append(parseNull(rs.value("_etn_custom_css")));

            }
        }

        Set formRs = getForm(etn, formId, langId);
        String formCss = "";

        while(formRs.next()){

            formCss = parseNull(formRs.value("form_css"));

            if(formCss.length() > 0){

                formCss = formCss.replaceAll("&quot;", "\"");
            }
        }

        bodyCss.append(formCss);
        bodyCss.append("\n input {box-shadow:none}");
        return bodyCss.toString();
    }

    private String getBodyJs(com.etn.beans.Contexte etn, String formId, String langId){

        String formJs = "";
        Set formRs = getForm(etn, formId, langId);

        if(formRs.next()){

            formJs = parseNull(formRs.value("form_js"));

            if(formJs.length() > 0){

                formJs = formJs.replaceAll("&quot;", "\"");
            }
        }

        return formJs;
    }

    //for pages module API call
    // example  callPagesUpdateFormAPI(<formId>, Etn.getId());
    public String callPagesUpdateFormAPI(String formId, int updatedBy){

        String responseStr = "";
        try{
            String url = GlobalParm.getParm("PAGES_FORM_UPDATE_API_URL");
            url += "?formId="+formId+"&pid="+updatedBy;
            responseStr = getStringResponseFromUrl(url);
        }
        catch(Exception ex){
            ex.printStackTrace();
        }

        return responseStr;
    }

    public String getStringResponseFromUrl(String url) throws Exception {

        StringBuilder response = new StringBuilder();

        HttpURLConnection connection = (HttpURLConnection) new URL(url).openConnection();

        // handle error response code it occurs
        int responseCode = connection.getResponseCode();
        InputStream inputStream;
        if (200 <= responseCode && responseCode <= 299) {
            inputStream = connection.getInputStream();
        } else {
            inputStream = connection.getErrorStream();
        }

        BufferedReader in = new BufferedReader(
            new InputStreamReader(
                inputStream));

        String currentLine;

        while ((currentLine = in.readLine()) != null)
            response.append(currentLine);

        in.close();

        return response.toString();
    }

    String readDataFromFile(String path, String tableName){

        StringBuffer outputFileData = new StringBuffer();
        String html = "";

        try{

            java.io.File f = new java.io.File(path);

            if(f.exists() && !f.isDirectory()){
    

                BufferedReader in = new BufferedReader(new java.io.FileReader(path));
                String data = in.readLine();

                while(data != null){
                    
                    outputFileData.append(data).append("\n");
                    data = in.readLine();
                }

                html = outputFileData.toString();
                if(html.length() > 0){

                    html = subStringTemplateContent(html, tableName);
                }
            }
        } catch(Exception e){
            
            e.printStackTrace();
        }
        
        if(html.length() > 0) return html;
        
        return "";
    }

    String subStringTemplateContent(String html, String tableName){

        String startingBoundary = "Content-Type: multipart/alternative;\n boundary=\"------------010101080201020804090106\"\n\nThis is a multi-part message in MIME format.\n--------------010101080201020804090106\nContent-Type: text/html; charset=utf-8\nContent-Transfer-Encoding: 7bit\n\n\n<div id='" + tableName + "_template_div'>\n";

        int endIndex = html.toString().indexOf("\n</div>\n--------------010101080201020804090106--");

        html = html.toString().substring(startingBoundary.length(), endIndex);

        return html;
    }

    freemarker.template.Configuration getFreemarkerConfig(String TEMPLATES_DIR) throws java.io.IOException {

        // Create your Configuration instance, and specify if up to what FreeMarker
        // version (here 2.3.27) do you want to apply the fixes that are not 100%
        // backward-compatible. See the Configuration JavaDoc for details.
        freemarker.template.Configuration cfg = new freemarker.template.Configuration(freemarker.template.Configuration.VERSION_2_3_28);

        // Specify the source where the template files come from. Here I set a
        // plain directory for it, but non-file-system sources are possible too:
        //cfg.setDirectoryForTemplateLoading(new java.io.File(TEMPLATES_DIR));
        // Set the preferred charset template files are stored in. UTF-8 is
        // a good choice in most applications:
        cfg.setDefaultEncoding("UTF-8");

        // Sets how errors will appear.
        // During web page *development* TemplateExceptionHandler.HTML_DEBUG_HANDLER is better.
        cfg.setTemplateExceptionHandler(freemarker.template.TemplateExceptionHandler.HTML_DEBUG_HANDLER);

        // Don't log exceptions inside FreeMarker that it will thrown at you anyway:
        cfg.setLogTemplateExceptions(false);

        // Wrap unchecked exceptions thrown during template processing into TemplateException-s.
        cfg.setWrapUncheckedExceptions(true);

        cfg.setDateTimeFormat("yyyy-MM-dd HH:mm");
        cfg.setDateFormat("yyyy-MM-dd");
        cfg.setTimeFormat("HH:mm");

        // String TEMPLATES_DIR = GlobalParm.getParm("BASE_DIR") + "/admin/templates/";
        freemarker.cache.FileTemplateLoader ftl = new freemarker.cache.FileTemplateLoader(new java.io.File(TEMPLATES_DIR));

        cfg.setTemplateLoader(ftl);

        return cfg;
    }

    String  getSearchCriteriaHtml(com.etn.beans.Contexte Etn, Set rs, String formid, ServletRequest request, String repliesDateFrom, String repliesDateTo, String isDeleteId,String lsu)
    {

        String htm = "<div class='col-xs-12 col-sm-12 col-md-12 col-lg-12' style='padding: 15px; background: #eee; border-radius: 6px; margin-bottom: 15px; margin-top:30px'>";
        if(lsu.length()>0)
            htm += "<form id='searchfrm' class='form-horizontal' action='search.jsp?___fid="+formid+"&lsu="+lsu+"' method='post'>";
        else
            htm += "<form id='searchfrm' class='form-horizontal' action='search.jsp?___fid="+formid+"' method='post'>";
        int i = 0;

        htm += "<input type='hidden' name='is_user_search' value='1' />";

        String selected = "";
        JSONObject optionsJson = null;
        JSONArray optionTxtArray = null;

        while(rs.next())
        {
            if(i % 2 == 0)
            {
                if(i >  0) htm += "</div>";
                htm += "<div class='row'>";
            }

            if("tel".equalsIgnoreCase(rs.value("type")) || "text".equalsIgnoreCase(rs.value("type")) || "fileupload".equalsIgnoreCase(rs.value("type")) || "texthidden".equalsIgnoreCase(rs.value("type")) || "texttextarea".equalsIgnoreCase(rs.value("type"))  || "textfield".equalsIgnoreCase(rs.value("type"))  || "password".equalsIgnoreCase(rs.value("type"))  || "autocomplete".equalsIgnoreCase(rs.value("type")))
            {
                String sval = "";

                if(isDeleteId.length() == 0 && !isDeleteId.equals("1")){
                    sval = parseNull(request.getParameter(parseNull(rs.value("db_column_name"))));
                }

                htm += "<div class='col-sm-6'><div class=' form-group'>";
                htm += "<label class='col-sm-3 control-label'>" + parseNull(rs.value("label")) + "</label>";
                htm += "<div class='col-sm-9' ><input class='form-control' type='text' name='"+parseNull(rs.value("db_column_name"))+"' value='"+escapeCoteValue(sval)+"' /></div>";
                htm += "</div></div>";
            }
            else if("number".equalsIgnoreCase(rs.value("type")))
            {
                htm += "<div class='col-sm-6'><div class=' form-group'>";
                htm += "<label class='col-sm-3 control-label'>" + parseNull(rs.value("label")) + "</label>";
                htm += "<div class='col-sm-9 form-inline' >";
                if("1".equals(rs.value("show_range")))
                {
                    String sfval = parseNull(request.getParameter("___rngf_"+parseNull(rs.value("db_column_name"))));
                    String stval = parseNull(request.getParameter("___rngt_"+parseNull(rs.value("db_column_name"))));

                    htm += "<input class='form-control' style='width:45%' type='text' name='___rngf_"+parseNull(rs.value("db_column_name"))+"' value='"+escapeCoteValue(sfval)+"' />";
                    htm += "&nbsp;&nbsp;&nbsp;<b>To : </b><input style='width:45%' class='form-control' type='text' name='___rngt_"+parseNull(rs.value("db_column_name"))+"' value='"+escapeCoteValue(stval)+"' />";
                }
                else
                {
                    String sval = "";

                    if(isDeleteId.length() == 0 && !isDeleteId.equals("1")){
                        sval = parseNull(request.getParameter(parseNull(rs.value("db_column_name"))));
                    }
                    htm += "<input class='form-control' type='text' name='"+parseNull(rs.value("db_column_name"))+"' value='"+escapeCoteValue(sval)+"' />";
                }
                htm += "</div>";
                htm += "</div></div>";
            }
            else if("textdate".equalsIgnoreCase(rs.value("type")) || "textdatetime".equalsIgnoreCase(rs.value("type")) )
            {
                htm += "<div class='col-sm-6'><div class=' form-group'>";
                htm += "<label class='col-sm-3 control-label'>" + parseNull(rs.value("label")) + "</label>";
                htm += "<div class='col-sm-9 form-inline' >";
                String controlclass = "ctextdate";
                if("textdatetime".equalsIgnoreCase(rs.value("type"))) controlclass = "ctextdatetime";
                if("1".equals(rs.value("show_range")))
                {
                    String sfval = parseNull(request.getParameter("___rngf_"+parseNull(rs.value("db_column_name"))));
                    String stval = parseNull(request.getParameter("___rngt_"+parseNull(rs.value("db_column_name"))));

                    htm += "<input style='width:45%' readonly class='form-control "+controlclass +"' type='text' name='___rngf_"+parseNull(rs.value("db_column_name"))+"' value='"+escapeCoteValue(sfval)+"' />";
                    htm += "&nbsp;&nbsp;&nbsp;<b>To : </b><input style='width:45%' readonly class='form-control "+controlclass +"' type='text' name='___rngt_"+parseNull(rs.value("db_column_name"))+"' value='"+escapeCoteValue(stval)+"' />";
                }
                else
                {
                    String sval = "";

                    if(isDeleteId.length() == 0 && !isDeleteId.equals("1")){
                        sval = parseNull(request.getParameter(parseNull(rs.value("db_column_name"))));
                    }
                    htm += "<input readonly class='form-control "+controlclass +"' type='text' name='"+parseNull(rs.value("db_column_name"))+"' value='"+escapeCoteValue(sval)+"' />";
                }
                htm += "</div>";
                htm += "</div></div>";
            }
            else if("email".equalsIgnoreCase(rs.value("type")))
            {
                String sval = "";

                if(isDeleteId.length() == 0 && !isDeleteId.equals("1")){
                    sval = parseNull(request.getParameter(parseNull(rs.value("db_column_name"))));
                }
                htm += "<div class='col-sm-6'><div class=' form-group'>";
                htm += "<label class='col-sm-3 control-label'>" + parseNull(rs.value("label")) + "</label>";
                htm += "<div class='col-sm-9' ><input class='form-control' type='email' name='"+parseNull(rs.value("db_column_name"))+"' value='"+escapeCoteValue(sval)+"' /></div>";
                htm += "</div></div>";
            }
            else if("dropdown".equalsIgnoreCase(rs.value("type")) || "radio".equalsIgnoreCase(rs.value("type"))  || "checkbox".equalsIgnoreCase(rs.value("type")))
            {
    
                String sval = "";

                if(isDeleteId.length() == 0 && !isDeleteId.equals("1")){
                    sval = parseNull(request.getParameter(parseNull(rs.value("db_column_name"))));
                }
                htm += "<div class='col-sm-6'><div class=' form-group'>";
                htm += "<label class='col-sm-3 control-label'>" + parseNull(rs.value("label")) + "</label>";
                htm += "<div class='col-sm-9' >";
                htm += "<select class='form-control' name='"+parseNull(rs.value("db_column_name"))+"' >";
                String opts = "";
                boolean anyempty = false;

                if(parseNull(rs.value("option_query")).length() > 0)
                {

                    if(parseNull(rs.value("option_query")).toLowerCase().startsWith("select ")){

                        Set _rs = Etn.execute(parseNull(rs.value("option_query")));
                        while(_rs.next())
                        {
                            String _key = parseNull(_rs.value(0));
                            String _val = parseNull(_rs.value(0));

                            selected = "";
                            if(sval.equals(_key)) selected = "selected";
                            opts += "<option "+selected+" value='"+escapeCoteValue(_key)+"'>"+escapeCoteValue(_val)+"</option>";
                            if(_key.length() == 0) anyempty = true;
                        }
                    } else {

                        if(parseNull(rs.value("option_query")).length() > 0){

                            String[] pairToken = parseNull(rs.value("option_query")).split(",");
                            String[] pairArr = null;

                            for(String pair : pairToken){

                                pairArr = pair.split(";");

                                selected = "";
                                if(sval.equals(pairArr[0])) selected = "selected";
                                opts += "<option "+selected+" value='"+escapeCoteValue(pairArr[0].trim())+"'>"+escapeCoteValue(pairArr[1].trim())+"</option>";
                                if(pairArr[0].length() == 0) anyempty = true;

                            }
                        }
                    }
                }
                else if(parseNull(rs.value("options")).length() > 0)
                {
                    try{

                        optionsJson = new JSONObject(parseNull(rs.value("options")));
                        optionTxtArray = optionsJson.getJSONArray("txt");

                        for(int j=0; j < optionTxtArray.length(); j++){
    
                            selected = "";
                            if(sval.equals(optionTxtArray.get(j))) selected = "selected";
                            opts += "<option "+selected+" value='"+escapeCoteValue(optionTxtArray.get(j).toString())+"'>"+escapeCoteValue(optionTxtArray.get(j).toString())+"</option>";
                            if(optionTxtArray.get(j).toString().length() == 0) anyempty = true;
                        }
                    }catch(JSONException je){
                        je.printStackTrace();
                    }catch(Exception e){
                        e.printStackTrace();
                    }

                }
                if(!anyempty) opts = "<option value=''>---select---</option>" + opts;
                htm += opts;

                htm += "</select>";
                htm += "</div>";
                htm += "</div></div>";
            }

            i++;
        }



        htm += "<div class='col-sm-6'><div class=' form-group'>";
        htm += "<label class='col-sm-3 control-label'>Created date</label>";
        htm += "<div class='col-sm-9' >";

        htm += "<input style='width:45%' class='form-control ctextdate' type='text' name='___rngf_created_on' value='"+escapeCoteValue(repliesDateFrom)+"' />";
        htm += "&nbsp;&nbsp;&nbsp;<b>To : </b><input style='width:45%' class='form-control ctextdate' type='text' name='___rngt_created_on' value='"+escapeCoteValue(repliesDateTo)+"' />";

        htm += "</div></div></div>";
        htm += "</div>";



        htm += "<div class='row'><div class='col-sm-12 text-center'><div class='' role='group' aria-label='controls'>";

        htm += "<button onclick='onSearch()' type='button' class='btn btn-success'>Search</button>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";

        htm += "</div></div></div>";
        htm += "</form></div>";

        return htm;
    }


    String displayFormReplies(com.etn.beans.Contexte Etn, Set selectedResultRs, Set results, String primarykey, String formid, String tablename, String siteId, String formType){

        String portaldb = GlobalParm.getParm("PROD_PORTAL_DB");
        String responseHtml = "";
        String userCurrentStatusCss = "bg-changed";
        if(formType.equals("sign_up")){

            responseHtml += "<div> <div class=\"small mb-3\"> <strong>Legend : </strong> <span class=\"bg-published rounded p-1\" >Verified</span> <span class=\"bg-changed rounded p-1\" >New user request</span> <span class=\"bg-secondary rounded p-1 \" >Inactive</span> <span class=\"bg-unpublished rounded p-1 \" >Rejected</span> <span class=\"bg-danger rounded p-1 \" >Duplicated users</span> </div> </div>";

            Set siteRs = Etn.execute("select * from " + portaldb + ".site_menus where site_id = " + escape.cote(siteId) + " and is_active = 1");

            if(siteRs.rs.Rows == 0){

                responseHtml += "<div> <div class=\"small alert alert-warning\"> <strong>Warning : </strong> <span class=\" rounded p-1\" >We didn't found any active menu in this site. Maybe you face some problem in user creation/verification process.</span> </div> </div>";
            }

        }
        responseHtml += "<table class=\"table table-hover m-t-20\" id=\"resultsdata\" style=\"width: 100%;\">";
    
        responseHtml += "<thead class=\"thead-dark\"><tr>";            
        responseHtml += "<th><input type='checkbox' id='sltall' value='1' /></th>";
        responseHtml += "<th>Created date</th>";
        
        if(formType.equals("sign_up"))
            responseHtml += "<th>Last login date</th>";
                
        while(selectedResultRs.next()) { 
            responseHtml += "<th>"+escapeCoteValue(selectedResultRs.value("label"))+"</th>"; 
        } 

        responseHtml += "<th>Action</th>";
        responseHtml += "</tr></thead>"; 

        if (results != null && results.rs.Rows > 0)
        {
            JSONObject optionsJson = null;
            JSONArray optionTxtArray = null;
    
            int j=0;
            String email = "";
            String isUserActive = "";
            String isUserStatusLock = "";
            String userStatusClass = "";
            String isUserVerified = "";
            String userClientKey = "";
            String portalUrl = "";
            String isAdmin = "";
            String login = "";

            while(results.next())
            {
                userCurrentStatusCss = "bg-changed";
                String clr = "";
                email = parseNull(results.value("_etn_email"));
                login = parseNull(results.value("_etn_login"));
				//we can remove login field in which case the email is the login itself
				if(login.length() == 0) login = email;
                userClientKey = parseNull(results.value(primarykey));
                portalUrl = parseNull(results.value("portalurl"));
                isAdmin = parseNull(results.value("is_admin"));
                portaldb = GlobalParm.getParm("PROD_PORTAL_DB");
                
                if(portalUrl.toLowerCase().contains("_portal")) portaldb = GlobalParm.getParm("PORTAL_DB");                      
                if("1".equals(isAdmin)) portaldb = GlobalParm.getParm("PROD_PORTAL_DB");

                //vhtm holds the html for visible non editable
                String vhtm = "<tr class='no_inline_edit_row ";
                
				if(formType.equals("sign_up"))
				{
					AsiminaAuthenticationHelper asiminaAuthenticationHelper = new AsiminaAuthenticationHelper(Etn,siteId,portaldb,GlobalParm.getParm("CLIENT_PASS_SALT"));
					AsiminaAuthentication asiminaAuthentication = asiminaAuthenticationHelper.getAuthenticationObject();
					AsiminaAuthenticationResponse getUserResponse = asiminaAuthentication.getUser(login);

					if(getUserResponse.isDone()){

						try{
							isUserActive = parseNull(getUserResponse.getHttpResponse().getString("is_active"));
						}catch(JSONException ex){
							ex.printStackTrace();
						}
						try{
							isUserVerified = parseNull(getUserResponse.getHttpResponse().getString("is_verified"));
						}catch(JSONException ex){
							ex.printStackTrace();
						}

						if(isUserVerified.equals("1")){

							if(isUserActive.equals("1"))
								userCurrentStatusCss = "bg-published";
							else
								userCurrentStatusCss = "bg-secondary";                        
		
						} else {

							if(isUserActive.equals("0"))
								userCurrentStatusCss = "bg-secondary";
							else
								userCurrentStatusCss = "bg-changed";
						}

						if(isUserActive.equals("0")){

							isUserStatusLock = "lock";
							userStatusClass = "btn-danger";

						} else if(isUserActive.equals("1")){

							isUserStatusLock = "unlock";
							userStatusClass = "btn-success"; 
						}

					} else {

						isUserStatusLock = "lock";
						userStatusClass = " disabled btn-danger ";
					}

					Set rejectUserRs = Etn.execute("select * from post_work where proces = " + escape.cote(tablename) + " and client_key = " + escape.cote(userClientKey) + " and phase = " + escape.cote("Reject"));

					if(rejectUserRs.rs.Rows > 0)
						userCurrentStatusCss = "bg-unpublished";


					Set duplicateUserRs = Etn.execute("select * from post_work where proces = " + escape.cote(tablename) + " and client_key = " + escape.cote(userClientKey) + " and phase = " + escape.cote("CreateClient"));
					String errCode = "";

					if(duplicateUserRs.next()){

						errCode = parseNull(duplicateUserRs.value("errCode"));
					}

					if(errCode.equals("20")){

						userCurrentStatusCss = " bg-danger ";
		
					}

                    vhtm += userCurrentStatusCss;
                }

                vhtm += "' id='no_inline_edit_"+results.value(primarykey)+"' >";
                //htm holds the html for editable row with form
                String htm = "<tr> <form class='inline_edit_row' style='"+clr+"display:none' id='inlinefrm_"+results.value(primarykey)+"' >";
                selectedResultRs.moveFirst();

                vhtm += "<td style='text-align:center; cursor:pointer'><input type='checkbox' onclick='selectDeleteReply(this)' class='slt_option' value='" + escapeCoteValue(results.value(primarykey)) + "' /><input type='hidden' name='selectedids' value=''  /></td>";

                vhtm += "<td style='cursor:pointer'><div>" + parseNull(results.value("created_on")) + "</div></td>";

                if(formType.equals("sign_up"))
                    vhtm += "<td>" + escapeCoteValue(results.value("user_last_login")) + "</td>";

                while(selectedResultRs.next())
                {
                    vhtm += "<td style='cursor:pointer'>";
                    htm += "<div>";

                    boolean anyempty = false;
                    //first try to get from rule mapping otherwise from master table ... if no record in rule id and master table always_visible = false means this
                    //field is not available to this particular rule so we wont let them edit this
                    String alwaysvisible = "0";
                    boolean required = false;
                    alwaysvisible = selectedResultRs.value("always_visible");
                    if("1".equals(parseNull(selectedResultRs.value("required")))) required = true;

                    Set rsm = Etn.execute("select * from process_rule_fields where rule_id = "+escape.cote(results.value("rule_id"))+" and field_id = "+escape.cote(selectedResultRs.value("field_id")));

                    if(rsm.rs.Rows == 0 && !"1".equals(alwaysvisible)) //this field is not mapped and not even marked alwaysvisible so not allowed in this rule
                    {
                        htm += "<input class='form-control' type='text' disabled value='' ></td>";
                        vhtm += "&nbsp;</td>";
                    }
                    else
                    {
                        if("1".equals(selectedResultRs.value("rule_field")))//its a rule field so not allowed to update
                        {
                            htm += escapeCoteValue(results.value(selectedResultRs.value("db_column_name")));
                            htm += "</td>";
                            vhtm += "<div id='span_"+results.value(primarykey)+"_"+selectedResultRs.value("db_column_name")+"'>"+escapeCoteValue(results.value(selectedResultRs.value("db_column_name")))+"</div>";
                            vhtm += "</div>";
                        }
                        else
                        { 
                            htm = "<div class='inline_edit_row' style='display: none;' id='inlinefrm_"+results.value(primarykey)+"'>";

                            if(selectedResultRs.value("type").equalsIgnoreCase("fileupload")){
   
                                String imgAvatar = results.value(selectedResultRs.value("db_column_name"));

                                if(formType.equals("sign_up") && imgAvatar.length() == 0){

                                    String gender = parseNull(results.value("_etn_civility"));

                                    if(gender.equalsIgnoreCase("Mr.")){

                                        imgAvatar = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADwAAAA8CAYAAAA6/NlyAAAACXBIWXMAAAsTAAALEwEAmpwYAAAF0WlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNS42LWMxNDIgNzkuMTYwOTI0LCAyMDE3LzA3LzEzLTAxOjA2OjM5ICAgICAgICAiPiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdEV2dD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlRXZlbnQjIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4wLyIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgQ0MgMjAxOCAoV2luZG93cykiIHhtcDpDcmVhdGVEYXRlPSIyMDIwLTA5LTIzVDEzOjA0OjQzKzAyOjAwIiB4bXA6TWV0YWRhdGFEYXRlPSIyMDIwLTA5LTIzVDEzOjA0OjQzKzAyOjAwIiB4bXA6TW9kaWZ5RGF0ZT0iMjAyMC0wOS0yM1QxMzowNDo0MyswMjowMCIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDo5NTU1NTllYi02NWM1LWQzNGMtODgwNS0xNDQ2MDM4Y2M1YzUiIHhtcE1NOkRvY3VtZW50SUQ9ImFkb2JlOmRvY2lkOnBob3Rvc2hvcDoxMDIwMWViZC04MWExLTBkNDEtODhjNS05NWMwMGQ1NDkyNTMiIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDplYzZlY2IwMy1mNjg2LWI0NDItYjgyMi0zMTJmMWUwYTBhMjgiIGRjOmZvcm1hdD0iaW1hZ2UvcG5nIiBwaG90b3Nob3A6Q29sb3JNb2RlPSIzIj4gPHhtcE1NOkhpc3Rvcnk+IDxyZGY6U2VxPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0iY3JlYXRlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDplYzZlY2IwMy1mNjg2LWI0NDItYjgyMi0zMTJmMWUwYTBhMjgiIHN0RXZ0OndoZW49IjIwMjAtMDktMjNUMTM6MDQ6NDMrMDI6MDAiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCBDQyAyMDE4IChXaW5kb3dzKSIvPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0ic2F2ZWQiIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6OTU1NTU5ZWItNjVjNS1kMzRjLTg4MDUtMTQ0NjAzOGNjNWM1IiBzdEV2dDp3aGVuPSIyMDIwLTA5LTIzVDEzOjA0OjQzKzAyOjAwIiBzdEV2dDpzb2Z0d2FyZUFnZW50PSJBZG9iZSBQaG90b3Nob3AgQ0MgMjAxOCAoV2luZG93cykiIHN0RXZ0OmNoYW5nZWQ9Ii8iLz4gPC9yZGY6U2VxPiA8L3htcE1NOkhpc3Rvcnk+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+39fAzAAAB51JREFUaN7VmwlMFFcYxwfRolTbaKuUahNrMDZtLdVatUQFqdIYrYpiFZdFELpyhmOrkbMiioAclVNFBV0Bo8UDsHiLSzgFLIrGKJG2iq3pqsSCduX4+t6wu+zCAvNmZgc6yT+b3Zn33vfbd3/vG4oy0AWPKVO4RdkhBcFNKgupHKkRfVcgKVVS0L913cuin8VpUFrq/3BBAzUB6il/ZLycBrpJASt1pZXTeaE8hx7oHWoBMrIAGdnGGrJvtdF5ozIGH7SeWoiMKTEAZF81X4JkMxg1ao4MyBEMtLdysA3CwN6mlqACm0mNbC4ZCducrCHBcy4c2DIDjkd+DBWZk+BFmQlb6GZsi2Fhb1FSpA42Bj4vGQUBy+16KRDpJ+85cCllCrRWjiBt4h3YJv5B71MmqqmFkSGva4zhbt67kB87DTK3fg5JPrNhx4b5eoG1FfydLVxMmgLK6uGkf2gWtpEv2PHoXyxjWviDgrGw2X7xgHD9KdzRBm5kv0da22XYVu41SwCL1X5jGISsteUErBZuIZ2/GpFCs69pkmaM1YFgKzMnQpjjQl6AsdIDZpH27Sz2AxQBbPWR9yFCbM0bqLbwGIBbDkFNS8mnHoajMf73DwdbGgRUW0dCLFF5RsxHb6ZTlmpRwXiebSzkPkgxVVGiBdk8zWRxwmYFhfutEMDSlWgjdXEM0YpsoH5rw2ZRcSX1Q0GAsVL9viSdrmz6AybeCDSdf0uwJq1WXa4Z0Yajr6ZszaZ24z2+6mpuK+xgr78ICnZ5w9lYfpW3fRPsdLHXAMdJrEjttNZXuwWksHd+Hq8x4mjIRriWHGgwFScFQLTrak15Ty6PJqnlgp6wZmw278m+s+nCd7muMiisWud2+9ItiR6xEyzInAjanhOVW4Zw9zNS828fC/9eEGCs3e4OdJlRrvPImjVi1O6/clJgvJdVA19K8BMM+NDmDZpyX5EtOeXa3kVih5ss9DO60NB1ywSDxToZ6aEBflj0NpljEHtDabcoi9E50XMuXWikeKWgwGejvTXAtUfNSedkO0rlNyYG3i5e0DVguawSFPhcnK8GGDsLCIGDiLeAWK8qx8JBqRNkB2+EU6iJCQl8dU8A5IS4wZEgVziXsBjtl43Jto4qrz/zDX7tSKjYv4mRcZlBznByh4QYKi1wHRTF+TB69n7e1yTA5ZTqqINxomfFUxgZUhjjBcbDjGDqpAlEsIm+DoDH0m+tpjN6vnyvJwlwI6U632GcSHHVgrHxK+dbgnTdIiLg/GhPWDTrI0jwcWD0fGm6N0kfVlCkU5Ly+mgoSfEXtN/2p/pse6KpiWIzBz/65YshAVu+zxNeVo4jBlawmZaaimbSC/rBgi1O9oCXFe+QTksK4kFLW0XxM+BYmLugoHgZuz9QBE/lY9jY3Eg8LenMx1UjIHStLeTv8hIMONXXEU7HTGN7HlXOauGhreL0yZDi4yjYomObaDH5GZTOwoPl0lLb+Z7mZwVX9jDrz/lRXnABLQ/V309sk6CxgBkwXmHVyMy5nC8Hsd48aKul/A04/qMzI6OLYn3oPW28ZA3Euq2GDKmY+To6wYrrgbod6+1hr0O0fAui5sm0RWgGq0QP6KwzAk5xI+pgGTYOAL3+6QPOBuu/eBrkaJ+ck4tHn/668KlBYEvTfKH9hgk3+3RcPCydeD3VWTecXszzDdxw0pZ7JFDP8Cc2blp9asiz5R34n1IzroNVAW+OeLbbR+brZQ/uUT99xXjxEXPVVjuKV+Dbucs5x3b1H2jGx2idwd/6+o/COVyBbXg/Lu0pXCt8AT8rnswpgI33A3G9h+Rn5vEG/O/1MewD15hG65GEPOjTnxem8wJbkurHPMyBbcgD26AWTVBarTEUy6zhWqqUM7D8QAA8LzNlAywVJGyp7Nhk8JGsAEdHR6iuqoCnv92B36svQf35bKg6kQplh3eCPCMMrqRugcvJUlrFe4Oh9GAEVGTHQe3pDLh37RQ8vlUGL548hIiICPB0t4d7ReMNH7ZEEpj2tPRNiA5ZSIOq5eHhAUqlEvRe2WsA0EaN1gO53keqq6s1eYlFa+HMvk+gfSCnO9fANCahh1UnPgA3FwcdWLVwDXV0dPSmiTLvBr4a1et2U1MTrF+/vld+gd7LoCZvov5+zUfoYX/BpZ11w0CWOFMvqLZkMpkuTauiGxbr8FKd2y0tLeDl5dVvnj/4LIOLWVPhRYUJ/8Gl+sKHlTXDIS7cekBYtXDz1FztqJlHjusGPu2ludXZ2QkxMTGM83USOXbs3LqY//Bh7av1uumSUOk3zUyNwnJ3dweFQtENfX5rN/DfdzU/FxYWAkG+zSKRyLAB4urLycnJHBWYQwIdHh4O7e3tXWRps7uBK9PpnxoaGgDlyzS/HGyD4O8+oEJt0OBSwhQ6NzcX4FGVbh9OsoTW1lbw8/MbMD0uC5c56G+3IGOskTEF6LNtIKOfyDbqAiMdig/rL02bKm/rIff+EuqrZqhf+SPj5EhKvSOspzN07JiggX2YslQfJE4rx3mJxeKh96KWvksikZgig+2QgpDxWaiWytFnI/pUHI1wVUKIkfL17mkKNxdRo+peFn4Wp8FpDWXXf/ywMAKAfSJyAAAAAElFTkSuQmCC";

                                    } else if(gender.equalsIgnoreCase("Mrs.")) {

                                        imgAvatar = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADwAAAA8CAYAAAA6/NlyAAAACXBIWXMAAAsTAAALEwEAmpwYAAAF0WlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNS42LWMxNDIgNzkuMTYwOTI0LCAyMDE3LzA3LzEzLTAxOjA2OjM5ICAgICAgICAiPiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdEV2dD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlRXZlbnQjIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4wLyIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgQ0MgMjAxOCAoV2luZG93cykiIHhtcDpDcmVhdGVEYXRlPSIyMDIwLTA5LTIzVDEzOjA2OjE5KzAyOjAwIiB4bXA6TWV0YWRhdGFEYXRlPSIyMDIwLTA5LTIzVDEzOjA2OjE5KzAyOjAwIiB4bXA6TW9kaWZ5RGF0ZT0iMjAyMC0wOS0yM1QxMzowNjoxOSswMjowMCIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDo2ODg5OTRiNC05MmE5LWQ1NGItYTJjMy1lMDNhZjVkOTcyOTAiIHhtcE1NOkRvY3VtZW50SUQ9ImFkb2JlOmRvY2lkOnBob3Rvc2hvcDpiN2NkN2I0NS0wY2FjLWExNDEtYmQ4NS05ZGMwZmFhMzZjNGYiIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDpmMTY3NjZmZS0yMzA3LTA4NDMtOGEwNC0yM2UzOTc5NzVhNDciIGRjOmZvcm1hdD0iaW1hZ2UvcG5nIiBwaG90b3Nob3A6Q29sb3JNb2RlPSIzIj4gPHhtcE1NOkhpc3Rvcnk+IDxyZGY6U2VxPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0iY3JlYXRlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDpmMTY3NjZmZS0yMzA3LTA4NDMtOGEwNC0yM2UzOTc5NzVhNDciIHN0RXZ0OndoZW49IjIwMjAtMDktMjNUMTM6MDY6MTkrMDI6MDAiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCBDQyAyMDE4IChXaW5kb3dzKSIvPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0ic2F2ZWQiIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6Njg4OTk0YjQtOTJhOS1kNTRiLWEyYzMtZTAzYWY1ZDk3MjkwIiBzdEV2dDp3aGVuPSIyMDIwLTA5LTIzVDEzOjA2OjE5KzAyOjAwIiBzdEV2dDpzb2Z0d2FyZUFnZW50PSJBZG9iZSBQaG90b3Nob3AgQ0MgMjAxOCAoV2luZG93cykiIHN0RXZ0OmNoYW5nZWQ9Ii8iLz4gPC9yZGY6U2VxPiA8L3htcE1NOkhpc3Rvcnk+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+A9DbvQAACVZJREFUaN7Vm/lTk9caxxn7Q+e205n7S2+nf8S93VxKbxG8Wq2FQEJYFJFVq9VSF4pcrIItQgJuiCwuiCA2iFZkS2QJBIIEGAXbuksVr2ICSNUrWq916Pee82ICMXlDzkmgbWaeGUjO8nzeszzPeZ7zenhM0ufTs/tekbZkzpc2ZyTJdIoimU7ZLtUpe2VNiiEiT5/LkPAd+Y2WoWVpHVrX48/wWdyR9UagLmOtVKfQUyBpkwI8ItQlbdC2ZG3b/vaHAw1sUc4mI1RNlHzGCykqpE3aNu3j9wdtzphDpmOr2yHFRp70FaRT+Ew9qH7Xm2TaqaYK1M6UV1EdpgRW2qxcKGtSPuBWWJuGwJObIS/9NwIrk4X/+aCJDkSXyR1ZnSKePN0RFsUCq1IQqlyOpdGfIHr2dMRM/7uNRM+ZgSXLJAjZsQIy9dcsIz1CdXI7aFxP9suC2WAZAc03CNuwCNGeb9uFFJPoD9/F4s1LIavfyrC2FUVUR7fABuuzXycNGlhggw7FI8pnBhPoixL10fuQqxJZoA1UV3eMLBNscH4cYjzfcQnWMtpe7yGoKJ4J2qWRZp3GQSUJiJn5lltgLdAfvAN5WRLT9ObeoJjWbEMaIv283AprloigOZA2pju/UbJuZKOmh203XpwUNimwZln0dSTT7u20yRp1KhjtbH0aorynTypw1NxZkGnTmey0U84JjwdF7edkwpolJGc1s0fmEJb6qTxeT0TI3CkBXhq+gFk3h743z0GAblYxs9h25szIQNRsS0R36S6cK9sN7Z5k7P0iEmv/5WlVblPAPCQHLhj7jjgxrK4oZRKZypnePKMbVPyl06Ab/efiWtV+PDpXJSo364tw/ngObmmLhf+zlodatSE/soHD7870tmdzq3mAQ9OinYJdM9cTd3RHHMLak7zV4VbthCpiOY6VimqbSAXv4T3yc/mEsLHEGfnhWDYzLJXGnC1Wba1cE8IXRBgfORHCMpzHvc+WBUwIrN6exAVrlh3RQZa21i+XcelJGcccDZ1Czwu8JvwTUdA475lo2ZfqEiyV4e5KnNq5ESs+eBcbwv14Q0V6S3TRlYDbOvl8G9Cv/OfhROo6DLaVuQw7Xr4/mo3E4I+5A4NCNFQIpfLC6rOgKUxD3e7NqFQkwFCoFHZZd0K+KIayLHzRsotvlAmrhxAL5qis7ii2v8nkpmBblBybZfOhXBKAo8lx6FEfcArGpFehKjMRO2ODBfu7dZGfUP/h2Qqbst91HGIHJqzMR0AqKa177Cp8ukCBzAgZcSRShF2Z2tOm3C3YtSwEJ9PiHcJSJ+SbEF9oyFrtUu3CpfJ8sv63Yv/aKBz56jO7dRL1u1nNU5GHkBFgBC5tL7SrgLFFZfm7qzwPLSU7rEZvotE1/31ZcxC1BekT1i00HGD1uto9aKqDFbi8w/E6pQpPmzYNZE9EPVnXLGt0wHAMr736F6FuQdp6h2VV5MGz7dTKXg8hv8MInNfm2D28WluIl14aBW4symQCHjQcx19fe1WoW6RMcGyf2/JZd+ohDx6TFKnbhnvdFQ6VuVCzHx2c3tX1hmI0l2x3/GC6TyJMl8lsmjx4bXBW214MT6L5cSQPu6uQeTqPyxZzTenxdrhQsxv3zpZPGWypOpvbDgtTmmfTGi9LYn0FczQVsNSeRwTPdSETSTctDrM0XqLmzEQ+OcJNBfCJresQPestIejAmX1s53I8LNKYLvjOq71m4L9nTzql9LXK3bh8Ygd+qsrBlfIsnC913myZox80GccHTBwPXtfSnAk0HxhaD6Q5ffIZbP0Wg/pReXDGufVPIyXmvgLL+YAF19KVwwMNm5ozDZtkH03qdN6zcizuLatM4T88uHo8pFkBsyIdjE6G03b51EHEzvjHaHx6vqdrx0NXAwChO1dYnYMfnLG/lp9c78DIk2FReXypSdyjignmykDYDQC4GuKhG1fkwn9aFBI72VD5dfAGXvz89tsI/nf7vGgdGsK1ZB98ZkBal+p6iMeVIJ4wyqljkUs69bqPZokC/HKlBb8O/IRn9414arqKxxe1omV76w5h1YdjKZzFCaHcN4Eoo1vCtKOx6XirEA81U/Q868q6vd1Ygi8XzLZqN3jPal5zVO22QDwVeckGm7jW57Nn4nLFXi7YPgK7YaG3TZvBeXF801nsjhfvnSuxZNqn77+NprwtBKLSadhWcvCnD8tuyjQlgutul8OLZjzASyM+Fg3VJvr64PxRJfq0hXjULQ5uai7BtYpsIRQr1lak1Nu9yTSedKn8cAJinttIe5IUMA+3GwrQsicehv1JuFC2DT1V2fhP7X5cr87BxePb0VmwCfqceAF6pddMh0F9lmk9YbqUJyFOU5g2yWsfL4StXIvAXBWyvr8F4wU9btUVoP3ARgK+3kY6D26CsakIvZc7kdx5E/Lcw1gSHUu8ONvLMREB3u5NiLNceaB3sahrGeXjjbDoOMgziiE5dg6+NUZB/NRGnOx7jMa++7j3Qy2GuyoFsBvqfFytyEKvZi8Z1cPClB76sQF1xodQ3Xxsqe9bcxPS4losSkgWHqLFlz6+0X1XHpy71JIB/4YjkFRp4f9t1zgFrSWyaQDq/ieC6PqG0H9BZ39Xvnga2jv3LGWD6vrttud/7AyC03MRWLrdvZdaxK4tBTTuhKRWC191ryjkeFnVetcCYRbDrTu4dO08eq524WLPRbTeNtmUoQ9qwvbVPUSXegRo891zbenFi2n+9WWkkxtOgZplRcugDYwzEt44wNSPpLYZAU07XL+YZr56KGnQGFgUMEsImZpiUKnn7tv9vtr0BBINe19+mhuGYH3h6+65XKrBy5IaUxEPdNH1YRuofT3Dwm8lvY9sfsu98pC5D6ob1dHtt2p9NaZ4vxrTCIsyawxDVkCVxrEpu7x5ENUvAC9vuev8qFJdiE6TemdaojEt9FWbHrBAp3TdRxWZquV3fsGq09ZA69t/RgV5CJXkt8TOn50fWaID1WVqXgGovfumr9qoYoGW15rgL7I2A06ZICXiPKxRRXWY8ncf/E6ZfPxqjK08a5tHaF+0z9/97RYytbz91KZqMs2euR2UtEnbpn384d5f8tcOvOGr6V9LRkJP5KkLI/mUtkHbom3+Kd5Sk5zFKxLNwHw/dX8SNRtklNrJaPUSkKHnQFSGhO/Ib6NlSFlSh9adLL3+D7WbcACSzpAWAAAAAElFTkSuQmCC";
                                    }
                              
                                } else if(imgAvatar.length() > 0 && !imgAvatar.contains(";base64,")) {

                                    imgAvatar = GlobalParm.getParm("FORM_UPLOADS_PATH") + formid + "/" + escapeCoteValue(results.value(primarykey)) + "/" + imgAvatar;
                                }


                                vhtm += "<a href=\"" + escapeCoteValue(imgAvatar) + "\" target='_blank' class=\"";

                                if(formType.equals("sign_up"))
                                    vhtm += "avatar rounded-circle overflow-hidden";

                                vhtm += "\">";

                                if(formType.equals("sign_up")){

                                    vhtm += "<img class=\"\" style=\"max-height:60px; max-width:60px\" alt=\"" + escapeCoteValue(results.value(selectedResultRs.value("db_column_name"))) + "\" src=\"" + escapeCoteValue(imgAvatar) + "\">";
                                
                                } else {

                                    vhtm += escapeCoteValue(results.value(selectedResultRs.value("db_column_name")));
                                }

                                vhtm += "</a>";

                            }else{

                                String savedValue = "";
                                if("textdate".equalsIgnoreCase(selectedResultRs.value("type"))){

                                    try{

                                        String dateVal = results.value(selectedResultRs.value("db_column_name"));
                                        String dateFormt = parseNull(selectedResultRs.value("date_format"));

                                        savedValue = escapeCoteValue(buildDateFormat(dateVal, dateFormt));

                                    } catch(Exception e){

                                        e.printStackTrace();
                                        savedValue = "";
                                    }
                                } else {

                                    savedValue = escapeCoteValue(results.value(selectedResultRs.value("db_column_name")));
                                }

                                //htm for non editable row
                                vhtm += "<div id='span_"+results.value(primarykey)+"_"+selectedResultRs.value("db_column_name")+"'>"+savedValue+"</div>";
                            }

                            //htm for editable row
                            String elementtriggers = parseNull(selectedResultRs.value("element_trigger"));
                            if(rsm.rs.Rows > 0 && rsm.next())//found in rule mapping
                            {
                                if("1".equals(parseNull(rsm.value("required")))) required = true;
                                else required = false;
                                elementtriggers = parseNull(rsm.value("element_trigger"));
                            }
                            String triggercls = "";
                            if(elementtriggers.length() > 0)
                            {
                                triggercls = getCssClassesForTriggers(elementtriggers);
                            }

                            String requiredCls = "";
                            String requiredHtm = "";
                            if(required)
                            {
                                requiredCls = results.value(primarykey)+"_required";
                                requiredHtm = "<span style='color:red;position:absolute;right:10px;top:5px;'>*</span>";
                            }
                            String datafilterattrs = " data-noe-html-form-id='inlinefrm_"+results.value(primarykey)+"' data-noe-fname='"+selectedResultRs.value("db_column_name")+"' data-noe-form-id='"+formid+"' data-noe-rule-id='"+results.value("rule_id")+"' data-noe-field-id='"+selectedResultRs.value("field_id")+"'  ";
                            if("radio".equalsIgnoreCase(selectedResultRs.value("type")) || "dropdown".equalsIgnoreCase(selectedResultRs.value("type"))  || "select".equalsIgnoreCase(selectedResultRs.value("type")))
                            {
                                String eleqry = parseNull(selectedResultRs.value("option_query"));
                                String eleopts = parseNull(selectedResultRs.value("options"));
                                if(rsm.rs.Rows > 0)
                                {
                                    eleqry = parseNull(rsm.value("option_query"));
                                    eleopts = parseNull(rsm.value("options"));
                                }
                                
                                htm += requiredHtm +  "<select "+datafilterattrs+" class='form-control "+triggercls+" "+requiredCls+" "+results.value(primarykey)+"_fields' id='"+results.value(primarykey)+"_"+selectedResultRs.value("db_column_name")+"' name='"+parseNull(selectedResultRs.value("db_column_name"))+"' >";
                                String opts = "";
                                String sval = parseNull(results.value(selectedResultRs.value("db_column_name")));
                                if(eleqry.length() > 0)
                                {
                                    if(eleqry.startsWith("select ")){

                                        Set _rs = Etn.execute(eleqry);
                                        while(_rs.next())
                                        {
                                            String _key = parseNull(_rs.value(0));
                                            String _val = _key;
                                            String selected = "";
                                            if(sval.equals(_key)) selected = "selected";
                                            opts += "<option "+selected+" value='"+escapeCoteValue(_key)+"'>"+escapeCoteValue(_val)+"</option>";
                                            if(_key.length() == 0) anyempty = true;
                                        }
                                    } else {

                                        if(eleqry.length() > 0){

                                            String[] pairToken = eleqry.split(",");
                                            String[] pairArr = null;

                                            for(String pair : pairToken){

                                                pairArr = pair.split(";");
                                                String selected = "";
                                                if(sval.equals(pairArr[0])) selected = "selected";
                                                opts += "<option "+selected+" value='"+escapeCoteValue(pairArr[0].trim())+"'>"+escapeCoteValue(pairArr[1])+"</option>";
                                                if(pairArr[0].trim().length() == 0) anyempty = true;
                                            }
                                        }
                                    }
                                }
                                else if(eleopts.length() > 0)
                                {

                                    try{

                                        optionsJson = new JSONObject(eleopts);
                                        optionTxtArray = optionsJson.getJSONArray("txt");
                                        String selected = "";
                                        
                                        for(int k=0; k < optionTxtArray.length(); k++){
                    
                                            selected = "";
                                            if(sval.equals(optionTxtArray.get(k))) selected = "selected";
                                            opts += "<option "+selected+" value='"+escapeCoteValue(optionTxtArray.get(k).toString())+"'>"+escapeCoteValue(optionTxtArray.get(k).toString())+"</option>";
                                            if(optionTxtArray.get(k).toString().length() == 0) anyempty = true;
                                        }
                                    }catch(JSONException je){
                                        je.printStackTrace();
                                    }catch(Exception e){
                                        e.printStackTrace();
                                    }
                                }
                                if(!anyempty) opts = "<option value=''>--------</option>" + opts;
                                htm += opts;

                                htm += "</select>";
                            }
                            else if("textdate".equalsIgnoreCase(selectedResultRs.value("type")) || "textdatetime".equalsIgnoreCase(selectedResultRs.value("type")) )
                            {
                                htm += requiredHtm +  "<input "+datafilterattrs+" readonly='readonly' class='form-control "+triggercls+" "+requiredCls+" "+results.value(primarykey)+"_fields "+selectedResultRs.value("type")+"' type='text' id='"+results.value(primarykey)+"_"+selectedResultRs.value("db_column_name")+"' name='"+selectedResultRs.value("db_column_name")+"' value='"+escapeCoteValue(parseNull(results.value(selectedResultRs.value("db_column_name"))))+"' ";
                                htm += "/>";
                            }
                            else if("texthidden".equalsIgnoreCase(selectedResultRs.value("type"))  )
                            {
                                htm += requiredHtm +  "<input "+datafilterattrs+" readonly='readonly' class='form-control "+triggercls+" "+requiredCls+" "+results.value(primarykey)+"_fields ' type='text' id='"+results.value(primarykey)+"_"+selectedResultRs.value("db_column_name")+"' name='"+selectedResultRs.value("db_column_name")+"' value='"+escapeCoteValue(parseNull(results.value(selectedResultRs.value("db_column_name"))))+"' ";
                                htm += "/>";
                            }
                            else if("autocomplete".equalsIgnoreCase(selectedResultRs.value("type")))
                            {
                                String autocompletechar = parseNull(selectedResultRs.value("autocomplete_char_after"));
                                htm += requiredHtm +  "<input data-noe-auto-char='"+autocompletechar+"' "+datafilterattrs+" class='noe_auto_complete form-control "+triggercls+" "+requiredCls+" "+results.value(primarykey)+"_fields "+selectedResultRs.value("type")+"' type='text' id='"+results.value(primarykey)+"_"+selectedResultRs.value("db_column_name")+"' name='"+selectedResultRs.value("db_column_name")+"' value='"+escapeCoteValue(parseNull(results.value(selectedResultRs.value("db_column_name"))))+"' ";
                                htm += "/>";
                            }
                            else if("texttextarea".equalsIgnoreCase(selectedResultRs.value("type")))
                            {
                                htm += requiredHtm +  "<input "+datafilterattrs+" class='form-control "+triggercls+" "+requiredCls+" "+results.value(primarykey)+"_fields' type='text' value='"+escapeCoteValue(parseNull(results.value(selectedResultRs.value("db_column_name"))))+"' ";
                                if(parseNull(selectedResultRs.value("maxlength")).length() > 0) htm += " maxlength='"+parseNull(selectedResultRs.value("maxlength"))+"' ";
                                
                                htm += " readonly  style='background-color: #eee;' onclick='pop_show_txt(this,\"" + results.value(primarykey)+"_"+selectedResultRs.value("db_column_name") + "\",\"" + parseNull(selectedResultRs.value("label")) + "\")' />";

                                htm += "<div id='" + results.value(primarykey)+"_"+selectedResultRs.value("db_column_name") + "_dialog' style='display: none;'></div> <textarea style='display: none;' " + datafilterattrs + "class='form-control "+triggercls+" "+requiredCls+" "+results.value(primarykey)+"_fields' id='"+results.value(primarykey)+"_"+selectedResultRs.value("db_column_name")+"' name='"+selectedResultRs.value("db_column_name")+"' >" + escapeCoteValue(parseNull(results.value(selectedResultRs.value("db_column_name")))) + "</textarea>";
                            }
                            else
                            {
                                String regexpattern = "";
                                if("textfield".equalsIgnoreCase(selectedResultRs.value("type"))) regexpattern = parseNull(selectedResultRs.value("regx_exp"));

                                htm += requiredHtm +  "<input "+regexpattern +" "+datafilterattrs+" class='form-control "+triggercls+" "+requiredCls+" "+results.value(primarykey)+"_fields' type='text' id='"+results.value(primarykey)+"_"+selectedResultRs.value("db_column_name")+"' name='"+selectedResultRs.value("db_column_name")+"' value='"+escapeCoteValue(parseNull(results.value(selectedResultRs.value("db_column_name"))))+"' ";
                                if(parseNull(selectedResultRs.value("maxlength")).length() > 0) htm += " maxlength='"+parseNull(selectedResultRs.value("maxlength"))+"' ";
                                htm += "/>";
                            }
                            htm += "</div>";
                            vhtm += htm+"</td>";
                        }//else not a rule field
                    }//else
                }//while
                 htm = "<div style='display: none;' id='sbmt_btn_" + results.value(primarykey) + "'>";
                htm += "<button type='button' class='btn btn-success' onclick='updateRow(\""+results.value(primarykey)+"\")'>Done</button>";
                htm += "<button style='margin-left:4px' type='button' class='btn btn-primary' onclick='cancelUpdate(\""+results.value(primarykey)+"\")'>Cancel</button>";
                htm += "<input type='hidden' name='"+primarykey+"' value='"+results.value(primarykey)+"' >";
                htm += "</div>";
                vhtm += "<td>";
                vhtm += "<button type='button' pw-id='" + results.value("post_work_id") + "' pk-id='"+results.value(primarykey)+"' ck-id='"+parseNull(results.value("clientUuid"))+"' rule-id='"+results.value("rule_id")+"' id='edit_btn_" + results.value(primarykey) + "' class='btn btn-primary btn-modal btn-sm view_form' role='button' data-toggle='modal' data-target='#view_form'><i data-feather='eye'></i></button> <button type='button' id='delete_btn_" + results.value(primarykey) + "'  class='btn btn-danger btn-sm' role='button' onclick='deleteReply(\""+results.value(primarykey)+"\",\""+parseNull(results.value("clientUuid"))+"\",\""+tablename+"\",\""+portaldb+"\")'><i data-feather='trash-2'></i></button>";

                if(formType.equalsIgnoreCase("sign_up")){

                    vhtm += "<button style='margin-left:4px' type='button' id='active_user_" + results.value(primarykey) + "' class='btn " + userStatusClass + " btn-sm' role='button' onclick='updateUserStatus(\""+login+"\",\"" + isUserActive + "\",\"" + portaldb + "\")'><i data-feather='" + isUserStatusLock + "'></i></button>";
                }

                com.etn.util.Logger.debug("common2.jsp","clientUuid:" + parseNull(results.value("clientUuid")));
                if(parseNull(results.value("clientUuid")).length()>0)
                {
                    vhtm += "<br><button style='margin-top:4px' type='button' role='reset password' class='btn btn-modal btn-primary reset-password-btn' data-uuid="+escape.cote(results.value("clientUuid"))+" data-login="+escape.cote(login)+" data-email="+escape.cote(email)+">Reset Password</button>";
                }

                vhtm += "</div>";
                htm += "</form></tr>";//</div>
                vhtm +=  htm + "</td>";
                responseHtml += vhtm;
            }
        }

        responseHtml += "</tbody>";
        responseHtml += "</table>";

        return responseHtml.toString();

    }

    org.json.JSONObject verifyClient(com.etn.beans.Contexte etn, javax.servlet.http.HttpServletRequest request, boolean formHasLoginField, String username, String email, String dbname, String siteId, String formType ) throws JSONException {

        if(formHasLoginField && username.length() == 0)
        {
            return new org.json.JSONObject("{\"status\":" + 1 + ",\"message\":\"" + libelle_msg(etn, request, "Login is not provided").replace("\"","\\\"") + "\"}");
        }
        else if(!formHasLoginField && email.length() == 0)
        {
            return new org.json.JSONObject("{\"status\":" + 2 + ",\"message\":\"" + libelle_msg(etn, request, "Email is not provided").replace("\"","\\\"") + "\"}");
        }
        
        //if not _etn_login field in form means we will use email as username as well
        if(!formHasLoginField) username = email;

        Set rs = etn.execute("select * from " + dbname + ".clients where site_id = "+escape.cote(siteId)+" and username = " + escape.cote(username));

        if(rs.rs.Rows > 0 && formType.equals("sign_up"))
        {
            if(formHasLoginField)
            {
                return new org.json.JSONObject("{\"status\":" + 3 + ",\"message\":\"" + libelle_msg(etn, request, "Login is already taken").replace("\"","\\\"") + "\"}");                 
            }
            else
            {
                return new org.json.JSONObject("{\"status\":" + 4 + ",\"message\":\"" + libelle_msg(etn, request, "Email is already registered with us").replace("\"","\\\"") + "\"}");                 
            }
        } 

        if(rs.rs.Rows == 0 && formType.equals("forgot_password"))
        {
            if(formHasLoginField)
            {
                return new org.json.JSONObject("{\"status\":" + 3 + ",\"message\":\"" + libelle_msg(etn, request, "Login is not registered").replace("\"","\\\"") + "\"}");                 
            }
            else
            {
                return new org.json.JSONObject("{\"status\":" + 4 + ",\"message\":\"" + libelle_msg(etn, request, "Email is not registered with us").replace("\"","\\\"") + "\"}");                 
            }            
        }

        return new org.json.JSONObject("{\"status\":" + 0 + ",\"message\":\"\"}");    
    }

    org.json.JSONObject verifyUserInCustomTable(com.etn.beans.Contexte etn, javax.servlet.http.HttpServletRequest request, boolean formHasLoginField, String username, String email, String formType, String tablename ) throws JSONException {

        if(formHasLoginField && username.length() == 0)
        {
            return new org.json.JSONObject("{\"status\":" + 1 + ",\"message\":\"" + libelle_msg(etn, request, "Login is not provided").replace("\"","\\\"") + "\"}");
        }
        else if(!formHasLoginField && email.length() == 0)
        {
            return new org.json.JSONObject("{\"status\":" + 2 + ",\"message\":\"" + libelle_msg(etn, request, "Email is not provided").replace("\"","\\\"") + "\"}");
        }
        
        String params = "";
        //if not _etn_login field in form means we will use email as username as well
        if(!formHasLoginField) {

            params = " _etn_email = " + escape.cote(email);
            username = email;
        
        } else { 

            params = " _etn_login = " + escape.cote(username);
        }

        Set rs = etn.execute("select * from " + tablename + " where " + params);

        if(rs.rs.Rows > 0 && formType.equals("sign_up"))
        {
            if(formHasLoginField)
            {
                return new org.json.JSONObject("{\"status\":" + 3 + ",\"message\":\"" + libelle_msg(etn, request, "Login is already taken").replace("\"","\\\"") + "\"}");                 
            }
            else
            {
                return new org.json.JSONObject("{\"status\":" + 4 + ",\"message\":\"" + libelle_msg(etn, request, "Email is already registered with us").replace("\"","\\\"") + "\"}");                 
            }
        } 

        return new org.json.JSONObject("{\"status\":" + 0 + ",\"message\":\"\"}");    
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

    String convertDateTimeToStandardFormat(String dateStr, String srcFormat){
        String retDate = dateStr;

        try{

            java.util.Date d = new java.util.Date(dateStr);

            java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat(srcFormat);

            retDate = formatter.format(d);

        }
        catch(Exception ex){
        ex.printStackTrace();
            //return same date
        }

        return retDate;
    }

    void updateVersionGame(com.etn.beans.Contexte Etn, String formId)
    {
        Set rs = Etn.execute("SELECT 1 FROM games_unpublished pf, games pfp WHERE pf.form_id = pfp.form_id AND pf.version = pfp.version AND pf.form_id = " + escape.cote(formId));
        if(rs.rs.Rows > 0){
            Etn.execute("UPDATE games_unpublished SET version = version + 1, updated_by="+escape.cote(""+Etn.getId())+", updated_on=NOW() where form_id= "+ escape.cote(formId));
        }
    }

    void updateVersionForm(com.etn.beans.Contexte Etn, String formId){

		//checking if its published then we will update version otherwise not
        Set rs = Etn.execute("SELECT 1 FROM process_forms_unpublished pf, process_forms pfp WHERE pf.form_id = pfp.form_id AND pf.version = pfp.version AND pf.form_id = " + escape.cote(formId));
		
        if(rs.rs.Rows > 0){
             Etn.executeCmd("UPDATE process_forms_unpublished SET version = version + 1 WHERE form_id = " + escape.cote(formId));       
             updateVersionGame(Etn,formId);
        }
    }

    String signUpFormQuery(com.etn.beans.Contexte Etn,Set selectedResultRs,String tableName,String portalDb,String testSiteUserParams,String siteId){
        HashMap<String,String> defaultColumns=new HashMap<String,String>();

        defaultColumns.put("_etn_login", "username");
        defaultColumns.put("_etn_email", "email");
        defaultColumns.put("_etn_first_name", "name");
        defaultColumns.put("_etn_last_name", "surname");
        defaultColumns.put("_etn_mobile_phone", "mobile_number");
        defaultColumns.put("_etn_civility", "civility");
        defaultColumns.put("_etn_avatar", "avatar");
        defaultColumns.put("created_on", "created_date");

        String query=" SELECT ";
        while(selectedResultRs.next()){
            query+=" COALESCE(";
            
            if(defaultColumns.get(selectedResultRs.value("db_column_name"))!=null)
                query+= "COALESCE("+selectedResultRs.value("db_column_name")+","+defaultColumns.get(selectedResultRs.value("db_column_name"))+"),'') ";
            else
                query+= selectedResultRs.value("db_column_name")+",'') "; 

            query +="as "+selectedResultRs.value("db_column_name")+",";
        }
        selectedResultRs.moveFirst();
        query+="COALESCE(last_login_on,'') as user_last_login, COALESCE(created_on,'') as created_on , COALESCE(client_uuid,'') AS clientUuid, rule_id , portalurl, "+tableName+"_id FROM "+tableName+" LEFT JOIN "+portalDb+".clients ON site_id = "+escape.cote(siteId)+" AND _etn_login = username UNION ";
        query+=" SELECT ";

        while(selectedResultRs.next()){
            if(defaultColumns.get(selectedResultRs.value("db_column_name"))!=null)
                query+= "COALESCE("+defaultColumns.get(selectedResultRs.value("db_column_name"))+",'') ";
            else
                query+= "'' "; 

            query +="as "+selectedResultRs.value("db_column_name")+",";
        }
        query+="COALESCE(last_login_on,'') as user_last_login, COALESCE("+defaultColumns.get("created_on")+",'') , COALESCE(client_uuid,'') AS clientUuid, '' , '', form_row_id FROM "+portalDb+".clients  WHERE COALESCE(form_row_id,0) = 0 AND site_id="+escape.cote(siteId);
        selectedResultRs.moveFirst();
        return query;
    }
%>