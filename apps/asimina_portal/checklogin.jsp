<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.util.Base64, javax.servlet.http.Cookie, com.etn.beans.app.GlobalParm, org.json.*"%>
<%@ include file="clientcommon.jsp"%>
<%@ include file="getuserhomepage.jsp"%>

<%!
	String parseNull(Object o) 
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}
%>
<%
	response.setHeader("X-Frame-Options","deny");
	
	String muid = parseNull(request.getParameter("muid"));
	
	org.json.JSONObject json = verifyUserAuth(Etn, request, response, muid);

	if(json.optString("login").equals("0"))
	{
		String token = java.util.UUID.randomUUID().toString();		
		com.etn.asimina.session.ClientSession.getInstance().addParameter(Etn, request, response, "logintoken", token);	
		json.put("token", token);		
	}
	
	//not checking if logged-in user is of same site because we are not supporting this for the time-being
	//com.etn.asimina.beans.Client client = com.etn.asimina.session.ClientSession.getInstance().getLoggedInClient(Etn, request, muid);
	com.etn.asimina.beans.Client client = com.etn.asimina.session.ClientSession.getInstance().getLoggedInClient(Etn, request);
	
	String homepage = "";
	
	if(client != null) 
	{
		String langId = "1";
		String lang = "";
		Set rsL = Etn.execute("select l.langue_id, l.langue_code from site_menus m join language l on l.langue_code = m.lang where m.menu_uuid  = " + escape.cote(muid));
		if(rsL.next())
		{
			langId = rsL.value("langue_id");
			lang = rsL.value("langue_code");
		}
		//System.out.println("langId::"+langId);
		
		String profilId = client.getProperty("client_profil_id");
		homepage = getHomePage(Etn,profilId,parseNull(json.optString("mlang")));	
				
		//fetch total number of favorite pages
		Set rsF = Etn.execute("Select distinct coalesce(pg.name, pr.lang_"+langId+"_name, cforums.forum_topic) as name, cf.source_id, cc.published_url as url, cf.source_type, cforums.content "
						+ " from client_favorites cf "
						+ " left outer join "+GlobalParm.getParm("PAGES_DB")+".pages pg on pg.uuid = case when cf.source_type = 'page' then cf.source_id else '000' end "
						+ " left outer join "+GlobalParm.getParm("CATALOG_DB")+".products pr on pr.product_uuid = case when cf.source_type = 'product' then cf.source_id else '000' end "
						+ " left outer join cached_content_view cc on cc.content_type = cf.source_type and cc.lang = "+escape.cote(lang)+" and ( cc.content_id = pg.id or cc.content_id = pr.id ) "
						+ " left outer join client_reviews cforums on cforums.type = 'forum' and cforums.post_id = case when cf.source_type = 'forum' then cf.source_id else '000' end "						
						+ " where cf.client_id = "+escape.cote(client.getProperty("client_uuid")));
								
		try {
			JSONArray jFavorites = new JSONArray();
			while(rsF.next()) {
				JSONObject jFavorite = new JSONObject();
				jFavorite.put("id", rsF.value("source_id"));
				jFavorite.put("name", rsF.value("name"));
				jFavorite.put("url", rsF.value("url"));
				jFavorite.put("type", rsF.value("source_type"));
				if("forum".equalsIgnoreCase(rsF.value("source_type"))) jFavorite.put("content", parseNull(rsF.value("content")));
				jFavorites.put(jFavorite);
			}
			json.put("favourites" , jFavorites);
		} catch (Exception e) {}

		rsF = Etn.execute("Select distinct coalesce(pg.name, pr.lang_"+langId+"_name, cforums.forum_topic) as name, cr.source_id, cc.published_url as url, cr.is_like, cr.source_type  "
						+ " from client_reactions cr "
						+ " left outer join "+GlobalParm.getParm("PAGES_DB")+".pages pg on pg.uuid = case when cr.source_type = 'page' then cr.source_id else '000' end "
						+ " left outer join "+GlobalParm.getParm("CATALOG_DB")+".products pr on pr.product_uuid = case when cr.source_type = 'product' then cr.source_id else '000' end "
						+ " left outer join cached_content_view cc on cc.content_type = cr.source_type and cc.lang = "+escape.cote(lang)+" and ( cc.content_id = pg.id or cc.content_id = pr.id ) "
						+ " left outer join client_reviews cforums on cforums.type = 'forum' and cforums.post_id = case when cr.source_type = 'forum' then cr.source_id else '000' end "
						+ " where cr.client_id = "+escape.cote(client.getProperty("client_uuid")));

		try {
			JSONArray jPageReactions = new JSONArray();
			while(rsF.next()) {
				JSONObject jPageReaction = new JSONObject();
				jPageReaction.put("id", rsF.value("source_id"));
				jPageReaction.put("name", rsF.value("name"));
				jPageReaction.put("url", rsF.value("url"));
				jPageReaction.put("type", rsF.value("source_type"));
				if(rsF.value("is_like").equals("1")) jPageReaction.put("reaction", "liked");
				else jPageReaction.put("reaction", "disliked");
				jPageReactions.put(jPageReaction);
			}
			json.put("reactions" , jPageReactions);
		} catch (Exception e) {}
	}	
	json.put("homepage", homepage);	
	
	out.write(json.toString());
%>
