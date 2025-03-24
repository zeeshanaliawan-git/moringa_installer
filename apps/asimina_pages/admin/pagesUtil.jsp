<%@ page
        import="com.etn.beans.app.GlobalParm, com.etn.Client.Impl.ClientSql, java.util.ArrayList, java.util.HashMap, java.util.LinkedHashMap, com.etn.pages.PagesUtil, com.etn.pages.PagesGenerator, com.etn.pages.FilesUtil, com.etn.pages.EntityImport, com.etn.pages.EntityExport,  com.etn.pages.Constant, com.etn.beans.Etn, com.etn.pages.excel.ExcelEntityImport, org.apache.poi.openxml4j.exceptions.InvalidFormatException, com.etn.pages.excel.ExcelImportFile, com.github.wnameless.json.unflattener.JsonUnflattener, java.util.regex.Pattern, org.json.JSONException" %>
<%!
    public void markPagesToGenerate(String id, String type, com.etn.beans.Contexte Etn) {
        // here "type" indicates which entity(table name) which is updated
        // e.g. blocs, bloc_template , library
        // "id" is the corresponding entity table id
        String q = "", q2 = "";
		
		System.out.println("In markPagesToGenerate id:"+id+" type:"+type);
	
        if ("blocs".equals(type)) {

            q = " UPDATE freemarker_pages p "
                + " JOIN ("
                + "     SELECT p.id FROM freemarker_pages p "   // blocs of freemarker pages
                + "     JOIN parent_pages_blocs pb ON pb.page_id = p.id "
                + "     JOIN blocs b ON b.id = pb.bloc_id "
                + "     WHERE b.id = " + escape.cote(id)
                + "   UNION "
                + "     SELECT DISTINCT fp.id from freemarker_pages fp" // blocs in page template of freemaker pages
                + "     JOIN pages p ON p.parent_page_id = fp.id AND p.type = "+escape.cote(Constant.PAGE_TYPE_FREEMARKER)
                + "     JOIN page_templates pt ON pt.id = p.template_id "
                + "     JOIN page_templates_items pti ON pti.page_template_id = pt.id "
                + "     JOIN page_templates_items_blocs ptb ON ptb.item_id = pti.id AND ptb.type = 'bloc' "
                + "     JOIN blocs b ON b.id = ptb.bloc_id "
                + "     WHERE b.id = " + escape.cote(id)
                + " ) as t ON t.id = p.id"
                + " SET "
				+ " p.updated_by = "+escape.cote(""+Etn.getId()) +","
				+ " p.updated_ts = now(), "				
                + " p.to_generate = '1', "
                + " p.to_generate_by = " + escape.cote("" + Etn.getId())
//                + " p.to_publish = CASE WHEN p.published_ts IS NOT NULL AND p.updated_ts <= p.published_ts THEN 1 ELSE p.to_publish END,"
//                + " p.to_publish_by = CASE WHEN p.published_ts IS NOT NULL AND p.updated_ts <= p.published_ts THEN "+ escape.cote("" + Etn.getId()) +" ELSE p.to_publish_by END,"
//                + " p.to_publish_ts = CASE WHEN p.published_ts IS NOT NULL AND p.updated_ts <= p.published_ts THEN NOW() ELSE p.to_publish_ts END"
                + " WHERE p.is_deleted = '0'";

            q2 = " UPDATE structured_contents sc "
                    + " JOIN ("
//                    + "     SELECT p.id FROM structured_contents p " // blocs in structured contents(for future if there will be blocs in structured)
//                    + "     JOIN parent_pages_blocs pb ON pb.page_id = p.id "
//                    + "     JOIN blocs b ON b.id = pb.bloc_id "
//                    + "     WHERE b.id = " + escape.cote(id)
//                    + "   UNION "
                    + "     SELECT DISTINCT sc.id from structured_contents sc" // page template blocs of structured
                    + "     JOIN pages p ON p.parent_page_id = sc.id AND p.type = "+escape.cote(Constant.PAGE_TYPE_STRUCTURED)
                    + "     JOIN page_templates pt ON pt.id = p.template_id "
                    + "     JOIN page_templates_items pti ON pti.page_template_id = pt.id "
                    + "     JOIN page_templates_items_blocs ptb ON ptb.item_id = pti.id AND ptb.type = 'bloc' "
                    + "     JOIN blocs b ON b.id = ptb.bloc_id "
                    + "     WHERE b.id = " + escape.cote(id)
                    + " ) as t ON t.id = sc.id"
                    + " SET "
					+ " sc.updated_by = "+escape.cote(""+Etn.getId()) +","
					+ " sc.updated_ts = now(), "					
                    + " sc.to_generate = '1', "
                    + " sc.to_generate_by = " + escape.cote("" + Etn.getId());
//                    + " sc.to_publish = CASE WHEN sc.published_ts IS NOT NULL AND sc.updated_ts <= sc.published_ts THEN 1 ELSE sc.to_publish END,"
//                    + " sc.to_publish_by = CASE WHEN sc.published_ts IS NOT NULL AND sc.updated_ts <= sc.published_ts THEN "+ escape.cote("" + Etn.getId()) +" ELSE sc.to_publish_by END,"
//                    + " sc.to_publish_ts = CASE WHEN sc.published_ts IS NOT NULL AND sc.updated_ts <= sc.published_ts THEN NOW() ELSE sc.to_publish_ts END";

        }
        else if ("bloc_templates".equals(type)) {

            q = " UPDATE freemarker_pages p "
                + " JOIN("
                + "     SELECT DISTINCT p.id FROM freemarker_pages p"  //blocs in pages
                + "     JOIN parent_pages_blocs pb ON pb.page_id = p.id "
                + "     JOIN blocs b ON b.id = pb.bloc_id "
                + "     JOIN bloc_templates bt ON bt.id = b.template_id "
                + "     WHERE bt.id = " + escape.cote(id)
                + "  UNION "
                + "     SELECT DISTINCT fp.id from freemarker_pages fp"
                + "     JOIN pages p ON p.parent_page_id = fp.id AND p.type = "+escape.cote(Constant.PAGE_TYPE_FREEMARKER)
                + "     JOIN page_templates pt ON pt.id = p.template_id "
                + "     JOIN page_templates_items pti ON pti.page_template_id = pt.id "
                + "     JOIN page_templates_items_blocs ptb ON ptb.item_id = pti.id AND ptb.type = 'bloc' "
                + "     JOIN blocs b ON b.id = ptb.bloc_id "
                + "     JOIN bloc_templates bt ON bt.id = b.template_id "
                + "     WHERE bt.id = " + escape.cote(id)
                + " ) as t ON t.id = p.id"
                + " SET "
				+ " p.updated_by = "+escape.cote(""+Etn.getId()) +","
				+ " p.updated_ts = now(), "
                + " p.to_generate = '1', "
                + " p.to_generate_by = " + escape.cote("" + Etn.getId())
//                + " p.to_publish = CASE WHEN p.published_ts IS NOT NULL AND p.updated_ts <= p.published_ts THEN 1 ELSE p.to_publish END,"
//                + " p.to_publish_by = CASE WHEN p.published_ts IS NOT NULL AND p.updated_ts <= p.published_ts THEN "+ escape.cote("" + Etn.getId()) +" ELSE p.to_publish_by END,"
//                + " p.to_publish_ts = CASE WHEN p.published_ts IS NOT NULL AND p.updated_ts <= p.published_ts THEN NOW() ELSE p.to_publish_ts END"
                + " WHERE p.is_deleted = '0'";

            q2 = " UPDATE structured_contents sc "
                    + " JOIN("
                    + "     SELECT sc.id FROM structured_contents sc"
                    + "     JOIN bloc_templates bt ON bt.id = sc.template_id "
                    + "     WHERE bt.id = " + escape.cote(id)
                    + "  UNION "
                    + "     SELECT DISTINCT fp.id from structured_contents fp"
                    + "     JOIN pages p ON p.parent_page_id = fp.id AND p.type = "+escape.cote(Constant.PAGE_TYPE_STRUCTURED)
                    + "     JOIN page_templates pt ON pt.id = p.template_id "
                    + "     JOIN page_templates_items pti ON pti.page_template_id = pt.id "
                    + "     JOIN page_templates_items_blocs ptb ON ptb.item_id = pti.id AND ptb.type = 'bloc' "
                    + "     JOIN blocs b ON b.id = ptb.bloc_id "
                    + "     JOIN bloc_templates bt ON bt.id = b.template_id "
                    + "     WHERE bt.id = " + escape.cote(id)
                    + " ) as t ON t.id = sc.id"
                    + " SET "
					+ " sc.updated_by = "+escape.cote(""+Etn.getId()) +","
					+ " sc.updated_ts = now(), "
                    + " sc.to_generate = '1', "
                    + " sc.to_generate_by = " + escape.cote("" + Etn.getId());
//                    + " sc.to_publish = CASE WHEN sc.published_ts IS NOT NULL AND sc.updated_ts <= sc.published_ts THEN 1 ELSE sc.to_publish END,"
//                    + " sc.to_publish_by = CASE WHEN sc.published_ts IS NOT NULL AND sc.updated_ts <= sc.published_ts THEN "+ escape.cote("" + Etn.getId()) +" ELSE sc.to_publish_by END,"
//                    + " sc.to_publish_ts = CASE WHEN sc.published_ts IS NOT NULL AND sc.updated_ts <= sc.published_ts THEN NOW() ELSE sc.to_publish_ts END";

        }
        else if ("libraries".equals(type)) {

            q = " UPDATE freemarker_pages p "
                + " JOIN ("
                + "     SELECT DISTINCT p.id FROM freemarker_pages p"
                + "     JOIN parent_pages_blocs pb ON pb.page_id = p.id "
                + "     JOIN blocs b ON b.id = pb.bloc_id "
                + "     JOIN bloc_templates bt ON bt.id = b.template_id "
                + "     JOIN bloc_templates_libraries btl ON btl.bloc_template_id = bt.id "
                + "     JOIN libraries l ON l.id = btl.library_id "
                + "     WHERE l.id = " + escape.cote(id)
                + "  UNION "
                + "     SELECT DISTINCT fp.id from freemarker_pages fp"
                + "     JOIN pages p ON p.parent_page_id = fp.id AND p.type = "+escape.cote(Constant.PAGE_TYPE_FREEMARKER)
                + "     JOIN page_templates pt ON pt.id = p.template_id "
                + "     JOIN page_templates_items pti ON pti.page_template_id = pt.id "
                + "     JOIN page_templates_items_blocs ptb ON ptb.item_id = pti.id AND ptb.type = 'bloc' "
                + "     JOIN blocs b ON b.id = ptb.bloc_id "
                + "     JOIN bloc_templates bt ON bt.id = b.template_id "
                + "     JOIN bloc_templates_libraries btl ON btl.bloc_template_id = bt.id "
                + "     JOIN libraries l ON l.id = btl.library_id "
                + "     WHERE l.id = " + escape.cote(id)
                + " ) as t ON t.id = p.id"
                + " SET "
				+ " p.updated_by = "+escape.cote(""+Etn.getId()) +","
				+ " p.updated_ts = now(), "				
                + " p.to_generate = '1', "
                + " p.to_generate_by = " + escape.cote("" + Etn.getId())
//                + " p.to_publish = CASE WHEN p.published_ts IS NOT NULL AND p.updated_ts <= p.published_ts THEN 1 ELSE p.to_publish END,"
//                + " p.to_publish_by = CASE WHEN p.published_ts IS NOT NULL AND p.updated_ts <= p.published_ts THEN "+ escape.cote("" + Etn.getId()) +" ELSE p.to_publish_by END,"
//                + " p.to_publish_ts = CASE WHEN p.published_ts IS NOT NULL AND p.updated_ts <= p.published_ts THEN NOW() ELSE p.to_publish_ts END"
                + " WHERE p.is_deleted = '0'";

            q2 = " UPDATE structured_contents sc "
                    + " JOIN ("
                    + "     SELECT DISTINCT sc.id FROM structured_contents sc"
                    + "     JOIN bloc_templates bt ON bt.id = sc.template_id "
                    + "     JOIN bloc_templates_libraries btl ON btl.bloc_template_id = bt.id "
                    + "     JOIN libraries l ON l.id = btl.library_id "
                    + "     WHERE l.id = " + escape.cote(id)
                    + "  UNION "
                    + "     SELECT DISTINCT fp.id from structured_contents fp"
                    + "     JOIN pages p ON p.parent_page_id = fp.id AND p.type = "+escape.cote(Constant.PAGE_TYPE_STRUCTURED)
                    + "     JOIN page_templates pt ON pt.id = p.template_id "
                    + "     JOIN page_templates_items pti ON pti.page_template_id = pt.id "
                    + "     JOIN page_templates_items_blocs ptb ON ptb.item_id = pti.id AND ptb.type = 'bloc' "
                    + "     JOIN blocs b ON b.id = ptb.bloc_id "
                    + "     JOIN bloc_templates bt ON bt.id = b.template_id "
                    + "     JOIN bloc_templates_libraries btl ON btl.bloc_template_id = bt.id "
                    + "     JOIN libraries l ON l.id = btl.library_id "
                    + "     WHERE l.id = " + escape.cote(id)
                    + " ) as t ON t.id = sc.id"
                    + " SET "
					+ " sc.updated_by = "+escape.cote(""+Etn.getId()) +","
					+ " sc.updated_ts = now(), "					
                    + " sc.to_generate = '1', "
                    + " sc.to_generate_by = " + escape.cote("" + Etn.getId());
//                    + " sc.to_publish = CASE WHEN sc.published_ts IS NOT NULL AND sc.updated_ts <= sc.published_ts THEN 1 ELSE sc.to_publish END,"
//                    + " sc.to_publish_by = CASE WHEN sc.published_ts IS NOT NULL AND sc.updated_ts <= sc.published_ts THEN "+ escape.cote("" + Etn.getId()) +" ELSE sc.to_publish_by END,"
//                    + " sc.to_publish_ts = CASE WHEN sc.published_ts IS NOT NULL AND sc.updated_ts <= sc.published_ts THEN NOW() ELSE sc.to_publish_ts END";


        }
        else if ("files".equals(type)) {

            q = " UPDATE freemarker_pages p "
                + " JOIN("
                + "     SELECT DISTINCT p.id FROM freemarker_pages p"
                + "     JOIN parent_pages_blocs pb ON pb.page_id = p.id "
                + "     JOIN blocs b ON b.id = pb.bloc_id "
                + "     JOIN bloc_templates bt ON bt.id = b.template_id "
                + "     JOIN bloc_templates_libraries btl ON btl.bloc_template_id = bt.id "
                + "     JOIN libraries l ON l.id = btl.library_id "
                + "     JOIN libraries_files lf ON lf.library_id = l.id "
                + "     JOIN files fl on fl.id = lf.file_id "
                + "     WHERE fl.id = " + escape.cote(id)
				+ "		and bt.site_id = fl.site_id "
				+ "		and p.site_id = fl.site_id "  
				+ "		and l.site_id = fl.site_id "
				+ "		and b.site_id = fl.site_id "
                + "  UNION "
                + "     SELECT DISTINCT fp.id from freemarker_pages fp"
                + "     JOIN pages p ON p.parent_page_id = fp.id AND p.type = "+escape.cote(Constant.PAGE_TYPE_FREEMARKER)
                + "     JOIN page_templates pt ON pt.id = p.template_id "
                + "     JOIN page_templates_items pti ON pti.page_template_id = pt.id "
                + "     JOIN page_templates_items_blocs ptb ON ptb.item_id = pti.id AND ptb.type = 'bloc' "
                + "     JOIN blocs b ON b.id = ptb.bloc_id "
                + "     JOIN bloc_templates bt ON bt.id = b.template_id "
                + "     JOIN bloc_templates_libraries btl ON btl.bloc_template_id = bt.id "
                + "     JOIN libraries l ON l.id = btl.library_id "
                + "     JOIN libraries_files lf ON lf.library_id = l.id "
                + "     JOIN files fl on fl.id = lf.file_id "
                + "     WHERE fl.id = " + escape.cote(id)
				+ "		and fp.site_id = fl.site_id "  
				+ "		and bt.site_id = fl.site_id "
				+ "		and l.site_id = fl.site_id "
				+ "		and b.site_id = fl.site_id "
                + " ) as t ON t.id = p.id"
                + " SET "
				+ " p.updated_by = "+escape.cote(""+Etn.getId()) +","
				+ " p.updated_ts = now(), "				
                + " p.to_generate = '1', "
                + " p.to_generate_by = " + escape.cote("" + Etn.getId())
//                + " p.to_publish = CASE WHEN p.published_ts IS NOT NULL AND p.updated_ts <= p.published_ts THEN 1 ELSE p.to_publish END,"
//                + " p.to_publish_by = CASE WHEN p.published_ts IS NOT NULL AND p.updated_ts <= p.published_ts THEN "+ escape.cote("" + Etn.getId()) +" ELSE p.to_publish_by END,"
//                + " p.to_publish_ts = CASE WHEN p.published_ts IS NOT NULL AND p.updated_ts <= p.published_ts THEN NOW() ELSE p.to_publish_ts END"
                + " WHERE p.is_deleted = '0'";


            q2 = " UPDATE structured_contents sc "
                    + " JOIN ("
                    + "     SELECT DISTINCT sc.id FROM structured_contents sc"
                    + "     JOIN bloc_templates bt ON bt.id = sc.template_id "
                    + "     JOIN bloc_templates_libraries btl ON btl.bloc_template_id = bt.id "
                    + "     JOIN libraries l ON l.id = btl.library_id "
                    + "     JOIN libraries_files lf ON lf.library_id = l.id "
                    + "     JOIN files fl on fl.id = lf.file_id "
                    + "     WHERE fl.id = " + escape.cote(id)
                    + "     and sc.site_id = fl.site_id "
                    + "     and bt.site_id = fl.site_id "
                    + "     and l.site_id = fl.site_id "
                    + "  UNION "
                    + "     SELECT DISTINCT fp.id from structured_contents fp"
                    + "     JOIN pages p ON p.parent_page_id = fp.id AND p.type = "+escape.cote(Constant.PAGE_TYPE_STRUCTURED)
                    + "     JOIN page_templates pt ON pt.id = p.template_id "
                    + "     JOIN page_templates_items pti ON pti.page_template_id = pt.id "
                    + "     JOIN page_templates_items_blocs ptb ON ptb.item_id = pti.id AND ptb.type = 'bloc' "
                    + "     JOIN blocs b ON b.id = ptb.bloc_id "
                    + "     JOIN bloc_templates bt ON bt.id = b.template_id "
                    + "     JOIN bloc_templates_libraries btl ON btl.bloc_template_id = bt.id "
                    + "     JOIN libraries l ON l.id = btl.library_id "
                    + "     JOIN libraries_files lf ON lf.library_id = l.id "
                    + "     JOIN files fl on fl.id = lf.file_id "
                    + "     WHERE fl.id = " + escape.cote(id)
                    + "     and fp.site_id = fl.site_id "
					+ "		and bt.site_id = fl.site_id "
                    + "     and b.site_id = fl.site_id "
                    + "     and l.site_id = fl.site_id "
                    + " ) as t ON t.id = sc.id"
                    + " SET "
					+ " sc.updated_by = "+escape.cote(""+Etn.getId()) +","
					+ " sc.updated_ts = now(), "					
                    + " sc.to_generate = '1', "
                    + " sc.to_generate_by = " + escape.cote("" + Etn.getId());
//                    + " sc.to_publish = CASE WHEN sc.published_ts IS NOT NULL AND sc.updated_ts <= sc.published_ts THEN 1 ELSE sc.to_publish END,"
//                    + " sc.to_publish_by = CASE WHEN sc.published_ts IS NOT NULL AND sc.updated_ts <= sc.published_ts THEN "+ escape.cote("" + Etn.getId()) +" ELSE sc.to_publish_by END,"
//                    + " sc.to_publish_ts = CASE WHEN sc.published_ts IS NOT NULL AND sc.updated_ts <= sc.published_ts THEN NOW() ELSE sc.to_publish_ts END";


        }
        else if ("page_templates".equals(type)) {
            q = " UPDATE freemarker_pages p "
                + " JOIN ("
                + " SELECT DISTINCT fp.id FROM freemarker_pages fp "
                + " JOIN pages p ON p.parent_page_id = fp.id AND p.type = "+escape.cote(Constant.PAGE_TYPE_FREEMARKER)
                + " JOIN page_templates pt ON pt.id = p.template_id AND pt.site_id = p.site_id "
                + " WHERE pt.id = " + escape.cote(id)
                + " ) as t ON t.id = p.id"
                + " SET "
				+ " p.updated_by = "+escape.cote(""+Etn.getId()) +","
				+ " p.updated_ts = now(), "				
                + " p.to_generate = '1', "
                + " p.to_generate_by = " + escape.cote("" + Etn.getId())
//                + " p.to_publish = CASE WHEN p.published_ts IS NOT NULL AND p.updated_ts <= p.published_ts THEN 1 ELSE p.to_publish END,"
//                + " p.to_publish_by = CASE WHEN p.published_ts IS NOT NULL AND p.updated_ts <= p.published_ts THEN "+ escape.cote("" + Etn.getId()) +" ELSE p.to_publish_by END,"
//                + " p.to_publish_ts = CASE WHEN p.published_ts IS NOT NULL AND p.updated_ts <= p.published_ts THEN NOW() ELSE p.to_publish_ts END"
                + " WHERE p.is_deleted = '0'";

            q2 = " UPDATE structured_contents sc "
                    + " JOIN ("
                    + " SELECT DISTINCT sc.id FROM structured_contents sc"  //blocs in pages
                    + " JOIN pages p ON p.parent_page_id = sc.id AND p.type = "+escape.cote(Constant.PAGE_TYPE_STRUCTURED)
                    + " JOIN page_templates pt ON pt.id = p.template_id AND pt.site_id = p.site_id "
                    + " WHERE pt.id = " + escape.cote(id)
                    + " ) as t ON t.id = sc.id"
                    + " SET "
					+ " sc.updated_by = "+escape.cote(""+Etn.getId()) +","
					+ " sc.updated_ts = now(), "					
                    + " sc.to_generate = '1', "
                    + " sc.to_generate_by = " + escape.cote("" + Etn.getId());
//                    + " sc.to_publish = CASE WHEN sc.published_ts IS NOT NULL AND sc.updated_ts <= sc.published_ts THEN 1 ELSE sc.to_publish END,"
//                    + " sc.to_publish_by = CASE WHEN sc.published_ts IS NOT NULL AND sc.updated_ts <= sc.published_ts THEN "+ escape.cote("" + Etn.getId()) +" ELSE sc.to_publish_by END,"
//                    + " sc.to_publish_ts = CASE WHEN sc.published_ts IS NOT NULL AND sc.updated_ts <= sc.published_ts THEN NOW() ELSE sc.to_publish_ts END";

        }
        else if (Constant.FOLDER_TYPE_PAGES.equals(type) || Constant.FOLDER_TYPE_STORE.equals(type)) {
            String folderTable = getFolderTableName(type);
            q = " UPDATE freemarker_pages p "
                + " JOIN ("
                + " SELECT DISTINCT fp.id FROM freemarker_pages fp "
                + " LEFT JOIN "+folderTable+" pf1 ON pf1.id = fp.folder_id AND pf1.site_id = fp.site_id "
                + " LEFT JOIN "+folderTable+" pf2 ON pf2.id = pf1.parent_folder_id "
                + " LEFT JOIN "+folderTable+" pf3 ON pf3.id = pf2.parent_folder_id "
                + " WHERE IFNULL(pf1.id,-1) = " + escape.cote(id)
                + " OR IFNULL(pf2.id,-1) = " + escape.cote(id)
                + " OR IFNULL(pf3.id,-1) = " + escape.cote(id)
                + " ) as t ON t.id = p.id"
                + " SET "
				+ " p.updated_by = "+escape.cote(""+Etn.getId()) +","
				+ " p.updated_ts = now(), "				
                + " p.to_generate = '1', "
                + " p.to_generate_by = " + escape.cote("" + Etn.getId())
//                + " p.to_publish = CASE WHEN p.published_ts IS NOT NULL AND p.updated_ts <= p.published_ts THEN 1 ELSE p.to_publish END,"
//                + " p.to_publish_by = CASE WHEN p.published_ts IS NOT NULL AND p.updated_ts <= p.published_ts THEN "+ escape.cote("" + Etn.getId()) +" ELSE p.to_publish_by END,"
//                + " p.to_publish_ts = CASE WHEN p.published_ts IS NOT NULL AND p.updated_ts <= p.published_ts THEN NOW() ELSE p.to_publish_ts END"
                + " WHERE p.is_deleted = '0'";

            q2 = " UPDATE structured_contents sc "
                    + " JOIN ("
                    + " SELECT DISTINCT sc.id FROM structured_contents sc"
                    + " LEFT JOIN "+folderTable+" pf1 ON pf1.id = sc.folder_id AND pf1.site_id = sc.site_id "
                    + " LEFT JOIN "+folderTable+" pf2 ON pf2.id = pf1.parent_folder_id "
                    + " LEFT JOIN "+folderTable+" pf3 ON pf3.id = pf2.parent_folder_id "
                    + " WHERE IFNULL(pf1.id,-1) = " + escape.cote(id)
                    + " OR IFNULL(pf2.id,-1) = " + escape.cote(id)
                    + " OR IFNULL(pf3.id,-1) = " + escape.cote(id)
                    + " ) as t ON t.id = sc.id"
                    + " SET "
					+ " sc.updated_by = "+escape.cote(""+Etn.getId()) +","
					+ " sc.updated_ts = now(), "					
                    + " sc.to_generate = '1', "
                    + " sc.to_generate_by = " + escape.cote("" + Etn.getId());
//                    + " sc.to_publish = CASE WHEN sc.published_ts IS NOT NULL AND sc.updated_ts <= sc.published_ts THEN 1 ELSE sc.to_publish END,"
//                    + " sc.to_publish_by = CASE WHEN sc.published_ts IS NOT NULL AND sc.updated_ts <= sc.published_ts THEN "+ escape.cote("" + Etn.getId()) +" ELSE sc.to_publish_by END,"
//                    + " sc.to_publish_ts = CASE WHEN sc.published_ts IS NOT NULL AND sc.updated_ts <= sc.published_ts THEN NOW() ELSE sc.to_publish_ts END";
        }

        if (q.length() > 0) {
            Etn.executeCmd(q);
            System.out.println(q);
            if (q2.length() > 0) {
                Etn.executeCmd(q2);
                System.out.println(q2);
            }

            q = "SELECT semfree(" + escape.cote(parseNull(GlobalParm.getParm("SEMAPHORE"))) + ");";
            Etn.execute(q);
        }
    }

    /*
     * common function to reuse between normal page delete and structured page delete
     */
    public void deletePageCommon(String pageId, com.etn.beans.Contexte Etn) {

        String q = " SELECT html_file_path, published_html_file_path"
                   + " FROM pages "
                   + " WHERE id = " + escape.cote(pageId);
        Set rs = Etn.execute(q);
        if (!rs.next()) {
            return;
        }

        String pageHtmlPath = parseNull(rs.value("html_file_path"));
        String publishedHtmlPath = parseNull(rs.value("published_html_file_path"));

        String BASE_DIR = GlobalParm.getParm("BASE_DIR");
        String PAGES_SAVE_FOLDER = GlobalParm.getParm("PAGES_SAVE_FOLDER");
        String PAGES_PUBLISH_FOLDER = GlobalParm.getParm("PAGES_PUBLISH_FOLDER");

        if (pageHtmlPath.length() > 0) {
            String htmlFilePath = BASE_DIR + PAGES_SAVE_FOLDER + pageHtmlPath;
            File htmlFile = new File(htmlFilePath);
            if (htmlFile.exists()) {
                htmlFile.delete();
            }
        }

        if (publishedHtmlPath.length() > 0) {
            String publishedFilePath = BASE_DIR + PAGES_PUBLISH_FOLDER + publishedHtmlPath;
            File publishedFile = new File(publishedFilePath);
            if (publishedFile.exists()) {
                publishedFile.delete();
            }
        }

        q = " DELETE FROM pages_meta_tags WHERE page_id = " + escape.cote(pageId);
        Etn.executeCmd(q);

        q = "DELETE FROM pages_urls WHERE page_id = " + escape.cote(pageId);
        Etn.executeCmd(q);

        q = " DELETE pv "
            + " FROM page_item_property_values pv "
            + " JOIN page_items pi ON pv.page_item_id = pi.id "
            + " WHERE pi.page_id = " + escape.cote(pageId);
        Etn.executeCmd(q);

        q = " DELETE FROM page_items "
            + " WHERE page_id = " + escape.cote(pageId);
        Etn.executeCmd(q);

        q = "DELETE FROM pages WHERE id = " + escape.cote(pageId);
        Etn.executeCmd(q);

    }

    void deleteInvalidStructuredPages(com.etn.beans.Contexte Etn) {
        try {
            String q = "SELECT id, parent_page_id, type FROM pages "
                       + " WHERE type = " + escape.cote(Constant.PAGE_TYPE_STRUCTURED)
                       + " AND id NOT IN ( SELECT DISTINCT page_id FROM structured_contents_details WHERE page_id > 0 ) ";

            Set rs = Etn.execute(q);
            while (rs.next()) {
                String pageId = rs.value("id");
                deletePageCommon(pageId, Etn);
				Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("PAGES_DB")+".pages_tags WHERE page_type = "+escape.cote(rs.value("type"))+" and page_id = " + escape.cote(rs.value("parent_page_id")));
            }			
        }
        catch (Exception ex) {
            //ignore
        }

    }

    public int insertAdvanceParams(Etn Etn,JSONObject jObj,boolean is_field) throws Exception {
        return PagesUtil.insertAdvanceParams(Etn, jObj,is_field);
    }

    public void insertUpdateTemplateSections(Etn Etn,
                                             JSONArray sectionsList,
                                             String templateId,
                                             String parentSectionId,
                                             boolean isSystem) throws Exception, SimpleException {

        LinkedHashMap<String, String> colValueHM = new LinkedHashMap<>();
        ArrayList<String> sectionIdList = new ArrayList<>();
        String q = "";

        boolean isNewProductTemplate = false;
        if(templateId.equals("0")) isNewProductTemplate = PagesUtil.checkProductTypeFromSection(Etn,parentSectionId);
        else{
            Set rsTemplateType = Etn.execute("select type from bloc_templates where id="+escape.cote(templateId));
            if(rsTemplateType.next()) if(rsTemplateType.value("type").contains("product")) isNewProductTemplate=true;
        }

        for (int i = 0; i < sectionsList.length(); i++) {
            JSONObject section = sectionsList.getJSONObject(i);
            colValueHM.clear();
            Set rsCustomId = Etn.execute("select * from template_reserved_ids where item_id="+escape.cote(section.getString("custom_id")));
            if(rsCustomId.rs.Rows>0){
                if(isNewProductTemplate) colValueHM.put("is_new_product_item", escape.cote(parseNull(section.optString("is_new_product_item"))));
                else throw new SimpleException(section.getString("custom_id")+" is reserved id. Please use some other custom id for section.");
            }

            colValueHM.put("bloc_template_id", escape.cote(templateId));
            colValueHM.put("parent_section_id", escape.cote(parentSectionId));
            colValueHM.put("name", escape.cote(section.getString("name")));
            colValueHM.put("sort_order", escape.cote("" + i));
            colValueHM.put("nb_items", escape.cote(section.getString("nb_items")));
            colValueHM.put("description", escape.cote(section.getString("description")));
            colValueHM.put("is_collapse", escape.cote(section.getString("is_collapse")));

            colValueHM.put("updated_ts", "NOW()");
            colValueHM.put("updated_by", escape.cote("" + Etn.getId()));

            int sectionId = parseInt(section.optString("id"));

            if (isSystem) {
                colValueHM.put("is_system", "'1'");

                q = "SELECT id FROM bloc_templates_sections "
                    + " WHERE bloc_template_id = " + escape.cote(templateId)
                    + " AND parent_section_id = " + escape.cote(parentSectionId)
                    + " AND custom_id = " + escape.cote(section.getString("custom_id"));
                Set rs = Etn.execute(q);
                if (rs.next()) sectionId = parseInt(rs.value("id"));
            }

            if (sectionId <= 0) {
                //new section
                colValueHM.put("custom_id", escape.cote(section.getString("custom_id")));
                colValueHM.put("created_ts", "NOW()");
                colValueHM.put("created_by", escape.cote("" + Etn.getId()));
                
                q = getInsertQuery("bloc_templates_sections", colValueHM);
                
                sectionId = Etn.executeCmd(q);

                if (sectionId <= 0) {
                    throw new SimpleException("Error in creating new section. Please try again.");
                }
            }
            else {
                //existing section update
                q = getUpdateQuery("bloc_templates_sections", colValueHM, " WHERE id = " + escape.cote("" + sectionId));

                int count = Etn.executeCmd(q);
                if (count <= 0) throw new SimpleException("Error in updating existing section. Please try again.");
            }

            sectionIdList.add(escape.cote("" + sectionId));
            try{
            	section.put("id","" + sectionId);
	            insertAdvanceParams(Etn,section,false);
            }catch(Exception e){ throw new SimpleException("Advance Parameter Error");}
            
            //fields processing
            JSONArray fieldsList = section.getJSONArray("fields");
            insertUpdateTemplateSectionFields(Etn, fieldsList, "" + sectionId, isSystem);

            //nested sections processing
            JSONArray nestedSectionsList = section.getJSONArray("sections");
            insertUpdateTemplateSections(Etn, nestedSectionsList, "0", "" + sectionId, isSystem);

        }//for sectionsList

        if (!isSystem) {
            //deleted sections
            q = "DELETE FROM bloc_templates_sections WHERE bloc_template_id = " + escape.cote("" + templateId)
                + " AND parent_section_id = " + escape.cote(parentSectionId);
            if (sectionIdList.size() > 0) {
                q += " AND id NOT IN ( " + String.join(",", sectionIdList) + ")";
            }
            Etn.executeCmd(q);
        }

    }

    public void insertUpdateTemplateSectionFields(Etn Etn, JSONArray fieldsList, String sectionId, boolean isSystem) throws Exception, SimpleException {
		PagesUtil.insertUpdateTemplateSectionFields(Etn, fieldsList, sectionId, isSystem);
	}
	
    public int copyBlock(Etn Etn, String blocId, String name, String siteId) throws Exception, SimpleException {

        int newblocId = -1;
        LinkedHashMap<String, String> colValueHM = new LinkedHashMap<>();
        String q = "";

        if (name.length() == 0) {
            throw new SimpleException("Error: Name cannot be empty");
        }

        q = "SELECT * FROM blocs  "
            + " WHERE id = " + escape.cote(blocId)
            + " AND site_id = " + escape.cote(siteId);

        Set rs = Etn.execute(q);
        if (!rs.next()) {
            throw new SimpleException("Invalid parameters.");
        }

        for (String colName : rs.ColName) {
            colValueHM.put(colName.toLowerCase(), escape.cote(rs.value(colName)));
        }

        int pid = Etn.getId();
        colValueHM.remove("id");

        colValueHM.put("uuid", escape.cote(getUUID()));
        colValueHM.put("name", escape.cote(name));
        colValueHM.put("created_by", escape.cote("" + pid));
        colValueHM.put("updated_by", escape.cote("" + pid));
        colValueHM.put("created_ts", "NOW()");
        colValueHM.put("updated_ts", "NOW()");

        q = getInsertQuery("blocs", colValueHM);

        newblocId = Etn.executeCmd(q);
        if (newblocId > 0) {
            //copy tag
            q = "INSERT INTO blocs_tags(bloc_id, tag_id) "
                + " SELECT " + escape.cote("" + newblocId) + ", tag_id FROM blocs_tags "
                + " WHERE bloc_id = " + escape.cote(blocId);
            Etn.executeCmd(q);

            q = "INSERT INTO blocs_details(bloc_id, langue_id, template_data) "
                + " SELECT " + escape.cote("" + newblocId) + ", langue_id,  template_data FROM blocs_details "
                + " WHERE bloc_id = " + escape.cote(blocId);
            Etn.executeCmd(q);
        }
        return newblocId;
    }

    JSONArray getPagePrefixPathsByFolderId(Contexte Etn, String folderId, String siteId) {

        String q = "SELECT f.langue_id, l.langue_code, concat_path FROM pages_folders_lang_path f"
                   + " JOIN language l on l.langue_id = f.langue_id"
                   + " WHERE f.folder_id = " + escape.cote(folderId)
                   + " AND f.site_id = " + escape.cote(siteId);
        Set rs = Etn.execute(q);
        JSONArray pagePathPrefix = new JSONArray();
        while (rs.next()) {
            pagePathPrefix.put(getJSONObject(rs));
        }
        return pagePathPrefix;
    }

    boolean deleteFolder(Contexte Etn, String id, String siteId, String folderType) throws SimpleException {
        final String folderTable = getFolderTableName(folderType);

        try {
            String q = " SELECT id, name "
                       + " FROM " + folderTable
                       + " WHERE id = " + escape.cote(id)
                       + " AND site_id = " + escape.cote(siteId);
            Set rs = Etn.execute(q);
            if (!rs.next()) {
                return false;
            }

            String curName = rs.value("name");

            q = "SELECT id from ("
                + "  SELECT id FROM " + folderTable
                + "  WHERE parent_folder_id = " + escape.cote(id)
                + "  AND site_id = " + escape.cote(siteId);

            if (folderType.equals(Constant.FOLDER_TYPE_CONTENTS)) {
                q += " UNION ALL"
                     + "  SELECT id FROM structured_contents "
                     + "  WHERE folder_id= " + escape.cote(id)
                     + "  AND site_id = " + escape.cote(siteId)
                     + "  AND type = 'content' ";
            }
            else {
                // bloc
                q += " UNION ALL"
                     + "  SELECT id FROM freemarker_pages "
                     + "  WHERE folder_id= " + escape.cote(id)
                     + "  AND site_id = " + escape.cote(siteId)
                     + " AND  is_deleted = '0'";
                // structured
                q += " UNION ALL"
                     + "  SELECT id FROM structured_contents "
                     + "  WHERE folder_id= " + escape.cote(id)
                     + "  AND site_id = " + escape.cote(siteId)
                     + "  AND type = 'page' ";
            }
            q += ") count_table";

            rs = Etn.execute(q);
            if (rs.rs.Rows > 0) {
                return false;
            }

            q = "DELETE FROM " + folderTable
                + " WHERE id = " + escape.cote(id)
                + " AND site_id = " + escape.cote(siteId);
            Etn.executeCmd(q);

            q = "DELETE FROM folders_details "
                + " WHERE folder_id = " + escape.cote(id);
            Etn.executeCmd(q);

            return true;
        }//try
        catch (Exception ex) {
            throw new SimpleException("Error in deleting folders.", ex);
        }
    }

    JSONObject getPageInfo(Contexte Etn, String pageId, String siteId) throws SimpleException {
        int STATUS_SUCCESS = 1, STATUS_ERROR = 0;
        int status = STATUS_ERROR;
        JSONObject data = new JSONObject();
        String message = "";
        LinkedHashMap<String, String> colValueHM = new LinkedHashMap<>();

        String q = "";
        Set rs = null;
        JSONObject retObj = new JSONObject();

        try{

            JSONObject pageObj = new JSONObject();
            JSONObject curObj = null;

            q = "SELECT * FROM pages "
                + " WHERE id = " + escape.cote(pageId)
                + " AND site_id = " + escape.cote(siteId);

            rs = Etn.execute(q);

            if(rs.rs.Rows <= 0){
                throw new SimpleException("Error: page not found.");
            }

            if(rs.next()){
                for(String colName : rs.ColName){
                    pageObj.put(colName.toLowerCase(), rs.value(colName));
                }
            }

            String parentPageId = rs.value("parent_page_id");
            String pageType = rs.value("type");
            String pageLayout = rs.value("layout");

            //get prefix paths list per language
            pageObj.put("pagePathPrefixList", getPagePrefixPathsByFolderId(Etn, rs.value("folder_id"), siteId));

            if(Constant.PAGE_TYPE_FREEMARKER.equals(pageType) || Constant.PAGE_TYPE_STRUCTURED.equals(pageType)){

                q = " SELECT meta_name, meta_content FROM pages_meta_tags "
                + " WHERE page_id = " + escape.cote(pageId)
                + " ORDER BY meta_name ";
                Set mRs = Etn.execute(q);
                JSONArray customMetaTags = new JSONArray();
                while(mRs.next()){
                    JSONObject metaTag = new JSONObject();
                    metaTag.put("meta_name", mRs.value("meta_name"));
                    metaTag.put("meta_content", mRs.value("meta_content"));
                    customMetaTags.put(metaTag);
                }

                pageObj.put("custom_meta_tags", customMetaTags);
            }
            else if(Constant.PAGE_TYPE_REACT.equals(pageType)){


                q = " SELECT url, js_key FROM pages_urls "
                + " WHERE page_id = " + escape.cote(pageId)
                + " ORDER BY js_key ";
                Set uRs = Etn.execute(q);
                JSONArray pageUrls = new JSONArray();
                while(uRs.next()){
                    JSONObject pageUrl = new JSONObject();
                    pageUrl.put("url", uRs.value("url"));
                    pageUrl.put("js_key", uRs.value("js_key"));
                    pageUrls.put(pageUrl);
                }

                pageObj.put("page_urls", pageUrls);

                JSONArray components = new JSONArray();
                pageObj.put("components",components);

                q = " SELECT i.*, IFNULL(c.name,'') AS component_name "
                    + " FROM page_items i "
                    + " LEFT JOIN components c ON c.id = i.component_id "
                    + " WHERE i.page_id = " + escape.cote(pageId)
                    + " ORDER BY index_key , id" ;
                rs = Etn.execute(q);
                while(rs.next()){
                    curObj = new JSONObject();
                    for(String colName : rs.ColName){
                        curObj.put(colName.toLowerCase(), rs.value(colName));
                    }

                    JSONArray propertyValues = new JSONArray();
                    curObj.put("property_values", propertyValues );

                    JSONArray urls = new JSONArray();
                    curObj.put("urls", urls );

                    components.put(curObj);

                    q = "SELECT * "
                        + " FROM page_item_property_values pv "
                        + " WHERE page_item_id = " + escape.cote(rs.value("id"));
                    Set cRs = Etn.execute(q);
                    while(cRs.next()){
                        curObj = new JSONObject();
                        curObj.put("property_id", cRs.value("property_id"));
                        curObj.put("value", cRs.value("value"));
                        propertyValues.put(curObj);
                    }

                    q = "SELECT url  "
                        + " FROM page_component_urls  "
                        + " WHERE type = 'item' AND component_id = '0' "
                        + " AND page_item_id = " + escape.cote(rs.value("id"));
                    cRs = Etn.execute(q);
                    while(cRs.next()){
                        urls.put(cRs.value("url"));
                    }

                    if(parseInt(rs.value("component_id")) > 0){
                        q = "SELECT * "
                        + " FROM page_item_property_values pv "
                        + " WHERE page_item_id = " + escape.cote(rs.value("id"));
                        cRs = Etn.execute(q);
                        while(cRs.next()){
                            curObj = new JSONObject();
                            curObj.put("property_id", cRs.value("property_id"));
                            curObj.put("value", cRs.value("value"));
                            propertyValues.put(curObj);
                        }

                    }
                }
            }
            status = STATUS_SUCCESS;
            retObj.put("page",pageObj);

        }//try
        catch(Exception ex){
            throw new SimpleException("Error in page info.",ex);
        }
        retObj.put("status", status);
        retObj.put("message", message);

        return retObj;
    }

    String getPageName(Contexte Etn, String id, String type) {

        String tableName = "freemarker_pages";
        if (type.equals(Constant.PAGE_TYPE_STRUCTURED)) {
            tableName = "structured_contents";
        } else if (type.equals("folder")) {
            tableName = "folders";
        } else if (type.equals(Constant.PAGE_TYPE_REACT)) {
            tableName = "pages";
        }

        if (id.length() > 0) {
            String q = "SELECT name FROM " + tableName + " WHERE id =" + escape.cote(id);
            Set rs = Etn.execute(q);
            if (rs.next()) {
                return parseNull(rs.value("name"));
            }
            else {
                return "";
            }
        }
        else {
            return "";
        }
    }

    JSONObject getPageParametersJson(ServletRequest request, String langId){
        String langAppend = "";
        if(langId.length()>0 && parseInt(langId)>0){
            langAppend = "_lang_"+langId;
        }
        JSONObject parameters = new JSONObject();
        parameters.put("pageId",parseNull(request.getParameter("pageId"+langAppend)));
        parameters.put("folderId",parseNull(request.getParameter("folderId"+langAppend)));
        parameters.put("pageType",parseNull(request.getParameter("pageType"+langAppend)));

        parameters.put("name",parseNull(request.getParameter("name"+langAppend)));
        parameters.put("path",parseNull(request.getParameter("path"+langAppend)));
        parameters.put("variant",parseNull(request.getParameter("variant"+langAppend)));
        parameters.put("langue_code",parseNull(request.getParameter("langue_code"+langAppend)));

        parameters.put("title",parseNull(request.getParameter("title"+langAppend)));
        parameters.put("canonical_url",parseNull(request.getParameter("canonical_url"+langAppend)));
        parameters.put("template_id",parseNull(request.getParameter("template_id"+langAppend)));

        parameters.put("meta_keywords",parseNull(request.getParameter("meta_keywords"+langAppend)));
        parameters.put("meta_description",parseNull(request.getParameter("meta_description"+langAppend)));

        parameters.put("dl_page_type",parseNull(request.getParameter("dl_page_type"+langAppend)));
        parameters.put("dl_sub_level_1",parseNull(request.getParameter("dl_sub_level_1"+langAppend)));
        parameters.put("dl_sub_level_2",parseNull(request.getParameter("dl_sub_level_2"+langAppend)));

        parameters.put("social_title",parseNull(request.getParameter("social_title"+langAppend)));
        parameters.put("social_type",parseNull(request.getParameter("social_type"+langAppend)));
        parameters.put("social_description",parseNull(request.getParameter("social_description"+langAppend)));
        parameters.put("social_image",parseNull(request.getParameter("social_image"+langAppend)));
        parameters.put("social_twitter_message",parseNull(request.getParameter("social_twitter_message"+langAppend)));
        parameters.put("social_twitter_hashtags",parseNull(request.getParameter("social_twitter_hashtags"+langAppend)));
        parameters.put("social_email_subject",parseNull(request.getParameter("social_email_subject"+langAppend)));
        parameters.put("social_email_popin_title",parseNull(request.getParameter("social_email_popin_title"+langAppend)));
        parameters.put("social_email_message",parseNull(request.getParameter("social_email_message"+langAppend)));
        parameters.put("social_sms_text",parseNull(request.getParameter("social_sms_text"+langAppend)));

        parameters.put("row_height",parseNull(request.getParameter("row_height"+langAppend)));
        parameters.put("item_margin_x",parseNull(request.getParameter("item_margin_x"+langAppend)));
        parameters.put("item_margin_y",parseNull(request.getParameter("item_margin_y"+langAppend)));
        parameters.put("container_padding_x",parseNull(request.getParameter("container_padding_x"+langAppend)));
        parameters.put("container_padding_y",parseNull(request.getParameter("container_padding_y"+langAppend)));

        parameters.put("package_name",parseNull(request.getParameter("package_name"+langAppend)));
        parameters.put("class_name",parseNull(request.getParameter("class_name"+langAppend)));
        parameters.put("layout",parseNull(request.getParameter("layout"+langAppend)));

        String[] metaNames = request.getParameterValues("meta_name"+langAppend);
        if(metaNames != null){
            JSONArray metaNamesJsonArrray = new JSONArray();
            for(String metaName : metaNames){
                metaNamesJsonArrray.put(metaName);
            }
            parameters.put("meta_name",metaNamesJsonArrray);
        }

        String[] metaContents = request.getParameterValues("meta_content"+langAppend);
        if(metaContents != null){
            JSONArray metaContentsJsonArrray = new JSONArray();
            for(String metaContent : metaContents){
                metaContentsJsonArrray.put(metaContent);
            }
            parameters.put("meta_content", metaContentsJsonArrray);
        }

        String[] pageUrls = request.getParameterValues("page_url"+langAppend);

        if(pageUrls != null){
            JSONArray pageUrlsJsonArrray = new JSONArray();
            for(String pageUrl : pageUrls){
                pageUrlsJsonArrray.put(pageUrl);
            }
            parameters.put("page_url", pageUrlsJsonArrray);
        }

        String[] pageUrlJsKeys = request.getParameterValues("page_url_js_key"+langAppend);

        if(pageUrlJsKeys != null){
            JSONArray pageUrlJsKeysJsonArrray = new JSONArray();
            for(String pageUrlJsKey : pageUrlJsKeys){
                pageUrlJsKeysJsonArrray.put(pageUrlJsKey);
            }
            parameters.put("page_url_js_key", pageUrlJsKeysJsonArrray);
        }
        return parameters;
    }

    JSONObject savePageCommonProducts(Contexte Etn, HttpServletRequest request, JSONObject parameters, String siteId, HttpSession session, String parentId) throws SimpleException {
        int STATUS_SUCCESS = 1, STATUS_ERROR = 0;

        int status = STATUS_ERROR;
        String message = "";
        JSONObject data = new JSONObject();

        LinkedHashMap<String, String> colValueHM = new LinkedHashMap<>();

        String q = "";
        Set rs = null;

        try {
            int pageId = parseInt(parameters.optInt("pageId"));
            String pageVersion = parameters.optString("page_version");
            String folderId = parameters.optString("folderId");
            String pageType = parameters.optString("pageType");
            String name = parameters.optString("name");
            String path = parameters.optString("path");
            String variant = parseNull(parameters.optString("variant")).isEmpty() ? "all":parameters.optString("variant");
            String langue_code = parameters.optString("langue_code");
            String title = parameters.optString("title");
            String meta_description = parameters.optString("meta_description");
            String social_title = parameters.optString("social_title");
            String social_description = parameters.optString("social_description");

            if(!pageVersion.equals("V2")) pageVersion="V1";

            String layout = parameters.optString("layout");
            if (layout.length() == 0) {
                layout = Constant.PAGE_LAYOUT_REACT;
            }

            q = "SELECT fp.concat_path as folder_path FROM pages_folders_lang_path fp"
                + " JOIN "+GlobalParm.getParm("CATALOG_DB") + ".language l on l.langue_id = fp.langue_id"
                + " WHERE fp.site_id = "+escape.cote(siteId)
                + " AND fp.folder_id = "+escape.cote(folderId)
                + " AND l.langue_code = "+escape.cote(langue_code);
            rs =  Etn.execute(q);
            String fullPagePath  = path;
            if(rs.next()){
                String pathPrefix = rs.value("folder_path");
                if(pathPrefix.length()>0){
                    fullPagePath = pathPrefix+"/"+path;
                }
            }

            String errorMsg = "";
            if (name.length() == 0) errorMsg = "Name cannot be empty";
            else if (path.length() == 0) errorMsg = "Path cannot be empty";

            if (errorMsg.length() == 0) {
                StringBuffer urlErrorMsg = new StringBuffer();
                String pageIdStr = (pageId > 0) ? "" + pageId : "";

                if (!isPageUrlUnique(Etn, siteId,langue_code, variant, fullPagePath,pageIdStr, urlErrorMsg)) errorMsg = "Error: Path '" + path + "' entered for language '" + 
                    langue_code + "' is not unique across the site. " + urlErrorMsg;
            }


            if (errorMsg.length() > 0) message = errorMsg;
            else {
                if (social_title.length() == 0) social_title = title;
                if (social_description.length() == 0) social_description = meta_description;

                int pid = Etn.getId();

                colValueHM.put("name", escape.cote(name));
                colValueHM.put("path", escape.cote(path));
                colValueHM.put("variant", escape.cote(variant));
                colValueHM.put("langue_code", escape.cote(langue_code));

                colValueHM.put("title", escape.cote(title));
                colValueHM.put("template_id", escape.cote(parameters.optString("template_id")));

                colValueHM.put("meta_description", escape.cote(meta_description));
                colValueHM.put("social_title", escape.cote(social_title));
                colValueHM.put("social_description", escape.cote(social_description));

                colValueHM.put("parent_page_id", parentId);
                colValueHM.put("updated_ts", "NOW()");
                colValueHM.put("updated_by", escape.cote("" + pid));
/*
                colValueHM.put("canonical_url", escape.cote(parameters.optString("canonical_url")));
                colValueHM.put("dl_page_type", escape.cote(parameters.optString("dl_page_type")));
                colValueHM.put("dl_sub_level_1", escape.cote(parameters.optString("dl_sub_level_1")));
                colValueHM.put("dl_sub_level_2", escape.cote(parameters.optString("dl_sub_level_2")));

                colValueHM.put("package_name", escape.cote(parameters.optString("package_name")));
                colValueHM.put("class_name", escape.cote(parameters.optString("class_name")));
                colValueHM.put("meta_keywords", escape.cote(parameters.optString("meta_keywords")));
                colValueHM.put("social_type", escape.cote(parameters.optString("social_type")));
                colValueHM.put("social_image", escape.cote(parameters.optString("social_image")));
                colValueHM.put("social_twitter_message", escape.cote(parameters.optString("social_twitter_message")));
                colValueHM.put("social_twitter_hashtags", escape.cote(parameters.optString("social_twitter_hashtags")));
                colValueHM.put("social_email_subject", escape.cote(parameters.optString("social_email_subject")));
                colValueHM.put("social_email_message", escape.cote(parameters.optString("social_email_message")));
                colValueHM.put("social_email_popin_title", escape.cote(parameters.optString("social_email_popin_title")));
                colValueHM.put("social_sms_text", escape.cote(parameters.optString("social_sms_text")));

                colValueHM.put("row_height", escape.cote("" + parameters.optInt("row_height")));
                colValueHM.put("item_margin_x", escape.cote("" + parameters.optInt("item_margin_x")));
                colValueHM.put("item_margin_y", escape.cote("" + parameters.optInt("item_margin_y")));
                colValueHM.put("container_padding_x", escape.cote("" + parameters.optInt("container_padding_x")));
                colValueHM.put("container_padding_y", escape.cote("" + parameters.optInt("container_padding_y")));
*/
                if (pageId <= 0) {
                    colValueHM.put("created_ts", "NOW()");
                    colValueHM.put("created_by", escape.cote("" + pid));

                    colValueHM.put("site_id", escape.cote(siteId));
                    colValueHM.put("type", escape.cote(pageType));
                    colValueHM.put("layout", escape.cote(layout));
                    colValueHM.put("layout_data", escape.cote("{}"));
                    colValueHM.put("folder_id", escape.cote(folderId));
                    colValueHM.put("page_version", escape.cote(pageVersion));

                    q = getInsertQuery("pages", colValueHM);
                    pageId = Etn.executeCmd(q);

                    if (pageId <= 0) {
                        message = "Error in creating page. Please try again.";
                    }
                    else {
                        status = STATUS_SUCCESS;
                        message = "Page created.";
                        data.put("pageId", pageId);
                        ActivityLog.addLog(Etn, request, parseNull(session.getAttribute("LOGIN")), "" + pageId, "CREATED", "Page", name, siteId);
                    }
                }
                else {
                    //existing page update
                    q = getUpdateQuery("pages", colValueHM, " WHERE id = " + escape.cote("" + pageId));

                    if (Etn.executeCmd(q) <= 0) message = "Error in updating page. Please try again.";
                    else {
                        status = STATUS_SUCCESS;
                        message = "Page updated.";
                        data.put("pageId", pageId);
                        ActivityLog.addLog(Etn, request, parseNull(session.getAttribute("LOGIN")), "" + pageId, "UPDATED", "Page", name, siteId);
                    }
                }
            }
        }//try
        catch (Exception ex) {
            status = STATUS_ERROR;
            message = "Error in saving page. Please try again.";
        }

        JSONObject jsonResponse = new JSONObject();
        jsonResponse.put("status", status);
        jsonResponse.put("message", message);
        jsonResponse.put("data", data);
        return jsonResponse;
    }
    JSONObject savePageCommon(Contexte Etn, HttpServletRequest request, JSONObject parameters, String siteId, HttpSession session, String parentId) throws SimpleException {
        int STATUS_SUCCESS = 1, STATUS_ERROR = 0;

        int status = STATUS_ERROR;
        String message = "";
        JSONObject data = new JSONObject();

        LinkedHashMap<String, String> colValueHM = new LinkedHashMap<>();

        String q = "";
        Set rs = null;

        try {
            int pageId = parseInt(parameters.optInt("pageId"));
            String folderId = parameters.optString("folderId");
            String pageType = parameters.optString("pageType");

            String name = parameters.optString("name");
            String path = parameters.optString("path");
            String variant = parameters.optString("variant");
            String langue_code = parameters.optString("langue_code");

            String title = parameters.optString("title");
            String canonical_url = parameters.optString("canonical_url");
            String template_id = parameters.optString("template_id");

            String meta_keywords = parameters.optString("meta_keywords");
            String meta_description = parameters.optString("meta_description");

            String dl_page_type = parameters.optString("dl_page_type");
            String dl_sub_level_1 = parameters.optString("dl_sub_level_1");
            String dl_sub_level_2 = parameters.optString("dl_sub_level_2");

            String social_title = parameters.optString("social_title");
            String social_type = parameters.optString("social_type");
            String social_description = parameters.optString("social_description");
            String social_image = parameters.optString("social_image");
            String social_twitter_message = parameters.optString("social_twitter_message");
            String social_twitter_hashtags = parameters.optString("social_twitter_hashtags");
            String social_email_subject = parameters.optString("social_email_subject");
            String social_email_popin_title = parameters.optString("social_email_popin_title");
            String social_email_message = parameters.optString("social_email_message");
            String social_sms_text = parameters.optString("social_sms_text");

            String row_height = "" + parameters.optInt("row_height");
            String item_margin_x = "" + parameters.optInt("item_margin_x");
            String item_margin_y = "" + parameters.optInt("item_margin_y");
            String container_padding_x = "" + parameters.optInt("container_padding_x");
            String container_padding_y = "" + parameters.optInt("container_padding_y");

            String package_name = parameters.optString("package_name");
            String class_name = parameters.optString("class_name");
            String layout = parameters.optString("layout");
            if (layout.length() == 0) {
                layout = Constant.PAGE_LAYOUT_REACT;
            }

            q = "SELECT fp.concat_path as folder_path FROM pages_folders_lang_path fp"
                + " JOIN "+GlobalParm.getParm("CATALOG_DB") + ".language l on l.langue_id = fp.langue_id"
                + " WHERE fp.site_id = "+escape.cote(siteId)
                + " AND fp.folder_id = "+escape.cote(folderId)
                + " AND l.langue_code = "+escape.cote(langue_code);
            rs =  Etn.execute(q);
            String fullPagePath  = path;
            if(rs.next()){
                String pathPrefix = rs.value("folder_path");
                if(pathPrefix.length()>0){
                    fullPagePath = pathPrefix+"/"+path;
                }
            }

            String errorMsg = "";
            if (name.length() == 0) {
                errorMsg = "Name cannot be empty";
            }
            else if (path.length() == 0) {
                errorMsg = "Path cannot be empty";
            }
            else if (pageType.equals(Constant.PAGE_TYPE_REACT)) {
                if (class_name.length() == 0) {
                    errorMsg = "Class name cannot be empty";
                }
                else if (package_name.length() == 0) {
                    errorMsg = "Package name cannot be empty";
                }
            }

            // @@@deprecated :- for now name check will be at the parent page

            //check duplicate page name
            // if(pageType.equals(Constant.PAGE_TYPE_FREEMARKER)){
            //     q = "SELECT id FROM pages WHERE name = " + escape.cote(name)
            //         + " AND type = " + escape.cote(Constant.PAGE_TYPE_FREEMARKER)
            //         + " AND folder_id = " + escape.cote(folderId)
            //         + " AND site_id = " + escape.cote(siteId);
            //     if(pageId>0){
            //         q += " AND id != "+escape.cote(""+pageId);
            //     }
            //     Set tempRs = Etn.execute(q);
            //     if(tempRs.next()){
            //         throw new SimpleException("Error: Name already exists. Please change name.");
            //     }
            // }

            if (errorMsg.length() == 0) {
                //check duplicate url/path

                StringBuffer urlErrorMsg = new StringBuffer();
                String pageIdStr = (pageId > 0) ? "" + pageId : "";


                boolean isUnique = isPageUrlUnique(Etn, siteId,
                                                   langue_code, variant, fullPagePath,
                                                   pageIdStr, urlErrorMsg);

                if (!isUnique) {
                    errorMsg = "Error: Path '" + path + "' entered for language '" + langue_code + "' is not unique across the site. " + urlErrorMsg;
                }

            }


            if (errorMsg.length() > 0) {
                message = errorMsg;
            }
            else {

                if (social_title.length() == 0) {
                    social_title = title;
                }

                if (social_description.length() == 0) {
                    social_description = meta_description;
                }

                int pid = Etn.getId();

                colValueHM.put("name", escape.cote(name));
                colValueHM.put("path", escape.cote(path));
                colValueHM.put("variant", escape.cote(variant));
                colValueHM.put("langue_code", escape.cote(langue_code));


                colValueHM.put("title", escape.cote(title));
                colValueHM.put("canonical_url", escape.cote(canonical_url));
                colValueHM.put("template_id", escape.cote(template_id));

                colValueHM.put("dl_page_type", escape.cote(dl_page_type));
                colValueHM.put("dl_sub_level_1", escape.cote(dl_sub_level_1));
                colValueHM.put("dl_sub_level_2", escape.cote(dl_sub_level_2));

                colValueHM.put("package_name", escape.cote(package_name));
                colValueHM.put("class_name", escape.cote(class_name));

                colValueHM.put("meta_keywords", escape.cote(meta_keywords));
                colValueHM.put("meta_description", escape.cote(meta_description));
                colValueHM.put("social_title", escape.cote(social_title));
                colValueHM.put("social_type", escape.cote(social_type));
                colValueHM.put("social_description", escape.cote(social_description));
                colValueHM.put("social_image", escape.cote(social_image));
                colValueHM.put("social_twitter_message", escape.cote(social_twitter_message));
                colValueHM.put("social_twitter_hashtags", escape.cote(social_twitter_hashtags));
                colValueHM.put("social_email_subject", escape.cote(social_email_subject));
                colValueHM.put("social_email_message", escape.cote(social_email_message));
                colValueHM.put("social_email_popin_title", escape.cote(social_email_popin_title));
                colValueHM.put("social_sms_text", escape.cote(social_sms_text));

                colValueHM.put("row_height", escape.cote(row_height));
                colValueHM.put("item_margin_x", escape.cote(item_margin_x));
                colValueHM.put("item_margin_y", escape.cote(item_margin_y));
                colValueHM.put("container_padding_x", escape.cote(container_padding_x));
                colValueHM.put("container_padding_y", escape.cote(container_padding_y));

                colValueHM.put("parent_page_id", parentId);
                colValueHM.put("updated_ts", "NOW()");
                colValueHM.put("updated_by", escape.cote("" + pid));

                if (pageId <= 0) {
                    //new page
                    colValueHM.put("created_ts", "NOW()");
                    colValueHM.put("created_by", escape.cote("" + pid));

                    colValueHM.put("site_id", escape.cote(siteId));
                    colValueHM.put("type", escape.cote(pageType));
                    colValueHM.put("layout", escape.cote(layout));
                    colValueHM.put("layout_data", escape.cote("{}"));
                    colValueHM.put("folder_id", escape.cote(folderId));

                    q = getInsertQuery("pages", colValueHM);
                    pageId = Etn.executeCmd(q);

                    if (pageId <= 0) {
                        message = "Error in creating page. Please try again.";
                    }
                    else {
                        status = STATUS_SUCCESS;
                        message = "Page created.";
                        data.put("pageId", pageId);
                        ActivityLog.addLog(Etn, request, parseNull(session.getAttribute("LOGIN")), "" + pageId, "CREATED", "Page", name, siteId);
                    }
                }
                else {
                    //existing page update
					
					if(parameters.optString("pageType","").equals(Constant.PAGE_TYPE_FREEMARKER))
					{
						com.etn.util.Logger.info("pagesutil.jsp", "Yes its a freemarker page so must be marked to generate as some settings are changed");
						colValueHM.put("to_generate",escape.cote("1"));
						colValueHM.put("to_generate_by",escape.cote(""+Etn.getId()));
					}
					
                    q = getUpdateQuery("pages", colValueHM, " WHERE id = " + escape.cote("" + pageId));

                    int count = Etn.executeCmd(q);

                    if (count <= 0) {
                        message = "Error in updating page. Please try again.";
                    }
                    else {
                        status = STATUS_SUCCESS;
                        message = "Page updated.";
                        data.put("pageId", pageId);
                        ActivityLog.addLog(Etn, request, parseNull(session.getAttribute("LOGIN")), "" + pageId, "UPDATED", "Page", name, siteId);
                    }
                }

                //check if status is success
                if (status == STATUS_SUCCESS && pageId > 0) {

                    StringBuilder logMsg = new StringBuilder();
                    logMsg.append("Page Info update|pageId=")
                            .append(pageId).append("|")
                            .append(message).append("|")
                            .append(name).append("|")
                            .append(title).append("|")
                            .append(siteId).append("|")
                            .append(langue_code).append("|")
                            .append(variant).append("|")
                            .append(path).append("|")
                            .append(title).append("|");

                    logDebugInfo(request, Etn.getId(), logMsg.toString());

                    if (pageType.equals(Constant.PAGE_TYPE_FREEMARKER) || pageType.equals(Constant.PAGE_TYPE_STRUCTURED)) {

                        JSONArray metaNames = parameters.optJSONArray("meta_name");
                        JSONArray metaContents = parameters.optJSONArray("meta_content");

                        q = " DELETE FROM pages_meta_tags WHERE page_id = " + escape.cote("" + pageId);
                        Etn.executeCmd(q);

                        if (metaNames != null && metaContents != null
                            && metaNames.length() == metaContents.length()) {

                            String qPrefix = "INSERT INTO pages_meta_tags(page_id, meta_name, meta_content) VALUES ( ";
                            for (int i = 0; i < metaNames.length(); i++) {
                                String curMetaName = parseNull(metaNames.get(i));
                                String curMetaContent = parseNull(metaContents.get(i));

                                if (curMetaName.length() == 0 || curMetaContent.length() == 0) {
                                    continue;//skip
                                }

                                q = qPrefix + escape.cote("" + pageId)
                                    + " , " + escape.cote(curMetaName)
                                    + " , " + escape.cote(curMetaContent)
                                    + " ) "
                                    + " ON DUPLICATE KEY UPDATE meta_content=VALUES(meta_content) ";
                                Etn.executeCmd(q);
                            }
                        }

//                        -- deprecated code page will only be generated at parent level now --
                        //generate page
//                        if(pageType.equals(Constant.PAGE_TYPE_STRUCTURED)){
//                            try{
//                                PagesGenerator pagesGen = new PagesGenerator(Etn);
//                                pagesGen.generateAndSavePage("" + pageId);
//                            }catch (Exception ex){
//                                ex.printStackTrace();
//                                q = "UPDATE pages SET to_generate=1 , to_generate_by= " + escape.cote("" + Etn.getId())
//                                    + " WHERE id = " + escape.cote("" + pageId);
//                                Etn.executeCmd(q);
//                            }
//                        }
                    }
                    else if (pageType.equals(Constant.PAGE_TYPE_REACT)) {
                        JSONArray pageUrls = parameters.getJSONArray("page_url");
                        JSONArray pageUrlJsKeys = parameters.getJSONArray("page_url_js_key");

                        q = " DELETE FROM pages_urls WHERE page_id = " + escape.cote("" + pageId);
                        Etn.executeCmd(q);

                        if (pageUrls != null && pageUrlJsKeys != null
                            && pageUrls.length() == pageUrlJsKeys.length()) {

                            String qPrefix = "INSERT INTO pages_urls(page_id, type, url, js_key) VALUES ( ";
                            for (int i = 0; i < pageUrls.length(); i++) {
                                String curPageUrl = parseNull(pageUrls.optString(i));
                                String curPageUrlJsKey = parseNull(pageUrlJsKeys.optString(i));

                                if (curPageUrl.length() == 0 || curPageUrlJsKey.length() == 0) {
                                    continue;//skip
                                }

                                q = qPrefix + escape.cote("" + pageId) + ",'init'"
                                    + " , " + escape.cote(curPageUrl)
                                    + " , " + escape.cote(curPageUrlJsKey)
                                    + " ) ";
                                Etn.executeCmd(q);
                            }
                        }
                    }

                }

            }
        }//try
        catch (Exception ex) {
            status = STATUS_ERROR;
            message = "Error in saving page. Please try again.";
        }

        JSONObject jsonResponse = new JSONObject();
        jsonResponse.put("status", status);
        jsonResponse.put("message", message);
        jsonResponse.put("data", data);
        return jsonResponse;
    }

    void rollbackPageInsert(Contexte Etn, String id, String siteId, String type){
        if(parseInt(id) > 0){
            Set rs = Etn.execute("SELECT id FROM pages WHERE parent_page_id = "+escape.cote(id) + " AND type = "+escape.cote(type));
		ArrayList<String> pagesId = new ArrayList<>();
            while (rs.next()){
                pagesId.add(rs.value("id"));
            }
            rollbackPageInsert(Etn, id, pagesId, true, siteId, type);
        }
    }

    void rollbackPageInsert(Contexte Etn, String id, ArrayList<String> pageIds, boolean isNew, String siteId, String pageType){
        if(isNew){
            String table = "freemarker_pages";
            if(pageType.equals(Constant.PAGE_TYPE_STRUCTURED)){
                table = "structured_contents";
            }
            Etn.execute("DELETE from "+table+" WHERE id = "+escape.cote(id)+" AND site_id = "+escape.cote(siteId));
            Etn.executeCmd("DELETE FROM parent_pages_blocs WHERE page_id = " + escape.cote(id));
            Etn.executeCmd("DELETE FROM parent_pages_forms WHERE page_id = " + escape.cote(id));
			Etn.executeCmd("DELETE FROM pages_tags WHERE page_type = "+escape.cote(pageType)+" and page_id = " + escape.cote(id));
            for(String pId: pageIds){
                deletePageCommon(pId, Etn);
             }
        }
    }

    String publishUnpublishCatalogAndProduct(Contexte Etn,String contentId,String action,String publishTime){
        String CATALOG_DB = GlobalParm.getParm("CATALOG_DB")+".";
        String PROD_CATALOG_DB = GlobalParm.getParm("PROD_CATALOG_DB")+".";

        Set rsProdV2 = Etn.execute("select p.* from products_map_pages pmp join "+CATALOG_DB+"products p on p.id=pmp.product_id where pmp.page_id="+escape.cote(contentId));
        if(rsProdV2.next()){
            String catalogId = PagesUtil.parseNull(rsProdV2.value("catalog_id"));
            Set rsCatalogV2 = Etn.execute("select * from "+CATALOG_DB+"catalogs where id="+escape.cote(catalogId));
            Set rsProdCatalogV2 = Etn.execute("select * from "+PROD_CATALOG_DB+"catalogs where id="+escape.cote(catalogId));

            if(rsCatalogV2.next() && rsProdCatalogV2.next()){
                if(action.equalsIgnoreCase("publish") && (PagesUtil.parseNull(rsProdCatalogV2.value("version")).isEmpty() || !rsProdCatalogV2.value("version").equals(rsCatalogV2.value("version")))){
                    movephase(catalogId, "catalogs", action, publishTime,CATALOG_DB,Etn);
                }
            }
            
            movephase(rsProdV2.value("id"), "products", action, publishTime,CATALOG_DB,Etn);
            
            Set rsCatalogEngine = Etn.execute("select val from "+CATALOG_DB+"config where code='SEMAPHORE'");
            rsCatalogEngine.next();
            Etn.execute("select semfree("+escape.cote(rsCatalogEngine.value("val"))+")");

            return "";
        }else return "Product not found for this page.";
    }

    boolean movephase(String clid, String process, String phase, String on,String catalogDb,Contexte Etn) {
        boolean succ = false;
        String qrys[] = new String[3];
        qrys[0] = "set @curid = 0";
        qrys[1] = "update "+catalogDb+"post_work set status = 1, id = @curid := id where status = 0 and client_key = "+escape.cote(clid)+" and proces = " +escape.cote(process);
        qrys[2] = "select @curid as lastLineId ";
        
        Set rs = Etn.execute(qrys);
        int lastLineId = 0;
        if(rs.next() && rs.next() && rs.next()) lastLineId = Integer.parseInt(rs.value(0));

        //check engine already started work
        if(lastLineId <= 0) {
            Set rs3 = Etn.execute("select * from "+catalogDb+"post_work where client_key = "+escape.cote(clid)+" and proces = " +escape.cote(process));
            //there are rows in post_work for this process and client_key so if lastLineId <= 0 means engine already started work
            if(rs3.rs.Rows > 0) return false;
        }

        String q = "insert into "+catalogDb+"post_work (proces, phase, client_key, insertion_date, priority, operador) values (";
        q += escape.cote(process)+","+escape.cote(phase)+","+escape.cote(clid)+", now() ";

        if(on.equals("-1")) q += ", now() ";
        else q += ", "+escape.cote(on);
        q += "," + escape.cote(Etn.getId()+"")+" ) " ;
        int r = Etn.executeCmd(q);

        if(r > 0) {
            succ = true;
            Etn.executeCmd("update "+catalogDb+"post_work set attempt = attempt + 1, status = 2, start = now(), end= now(), nextid = "+r+" where id = " + escape.cote(""+lastLineId));//change
        }else Etn.executeCmd("update "+catalogDb+"post_work set status = 0 where id = " + escape.cote(""+lastLineId));//change
        
        return succ;
    }

%>
<%!
    public static class CustomEntityExport extends EntityExport {

        public CustomEntityExport(Etn Etn, Properties env, boolean debug, String siteId) {
            super(Etn, env, debug, siteId);
        }

        public CustomEntityExport(Contexte Etn, String siteId) {
            super(Etn, siteId);
        }

    }
%>
<%!
    public static class CustomEntityImport extends ExcelEntityImport {
        public CustomEntityImport(File file) throws IOException, InvalidFormatException {
                super(file);
        }
    }

    public static class CustomExcelEntityImport extends ExcelEntityImport {

        public CustomExcelEntityImport(File excelFile) throws IOException, InvalidFormatException {
            super(excelFile);
        }
    }
%>