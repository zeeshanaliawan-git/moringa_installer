<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>


<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape,com.etn.beans.app.GlobalParm, com.etn.asimina.util.PortalHelper"%>
<%@ page import="org.json.JSONObject, java.util.*,org.json.JSONArray"%>


<%!
	JSONArray commentReplies(com.etn.beans.Contexte Etn,com.etn.asimina.beans.Client client,String parentPostId){
		JSONArray jComments = new JSONArray();
		try{
			String qry3 = "SELECT r.post_id, r.source_id, r.source_type, r.post_parent_id, r.type, r.category,  "+
			" date_format(r.created_dt,'%d/%m/%Y %h:%i:%s') created_dt, date_format(r.created_dt, '%Y-%m-%dT%H:%i:%s') created_ts_iso, "+
			" date_format(r.org_reply_date,'%d/%m/%Y %h:%i:%s') org_reply_date, date_format(r.org_reply_date,'%Y-%m-%dT%H:%i:%s') org_reply_ts_iso, "+
			" date_format(r.verification_date,'%d/%m/%Y %h:%i:%s') verification_date, date_format(r.verification_date,'%Y-%m-%dT%H:%i:%s') verification_ts_iso, "+
			" r.rating, r.content, r.org_reply,  r.org_reply_by, r.moderation_score, "+
			" r.sentiment_score, r.nb_likes, r.nb_dislikes, r.is_pinned, case when COALESCE(r.is_signaled,'') = '' then 0 else 1 end is_signaled, r.is_verified, "+
			" c.name as author_owner_name, c.surname as author_owner_surname, c.avatar as author_owner_avatar "+
			" FROM client_reviews r, clients c "+
			" WHERE r.post_parent_id="+escape.cote(parentPostId)+" and r.client_id=c.client_uuid and r.is_deleted=0 order by r.created_dt desc";

			Set rsChildCmnts= Etn.execute(qry3);
			while(rsChildCmnts.next()){
				JSONObject jComment = new JSONObject();
				JSONObject jCommentAuthor = new JSONObject();
				for(String replyColName:rsChildCmnts.ColName){
					if(replyColName.toLowerCase().equals("post_id")){
						if(client!=null)
						{
							String clientId=client.getProperty("client_uuid");
							Set rsLiked = Etn.execute("SELECT is_like FROM client_review_reactions WHERE post_id="+escape.cote(rsChildCmnts.value(replyColName))+" AND client_id="+escape.cote(clientId));
							if(rsLiked.next())
							{
								String clientReaction = "disliked";
								if(PortalHelper.parseNull(rsLiked.value("is_like")).equals("1")) clientReaction = "liked";
								jComment.put("client_reaction", clientReaction);
							}
							else jComment.put("client_reaction", "");
						}
						else jComment.put("client_reaction", "");
						
						jComment.put("replies", commentReplies(Etn,client,rsChildCmnts.value(replyColName)));
						jComment.put(replyColName.toLowerCase(),rsChildCmnts.value(replyColName));
					}else if(replyColName.toLowerCase().startsWith("author_")){
						jCommentAuthor.put(replyColName.toLowerCase().substring("author_".length()), rsChildCmnts.value(replyColName));
					}else{
						jComment.put(replyColName.toLowerCase(),rsChildCmnts.value(replyColName));
					}
					
				}
				jComment.put("author", jCommentAuthor);

				int totalReplies = 0;
				if(jComment.has("replies"))
				{
					for(int j=0;j<jComment.getJSONArray("replies").length();j++)
					{
						totalReplies = totalReplies + jComment.getJSONArray("replies").getJSONObject(j).getInt("total_replies");
					}
				}
				jComment.put("total_replies", totalReplies);				
				jComments.put(jComment);
			}
		}catch(Exception e){
			e.printStackTrace();
		}
		return jComments;
	}
%>

