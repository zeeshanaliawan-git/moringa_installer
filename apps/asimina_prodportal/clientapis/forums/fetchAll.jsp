<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>


<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape,com.etn.beans.app.GlobalParm,com.etn.asimina.util.PortalHelper"%>
<%@ page import="org.json.JSONObject,org.json.JSONArray, java.util.*"%>

<%
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

	com.etn.asimina.beans.Client client = com.etn.asimina.session.ClientSession.getInstance().getLoggedInClient(Etn, request);

	String[] tags = request.getParameterValues("tag");
	String[] categories = request.getParameterValues("categories");
	String pno = PortalHelper.parseNull(request.getParameter("pno"));
	String pagesize = PortalHelper.parseNull(request.getParameter("psize"));
	if(pagesize.length() == 0 || pagesize.equals(null)) pagesize = "25";
	int nPageSize = 25;
	try {
		nPageSize = PortalHelper.parseNullInt(pagesize);
	}catch (Exception e) { }
	int pageno = 1;
	try	{
		pageno = PortalHelper.parseNullInt(pno);
	} catch (Exception e) { }

	//user will start pageno from 1 but for us it should be 0
	pageno = pageno - 1;
	if(pageno < 0) pageno = 0;

	try{
        String limitApply=" Limit "+(pageno*Integer.parseInt(pagesize))+", "+pagesize;
        List<JSONObject> respObjArray = new ArrayList<>();

		String qry = "SELECT distinct r.post_id, r.source_id, r.source_type,r.forum_topic, r.post_parent_id, r.type, r.category,  "+
						" date_format(r.created_dt,'%d/%m/%Y %h:%i:%s') created_dt, date_format(r.created_dt, '%Y-%m-%dT%H:%i:%s') created_ts_iso, "+
						" date_format(r.org_reply_date,'%d/%m/%Y %h:%i:%s') org_reply_date, date_format(r.org_reply_date,'%Y-%m-%dT%H:%i:%s') org_reply_ts_iso, "+
						" date_format(r.verification_date,'%d/%m/%Y %h:%i:%s') verification_date, date_format(r.verification_date,'%Y-%m-%dT%H:%i:%s') verification_ts_iso, "+
						" r.rating, r.content, r.org_reply,  r.org_reply_by, r.moderation_score, "+
						" r.sentiment_score, r.nb_likes, r.nb_dislikes, r.is_pinned, case when COALESCE(r.is_signaled,'') = '' then 0 else 1 end is_signaled, r.is_verified, "+
						" c.name as author_owner_name, c.surname as author_owner_surname, c.avatar as author_owner_avatar, count(rcomments.post_id) as no_of_comments "+
						" FROM client_reviews r left join client_reviews rcomments on rcomments.source_type = 'forum' and rcomments.source_id = r.post_id and rcomments.is_deleted = 0, clients c ";
		if(tags != null && tags.length > 0)
		{
			qry += ", client_review_tags crt ";
		}
						
		qry += " WHERE r.site_id = "+escape.cote(siteid)+" and r.source_type = 'forum' and r.type = 'forum' and r.is_verified = 1 ";
		if(tags != null && tags.length > 0)
		{
			qry += " and crt.post_id = r.post_id ";
			String inclause = "(";
			for(int i=0;i<tags.length;i++)
			{
				if(i>0) inclause += ",";
				inclause += escape.cote(tags[i]);
			}
			inclause += ")";
			qry += " and crt.tag_id in "+inclause;
		}

		if(categories != null && categories.length > 0)
		{
			String inclause = "(";
			for(int i=0;i<categories.length;i++)
			{
				if(i>0) inclause += ",";
				inclause += escape.cote(categories[i]);
			}
			inclause += ")";
			qry += " and r.category in "+inclause;
		}
		
		qry += " and r.client_id=c.client_uuid and r.is_deleted =0 group by r.post_id order by r.created_dt desc " + limitApply;
		Set rs = Etn.executeWithCount(qry);
		int nbRes = Etn.UpdateCount;
		obj.put("total_records", nbRes);
		
		if(nbRes <= Integer.parseInt(pagesize)){
			obj.put("total_pages", 1);
		}else{
			obj.put("total_pages", (int)(nbRes/nPageSize)+1);
		}
        while(rs.next()){
            JSONObject forumObj = new JSONObject();
            JSONObject author = new JSONObject();
            forumObj.put("author",author);
            for(String colName: rs.ColName){
                if(colName.toLowerCase().startsWith("author_"))
                {
                    author.put(colName.toLowerCase().substring("author_".length()), rs.value(colName));
                }
                else{
					if(colName.toLowerCase().equals("post_id"))
					{
						String fPostId = rs.value(colName);
						
						JSONArray fTags = new JSONArray();
						Set rsTags = Etn.execute("select ft.* from client_reviews cr, client_review_tags crt, "+GlobalParm.getParm("COMMONS_DB")+".forum_tags ft "+
											" where cr.post_id = crt.post_id and ft.site_id = cr.site_id and ft.tag_id = crt.tag_id and crt.post_id = "+escape.cote(fPostId));
						while(rsTags.next())
						{
							JSONObject fTag = new JSONObject();
							fTag.put("id", rsTags.value("tag_id"));
							fTag.put("name", rsTags.value("tag_name"));
							fTags.put(fTag);
						}
						forumObj.put("tags", fTags);
						
						if(client != null)
						{
							Set rsC = Etn.execute("select * from client_favorites where source_type='forum' and source_id = "+escape.cote(fPostId)+" and client_id = "+escape.cote(client.getProperty("client_uuid")));
							if(rsC.next()) forumObj.put("client_favorite", true);
							else forumObj.put("client_favorite", false);
							
							rsC = Etn.execute("SELECT is_like FROM client_reactions WHERE client_id="+escape.cote(client.getProperty("client_uuid"))+" AND source_type= 'forum' AND source_id="+escape.cote(fPostId));
							if(rsC.next())
							{
								String clientReaction = "disliked";
								if(PortalHelper.parseNull(rsC.value("is_like")).equals("1")) clientReaction = "liked";
								forumObj.put("client_reaction", clientReaction);
							}

						}
					}
                    forumObj.put(colName.toLowerCase(),rs.value(colName));
                }
            }
            respObjArray.add(forumObj);
        }

        obj.put("data",respObjArray);

	}catch(Exception e){
        message="Some  error occured while getting data.";
        status=2;
	}

	obj.put("msg",message);
    obj.put("status", status);
    

    out.write(obj.toString());
%>