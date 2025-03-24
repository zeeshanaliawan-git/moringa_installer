<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@page import="com.etn.lang.ResultSet.Set"%>
<%@ include file="/common.jsp"%>
<%@ page import="com.etn.sql.escape, com.etn.util.ItsDate, com.etn.util.*, com.etn.beans.app.GlobalParm,com.etn.util.Base64"%>
<%@page import="java.io.*"%>
<%@ page import="org.jsoup.*"%>
<%@ page import="org.jsoup.nodes.*, com.etn.asimina.util.CommonHelper"%>

<%!
    String getDomain(String url)
    {
        String domain = url;
        if(domain.toLowerCase().indexOf("https://") > -1) domain = domain.substring(domain.toLowerCase().indexOf("https:") + 8);
        else if(domain.toLowerCase().indexOf("http://") > -1) domain = domain.substring(domain.toLowerCase().indexOf("http:") + 7);

        if(domain.indexOf("/") > -1) domain = domain.substring(0, domain.indexOf("/"));
        return domain.trim();
    }

    String getRelativeFilePath(com.etn.beans.Contexte Etn, String url, String filename){
        String basedir =  GlobalParm.getParm("DOWNLOAD_PAGES_FOLDER");
        if(!basedir.trim().endsWith("/")) basedir = basedir + "/";
        basedir += "0" + "/";

        String domain  = getDomain(url);
        String localPath = getLocalPath(Etn, url);

        String path = basedir;
        path += getFolderId(Etn, domain);
        path += localPath + filename;

        return path;
    }

    String getRelativeFilePathCKEditor(com.etn.beans.Contexte Etn, String url, String filename){

        String basedir =  GlobalParm.getParm("CKEDITOR_DOWNLOAD_PAGES_FOLDER");

        if(!basedir.trim().endsWith("/")) basedir = basedir + "/";
        basedir += "0" + "/";

        String domain  = getDomain(url);
        String localPath = getLocalPath(Etn, url);

        String path = basedir;
        path += getFolderId(Etn, domain);
        path += localPath + filename;

        return path;
    }

%>