<%
    String message="";
    int status=0;

    JSONObject obj = new JSONObject();

    com.etn.asimina.beans.Client client = com.etn.asimina.session.ClientSession.getInstance().getLoggedInClient(Etn, request);

	String pno = PortalHelper.parseNull(request.getParameter("pno"));
	String pagesize = PortalHelper.parseNull(request.getParameter("psize"));
	if(pagesize.length() == 0) pagesize = "25";
	int pageno = 1;
	try	{
		pageno = PortalHelper.parseNullInt(pno);
	} catch (Exception e) { pageno = 1; }

	//user will start pageno from 1 but for us it should be 0
	pageno = pageno - 1;
	if(pageno < 0) pageno = 0;

    try
	{
        String limitApply=" Limit "+(pageno*Integer.parseInt(pagesize))+", "+pagesize;
        List<JSONObject> respArray = new ArrayList<>();
        String postid = PortalHelper.parseNull(request.getParameter("post_id"));
        String sourceId = PortalHelper.parseNull(request.getParameter("source_id"));
        String sourceType = PortalHelper.parseNull(request.getParameter("source_type"));
		boolean loadAll = "1".equals(PortalHelper.parseNull(request.getParameter("loadAll")));

        if((sourceId.length() > 0 && sourceType.length() > 0) || postid.length() > 0) 
		{
			String whereclause = "";
			if(sourceId.length() > 0 && sourceType.length() > 0) whereclause = " and r.source_id="+escape.cote(sourceId)+" AND COALESCE(r.post_parent_id,'') = '' AND r.source_type="+escape.cote(sourceType) ;
			else whereclause = " and r.post_parent_id = "+escape.cote(postid);
			
            String qry = "SELECT r.post_id, r.source_id, r.source_type, r.post_parent_id, r.type, r.category,  "+
						" date_format(r.created_dt,'%d/%m/%Y %h:%i:%s') created_dt, date_format(r.created_dt, '%Y-%m-%dT%H:%i:%s') created_ts_iso, "+
						" date_format(r.org_reply_date,'%d/%m/%Y %h:%i:%s') org_reply_date, date_format(r.org_reply_date,'%Y-%m-%dT%H:%i:%s') org_reply_ts_iso, "+
						" date_format(r.verification_date,'%d/%m/%Y %h:%i:%s') verification_date, date_format(r.verification_date,'%Y-%m-%dT%H:%i:%s') verification_ts_iso, "+
						" r.rating, r.content, r.org_reply,  r.org_reply_by, r.moderation_score, "+
						" r.sentiment_score, r.nb_likes, r.nb_dislikes, r.is_pinned, case when COALESCE(r.is_signaled,'') = '' then 0 else 1 end is_signaled, r.is_verified, "+
						" c.name as author_owner_name, c.surname as author_owner_surname, c.avatar as author_owner_avatar "+
						" FROM client_reviews r, clients c "+
						" WHERE case when r.type = 'review' then r.is_verified else 1 end = 1 "+
						" and r.client_id=c.client_uuid and r.is_deleted=0 "+whereclause+" order by r.created_dt desc ";
            qry += limitApply;

            Set rs = Etn.executeWithCount(qry);
			int nbRes = Etn.UpdateCount;
			
			obj.put("total_records",nbRes);
			obj.put("page_no",(pageno+1));
			obj.put("page_size",pagesize);
            while (rs.next())
			{
                JSONObject respObj = new JSONObject();
                JSONObject author = new JSONObject();
				respObj.put("author", author);
                for (String column : rs.ColName) 
				{
					if(column.toLowerCase().startsWith("author_"))
					{
						author.put(column.toLowerCase().substring("author_".length()), rs.value(column));
					}
					else if(column.toLowerCase().equals("post_id"))
					{
						respObj.put(column.toLowerCase(), rs.value(column));
						if(loadAll){
							respObj.put("replies", commentReplies(Etn,client,rs.value(column)));
						}
					}	
					else
					{
						respObj.put(column.toLowerCase(), rs.value(column));
					}
                }
				
				if((respObj.optString("post_id","")).length() > 0)
				{
					Set rsF = Etn.execute("select count(0) as c from client_reviews where post_parent_id = "+escape.cote(respObj.getString("post_id")));
					rsF.next();
					respObj.put("no_of_replies", rsF.value(0));
					
					if(client!=null)
					{
						String clientId=client.getProperty("client_uuid");
						Set rsLiked = Etn.execute("SELECT is_like FROM client_review_reactions WHERE post_id="+escape.cote(respObj.optString("post_id",""))+" AND client_id="+escape.cote(clientId));
						if(rsLiked.next())
						{
							String clientReaction = "disliked";
							if(PortalHelper.parseNull(rsLiked.value("is_like")).equals("1")) clientReaction = "liked";
							respObj.put("client_reaction", clientReaction);
						}
					}
				}
				if(loadAll)
				{
					int totalReplies = 0;
					if(respObj.has("replies"))
					{					
						for(int j=0;j<respObj.getJSONArray("replies").length();j++)
						{
							totalReplies = totalReplies + respObj.getJSONArray("replies").getJSONObject(j).getInt("total_replies");
						}
					}
					respObj.put("total_replies", totalReplies);
				}
                respArray.add(respObj);
            }
            obj.put("data",respArray);
            message="Data fetched successfully.";
        }
        else 
		{
            message="You must provided either source_id and source_type or post_id";
            status = 10;
        }
    }
	catch (Exception e){
        message="Some  error occured while getting data.";
        status=2;
    }





    obj.put("msg",message);
    obj.put("status", status);

    out.write(obj.toString());
%>