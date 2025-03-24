<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>


<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape,com.etn.beans.app.GlobalParm,com.etn.asimina.util.PortalHelper"%>
<%@ page import="org.json.*, java.util.*"%>

<%!
	void getChildFolders(com.etn.beans.Contexte Etn, String fid, List<String> allFolders)
	{
		Set rs = Etn.execute("select * from "+GlobalParm.getParm("PAGES_DB")+".folders where parent_folder_id = "+escape.cote(fid));
		while(rs.next())
		{
			allFolders.add(rs.value("id"));
			getChildFolders(Etn, rs.value("id"), allFolders);
		}
	}
%>
<%
	//increase buffer size
	Etn.setSeparateur(2, '\001', '\002');

    String message="";
    int status=0;
    JSONObject obj = new JSONObject();

	String siteuuid = PortalHelper.parseNull(request.getParameter("suid"));
	if(siteuuid.length() == 0)
	{
		message="Site uuid is required";
		status = 10;						
		obj.put("msg",message);
		obj.put("status", status);

		out.write(obj.toString());
		return;		
	}
	
	Set rsSite = Etn.execute("Select * from sites where suid = "+escape.cote(siteuuid));
	if(rsSite.rs.Rows == 0)
	{
		message="Invalid site uuid provided";
		status = 10;						
		obj.put("msg",message);
		obj.put("status", status);

		out.write(obj.toString());
		return;
	}
	
	rsSite.next();
	String siteid = rsSite.value("id");

	String lang = PortalHelper.parseNull(request.getParameter("lang"));
	if(lang.length() == 0)
	{
		Set rsL = Etn.execute("select * from language order by langue_id");
		if(rsL.next())
		{
			lang = rsL.value("langue_code");
		}
	}
	
    com.etn.asimina.beans.Client client = com.etn.asimina.session.ClientSession.getInstance().getLoggedInClient(Etn, request);

    try
	{
		boolean loadAll = "1".equals(PortalHelper.parseNull(request.getParameter("load_all")));
		
		String sortDirection = PortalHelper.parseNull(request.getParameter("sort_direction"));
		String orderBy = PortalHelper.parseNull(request.getParameter("order_by"));
		String pno = PortalHelper.parseNull(request.getParameter("pno"));
		String pagesize = PortalHelper.parseNull(request.getParameter("psize"));
		if(pagesize.length() == 0 || pagesize.equals(null)) pagesize = "25";
		int pageno = 1;
		try	{
			pageno = PortalHelper.parseNullInt(pno);
		} catch (Exception e) { pageno = 1; }

		//user will start pageno from 1 but for us it should be 0
		pageno = pageno - 1;
		if(pageno < 0) pageno = 0;
		
		String limitApply=" Limit "+(pageno*Integer.parseInt(pagesize))+", "+pagesize;

		List<String> folderIds = new ArrayList<String>();
		String[] folderUuids = request.getParameterValues("folder_id");		
		if(folderUuids != null)
		{
			for(String fuuid : folderUuids)
			{
				Set rsF = Etn.execute("select * from "+GlobalParm.getParm("PAGES_DB")+".folders where uuid = "+escape.cote(fuuid) + " and site_id = "+escape.cote(siteid));
				if(rsF.next())
				{
					folderIds.add(rsF.value("id"));
				}
				else
				{
					message="Folder ID : "+fuuid+" does not belong to this site";
					status = 10;						
					obj.put("msg",message);
					obj.put("status", status);

					out.write(obj.toString());
					return;					
				}
			}
		}
				
		List<String> allFolders = new ArrayList<String>();
		for(String fid : folderIds)
		{
			allFolders.add(fid);
			if(loadAll) getChildFolders(Etn, fid, allFolders);
		}

		String query = "select date_format(p.created_ts, '%Y-%m-%dT%H:%i:%s') created_ts, p.id, p.uuid, p.name, "+
						" coalesce(c1.no_of_likes,0) no_of_likes, coalesce(c1.no_of_dislikes,0) no_of_dislikes, coalesce(c2.no_of_comments,0) no_of_comments, coalesce(c3.no_of_reviews, 0) no_of_reviews "+
						"from "+GlobalParm.getParm("PAGES_DB")+".pages p ";
		if(allFolders.size() > 0)
		{
			String inclause = "(";
			for(int i=0;i<allFolders.size();i++)
			{
				if(i>0) inclause += ",";
				inclause += escape.cote(allFolders.get(i));
			}
			inclause += ")";
			
			query += " join "+GlobalParm.getParm("PAGES_DB")+".folders f on f.id in "+inclause+" and f.id = p.folder_id ";
		}
		query += " left join ( "+
				" select cr.source_id, sum(case when cr.is_like = 1 then 1 else 0 end) no_of_likes, sum(case when cr.is_like = 0 then 1 else 0 end) no_of_dislikes "+
				" from client_reactions cr where cr.source_type = 'page' "+
				" group by cr.source_id "+
				") c1 on c1.source_id = p.uuid  "+
				" left join ( "+
				" select cv.source_id, count(cv.post_id) as no_of_comments "+
				" from client_reviews cv where cv.source_type = 'page' and cv.type = 'comment' "+
				" group by cv.source_id "+
				" ) c2 on c2.source_id = p.uuid "+
				" left join ( "+
				" select cv.source_id, count(cv.post_id) as no_of_reviews "+
				" from client_reviews cv where cv.source_type = 'page' and cv.type = 'review' "+
				" group by cv.source_id "+
				" ) c3 on c3.source_id = p.uuid "+
				" order by ";

		if(orderBy.equalsIgnoreCase("likes"))
		{
			query += " no_of_likes ";
		}
		else if(orderBy.equalsIgnoreCase("dislikes"))
		{
			query += " no_of_dislikes ";
		}
		else if(orderBy.equalsIgnoreCase("comments"))
		{
			query += " no_of_comments ";
		}
		else if(orderBy.equalsIgnoreCase("reviews"))
		{
			query += " no_of_reviews ";
		}
		else if(orderBy.equalsIgnoreCase("name"))
		{
			query += " name ";
		}
		else
		{
			query += " created_ts ";
		}
		if(sortDirection.equalsIgnoreCase("desc"))
		{
			query += " desc ";
		}

		query += limitApply;
		
		System.out.println(query);
		
		Set rs = Etn.executeWithCount(query);
		int nbRes = Etn.UpdateCount;
		
		obj.put("total_records", nbRes);
		
		if(nbRes <= Integer.parseInt(pagesize)){
			obj.put("total_pages", 1);
		}else{
			obj.put("total_pages", (int)(nbRes/Integer.parseInt(pagesize))+1);
		}

		JSONArray result = new JSONArray();
		while(rs.next()){
			JSONObject jPage = new JSONObject();
			
			jPage.put("created_ts", rs.value("created_ts"));
			jPage.put("uuid", rs.value("uuid"));
			jPage.put("name", rs.value("name"));
			jPage.put("no_of_likes", rs.value("no_of_likes"));
			jPage.put("no_of_dislikes", rs.value("no_of_dislikes"));
			jPage.put("no_of_comments", rs.value("no_of_comments"));
			jPage.put("no_of_reviews", rs.value("no_of_reviews"));
			
			Set rsP = Etn.execute("select ccv.published_url as url from cached_content_view ccv where ccv.content_type = 'page'"+
				" and ccv.content_id ="+escape.cote(rs.value("id"))+" and ccv.site_id = "+escape.cote(siteid)+
				" and ccv.lang ="+escape.cote(lang));
			if(rsP.next()){
				jPage.put("url", rsP.value("url"));
			}else{
				jPage.put("url", "");
			}
			
			//check if page is a structured page then we add its data to json
			Set rsSc = Etn.execute("select scd.fd_content_data_3 from "+GlobalParm.getParm("PAGES_DB")+".pages p inner join "+GlobalParm.getParm("PAGES_DB")+".structured_contents_details scd on scd.page_id = p.id where p.type = 'structured' and p.uuid = "+escape.cote(rs.value("uuid")));
			if(rsSc.next())
			{				
				String contentsJson = PortalHelper.parseNull(rsSc.value("fd_content_data_3"));
				if(contentsJson.length() == 0) contentsJson = "{}";
				jPage.put("contents", new JSONObject(contentsJson));
			}
			
			result.put(jPage);
		}
		obj.put("data", result);
		message="Data fetched successfully.";

    }catch (Exception e){
        message="Error fetching data.";
        status=2;
    }

    obj.put("msg",message);
    obj.put("status", status);

    out.write(obj.toString());
%>