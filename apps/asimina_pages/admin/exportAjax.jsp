<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.pages.EntityExport, com.etn.sql.escape"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="pagesUtil.jsp"%>
<%
    final int STATUS_SUCCESS = 1, STATUS_ERROR = 0;

    int status = STATUS_ERROR;
    String message = "";
    JSONObject data = new JSONObject();

    LinkedHashMap<String, String> colValueHM = new LinkedHashMap<>();

    String q = "";
    Set rs = null;
    int count = 0;

    String siteId = getSiteId(session);
    String requestType = parseNull(request.getParameter("requestType"));

	try{

	    if("getExportsList".equalsIgnoreCase(requestType)){
	    	try{

	    		JSONArray retList = new JSONArray();
				JSONObject curObj = null;

				q = " SELECT 'pages' AS id, 'pages : block'  AS label, COUNT(0) as nb_count FROM freemarker_pages  "
                        + " WHERE site_id = " + escape.cote(siteId)
                        + " AND  is_deleted = '0'"
                    + " UNION "
                        + " SELECT 'structured_pages' AS id, 'pages : structured'  AS label, COUNT(0) as nb_count FROM structured_contents sc "
                        + " JOIN bloc_templates bt ON bt.id = sc.template_id "
                        + " WHERE sc.type = 'page' AND bt.type != "+escape.cote(Constant.TEMPLATE_STORE)+" AND sc.structured_version='V1' and sc.site_id = " + escape.cote(siteId)
                    + " UNION "
                        + " SELECT 'stores' AS id, 'stores'  AS label, COUNT(0) as nb_count "
                        + " FROM structured_contents sc"
                        + " JOIN bloc_templates bt ON bt.id = sc.template_id "
                        + " WHERE sc.type = 'page' AND bt.type = "+escape.cote(Constant.TEMPLATE_STORE)+" AND sc.structured_version='V1' AND sc.site_id = " + escape.cote(siteId)
                    + " UNION "
                        + " SELECT 'blocs' AS id, 'blocs'  AS label, COUNT(0) as nb_count FROM blocs  "
                        + " WHERE site_id = " + escape.cote(siteId)
                    + " UNION "
                        + " SELECT 'bloc_templates' AS id, 'bloc_templates'  AS label, COUNT(0) as nb_count FROM bloc_templates  "
                        + " WHERE site_id = " + escape.cote(siteId)
                    + " UNION "
                        + " SELECT 'page_templates' AS id, 'page_templates'  AS label, COUNT(0) as nb_count FROM page_templates  "
                        + " WHERE site_id = " + escape.cote(siteId)
                    + " UNION "
                        + " SELECT 'libraries' AS id, 'libraries'  AS label, COUNT(0) as nb_count FROM libraries  "
                        + " WHERE site_id = " + escape.cote(siteId)
                    + " UNION "
                        + " SELECT 'structured_contents' AS id, 'structured_data'  AS label, COUNT(0) as nb_count FROM structured_contents sc "
                        + " WHERE sc.type = 'content' AND sc.structured_version='V1' AND  sc.site_id = " + escape.cote(siteId)
                    + " UNION "
                        + " SELECT 'catalogs' AS id, 'product folders (catalogs)'  AS label, COUNT(0) as nb_count FROM "+GlobalParm.getParm("CATALOG_DB")+".catalogs  "
                        + " WHERE catalog_version='V1' AND site_id = " + escape.cote(siteId)
                    + " UNION "
                        + " SELECT 'products' AS id, 'products'  AS label, COUNT(0) as nb_count FROM "+GlobalParm.getParm("CATALOG_DB")+".products p "
                        + " JOIN "+GlobalParm.getParm("CATALOG_DB")+".catalogs c ON c.id = p.catalog_id"
                        + " WHERE p.product_version='V1' AND c.site_id = " + escape.cote(siteId)
                    + " UNION "
                        + " SELECT 'forms' AS id, 'Forms' AS label, COUNT(0) AS nb_count FROM "+GlobalParm.getParm("FORMS_DB")+".process_forms WHERE site_id = " + escape.cote(siteId)
                    + " UNION "
                        + " SELECT 'variables' AS id, 'Variables' AS label, COUNT(0) AS nb_count FROM variables WHERE site_id = " + escape.cote(siteId);
                    ;

				rs = Etn.execute(q);
				while(rs.next()){
					curObj = new JSONObject();
					for(String colName : rs.ColName){
						curObj.put(colName.toLowerCase(), rs.value(colName));
					}
					retList.put(curObj);
				}

				data.put("exports",retList);
				status = STATUS_SUCCESS;
	    	} catch(Exception ex){
				throw new SimpleException("Error in getting exports list. Please try again.",ex);
	    	}
	    }
	    else if("getExportSelectList".equalsIgnoreCase(requestType)){
	    	try{
	    		String exportType = parseNull(request.getParameter("exportType"));

	    		if( !EntityExport.isValidExportImportType(exportType) ){
	    		    throw new SimpleException("Invalid type");
	    		}

	    		String tableName = escape.cote(exportType);
	    		tableName = tableName.substring(1,tableName.length()-1);
	    		JSONArray retList = new JSONArray();
				JSONObject curObj = null;

				q = " SELECT id , name, '' as type, '' as folder_name FROM "+exportType+ " WHERE site_id = " + escape.cote(siteId);

                switch(exportType){
                    case "pages":
                        q = " SELECT p.id, p.name, 'Page : block' as type, IFNULL(f.name,'/ (Root)') as folder_name "
                            + " FROM freemarker_pages p "
                            + " LEFT JOIN pages_folders f ON p.folder_id = f.id"
                            + " WHERE p.site_id = " + escape.cote(siteId)
                            + " AND  p.is_deleted = '0'";
                        break;

                    case "structured_pages":
                        q = " SELECT sc.id, sc.name, 'Page : structured' as type, IFNULL(f.name,'/ (Root)') as folder_name "
                            + " FROM  structured_contents sc "
                            + " JOIN bloc_templates bt ON bt.id = sc.template_id "
                            + " LEFT JOIN pages_folders f ON f.id = sc.folder_id"
                            + " WHERE sc.site_id = " + escape.cote(siteId)
                            + " AND sc.structured_version='V1' AND sc.type = " + escape.cote(Constant.STRUCTURE_TYPE_PAGE)
                            + " AND bt.type != " + escape.cote(Constant.TEMPLATE_STORE);

                        break;

                    case "stores":
                        q = " SELECT sc.id, sc.name, 'Store' as type, IFNULL(f.name,'/ (Root)') as folder_name "
                            + " FROM  structured_contents sc "
                            + " JOIN bloc_templates bt ON bt.id = sc.template_id "
                            + " LEFT JOIN stores_folders f ON f.id = sc.folder_id"
                            + " WHERE sc.site_id = " + escape.cote(siteId)
                            + " AND sc.structured_version='V1' AND sc.type = " + escape.cote(Constant.STRUCTURE_TYPE_PAGE)
                            + " AND bt.type = " + escape.cote(Constant.TEMPLATE_STORE);
                        break;

                    case "blocs":
                        q = " SELECT b.id, b.name, bt.name as type, '' as folder_name "
                            + " FROM  blocs b"
                            + " JOIN bloc_templates bt ON bt.id = b.template_id"
                            + " WHERE b.site_id = " + escape.cote(siteId);
                        break;

                    case "bloc_templates":
                        q = " SELECT id, CONCAT(name,' (',custom_id,')') AS  name, type as type , '' as folder_name FROM  bloc_templates WHERE site_id = " + escape.cote(siteId);
                        break;

                    case "page_templates":
                        q = " SELECT id, name, custom_id as type , '' as folder_name FROM  page_templates WHERE site_id = " + escape.cote(siteId);
                        break;

                    case "structured_contents":
                        q = " SELECT sc.id, sc.name, bt.name as type, IFNULL(f.name,'/ (Root)') as folder_name "
                            + " FROM  structured_contents sc "
                            + " JOIN bloc_templates bt ON bt.id = sc.template_id"
                            + " LEFT JOIN structured_contents_folders f ON f.id = sc.folder_id"
                            + " WHERE sc.site_id = " + escape.cote(siteId)
                            + " AND sc.structured_version='V1' AND sc.type = " + escape.cote(Constant.STRUCTURE_TYPE_CONTENT);
                        break;

                    case "catalogs":
                        q = " SELECT c.id, c.name, c.catalog_type AS type, '' AS folder_name FROM  "+GlobalParm.getParm("CATALOG_DB")+".catalogs c WHERE c.catalog_version='V1' AND c.site_id = " + escape.cote(siteId);
                        break;

                    case "products":
                        q = " SELECT p.id, p.lang_1_name AS name,  CONCAT(c.name,' (',c.catalog_type,')') AS type "
                            + " , IFNULL(f.name, c.name) as folder_name"
                            + " FROM "+GlobalParm.getParm("CATALOG_DB")+".products p "
                            + " JOIN "+GlobalParm.getParm("CATALOG_DB")+".catalogs c ON c.id = p.catalog_id "
                            + " LEFT JOIN "+GlobalParm.getParm("CATALOG_DB")+".products_folders f ON f.id = p.folder_id AND f.catalog_id = c.id "
                            + " WHERE p.product_version='V1' AND c.site_id = " + escape.cote(siteId);
                        break;

                    case "forms":
                        q = " SELECT form_id AS id, process_name AS name, type AS type, '' as folder_name FROM "+GlobalParm.getParm("FORMS_DB")+".process_forms WHERE site_id = " + escape.cote(siteId);
                        break;

                    case "variables":
                        q = " SELECT id, name, '' AS type, '' as folder_name FROM variables WHERE site_id = " + escape.cote(siteId);
                        break;
                }

                Logger.debug(q);
				rs = Etn.execute(q);

				while(rs.next()){
					curObj = new JSONObject();
					for(String colName : rs.ColName){
						curObj.put(colName.toLowerCase(), rs.value(colName));
					}
					retList.put(curObj);
				}
				data.put("exports",retList);
				status = STATUS_SUCCESS;
	    	} catch(Exception ex){
				throw new SimpleException("Error in getting exports list. Please try again.",ex);
	    	}
	    }
	    /*else if("test".equalsIgnoreCase(requestType)){
	    	try{

			}//try
	    	catch(Exception ex){
				throw new SimpleException("Error in testing.",ex);
	    	}
	    }*/

    } catch(SimpleException ex){
		message = ex.getMessage();
		ex.print();
	}

    JSONObject jsonResponse = new JSONObject();
    jsonResponse.put("status",status);
    jsonResponse.put("message",message);
    jsonResponse.put("data",data);
   	out.write(jsonResponse.toString());
%>
