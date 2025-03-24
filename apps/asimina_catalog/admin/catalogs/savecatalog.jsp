<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, java.util.*"%>
<%@ page import="com.etn.asimina.util.*"%>
<%@ page import="com.etn.asimina.data.LanguageFactory"%>
<%@ page import="com.etn.asimina.beans.Language"%>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload"%>
<%@ page import="com.etn.beans.app.GlobalParm"%>
<%@ include file="/WEB-INF/include/constants.jsp"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%!

    String decodeCKEditorValue(String str){
        if(str != null){
            return str.replace("_etnipt_=","src=").replace("_etnhrf_=","href=").replace("_etnstl_=","style=");
        }
        else{
            return str;
        }
    }

	void saveDescriptions(List<Language> langsList, String siteid, String id, boolean isNew, ParseFormRequest formRequest, com.etn.beans.Contexte Etn)
	{
		String defaultPagePath = "";
		if(isNew)
		{
			//get newly inserted catalog
			Set rs = Etn.execute("Select * from catalogs where id = " + escape.cote(id));
			rs.next();

			defaultPagePath = "catalogs/" + UrlHelper.removeSpecialCharacters(UrlHelper.removeAccents(rs.value("name")));
		}

		for(Language lang : langsList)
		{
			String langId = lang.getLanguageId();

			String pagePath = parseNull(formRequest.getParameter("cat_desc_page_path_lang_" + langId));
			String canonicalUrl = parseNull(formRequest.getParameter("cat_desc_canonical_url_lang_" + langId));
			String folderName = parseNull(formRequest.getParameter("cat_desc_folder_name_lang_" + langId));
			String pageTemplateId = parseNull(formRequest.getParameter("cat_desc_page_template_id_lang_" + langId));

			String topBannerOpentype = parseNull(formRequest.getParameter("lang_"+langId+"_top_banner_path_opentype"));
			String bottomBannerOpentype = parseNull(formRequest.getParameter("lang_"+langId+"_bottom_banner_path_opentype"));

			//when inserting new catalog give a default path
			if(isNew && pagePath.length() == 0)
			{
				pagePath = defaultPagePath;

				//check if the default page path we created is unique across the site for the language ... we assume adding the -c<ID> will make it unique
				if(!UrlHelper.isUrlUnique(Etn, siteid, lang.getCode(), "catalog", id, pagePath)) pagePath += "-c" + id;
			}
			String query = "insert into catalog_descriptions (catalog_id, langue_id, page_path, canonical_url, folder_name, top_banner_path_opentype, bottom_banner_path_opentype, page_template_id) values ("
				+escape.cote(id)+", "+escape.cote(lang.getLanguageId())+", "+escape.cote(pagePath)
				+", "+escape.cote(canonicalUrl)+", "+escape.cote(folderName)+", "+escape.cote(topBannerOpentype)
				+", "+escape.cote(bottomBannerOpentype)
				+", "+escape.cote(pageTemplateId)
				+") on duplicate key update page_path=VALUES(page_path) ,canonical_url=VALUES(canonical_url) ,folder_name=VALUES(folder_name) ,top_banner_path_opentype=VALUES(top_banner_path_opentype) ,bottom_banner_path_opentype=VALUES(bottom_banner_path_opentype), page_template_id=VALUES(page_template_id) ";
			Logger.info(query);
			Etn.executeCmd(query);
		}
	}

    void saveAttributes(String id, boolean isNew, ParseFormRequest formRequest, com.etn.beans.Contexte Etn)
	{
        String attribsDeleted = parseNull(formRequest.getParameter("attribute_deleted"));
        String attribValuesDeleted = parseNull(formRequest.getParameter("attribute_values_deleted"));

        String[] attribIds = formRequest.getParameterValues("attribute_id");
        String[] attribTypeList = formRequest.getParameterValues("attribute_type");
        String[] attribNames = formRequest.getParameterValues("attribute_name");
        String[] attribVisibleToList = formRequest.getParameterValues("attribute_visible_to");
        String[] attribValueTypeList = formRequest.getParameterValues("attribute_value_type");
        String[] attribIsSearchableList = formRequest.getParameterValues("attribute_is_searchable");
        //delete attributes
        if(id.length() > 0 && attribsDeleted.length() > 0 ){
            String[] deletedIds = attribsDeleted.split(",");

            for(String deletedId : deletedIds){
                deletedId = deletedId.trim();
                if(parseInt(deletedId) > 0 ){
                    //TODO check if any attrib value is used(referenced) in any product
                    //then "do not" delete it

                    Etn.executeCmd("DELETE FROM catalog_attribute_values WHERE cat_attrib_id = "+ escape.cote(deletedId));
                    Etn.executeCmd("DELETE FROM catalog_attributes WHERE cat_attrib_id = "+ escape.cote(deletedId) + " AND catalog_id = " + escape.cote(id));
                }
            }
        }
        //delete attribute values
        if(id.length() > 0 && attribValuesDeleted.length() > 0 ){
            String[] deletedIds = attribValuesDeleted.split(",");

            for(String deletedId : deletedIds){
                deletedId = deletedId.trim();
                if(parseInt(deletedId) > 0 ){
                    //TODO check if any attrib value is used(referenced) in any product
                    //then "do not" delete it
                    Etn.executeCmd("DELETE FROM catalog_attribute_values WHERE id = "+ escape.cote(deletedId));
                }
            }
        }

        if(isNew){
            String catalogType = parseNull(formRequest.getParameter("catalog_type"));
            if("device".equals(catalogType) || "accessory".equals(catalogType)){
                //for device / accessory type
                //add fixed attributes  Color and Storage

                String q = "INSERT INTO catalog_attributes (catalog_id, name , visible_to, value_type, type,sort_order, is_fixed) VALUES ("
                    + escape.cote(id) +", 'Color' , 'all', 'color', 'selection', '0', '1' ) , ("
                    + escape.cote(id) +", 'Storage' , 'all', 'text', 'selection', '0', '1' ) ";
                Etn.execute(q);
            }
        }

        //insert / update new attributes
        if( attribIds.length  == attribNames.length &&  attribIds.length  == attribVisibleToList.length
             &&  attribIds.length  == attribTypeList.length &&  attribIds.length  == attribIsSearchableList.length  ){
            for(int i=0; i<attribIds.length; i++){
                String attribId = parseNull(attribIds[i]);
                String attribName = parseNull(attribNames[i]);
                String attribVisibleTo =  parseNull(attribVisibleToList[i]);
                String attribValueType = parseNull(attribValueTypeList[i]);
                String attribType = parseNull(attribTypeList[i]);
                String attribIsSearchable = "1".equals(parseNull(attribIsSearchableList[i]))?"1":"0";

                int newAttribId = 0;
                boolean isValidAttrib = false;
                if(parseInt(attribId) > 0){
                    //update
                    String q = "UPDATE catalog_attributes SET sort_order = "+ i
                                        + " , name = "+escape.cote(attribName)
                                        + " , visible_to = "+escape.cote(attribVisibleTo)
                                        + " , value_type = "+escape.cote(attribValueType)
                                        + " , type = " + escape.cote(attribType)
                                        + " , is_searchable = " + escape.cote(attribIsSearchable)
                                        + " WHERE cat_attrib_id = "+ escape.cote(attribId)
                                        + " AND catalog_id = " + escape.cote(id);
                    Etn.executeCmd(q);
                    isValidAttrib = true;
                }
                else if(attribName.length() > 0){
                    //insert
                    String q = "INSERT INTO catalog_attributes (catalog_id, name , visible_to, value_type, sort_order, type, is_searchable) VALUES ("
                                        + escape.cote(id) +"," + escape.cote(attribName) +"," + escape.cote(attribVisibleTo) + "," + escape.cote(attribValueType) + "," + i +"," + escape.cote(attribType)+"," + escape.cote(attribIsSearchable)+ ") ";
                    newAttribId = Etn.executeCmd(q);
                    isValidAttrib = true;
                }


                if(!isValidAttrib){
                    continue; //skip attrib values processing
                }

                String[] attribValueIdList = formRequest.getParameterValues("attribute_value_id_" + attribId);
                String[] attribValueList = formRequest.getParameterValues("attribute_value_" + attribId);
                String[] attribSmallTextList = formRequest.getParameterValues("attribute_small_text_" + attribId);
                String[] attribColorList = formRequest.getParameterValues("attribute_color_" + attribId);

                if( attribValueIdList != null
                    && attribValueIdList.length == attribValueList.length
                    && attribValueIdList.length == attribSmallTextList.length
                    && attribValueIdList.length == attribColorList.length
                    ) {

                    if(newAttribId > 0){
                        attribId = "" + newAttribId;
                    }

                    for(int j=0; j<attribValueIdList.length; j++){
                        String attribValueId = parseNull(attribValueIdList[j]);
                        String attribValue = parseNull(attribValueList[j]);
                        String attribSmallText = parseNull(attribSmallTextList[j]);
                        String attribColor = parseNull(attribColorList[j]);
                        int sortOrder = j;
                        if(parseInt(attribValueId) > 0){
                            //update
                            String q = "UPDATE catalog_attribute_values SET sort_order = " + sortOrder
                                                + " , attribute_value = " + escape.cote(attribValue)
                                                + " , small_text = " + escape.cote(attribSmallText)
                                                + " , color = " + escape.cote(attribColor)
                                                + " WHERE id = "+ escape.cote(attribValueId)
                                                + "     AND cat_attrib_id = " + escape.cote(attribId);
                            Etn.executeCmd(q);
                        }
                        else if(attribValue.length() > 0){
                            //insert
                            String q = "INSERT INTO catalog_attribute_values (cat_attrib_id , attribute_value, small_text, color , sort_order) VALUES ("
                                        + escape.cote(attribId) +"," + escape.cote(attribValue) + ","
                                        + escape.cote(attribSmallText) + "," + escape.cote(attribColor) + ","
                                        + sortOrder + ") ";
                            Etn.executeCmd(q);
                        }

                    }

                }

            }

        }
    }

    void saveEssentialBlocks(List<Language> langsList, String id, ParseFormRequest formRequest, com.etn.beans.Contexte Etn){

        CatalogEssentialsImageHelper imageHelper = new CatalogEssentialsImageHelper(id);
        String catalogName = parseNull(formRequest.getParameter("name"));

        Etn.executeCmd("DELETE FROM catalog_essential_blocks WHERE catalog_id = " + escape.cote(id));
        
        for(Language lang : langsList){


            String [] blockTexts = formRequest.getParameterValues("description_essential_block_text_lang_" + lang.getLanguageId());
            // String [] imageDatas = formRequest.getParameterValues("description_essential_block_image_lang_" + lang.getLanguageId() + "Data");
            String [] imageFileNames = formRequest.getParameterValues("description_essential_block_image_lang_" + lang.getLanguageId() + "Name");
            String [] imageLabels = formRequest.getParameterValues("description_essential_block_image_lang_" + lang.getLanguageId() + "Label");

            if(UIHelper.areListsValid(blockTexts,imageFileNames,imageLabels)){
                for(int i=0; i < blockTexts.length; i++){
                    // String fileName = catalogName + "_essentials_" + lang.getCode() + "_" + i;
                    // fileName = getAsiminaFileName(fileName,imageFileNames[i]);
                    // imageHelper.saveBase64(imageDatas[i],fileName);
                    Etn.executeCmd("insert into catalog_essential_blocks (catalog_id,langue_id,block_text,file_name,actual_file_name,image_label,order_seq) values ("
                                    + escape.cote(id) + "," + escape.cote(lang.getLanguageId())
                                    + "," + escape.cote(blockTexts[i])
                                    + "," + escape.cote(imageFileNames[i])
                                    + "," + escape.cote(imageFileNames[i])
                                    + "," + escape.cote(imageLabels[i])
                                    + "," + escape.cote(String.valueOf(i+1))
                                    + ")" );
                }
            }
        }
    }

