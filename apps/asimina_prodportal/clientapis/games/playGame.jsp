<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>


<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape,com.etn.beans.app.GlobalParm,com.etn.asimina.util.PortalHelper"%>
<%@ page import="org.json.*, java.util.*,java.sql.Timestamp"%>
<%@ include file="common.jsp"%>

<%

	String gameId = PortalHelper.parseNull(request.getParameter("id"));
    String queryParm = PortalHelper.parseNull(request.getParameter("q"));

	try{
        
        String portalDb=GlobalParm.getParm("PROD_PORTAL_DB");
        String formsDb=GlobalParm.getParm("FORMS_DB");
        String catalogDb=GlobalParm.getParm("PROD_CATALOG_DB");

		if(gameId.length() == 0)
		{
			out.write(errorResponse("game_id_missing","critical","Game id is required","","","","",0));
			return;		
		}

		Set rs = Etn.execute("select g.id,case when COALESCE(g.launch_date,'') = '' then '' else "+
            "date_format(COALESCE(g.launch_date,'0000-00-00 00:00:00'),'%Y/%m/%dT%H:%i:%s') end as 'launch_date'"+
            ",case when COALESCE(g.end_date,'') = '' then '' else "+
            "date_format(COALESCE(g.end_date,'9999-00-00 00:00:00'), '%Y/%m/%dT%H:%i:%s') end as 'end_date'"+
            ",g.name,g.play_game_column,g.form_id,g.can_lose,g.attempts_per_user,g.win_type,g.site_id,pf.table_name "+
			"from "+formsDb+".games g left join "+formsDb+".process_forms pf on pf.form_id=g.form_id where g.id="+escape.cote(gameId));
		if(rs!=null && rs.rs.Rows>0 && rs.next()){
            
            Set rsTimeCheck =Etn.execute("select * from "+formsDb+".games where (COALESCE(launch_date,'0000-00-00 00:00:00')<=now() or launch_date='0000-00-00 00:00:00')"+
				"and (COALESCE(end_date,'9999-00-00 00:00:00') >now() or end_date='0000-00-00 00:00:00') and id="+escape.cote(gameId));

			if(rsTimeCheck!=null && rsTimeCheck.rs.Rows>0 && rsTimeCheck.next()){

                String tableName = PortalHelper.parseNull(rs.value("table_name"));

                if(queryParm.length() == 0)
                {
                    out.write(errorResponse("search_value_missing","critical","Search value is required",PortalHelper.parseNull(rs.value("win_type")),PortalHelper.parseNull(rs.value("launch_date")),PortalHelper.parseNull(rs.value("end_date")),PortalHelper.parseNull(rs.value("attempts_per_user")),0));
                    return;		
                }
                else
                {
                    String identityType = PortalHelper.parseNull(rs.value("play_game_column"));
                    String identity=identityType;
                    String identityTypeValue=queryParm;

                    Set rsFieldLabel = Etn.execute("select pffd.label from "+formsDb+".process_form_fields pff left join "+formsDb+".process_form_field_descriptions pffd on "+
                        " pff.field_id=pffd.field_id where pff.form_id="+escape.cote(PortalHelper.parseNull(rs.value("form_id")))+
                        " and pff.db_column_name="+escape.cote(identityType));
                    if(rsFieldLabel.next()){
                        identity = PortalHelper.parseNull(rsFieldLabel.value("label"));
                    }
                    
                    String canLose = PortalHelper.parseNull(rs.value("can_lose"));

                    Set rs2=Etn.execute("select _etn_game_status as 'status',"+tableName+"_id as 'id' from "+formsDb+"."+tableName+
                        " where "+identityType+"="+escape.cote(identityTypeValue)+" and _etn_game_status = 'start' order by id desc Limit 1");
                    if(rs2!=null &&rs2.rs.Rows>0 && rs2.next())
                    {

                        Etn.executeCmd("delete from "+formsDb+"."+tableName+" where "+identityType+"="+escape.cote(identityTypeValue)+" and "+tableName+"_id !="+
						escape.cote(rs2.value("id"))+" and COALESCE(_etn_game_status,'') != 'end'");

                        String finalPrize="";
                        String name="";
                        String voucherCode="";
                        String prizes="";
                        String coupons="";
                        String winStatus = "lose"; 
                        String gameStatus=PortalHelper.parseNull(rs2.value("status"));
                        String[] gameOutCome={"lose","win"};
                        String tempId="";
                        String couponPrizeName="";

                        if(canLose.equalsIgnoreCase("0")){
                            winStatus = gameOutCome[1];
                        }else if(canLose.equalsIgnoreCase("1")){
                            winStatus = gameOutCome[getRandomNumber(101,2)];
                        }
                        String query="";
                        if(winStatus.equalsIgnoreCase("win")){

                            Set rs3=Etn.execute("Select id,type,cart_rule_id,prize,COALESCE(quantity,0) as quantity from "+formsDb+
                                ".game_prize where game_uuid="+escape.cote(gameId));
                            if(rs3!=null)
                            {
                                while(rs3.next())
                                {
                                    if(PortalHelper.parseNull(rs3.value("type")).equalsIgnoreCase("coupon"))
                                    {
                                        if(PortalHelper.parseNull(rs3.value("prize")).length()>0){
                                           couponPrizeName=rs3.value("prize");
                                        }else{
                                            Set rs6 = Etn.execute("select name from "+catalogDb+".cart_promotion where id="+escape.cote(rs3.value("cart_rule_id")));
                                            if(rs6!=null && rs6.rs.Rows>0 && rs6.next()){
                                               couponPrizeName=rs6.value("name");
                                            }
                                        }

                                        Set rs4=Etn.execute("select coupon_code from "+catalogDb+".cart_promotion_coupon where cp_id="+
                                        escape.cote(rs3.value("cart_rule_id"))+" and coupon_code not in (select COALESCE(_etn_coupons,'') from "+formsDb+"."+tableName+")");
                                        while(rs4.next())
                                        {
                                            if(coupons.length()>0){
                                                coupons+=",coupn&"+PortalHelper.parseNull(rs4.value("coupon_code"))+"&"+PortalHelper.parseNull(rs3.value("id"))
                                                +"&"+couponPrizeName;
                                            }else{
                                                coupons="coupn&"+PortalHelper.parseNull(rs4.value("coupon_code"))+"&"+PortalHelper.parseNull(rs3.value("id"))
                                                +"&"+couponPrizeName;
                                            }
                                        }
                                        
                                    }
                                    else
                                    {
                                        int quantity = Integer.parseInt(PortalHelper.parseNull(rs3.value("quantity")));
                                        while(quantity>0){
                                            if(prizes.length()>0){
                                                prizes+=",prize&"+PortalHelper.parseNull(rs3.value("prize"))+"&"+PortalHelper.parseNull(rs3.value("id"));
                                            }else{
                                                prizes="prize&"+PortalHelper.parseNull(rs3.value("prize"))+"&"+PortalHelper.parseNull(rs3.value("id"));
                                            }
                                            quantity--;
                                        }
                                    }
                                }
                                String allPrizes = prizes;
                                if(allPrizes.length()>0){
                                    if(coupons.length()>0){
                                        allPrizes += ","+coupons;
                                    }
                                }else{
                                    allPrizes = coupons;
                                }

                                if(allPrizes.length()>0){

                                    List<String> prizeArray = Arrays.asList(allPrizes.split(","));
                                    Collections.shuffle(prizeArray);

                                    finalPrize = prizeArray.get(getRandomNumber(101*prizeArray.size(),prizeArray.size()));
                                    List<String> tempArray = Arrays.asList(finalPrize.split("&"));
                                    if(tempArray.get(0).equalsIgnoreCase("prize")){
                                        query+=",_etn_prize_id="+escape.cote(tempArray.get(2))+",_etn_prize="+escape.cote(tempArray.get(1));
                                        name=tempArray.get(1);
                                    }else{
                                        query+=",_etn_prize_id="+escape.cote(tempArray.get(2))+", _etn_coupons="+escape.cote(tempArray.get(1))
                                        +",_etn_prize="+escape.cote(tempArray.get(3));
                                        voucherCode=tempArray.get(1);
                                        couponPrizeName=tempArray.get(3);
                                    }
                                    tempId=tempArray.get(2);
                                }else{
                                    winStatus="lose";
                                }
                            }else{
                                winStatus="lose";
                            }
                        }
                        query="update "+formsDb+"."+tableName+" set _etn_game_status='end',updated_on=NOW(),_etn_win_status="+escape.cote(winStatus)+query;
                        query+=" where "+tableName+"_id="+rs2.value("id");
                        Etn.execute(query);
                        if(name.length()>0){
                            Etn.executeCmd("update "+formsDb+".game_prize set quantity=quantity-1 where id="+escape.cote(tempId));
                            out.write(successResponsePlayGame(gameId,name,tempId,voucherCode,winStatus));
                        }else{
                            out.write(successResponsePlayGame(gameId,couponPrizeName,tempId,voucherCode,winStatus));
                        }
						changeGamePhase(Etn, gameId, rs2.value("id"), tableName);
                        return;
                        
                    }else{
                        int count=0;
                        Set rsCount = Etn.execute("select * from "+formsDb+"."+tableName+" where "+identityType+"="+escape.cote(identityTypeValue)+
                        " and _etn_game_status = 'end'");
                        if(rsCount!=null && rsCount.rs.Rows>0 && rsCount.next()){
                            count=rsCount.rs.Rows;
                        }
                        out.write(errorResponse("invalid_"+identity.toLowerCase().replace(" ","_"),"critical",identity+" is invalid.",PortalHelper.parseNull(rs.value("win_type")),PortalHelper.parseNull(rs.value("launch_date")),PortalHelper.parseNull(rs.value("end_date")),PortalHelper.parseNull(rs.value("attempts_per_user")),count));
                        return;
                    }
                }
            }else{
				out.write(errorResponse("game_date_error","critical","Game is either expired or not launched","","","","",0));
				return;
			}
			
        }
        else
        {
            out.write(errorResponse("invalid_gameid","critical","Game id is invalid","","","","",0));
            return;		
        }
        

	}
    catch(Exception e){
        e.printStackTrace();
		out.write(errorResponse("exception","critical","An exception occured while processing.","","","","",0));
		return;
	}
%>