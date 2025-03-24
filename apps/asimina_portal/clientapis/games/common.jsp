<%!
	boolean changeGamePhase(com.etn.beans.Contexte Etn, String gameid, String targetTableId, String targetTable)
	{		
		//System.out.println("*************************** in CHANGE order phase");
		Set rsG = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("FORMS_DB")+"."+targetTable+" where "+targetTable+"_id = "+escape.cote(targetTableId));
		rsG.next();
		
		String msg = "";
		String startphase = "";
		String nextphase = "";
		if("start".equals(rsG.value("_etn_game_status"))) 
		{
			startphase = "FormSubmitted";
			msg = "Game started";
			nextphase = "GameStarted";
		}
		else if("end".equals(rsG.value("_etn_game_status")))
		{
			startphase = "GameStarted";
			msg = "Game finished";
			nextphase = "GameFinished";
		}
		//System.out.println("update "+com.etn.beans.app.GlobalParm.getParm("FORMS_DB")+".post_work set status = 1, id = @curid := id, errCode = 0, errMessage = "+escape.cote(msg)+" where phase = "+escape.cote(startphase)+" and status = 0 and client_key = "+escape.cote(targetTableId));
		String qrys[] = new String[3];
		qrys[0] = "set @curid = 0";
		qrys[1] = "update "+com.etn.beans.app.GlobalParm.getParm("FORMS_DB")+".post_work set status = 1, id = @curid := id, errCode = 0, errMessage = "+escape.cote(msg)+" where phase = "+escape.cote(startphase)+" and status = 0 and client_key = "+escape.cote(targetTableId);
		qrys[2] = "select @curid as lastLineId ";
	
		Set rs = Etn.execute(qrys);
		int lastLineId = 0;
		if(rs.next() && rs.next() && rs.next()) lastLineId = Integer.parseInt(rs.value(0));
		boolean isError = false;
		int newId = 0;
		
		if(lastLineId == 0)
		{
			isError = true;
		}
	
		else
		{
			String insertPostWorkLineQry =  "insert into "+com.etn.beans.app.GlobalParm.getParm("FORMS_DB")+".post_work "+
			  "(proces, phase, priority, insertion_date, client_key, form_table_name ) "+
			  " select proces, "+escape.cote(nextphase)+", now(), now(),client_key,form_table_name "+
			  " from "+com.etn.beans.app.GlobalParm.getParm("FORMS_DB")+".post_work p where p.id = " + escape.cote(""+lastLineId);
			
			newId = Etn.executeCmd(insertPostWorkLineQry);
			
			if(newId > 0)
			{		
				String updatePostWorkLineQry = " update "+com.etn.beans.app.GlobalParm.getParm("FORMS_DB")+".post_work set status = 2, start = if(start is null,insertion_date, start), end = current_timestamp, nextId = "+escape.cote(""+newId)+", attempt=attempt+1 where id = " + lastLineId;
				int rowsUpdated = Etn.executeCmd(updatePostWorkLineQry);
				
				Etn.executeCmd(" Update "+com.etn.beans.app.GlobalParm.getParm("FORMS_DB")+"."+targetTable+" set lastid = "+escape.cote(""+lastLineId)+" where "+targetTable+"_id = "+escape.cote(targetTableId)+" ");

				Set rsConfig = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("FORMS_DB")+".config where code = 'SEMAPHORE'");
				rsConfig.next();
				Etn.execute("select semfree("+escape.cote(rsConfig.value("val"))+")");
			}
		}
		return isError;
		
	}

	String errorResponse(String code,String level,String message,String gameMode,String start,String end,String max,int count) throws Exception{
		
		org.json.JSONObject context = new org.json.JSONObject();
		org.json.JSONObject obj = new org.json.JSONObject();
		context.put("gameMode",gameMode);
		context.put("startTimestamp",start);
		context.put("endTimestamp",end);
		context.put("nowTimestamp",new Timestamp(System.currentTimeMillis()));
		context.put("maxGamePerUser",max);
		context.put("countGameForUser",count);

		obj.put("code",code);
		obj.put("level",level);
		obj.put("message",message);
		obj.put("context", context);
		return obj.toString();
	}
	String successResponsePlayGame(String gameId,String name,String prizeId,String voucherCode, String winStatus) throws Exception{
		
		org.json.JSONObject resp = new org.json.JSONObject();
		org.json.JSONObject prize = new org.json.JSONObject();

        prize.put("id",prizeId);
        prize.put("name",name);
        prize.put("description","");
        prize.put("voucherCode",voucherCode);

		resp.put("gameWheelId",gameId);
		resp.put("winStatus",winStatus);
		resp.put("prize",prize);

		return resp.toString();
	}

    int getRandomNumber(int max,int size) throws Exception {
        Random randomNum = new Random();
        return (1 + randomNum.nextInt(max))%size;
    }

	String successResponseStartGame(String gameId,String canLose,com.etn.beans.Contexte Etn,String state,String tableName) throws Exception {
		
		String formsDb=GlobalParm.getParm("FORMS_DB");
		String catalogDb=GlobalParm.getParm("PROD_CATALOG_DB");

		org.json.JSONObject resp = new org.json.JSONObject();
		JSONArray prizeArray = new JSONArray();

		Set rs =Etn.execute("select * from "+formsDb+".game_prize where game_uuid="+escape.cote(gameId));
		if(rs!=null && rs.rs.Rows>0){
			while(rs.next()){
				org.json.JSONObject prizeObj = new org.json.JSONObject();

				if(PortalHelper.parseNull(rs.value("type")).equalsIgnoreCase("coupon"))
				{
					Set rs2=Etn.execute("select * from "+catalogDb+".cart_promotion_coupon where cp_id="+escape.cote(rs.value("cart_rule_id"))+
						" and coupon_code not in (select COALESCE(_etn_coupons,'') from "+formsDb+"."+tableName+")");

					if(rs2.rs.Rows>0 && rs2.next())
					{
						prizeObj.put("id",rs.value("id"));
						if(PortalHelper.parseNull(rs.value("prize")).length()>0){
							prizeObj.put("name",rs.value("prize"));
						}else{
							Set rs3 = Etn.execute("select name from "+catalogDb+".cart_promotion where id="+escape.cote(rs.value("cart_rule_id")));
							if(rs3!=null && rs3.rs.Rows>0 && rs3.next()){
								prizeObj.put("name",rs3.value("name"));
							}else{
								prizeObj.put("name","");
							}
						}
						prizeArray.put(prizeObj);
					}
					
				}
				else
				{
					if(!PortalHelper.parseNull(rs.value("quantity")).equalsIgnoreCase("0")){
						prizeObj.put("id",rs.value("id"));
						prizeObj.put("name",rs.value("prize"));
						prizeArray.put(prizeObj);
					}
				}
				
			}

		}

		resp.put("id",gameId);
		resp.put("state",state);
		if(canLose.equals("1")){
			canLose="true";
		}else{
			canLose="false";
		}
		resp.put("canLose",canLose);
		resp.put("prizes",prizeArray);

		return resp.toString();
	}
	
%>