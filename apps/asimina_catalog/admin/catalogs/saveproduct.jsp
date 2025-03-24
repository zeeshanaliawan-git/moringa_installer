<%-- Reviewed By Awais --%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, java.util.*"%>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload"%>
<%@ page import="com.etn.asimina.util.*"%>
<%@ page import="com.etn.asimina.data.LanguageFactory"%>
<%@ page import="com.etn.asimina.beans.Language"%>
<%@ page import="com.etn.util.Logger"%>
<%@ page import="com.etn.beans.Contexte"%>
<%@ page import="javax.xml.bind.DatatypeConverter"%>
<%@ page import="com.etn.beans.app.GlobalParm"%>
<%@ page import="java.io.FileOutputStream"%>
<%@ page import="java.nio.file.Files"%>
<%@ page import="java.nio.file.Path"%>
<%@ page import="java.nio.file.Paths"%>
<%@ page import="com.etn.asimina.beans.KeyValuePair"%>

<%@ include file="../../WEB-INF/include/constants.jsp"%>
<%@ include file="../../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../../WEB-INF/include/imager.jsp"%>
<%!
	void findAllParentFolders(Contexte Etn, String folderId, List<String> folderIds)
	{		
		Set rs = Etn.execute("select * from products_folders where id = "+escape.cote(folderId));
		if(rs.next())
		{
			folderIds.add(rs.value("uuid"));
			int parentFolderId = 0;
			try {
				parentFolderId = Integer.parseInt(rs.value("parent_folder_id"));
			} catch (Exception e) {}
			if(parentFolderId > 0)
			{
				findAllParentFolders(Etn, ""+parentFolderId, folderIds);
			}
		}
	}
	
	void checkProductViewsUsage(Contexte Etn, String siteid, String productId, boolean isNew)
	{
		Logger.info("saveproduct.jsp", "in checkProductViewsUsage");
		Set rs = Etn.execute("select p.*, c.catalog_uuid from products p, catalogs c where c.id = p.catalog_id and p.id = "+escape.cote(productId));
		if(rs.rs.Rows == 0) return;
		rs.next();
		List<String> freemarkerPageIds = new ArrayList<>();			
		List<String> structuredContentIds = new ArrayList<>();			
		if(isNew)
		{
			List<String> folderIds = new ArrayList<>();
			folderIds.add(rs.value("catalog_uuid"));
			if(parseNull(rs.value("folder_id")).length() > 0) 
			{
				findAllParentFolders(Etn, parseNull(rs.value("folder_id")), folderIds);
			}
			String inclause = "";
			for(int i=0;i<folderIds.size();i++)
			{
				if(i>0) inclause += ",";
				inclause += escape.cote(folderIds.get(i));
			}
			Logger.info("saveproduct.jsp", "select d.view_query, p.parent_page_id, p.type as page_type "+
							" join " + GlobalParm.getParm("PAGES_DB")+".products_view_bloc_criteria c "+
							" join "+GlobalParm.getParm("PAGES_DB")+".products_view_bloc_data d on c.data_id = d.id and d.site_id = "+escape.cote(siteid)+" and for_prod_site = 0 "+
							" join "+GlobalParm.getParm("PAGES_DB")+".pages p on p.id = d.page_id "+
							" where c.cid in ("+inclause+")");
							
			Set rsP = Etn.execute("select distinct d.view_query, p.parent_page_id, p.type as page_type "+
							" from " + GlobalParm.getParm("PAGES_DB")+".products_view_bloc_criteria c "+
							" join "+GlobalParm.getParm("PAGES_DB")+".products_view_bloc_data d on c.data_id = d.id and d.site_id = "+escape.cote(siteid)+" and for_prod_site = 0 "+
							" join "+GlobalParm.getParm("PAGES_DB")+".pages p on p.id = d.page_id "+
							" where c.cid in ("+inclause+")");
							
			while(rsP.next())
			{
				String qry = rsP.value("view_query");
				Set rsQ = Etn.execute(qry);
				while(rsQ.next())
				{
					//from PagesGenerator.java we always save the query in db with first column as page ID ... make sure its always like that otherwise we are in trouble
					String qryProductId = rsQ.value(0);
					if(qryProductId.equals(productId))
					{
						//we got the new productId in the results of the query of view which means this page must be marked for regenerate
						if("freemarker".equals(rsP.value("page_type")) && freemarkerPageIds.contains(rsP.value("parent_page_id")) == false) freemarkerPageIds.add(rsP.value("parent_page_id"));
						else if("structured".equals(rsP.value("page_type")) && structuredContentIds.contains(rsP.value("parent_page_id")) == false) structuredContentIds.add(rsP.value("parent_page_id"));
						break;
					}
				}
			}			
		}
		else
		{
			Logger.info("saveproduct.jsp","select distinct p.parent_page_id, p.type as page_type "+
					" from " + GlobalParm.getParm("PAGES_DB")+".products_view_bloc_results r "+
					" join " + GlobalParm.getParm("PAGES_DB")+".products_view_bloc_data d on d.id = r.data_id and d.site_id = "+escape.cote(siteid)+" and d.for_prod_site = 0 "+
					" join " + GlobalParm.getParm("PAGES_DB")+".pages p on p.id = d.page_id "+
					" where r.product_id = "+escape.cote(productId)); 
										
			Set rsP = Etn.execute("select distinct p.parent_page_id, p.type as page_type "+
					" from " + GlobalParm.getParm("PAGES_DB")+".products_view_bloc_results r "+
					" join " + GlobalParm.getParm("PAGES_DB")+".products_view_bloc_data d on d.id = r.data_id and d.site_id = "+escape.cote(siteid)+" and d.for_prod_site = 0 "+
					" join " + GlobalParm.getParm("PAGES_DB")+".pages p on p.id = d.page_id "+
					" where r.product_id = "+escape.cote(productId)); 

			while(rsP.next())
			{
				if("freemarker".equals(rsP.value("page_type")) && freemarkerPageIds.contains(rsP.value("parent_page_id")) == false) freemarkerPageIds.add(rsP.value("parent_page_id"));
				else if("structured".equals(rsP.value("page_type")) && structuredContentIds.contains(rsP.value("parent_page_id")) == false) structuredContentIds.add(rsP.value("parent_page_id"));				
			}
		}
		
		for(int i=0;i<freemarkerPageIds.size();i++)
		{
			Logger.info("saveproduct.jsp", "Mark freemarker page for regenerate. Page ID : " + freemarkerPageIds.get(i));
			
			boolean republishAlso = false;
			Set rsP = Etn.execute("select id from "+GlobalParm.getParm("PAGES_DB")+".freemarker_pages where published_ts > updated_ts and publish_status = 'published' and id = "+escape.cote(freemarkerPageIds.get(i)));
			if(rsP.next()) republishAlso = true;
			
			String q = "update "+GlobalParm.getParm("PAGES_DB")+".freemarker_pages set to_generate = 1, to_generate_by = "+escape.cote(""+Etn.getId())+", updated_ts = now()";
			if(republishAlso) q += ", to_publish = 1, to_publish_ts = now(), to_publish_by = "+escape.cote(""+Etn.getId());
			q += " where id = " + escape.cote(freemarkerPageIds.get(i));
			com.etn.util.Logger.info("saveproduct.jsp", q);
			Etn.executeCmd(q);
		}
		for(int i=0;i<structuredContentIds.size();i++)
		{
			Logger.info("saveproduct.jsp", "Mark structured content for regenerate. Content ID : " + structuredContentIds.get(i));
			boolean republishAlso = false;
			Set rsP = Etn.execute("select id from "+GlobalParm.getParm("PAGES_DB")+".structured_contents where published_ts > updated_ts and publish_status = 'published' and id = "+escape.cote(structuredContentIds.get(i)));
			if(rsP.next()) republishAlso = true;
			
			String q = "update "+GlobalParm.getParm("PAGES_DB")+".structured_contents set to_generate = 1, to_generate_by = "+escape.cote(""+Etn.getId())+", updated_ts = now()";
			if(republishAlso) q += ", to_publish = 1, to_publish_ts = now(), to_publish_by = "+escape.cote(""+Etn.getId());
			q += " where id = " + escape.cote(structuredContentIds.get(i));
			com.etn.util.Logger.info("saveproduct.jsp", q);
			Etn.executeCmd(q);
		}
		
		Set rsC = Etn.execute("select * from "+GlobalParm.getParm("PAGES_DB")+".config where code = 'SEMAPHORE'");
		if(rsC.next())
		{
			Etn.execute("select semfree("+escape.cote(rsC.value("val"))+")");
		}
		
	}
	
    String decodeCKEditorValue(String str){
        if(str != null){
            return str.replace("_etnipt_=","src=").replace("_etnhrf_=","href=").replace("_etnstl_=","style=");
        }
        else{
            return str;
        }
    }

    void saveShareBar(Contexte Etn,List<Language> langsList,String id,ParseFormRequest formRequest,ImageHelper imageHelper,String productName){
        java.util.Set<String> params = formRequest.keySet();

        java.util.List<KeyValuePair<String,String>> values = new java.util.ArrayList<>();

        for(String parameter : params){
            if(parameter.startsWith("share_bar_") && parameter.startsWith("share_bar_facebook_image_") == false){
                String colName = parameter.replace("share_bar_","");
                values.add(new KeyValuePair<>(colName,escape.cote(formRequest.getParameter(parameter))));
            }
        }
        for(Language lang : langsList){
            String languageId = lang.getLanguageId();
            String imageData = escape.cote(formRequest.getParameter("share_bar_facebook_image_lang_" + languageId + "Data"));
            String originalFileName = formRequest.getParameter("share_bar_facebook_image_lang_" + languageId + "Name");
            String fileName = (productName.length() > 0) ? getAsiminaFileName(productName + "_" + lang.getCode() + "_facebook",originalFileName) : originalFileName;
            if(imageData.length() > 0 && originalFileName.length() > 0){
                imageHelper.saveBase64(imageData,fileName);
                values.add(new KeyValuePair<>("lang_" + languageId + "_og_image",escape.cote(fileName)));
                values.add(new KeyValuePair<>("lang_" + languageId + "_og_original_image_name",escape.cote(originalFileName)));
                values.add(new KeyValuePair<>("lang_" + languageId + "_og_image_label",escape.cote(formRequest.getParameter("share_bar_facebook_image_lang_" + languageId + "Label"))));
            }
        }

        String icols = "", ivals = "", ucols = "";
        for(KeyValuePair<String,String> pair : values){
            icols += "," + pair.getKey();
            ivals += "," + pair.getValue();
            ucols += "," + pair.getKey() + "=" + pair.getValue();
        }
        String q = "insert into share_bar (id, ptype, created_by";
        q += icols + ") values (" + escape.cote(id) + ",'product', " + escape.cote(""+Etn.getId())  +  ivals + ") on duplicate key update updated_by = " + escape.cote(""+Etn.getId()) + ", updated_on = now() " + ucols;
        Etn.executeCmd(q);
    }

    void saveImages(Contexte Etn,List<Language> langsList,String productId,ParseFormRequest formRequest,ImageHelper imageHelper,String productName){
        List<Language> langs = langsList;
        for(Language lang : langs){
            String languageId = lang.getLanguageId();
            //String [] imageDatas = formRequest.getParameterValues("product_image_lang_" + languageId + "Data" );
            String [] imageNames = formRequest.getParameterValues("product_image_lang_" + languageId + "Name");
            String [] imageLabels = formRequest.getParameterValues("product_image_lang_" + languageId + "Label");
            if(imageNames.length == imageLabels.length){
                //delete , insert
                Etn.executeCmd("DELETE FROM product_images WHERE product_id="+escape.cote(productId)
                    + " AND langue_id=" + escape.cote(languageId));

                for(int i=0; i < imageNames.length; i++){
                    //String imageData = imageDatas[i];
                    String imageLabel = imageLabels[i];
                    String imageName = imageNames[i];
                    if(imageName.length() > 0){
                         //String fileName = (productName.length() > 0) ? getAsiminaFileName(productName + "_" + lang.getCode() + "_" + i,imageName) : imageName;
                         //imageHelper.saveBase64(imageData,fileName);
                         //saveAllImages(imageHelper.getImageDirectory(),fileName);
                         Etn.executeCmd("insert into product_images (product_id,langue_id,image_file_name,image_label,actual_file_name,sort_order) values (" +
                                escape.cote(productId) + "," + escape.cote(languageId) + "," + escape.cote(imageName) + "," + escape.cote(imageLabel) + "," + escape.cote(imageName) + "," + escape.cote(String.valueOf(i+1)) + ")");
                    }
                }
            }
            else{
                Logger.error("Unexpected Error: image names and labels count dont match.");
            }
        }
    }

    void saveMetaTags(Contexte Etn,List<Language> langsList,String id,ParseFormRequest formRequest){
        Etn.execute("delete from products_meta_tags where product_id = " + escape.cote(id));

        String [] metaNames = formRequest.getParameterValues("meta_name");
        List<Language> langs = langsList;

        if(metaNames.length>0){
            for(Language lang : langs){
                String languageId = lang.getLanguageId();
                String [] metaContents = formRequest.getParameterValues("meta_content_lang_" + languageId);
                for(int i = 0; i < metaContents.length; i++){
                    if(metaNames[i].length()>0){
                        Etn.executeCmd("insert into products_meta_tags (product_id, langue_id, meta_name, content) values("+escape.cote(id)+","+escape.cote(languageId)+","+escape.cote(metaNames[i])+","+escape.cote(metaContents[i])+")");
                    }
                }
            }
        }
    }

    void saveTags(Contexte Etn,String id,ParseFormRequest formRequest){
        Etn.execute("delete from product_tags where product_id = " + escape.cote(id));
        String [] productTags = formRequest.getParameterValues("tagValue");
        for(String productTag : productTags){
            Etn.executeCmd("insert into product_tags(product_id,tag_id,created_by,created_on) values (" + escape.cote(id) + "," + escape.cote(productTag) + "," + escape.cote(String.valueOf(Etn.getId())) + ",NOW())");
        }
    }

    void saveProductDescription(Contexte Etn, List<Language> langsList,String id,ParseFormRequest formRequest,ImageHelper imageHelper,String productName, boolean isNew, String siteid)
    {
        Etn.executeCmd("delete from product_descriptions where product_id = " + escape.cote(id));
        Etn.executeCmd("delete from product_essential_blocks where product_id = " + escape.cote(id));
        Etn.executeCmd("delete from product_tabs where product_id = " + escape.cote(id));

		String defaultPagePath = "";
		if(isNew) defaultPagePath = UrlHelper.getProductSuggestedPath(Etn, id);

        List<Language> langs = langsList;
        for(Language lang : langs){
            String summary = formRequest.getParameter("description_summary_lang_" + lang.getLanguageId());
            String mainFeatures = formRequest.getParameter("description_main_features_lang_" + lang.getLanguageId());
            String videoUrl = formRequest.getParameter("description_video_url_lang_" + lang.getLanguageId());
            String alignment = formRequest.getParameter("description_essentials_alignment_lang_" + lang.getLanguageId());

            String seo = parseNull(formRequest.getParameter("description_seo_lang_" + lang.getLanguageId()));
            String seo_title = parseNull(formRequest.getParameter("description_seo_title_lang_" + lang.getLanguageId()));
            String seo_canonical_url = parseNull(formRequest.getParameter("description_seo_canonical_url_lang_" + lang.getLanguageId()));
            String page_path = parseNull(formRequest.getParameter("description_page_path_lang_" + lang.getLanguageId()));
            String page_template_id = parseNull(formRequest.getParameter("description_page_template_id_lang_" + lang.getLanguageId()));

			if(isNew && page_path.length() == 0)
			{
				page_path = defaultPagePath;

				//check if the default page path we created is unique across the site for the language ... we assume adding the -p<ID> will make it unique
				if(!UrlHelper.isUrlUnique(Etn, siteid, lang.getCode(), "product", id, page_path)) page_path += "-p" + id;
            }

            String query = " insert into product_descriptions(product_id,langue_id, seo, summary, main_features, video_url, essentials_alignment, seo_title, seo_canonical_url, page_path, page_template_id) values ( "
                    + escape.cote(id) + "," + escape.cote(lang.getLanguageId()) + "," +  escape.cote(seo) + "," +  escape.cote(summary) + "," +  escape.cote(mainFeatures)+ "," +  escape.cote(videoUrl) + "," +  escape.cote(alignment) + "," +  escape.cote(seo_title) + "," +  escape.cote(seo_canonical_url) + "," +  escape.cote(page_path)+ "," +  escape.cote(page_template_id) + ")";

            Etn.executeCmd(query);

            String [] blockTexts = formRequest.getParameterValues("description_essential_block_text_lang_" + lang.getLanguageId());
            // String [] imageDatas = formRequest.getParameterValues("description_essential_block_image_lang_" + lang.getLanguageId() + "Data");
            String [] imageFileNames = formRequest.getParameterValues("description_essential_block_image_lang_" + lang.getLanguageId() + "Name");
            String [] imageLabels = formRequest.getParameterValues("description_essential_block_image_lang_" + lang.getLanguageId() + "Label");

            if(UIHelper.areListsValid(blockTexts,imageFileNames,imageLabels)){
                for(int i=0; i < blockTexts.length; i++){
                    //String fileName = (productName.length() > 0) ? getAsiminaFileName(productName + "_essentials_" + lang.getCode() + "_" + i,imageFileNames[i]) : imageFileNames[i];
                    //imageHelper.saveBase64(imageDatas[i],fileName);
                    String fileName = imageFileNames[i];
                    Etn.executeCmd("insert into product_essential_blocks(product_id,langue_id,block_text,file_name,actual_file_name,image_label, order_seq) values ("
                                    + escape.cote(id) + "," + escape.cote(lang.getLanguageId()) + "," + escape.cote(blockTexts[i]) + "," + escape.cote(fileName)
                                    + "," + escape.cote(imageFileNames[i]) + "," + escape.cote(imageLabels[i]) + "," + escape.cote(String.valueOf(i+1)) + ")" );
                }
            }

            String [] tabNames = formRequest.getParameterValues("product_tab_name_lang_" + lang.getLanguageId());
            String [] tabContents = formRequest.getParameterValues("product_tab_content_lang_" + lang.getLanguageId());
            if(tabNames.length == tabContents.length){
                for(int i=0; i < tabNames.length; i++){
                    Etn.executeCmd("insert into product_tabs(product_id,langue_id,name,content,order_seq) values ("
                        + escape.cote(id) + "," + escape.cote(lang.getLanguageId()) + "," + escape.cote(tabNames[i]) + "," + escape.cote(tabContents[i]) + "," + escape.cote(String.valueOf(i+1)) + ")" );
                }
            }
            else{
                Logger.error("Something awful has happened 201");
            }
        }
    }

    void saveVariants(Contexte Etn,List<Language> langsList,String id,ParseFormRequest formRequest,
    					ProductImageHelper productImageHelper,String productName,
    					String catalogId)
    {

    	String q = "";
    	Set rs = null;
    	LinkedHashMap<String, String> colValueHM = new LinkedHashMap<>();


    	q = " DELETE d "
	        + " FROM product_variant_details d "
	        + " JOIN product_variants v ON d.product_variant_id = v.id "
	        + " AND v.product_id = " + escape.cote(id);
	    Etn.executeCmd(q);

	    q = " DELETE r "
            + " FROM product_variant_ref r "
            + " JOIN product_variants v ON r.product_variant_id = v.id "
            + " AND v.product_id = " + escape.cote(id);
	    Etn.executeCmd(q);

	    q = " DELETE r "
            + " FROM product_variant_resources r "
            + " JOIN product_variants v ON r.product_variant_id = v.id "
            + " AND v.product_id = " + escape.cote(id);
	    Etn.executeCmd(q);


        String [] variantUIIds = formRequest.getParameterValues("variantId");
        String [] variantSKU = formRequest.getParameterValues("variantSKU");
        String [] variantActive = formRequest.getParameterValues("variantActive");
        String [] variantIsShowPrice = formRequest.getParameterValues("variantIsShowPrice");
        String [] variantPrice = formRequest.getParameterValues("variantPrice");
        String [] variantStock = formRequest.getParameterValues("variantStock");
        String [] variantDefault = formRequest.getParameterValues("variantDefault");
        //these fields are filled for offer_postpaid only. In other cases we get empty fields in request.
        String [] variantFrequency = formRequest.getParameterValues("variantFrequency");
        String [] variantCommitment = formRequest.getParameterValues("variantCommitment");
        String [] variantSticker = formRequest.getParameterValues("variantSticker");

        boolean isDefaultSet = false;
        for(String curVariantDefault : variantDefault){
            if (curVariantDefault.equals("1")) {
                isDefaultSet = true;
                break;
            }
        }
        if(!isDefaultSet && variantDefault.length > 0){
            variantDefault[0] = "1";
        }

        String[] variantIds = new String[variantUIIds.length];

        for(int i=0; i < variantUIIds.length; i++){
        	String curVariantId = variantUIIds[i];

        	rs = null;
        	if(parseInt(curVariantId) > 0){
        		q = "SELECT id FROM product_variants WHERE id = " + escape.cote(curVariantId)
        			+ " AND product_id = " + escape.cote(id);
        		rs = Etn.execute(q);
        	}

        	colValueHM.clear();
        	colValueHM.put("product_id", escape.cote(id) );
        	colValueHM.put("sku", escape.cote(variantSKU[i]) );
        	colValueHM.put("is_active", escape.cote(variantActive[i]) );
        	colValueHM.put("is_default", escape.cote(variantDefault[i]) );
            colValueHM.put("is_show_price", escape.cote(variantIsShowPrice[i]) );
        	colValueHM.put("price", escape.cote(variantPrice[i]) );
			String variantFreq = "";
			if(variantFrequency != null && variantFrequency.length > 0) variantFreq = variantFrequency[i];
        	colValueHM.put("frequency", escape.cote(variantFreq) );
        	colValueHM.put("commitment", escape.cote(variantCommitment[i]) );
        	colValueHM.put("updated_by", escape.cote("" + Etn.getId()) );
        	colValueHM.put("updated_on", "NOW()" );
            colValueHM.put("sticker", escape.cote(variantSticker[i]));
            colValueHM.put("order_seq", escape.cote(String.valueOf(i+1)));

        	if(rs != null && rs.next()){
        		//update existing variant
        		q = getUpdateQuery("product_variants", colValueHM, " WHERE id = "+ escape.cote(curVariantId));

        		Etn.executeCmd(q);
        		variantIds[i] = String.valueOf(parseInt(curVariantId));
        	}
        	else{
        		//new variant
        		String uuid = java.util.UUID.randomUUID().toString();
        		colValueHM.put("uuid", escape.cote(uuid) );
        		colValueHM.put("stock", "'0'" );
        		colValueHM.put("created_by", escape.cote("" + Etn.getId()) );
        		colValueHM.put("created_on", "NOW()" );

        		q = getInsertQuery("product_variants", colValueHM);

        		int newVariantId = Etn.executeCmd(q);
        		variantIds[i] = String.valueOf(newVariantId);
        	}
        }

        //remove/cleanup deleted variants
        q = "DELETE FROM product_variants "
	        + " WHERE product_id = " + escape.cote(id);

	    if(variantIds.length > 0){

	    	String commaSepVariantIds = "";
		    for(String varId : variantIds){
		    	if(commaSepVariantIds.length() > 0) commaSepVariantIds += ",";
		    	commaSepVariantIds += escape.cote(varId);
		    }
	        if(commaSepVariantIds.length() > 0){
	        	q += " AND id NOT IN (" + commaSepVariantIds + ")";
	        }

	    }

        Etn.executeCmd(q);

        if(variantIds.length > 0){//if some variants were added then we should do this.
        	Set catAttributesRs = Etn.execute("SELECT cat_attrib_id FROM catalog_attributes WHERE catalog_id = " + escape.cote(catalogId) + " and type = 'selection' ORDER BY sort_order ");
            while(catAttributesRs.next()){
                String catalogAttributeId = catAttributesRs.value("cat_attrib_id");
                String [] variantCatalogAttributes = formRequest.getParameterValues("variantCatalogAttribute" + catalogAttributeId);
                if(variantCatalogAttributes.length == variantIds.length){
                    for(int i=0; i < variantCatalogAttributes.length; i++){

                        if(parseInt(variantCatalogAttributes[i]) > 0){
                        	q = " INSERT INTO product_variant_ref( cat_attrib_id, catalog_attribute_value_id, product_variant_id) "
                                + " SELECT cat_attrib_id, id, "
                                + escape.cote(variantIds[i])
                                + " FROM catalog_attribute_values "
                                + " WHERE cat_attrib_id = " + escape.cote(catalogAttributeId)
                                + " AND id = " + escape.cote(variantCatalogAttributes[i]);
                            Etn.executeCmd(q);
                        }
                        else{
                            q = " INSERT INTO product_variant_ref( cat_attrib_id, catalog_attribute_value_id, product_variant_id) VALUES ( "
                                + escape.cote(catalogAttributeId) + ", "
                                + escape.cote(variantCatalogAttributes[i]) + ", "
                                + escape.cote(variantIds[i]) + " )";
                            Etn.executeCmd(q);
                        }
                    }
                }
                else{
                    Logger.error("something awful happened while saving product 1");
                }

            }// while
            List<Language> langs = langsList;
            Map<Integer,Map<String, String>> productVariantNames = new HashMap<>();

            boolean isFirstLang = true;
            for(Language lang : langs){

                String [] variantNames = formRequest.getParameterValues("variantName_lang_" + lang.getLanguageId());
                String [] variantMainFeatures = formRequest.getParameterValues("variantMainFeatures_lang_" + lang.getLanguageId());
                String [] variantDesktopLabel = formRequest.getParameterValues("variantButtonDesktopLabel_lang_" + lang.getLanguageId());
                String [] variantDesktopUrl = formRequest.getParameterValues("variantButtonDesktopUrl_lang_" + lang.getLanguageId());
                String [] variantDesktopUrlOpenType = formRequest.getParameterValues("variantButtonDesktopUrl_lang_" + lang.getLanguageId() + "_opentype");
                String [] variantMobileLabel = formRequest.getParameterValues("variantButtonMobileLabel_lang_" + lang.getLanguageId());
                String [] variantMobileUrl = formRequest.getParameterValues("variantButtonMobileUrl_lang_" + lang.getLanguageId());
                String [] variantMobileUrlOpenType = formRequest.getParameterValues("variantButtonMobileUrl_lang_" + lang.getLanguageId() +"_opentype");

                if( areAllArraySizeEqual(variantIds, variantNames, variantMainFeatures,
                                            variantDesktopLabel,variantDesktopUrl,
                                            variantMobileLabel, variantMobileUrl ) ){


                    for(int i=0; i < variantIds.length ; i++){

                        if(!productVariantNames.containsKey(Integer.valueOf(i))){
                            productVariantNames.put(Integer.valueOf(i), new HashMap<>());
                        }
                        String curLangVariantName = variantNames[i];
                        if(curLangVariantName.trim().length() == 0 && !isFirstLang){
                            String firstLangId = langs.get(0).getLanguageId();
                            curLangVariantName = productVariantNames.get(i).get(firstLangId);
                        }

                        productVariantNames.get(Integer.valueOf(i)).put(lang.getLanguageId(),curLangVariantName);

                        if(curLangVariantName.length() > 0){

 							colValueHM.clear();
 							colValueHM.put("product_variant_id", escape.cote(variantIds[i]) );
 							colValueHM.put("langue_id", escape.cote(lang.getLanguageId()) );
 							colValueHM.put("name", escape.cote(curLangVariantName) );
 							colValueHM.put("main_features", escape.cote(variantMainFeatures[i]) );
                            colValueHM.put("action_button_desktop", escape.cote(variantDesktopLabel[i]));
                            colValueHM.put("action_button_desktop_url", escape.cote(variantDesktopUrl[i]));
                            colValueHM.put("action_button_desktop_url_opentype", escape.cote(variantDesktopUrlOpenType[i]));
                            colValueHM.put("action_button_mobile", escape.cote(variantMobileLabel[i]));
                            colValueHM.put("action_button_mobile_url", escape.cote(variantMobileUrl[i]));
                            colValueHM.put("action_button_mobile_url_opentype", escape.cote(variantMobileUrlOpenType[i]));

 							q = getInsertQuery("product_variant_details",colValueHM);
 							Etn.executeCmd(q);
                        }
                    }
                }
                else{
                    Logger.error("something awful happened while saving product 2");
                }

                isFirstLang = false;
            }

            for(com.etn.asimina.beans.Language lang : langs){
                String [] variantVideoURL = formRequest.getParameterValues("variantVideo_lang_" + lang.getLanguageId());
                if(variantVideoURL.length == variantIds.length){
                    for(int i=0; i < variantVideoURL.length; i++){
                        if(variantVideoURL[i].length() > 0){
                            Etn.executeCmd("insert into product_variant_resources(product_variant_id,type,langue_id,path) values ("
                                                    + escape.cote(variantIds[i]) + ",'video'," + escape.cote(lang.getLanguageId()) + "," + escape.cote(variantVideoURL[i]) + ")" );
                        }
                    }
                }
            }

            if(variantIds.length == variantUIIds.length){
                for(int i=0; i < variantUIIds.length; i++){
                    for(Language lang : langs){
                        //String [] imageData = formRequest.getParameterValues("variantImage" + variantUIIds[i] + "_lang_" + lang.getLanguageId() + "Data");
                        String [] fileNames = formRequest.getParameterValues("variantImage" + variantUIIds[i] + "_lang_" + lang.getLanguageId() + "Name");
                        String [] imageLabels = formRequest.getParameterValues("variantImage" + variantUIIds[i] + "_lang_" + lang.getLanguageId() + "Label");
                        for(int j=0; j < fileNames.length; j++){
                            String variantFileName = fileNames[j];
                            //String curLangVariantName = productVariantNames.get(Integer.valueOf(i)).get(lang.getLanguageId());
                            //String variantFileName = getAsiminaFileName(productName + "_" + curLangVariantName + "_" + lang.getCode() + "_" + j,fileNames[j]);
                            if(variantFileName.length() > 0){
                                //productImageHelper.saveBase64(imageData[j],variantFileName);
                                //saveAllImages(productImageHelper.getImageDirectory(),variantFileName);

                                colValueHM.clear();
                                colValueHM.put("product_variant_id",escape.cote(variantIds[i]));
                                colValueHM.put("type","'image'");
                                colValueHM.put("langue_id",escape.cote(lang.getLanguageId()));
                                colValueHM.put("path",escape.cote(variantFileName));
                                colValueHM.put("actual_file_name",escape.cote(variantFileName));
                                colValueHM.put("label",escape.cote(imageLabels[j]));
                                colValueHM.put("sort_order",escape.cote(String.valueOf(j)));
                                q = getInsertQuery("product_variant_resources", colValueHM);
                                Etn.executeCmd(q);
                            }
                        }
                    }
                }
            }
            else{
                Logger.error("something awful happened while saving product 3");
            }
        }
    }

