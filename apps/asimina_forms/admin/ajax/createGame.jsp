<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>

<%
	request.setCharacterEncoding("utf-8");
	response.setCharacterEncoding("utf-8");
%>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.util.Logger"%>
<%@ page import="java.util.LinkedHashMap,org.json.*,java.util.Enumeration,javax.servlet.ServletException, com.etn.beans.app.GlobalParm,javax.servlet.http.*, org.apache.poi.ss.formula.functions.Column"%>
<%@ page import="com.etn.asimina.data.LanguageFactory, com.etn.asimina.util.ActivityLog"%>
<%@ page import="java.util.List,java.util.Map,java.util.ArrayList,com.etn.util.ItsDate,java.text.SimpleDateFormat,java.util.Date" %>
<%@ page import="com.etn.asimina.beans.Language"%>


<%@ include file="../../common2.jsp" %>

<%!
    Boolean gameExists(com.etn.beans.Contexte etn,String gameName, String siteId)
    {   
        Set rs = etn.execute("SELECT * FROM games_unpublished WHERE NAME = "+escape.cote(gameName)+" AND is_deleted!='1' AND site_id="+escape.cote(siteId));
        if(rs != null && rs.rs.Rows > 0)
            return true;
        return false;
    }

    Map<String, String> getFieldMap(String dbColumnName, String name, String label, String value, String valueOtherLang, String type, String fileExtension, String allowNationalMode, String options, String optionOtherLang, String hrefCheckbox, String isDeletable, String useToSearch, String displayReplyForm, String displayOrderOfFields, String required){

		Map<String, String> fieldsMap = new HashMap<String, String>();
		
		fieldsMap.put("db_column_name", dbColumnName);
		fieldsMap.put("name", name);
		fieldsMap.put("label", label);
		fieldsMap.put("value", value);
		fieldsMap.put("value_other_lang", valueOtherLang);
		fieldsMap.put("type", type);
		fieldsMap.put("file_extension", fileExtension);
		fieldsMap.put("allow_national_mode", allowNationalMode);
		fieldsMap.put("options", options);
		fieldsMap.put("options_other_lang", optionOtherLang);
		fieldsMap.put("href_chckbx", hrefCheckbox);
		fieldsMap.put("is_deletable", isDeletable);
		fieldsMap.put("use_to_search", useToSearch);
		fieldsMap.put("display_reply_form", displayReplyForm);
		fieldsMap.put("display_order", displayOrderOfFields);
		fieldsMap.put("required", required);

		return fieldsMap;
	}

    int insertProcessForm(com.etn.beans.Contexte etn, String formId, String name, String tableName, String siteId, String formType){

		String query = "INSERT INTO " + com.etn.beans.app.GlobalParm.getParm("FORMS_DB") + ".process_forms_unpublished (form_id, process_name, table_name, site_id, variant, template, form_method, form_autocomplete, form_width, type) VALUES (" + escape.cote(formId) + "," + escape.cote(name) + "," + escape.cote(tableName) + "," + escape.cote(siteId+"") + "," + escape.cote("all") + "," + escape.cote("0") + "," + escape.cote("post") + "," + escape.cote("off") + "," + escape.cote("12") + "," + escape.cote(formType) + ")";
		return etn.executeCmd(query);
	}

	void insertProcessFormDescription(com.etn.beans.Contexte etn, String formId, String name, String langId, String title){

		etn.executeCmd("insert into " + com.etn.beans.app.GlobalParm.getParm("FORMS_DB") + ".process_form_descriptions_unpublished (form_id, langue_id, title) values (" + escape.cote(formId) + ", " + escape.cote(langId) + ", " + escape.cote(title) + ")");
	}

	void insertProcessFormField(List<Map<String, String>> fieldsList, Set langRs, String formId, com.etn.beans.Contexte etn) throws JSONException {

        String lineUuid = "";
        String fieldUuid = "";
		String fieldQuery = "";
		String fieldDespQuery = "";
		String fieldValue = "";
		String fieldOptions = "";

		JSONObject elementTriggerObject = new JSONObject();
		JSONArray elementTriggerValueArray = new JSONArray();
		JSONArray elementTriggerJSArray = new JSONArray();
		JSONArray elementTriggerEventArray = new JSONArray();

		for(int i=0; i < fieldsList.size(); i++){

	        lineUuid = UUID.randomUUID().toString();
	        fieldUuid = UUID.randomUUID().toString();

	        etn.executeCmd("INSERT INTO " + com.etn.beans.app.GlobalParm.getParm("FORMS_DB") + ".process_form_lines_unpublished (id, form_id, line_id, line_width, line_seq) VALUES (" + escape.cote(lineUuid) + ", " + escape.cote(formId) + ", " + escape.cote("line"+(i+1)) + ", " + escape.cote("12") + ", " + escape.cote((i+1)+"") + ")");
			
	        elementTriggerEventArray.put("");
	        elementTriggerValueArray.put("");
	        elementTriggerJSArray.put("");

			elementTriggerObject.put("event",elementTriggerEventArray);
			elementTriggerObject.put("query",elementTriggerValueArray);
			elementTriggerObject.put("js",elementTriggerJSArray);

	        fieldQuery = "INSERT INTO " + com.etn.beans.app.GlobalParm.getParm("FORMS_DB") + ".process_form_fields_unpublished( form_id, line_id, field_id, field_type, db_column_name, font_weight, color, name, autocomplete_char_after, element_trigger, type, file_extension, allow_national_mode, href_chckbx, is_deletable, required) VALUES (" + escape.cote(formId) + "," + escape.cote(lineUuid) + "," + escape.cote(fieldUuid) + "," + escape.cote("fs") + "," + escape.cote(fieldsList.get(i).get("db_column_name")) + "," + escape.cote("-1") + "," + escape.cote("#333333") + "," + escape.cote(fieldsList.get(i).get("name")) + "," + escape.cote("2") + "," + elementTriggerCote(elementTriggerObject.toString()) + "," + escape.cote(fieldsList.get(i).get("type")) + "," + escape.cote(fieldsList.get(i).get("file_extension")) + "," + escape.cote(fieldsList.get(i).get("allow_national_mode")) + "," + escape.cote(fieldsList.get(i).get("href_chckbx")) + "," + escape.cote(fieldsList.get(i).get("is_deletable")) + "," + escape.cote(fieldsList.get(i).get("required")) + ")";

	        int rid = etn.executeCmd(fieldQuery);

	        if(rid > 0){

		        langRs.moveFirst();
		        while(langRs.next()){

		        	if(langRs.value("langue_id").equals("1")){

		        		fieldValue = fieldsList.get(i).get("value");
		        		fieldOptions = fieldsList.get(i).get("options");

			        } else {

		        		fieldValue = fieldsList.get(i).get("value_other_lang");
		        		fieldOptions = fieldsList.get(i).get("options_other_lang");
				    }

		        	fieldDespQuery = "INSERT INTO " + GlobalParm.getParm("FORMS_DB") + ".process_form_field_descriptions_unpublished(form_id, field_id, langue_id, label, value, options) VALUES(" + escape.cote(formId) + "," + escape.cote(fieldUuid) + "," + escape.cote(langRs.value("langue_id")) + "," + escape.cote(fieldsList.get(i).get("label")) + "," + escape.cote(fieldValue) + "," + escape.cote(fieldOptions) + ")";
		        	etn.executeCmd(fieldDespQuery);
			    }

			    if(fieldsList.get(i).get("use_to_search").equals("1")){
				    etn.executeCmd("INSERT INTO " + GlobalParm.getParm("FORMS_DB") + ".form_search_fields_unpublished(form_id, field_id, display_order) VALUES (" + escape.cote(formId) + "," + escape.cote(fieldUuid) + "," + escape.cote(fieldsList.get(i).get("display_order")) + ")");
				}

			    if(fieldsList.get(i).get("display_reply_form").equals("1")){
				    etn.executeCmd("INSERT INTO " + GlobalParm.getParm("FORMS_DB") + ".form_result_fields_unpublished(form_id, field_id, display_order) VALUES (" + escape.cote(formId) + "," + escape.cote(fieldUuid) + "," + escape.cote(fieldsList.get(i).get("display_order")) + ")");
				}				
		    }
		}
	}

	void insertGamePrize(com.etn.beans.Contexte etn, String gameId, String cartRuleId,String prize,String quantity,String type, String siteId)
	{
		if(quantity.length() == 0) quantity = "1";
		if("prize".equalsIgnoreCase(type)) cartRuleId = "";
		else quantity = "1";
		if(Integer.parseInt(quantity) == 0) quantity = "1";
		etn.executeCmd("INSERT INTO game_prize_unpublished (id, game_uuid, cart_rule_id, prize, quantity, type, created_by) "+
				" VALUES ( uuid()," + escape.cote(gameId) + ", "+escape.cote(cartRuleId)+", "+escape.cote(prize)+", "+escape.cote(quantity)+", "+escape.cote(type)+"," + escape.cote(etn.getId()+"") + ") ");
	}

	String returnDBDateFormat(String datetime)
	{

		try{
            Date date1=new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").parse(datetime);  
            String newDateString;
            
            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
            Date d = sdf.parse(datetime);
            sdf.applyPattern("yyyy-MM-dd HH:mm:ss");
            newDateString = sdf.format(d);
            return newDateString;
        }catch(Exception e)
        {
            return null;
        }

	}

    int insertGame(com.etn.beans.Contexte etn, String gameId, String formId, String gameName, String multiple_times, String siteId, String win_type, String launch_date , String end_date , String canLose)
    {
        return etn.executeCmd("INSERT INTO games_unpublished (play_game_column, id, form_id, name, attempts_per_user , site_id, win_type, created_by, can_lose, launch_date, end_date) VALUES ('_etn_phone', "+ escape.cote(gameId) +','+escape.cote(formId)+','+escape.cote(gameName)+','+escape.cote(multiple_times)+','+escape.cote(siteId)+','+escape.cote(win_type)+ "," + escape.cote(etn.getId()+"")+","+escape.cote(canLose)+","+escape.cote(returnDBDateFormat(launch_date))+","+escape.cote(returnDBDateFormat(end_date))+")");
    }

    boolean createGame(String siteId, String gameName, String multiple_times, String win_type, javax.servlet.http.HttpServletRequest request, com.etn.beans.Contexte etn) throws JSONException 
	{
		String formId = UUID.randomUUID().toString();   
		String gameId = UUID.randomUUID().toString();   
		int gameAutoIncrementId = insertGame(etn, gameId, formId, gameName, multiple_times, siteId, win_type, parseNull(request.getParameter("launch_date")), parseNull(request.getParameter("end_date")),parseNull(request.getParameter("can_lose")));
		
        String tableName = "game_"+siteId+"_"+gameAutoIncrementId;
		Logger.debug("createGame.jsp","tableName="+tableName);
		
		Set rs = etn.execute("SELECT * FROM " + GlobalParm.getParm("FORMS_DB") + ".process_forms_unpublished WHERE type = " + escape.cote("simple") + " AND site_id = " + escape.cote(siteId) + " AND table_name = " + escape.cote(tableName));
		Logger.debug("createGame.jsp","Rows="+rs.rs.Rows);
		if(rs.rs.Rows == 0)
		{
				String [] cart_types = request.getParameterValues("cart_type");
				String [] coupons = request.getParameterValues("coupons");
				String [] others = request.getParameterValues("others");
				String [] quantities = request.getParameterValues("quantity");
				Logger.debug("createGame.jsp","Creating Game ::" + gameName + " for Site id :: " + siteId);
			
			System.out.println("cart_type"+cart_types);
			if(cart_types!=null){
				if(cart_types.length>0){
					Logger.debug("createGame.jsp","Inserting game prizes for " + gameName + " and Site id :: " + siteId);
					for(int i=0;i<cart_types.length;i++){
						if(parseNull(cart_types[i]).length()>0)
							insertGamePrize(etn, gameId, parseNull(coupons[i]), parseNull(others[i]) ,parseNull(quantities[i]), parseNull(cart_types[i]) , siteId);
					}
				}
			}

			int rid = insertProcessForm(etn, formId, gameName, tableName , siteId, "simple");
			
			if(rid > 0){

				Set langRs = etn.execute("select * from language order by langue_id");
				while(langRs.next())
				{
					insertProcessFormDescription(etn, formId, gameName, parseNull(langRs.value("langue_id")), "Game");
				}

				List<Map<String, String>> fieldsList = new ArrayList<Map<String, String>>();
				
				//fieldsList.add(getFieldMap("_etn_email", "email", "Email", "", "", "email", "", "", "{}", "{}", "0", "0", "1", "1", "5", "0"));
				fieldsList.add(getFieldMap("_etn_phone", "phone", "Phone", "", "", "tel", "", "", "{}", "{}", "0", "0", "1", "1", "5", "0"));
				fieldsList.add(getFieldMap("_etn_game_status", "game_status", "Game Status", "", "", "texthidden", "", "", "{}", "{}", "1", "0", "0", "0", "11", "0"));
				fieldsList.add(getFieldMap("_etn_prize_id", "prize_id", "Prize Id", "", "", "texthidden", "", "", "{}", "{}", "1", "0", "0", "0", "11", "0"));
				fieldsList.add(getFieldMap("_etn_prize", "prize", "Prize", "", "", "texthidden", "", "", "{}", "{}", "1", "0", "0", "0", "11", "0"));
				fieldsList.add(getFieldMap("_etn_coupons", "coupons", "Coupons", "", "", "texthidden", "", "", "{}", "{}", "1", "0", "0", "0", "11", "0"));
				fieldsList.add(getFieldMap("_etn_win_status", "win_status", "Win Status", "", "", "texthidden", "", "", "{}", "{}", "1", "0", "0", "0", "11", "0"));

				// creation Game form fields
				insertProcessFormField(fieldsList, langRs, formId, etn);
				Logger.debug("createGame.jsp","Created Game for Site id :: "+siteId);
				return true;
			}
		}
		else
		{
			Logger.debug("createGame.jsp","Table name "+tableName+" already exists for Site id :: "+siteId);
			//delete the row we just inserted
			etn.executeCmd("delete from games_unpublished where nid = " + escape.cote(""+gameAutoIncrementId));
		}
		return false;
	}
	
