<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, org.json.*,java.util.*, com.etn.beans.app.GlobalParm, com.etn.asimina.util.ActivityLog, com.etn.asimina.util.UIHelper, com.etn.asimina.util.BlockedUserConfig"%>

<%@ include file="../WEB-INF/include/commonMethod.jsp"%>

<%!
    boolean verifyForm(Contexte Etn, String id)
    {
        Set rs = Etn.execute("SELECT * FROM "+GlobalParm.getParm("FORMS_DB")+".process_forms_unpublished where form_id="+escape.cote(id));
        if(rs.next()) return true;
        return false;
    }

    List<String> personForms(Contexte Etn, String personId)
    {
        Set rs = Etn.execute("SELECT * FROM person_forms where person_id="+escape.cote(personId));
        List<String> selectedForms = new ArrayList();
        while(rs.next())
        {
            selectedForms.add(parseNull(rs.value("form_id")));
        }
        return selectedForms;
    } 

    JSONArray getForms(Contexte Etn, String [] sites,String personId)
    {
        List<String> usrForms = personForms(Etn,personId);
        String qry = "SELECT *,s.name as site_name FROM "+GlobalParm.getParm("FORMS_DB")+".process_forms_unpublished inner join "+GlobalParm.getParm("PORTAL_DB")+".sites s on id = site_id where site_id in ";
        String whereClause = "";
        int count=0;
        for(String sid : sites)
        {
            if(count != 0) whereClause+=",";
            whereClause += escape.cote(sid);
            count+=1;
        }

        Set rs = Etn.execute(qry+"("+whereClause+") ORDER BY site_id");

        JSONArray forms = new JSONArray();

        while(rs.next())
        {
            JSONObject form = new JSONObject();
            form.put("id",parseNull(rs.value("form_id")));
            form.put("name",parseNull(rs.value("process_name")));
            form.put("site",parseNull(rs.value("site_name")));
            if(usrForms.contains(parseNull(rs.value("form_id")))) form.put("selected",true);
            else  form.put("selected",false);
            forms.put(form);
        }
        return forms;
    }

    boolean verifyPerson(Contexte Etn, String id)
    {
        Set rs = Etn.execute("SELECT * FROM person where person_id="+escape.cote(id));
        if(rs.next()) return true;
        return false;
    }

    boolean verifySite(Contexte Etn, String id)
    {
        Set rs = Etn.execute("SELECT * FROM "+GlobalParm.getParm("PORTAL_DB")+".sites where id="+escape.cote(id));
        if(rs.next()) return true;
        return false;
    }
%>

<%
    JSONObject json = new JSONObject();

    final String method = parseNull(request.getMethod());
    final String action = parseNull(request.getParameter("action"));
    final String personId = parseNull(request.getParameter("person_id"));
    final String siteIds = parseNull(request.getParameter("sites"));

    final String [] sites = siteIds.split(",");

    if("POST".equalsIgnoreCase(method) == false)
	{
		json.put("status", 100);
		json.put("err_code", "METHOD_NOT_SUPPORTED");
		json.put("msg", "Method '"+method+"' is not supported");
		out.write(json.toString());
		return;
	}

    if(personId.length() == 0)
	{
		json.put("status", 100);
		json.put("err_code", "PERSON_ID_MISSING");
		json.put("msg", "Person id is Required");
		out.write(json.toString());
		return;
	}

    if(verifyPerson(Etn,personId) == false)
	{
		json.put("status", 100);
		json.put("err_code", "PERSON_ID_INVALID");
		json.put("msg", "Please enter correct person id");
		out.write(json.toString());
		return;
	}

    if(!("setForms".equalsIgnoreCase(action)==false || "getForms".equalsIgnoreCase(action)==false))
    {
        json.put("status", 10);
        json.put("err_code", "INVALID ACTION");
        json.put("msg", "action is not supported");
        out.write(json.toString());
        return;
    }

    if("getForms".equalsIgnoreCase(action))
    {

        if(sites.length == 0)
        {
            json.put("status", 110);
            json.put("err_code", "SITES_NOT_SELECTED");
            json.put("msg", "Please select sites");
            out.write(json.toString());
            return;
        }

        for(String site : sites){

            if(verifySite(Etn,site) == false)
            {
                json.put("status", 120);
                json.put("err_code", "INVALID_SITE");
                json.put("msg", "Invalid site");
                out.write(json.toString());
                return;
            }
        }

        JSONArray result = getForms(Etn,sites,personId);
        json.put("status", 0);
        json.put("data", result);
        out.write(json.toString());
        return;
    }

    if("setForms".equalsIgnoreCase(action))
    {
        
        final String[] ids = request.getParameterValues("ids[]");
        Etn.execute("delete from person_forms where person_id="+escape.cote(personId));
        List<String> invalidIds = new ArrayList<>();
        for(String id : ids){
            if(verifyForm(Etn,id) == false){
                invalidIds.add(id);
                continue;
            }
            Etn.executeCmd("insert into person_forms(person_id,form_id) values("+escape.cote(personId)+","+escape.cote(id)+") on duplicate key update person_id=person_id,form_id=form_id");
        }

        JSONArray result = new JSONArray();

        for(String invalidId : invalidIds)
            result.put(invalidId);
        

        json.put("status", 0);
        json.put("msg","Successfully inserted");

        if(result.length() > 0)
        json.put("data", new JSONObject().put("invalid_ids",result));
        
        out.write(json.toString());
        return;
    }     
        
%>