%>
<%
    try{
        if(ServletFileUpload.isMultipartContent(request)){

            ParseFormRequest formRequest = new ParseFormRequest(this);
            formRequest.parse(request);

            if(formRequest.areFilesValid()){


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
                List<Language> langsList = getLangs(Etn,selectedsiteid);
                List<String> intcols = new ArrayList<>();
                intcols.add("familie_id");
                intcols.add("stock");
                intcols.add("subscription_require_email");
                intcols.add("subscription_require_phone");

                String id = parseNull(formRequest.getParameter("id"));
                String cid = parseNull(formRequest.getParameter("catalog_id"));
                String folderId = parseNull(formRequest.getParameter("folder_id"));
                int idInt = 0;

                String productName = parseNull(formRequest.getParameter("lang_1_name"));//we need this for naming files

                HashSet<String> ignoreColEquals = new HashSet<>();
                ignoreColEquals.add("id");
                ignoreColEquals.add("ignore");
                ignoreColEquals.add("lang_tab");
                ignoreColEquals.add("deleteimage");
                ignoreColEquals.add("tax_percentage");

                ArrayList<String> ignoreColStartsWith = new ArrayList<>();
                ignoreColStartsWith.add("product_tabs_");
                ignoreColStartsWith.add("attribute_");
                ignoreColStartsWith.add("linked_product_id");
                ignoreColStartsWith.add("variant");
                ignoreColStartsWith.add("share_bar");
                ignoreColStartsWith.add("description_");
                ignoreColStartsWith.add("product_image_");
                ignoreColStartsWith.add("tagValue");
                ignoreColStartsWith.add("product_tab_");
                ignoreColStartsWith.add("meta_");

                boolean isSkipParam = false;
		        boolean isNew = false;
                if(id.length() == 0)
                {
	                isNew = true;
                    String cols = "product_uuid";
                    String vals = "UUID()";
                    for(String parameter : formRequest.getParameterMap().keySet())
                    {

                        isSkipParam = false;
                        if(ignoreColEquals.contains(parameter)){
                            isSkipParam = true;
                        }
                        else{
                            for(String ignoreStr : ignoreColStartsWith){
                            	if(parameter.startsWith(ignoreStr)){
                            		isSkipParam = true;
                            		break;
                            	}
                            }
                        }

                        if(isSkipParam){
                            continue;
                        }

                        cols += "," + parameter;

                        if(intcols.contains(parameter) &&
                            parseNull(formRequest.getParameter(parameter)).length() == 0){

                            vals += ", NULL";
                        }
                        else {
                            vals += "," + escape.cote(formRequest.getParameter(parameter));
                        }
                    }
                    cols += ", created_by";
                    vals += ","+ escape.cote(""+Etn.getId());

                    cols += ", updated_by";
                    vals += ","+ escape.cote(""+Etn.getId());
                    cols += ", updated_on";
                    vals += ","+ "NOW()";
                    idInt = Etn.executeCmd("insert into products ("+cols+") values ("+vals+")");

                    id = String.valueOf(idInt);

                }
                else
                {
                    String q = "update products set version = version + 1, updated_on = now(), updated_by = " + escape.cote(""+Etn.getId());
                    ignoreColEquals.add("folder_id");
                    for(String parameter : formRequest.getParameterMap().keySet())
                    {

                        isSkipParam = false;
                        if(ignoreColEquals.contains(parameter)){
                            isSkipParam = true;
                        }
                        else{
                            for(String ignoreStr : ignoreColStartsWith){
                            	if(parameter.startsWith(ignoreStr)){
                            		isSkipParam = true;
                            		break;
                            	}
                            }
                        }

                        if(isSkipParam){
                            continue;
                        }

                        if(intcols.contains(parameter) && parseNull(formRequest.getParameter(parameter)).length() == 0) q += ", " + parameter + " = NULL ";
                        else if(parameter.endsWith("_features")) q += ", " + parameter + " = " + escape.cote(parseNull(formRequest.getParameter(parameter)).replace("_etnipt_=","src=").replace("_etnhrf_=","href=").replace("_etnstl_=","style="));
                        else q += ", " + parameter + " = " + escape.cote(formRequest.getParameter(parameter));
                    }
                    if(parseNull(formRequest.getParameter("deleteimage")).equals("1"))
                    {
                        q += ", image_name = null ";
                        q += ", image_actual_name = null ";
                    }
                    q += " where id = " + escape.cote(id);
                    Logger.debug("UPDATE PRODUCT: " + q);
                    Etn.executeCmd(q);
                    System.out.println("Don============");
                    idInt = Integer.parseInt(id);

                }


                ProductImageHelper productImageHelper = new ProductImageHelper(id);
                ProductShareBarImageHelper productShareBarImageHelper = new ProductShareBarImageHelper(id);
                ProductEssentialsImageHelper productEssentialsImageHelper = new ProductEssentialsImageHelper(id);

                //update/insert share-bar
                Set rs = Etn.execute("select * from products where id = " + escape.cote(""+id));

                //update/insert product attribute values

                //delete attributes
                String attribsValuesDeleted = formRequest.getParameter("attribute_values_deleted");

                if(id.length() > 0 && attribsValuesDeleted != null && attribsValuesDeleted.trim().length() > 0 ){
                    String[] deletedIds = attribsValuesDeleted.split(",");

                    for(String deletedId : deletedIds){
                        if(deletedId.trim().length() > 0 ){
                            Etn.executeCmd("DELETE FROM product_attribute_values WHERE id = "+ escape.cote(deletedId) + " AND product_id = " + escape.cote(id));
                        }
                    }
                }

                Set catAttributesRs = Etn.execute("SELECT cat_attrib_id FROM catalog_attributes WHERE catalog_id = " + escape.cote(cid) + " ORDER BY sort_order ");

                while(catAttributesRs.next()){
                    String attribId = catAttributesRs.value("cat_attrib_id");

                    String[] attribValueIdList = formRequest.getParameterValues("attribute_value_id_" + attribId);
                    String[] attribValueList = formRequest.getParameterValues("attribute_value_" + attribId);
                    String[] attribIsDefaultList = formRequest.getParameterValues("attribute_is_default_" + attribId);
                    String[] attribSmallTextList = formRequest.getParameterValues("attribute_small_text_" + attribId);
                    String[] attribColorList = formRequest.getParameterValues("attribute_color_" + attribId);

                    if( areAllArraySizeEqual(attribValueIdList, attribValueList, attribIsDefaultList,
                    		attribSmallTextList, attribColorList) ) {

                        for(int i=0; i<attribValueIdList.length; i++){
                            String attribValueId = attribValueIdList[i];
                            String attribValue = attribValueList[i];
                            String attribIsDefault = attribIsDefaultList[i].length() > 0 ? attribIsDefaultList[i] : "0";
                            String attribSmallText = attribSmallTextList[i];
                            String attribColor = attribColorList[i];
                            if(parseInt(attribValueId) > 0){
                                //update
                                String q = "UPDATE product_attribute_values SET sort_order = " + i
                                           + " , attribute_value = " + escape.cote(attribValue)
                                           + " , is_default = " + escape.cote(attribIsDefault)
                                           + " , small_text = " + escape.cote(attribSmallText)
                                           + " , color = " + escape.cote(attribColor)
                                           + " WHERE id = " + escape.cote(attribValueId)
                                           + "     AND product_id = " + escape.cote(id)
                                           + "     AND cat_attrib_id = " + escape.cote(attribId);

                                Etn.executeCmd(q);
                            }
                            else{
                                //insert
                                String q = "INSERT INTO product_attribute_values (product_id, cat_attrib_id , attribute_value,  is_default, small_text, color , sort_order) VALUES ("
                                            + escape.cote(id) +"," + escape.cote(attribId) +"," + escape.cote(attribValue) + "," + escape.cote(attribIsDefault) + "," + escape.cote(attribSmallText) + "," + escape.cote(attribColor) + "," + i + ") ";
                                Etn.executeCmd(q);
                            }

                        }

                    }

                }

                //process linked products

                String[] linkedProductIdList = formRequest.getParameterValues("linked_product_id");
                String linkedProductIds = "";
                if(linkedProductIdList != null){
                    for(String pId : linkedProductIdList){
                        if(pId.trim().length() > 0){
                            linkedProductIds += escape.cote(pId) + ",";
                        }
                    }
                    if(linkedProductIds.length() > 0){
                        linkedProductIds = linkedProductIds.substring(0,linkedProductIds.length()-1);
                    }
                }


                String productType = formRequest.getParameter("product_type");
                if( ! "service".equalsIgnoreCase(productType) && ! "service_day".equalsIgnoreCase(productType) && ! "service_night".equalsIgnoreCase(productType)  ){
                    Etn.executeCmd("UPDATE products SET link_id = NULL WHERE id = " + escape.cote(""+id));
                }
                else {
                    //service or service_day or service_night product
                    String linkId = "";
                    rs = Etn.execute("SELECT link_id FROM products WHERE id = " + escape.cote(""+id));
                    if(rs.next()){
                        linkId = rs.value("link_id");
                        if(parseInt(linkId) <= 0){
                            linkId  = "";
                        }
                    }

                    if(linkId.length() > 0){

                        if(linkedProductIds.length() > 0){
                            //the products of this link has changed ,
                            //remove it from all existing and add the new selected products to this link

                            Etn.executeCmd("UPDATE products SET link_id = NULL WHERE link_id = " + escape.cote(linkId) );

                            Etn.executeCmd("UPDATE products SET link_id =" + escape.cote(linkId)
                                            + " WHERE id IN (" +linkedProductIds + "," + escape.cote(id) + ")" );
                        }
                        else{
                            //the product was part of the link
                            //but has been removed from the link
                            Etn.executeCmd("UPDATE products SET link_id = NULL WHERE id = " + escape.cote(id) );
                        }

                    }
                    else if(linkId.length() == 0 && linkedProductIds.length() > 0){

                        rs = Etn.execute(" SELECT DISTINCT p.link_id FROM products p "
                                            + " JOIN product_link pl ON pl.id = p.link_id "
                                            + " WHERE p.id IN (" + linkedProductIds + ")");

                        if(rs.rs.Rows == 1){
                            //if all added products have same link_id , use that link_id and add current product to it
                            rs.next();
                            linkId = rs.value("link_id");
                            Etn.executeCmd("UPDATE products SET link_id =" + escape.cote(linkId)
                                            + " WHERE id = " + escape.cote(id) );
                        }
                        else{
                            //create new link id
                            linkId = "" + Etn.executeCmd("INSERT INTO product_link(stock, created_ts, created_by) VALUES ( 0, NOW(), "+escape.cote(""+Etn.getId())+")");

                            Etn.executeCmd("UPDATE products SET link_id =" + escape.cote(linkId)
                                            + " WHERE id IN (" +linkedProductIds + "," + escape.cote(id) + ")" );
                        }

                    }

                    //un comment after fixing product.jsp
                    //clean up product stock if prod type changes to service
                    //edge case in case of  service* prodType check product_stocks
                    rs = Etn.execute(" SELECT product_id FROM product_stocks WHERE product_id =  "+ escape.cote(""+id));
                    if(rs != null && rs.rs.Rows > 1){
                        // service can only have 1 row
                        Etn.executeCmd("DELETE FROM product_stocks WHERE product_id =  "+ escape.cote(""+id));
                        Etn.executeCmd("INSERT INTO product_stocks(product_id,attribute_values,stock,resources,created_ts,created_by) "
                                        + " VALUES("+ escape.cote(""+id) +",'',0,'',NOW(),"+escape.cote(""+Etn.getId())+")");
                    }

                }//else service product type

                //clean up linked products who are single in the link group
                rs = Etn.execute("SELECT link_id FROM products WHERE link_id IS NOT NULL GROUP BY link_id  HAVING COUNT(id) = 1 ");
                while(rs != null && rs.next()){
                    Etn.executeCmd("UPDATE products SET link_id = NULL WHERE link_id = " + escape.cote(rs.value("link_id")) );//change
                }

                if(idInt > 0){
                    saveVariants(Etn,langsList,id,formRequest,productImageHelper,productName,cid);
                    saveShareBar(Etn,langsList,id,formRequest,productShareBarImageHelper,productName);
                    saveTags(Etn,id,formRequest);
                    saveMetaTags(Etn,langsList,id,formRequest);
                    saveProductDescription(Etn,langsList,id,formRequest,productEssentialsImageHelper,productName, isNew, selectedsiteid);
                    saveImages(Etn,langsList,id,formRequest,productImageHelper,productName);
                }

				boolean checkProductViewsUsage = false;
                String saveMsg = "";
                if(isNew){
                    saveMsg = "Product saved";
                    ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),id,"CREATED","Product",productName,selectedsiteid);
					checkProductViewsUsage = true;
                }
                else{
                    saveMsg = "Modifications saved";
                    ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),id,"UPDATED","Product",productName,selectedsiteid);
					checkProductViewsUsage = true;
                }
				if(checkProductViewsUsage) checkProductViewsUsage(Etn, selectedsiteid, id, isNew);
                session.setAttribute("PRODUCT_SAVE_MSG",saveMsg);

                response.setStatus(javax.servlet.http.HttpServletResponse.SC_MOVED_TEMPORARILY);
                String url = "product.jsp?cid="+cid;
                Set rsFolder =  Etn.execute("select uuid as folderUuid from products_folders where id  = "+escape.cote(folderId));
                if(rsFolder.next()){
                    url = url + "&folderId="+rsFolder.value("folderUuid");
                }
                if(idInt > 0){
                    url = url + "&id="+id;
                }
                response.setHeader("Location", url);
				
				Etn.executeCmd("update "+GlobalParm.getParm("PREPROD_PORTAL_DB")+".cache_tasks set status = 9 where status = 0 and task = 'generate' and site_id = "+escape.cote(selectedsiteid)+" and content_type = 'product' and content_id = "+escape.cote(id));
				Etn.executeCmd("insert into "+GlobalParm.getParm("PREPROD_PORTAL_DB")+".cache_tasks (site_id, content_type, content_id, task) "+
					" values("+escape.cote(selectedsiteid)+", 'product', "+escape.cote(id)+", 'generate') ");														

				Etn.execute("select semfree("+escape.cote(GlobalParm.getParm("PORTAL_ENG_SEMA"))+")");
				
				
            }
        }
    }catch(Exception ex){
        ex.printStackTrace();
        response.setStatus(javax.servlet.http.HttpServletResponse.SC_MOVED_TEMPORARILY);
        response.setHeader("Location", "catalogs.jsp");
    }

%>   }

%>