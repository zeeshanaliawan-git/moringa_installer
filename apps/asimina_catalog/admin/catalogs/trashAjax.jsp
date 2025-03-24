<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,java.io.File,com.etn.util.ItsDate,org.apache.commons.io.FileUtils, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map,java.util.List, com.etn.beans.app.GlobalParm, com.etn.asimina.util.*,com.etn.asimina.util.FileUtil"%>
<%@ include file="../../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../common.jsp"%>
<%@ include file="/WEB-INF/include/constants.jsp"%>

<%!
	public boolean isMediaType(String fileType) {
        return "img".equals(fileType) ||  "video".equals(fileType);
    }

	public void deletePageCommon(String pageId, Contexte Etn,String revertType) {

        String q = " SELECT html_file_path, published_html_file_path"
                   + " FROM "+GlobalParm.getParm("PAGES_DB")+".pages_tbl "
                   + " WHERE id = " + escape.cote(pageId);
        Set rs = Etn.execute(q);
        if (!rs.next()) {
            return;
        }
        String pageHtmlPath = parseNull(rs.value("html_file_path"));
        String publishedHtmlPath = parseNull(rs.value("published_html_file_path"));

        String BASE_DIR = "";
        String PAGES_SAVE_FOLDER ="";
        String PAGES_PUBLISH_FOLDER = "";

		Set pagesPath=Etn.execute("select * from "+GlobalParm.getParm("PAGES_DB")+".config where code in ('BASE_DIR','PAGES_SAVE_FOLDER','PAGES_PUBLISH_FOLDER')");
		while(pagesPath.next()){

			if(pagesPath.value("code").equalsIgnoreCase("base_dir")){
				BASE_DIR = pagesPath.value("val");
			}else if(pagesPath.value("code").equalsIgnoreCase("PAGES_SAVE_FOLDER")){
				PAGES_SAVE_FOLDER = pagesPath.value("val");
			}else if(pagesPath.value("code").equalsIgnoreCase("PAGES_PUBLISH_FOLDER")){
				PAGES_PUBLISH_FOLDER = pagesPath.value("val");
			} 
		}

        if (pageHtmlPath.length() > 0) {
            String htmlFilePath = BASE_DIR;
			if(revertType.length() == 0) {
				htmlFilePath+="delete/";
			}
			htmlFilePath+= PAGES_SAVE_FOLDER + pageHtmlPath;

            File htmlFile = new File(htmlFilePath);
            if (htmlFile.exists()) {
                htmlFile.delete();
            }
        }

        if (publishedHtmlPath.length() > 0) {
			String publishedFilePath = BASE_DIR;
			if(revertType.length() == 0) {
				publishedFilePath+="delete/";
			}
			publishedFilePath+= PAGES_PUBLISH_FOLDER + publishedHtmlPath;

            File publishedFile = new File(publishedFilePath);
            if (publishedFile.exists()) {
                publishedFile.delete();
            }
        }

        q = " DELETE FROM "+GlobalParm.getParm("PAGES_DB")+".pages_meta_tags WHERE page_id = " + escape.cote(pageId);
        Etn.executeCmd(q);

        q = "DELETE FROM "+GlobalParm.getParm("PAGES_DB")+".pages_urls WHERE page_id = " + escape.cote(pageId);
        Etn.executeCmd(q);

        q = " DELETE pv FROM "+GlobalParm.getParm("PAGES_DB")+".page_item_property_values pv "
            + " JOIN "+GlobalParm.getParm("PAGES_DB")+".page_items pi ON pv.page_item_id = pi.id WHERE pi.page_id = " + escape.cote(pageId);
        Etn.executeCmd(q);

        q = " DELETE FROM "+GlobalParm.getParm("PAGES_DB")+".page_items WHERE page_id = " + escape.cote(pageId);
        Etn.executeCmd(q);

        q = "DELETE FROM "+GlobalParm.getParm("PAGES_DB")+".pages_tbl WHERE id = " + escape.cote(pageId);
        Etn.executeCmd(q);

    }

	void moveToFolder(String htmlFilePathSource,String htmlFilePathDestination){
        try {
            File sourceFile = FileUtil.getFile(htmlFilePathSource);//change
            File destinationFolder = FileUtil.getFile(htmlFilePathDestination);//change

            if (!sourceFile.exists()) {
                System.out.println("Source file does not exist");
            } else {
				FileUtil.mkDirs(destinationFolder);//change
                
                File destinationFile = FileUtil.getFile(htmlFilePathDestination + sourceFile.getName());//change
                
                sourceFile.renameTo(destinationFile);

                File htmlFile =  FileUtil.getFile(htmlFilePathSource);//change
                if (htmlFile.exists()) {
                    htmlFile.delete();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

	void movePageBackToFolder(Contexte Etn,String pageId) {

        String q = " SELECT html_file_path, published_html_file_path"
                   + " FROM "+GlobalParm.getParm("PAGES_DB")+".pages_tbl "
                   + " WHERE id = " + escape.cote(pageId);
        Set rs = Etn.execute(q);
        if (!rs.next()) {
            return;
        }
        String pageHtmlPath = parseNull(rs.value("html_file_path"));
        String publishedHtmlPath = parseNull(rs.value("published_html_file_path"));

        String BASE_DIR = "";
        String PAGES_SAVE_FOLDER ="";
        String PAGES_PUBLISH_FOLDER = "";

		Set pagesPath=Etn.execute("select * from "+GlobalParm.getParm("PAGES_DB")+".config where code in ('BASE_DIR','PAGES_SAVE_FOLDER','PAGES_PUBLISH_FOLDER')");
		while(pagesPath.next()){

			if(pagesPath.value("code").equalsIgnoreCase("base_dir")){
				BASE_DIR = pagesPath.value("val");
			}else if(pagesPath.value("code").equalsIgnoreCase("PAGES_SAVE_FOLDER")){
				PAGES_SAVE_FOLDER = pagesPath.value("val");
			}else if(pagesPath.value("code").equalsIgnoreCase("PAGES_PUBLISH_FOLDER")){
				PAGES_PUBLISH_FOLDER = pagesPath.value("val");
			} 
		}

        if (pageHtmlPath.length() > 0) {
            String htmlFilePathDestination = BASE_DIR + PAGES_SAVE_FOLDER + pageHtmlPath.substring(0, pageHtmlPath.lastIndexOf("/")+1);
            String htmlFilePathSource = BASE_DIR + "delete/" + PAGES_SAVE_FOLDER + pageHtmlPath;
            moveToFolder(htmlFilePathSource,htmlFilePathDestination);
        }

        if (publishedHtmlPath.length() > 0) {
            String htmlFilePathDestination = BASE_DIR + PAGES_PUBLISH_FOLDER + publishedHtmlPath.substring(0, publishedHtmlPath.lastIndexOf("/")+1);
            String htmlFilePathSource = BASE_DIR + "delete/" + PAGES_PUBLISH_FOLDER + publishedHtmlPath;

            File sourceFile = new File(htmlFilePathSource);
            File destinationFolder = new File(htmlFilePathDestination);

            moveToFolder(htmlFilePathSource,htmlFilePathDestination);
        }

    }

	String deletecontentPages(Contexte Etn, String id, String siteId,String revertType){

		Set detailRs= Etn.execute("SELECT page_id FROM "+GlobalParm.getParm("PAGES_DB")+".structured_contents_details WHERE page_id > 0 AND content_id = "+escape.cote(id));
		while(detailRs.next()){
			String detailPageId = detailRs.value("page_id");
			if(parseInt(detailPageId)>0){
				deletePageCommon(detailPageId, Etn,revertType);
			}
		}

        Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("PAGES_DB")+".pages_tags WHERE page_type = 'structured' and page_id = " + escape.cote(id));

		Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("PAGES_DB")+".structured_contents_details WHERE content_id = " + escape.cote(id));

		Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("PAGES_DB")+".structured_contents_tbl WHERE id = " + escape.cote(id));
		Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("PAGES_DB")+".products_map_pages WHERE page_id = " + escape.cote(id));
		Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("PAGES_DB")+".locked_items where item_id="+escape.cote(id)+" and item_type='structured' and site_id="+escape.cote(siteId));

		Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("PAGES_DB")+".parent_pages_blocs WHERE page_id = " + escape.cote(id));

		return "success";
	}

	String revertStructuredPage(Contexte Etn, String id, String siteId){

        Set rs=Etn.execute("select id from "+GlobalParm.getParm("PAGES_DB")+".structured_contents_tbl where name = (select name from "+GlobalParm.getParm("PAGES_DB")+
			".structured_contents_tbl where id="+escape.cote(id)+") and type =(select type from "+GlobalParm.getParm("PAGES_DB")+
			".structured_contents_tbl where id="+escape.cote(id)+") and id !="+escape.cote(id)+" AND site_id = "+escape.cote(siteId));
        
        if(rs.rs.Rows>0){
            return "fail";
        }else{

            rs=Etn.execute("select id from "+GlobalParm.getParm("PAGES_DB")+".pages_tbl where parent_page_id="+escape.cote(id));
            while(rs.next()){
                movePageBackToFolder(Etn,rs.value("id"));
            }

            Etn.executeCmd("update "+GlobalParm.getParm("PAGES_DB")+".pages_tbl set is_deleted='0',updated_by="+escape.cote(""+Etn.getId())+" where parent_page_id="+escape.cote(id));
            Etn.executeCmd("update "+GlobalParm.getParm("PAGES_DB")+".structured_contents_tbl set is_deleted='0',updated_by="+escape.cote(""+Etn.getId())+" WHERE id = " + escape.cote(id));

            return "success";
        }

    }

	String deleteblocPages(Contexte Etn, String id, String siteId,String revertType){
		
		Set rs = Etn.execute("SELECT id as page_id  FROM "+GlobalParm.getParm("PAGES_DB")+".pages_tbl WHERE parent_page_id = " + escape.cote(id)+ " AND type = 'freemarker'");
		while(rs.next()){
			String pageId = rs.value("page_id");
			if(parseInt(pageId)>0){
				deletePageCommon(pageId, Etn,revertType);
			}
		}

        Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("PAGES_DB")+".pages_tags WHERE page_type = 'freemarker' and page_id = " + escape.cote(id));

		Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("PAGES_DB")+".freemarker_pages_tbl WHERE id = " + escape.cote(id)+" AND site_id = "+escape.cote(siteId) +" AND is_deleted = '1'" );
		Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("PAGES_DB")+".parent_pages_blocs WHERE page_id = " + escape.cote(id));
		Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("PAGES_DB")+".locked_items where item_id="+escape.cote(id)+" and item_type='freemarker' and site_id="+escape.cote(siteId));
		Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("PAGES_DB")+".parent_pages_forms WHERE page_id = " + escape.cote(id));

		return "success";
            
	}

	String revertBlocPages(Contexte Etn, String id, String siteId){

        Set rs=Etn.execute("select id from "+GlobalParm.getParm("PAGES_DB")+".freemarker_pages_tbl where name = (select name from "+GlobalParm.getParm("PAGES_DB")+
			".freemarker_pages_tbl where id="+escape.cote(id)+") and id !="+escape.cote(id)+" and site_id="+escape.cote(siteId));
        if(rs.rs.Rows>0){
            return "fail";
        }else{

            rs=Etn.execute("select id from "+GlobalParm.getParm("PAGES_DB")+".pages_tbl where parent_page_id="+escape.cote(id));
            while(rs.next()){
                movePageBackToFolder(Etn,rs.value("id"));
            }

            Etn.executeCmd("update "+GlobalParm.getParm("PAGES_DB")+".pages_tbl set is_deleted='0',updated_by="+escape.cote(""+Etn.getId())+" where parent_page_id="+escape.cote(id));
            Etn.executeCmd("update "+GlobalParm.getParm("PAGES_DB")+".freemarker_pages_tbl set is_deleted='0',updated_by="+escape.cote(""+Etn.getId())+" WHERE id = " + escape.cote(id)+" AND site_id = "+escape.cote(siteId) );
            return "success";
        }
        
    }

	String deleteReactPages(Contexte Etn, String id, String siteId,String revertType){
		
		deletePageCommon(id, Etn,revertType);
		Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("PAGES_DB")+".pages_tags WHERE page_type = 'react' and page_id = " + escape.cote(id));

		return "success";
	}

	String revertReactPage(Contexte Etn, String id, String siteId){

        Set rs=Etn.execute("select id from "+GlobalParm.getParm("PAGES_DB")+".pages_tbl where name = (select name from "+GlobalParm.getParm("PAGES_DB")+
			".pages_tbl where id="+escape.cote(id)+") and id !="+escape.cote(id)+" and type = (select type from "+GlobalParm.getParm("PAGES_DB")+
			".pages_tbl where id="+escape.cote(id)+") AND site_id = "+escape.cote(siteId));
        
        if(rs.rs.Rows>0){
            return "fail";
        }else{

			movePageBackToFolder(Etn,id);

            Etn.executeCmd("update "+GlobalParm.getParm("PAGES_DB")+".pages_tbl set is_deleted='0',updated_by="+escape.cote(""+Etn.getId())+" where id="+escape.cote(id));

            return "success";
        }
    }

	void deletePagesFolders(Contexte Etn, String prodId, String siteId,String revertType){

		Set rsDelete=Etn.execute("select id from "+GlobalParm.getParm("PAGES_DB")+".structured_contents_tbl WHERE folder_id = " + escape.cote(prodId));
		while(rsDelete.next()){
			deletecontentPages(Etn,rsDelete.value("id"),siteId,revertType);
		}
		
		rsDelete=Etn.execute("select id from "+GlobalParm.getParm("PAGES_DB")+".freemarker_pages_tbl WHERE folder_id = " + escape.cote(prodId));
		while(rsDelete.next()){
			deleteblocPages(Etn,rsDelete.value("id"),siteId,revertType);
		}
		
		rsDelete=Etn.execute("select id from "+GlobalParm.getParm("PAGES_DB")+".pages_tbl WHERE folder_id = " + escape.cote(prodId));
		while(rsDelete.next()){
			deleteReactPages(Etn,rsDelete.value("id"),siteId,revertType);
		}

		Set rs= Etn.execute("Select * from "+GlobalParm.getParm("PAGES_DB")+".folders_tbl where parent_folder_id = " + escape.cote(prodId));
		while(rs.next()){
			deletePagesFolders(Etn,parseNull(rs.value("id")),siteId,revertType);
			
		}
		
		Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("PAGES_DB")+".folders_details WHERE folder_id = " + escape.cote(prodId));
		Etn.executeCmd("delete from "+GlobalParm.getParm("PAGES_DB")+".folders_tbl WHERE id = " + escape.cote(prodId)+ " AND site_id = " + escape.cote(siteId));  
	}

	Boolean checkFolderBeforeRevert(Contexte Etn,String id,String siteId){
        
        Set rs=Etn.execute("SELECT * FROM "+GlobalParm.getParm("PAGES_DB")+".folders_tbl f1 JOIN "+GlobalParm.getParm("PAGES_DB")+
			".folders_tbl f2 ON f1.name=f2.name and f1.site_id=f2.site_id and f1.parent_folder_id=f2.parent_folder_id and f1.type=f2.type and f2.is_deleted=0 WHERE f1.id="+escape.cote(id));
	    if(rs.rs.Rows>0){
            return false;
        }
        return null;
        
    }

    void markFolderForRevert(Contexte Etn,String id,String siteId){

        Set rs =Etn.execute("select id from "+GlobalParm.getParm("PAGES_DB")+".structured_contents_tbl WHERE folder_id = " + escape.cote(id));
        while(rs.next()){
            revertStructuredPage(Etn,rs.value("id"),siteId);
        }
        
        rs =Etn.execute("select id from "+GlobalParm.getParm("PAGES_DB")+".freemarker_pages_tbl WHERE folder_id = " + escape.cote(id));
        while(rs.next()){
            revertBlocPages(Etn,rs.value("id"),siteId);
        }
        
        rs =Etn.execute("select id from "+GlobalParm.getParm("PAGES_DB")+".pages_tbl WHERE folder_id = " + escape.cote(id));
        while(rs.next()){
            revertReactPage(Etn,rs.value("id"),siteId);
        }

        rs = Etn.execute("select id from "+GlobalParm.getParm("PAGES_DB")+".folders_tbl where parent_folder_id="+escape.cote(id));
        while(rs.next()){
            markFolderForRevert(Etn,parseNull(rs.value("id")),siteId);
        }
        Etn.executeCmd("update "+GlobalParm.getParm("PAGES_DB")+".folders_tbl set is_deleted='0',updated_by="+escape.cote(""+Etn.getId())+" WHERE id = " + escape.cote(id));
        
    }

    String revertFolder1(Contexte Etn, String id, String siteId){

        Boolean isValidFolder = checkFolderBeforeRevert(Etn,id,siteId);

        if(isValidFolder==null){

            markFolderForRevert(Etn,id,siteId);
			return "success";
        }
		return "fail";
    }


	void deleteProduct(com.etn.beans.Contexte Etn,String id,String siteId){
		com.etn.util.Logger.debug("trashAjax.jsp","delete product : " + id);
		Etn.executeCmd("delete from product_tabs where product_id = " + escape.cote(id));
		Etn.executeCmd("delete from tarif_category_items where tarif_category_id in (select id from tarif_categories where product_id = " +
			escape.cote(id) + " ) ");
		Etn.executeCmd("delete from tarif_categories where product_id = " + escape.cote(id));
		Etn.executeCmd("delete from product_attribute_values where product_id = " + escape.cote(id));
		Etn.executeCmd("delete from product_stocks where product_id = " + escape.cote(id));
		Etn.executeCmd("delete from product_images where product_id = " + escape.cote(id));
		Etn.executeCmd("delete from product_relationship where product_id = " + escape.cote(id) + " or related_product_id = " + 
			escape.cote(id));
		Etn.executeCmd("delete from share_bar where id = " + escape.cote(id));
		
		Set rsPages = Etn.execute("select page_id from "+GlobalParm.getParm("PAGES_DB")+".products_map_pages where product_id="+escape.cote(id));
		if(rsPages.next()) deletecontentPages(Etn,rsPages.value("page_id"),siteId,"delete");

		Etn.executeCmd("delete from products_definition_tbl where id = (select product_definition_id from products_tbl where id=" + escape.cote(id)+")");

		Etn.executeCmd("delete from products_tbl where id = " + escape.cote(id));
		Etn.executeCmd("DELETE FROM product_descriptions WHERE product_id = " + escape.cote(id));
		Etn.executeCmd("DELETE FROM product_tags WHERE product_id = " + escape.cote(id));
		Etn.executeCmd("DELETE FROM product_essential_blocks WHERE product_id = " + escape.cote(id));
		

		//variants
		Etn.executeCmd("DELETE d FROM product_variant_details d  JOIN product_variants v ON d.product_variant_id = v.id  AND v.product_id = " + escape.cote(id));
		Etn.executeCmd("DELETE r FROM product_variant_ref r JOIN product_variants v ON r.product_variant_id = v.id AND v.product_id = " + escape.cote(id));
		Etn.executeCmd("DELETE r FROM product_variant_resources r  JOIN product_variants v ON r.product_variant_id = v.id AND v.product_id = " + escape.cote(id));
		Etn.executeCmd("DELETE FROM product_variants WHERE product_id = " + escape.cote(id));

		try{

			//now delete product image directories
			ProductShareBarImageHelper sbImageHelper = new ProductShareBarImageHelper(id);
			deleteDirectoryWithContent(sbImageHelper.getImageDirectory());

			ProductEssentialsImageHelper essImageHelper = new ProductEssentialsImageHelper(id);
			deleteDirectoryWithContent(essImageHelper.getImageDirectory());

			ProductImageHelper prodImageHelper = new ProductImageHelper(id);
			deleteDirectoryWithContent(prodImageHelper.getImageDirectory());
		}catch(Exception e){
			e.printStackTrace();
		}

	}


	void deleteFolder(com.etn.beans.Contexte Etn,String id,String siteId){
		
		Set rsFolder = Etn.execute("select id from products_folders_tbl where parent_folder_id="+escape.cote(id));
		while(rsFolder.next()){
			deleteFolder(Etn, rsFolder.value("ID"), siteId);
		}
		
		com.etn.util.Logger.debug("trashAjax.jsp","Delete products for folder : "+id);
		Set rsProd = Etn.execute("select id from products_tbl where folder_id = "+escape.cote(id) );
		while(rsProd.next()){
			deleteProduct(Etn,rsProd.value("ID"),siteId);
		}
		// Deleting parent folder
		Etn.executeCmd("DELETE FROM products_folders_details WHERE folder_id = "+escape.cote(id));		
		Etn.executeCmd("DELETE FROM products_folders_tbl WHERE id = "+escape.cote(id)+" AND site_id = "+escape.cote(siteId));
	}
	
	void deleteCatalog(com.etn.beans.Contexte Etn,String id,String siteId){
		
		Set rsProd=Etn.execute("select id from products_folders_tbl where coalesce(parent_folder_id,0) = 0 and catalog_id="+escape.cote(id));
		while(rsProd.next()){
			deleteFolder(Etn,rsProd.value("ID"),siteId);
		}
		
		com.etn.util.Logger.debug("trashAjax.jsp","Delete products for catalog : "+id);
		//	Deleting products related to catalog
		rsProd = Etn.execute("select id from products_tbl where catalog_id = "+escape.cote(id) );
		while(rsProd.next()){
			deleteProduct(Etn,rsProd.value("ID"),siteId);
		}
		
		// Deleting parent catalog
		Etn.executeCmd("delete from catalog_descriptions where catalog_id = "+escape.cote(id)+" ");		
		Etn.executeCmd("delete from catalogs_tbl where id = "+escape.cote(id)+" ");
	}

	int revertExpertSystemQueries(com.etn.beans.Contexte Etn,String id,String siteId,String logedInUserId, String prodId){
		int rsp3 = 0;
		String q="";
		Set rsExpertSystemQuery = Etn.execute(q="select qs2.* from "+GlobalParm.getParm("EXPERT_SYSTEM_DB")+".query_settings_tbl qs1 join "+
			GlobalParm.getParm("EXPERT_SYSTEM_DB")+".query_settings_tbl qs2 on qs1.site_id=qs2.site_id and "+
			" qs1.query_id =qs2.query_id where qs2.is_deleted='0' AND qs1.qs_uuid="+escape.cote(id));
		
		if(rsExpertSystemQuery.next()){
			rsp3 = 1;
		}else{
			Etn.executeCmd("UPDATE "+GlobalParm.getParm("EXPERT_SYSTEM_DB")+".query_settings_tbl SET is_deleted='0',updated_on=now(),updated_by="+
				escape.cote(logedInUserId)+" WHERE qs_uuid = "+escape.cote(prodId));

		}
		return rsp3;
	}

	int forceRevertQuerySettings(com.etn.beans.Contexte Etn,String id,String siteId,String logedInUserId, String prodId){
		int rsp =0;
		Set rsForceRevert = Etn.execute("delete qs2.* from "+GlobalParm.getParm("EXPERT_SYSTEM_DB")+".query_settings_tbl qs1 join "+
			GlobalParm.getParm("EXPERT_SYSTEM_DB")+".query_settings_tbl qs2 on qs1.site_id=qs2.site_id and "+
			" qs1.query_id =qs2.query_id where qs2.is_deleted='0' AND qs1.qs_uuid="+escape.cote(id));
		
		Etn.executeCmd("UPDATE "+GlobalParm.getParm("EXPERT_SYSTEM_DB")+".query_settings_tbl SET is_deleted='0',updated_on=now(),updated_by="+
						escape.cote(logedInUserId)+" WHERE qs_uuid = "+escape.cote(prodId));

		rsp = 1;
		return rsp;

	}

	int revertCatalog(com.etn.beans.Contexte Etn,String id,String siteId,String logedInUserId){
		int rsp = 0;
		Set rsCatalog = Etn.execute("select c2.* from catalogs_tbl c1 join catalogs_tbl c2 on c1.name=c2.name and c1.site_id=c2.site_id and "+
			" c1.catalog_uuid=c2.catalog_uuid and c1.id !=c2.id where c1.id="+escape.cote(id));
		if(rsCatalog.next()){
			rsp = 1;
		}else{
			// reverting parent catalog
			Etn.executeCmd("UPDATE catalogs_tbl SET is_deleted='0',updated_on=now(),updated_by="+
				escape.cote(logedInUserId)+" WHERE id = "+escape.cote(id));
			
			Set rsProd=Etn.execute("select id from products_folders_tbl where coalesce(parent_folder_id,0) = 0 and catalog_id="+escape.cote(id));
			while(rsProd.next()){
				revertFolder(Etn,rsProd.value("ID"),siteId,logedInUserId);
			}
			
			com.etn.util.Logger.debug("trashAjax.jsp","Revert products for catalog : "+id);
			//	Deleting products related to catalog
			rsProd = Etn.execute("select id from products_tbl where catalog_id = "+escape.cote(id) );
			while(rsProd.next()){
				revertProduct(Etn,rsProd.value("ID"),siteId,logedInUserId);
			}
		}
		return rsp;
	}
	
	boolean isFormPublished(com.etn.beans.Contexte Etn,String name,String siteId){
		Set rs = Etn.execute("SELECT form_id FROM "+GlobalParm.getParm("FORMS_DB")+".process_forms WHERE process_name="+escape.cote(name)+" AND site_id="+escape.cote(siteId));
		if(rs!=null && rs.next() && rs.rs.Rows>0)
			return true;
		return false;
	}

	boolean isGamePublished(com.etn.beans.Contexte Etn,String name,String siteId){
		Set rs = Etn.execute("SELECT * FROM "+GlobalParm.getParm("FORMS_DB")+".games WHERE name="+escape.cote(name)+" AND site_id="+escape.cote(siteId));
		if(rs!=null && rs.next() && rs.rs.Rows>0)
			return true;
		return false;
	}

	void deleteForm(com.etn.beans.Contexte Etn,String id,String siteId){
		Set deleteProcessRs = Etn.execute("SELECT table_name, process_name, site_id FROM "+GlobalParm.getParm("FORMS_DB")+
			".process_forms_unpublished_tbl WHERE form_id = " + 
			escape.cote(id) + " and site_id = " + escape.cote(siteId));

		if(deleteProcessRs.next()) {

			String tblName = parseNull(deleteProcessRs.value("table_name"));		

			Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("FORMS_DB")+".coordinates where process = " + escape.cote(tblName));
			Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("FORMS_DB")+".rules WHERE start_proc = " + escape.cote(tblName) + 
				" AND next_proc = " + escape.cote(tblName));
			Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("FORMS_DB")+".phases WHERE process = " + escape.cote(tblName));
			Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("FORMS_DB")+".has_action WHERE start_proc = " + escape.cote(tblName));

			Etn.executeCmd("DELETE m FROM "+GlobalParm.getParm("FORMS_DB")+".mails_unpublished m INNER JOIN "+
				GlobalParm.getParm("FORMS_DB")+".mail_config_unpublished mc ON m.id = mc.id "+
				"INNER JOIN "+GlobalParm.getParm("FORMS_DB")+".process_forms_unpublished_tbl pf ON mc.ordertype = pf.table_name WHERE pf.form_id = " + 
					escape.cote(id));

			Etn.executeCmd("DELETE mc FROM "+GlobalParm.getParm("FORMS_DB")+".mail_config_unpublished mc INNER JOIN "+
				GlobalParm.getParm("FORMS_DB")+".process_forms_unpublished_tbl pf ON mc.ordertype = pf.table_name "+
				"WHERE pf.form_id = " + escape.cote(id));

			Etn.executeCmd("DELETE fr FROM "+GlobalParm.getParm("FORMS_DB")+".freq_rules_unpublished fr INNER JOIN "+
				GlobalParm.getParm("FORMS_DB")+".process_forms_unpublished_tbl pf ON fr.form_id = pf.form_id "+
				"WHERE pf.form_id = " + escape.cote(id));

			Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("FORMS_DB")+".process_form_field_descriptions_unpublished WHERE form_id = " + escape.cote(id));
			Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("FORMS_DB")+".process_form_fields_unpublished WHERE form_id = " + escape.cote(id));
			Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("FORMS_DB")+".process_form_lines_unpublished WHERE form_id = " + escape.cote(id));
			Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("FORMS_DB")+".process_form_fields_unpublished WHERE form_id = " + escape.cote(id));

			Set rsExists = Etn.execute("SELECT * FROM information_schema.TABLES WHERE TABLE_SCHEMA = "+
				escape.cote(GlobalParm.getParm("FORMS_DB"))+" AND TABLE_TYPE LIKE 'BASE TABLE' AND TABLE_NAME = "+ escape.cote(tblName));

			if(rsExists.next()){
				long millis = System.currentTimeMillis();

				Etn.execute("Alter table "+GlobalParm.getParm("FORMS_DB")+"."+tblName+" rename to "+GlobalParm.getParm("FORMS_DB")+".del_"+millis);

				Etn.executeCmd("insert into "+GlobalParm.getParm("FORMS_DB")+".original_forms_names (site_id, table_name,table_new_name) values("+escape.cote(siteId)+", "+escape.cote(tblName)+","+escape.cote("del_"+millis)+")");
			}else{
				Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("FORMS_DB")+".process_forms_unpublished_tbl WHERE form_id = " + escape.cote(id));
			}
		}
	}

	int revertForm(com.etn.beans.Contexte Etn, String id, String siteId,String severity,String logedInUserId)
	{
		Set rsCheckTrash= Etn.execute("SELECT f1.form_id as 'id_1', f1.process_name as 'name1', f1.is_deleted , f2.process_name as 'name2', f2.is_deleted,f2.form_id as 'id' "+
                "FROM "+GlobalParm.getParm("FORMS_DB")+".process_forms_unpublished_tbl f1 left JOIN "+
				GlobalParm.getParm("FORMS_DB")+".process_forms_unpublished_tbl f2 ON f1.process_name=f2.process_name "+
                "AND f1.form_id != f2.form_id AND f1.site_id=f2.site_id "+
                "WHERE f1.form_id="+escape.cote(id)+" AND f1.site_id = " + escape.cote(siteId));
		
		rsCheckTrash.next();
		if(!severity.equalsIgnoreCase("force")){
			if(rsCheckTrash.value("id").equals("")){
				Etn.executeCmd("UPDATE "+GlobalParm.getParm("FORMS_DB")+".process_forms_unpublished_tbl SET is_deleted='0', updated_on=now(),updated_by="+
					escape.cote(logedInUserId)+" WHERE form_id = "+escape.cote(id));
			}else{
				return 1;
			}
		}else{
			try{
				if(!isFormPublished(Etn,rsCheckTrash.value("name2"),siteId)){
					deleteForm(Etn,rsCheckTrash.value("id"),siteId);
					Etn.executeCmd("UPDATE "+GlobalParm.getParm("FORMS_DB")+".process_forms_unpublished_tbl SET is_deleted='0',updated_on=now(),updated_by="+
						escape.cote(logedInUserId)+" WHERE form_id = "+escape.cote(id));
				}else
				{
					return 2;
				}
			}catch(Exception e){
				Etn.executeCmd("UPDATE "+GlobalParm.getParm("FORMS_DB")+".process_forms_unpublished_tbl SET is_deleted='0',updated_on=now(),updated_by="+
					escape.cote(logedInUserId)+" WHERE form_id = "+escape.cote(id));
			}
		}
		return 0;
	}

	int revertGame(com.etn.beans.Contexte Etn,String id,String siteId,String severity,String logedInUserId)
	{
		Set rsCheckTrash= Etn.execute("SELECT f1.name as 'name1',f1.is_deleted,f1.form_id as 'form_id_1' ,f2.name as 'name2', f2.is_deleted, f2.id as 'id', f2.form_id as 'form_id_2' "+
                "FROM "+GlobalParm.getParm("FORMS_DB")+".games_unpublished f1 left JOIN "+
				GlobalParm.getParm("FORMS_DB")+".games_unpublished f2 ON f1.name=f2.name "+
                "AND f1.id != f2.id AND f1.site_id=f2.site_id "+
                "WHERE f1.id="+escape.cote(id)+" AND f1.site_id = " + escape.cote(siteId));
		rsCheckTrash.next();
		if(!severity.equalsIgnoreCase("force")){
			if(rsCheckTrash.value("id").equals("")){
				Etn.executeCmd("UPDATE "+GlobalParm.getParm("FORMS_DB")+".games_unpublished SET is_deleted='0',updated_on=now(),updated_by="+
					escape.cote(logedInUserId)+" WHERE id = "+escape.cote(id));
				return revertForm(Etn, parseNull(rsCheckTrash.value("form_id_1")), siteId, severity, logedInUserId);
			}else{
				return 1;
			}
		}else{
			try{
				
				if(!isGamePublished(Etn,rsCheckTrash.value("name2"),siteId)){
					deleteGame(Etn,rsCheckTrash.value("id"),siteId);
					deleteForm(Etn,rsCheckTrash.value("form_id_2"),siteId);
					Etn.executeCmd("UPDATE "+GlobalParm.getParm("FORMS_DB")+".games_unpublished SET is_deleted='0',updated_on=now(),updated_by="+
						escape.cote(logedInUserId)+" WHERE id = "+escape.cote(id));
				}else
				{
					return 2;
				}
			}catch(Exception e){
				Etn.executeCmd("UPDATE "+GlobalParm.getParm("FORMS_DB")+".games_unpublished SET is_deleted='0',updated_on=now(),updated_by="+
					escape.cote(logedInUserId)+" WHERE id = "+escape.cote(id));
			}
			return revertForm(Etn, parseNull(rsCheckTrash.value("form_id_1")), siteId, severity, logedInUserId);
		}
		
	}

	void deleteGamePrize(com.etn.beans.Contexte Etn,String gameId){
		Etn.execute("DELETE FROM "+GlobalParm.getParm("FORMS_DB")+".game_prize_unpublished WHERE game_uuid="+escape.cote(gameId));
	}

	void deleteGame(com.etn.beans.Contexte Etn,String gameId,String siteId){
		Set rs = Etn.execute("SELECT id, form_id FROM "+GlobalParm.getParm("FORMS_DB")+".games_unpublished where id="+escape.cote(gameId)+" and site_id="+escape.cote(siteId));
		if(rs!=null && rs.next() && rs.rs.Rows>0)
			deleteForm(Etn,parseNull(rs.value("form_id")),siteId);
		deleteGamePrize(Etn,gameId);
		Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("FORMS_DB")+".games_unpublished WHERE id = "+escape.cote(gameId)+" AND site_id="+escape.cote(siteId));
	}

	void deleteAdditionalFee(com.etn.beans.Contexte Etn,String id,String siteId){
		Etn.executeCmd("DELETE FROM additionalfee_rules WHERE add_fee_id = " + escape.cote(id));
		Etn.executeCmd("DELETE FROM additionalfees_tbl WHERE id = " + escape.cote(id));	
	}
	void deleteCartPromotion(com.etn.beans.Contexte Etn,String id,String siteId){
		Etn.executeCmd("DELETE FROM cart_promotion_coupon WHERE cp_id = " + escape.cote(id));
		Etn.executeCmd("DELETE FROM cart_promotion_tbl WHERE id = " + escape.cote(id));
	}
	void deletePromotion(com.etn.beans.Contexte Etn,String id,String siteId){
		Etn.executeCmd("delete from promotions_rules where promotion_id = " + escape.cote(id));
		Etn.executeCmd("delete from promotions_tbl where id = " + escape.cote(id));
	}
	void deleteComeWith(com.etn.beans.Contexte Etn,String id,String siteId){
		Etn.executeCmd("DELETE FROM comewiths_rules WHERE comewith_id = " + escape.cote(id));
		Etn.executeCmd("DELETE FROM comewiths_tbl WHERE id = " + escape.cote(id));
	}
	void deleteSubsidies(com.etn.beans.Contexte Etn,String id,String siteId){
		Etn.executeCmd("DELETE FROM subsidies_rules WHERE subsidy_id = " + escape.cote(id));
		Etn.executeCmd("DELETE FROM subsidies_tbl WHERE id = " + escape.cote(id));
	}
	void deleteDeliveryFee(com.etn.beans.Contexte Etn,String id,String siteId){
		Etn.executeCmd("delete from deliveryfees_rules where deliveryfee_id = " + escape.cote(id));
		Etn.executeCmd("delete from deliveryfees_tbl where id = " + escape.cote(id));
	}
	void deleteBlocTemplate(com.etn.beans.Contexte Etn,String id,String siteId){
		Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("PAGES_DB")+".bloc_templates_libraries WHERE bloc_template_id = " + escape.cote(id));
		Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("PAGES_DB")+".sections_fields_details WHERE field_id IN ( SELECT id FROM "+
			GlobalParm.getParm("PAGES_DB")+".sections_fields where section_id in "+
			"(SELECT id FROM "+GlobalParm.getParm("PAGES_DB")+".bloc_templates_sections WHERE bloc_template_id = "+escape.cote(id)+" ))");

		Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("PAGES_DB")+".sections_fields WHERE section_id IN ( SELECT id FROM "+
			GlobalParm.getParm("PAGES_DB")+".bloc_templates_sections WHERE bloc_template_id = "+escape.cote(id)+" )");

		Etn.executeCmd(" DELETE FROM "+GlobalParm.getParm("PAGES_DB")+".bloc_templates_sections WHERE bloc_template_id = "+escape.cote(id));
		Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("PAGES_DB")+".bloc_templates_tbl WHERE id = " + escape.cote(id));
	}
	void deletePageTemplate(com.etn.beans.Contexte Etn,String id,String siteId){
		Etn.executeCmd("DELETE pt, items, details, bl "
			+ " FROM "+GlobalParm.getParm("PAGES_DB")+".page_templates_tbl pt "
			+ " LEFT JOIN "+GlobalParm.getParm("PAGES_DB")+".page_templates_items items ON pt.id = items.page_template_id "
			+ " LEFT JOIN "+GlobalParm.getParm("PAGES_DB")+".page_templates_items_details details ON details.item_id = items.id "
			+ " LEFT JOIN "+GlobalParm.getParm("PAGES_DB")+".page_templates_items_blocs bl ON bl.item_id = items.id "
			+ " WHERE pt.id = " + escape.cote(id)
			+ " AND pt.site_id = " + escape.cote(siteId));
	}

	String revertProduct(com.etn.beans.Contexte Etn,String id,String siteId,String logedInUserId){
		Set rsProd=Etn.execute("select folder_id from products_tbl WHERE id="+escape.cote(id));
		rsProd.next();
		if(rsProd.value("FOLDER_ID")!=null){
			rsProd=Etn.execute("SELECT * from products_folders_tbl where id = "+escape.cote(rsProd.value("FOLDER_ID"))+" AND is_deleted='1'");
			if(!rsProd.next()){
				Set rsProduct = Etn.execute("select p2.id from products_tbl p1 join products_tbl p2 on p1.catalog_id=p2.catalog_id and p1.folder_id=p2.folder_id and "+
					"(p1.lang_1_name=p2.lang_1_name) and p2.is_deleted=0 where p1.id="+escape.cote(id));
				if(rsProduct.rs.Rows==0){
					Set rspage = Etn.execute("select page_id from "+GlobalParm.getParm("PAGES_DB")+".products_map_pages where product_id="+escape.cote(id));
					if(rspage.next()){
						revertStructuredPage(Etn,rspage.value("page_id"),siteId);
					}
					Etn.executeCmd("UPDATE products_tbl SET is_deleted='0',updated_on=now(),updated_by="+escape.cote(logedInUserId)+" WHERE id = "+escape.cote(id));
					Etn.executeCmd("UPDATE products_definition_tbl SET is_deleted='0',updated_ts=now(),updated_by="+escape.cote(logedInUserId)+
						" WHERE id = (select product_definition_id from products where id="+escape.cote(id)+")");
					return "";
				}
				else{
					return "Product already exist.";
				}
			}else{
				Set rsProd1 = Etn.execute("select lang_1_name from products_tbl where id="+escape.cote(id));
				rsProd1.next();

				return "Revert parent folder : "+rsProd.value("NAME")+" to revert product : "+rsProd1.value("LANG_1_NAME");
			}
		}else{
			rsProd=Etn.execute("SELECT * from catalogs_tbl where id = (select catalog_id from products_tbl WHERE id="+escape.cote(id)+") AND is_deleted='1'");
			if(!rsProd.next()){
				Set rsProduct = Etn.execute("select p2.id from products_tbl p1 join products_tbl p2 on p1.catalog_id=p2.catalog_id and p1.folder_id=p2.folder_id and "+
				" CONCAT( COALESCE(p1.lang_1_name,'') ,'-', COALESCE(p1.lang_2_name,'') ,'-', COALESCE(p1.lang_3_name,'') ,'-', COALESCE(p1.lang_4_name,'') ,'-', "+
				"COALESCE(p1.lang_5_name,'') )=CONCAT( COALESCE(p2.lang_1_name,'') ,'-', COALESCE(p2.lang_2_name,'') ,'-', COALESCE(p2.lang_3_name,'') ,'-', "+
				"COALESCE(p2.lang_4_name,'') ,'-', COALESCE(p2.lang_5_name,'') ) and p2.is_deleted=0 where p1.id="+escape.cote(id));
				
				if(rsProduct.rs.Rows==0){
					Etn.executeCmd("UPDATE products_tbl SET is_deleted='0',updated_on=now(),updated_by="+
						escape.cote(logedInUserId)+" WHERE id = "+escape.cote(id));
					return "";
				}else{
					return "Product already exist.";
				}
			}else{
				Set rsProd2 = Etn.execute("select lang_1_name from products_tbl where id="+escape.cote(id));
				rsProd2.next();

				return "Revert parent folder : "+rsProd.value("NAME")+" to revert product : "+rsProd2.value("LANG_1_NAME");
			}
		}
	}

	void revertFolder(com.etn.beans.Contexte Etn,String id,String siteId,String logedInUserId){
		// reverting parent folder
		Etn.executeCmd("UPDATE products_folders_tbl SET is_deleted='0',updated_on=now(),updated_by="+escape.cote(logedInUserId)+
			" WHERE id = "+escape.cote(id));

		Set rsFolder = Etn.execute("select id from products_folders_tbl where parent_folder_id="+escape.cote(id));
		while(rsFolder.next()){
			revertFolder(Etn,rsFolder.value("ID"),siteId,logedInUserId);
		}
		
		com.etn.util.Logger.debug("trashAjax.jsp","Revert products for folder : "+id);
		Set rsProd = Etn.execute("select id from products_tbl where folder_id = "+escape.cote(id) );
		while(rsProd.next()){
			revertProduct(Etn,rsProd.value("ID"),siteId,logedInUserId);
		}

	}

	String revertFiles(Contexte Etn,String id,String siteId,String logedInUserId,String severity){
			
		Set rsFiles=Etn.execute("SELECT ft.type as 'type',ft.is_deleted,ft.file_name as 'f1',ft2.is_deleted,ft2.file_name as 'f2',ft2.id as 'ftid' from "+
			GlobalParm.getParm("PAGES_DB")+".files_tbl ft LEFT JOIN "+GlobalParm.getParm("PAGES_DB")+".files_tbl ft2 ON "+
			"ft.file_name=ft2.file_name AND ft.id != ft2.id and ft.site_id=ft2.site_id WHERE ft.id = "
			+escape.cote(id)+" AND ft.site_id = " + escape.cote(siteId));

		rsFiles.next();
		if(!severity.equalsIgnoreCase("force")){
			
			if(rsFiles.value("f2").equals("")){
				String fileName = rsFiles.value("f1");
				String fileType = rsFiles.value("type");
				String UPLOAD_DIR = GlobalParm.getParm("PAGES_UPLOAD_DIRECTORY") + siteId + "/"+fileType+"/";
				String TRASH_DIR = GlobalParm.getParm("TRASH_FOLDER") + siteId + "/"+ fileType + "/";
					
				File uploadDir = FileUtil.getFile(UPLOAD_DIR);//change
				FileUtil.mkDirs(uploadDir);//change

				String filePath = UPLOAD_DIR   +fileName;
				String trashFilePath = TRASH_DIR +fileName;
				
				File file = new File(filePath);
				File trashFile = new File(trashFilePath);
				
				try{

					FileUtils.copyFile(trashFile,file);

				}catch(Exception ex){
					
					return "Error in reverting file. refresh and try again";
				}

				if(trashFile.exists()){
					trashFile.delete();
				}

				if(isMediaType(fileType)){
					String[] folders = {"thumb", "og", "4x3"};
					for(String folder : folders){
						file = FileUtil.getFile(UPLOAD_DIR + folder + "/" );//change
						FileUtil.mkDirs(file);//change

						trashFile = FileUtil.getFile(TRASH_DIR  +  folder + "/" +fileName);//change
						file = FileUtil.getFile(UPLOAD_DIR + folder + "/" +fileName);//change

						try{
							FileUtils.copyFile(trashFile,file);
						}catch(Exception ex){
							return "Error in reverting file. refresh and try again.";
						}
						if(trashFile.exists()){
							trashFile.delete();
						}
					}
				}
				Etn.executeCmd("UPDATE "+GlobalParm.getParm("PAGES_DB")+".files_tbl SET is_deleted='0',updated_ts=now(),updated_by="+
					escape.cote(logedInUserId)+" WHERE id = "+escape.cote(id)+ " AND site_id = " + escape.cote(siteId));
				
			}else{
				return rsFiles.value("f1");
			}
		}else{
			deleteFiles(Etn,rsFiles.value("ftid"),siteId,logedInUserId,"upload");
			revertFiles(Etn,id, siteId, logedInUserId,"");
			
		}
		return "success";
	}

	String deleteFiles(Contexte Etn,String id,String siteId,String logedInUserId,String deleteType){
		Set rsFiles=Etn.execute("SELECT type ,file_name from "+GlobalParm.getParm("PAGES_DB")+".files_tbl WHERE id = "+
			escape.cote(id)+" AND site_id = " + escape.cote(siteId));
		
		if(rsFiles.next()){
			String fileName = rsFiles.value("file_name");
			String fileType = rsFiles.value("type");

			String TRASH_DIR = GlobalParm.getParm("TRASH_FOLDER");
			if(deleteType.equalsIgnoreCase("upload")){
				TRASH_DIR=TRASH_DIR.replace("trash","uploads");	
			}
			TRASH_DIR =TRASH_DIR+  siteId + "/"+ fileType + "/";

			File trashFile = new File(TRASH_DIR+fileName);
			if(trashFile.exists()){
				trashFile.delete();
			}
			if(isMediaType(fileType)){
				String[] folders = {"thumb", "og", "4x3"};
				for(String folder : folders){
					trashFile = new File(TRASH_DIR  +  folder + "/" +fileName);
					if(trashFile.exists()){
						trashFile.delete();
					}
				}
			}
			Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("PAGES_DB")+".libraries_files WHERE file_id = " + escape.cote(id));
			Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("PAGES_DB")+".files_tbl WHERE id = " + escape.cote(id) + 
				" AND site_id = " + escape.cote(siteId));
		}else{
			return rsFiles.value("file_name");
		}
		return "success";
	}

