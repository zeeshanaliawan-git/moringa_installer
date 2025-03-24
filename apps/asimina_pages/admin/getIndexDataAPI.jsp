<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set,  com.etn.pages.PagesUtil, com.etn.pages.PagesGenerator,com.etn.pages.TemplateDataGenerator, org.json.JSONObject"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="pagesUtil.jsp"%>
<%!
     JSONObject getFieldsLinearJSON(JSONObject obj){
         JSONObject retObj = new JSONObject();

         for (String key : obj.keySet()) {
            Object curVal = obj.get(key);
            boolean isSection = false;

            if(curVal instanceof JSONObject){
                //its a section
                JSONObject sectionFields = getFieldsLinearJSON((JSONObject) curVal);
                for(String secKey : sectionFields.keySet()){
                    putValueInLinearJSON(retObj, secKey, sectionFields.get(secKey));
                }
            }
            else if(curVal instanceof JSONArray){
                for(Object arrayItem : (JSONArray)curVal ){
                    if(arrayItem instanceof JSONObject){
                        //its a section
                        JSONObject sectionFields = getFieldsLinearJSON((JSONObject) arrayItem);
                        for(String secKey : sectionFields.keySet()){
                            putValueInLinearJSON(retObj, secKey, sectionFields.get(secKey));
                            // retObj.put(secKey, sectionFields.get(secKey));
                        }
                    }
                    else{
                        putValueInLinearJSON(retObj, key, arrayItem);
                    }
                }
            }
            else {
                putValueInLinearJSON(retObj, key, curVal);
            }
         }

         return retObj;
     }

     void putValueInLinearJSON(JSONObject obj, String key, Object val){
        Object targetVal = obj.opt(key);
        if(targetVal == null){
            obj.put(key,val);
        }
        else if(targetVal instanceof JSONArray){
            //target is array, append value to it
            ((JSONArray)targetVal).put(val);
        }
        else{
            // key already exist
            //convert value to array , append old value then new value
            JSONArray valList = new JSONArray();
            valList.put(targetVal).put(val);
            obj.put(key, valList);
        }
     }


%>
<%
    int STATUS_SUCCESS = 1, STATUS_ERROR = 0;

    int status = STATUS_ERROR;
    String message = "";
    JSONObject dataObj = new JSONObject();
    try{
        String lang = parseNull(request.getParameter("lang"));
        String siteId = parseNull(request.getParameter("siteId"));
        String contentUuid = parseNull(request.getParameter("contentId"));

		Set rsLang = Etn.execute("select langue_id from language where langue_code = "+escape.cote(lang));
		if(rsLang.next()){
		    String q = "SELECT sc.id, sc.name, sc.template_id, scd.content_data as template_data "
		    + " FROM structured_contents_published sc "
		    + " JOIN structured_contents_details_published scd ON sc.id = scd.content_id"
		    + " WHERE sc.site_id = " + escape.cote(siteId)
		    + " AND sc.uuid = " + escape.cote(contentUuid)
		    + " AND scd.langue_id = " + escape.cote(rsLang.value("langue_id"));
		    Logger.debug("## GET INDEXED " + q);
			Set rs = Etn.execute(q);
			if(rs.next())
			{
			    String templateId = rs.value("template_id");
			    String templateData = PagesUtil.decodeJSONStringDB(rs.value("template_data"));
			    JSONObject templateDataJson = new JSONObject(templateData);
				PagesGenerator pagesGen = new PagesGenerator(Etn);
				TemplateDataGenerator dataGenerator = pagesGen.getTemplateDataGenerator(siteId);
				dataGenerator.setIndexedDataOnly(true);
				String CATALOG_DB = GlobalParm.getParm("CATALOG_DB");
				LinkedHashMap<String, String> tagsHM = PagesUtil.getAllTags(Etn, siteId, CATALOG_DB);

				HashMap<String,Object> dataMap = dataGenerator.getBlocTemplateDataMap(templateId, templateDataJson, tagsHM, rsLang.value("langue_id"));
				JSONObject srcJson = new JSONObject(dataMap);
				//JSONObject dataJson = getFieldsLinearJSON(srcJson);

				// dataObj.put("src_data",srcJson);
				dataObj.put("content_data",srcJson);

				status = STATUS_SUCCESS;
			}
		}
    }
    catch(Exception ex){
        message = ex.getMessage();
        ex.printStackTrace();
    }

    JSONObject jsonResponse = new JSONObject()
        .put("status",status)
        .put("message",message)
        .put("data",dataObj);
    out.write(jsonResponse.toString());
%>