%>
<%
    try{

        if(ServletFileUpload.isMultipartContent(request)){
            ParseFormRequest formRequest = new ParseFormRequest(this);
            formRequest.parse(request);

            if(!formRequest.areFilesValid()){
                throw new Exception("ParseFormRequest : Files not valid.");
            }

            //to bypass cross site scripting filter
            //ckeditor field values are encoded
            //decode values here
            Map<String,List<String>> paramMap = formRequest.getParameterMap();
            for(String paramName : paramMap.keySet()){
                List<String> paramValues = paramMap.get(paramName);
                for(int i=0; i<paramValues.size(); i++){
                    String paramValue = paramValues.get(i);
                    paramValues.set(i,decodeCKEditorValue(paramValue));
                }
            }



            String selectedsiteid = getSelectedSiteId(session);

            List<Language> langsList= getLangs(Etn, selectedsiteid);
            String id = parseNull(formRequest.getParameter("id"));
            
            String pid = ""+Etn.getId();
            boolean isNew = false;

            if(id.length() == 0)
            {
                String cols = "site_id, created_by,updated_by,updated_on";
                String vals = escape.cote(selectedsiteid)+","+escape.cote(pid)+","+escape.cote(pid)+",now()";

                for(String parameter : formRequest.getParameterMap().keySet())
                {
                    if("id".equals(parameter) || "ignore".equals(parameter)
                        || parameter.startsWith("attribute_")
                        || parameter.startsWith("description_essential_block")
                        || parameter.startsWith("cat_desc_")
                        || parameter.endsWith("_top_banner_path_opentype")
                        || parameter.endsWith("_bottom_banner_path_opentype") ) continue;

                    cols += "," + parameter;
                    vals += "," + escape.cote(formRequest.getParameter(parameter));
                }
                id = "" + Etn.executeCmd("insert into catalogs ("+cols+") values ("+vals+")");
		        isNew = true;
            }
            else
            {
                String q = "update catalogs set version = version + 1, updated_on = now(), updated_by = " + escape.cote(pid);
                for(String parameter : formRequest.getParameterMap().keySet())
                {
                    if("id".equals(parameter) || "ignore".equals(parameter)
                        || parameter.startsWith("attribute_")
                        || parameter.startsWith("description_essential_block")
                        || parameter.startsWith("cat_desc_")
                        || parameter.endsWith("_top_banner_path_opentype")
                        || parameter.endsWith("_bottom_banner_path_opentype") ) continue;

                    q += ", " + parameter + " = " + escape.cote(formRequest.getParameter(parameter));
                }

                String [] checkBoxFieldCols = {"topban_product_list", "topban_product_detail", "topban_hub",
                     "bottomban_product_list", "bottomban_product_detail", "bottomban_hub"};
                for(String curCol : checkBoxFieldCols){
                    if( null == formRequest.getParameter(curCol) ){
                       q += ", " +curCol+ "= 0";
                    }
                }
                q += " where id = " + escape.cote(id);
                Etn.executeCmd(q);
                
            }


            saveAttributes(id, isNew, formRequest, Etn);

            saveEssentialBlocks(langsList, id, formRequest, Etn);

            saveDescriptions(langsList, selectedsiteid, id, isNew, formRequest, Etn);

            String saveMsg = "";
            if(isNew){
            	saveMsg = "Catalog saved";
                ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),id,"CREATED","Catalog",parseNull(formRequest.getParameter("name")),selectedsiteid);
            }
            else{
            	saveMsg = "Modifications saved";
                ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),id,"UPDATED","Catalog",parseNull(formRequest.getParameter("name")),selectedsiteid);
            }
            session.setAttribute("CATALOG_SAVE_MSG",saveMsg);

			Etn.executeCmd("update "+GlobalParm.getParm("PREPROD_PORTAL_DB")+".cache_tasks set status = 9 where status = 0 and task = 'generate' and site_id = "+escape.cote(selectedsiteid)+" and content_type = 'catalog' and content_id = "+escape.cote(id));
			Etn.executeCmd("insert into "+GlobalParm.getParm("PREPROD_PORTAL_DB")+".cache_tasks (site_id, content_type, content_id, task) "+
				" values("+escape.cote(selectedsiteid)+", 'catalog', "+escape.cote(id)+", 'generate') ");														
			Etn.execute("select semfree("+escape.cote(GlobalParm.getParm("PORTAL_ENG_SEMA"))+")");

            response.setStatus(javax.servlet.http.HttpServletResponse.SC_MOVED_TEMPORARILY);
            response.setHeader("Location", "catalog.jsp?id="+id);

        }

    }
    catch(Exception ex){
        ex.printStackTrace();
        response.setStatus(javax.servlet.http.HttpServletResponse.SC_MOVED_TEMPORARILY);
        response.setHeader("Location", "catalogs.jsp");
    }

%>
<%


%>