%>
<%
	String STATUS_SUCCESS = "SUCCESS", STATUS_ERROR = "ERROR";
	String message = "";
    String status = STATUS_SUCCESS;
    String requestType = parseNull(request.getParameter("requestType"));
    String severity = parseNull(request.getParameter("severity"));
	String productIds[] = request.getParameterValues("productId[]");
	String prodId = request.getParameter("prodId");
	String methoPerform = request.getParameter("method");
	String siteId = getSelectedSiteId(session);

    String logedInUserId = parseNull(Etn.getId());

	try{

		if("multiple".equalsIgnoreCase(requestType)){
			for(int i=0;i<productIds.length;i++){

				String method=productIds[i].substring(productIds[i].length() - 1);
				productIds[i]=productIds[i].substring(0, productIds[i].length() - 1);

				if(methoPerform.equalsIgnoreCase("revert")){

					if(method.equalsIgnoreCase("p")){
						message=revertProduct(Etn,productIds[i],siteId,logedInUserId);
						if(!message.equals("")){
							status = STATUS_ERROR;
						}
					}
					else if(method.equalsIgnoreCase("f")){
						revertFolder(Etn,productIds[i],siteId,logedInUserId);
					}
					else if(method.equalsIgnoreCase("c")){
						revertCatalog(Etn,productIds[i],siteId,logedInUserId);
					}
					else if(method.equalsIgnoreCase("o")){
						Set rsCheckTrash= Etn.execute("SELECT f1.process_name as 'name1',f1.is_deleted,f2.process_name as 'name2', f2.is_deleted,f2.form_id as 'id' "+
							"FROM "+GlobalParm.getParm("FORMS_DB")+".process_forms_unpublished_tbl f1 left JOIN "+
							GlobalParm.getParm("FORMS_DB")+".process_forms_unpublished_tbl f2 ON f1.process_name=f2.process_name "+
							"AND f1.form_id != f2.form_id AND f1.site_id=f2.site_id "+
							"WHERE f1.form_id="+escape.cote(productIds[i])+" AND f1.site_id = " + escape.cote(siteId));
						rsCheckTrash.next();
						if(rsCheckTrash.value("id").equals("")){
							Etn.executeCmd("UPDATE "+GlobalParm.getParm("FORMS_DB")+".process_forms_unpublished_tbl "+
								"SET is_deleted='0',updated_on=now(),updated_by="+escape.cote(logedInUserId)+" WHERE form_id = "+escape.cote(productIds[i]));
						}else{
							status =STATUS_ERROR;
							message+="<br>Form with name "+rsCheckTrash.value("name1")+" already exist. Cannot revert it.";
						}
					}
					else if(method.equalsIgnoreCase("a")){
						Etn.executeCmd("UPDATE additionalfees_tbl SET is_deleted='0',updated_on=now(),updated_by="+
							escape.cote(logedInUserId)+" WHERE id = "+escape.cote(productIds[i]));
					}
					else if(method.equalsIgnoreCase("t")){
						Etn.executeCmd("UPDATE cart_promotion_tbl SET is_deleted='0',updated_on=now(),updated_by="+
							escape.cote(logedInUserId)+" WHERE id = "+escape.cote(productIds[i]));
					}
					else if(method.equalsIgnoreCase("r")){
						Etn.executeCmd("UPDATE promotions_tbl SET is_deleted='0',updated_on=now(),updated_by="+
							escape.cote(logedInUserId)+" WHERE id = "+escape.cote(productIds[i]));
					}
					else if(method.equalsIgnoreCase("w")){
						Etn.executeCmd("UPDATE comewiths_tbl SET is_deleted='0',updated_on=now(),updated_by="+
							escape.cote(logedInUserId)+" WHERE id = "+escape.cote(productIds[i]));
					}
					else if(method.equalsIgnoreCase("s")){
						Etn.executeCmd("UPDATE subsidies_tbl SET is_deleted='0',updated_on=now(),updated_by="+
							escape.cote(logedInUserId)+" WHERE id = "+escape.cote(productIds[i]));
					}
					else if(method.equalsIgnoreCase("d")){
						Etn.executeCmd("UPDATE deliveryfees_tbl SET is_deleted='0',updated_on=now(),updated_by="+
							escape.cote(logedInUserId)+" WHERE id = "+escape.cote(productIds[i]));
					}
					else if(method.equalsIgnoreCase("m")){
						Etn.executeCmd("UPDATE deliverymins_tbl SET is_deleted='0',updated_on=now(),updated_by="+
							escape.cote(logedInUserId)+" WHERE id = "+escape.cote(productIds[i]));
					}
					else if(method.equalsIgnoreCase("b")){
						Set rsCheckTrash = Etn.execute("SELECT bt1.* FROM "+GlobalParm.getParm("PAGES_DB")+".bloc_templates_tbl bt1 JOIN "+GlobalParm.getParm("PAGES_DB")+
							".bloc_templates_tbl bt2 ON bt1.site_id=bt2.site_id AND bt1.custom_id=bt2.custom_id AND bt1.id!=bt2.id where bt1.id="+escape.cote(productIds[i]));
						
						if(rsCheckTrash.rs.Rows==0){
							Etn.executeCmd("UPDATE "+GlobalParm.getParm("PAGES_DB")+".bloc_templates_tbl SET is_deleted='0',updated_ts=now(),updated_by="+
								escape.cote(logedInUserId)+" WHERE id = "+escape.cote(productIds[i]));
						}else{
							rsCheckTrash.next();
							status = STATUS_ERROR;
							message += "<br>Cannot revert "+rsCheckTrash.value("name")+". Template already exist.";
						}
					}
					else if(method.equalsIgnoreCase("l")){
						Set rsCheckTrash= Etn.execute("SELECT f1.name as 'name1',f1.is_deleted,f2.name as 'name2', f2.is_deleted,f2.id as 'id' FROM "+
							GlobalParm.getParm("PAGES_DB")+".page_templates_tbl f1 JOIN "+GlobalParm.getParm("PAGES_DB")+
							".page_templates_tbl f2 ON f1.custom_id=f2.custom_id AND f1.id != f2.id AND f1.site_id=f2.site_id "+
							"WHERE f1.id="+escape.cote(productIds[i]));
						
						if(rsCheckTrash.rs.Rows==0){
							Etn.executeCmd("UPDATE "+GlobalParm.getParm("PAGES_DB")+".page_templates_tbl SET is_deleted='0',updated_ts=now(),updated_by="+
								escape.cote(logedInUserId)+" WHERE id = "+escape.cote(productIds[i]));
						}else{
							rsCheckTrash.next();
							status = STATUS_ERROR;
							message += "<br>Cannot revert "+rsCheckTrash.value("name1")+". Template already exist.";
						}
					}
					else if(method.equalsIgnoreCase("e")){
						String resp=revertFiles(Etn,productIds[i], siteId, logedInUserId,"");
						if(!resp.equalsIgnoreCase("success")){
							status = STATUS_ERROR;
							message += "<br>Cannot revert "+resp+". File already exist.";
						}
						
					}
					else if(method.equalsIgnoreCase("i")){
						//check duplicate in trash
						Set rsCheckTrash= Etn.execute("SELECT f1.name as 'name1',f1.is_deleted,f2.name as 'name2', f2.is_deleted,f2.id as 'id' FROM "+
							GlobalParm.getParm("PAGES_DB")+".libraries_tbl f1 left JOIN "+GlobalParm.getParm("PAGES_DB")+
							".libraries_tbl f2 ON f1.name=f2.name AND f1.id != f2.id AND f1.site_id=f2.site_id "+
							"WHERE f1.id="+escape.cote(productIds[i])+" AND f1.site_id = " + escape.cote(siteId));
						
						if(rsCheckTrash.value("name2").equals("")){
							Etn.executeCmd("UPDATE "+GlobalParm.getParm("PAGES_DB")+".libraries_tbl SET is_deleted='0',updated_ts=now(),updated_by="+
								escape.cote(logedInUserId)+" WHERE id = "+escape.cote(productIds[i]));
						}else{
							status = STATUS_ERROR;
							message += "<br>Cannot revert "+rsCheckTrash.value("name2")+". Library already exist.";
						}
					}
					else if(method.equalsIgnoreCase("q")){
						Etn.executeCmd("UPDATE quantitylimits_tbl SET is_deleted='0',updated_on=now(),updated_by="+
							escape.cote(logedInUserId)+" WHERE id = "+escape.cote(productIds[i]));
					}
					else if(method.equalsIgnoreCase("g")){
						int rsp3=0;
						Set rsExpertSystemQuery = Etn.execute("select qs2.* from "+GlobalParm.getParm("EXPERT_SYSTEM_DB")+".query_settings_tbl qs1 join "+
							GlobalParm.getParm("EXPERT_SYSTEM_DB")+".query_settings_tbl qs2 on qs1.site_id=qs2.site_id and "+
							" qs1.query_id =qs2.query_id where qs2.is_deleted='0' AND qs1.qs_uuid="+escape.cote(productIds[i]));
						
						if(rsExpertSystemQuery.next()){
							rsp3 = 1;
							status = STATUS_ERROR;
							message = "Selected query setting can not be reverted as duplicate present in Expert System V2.";
						}else{
							Etn.executeCmd("UPDATE "+GlobalParm.getParm("EXPERT_SYSTEM_DB")+".query_settings_tbl SET is_deleted='0',updated_on=now(),updated_by="+
								escape.cote(logedInUserId)+" WHERE qs_uuid = "+escape.cote(productIds[i]));
							
							status = STATUS_SUCCESS;
							message = "successfully reverted selected query settings";

							}

						//Etn.executeCmd("UPDATE "+GlobalParm.getParm("EXPERT_SYSTEM_DB")+".query_settings_tbl SET is_deleted='0',updated_on=now(),updated_by="+
						//	escape.cote(logedInUserId)+" WHERE qs_uuid = "+escape.cote(productIds[i]));
					}
					else if("forceRevertQuerySettingsMultiple".equalsIgnoreCase(requestType)){
						Set rsForceRevert = Etn.execute("delete qs2.* from "+GlobalParm.getParm("EXPERT_SYSTEM_DB")+".query_settings_tbl qs1 join "+
							GlobalParm.getParm("EXPERT_SYSTEM_DB")+".query_settings_tbl qs2 on qs1.site_id=qs2.site_id and "+
							" qs1.query_id =qs2.query_id where qs2.is_deleted='0' AND qs1.qs_uuid="+escape.cote(productIds[i]));
						
						Etn.executeCmd("UPDATE "+GlobalParm.getParm("EXPERT_SYSTEM_DB")+".query_settings_tbl SET is_deleted='0',updated_on=now(),updated_by="+
										escape.cote(logedInUserId)+" WHERE qs_uuid = "+escape.cote(productIds[i]));

										status= STATUS_SUCCESS;
										message = "Selected Items reverted by force!";

					}
					else if(method.equalsIgnoreCase("j")){

						Set rsReactPage=Etn.execute("select name from "+GlobalParm.getParm("PAGES_DB")+".structured_contents_tbl where id="+escape.cote(productIds[i]));
						rsReactPage.next();

						if(!revertStructuredPage(Etn,productIds[i],siteId).equals("success")){
							status =STATUS_ERROR;
							message +="Cannot revert page "+rsReactPage.value("name")+". It already exist.";
						}
					}
					else if(method.equalsIgnoreCase("k")){
						Set rsReactPage=Etn.execute("select name from "+GlobalParm.getParm("PAGES_DB")+".freemarker_pages_tbl where id="+escape.cote(productIds[i]));
						rsReactPage.next();

						if(!revertBlocPages(Etn,productIds[i],siteId).equals("success")){
							status =STATUS_ERROR;
							message +="Cannot revert page "+rsReactPage.value("name")+". It already exist.";
						}
					}
					else if(method.equalsIgnoreCase("h")){
						
						Set rsReactPage=Etn.execute("select name from "+GlobalParm.getParm("PAGES_DB")+".pages_tbl where id="+escape.cote(productIds[i]));
						rsReactPage.next();

						if(!revertReactPage(Etn,productIds[i],siteId).equals("success")){
							status =STATUS_ERROR;
							message +="Cannot revert page "+rsReactPage.value("name")+". It already exist.";
						}
					}
					else if(method.equalsIgnoreCase("n")){

						Set rsPageFolders=Etn.execute("select name from "+GlobalParm.getParm("PAGES_DB")+".folders_tbl where id="+escape.cote(productIds[i]));
						rsPageFolders.next();

						if(!revertFolder1(Etn,productIds[i],siteId).equals("success")){
							status =STATUS_ERROR;
							message +="Cannot revert folder "+rsPageFolders.value("name")+". It already exist.";
						}
					}else if(method.equalsIgnoreCase("z")){
						revertGame(Etn,productIds[i],siteId,"",logedInUserId);
					}

				}
				else if(methoPerform.equalsIgnoreCase("delete")){

					if(method.equalsIgnoreCase("p")){
						deleteProduct(Etn,productIds[i],siteId);
					}
					else if(method.equalsIgnoreCase("f")){
						deleteFolder(Etn,productIds[i],siteId);
					}
					else if(method.equalsIgnoreCase("c")){
						deleteCatalog(Etn,productIds[i],siteId);
					}
					else if(method.equalsIgnoreCase("o")){
						deleteForm(Etn,productIds[i],siteId);
					}
					else if(method.equalsIgnoreCase("a")){
						deleteAdditionalFee(Etn,productIds[i],siteId);
					}
					else if(method.equalsIgnoreCase("t")){
						deleteCartPromotion(Etn,productIds[i],siteId);
					}
					else if(method.equalsIgnoreCase("r")){
						deletePromotion(Etn,productIds[i],siteId);
					}
					else if(method.equalsIgnoreCase("w")){
						deleteComeWith(Etn,productIds[i],siteId);
					}
					else if(method.equalsIgnoreCase("s")){
						deleteSubsidies(Etn,productIds[i],siteId);
					}
					else if(method.equalsIgnoreCase("d")){
						deleteDeliveryFee(Etn,productIds[i],siteId);
					}
					else if(method.equalsIgnoreCase("m")){
						Etn.executeCmd("delete from deliverymins_tbl where id = " + escape.cote(productIds[i]));
					}
					else if(method.equalsIgnoreCase("b")){
						deleteBlocTemplate(Etn,productIds[i],siteId);
					}
					else if(method.equalsIgnoreCase("l")){
						deletePageTemplate(Etn,productIds[i],siteId);
					}
					else if(method.equalsIgnoreCase("e")){
						String resp=deleteFiles(Etn,productIds[i],siteId,logedInUserId,"");
						if(!resp.equalsIgnoreCase("success")){
							status = STATUS_ERROR;
							message += "<br>Cannot delete "+resp+".";
						}
					}
					else if(method.equalsIgnoreCase("i")){
						Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("PAGES_DB")+".libraries_files WHERE library_id = " + escape.cote(productIds[i]));
						Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("PAGES_DB")+".libraries_tbl WHERE id = " + escape.cote(productIds[i]));
					}
					else if(method.equalsIgnoreCase("q")){
						Etn.executeCmd("delete from quantitylimits_rules where quantitylimit_id = " + escape.cote(productIds[i]));
						Etn.executeCmd("delete from quantitylimits_tbl where id = " + escape.cote(productIds[i]));
					}
					else if(method.equalsIgnoreCase("g")){
						Etn.execute("delete from "+GlobalParm.getParm("EXPERT_SYSTEM_DB")+".query_settings_tbl where qs_uuid = "+escape.cote(productIds[i]));
					}
					else if(method.equalsIgnoreCase("j")){
						String st=deletecontentPages(Etn,productIds[i],siteId,"");
						if(!st.equalsIgnoreCase("success")){
							status = STATUS_ERROR;
							message += st;
						}
					}
					else if(method.equalsIgnoreCase("k")){
						String st=deleteblocPages(Etn,productIds[i],siteId,"");
						if(!st.equalsIgnoreCase("success")){
							status = STATUS_ERROR;
							message += st;
						}
					}
					else if(method.equalsIgnoreCase("h")){
						String st=deleteReactPages(Etn,productIds[i],siteId,"");
						if(!st.equalsIgnoreCase("success")){
							status = STATUS_ERROR;
							message += st;
						}
						
					}
					else if(method.equalsIgnoreCase("n")){
						deletePagesFolders(Etn,productIds[i],siteId,"");
					}else if(method.equalsIgnoreCase("z")){
						deleteGame(Etn,productIds[i],siteId);
					}
				}
			}
		}
		else if("deleteProduct".equalsIgnoreCase(requestType)){
			deleteProduct(Etn,prodId,siteId);
		}
		else if("revertProduct".equalsIgnoreCase(requestType)){
			message = revertProduct(Etn,prodId,siteId,logedInUserId);
			if(!message.equals("")){
				status = STATUS_ERROR;
			}
		}
		else if("deleteCatalog".equalsIgnoreCase(requestType)){
			deleteCatalog(Etn,prodId,siteId);
		}
		else if("revertCatalog".equalsIgnoreCase(requestType)){
			
			int rsp = revertCatalog(Etn,prodId,siteId,logedInUserId);
			if(rsp==1){
				status = STATUS_ERROR;
				message = "Catalog can not be deleted as duplicate present in Products screen.";
			}
		}
		else if("deleteFolder".equalsIgnoreCase(requestType)){
			deleteFolder(Etn,prodId,siteId);
		}
		else if("revertFolder".equalsIgnoreCase(requestType)){
			revertFolder(Etn,prodId,siteId,logedInUserId);
		}else if("deleteGame".equalsIgnoreCase(requestType)){
			deleteGame(Etn,prodId,siteId);
		}
		else if("deleteForm".equalsIgnoreCase(requestType)){
			deleteForm(Etn,prodId,siteId);
		}
		else if("revertForm".equalsIgnoreCase(requestType)){
			int val = revertForm(Etn,prodId,siteId,severity,logedInUserId);
			if(val == 1){
				status = STATUS_ERROR;
				message="Form with this name exist.";
			}
			else if(val == 2)
			{
				status = STATUS_ERROR;
				message="Form with this name is published";
			}
		}
		else if("revertGame".equalsIgnoreCase(requestType))
		{
			int val = revertGame(Etn,prodId,siteId,severity,logedInUserId);
			if(val == 1){
				status = STATUS_ERROR;
				message="Game with this name exist.";
			}else if(val == 2)
			{
				status = STATUS_ERROR;
				message="Game with this name is published";
			}
		}
		else if("deleteAdditional".equalsIgnoreCase(requestType)){
			deleteAdditionalFee(Etn,prodId,siteId);
		}
		else if("revertAdditional".equalsIgnoreCase(requestType)){
			Etn.executeCmd("UPDATE additionalfees_tbl SET is_deleted='0',updated_on=now(),updated_by="+
				escape.cote(logedInUserId)+" WHERE id = "+escape.cote(prodId));
		}
		else if("deleteCartPromotion".equalsIgnoreCase(requestType)){
			deleteCartPromotion(Etn,prodId,siteId);
		}
		else if("revertCartPromotion".equalsIgnoreCase(requestType)){
			Etn.executeCmd("UPDATE cart_promotion_tbl SET is_deleted='0',updated_on=now(),updated_by="+
				escape.cote(logedInUserId)+" WHERE id = "+escape.cote(prodId));
		}
		else if("deletePromotion".equalsIgnoreCase(requestType)){
			deletePromotion(Etn,prodId,siteId);
		}
		else if("revertPromotion".equalsIgnoreCase(requestType)){
			Etn.executeCmd("UPDATE promotions_tbl SET is_deleted='0',updated_on=now(),updated_by="+
				escape.cote(logedInUserId)+" WHERE id = "+escape.cote(prodId));
		}
		else if("deleteComewith".equalsIgnoreCase(requestType)){
			deleteComeWith(Etn,prodId,siteId);
		}
		else if("revertComewith".equalsIgnoreCase(requestType)){
			Etn.executeCmd("UPDATE comewiths_tbl SET is_deleted='0',updated_on=now(),updated_by="+
				escape.cote(logedInUserId)+" WHERE id = "+escape.cote(prodId));
		}
		else if("deleteSubsidies".equalsIgnoreCase(requestType)){
			deleteSubsidies(Etn,prodId,siteId);
		}
		else if("revertSubsidies".equalsIgnoreCase(requestType)){
			Etn.executeCmd("UPDATE subsidies_tbl SET is_deleted='0',updated_on=now(),updated_by="+
				escape.cote(logedInUserId)+" WHERE id = "+escape.cote(prodId));
		}
		else if("deleteDelivery".equalsIgnoreCase(requestType)){
			deleteDeliveryFee(Etn,prodId,siteId);
		}
		else if("revertDelivery".equalsIgnoreCase(requestType)){
			Etn.executeCmd("UPDATE deliveryfees_tbl SET is_deleted='0',updated_on=now(),updated_by="+
				escape.cote(logedInUserId)+" WHERE id = "+escape.cote(prodId));
		}
		else if("deleteDeliveryMins".equalsIgnoreCase(requestType)){
			Etn.executeCmd("delete from deliverymins_tbl where id = " + escape.cote(prodId));
		}
		else if("revertDeliveryMins".equalsIgnoreCase(requestType)){
			Etn.executeCmd("UPDATE deliverymins_tbl SET is_deleted='0',updated_on=now(),updated_by="+
				escape.cote(logedInUserId)+" WHERE id = "+escape.cote(prodId));
		}
		else if("deleteBlockTemplates".equalsIgnoreCase(requestType)){
			deleteBlocTemplate(Etn,prodId,siteId);
		}
		else if("revertBlockTemplates".equalsIgnoreCase(requestType)){
			
			Set rsCheckTrash = Etn.execute("SELECT bt1.name,bt2.id FROM "+GlobalParm.getParm("PAGES_DB")+".bloc_templates_tbl bt1 JOIN "+
				GlobalParm.getParm("PAGES_DB")+".bloc_templates_tbl bt2 ON bt1.site_id=bt2.site_id AND bt1.custom_id=bt2.custom_id AND bt1.id!=bt2.id where bt1.id="+
				escape.cote(prodId));
			
			rsCheckTrash.next();
			if(!severity.equalsIgnoreCase("force")){
				if(rsCheckTrash.rs.Rows==0){
					Etn.executeCmd("UPDATE "+GlobalParm.getParm("PAGES_DB")+".bloc_templates_tbl SET is_deleted='0',updated_ts=now(),updated_by="+
						escape.cote(logedInUserId)+" WHERE id = "+escape.cote(prodId));
				}else{
					status = STATUS_ERROR;
					message = "Cannot revert "+rsCheckTrash.value("name")+". Template already exist.";
				}
			}else{
				deleteBlocTemplate(Etn,rsCheckTrash.value("id"),siteId);
				Etn.executeCmd("UPDATE "+GlobalParm.getParm("PAGES_DB")+".bloc_templates_tbl SET is_deleted='0',updated_ts=now(),updated_by="+
					escape.cote(logedInUserId)+" WHERE id = "+escape.cote(prodId));
			}
		}
		else if("deletePageTemplate".equalsIgnoreCase(requestType)){
			deletePageTemplate(Etn,prodId,siteId);
		}
		else if("revertPageTemplate".equalsIgnoreCase(requestType)){
			Set rsCheckTrash= Etn.execute("SELECT f1.name as 'name1',f1.is_deleted,f2.name as 'name2', f2.is_deleted,f2.id as 'id' FROM "+
				GlobalParm.getParm("PAGES_DB")+".page_templates_tbl f1 JOIN "+GlobalParm.getParm("PAGES_DB")+
				".page_templates_tbl f2 ON f1.custom_id=f2.custom_id AND f1.id != f2.id AND f1.site_id=f2.site_id "+
				"WHERE f1.id="+escape.cote(prodId));
			
			rsCheckTrash.next();
			if(!severity.equalsIgnoreCase("force")){
				if(rsCheckTrash.rs.Rows==0){
					Etn.executeCmd("UPDATE "+GlobalParm.getParm("PAGES_DB")+".page_templates_tbl SET is_deleted='0',updated_ts=now(),updated_by="+
						escape.cote(logedInUserId)+" WHERE id = "+escape.cote(prodId));
				}else{
					status = STATUS_ERROR;
					message = "Cannot revert "+rsCheckTrash.value("name1")+". Page template already exist.";
				}
			}else{
				deletePageTemplate(Etn,rsCheckTrash.value("id"),siteId);
				Etn.executeCmd("UPDATE "+GlobalParm.getParm("PAGES_DB")+".page_templates_tbl SET is_deleted='0',updated_ts=now(),updated_by="+
					escape.cote(logedInUserId)+" WHERE id = "+escape.cote(prodId));
			}
		}
		else if("deleteFiles".equalsIgnoreCase(requestType)){
			String resp=deleteFiles(Etn,prodId,siteId,logedInUserId,"");
			if(!resp.equalsIgnoreCase("success")){
				status = STATUS_ERROR;
				message += "<br>Cannot delete "+resp+".";
			}
		}
		else if("revertFiles".equalsIgnoreCase(requestType)){
			String resp=revertFiles(Etn,prodId, siteId, logedInUserId,severity);
			if(!resp.equalsIgnoreCase("success")){
				status = STATUS_ERROR;
				message = "Cannot revert "+resp+". File already exist.";
			}
		}
		else if("deleteLibrary".equalsIgnoreCase(requestType)){
			Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("PAGES_DB")+".libraries_files WHERE library_id = " + escape.cote(prodId));
			Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("PAGES_DB")+".libraries_tbl WHERE id = " + escape.cote(prodId));
		}
		else if("revertLibrary".equalsIgnoreCase(requestType)){
			//check duplicate in trash
			Set rsCheckTrash= Etn.execute("SELECT f1.name as 'name1',f1.is_deleted,f2.name as 'name2', f2.is_deleted,f2.id as 'id' FROM "+
				GlobalParm.getParm("PAGES_DB")+".libraries_tbl f1 left JOIN "+GlobalParm.getParm("PAGES_DB")+
				".libraries_tbl f2 ON f1.name=f2.name AND f1.id != f2.id AND f1.site_id=f2.site_id "+
				"WHERE f1.id="+escape.cote(prodId)+" AND f1.site_id = " + escape.cote(siteId));
			rsCheckTrash.next();
			if(!severity.equalsIgnoreCase("force")){
				if(rsCheckTrash.value("name2").equals("")){
					Etn.executeCmd("UPDATE "+GlobalParm.getParm("PAGES_DB")+".libraries_tbl SET is_deleted='0',updated_ts=now(),updated_by="+
						escape.cote(logedInUserId)+" WHERE id = "+escape.cote(prodId));
				}
				else{
					status =STATUS_ERROR;
					message ="Library with name "+rsCheckTrash.value("name2")+" alreay exist.";
				}
			}else{
				Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("PAGES_DB")+".libraries_files WHERE library_id = " + escape.cote(rsCheckTrash.value("id")));
				Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("PAGES_DB")+".libraries_tbl WHERE id = " + escape.cote(rsCheckTrash.value("id")));
				Etn.executeCmd("UPDATE "+GlobalParm.getParm("PAGES_DB")+".libraries_tbl SET is_deleted='0',updated_ts=now(),updated_by="+
					escape.cote(logedInUserId)+" WHERE id = "+escape.cote(prodId));
			}
		}
		else if("deleteQuantityLimits".equalsIgnoreCase(requestType)){
			Etn.executeCmd("delete from quantitylimits_rules where quantitylimit_id = " + escape.cote(prodId));
			Etn.executeCmd("delete from quantitylimits_tbl where id = " + escape.cote(prodId));
		}
		else if("revertQuantityLimits".equalsIgnoreCase(requestType)){
			Etn.executeCmd("UPDATE quantitylimits_tbl SET is_deleted='0',updated_on=now(),updated_by="+escape.cote(logedInUserId)+" WHERE id = "+escape.cote(prodId));
		}
		else if("deleteExpertSystem".equalsIgnoreCase(requestType)){
			Etn.execute("delete from "+GlobalParm.getParm("EXPERT_SYSTEM_DB")+".query_settings_tbl where qs_uuid = "+escape.cote(prodId));  
		}
		else if("revertExpertSystem".equalsIgnoreCase(requestType)){
			
			int rsp2 = revertExpertSystemQueries(Etn,prodId,siteId,logedInUserId,prodId); 
			if(rsp2==1){
				status = STATUS_ERROR;
				message = "Query Setting can not be deleted as duplicate present in Expert System V2.";
			}
			//Etn.executeCmd("UPDATE "+GlobalParm.getParm("EXPERT_SYSTEM_DB")+".query_settings_tbl SET is_deleted='0',updated_on=now(),updated_by="+
			//	escape.cote(logedInUserId)+" WHERE qs_uuid = "+escape.cote(prodId));
		}
		else if("forceRevertQuerySettings".equalsIgnoreCase(requestType)){
			int rsp2 = forceRevertQuerySettings(Etn,prodId,siteId,logedInUserId,prodId);
			if(rsp2 == 1){
				status = STATUS_SUCCESS;
				message = "Successfully reverted by force!";
			}
			else{
				status = STATUS_ERROR;
				message = "Could not be reverted by force!";
			}
		}
		else if("deleteContentpage".equalsIgnoreCase(requestType)){
			String st=deletecontentPages(Etn,prodId,siteId,"");
			if(!st.equalsIgnoreCase("success")){
				status = STATUS_ERROR;
				message += st;
			}
		}
		else if("revertContentpage".equalsIgnoreCase(requestType)){
			Set rsReactPage=Etn.execute("select name from "+GlobalParm.getParm("PAGES_DB")+".structured_contents_tbl where id="+escape.cote(prodId));
			rsReactPage.next();

			if(!severity.equalsIgnoreCase("force")){
				if(!revertStructuredPage(Etn,prodId,siteId).equals("success")){
					status =STATUS_ERROR;
					message +="Cannot revert page "+rsReactPage.value("name")+". It already exist.";
				}
			}else{
				rsReactPage = Etn.execute("select id,name from "+GlobalParm.getParm("PAGES_DB")+".structured_contents_tbl where name = (select name from "+GlobalParm.getParm("PAGES_DB")+".structured_contents_tbl where id="+escape.cote(prodId)+") and id !="+escape.cote(prodId));
				if(rsReactPage.next()){
					String st=deletecontentPages(Etn,rsReactPage.value("id"),siteId,"force");
					if(!st.equalsIgnoreCase("success")){
						status = STATUS_ERROR;
						message += st;
					}else{
						if(!revertStructuredPage(Etn,prodId,siteId).equals("success")){
							status =STATUS_ERROR;
							message +="Cannot revert page "+rsReactPage.value("name")+". It already exist.";
						}
					}
				}
			}
		}
		else if("deleteBlocpage".equalsIgnoreCase(requestType)){
			String st=deleteblocPages(Etn,prodId,siteId,"");
			if(!st.equalsIgnoreCase("success")){
				status = STATUS_ERROR;
				message += st;
			}
		}
		else if("revertBlocpage".equalsIgnoreCase(requestType)){
			Set rsReactPage=Etn.execute("select name from "+GlobalParm.getParm("PAGES_DB")+".freemarker_pages_tbl where id="+escape.cote(prodId));
			rsReactPage.next();

			if(!severity.equalsIgnoreCase("force")){
				if(!revertBlocPages(Etn,prodId,siteId).equals("success")){
					status =STATUS_ERROR;
					message +="Cannot revert page "+rsReactPage.value("name")+". It already exist.";
				}
			}else{
				rsReactPage = Etn.execute("select id,name from "+GlobalParm.getParm("PAGES_DB")+".freemarker_pages_tbl where name = (select name from "+GlobalParm.getParm("PAGES_DB")+".freemarker_pages_tbl where id="+escape.cote(prodId)+") and id !="+escape.cote(prodId));
				if(rsReactPage.next()){
					String st=deleteblocPages(Etn,rsReactPage.value("id"),siteId,"force");
					if(!st.equalsIgnoreCase("success")){
						status = STATUS_ERROR;
						message += st;
					}else{
						if(!revertBlocPages(Etn,prodId,siteId).equals("success")){
							status =STATUS_ERROR;
							message +="Cannot revert page "+rsReactPage.value("name")+". It already exist.";
						}
					}
				}
			}
		}
		else if("deleteReactpage".equalsIgnoreCase(requestType)){
			String st=deleteReactPages(Etn,prodId,siteId,"");
			if(!st.equalsIgnoreCase("success")){
				status = STATUS_ERROR;
				message += st;
			}
		}
		else if("revertReactpage".equalsIgnoreCase(requestType)){
			
			Set rsReactPage=Etn.execute("select name from "+GlobalParm.getParm("PAGES_DB")+".pages_tbl where id="+escape.cote(prodId));
			rsReactPage.next();

			if(!severity.equalsIgnoreCase("force")){
				if(!revertReactPage(Etn,prodId,siteId).equals("success")){
					status =STATUS_ERROR;
					message +="Cannot revert page "+rsReactPage.value("name")+". It already exist.";
				}
			}else{
				rsReactPage = Etn.execute("select id,name from "+GlobalParm.getParm("PAGES_DB")+".pages_tbl where name = (select name from "+GlobalParm.getParm("PAGES_DB")+".pages_tbl where id="+escape.cote(prodId)+") and id !="+escape.cote(prodId));
				if(rsReactPage.next()){
					String st=deleteReactPages(Etn,rsReactPage.value("id"),siteId,"force");
					if(!st.equalsIgnoreCase("success")){
						status = STATUS_ERROR;
						message += st;
					}else{
						if(!revertReactPage(Etn,prodId,siteId).equals("success")){
							status =STATUS_ERROR;
							message +="Cannot revert page "+rsReactPage.value("name")+". It already exist.";
						}
					}
				}
			}
		}
		else if("revertPagesfolder".equalsIgnoreCase(requestType)){
			
			Set rsReactPage=Etn.execute("select name from "+GlobalParm.getParm("PAGES_DB")+".folders_tbl where id="+escape.cote(prodId));
			rsReactPage.next();

			if(!severity.equalsIgnoreCase("force")){
				if(!revertFolder1(Etn,prodId,siteId).equals("success")){
					status =STATUS_ERROR;
					message +="Cannot revert folder "+rsReactPage.value("name")+". It already exist.";
				}
			}else{
				rsReactPage = Etn.execute("select id,name from "+GlobalParm.getParm("PAGES_DB")+".folders_tbl where name = (select name from "+GlobalParm.getParm("PAGES_DB")+
					".folders_tbl where id="+escape.cote(prodId)+") and type = (select type from "+GlobalParm.getParm("PAGES_DB")+".folders_tbl where id="+escape.cote(prodId)+
					") and parent_folder_id = (select parent_folder_id from "+GlobalParm.getParm("PAGES_DB")+".folders_tbl where id="+escape.cote(prodId)+
					") and site_id="+escape.cote(siteId)+" and id !="+escape.cote(prodId));
				if(rsReactPage.next()){
					deletePagesFolders(Etn,rsReactPage.value("id"),siteId,"force");
					if(!revertFolder1(Etn,prodId,siteId).equals("success")){
						status =STATUS_ERROR;
						message +="Cannot revert page "+rsReactPage.value("name")+". It already exist.";
					}
					
				}
			}
		}
		else if("deletePagesfolder".equalsIgnoreCase(requestType)){
			deletePagesFolders(Etn,prodId,siteId,"");
		}
	}catch(Exception e){
		status =STATUS_ERROR;
		message ="Some error occurred while processing your request.";
	}

	response.setContentType("application/json");
  	out.write("{\"status\":\""+status+"\",\"message\":\""+message+"\"}");

%>
