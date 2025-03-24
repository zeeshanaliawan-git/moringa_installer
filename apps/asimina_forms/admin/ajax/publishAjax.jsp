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
<%@ include file="/common2.jsp"%>


<%
	String siteId = getSelectedSiteId(session);

    int STATUS_SUCCESS = 1, STATUS_ERROR = 0;

    int status = STATUS_ERROR;
    String message = "";
    String pagesFormsError = "";
    String q = "";
    Set rs = null;

    String requestType = parseNull(request.getParameter("requestType"));

    if("isPublishLogin".equalsIgnoreCase(requestType)){

        try{
            String COMMONS_DB = GlobalParm.getParm("COMMONS_DB");
        	q = " SELECT 1 FROM "+COMMONS_DB+".user_sessions "
        		+ " WHERE is_publish_prod_login = 1 AND forms_session_id = " + escape.cote(session.getId());
        	rs = Etn.execute(q);

        	if(rs.next()){
        		status = STATUS_SUCCESS;
        	}

        }//try
        catch(Exception ex){
            throw new Exception("Error in checking publish login.",ex);
        }
    }
    else if("doPublishLogin".equalsIgnoreCase(requestType)){

        try{

            String username = parseNull(request.getParameter("username"));
            String password = parseNull(request.getParameter("password"));

            q = "SELECT l.pid FROM login l, profil pr, profilperson pp "
                + " WHERE pr.profil not in ('PROD_CACHE_MGMT','PROD_SITE_ACCESS','TEST_SITE_ACCESS') "
                + " AND l.pid = pp.person_id  "
                + " AND pp.profil_id = pr.profil_id "
                + " AND l.name = " + escape.cote(username)
                + " AND l.pass = sha2(concat("+escape.cote(GlobalParm.getParm("ADMIN_PASS_SALT"))+",':',"+escape.cote(password)+",':',l.puid),256) ";

            rs = Etn.execute(q);
            if(rs.next()){
                String COMMONS_DB = GlobalParm.getParm("COMMONS_DB");
                q = "UPDATE "+COMMONS_DB+".user_sessions SET is_publish_prod_login = 1 "
                	+  " WHERE forms_session_id = " + escape.cote(session.getId());

                Etn.executeCmd(q);
                status = STATUS_SUCCESS;
            }
            else{
                message = "Invalid username or password";
                status = STATUS_ERROR;
            }

        }//try
        catch(Exception ex){
            throw new Exception("Error in publish login.",ex);
        }
    }
    else if("publishForms".equalsIgnoreCase(requestType)){

        try{
            String formIds = parseNull(request.getParameter("ids"));
            String publishTimeStr = parseNull(request.getParameter("publishTime"));
            ArrayList<String> formIdList = new ArrayList<String>();

            String publishTime = ""; //default
            boolean isPublishNow = false;
            if(publishTimeStr.equalsIgnoreCase("now")){
                publishTime = "now";
                isPublishNow = true;
            }
            else{

                publishTime = buildDateTimeDb(publishTimeStr);

                if(publishTime.length() == 0){
                    throw new Exception("Error: Invalid publish on time");
                }
            }

            for(String formId : formIds.split(",")){

                if(formId.length() > 0){

                    q = " SELECT form_id FROM process_forms_unpublished "
                        + " WHERE form_id = " + escape.cote(""+formId)
                        + " AND site_id = " + escape.cote(siteId);

                    rs = Etn.execute(q);

                    if(rs.next()){

                       formIdList.add(formId);
                    }
                }
            }

            int fid = Etn.getId();

            if(formIdList.size() == 0){
                message = "Error: No valid form ids found";
            }

            if(isPublishNow){

                publishTime = "NOW()";

            } else {

                publishTime = escape.cote(publishTime);
            }

            for(String formId : formIdList){
                try{
                    Etn.execute("UPDATE process_forms_unpublished SET to_publish = 1, to_publish_ts = " + publishTime + ", to_publish_by = " + escape.cote(fid+"") + ",to_unpublish = 0 WHERE site_id = " + escape.cote(siteId) + " AND form_id = " + escape.cote(formId));					
                }
                catch(Exception ex){
                    ex.printStackTrace();
                }
				Etn.execute("select semfree("+escape.cote(GlobalParm.getParm("SEMAPHORE"))+")");
            }

            if(formIdList.size() == 1) {

                status = STATUS_SUCCESS;
                message = "Form is marked for publishing.";

            } else {

                status = STATUS_SUCCESS;
                message = formIdList.size() + " form(s) marked for publishing .";

            }//else

        }//try
        catch(Exception ex){
            throw new Exception("Error in publishing form(s). Please try again.",ex);
        }
    }
    else if("unpublishForms".equalsIgnoreCase(requestType)){

        try{
            String formIds = parseNull(request.getParameter("ids"));
            String publishTimeStr = parseNull(request.getParameter("publishTime"));
            ArrayList<String> formIdList = new ArrayList<String>();

            String publishTime = ""; //default
            boolean isPublishNow = false;
            int unpulishPagesFormsCount = 0;
            if(publishTimeStr.equalsIgnoreCase("now")){
                publishTime = "now";
                isPublishNow = true;
            }
            else{

                publishTime = buildDateTimeDb(publishTimeStr);

                if(publishTime.length() == 0){
                    throw new Exception("Error: Invalid unpublish on time");
                }
            }
            for(String formId : formIds.split(",")){

                if(formId.length() > 0){

                    q = " SELECT form_id, process_name FROM process_forms_unpublished "
                        + " WHERE form_id = " + escape.cote(""+formId)
                        + " AND site_id = " + escape.cote(siteId);

                    rs = Etn.execute(q);

                    if(rs.next()){
                       // check form is being used in pages or not
                        String pagesDb = GlobalParm.getParm("PAGES_DB");
                        Set formPagesRs =  Etn.execute("SELECT p.name, p.path FROM "+pagesDb+".pages_forms pf INNER JOIN "+pagesDb+".pages p ON pf.page_id = p.id WHERE pf.form_id = "+escape.cote(formId));

                        if(formPagesRs.rs.Rows>0){
                            unpulishPagesFormsCount = unpulishPagesFormsCount + 1;
                            pagesFormsError += unpulishPagesFormsCount+") "+rs.value("process_name")+":\t";
                            while(formPagesRs.next()){
                                pagesFormsError += formPagesRs.value("name")+" ("+formPagesRs.value("path")+"), ";
                            }
                            pagesFormsError += "\n";
                        }else{
                            formIdList.add(formId);
                        }
                    }
                }
            }
            int fid = Etn.getId();

			//we can have a form to be unpublished which is used in some page so in that case formIdList size will be 0
			//but unpulishPagesFormsCount will be greater than 0 and in that case we should not show this error message
			//as we did get a form id but we just cannot unpublish it
            if(formIdList.size() == 0 && unpulishPagesFormsCount == 0){
                message = "Error: No valid form ids found";
            }

            if(isPublishNow){

                publishTime = "NOW()";

            } else {

                publishTime = escape.cote(publishTime);
            }

            for(String formId : formIdList)
			{
                try{
                    Etn.execute("UPDATE process_forms_unpublished SET to_unpublish = 1, to_unpublish_ts = " + publishTime + ", to_unpublish_by = " + escape.cote(fid+"") + ",to_publish = 0 WHERE site_id = " + escape.cote(siteId) + " AND form_id = " + escape.cote(formId));
                }
                catch(Exception ex){
                    ex.printStackTrace();
                }
				Etn.execute("select semfree("+escape.cote(GlobalParm.getParm("SEMAPHORE"))+")");
            }
            if(message.length() == 0){
                if(formIdList.size() == 1) {
                    status = STATUS_SUCCESS;
                    message = "Form is marked for unpublishing.";
                } else {
                    status = STATUS_SUCCESS;
                    message = formIdList.size() + " form(s) marked for unpublishing .";
                }//else
            }
        }//try
        catch(Exception ex){
            throw new Exception("Error in unpublishing form(s). Please try again.",ex);
        }
    }else if("publishGames".equalsIgnoreCase(requestType)){
        try{
            String gameIds = parseNull(request.getParameter("ids"));
            String publishTimeStr = parseNull(request.getParameter("publishTime"));
            ArrayList<String> gameIdList = new ArrayList<String>();

            String publishTime = ""; //default
            boolean isPublishNow = false;
            if(publishTimeStr.equalsIgnoreCase("now")){
                publishTime = "now";
                isPublishNow = true;
            }
            else{

                publishTime = buildDateTimeDb(publishTimeStr);

                if(publishTime.length() == 0){
                    throw new Exception("Error: Invalid publish on time");
                }
            }

            for(String gameId : gameIds.split(",")){

                if(gameId.length() > 0){

                    q = "SELECT id FROM games_unpublished WHERE id="+escape.cote(""+gameId)+" AND site_id="+escape.cote(siteId);

                    /*q = " SELECT form_id FROM process_forms_unpublished "
                        + " WHERE form_id = " + escape.cote(""+formId)
                        + " AND site_id = " + escape.cote(siteId);*/

                    rs = Etn.execute(q);

                    if(rs.next()){
                       gameIdList.add(gameId);
                    }
                }
            }

            int fid = Etn.getId();

            if(gameIdList.size() == 0){
                message = "Error: No valid form ids found";
            }

            if(isPublishNow){

                publishTime = "NOW()";

            } else {

                publishTime = escape.cote(publishTime);
            }

            for(String gameId : gameIdList){
                try{
                    Etn.execute("UPDATE games_unpublished SET to_publish = 1, to_publish_ts = " + publishTime + ", to_publish_by = " + escape.cote(fid+"") + ",to_unpublish = 0 WHERE site_id = " + escape.cote(siteId) + " AND id = " + escape.cote(gameId));
                    Etn.execute("UPDATE process_forms_unpublished SET to_publish = 1, to_publish_ts = " + publishTime + ", to_publish_by = " + escape.cote(fid+"") + ",to_unpublish = 0 WHERE site_id = " + escape.cote(siteId) + " AND form_id = (SELECT form_id from games_unpublished WHERE id ="+escape.cote(gameId)+")");					
                }
                catch(Exception ex){
                    ex.printStackTrace();
                }
				Etn.execute("select semfree("+escape.cote(GlobalParm.getParm("SEMAPHORE"))+")");
            }

            if(gameIdList.size() == 1) {

                status = STATUS_SUCCESS;
                message = "Game is marked for publishing.";

            } else {

                status = STATUS_SUCCESS;
                message = gameIdList.size() + " game(s) marked for publishing .";

            }//else

        }//try
        catch(Exception ex){
            throw new Exception("Error in publishing Game(s). Please try again.",ex);
        }
    }else if("unpublishGames".equalsIgnoreCase(requestType)){
        try{
            String gameIds = parseNull(request.getParameter("ids"));
            String publishTimeStr = parseNull(request.getParameter("publishTime"));
            ArrayList<String> gameIdList = new ArrayList<String>();

            String publishTime = ""; //default
            boolean isPublishNow = false;
            int unpulishPagesFormsCount = 0;
            if(publishTimeStr.equalsIgnoreCase("now")){
                publishTime = "now";
                isPublishNow = true;
            }
            else{

                publishTime = buildDateTimeDb(publishTimeStr);

                if(publishTime.length() == 0){
                    throw new Exception("Error: Invalid unpublish on time");
                }
            }
            for(String gameId : gameIds.split(",")){

                if(gameId.length() > 0){
                    
                    q = "SELECT id,form_id FROM games_unpublished WHERE id="+escape.cote(""+gameId)+" AND site_id="+escape.cote(siteId);

                    /*q = " SELECT form_id, process_name FROM process_forms_unpublished "
                        + " WHERE form_id = " + escape.cote(""+formId)
                        + " AND site_id = " + escape.cote(siteId);*/

                    rs = Etn.execute(q);

                    if(rs.next()){
                       
                        gameIdList.add(gameId);
                    }
                }
            }
            int fid = Etn.getId();

			//we can have a form to be unpublished which is used in some page so in that case formIdList size will be 0
			//but unpulishPagesFormsCount will be greater than 0 and in that case we should not show this error message
			//as we did get a form id but we just cannot unpublish it
            if(gameIdList.size() == 0){
                message = "Error: No valid form ids found";
            }

            if(isPublishNow){

                publishTime = "NOW()";

            } else {

                publishTime = escape.cote(publishTime);
            }

            for(String gameId : gameIdList)
			{
                try{
                    Etn.execute("UPDATE games_unpublished SET to_unpublish = 1, to_unpublish_ts = " + publishTime + ", to_unpublish_by = " + escape.cote(fid+"") + ",to_publish = 0 WHERE site_id = " + escape.cote(siteId) + " AND id = " + escape.cote(gameId));
                    Etn.execute("UPDATE process_forms_unpublished SET to_unpublish = 1, to_unpublish_ts = " + publishTime + ", to_unpublish_by = " + escape.cote(fid+"") + ",to_publish = 0 WHERE site_id = " + escape.cote(siteId) + " AND form_id = (SELECT form_id from games_unpublished WHERE id ="+escape.cote(gameId)+")");					
                }
                catch(Exception ex){
                    ex.printStackTrace();
                }
				Etn.execute("select semfree("+escape.cote(GlobalParm.getParm("SEMAPHORE"))+")");
            }
            if(message.length() == 0){
                if(gameIdList.size() == 1) {
                    status = STATUS_SUCCESS;
                    message = "Game is marked for unpublishing.";
                } else {
                    status = STATUS_SUCCESS;
                    message = gameIdList.size() + " game(s) marked for unpublishing .";
                }//else
            }
        }//try
        catch(Exception ex){
            throw new Exception("Error in unpublishing game(s). Please try again.",ex);
        }
    }

    JSONObject jsonResponse = new JSONObject();
    jsonResponse.put("status",status);
    jsonResponse.put("message",message);
    jsonResponse.put("unpublishedPagesForms",pagesFormsError);
    out.write(jsonResponse.toString());
%>