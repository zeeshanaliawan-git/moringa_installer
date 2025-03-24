<%!
	org.json.JSONObject markLiked(com.etn.beans.Contexte Etn, com.etn.asimina.beans.Client client, String sourceId, String sourceType) throws Exception
	{
		return likeDislike(Etn, client, sourceId, sourceType, true);
	}
	
	org.json.JSONObject markDisliked(com.etn.beans.Contexte Etn, com.etn.asimina.beans.Client client, String sourceId, String sourceType) throws Exception
	{
		return likeDislike(Etn, client, sourceId, sourceType, false);
	}
	
	void doUndo(com.etn.beans.Contexte Etn,String clientId, String sourceId, String sourceType,String strIsLike){
		String query="select * from client_reactions where source_id="+com.etn.sql.escape.cote(sourceId)+
			" and source_type="+com.etn.sql.escape.cote(sourceType)+" and client_id="+com.etn.sql.escape.cote(clientId)+" and is_like="+com.etn.sql.escape.cote(strIsLike);
		
		com.etn.lang.ResultSet.Set rs2=Etn.execute(query);
		
		if(rs2.rs.Rows>0){
			Etn.executeCmd("delete from client_reactions where source_id="+com.etn.sql.escape.cote(sourceId)+
				" and source_type="+com.etn.sql.escape.cote(sourceType)+" and client_id="+com.etn.sql.escape.cote(clientId)+" and is_like="+com.etn.sql.escape.cote(strIsLike));
		}else{
			Etn.executeCmd("INSERT INTO client_reactions (source_id,source_type,client_id,is_like) VALUES ("+com.etn.sql.escape.cote(sourceId)+","+com.etn.sql.escape.cote(sourceType)+","+com.etn.sql.escape.cote(clientId)+","+com.etn.sql.escape.cote(strIsLike)+") ON DUPLICATE KEY UPDATE is_like="+com.etn.sql.escape.cote(strIsLike));
		}

		if(sourceType.equals("forum"))
		{
			//for forum we have no source id ... its always null ... for forum the main record has the post_id to be matched and we update its likes/dislikes
			//for pages/products there is no row in client_reviews .. they can only have their associated comments in the client_reviews table
			rs2 = Etn.execute("select coalesce(sum(case is_like when 1 then 1 else 0 end),0) as likes , coalesce(sum(case is_like when 0 then 1 else 0 end),0) as dislikes from client_reactions where source_id="+com.etn.sql.escape.cote(sourceId)+ " and source_type="+com.etn.sql.escape.cote(sourceType));
			if(rs2.next())
			{
				Etn.executeCmd("update client_reviews set nb_likes ="+com.etn.sql.escape.cote(rs2.value("likes")) + ", nb_dislikes = "+com.etn.sql.escape.cote(rs2.value("dislikes")) +" where post_id="+com.etn.sql.escape.cote(sourceId)+ " and `type` ="+com.etn.sql.escape.cote(sourceType));
			}
		}
	}

	org.json.JSONObject likeDislike(com.etn.beans.Contexte Etn, com.etn.asimina.beans.Client client, String sourceId, String sourceType, boolean isLike) throws Exception
	{
		String message="";
		int status=0;
		JSONObject obj = new JSONObject();

		if(client!=null){
			try{
				if(sourceId.length() > 0 && sourceType.length() > 0){
					boolean isOk = true;
					if(sourceType.equals("page"))
					{
						com.etn.lang.ResultSet.Set rs = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("PAGES_DB")+".pages where uuid = "+com.etn.sql.escape.cote(sourceId));
						if(rs.rs.Rows == 0)
						{
							status = 20;
							message = "Invalid page id provided";
							isOk = false;
						}
					}
					else if(sourceType.equals("product"))
					{
						com.etn.lang.ResultSet.Set rs = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".products where product_uuid = "+com.etn.sql.escape.cote(sourceId));
						if(rs.rs.Rows == 0)
						{
							status = 20;
							message = "Invalid product id provided";
							isOk = false;
						}						
					}
					else if(sourceType.equals("forum"))
					{
						com.etn.lang.ResultSet.Set rs = Etn.execute("select * from client_reviews where `type` = 'forum' and post_id = "+com.etn.sql.escape.cote(sourceId));
						if(rs.rs.Rows == 0)
						{
							status = 20;
							message = "Invalid forum id provided";
							isOk = false;
						}						
					}
					if(isOk)
					{
						JSONObject data = new JSONObject();

						String clientId=client.getProperty("client_uuid");
						
						String strIsLike = "0";
						if(isLike) {
							strIsLike = "1";
							doUndo(Etn,clientId, sourceId, sourceType, strIsLike);
						}else{
							doUndo(Etn,clientId, sourceId, sourceType, strIsLike);
						}
						
						com.etn.lang.ResultSet.Set rs = Etn.execute("SELECT coalesce(sum(case is_like when 1 then 1 else 0 end),0) as likes ,coalesce(sum(case is_like when 0 then 1 else 0 end),0) as dislikes FROM client_reactions WHERE source_type="+com.etn.sql.escape.cote(sourceType)+" AND source_id="+com.etn.sql.escape.cote(sourceId));
						rs.next();

						data.put("source_id",sourceId);
						data.put("source_type",sourceType);
						data.put("total_likes",rs.value("likes"));
						data.put("total_dislikes",rs.value("dislikes"));

						obj.put("data", data);

						message="Action performed successfully";
					}
				}else{
					message="Required fields are missing";
					status = 10;
				}
			}catch (Exception e){
				message="Error performing action";
				status=2;
			}
		}else{
			message="User not logged in";
			status=100;
		}

		obj.put("msg",message);
		obj.put("status", status);
		return obj;
	}
	
	org.json.JSONObject markFavorite(com.etn.beans.Contexte Etn, com.etn.asimina.beans.Client client, String sourceId, String sourceType) throws Exception
	{
		return favoriteUnfavorite(Etn, client, sourceId, sourceType, true);
	}
	
	org.json.JSONObject markUnfavorite(com.etn.beans.Contexte Etn, com.etn.asimina.beans.Client client, String sourceId, String sourceType) throws Exception
	{
		return favoriteUnfavorite(Etn, client, sourceId, sourceType, false);
	}
	
	org.json.JSONObject favoriteUnfavorite(com.etn.beans.Contexte Etn, com.etn.asimina.beans.Client client, String sourceId, String sourceType, boolean isFavorite) throws Exception
	{
		String message="";
		int status=0;
		JSONObject obj = new JSONObject();

		if(client!=null){
			try{

				if(sourceId.length() > 0 && sourceType.length() > 0){
					boolean isOk = true;
					if(sourceType.equals("page"))
					{
						com.etn.lang.ResultSet.Set rs = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("PAGES_DB")+".pages where uuid = "+com.etn.sql.escape.cote(sourceId));
						if(rs.rs.Rows == 0)
						{
							status = 20;
							message = "Invalid page id provided";
							isOk = false;
						}
					}
					else if(sourceType.equals("product"))
					{
						com.etn.lang.ResultSet.Set rs = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".products where product_uuid = "+com.etn.sql.escape.cote(sourceId));
						if(rs.rs.Rows == 0)
						{
							status = 20;
							message = "Invalid product id provided";
							isOk = false;
						}						
					}
					else if(sourceType.equals("forum"))
					{
						com.etn.lang.ResultSet.Set rs = Etn.execute("select * from client_reviews where `type` = 'forum' and post_id = "+com.etn.sql.escape.cote(sourceId));
						if(rs.rs.Rows == 0)
						{
							status = 20;
							message = "Invalid forum id provided";
							isOk = false;
						}						
					}
					if(isOk)
					{
						JSONObject data = new JSONObject();

						String clientId=client.getProperty("client_uuid");

						if(isFavorite) {
							Etn.executeCmd("INSERT INTO client_favorites (source_id,source_type,client_id) VALUES ("+com.etn.sql.escape.cote(sourceId)+","+com.etn.sql.escape.cote(sourceType)+","+com.etn.sql.escape.cote(clientId)+")");
						} else {
							Etn.executeCmd("DELETE FROM client_favorites WHERE client_id="+com.etn.sql.escape.cote(clientId)+" AND source_type="+com.etn.sql.escape.cote(sourceType)+" AND source_id="+com.etn.sql.escape.cote(sourceId));
						}
						
						com.etn.lang.ResultSet.Set rs = Etn.execute("SELECT count(0) as favourites FROM client_favorites WHERE source_type="+com.etn.sql.escape.cote(sourceType)+" AND source_id="+com.etn.sql.escape.cote(sourceId));
						rs.next();

						data.put("source_id",sourceId);
						data.put("source_type",sourceType);
						data.put("total_favourites", rs.value("favourites"));
						obj.put("data", data);

						//fetch total number of favorite pages
						com.etn.lang.ResultSet.Set rsF = Etn.execute("Select count(0) as cnt from client_favorites where client_id = "+com.etn.sql.escape.cote(clientId));
						rsF.next();
						data.put("client_total_favourites" , rsF.value("cnt"));

						message="Action performed successfully";
					}
				}else{
					message="Required fields are missing";
					status = 10;
				}
			}catch (Exception e){
				message="Error performing action";
				status=2;
			}
		}else{
			message="User not logged in";
			status=100;
		}

		obj.put("msg",message);
		obj.put("status", status);

		return obj;
	}
	
%>