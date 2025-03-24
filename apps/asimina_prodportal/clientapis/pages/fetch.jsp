<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>


<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape,com.etn.beans.app.GlobalParm,com.etn.asimina.util.PortalHelper"%>
<%@ page import="org.json.*, java.util.*"%>

<%!
	JSONArray getPageComments(com.etn.beans.Contexte Etn,com.etn.asimina.beans.Client client, boolean loadAll, String sourceId, String limitApply) throws Exception
	{
		return getComments(Etn, client, loadAll, sourceId, limitApply, null);
	}
	
	JSONArray getComments(com.etn.beans.Contexte Etn,com.etn.asimina.beans.Client client, boolean loadAll, String sourceId, String limitApply, String parentCommentId) throws Exception
	{
		String qry = "SELECT r.post_id, r.source_id, r.source_type, r.post_parent_id, r.type, r.category,  "+
		" date_format(r.created_dt,'%d/%m/%Y %h:%i:%s') created_dt, date_format(r.created_dt, '%Y-%m-%dT%H:%i:%s') created_ts_iso, "+
		" date_format(r.org_reply_date,'%d/%m/%Y %h:%i:%s') org_reply_date, date_format(r.org_reply_date,'%Y-%m-%dT%H:%i:%s') org_reply_ts_iso, "+
		" date_format(r.verification_date,'%d/%m/%Y %h:%i:%s') verification_date, date_format(r.verification_date,'%Y-%m-%dT%H:%i:%s') verification_ts_iso, "+
		" r.rating, r.content, r.org_reply,  r.org_reply_by, r.moderation_score, "+
		" r.sentiment_score, r.nb_likes, r.nb_dislikes, r.is_pinned, case when COALESCE(r.is_signaled,'') = '' then 0 else 1 end is_signaled, r.is_verified, "+
		" c.name as author_owner_name, c.surname as author_owner_surname, c.avatar as author_owner_avatar "+
		" FROM client_reviews r, clients c "+
		" WHERE r.client_id=c.client_uuid and r.is_deleted=0 ";
		
		if(parentCommentId == null)	qry += " and r.source_type = 'page' and r.source_id="+escape.cote(sourceId)+" and COALESCE(r.post_parent_id,'') = ''";
		else qry += " and r.post_parent_id="+escape.cote(parentCommentId);
		
		qry += " order by r.created_dt desc ";
		
		if(limitApply != null) qry += limitApply;
		
		JSONArray jComments = new JSONArray();
		Set rsComments = Etn.execute(qry);

		while(rsComments.next()){
			JSONObject jComment = new JSONObject();
			JSONObject jCommentAuthor = new JSONObject();
			for(String CmntColName:rsComments.ColName){
				if(CmntColName.toLowerCase().equals("post_id"))
				{
					if(loadAll){

						JSONArray jReplies = getComments(Etn, client, loadAll, null, null, rsComments.value(CmntColName));
						jComment.put("replies", jReplies);
					}

					jComment.put(CmntColName.toLowerCase(),rsComments.value(CmntColName));
					if(client!=null)
					{
						String clientId=client.getProperty("client_uuid");
						Set rsLiked = Etn.execute("SELECT is_like FROM client_review_reactions WHERE post_id="+escape.cote(rsComments.value(CmntColName))+" AND client_id="+escape.cote(clientId));
						if(rsLiked.next())
						{
							String clientReaction = "disliked";
							if(PortalHelper.parseNull(rsLiked.value("is_like")).equals("1")) clientReaction = "liked";
							jComment.put("client_reaction", clientReaction);
						}
						else jComment.put("client_reaction", "");
					}
					else jComment.put("client_reaction", "");
				}								
				else if(CmntColName.toLowerCase().startsWith("author_"))
				{
					jCommentAuthor.put(CmntColName.toLowerCase().substring("author_".length()), rsComments.value(CmntColName));
				}								
				else jComment.put(CmntColName.toLowerCase(),rsComments.value(CmntColName));
			}
			jComment.put("author", jCommentAuthor);
			
			if(loadAll)
			{								
				int totalReplies = 0;
				if(jComment.has("replies"))
				{
					for(int j=0;j<jComment.getJSONArray("replies").length();j++)
					{
						totalReplies = totalReplies + jComment.getJSONArray("replies").getJSONObject(j).getInt("total_replies");
					}
				}
				jComment.put("total_replies", totalReplies);
			}
			
			jComments.put(jComment);
		}	
		return jComments;
	}
%>

<%
    String message="";
    int status=0;
    JSONObject obj = new JSONObject();

    com.etn.asimina.beans.Client client = com.etn.asimina.session.ClientSession.getInstance().getLoggedInClient(Etn, request);

    try{
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
		boolean loadAll = "1".equals(PortalHelper.parseNull(request.getParameter("loadAll")));
		
        String sourceId = PortalHelper.parseNull(request.getParameter("source_id"));
        String sourceType = "page";
        if(sourceId.length() > 0){
            JSONObject data = new JSONObject();

            Set rs=Etn.execute("SELECT coalesce(sum(case is_like when 1 then 1 else 0 end),0) as liked ,coalesce(sum(case is_like when 0 then 1 else 0 end),0) as disliked FROM client_reactions "+
					" WHERE source_type="+escape.cote(sourceType)+" AND source_id="+escape.cote(sourceId));
            rs.next();
            Set rs2=Etn.execute("SELECT count(0) as favourites FROM client_favorites WHERE source_type="+escape.cote(sourceType)+" AND source_id="+escape.cote(sourceId));
            rs2.next();

			data.put("source_id",sourceId);
			data.put("source_type",sourceType);
            data.put("likes",rs.value("liked"));
            data.put("dislikes",rs.value("disliked"));
            data.put("favourites",rs2.value("favourites"));

            if(client!=null){
                String clientId=client.getProperty("client_uuid");
                rs=Etn.execute("SELECT is_like FROM client_reactions WHERE client_id="+escape.cote(clientId)+" AND source_type="+escape.cote(sourceType)+" AND source_id="+escape.cote(sourceId));
                if(rs.next())
				{
					String clientReaction = "disliked";
					if(PortalHelper.parseNull(rs.value("is_like")).equals("1")) clientReaction = "liked";
					data.put("client_reaction", clientReaction);
				}

                rs2=Etn.execute("SELECT * FROM client_favorites WHERE client_id="+escape.cote(clientId)+" AND source_type="+escape.cote(sourceType)+" AND source_id="+escape.cote(sourceId));
                if(rs2.next())
				{
					data.put("client_favorite", true);
				} 
				else data.put("client_favorite", false);
            }
			
			data.put("comments", getPageComments(Etn, client, loadAll, sourceId, limitApply));
			
            obj.put("data", data);
            message="Data fetched successfully.";
        }else{
            message="Required fields are missing";
            status = 10;
        }
    }catch (Exception e){
        message="Error fetching data.";
        status=2;
    }

    obj.put("msg",message);
    obj.put("status", status);

    out.write(obj.toString());
%>