<%
    String status = "ERROR";
    String message = "";

    String createType = parseNull(request.getParameter("type"));
    String name = parseNull(request.getParameter("urlname")).trim();
    String jsonId = parseNull(request.getParameter("esjsonId"));
    int layoutDesign = parseNullInt(request.getParameter("layout_design"));
    int counter = 0;

    if("new".equals(createType) && name.length() > 0 ){
        try{
            
            Set expertSystemHtmlRs = Etn.execute("SELECT * FROM expert_system_html WHERE json_id = " + escape.cote(jsonId) + " ORDER BY tag_id;");
            Set expertSystemScriptRs = Etn.execute("SELECT parent_json_tag, d3chart, GROUP_CONCAT(json_tag ORDER BY json_tag) as json_tag FROM expert_system_script WHERE json_id = " + escape.cote(jsonId) + " AND LENGTH(html_tag) > 0 GROUP BY 1 ORDER BY parent_json_tag");
            Set expertSystemJsonRs = Etn.execute("SELECT * FROM expert_system_json WHERE id = "  + escape.cote(jsonId));

            //remove whitespaces from  url
            String url  = name = name.replaceAll("/", "").replaceAll("\\\\", "").replace(" ","-");
    
            String pageName = url;//store as page name in pagetype
            pageName = Base64.encode(pageName.getBytes("UTF-8"));

            String fileName = name + ".html";
            String relPath = getRelativeFilePath(Etn, url, fileName);
            
            String fullPath = relPath;
            message = fullPath;
            
            File htmlFile = new File(fullPath);

            if(!htmlFile.exists()){

                String dirPath = fullPath.substring(0, fullPath.lastIndexOf(fileName));
                File dirPathFile = new File(dirPath);
                dirPathFile.mkdirs();
                htmlFile.createNewFile();
            }
            
            String output = "";
            Set rsParams = Etn.execute("select distinct param from expert_system_query_params where param NOT LIKE '%__session_%' AND json_id = " + escape.cote(jsonId));

            expertSystemJsonRs.next();
            String _url = parseNull(expertSystemJsonRs.value("url"));
            if(_url.indexOf("?") > -1) _url = _url.substring(0, _url.indexOf("?"));

            if(rsParams.rs.Rows > 0){
                
                output += "<div class=\"col-sm-12 col-xs-12 col-md-12\" style=\"margin-bottom: 20px;\">";
                output += "\t<form id=\"__es_form_params_"+parseNull(expertSystemJsonRs.value("json_uuid"))+"\" name=\"\" >\n";
                output += "<div class=\"form-row\">";
                while(rsParams.next())
                {

                    output += "\t\t<div class=\"form-group col-md-6\"><label>"+rsParams.value("param")+"</label>&nbsp;<input class=\"form-control\" type='text' name='"+rsParams.value("param")+"' id='param_"+rsParams.value("param")+"' value='' /></div>\n";
                }

                output += "<input type=\"hidden\" name=\"jsonId\" value=\""+parseNull(expertSystemJsonRs.value("json_uuid"))+"\" />";
    
                output += "</div>";
    
                if(rsParams.rs.Rows > 0) 
                {
                    output += "\t\t<br/> <div class=\"col-sm-12 col-xs-12 col-md-12\" style=\"text-align: center;\"> <button class=\"btn btn-primary\" type='button' id='__submit_form_es_"+parseNull(expertSystemJsonRs.value("json_uuid"))+"' >Search</button> </div> \n";
                }

                output += "\t</form>\n";
                output += "</div>";

            }

            //write basic html to the file
            StringBuffer pageContent = new StringBuffer();

            pageContent.append("<!doctype html>");
            
            pageContent.append("<html>");

            pageContent.append("<head>");
            pageContent.append("<link href=\""+GlobalParm.getParm("EXPERT_SYSTEM_WEB_APP")+"css/bootstrap.min.css\" rel=\"stylesheet\" type=\"text/css\">");
            pageContent.append("<SCRIPT LANGUAGE=\"JavaScript\" SRC=\""+GlobalParm.getParm("CKEDITOR_WEB_APP")+"js/ck_default.js\" ></script>");
            pageContent.append("</head>");
 
            pageContent.append("<body class=\"container\">");
            
            pageContent.append("\n <!-- YOU CAN ONLY CHANGE THE LABEL OF THE EXPERT SYSTEM BLOCK FOR THE SAVER SIDE --> \n");
            pageContent.append("\n <!-- START EXPERT SYSTEM LAYOUT BLOCK --> \n");
            pageContent.append("<div id=\"___es_desgin_layout_main_\" style=\"margin-top: 50px; margin-bottom: 50px;\" class=\"expertsystemcomponent col-sm-12 col-xs-12 col-md-12\" data-es-files-url=\"");
            pageContent.append(GlobalParm.getParm("EXPERT_SYSTEM_WEB_APP"));
            pageContent.append("ckEditorApplyRules.jsp\" ");
            pageContent.append("data-jsonid=\"");
            pageContent.append(parseNull(expertSystemJsonRs.value("json_uuid")));
            pageContent.append("\" fetch-data-es-url=\"");
            pageContent.append(GlobalParm.getParm("EXPERT_SYSTEM_WEB_APP"));
            pageContent.append("fetchdata.jsp\" >");

            int qL = expertSystemScriptRs.rs.Rows;

            pageContent.append(output);

            while(expertSystemScriptRs.next()){
                
                pageContent.append("\n <!-- START EXPERT SYSTEM CONTENT BLOCK --> \n");
                pageContent.append("<div class=\"row\">");
                for(int i=0; i<layoutDesign; i++){

                    if(i>0) expertSystemScriptRs.next();

                    if(expertSystemScriptRs.rs.Rows > counter){

                        counter++;
    
                        if(layoutDesign==1) pageContent.append("<div class=\"col-sm-12 col-xs-12 col-md-12 row\" >");
                        else if(layoutDesign==2){
                            
                            if(qL%2==0) pageContent.append("<div class=\"col-sm-6 col-xs-6 col-md-6\">");
                            else if(qL==counter) pageContent.append("<div class=\"col-sm-12 col-xs-12 col-md-12\">");
                            else pageContent.append("<div class=\"col-sm-6 col-xs-6 col-md-6\">");
                        } 
                        
                        expertSystemHtmlRs.next();

//                        pageContent.append("<div class=\"expertsystemcomponent\" >");
                        pageContent.append("<div class=\"panel panel-default\"><div class=\"panel-body\">");

                        if(expertSystemHtmlRs.value("tag_type").equals("SPAN")){
                            
                            StringTokenizer st = new StringTokenizer(parseNull(expertSystemScriptRs.value("json_tag")), ",");

                            while(st.hasMoreTokens()){
                                
                                String tag = parseNull(st.nextToken());
                                pageContent.append("<span style=\"font-weight:bold;\">"+tag+" : </span>&nbsp;");
                                pageContent.append("<span id='"+ expertSystemScriptRs.value("parent_json_tag").replace(".","_") +"_" + tag + "'>&nbsp;</span> <br/>");
                            }

                        }else if(expertSystemHtmlRs.value("tag_type").equals("TABLE")){

                            pageContent.append("<table class=\"table\" id='"+expertSystemHtmlRs.value("tag_id")+"' style='font-size:12px'></table>");
    
                        }else if(parseNull(expertSystemScriptRs.value("parent_json_tag")).startsWith("c3json_") && parseNull(expertSystemScriptRs.value("json_tag")).startsWith("data")){
                            
                            pageContent.append("<div id='"+expertSystemHtmlRs.value("tag_id")+"'></div>");

                        }else if(parseNull(expertSystemScriptRs.value("parent_json_tag")).startsWith("d3json_") && parseNull(expertSystemScriptRs.value("json_tag")).startsWith("data")){

                            if("treemap".equals(parseNull(expertSystemScriptRs.value("d3chart")))) {
                                pageContent.append("<div >click or option-click to descend or ascend: <select id='"+expertSystemHtmlRs.value("tag_id")+"_size_count_select'><option value='size'>Size</option><option value='count'>Count</option></select></div>");
                            }
                            
                            pageContent.append("<div id='"+expertSystemHtmlRs.value("tag_id")+"'></div>");
    
                        }else if(parseNull(expertSystemScriptRs.value("parent_json_tag")).startsWith("d3mapjson_") && parseNull(expertSystemScriptRs.value("json_tag")).startsWith("data")){
                            
                            pageContent.append("<div id='"+expertSystemHtmlRs.value("tag_id")+"' style='width: 700px; height: 433px;'></div>");

                        }else if(parseNull(expertSystemScriptRs.value("parent_json_tag")).startsWith("d3mapchljson_") && parseNull(expertSystemScriptRs.value("json_tag")).startsWith("data")){
                            
                            pageContent.append("<div id='"+expertSystemHtmlRs.value("tag_id")+"' style='width: 700px; height: 433px;'></div>");
                        }

                        pageContent.append("</div></div></div>");
//                        pageContent.append("</div>");

                    }
                }

                pageContent.append("</div>");
                pageContent.append("\n<!-- END EXPERT SYSTEM CONTENT BLOCK -->\n");
            }


            pageContent.append("</div>");
            pageContent.append("\n <!-- END EXPERT SYSTEM LAYOUT BLOCK --> \n");
            pageContent.append("</body>");
            pageContent.append("</html>");

            writeFile(htmlFile, pageContent.toString());

            //insert entry in table

            String content_type = "text/html;charset=UTF-8";
            String menu_id  = "-1";
            String encoded_url = Base64.encode(url.getBytes("UTF-8"));

            String insQ = "INSERT INTO " + GlobalParm.getParm("CKEDITOR_DB_NAME") + ".cached_pages(url, filename, content_type, menu_id, hex_eurl,encoded_url, pagetype, dpagetype, is_es_page, es_page_layout)"
                            + " VALUES ( "+escape.cote(url)+", "+escape.cote(fileName)
                            +", "+ escape.cote(content_type)
                            +", "+escape.cote(menu_id)+", "+escape.cote(encoded_url)+", "+escape.cote(encoded_url)+", "+escape.cote(pageName)
                            +", "+escape.cote(url)
                            +", "+escape.cote("1")
                            +", "+layoutDesign+" )";
            //message = insQ;
            
            int rowId = Etn.executeCmd(insQ);
            if(rowId <= 0){
                //some error in query
                status = "ERROR";
                message = "Error: adding record in DB.";
            }else{
                
                String updateQuery = "UPDATE expert_system_json SET ckeditor_page_id = "+escape.cote(rowId+"")+" WHERE id = "+escape.cote(jsonId);
                Etn.executeCmd(updateQuery);
                status = "SUCCESS";
                message = "Page added successfully.";
            }
        }
        catch(Exception ex){
            status = "ERROR";
            message = ex.getMessage();
        }
     
        out.write("{\"RESPONSE\":\""+status+"\",\"MESSAGE\":\""+message+"\"  }");
    
    } else if("update".equals(createType)){
        
        String ckeditorPageId = parseNull(request.getParameter("ckeditor_page_id"));

        Set ckeditorRs = Etn.execute("SELECT id, url, filename, es_page_layout FROM " + GlobalParm.getParm("CKEDITOR_DB_NAME") + ".cached_pages WHERE id = "+escape.cote(ckeditorPageId));
        
        if(ckeditorRs.next()){
            
            String fileName = ckeditorRs.value("filename");
            String pageUrl = ckeditorRs.value("url");
            String relPath = getRelativeFilePath(Etn, pageUrl, fileName);

            try{

                Set expertSystemHtmlRs = Etn.execute("SELECT * FROM expert_system_html WHERE json_id = " + escape.cote(jsonId) + " ORDER BY tag_id;");
                Set expertSystemScriptRs = Etn.execute("SELECT parent_json_tag, GROUP_CONCAT(json_tag ORDER BY json_tag) as json_tag FROM expert_system_script WHERE json_id = " + escape.cote(jsonId) + " AND LENGTH(html_tag) > 0 GROUP BY 1 ORDER BY parent_json_tag");
                Set expertSystemJsonRs = Etn.execute("SELECT * FROM expert_system_json WHERE id = "  + escape.cote(jsonId));

                String output = "";
                Set rsParams = Etn.execute("select distinct param from expert_system_query_params where param NOT LIKE '%__session_%' AND json_id = " + escape.cote(jsonId));

                expertSystemJsonRs.next();
                String _url = parseNull(expertSystemJsonRs.value("url"));
                if(_url.indexOf("?") > -1) _url = _url.substring(0, _url.indexOf("?"));

                if(rsParams.rs.Rows > 0){
                    
                    output += "<div class=\"col-sm-12 col-xs-12 col-md-12\" style=\"margin-bottom: 20px;\">";
                    output += "\t<form id=\"__es_form_params_"+parseNull(expertSystemJsonRs.value("json_uuid"))+"\" name=\"\" >\n";
                    output += "<div class=\"form-row\">";
                    while(rsParams.next())
                    {

                        output += "\t\t<div class=\"form-group col-md-6\"><label>"+rsParams.value("param")+"</label>&nbsp;<input class=\"form-control\" type='text' name='"+rsParams.value("param")+"' id='param_"+rsParams.value("param")+"' value='' /></div>\n";
                    }

                    output += "<input type=\"hidden\" name=\"jsonId\" value=\""+parseNull(expertSystemJsonRs.value("json_uuid"))+"\" />";
        
                    output += "</div>";
        
                    if(rsParams.rs.Rows > 0) 
                    {
                        output += "\t\t<br/> <div class=\"col-sm-12 col-xs-12 col-md-12\" style=\"text-align: center;\"> <button class=\"btn btn-primary\" type='button' id='__submit_form_es_"+parseNull(expertSystemJsonRs.value("json_uuid"))+"' >Search</button> </div> \n";
                    }

                    output += "\t</form>\n";
                    output += "</div>";

                }

                int qL = expertSystemScriptRs.rs.Rows;

                StringBuffer pageContent = new StringBuffer();
                
                pageContent.append(output);
    
                while(expertSystemScriptRs.next()){
                    
                    pageContent.append("\n <!-- START EXPERT SYSTEM CONTENT BLOCK --> \n");
                    pageContent.append("<div class=\"row\">");
                    for(int i=0; i<layoutDesign; i++){

                        if(i>0) expertSystemScriptRs.next();

                        if(expertSystemScriptRs.rs.Rows > counter){

                            counter++;
        
                            if(layoutDesign==1) pageContent.append("<div class=\"col-sm-12 col-xs-12 col-md-12 row\" >");
                            else if(layoutDesign==2){
                                
                                if(qL%2==0) pageContent.append("<div class=\"col-sm-6 col-xs-6 col-md-6\">");
                                else if(qL==counter) pageContent.append("<div class=\"col-sm-12 col-xs-12 col-md-12\">");
                                else pageContent.append("<div class=\"col-sm-6 col-xs-6 col-md-6\">");
                            } 
                            
                            expertSystemHtmlRs.next();

//                            pageContent.append("<div class=\"expertsystemcomponent\" >");
                            pageContent.append("<div class=\"panel panel-default\"><div class=\"panel-body\">");

                            if(expertSystemHtmlRs.value("tag_type").equals("SPAN")){
                                
                                StringTokenizer st = new StringTokenizer(parseNull(expertSystemScriptRs.value("json_tag")), ",");

                                while(st.hasMoreTokens()){
                                    
                                    String tag = parseNull(st.nextToken());
                                    pageContent.append("<span style=\"font-weight:bold;\">"+tag+" : </span>&nbsp;");
                                    pageContent.append("<span id='"+ expertSystemScriptRs.value("parent_json_tag").replace(".","_") +"_" + tag + "'>&nbsp;</span> <br/>");
                                }

                            }else if(expertSystemHtmlRs.value("tag_type").equals("TABLE")){

                                pageContent.append("<table class=\"table\" id='"+expertSystemHtmlRs.value("tag_id")+"' style='font-size:12px'></table>");
        
                            }else if(parseNull(expertSystemScriptRs.value("parent_json_tag")).startsWith("c3json_") && parseNull(expertSystemScriptRs.value("json_tag")).startsWith("data")){
                            
                                pageContent.append("<div id='"+expertSystemHtmlRs.value("tag_id")+"'></div>");

                            }else if(parseNull(expertSystemScriptRs.value("parent_json_tag")).startsWith("d3json_") && parseNull(expertSystemScriptRs.value("json_tag")).startsWith("data")){

                                if("treemap".equals(parseNull(expertSystemScriptRs.value("d3chart")))) {
                                    pageContent.append("<div >click or option-click to descend or ascend: <select id='"+expertSystemHtmlRs.value("tag_id")+"_size_count_select'><option value='size'>Size</option><option value='count'>Count</option></select></div>");
                                }
                                
                                pageContent.append("<div id='"+expertSystemHtmlRs.value("tag_id")+"'></div>");
        
                            }else if(parseNull(expertSystemScriptRs.value("parent_json_tag")).startsWith("d3mapjson_") && parseNull(expertSystemScriptRs.value("json_tag")).startsWith("data")){
                                
                                pageContent.append("<div id='"+expertSystemHtmlRs.value("tag_id")+"' style='width: 700px; height: 433px;'></div>");

                            }else if(parseNull(expertSystemScriptRs.value("parent_json_tag")).startsWith("d3mapchljson_") && parseNull(expertSystemScriptRs.value("json_tag")).startsWith("data")){
                                
                                pageContent.append("<div id='"+expertSystemHtmlRs.value("tag_id")+"' style='width: 700px; height: 433px;'></div>");
                            }

                            pageContent.append("</div></div></div>");
//                            pageContent.append("</div>");

                        }
                    }

                    pageContent.append("</div>");
                    pageContent.append("\n<!-- END EXPERT SYSTEM CONTENT BLOCK -->\n");
                }

                Document doc = Jsoup.parse(new File(relPath), "utf-8"); 
                Element divTag = doc.getElementById("___es_desgin_layout_main_"); 
                
                divTag.html(pageContent.toString());
                writeFile(new File(relPath), doc.toString());

                String updateQuery = "UPDATE " + GlobalParm.getParm("CKEDITOR_DB_NAME") + ".cached_pages SET es_page_layout = "+escape.cote(layoutDesign)+" WHERE id = "+escape.cote(ckeditorPageId);
                Etn.executeCmd(updateQuery);

                status = "SUCCESS";
                message = "Page updated successfully.";

            }catch(Exception e){
                status = "ERROR";
                message = e.getMessage();
            }

            out.write("{\"RESPONSE\":\""+status+"\",\"MESSAGE\":\""+message+"\"  }");

        }
        
        
    } else if("getCkeditorPageName".equals(createType)){
        
        String ckeditorPageId = parseNull(request.getParameter("ckeditor_page_id"));

        Set ckeditorRs = Etn.execute("SELECT id, url, filename, es_page_layout FROM " + GlobalParm.getParm("CKEDITOR_DB_NAME") + ".cached_pages WHERE id = "+escape.cote(ckeditorPageId));
        Set expertSystemRs = Etn.execute("SELECT * FROM expert_system_html WHERE json_id = "+escape.cote(jsonId));

        String json = "{";


        if(ckeditorRs.next()){

            String fileName = ckeditorRs.value("filename");
            String pageUrl = ckeditorRs.value("url");
            String relPath = getRelativeFilePathCKEditor(Etn, pageUrl, fileName);
            
            json += "\"name\":\""+ckeditorRs.value("url")+"\",\"file_path\":\""+relPath+"\",\"design_layout\":\""+ckeditorRs.value("es_page_layout")+"\",";

        } else json += "\"name\":\"\",\"file_path\":\"\",\"design_layout\":\"\",";

        json += "\"html_generated\":\""+expertSystemRs.rs.Rows+"\"";

        json += "}";
        
        out.write(json);
    
    }

%>