%>

<%
    JSONObject result = new JSONObject();

    String gameName = parseNull(request.getParameter("game_name"));
    String attempts_per_user = parseNull(request.getParameter("multiple_times"));
    String launch_date = parseNull(request.getParameter("launch_date"));
    String end_date = parseNull(request.getParameter("end_date"));
    String win_type = parseNull(request.getParameter("win_type"));
	
	String can_lose = parseNull(request.getParameter("can_lose"));
    String siteId = getSelectedSiteId(session);

    String err_code = "";
    String err_description = "";
    int status = 0;
    String query = "";

	Logger.debug("createGame.jsp","attempts_per_user=" + attempts_per_user);
	Logger.debug("createGame.jsp","launch_date=" + launch_date);
	Logger.debug("createGame.jsp","end_date=" + end_date);
	Logger.debug("createGame.jsp","gameName=" + gameName);
	Logger.debug("createGame.jsp","win_type=" + win_type);
	Logger.debug("createGame.jsp","can_lose=" + can_lose);

	

    if(!win_type.equals("Draw") && !win_type.equals("Instant")){
		
        err_code = "invalid_win_type";
        if(win_type.length() > 0)
            err_description = "Win type is invalid";
        else
            err_description = "Win type is not selected";
        status = 10;
    }

    if(!(Integer.parseInt(attempts_per_user) >= 0)){
        err_code = "invalid_times_play";
        err_description = "times play cannot be negative";
        status = 10;
    }
	if(status == 0){
        if(gameName.length()>0 ){
            int rid = 0;
            if(!gameExists(Etn,gameName,siteId)){
				Logger.debug("createGame.jsp","game Creation process started");
                if(!createGame(siteId, gameName, attempts_per_user, win_type,request, Etn)){
					err_code = "game_already_exists";
					err_description = "Game "+gameName+" already exists";
					status = 20;	
				}
            }
            else
            {
                err_code = "game_already_exists";
                err_description = "Game "+gameName+" already exists";
                status = 20; 
            }        
        }
        else{
			Logger.error("createGame.jsp","Game name is empty");
            err_code = "game_name_is_empty";
            err_description = "Game Name is Empty";
            status = 30;
        }
	}

    if(status != 0)
    {
        result.put("err_code",err_code);
        result.put("err_description",err_description);
        result.put("status",status);
    }
	else{
		result.put("msg","New Game created");
        result.put("status",status);		
	}
	out.write(result.toString());
%>