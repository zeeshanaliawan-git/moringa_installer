<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>

<%
	request.setCharacterEncoding("utf-8");
	response.setCharacterEncoding("utf-8");
%>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.util.Logger"%>
<%@ page import="java.util.LinkedHashMap,org.json.*,java.util.Enumeration,javax.servlet.ServletException, com.etn.beans.app.GlobalParm,javax.servlet.http.*, org.apache.poi.ss.formula.functions.Column"%>
<%@ page import="com.etn.asimina.data.LanguageFactory, com.etn.asimina.util.ActivityLog"%>
<%@ page import="java.util.List,java.util.Map,java.util.ArrayList,com.etn.util.ItsDate" %>
<%@ page import="com.etn.asimina.beans.Language"%>


<%@ include file="../../common2.jsp" %>

<%!
    Boolean gameExists(com.etn.beans.Contexte etn,String gameName)
    {   
        Set rs = etn.execute("SELECT * FROM games_unpublished WHERE NAME = "+escape.cote(gameName));
        if(rs != null && rs.rs.Rows > 0)
            return true;
        return false;
    }

    boolean cartRuleExists(com.etn.beans.Contexte etn,String prizeId,String gameId, String cart_rule_id)
    {
        Set rs = etn.execute("SELECT * FROM game_prize_unpublished WHERE cart_rule_id="+escape.cote(cart_rule_id)+" AND game_uuid="+escape.cote(gameId));
        if(rs != null && rs.rs.Rows > 0)
            return true;
        return false;
    }


	void insertGamePrize(com.etn.beans.Contexte etn, String gameId, String cartRuleId,String prize,String quantity,String type, String siteId)
	{
		if(quantity.length() == 0) quantity = "1";
		if("prize".equalsIgnoreCase(type)) cartRuleId = "";
		else quantity = "1";
		if(Integer.parseInt(quantity) == 0) quantity = "1";
		etn.executeCmd("INSERT INTO game_prize_unpublished (id, game_uuid, cart_rule_id, prize, quantity, type, created_by) "+
				" VALUES ( uuid()," + escape.cote(gameId) + ", "+escape.cote(cartRuleId)+", "+escape.cote(prize)+", "+escape.cote(quantity)+", "+escape.cote(type)+"," + escape.cote(etn.getId()+"") + ") ");
	}

    int existGameCartRule(com.etn.beans.Contexte etn, String id, String gameId)
    {
        Set rs = etn.execute( "SELECT COUNT(*) as count FROM game_prize_unpublished WHERE game_uuid = " + escape.cote(gameId)+" AND id="+escape.cote(id));
        rs.next();
        return Integer.parseInt(rs.value("count"));
    }

    void updateGamePrize(com.etn.beans.Contexte etn,String id,String cartRuleId,String prize,String quantity,String type )
    {
        System.out.println("updateGamePrize::id ::"+id+"::::cartRuleId ::"+cartRuleId+"::prize::"+prize+":::quantity ::"+quantity);
        if(type.equals("Coupon"))
            etn.executeCmd("UPDATE game_prize_unpublished SET cart_rule_id="+escape.cote(cartRuleId)+", prize="+escape.cote(prize)+", type="+escape.cote("Coupon")+", updated_on=NOW(), quantity=1 , updated_by="+escape.cote(""+etn.getId())+" WHERE id="+escape.cote(id));
        else
            etn.executeCmd("UPDATE game_prize_unpublished SET cart_rule_id=NULL , prize="+escape.cote(prize)+", type="+escape.cote("Prize")+", updated_on=NOW(), quantity="+escape.cote(quantity)+" , updated_by="+escape.cote(""+etn.getId())+" WHERE id="+escape.cote(id));
    }

    boolean updateGame(String siteId, String gameId, String multiple_times, String win_type,String can_lose ,String deletedPrize, javax.servlet.http.HttpServletRequest request, com.etn.beans.Contexte etn, String play_game_column) throws JSONException
    {
        String launch_date = parseNull(request.getParameter("launch_date"));
        String end_date = parseNull(request.getParameter("end_date"));
        boolean flag=false;

        System.out.println("inside updating game");

        String [] prizeIds = request.getParameterValues("prize-id");  
        String [] cart_types = request.getParameterValues("cart_type");
        String [] coupons = request.getParameterValues("coupons");
        String [] others = request.getParameterValues("others");
        String [] quantities = request.getParameterValues("quantity");

        System.out.println("before setting date");
        String z1 = null, z2 = null;
        if(launch_date.length()>0){
            long l1 = ItsDate.getDate(launch_date);
            z1 = ItsDate.stamp(l1);
        }
        if(end_date.length()>0){
            long l2 = ItsDate.getDate(end_date);
            z2 = ItsDate.stamp(l2);
        }

        System.out.println("after setting date");

        
        List<String> deletedPrizeIds = null;
        if(deletedPrize.split(",").length > 0){
            deletedPrizeIds = new ArrayList<>(Arrays.asList(deletedPrize.split(",")));
            for(String prizeId: deletedPrizeIds)
            {
                if(gamePrizesExists(etn,prizeId,gameId))
                    gamePrizeDelete(etn,prizeId, gameId);
            }
        }
        
        etn.executeCmd("UPDATE games_unpublished SET play_game_column = "+escape.cote(play_game_column)+", attempts_per_user="+escape.cote(multiple_times)+", win_type="+escape.cote(win_type)+", updated_on=NOW(), updated_by="+escape.cote(""+etn.getId())+", version= version + 1, launch_date="+escape.cote(z1)+", end_date="+escape.cote(z2)+", can_lose="+escape.cote(can_lose)+" WHERE id="+escape.cote(gameId));

        if(cart_types!=null){
            for(int i=0;i<cart_types.length;i++){
            
                if(deletedPrizeIds!=null && prizeIds[i].length()>0){
                    if(deletedPrizeIds.contains(prizeIds[i])) continue;
                }

                if(cart_types[i].length()>0){
                    Boolean isAllow= !cartRuleExists(etn,prizeIds[i],gameId,coupons[i]);
                    if(cart_types[i].equalsIgnoreCase("prize")) isAllow=true;

                    System.out.println("cart_types"+cart_types[i]);
                    if(parseNull(prizeIds[i]).length()>0 && isAllow)
                    {       
                        updateGamePrize(etn,parseNull(prizeIds[i]),parseNull(coupons[i]),parseNull(others[i]),parseNull(quantities[i]),parseNull(cart_types[i]));
                    }
                    else if(isAllow)
                    {
                        insertGamePrize(etn,parseNull(gameId),parseNull(coupons[i]),parseNull(others[i]),parseNull(quantities[i]),parseNull(cart_types[i]),parseNull(siteId));
                    }
                    flag=true;
                }
            }
        }

        return flag;
    }

    Boolean gamePrizesExists(com.etn.beans.Contexte etn,String Id, String gameId)
    {   
        Set rs = etn.execute("SELECT * FROM game_prize_unpublished WHERE game_uuid="+escape.cote(gameId)+" AND id = "+escape.cote(Id));
        if(rs != null && rs.rs.Rows > 0)
            return true;
        return false;
    }

    void gamePrizeDelete(com.etn.beans.Contexte etn,String Id, String gameId)
    {
        etn.execute("DELETE FROM game_prize_unpublished WHERE game_uuid="+escape.cote(gameId)+" AND id=" + escape.cote(Id));
    }

%>

<%
    JSONObject result = new JSONObject();

    String gameId = parseNull(request.getParameter("game_id"));
    String gameName = parseNull(request.getParameter("game_name"));
    String attempts_per_user = parseNull(request.getParameter("multiple_times"));
    String canLose = parseNull(request.getParameter("can_lose"));
    String win_type = parseNull(request.getParameter("win_type"));
    String deletedPrize = request.getParameter("deleted_prizes");
    String play_game_column = request.getParameter("play_game_column");
    String siteId = getSelectedSiteId(session);

    String err_code = "";
    String msg="";
    String err_description = "";
    int status = 0;
    String query = "";

    

	Logger.debug("editGame.jsp","attempts_per_user=" + attempts_per_user);
	Logger.debug("editGame.jsp","deleted_prizes=" + deletedPrize);
	Logger.debug("editGame.jsp","gameName=" + gameName);
	Logger.debug("editGame.jsp","win_type=" + win_type);
	Logger.debug("editGame.jsp","play_game_column=" + play_game_column);


	

    if(!win_type.equals("Draw") && !win_type.equals("Instant")){
		
        err_code = "invalid_win_type";
        if(win_type.length() > 0)
            err_description = "Win type is invalid";
        else
            err_description = "Win type is not selected";
        status = 10;
    }

    if(!(Integer.parseInt(attempts_per_user) >= 0)){
        err_code = "invalid_times_play";
        err_description = "times play cannot be negative";
        status = 10;
    }

	if(status == 0){
        System.out.println("inside of updation");
        if(gameId.length()>0){
            System.out.println("updating game");
            if(updateGame(siteId, gameId, attempts_per_user, win_type, canLose ,deletedPrize ,request, Etn, play_game_column))
            {
                msg="Updated Successfully";

            }else{
                err_code="error_in_updation";
                err_description="Error occurred during updation";
            }
        }
	}

    if(status != 0)
    {
        result.put("err_code",err_code);
        result.put("err_description",err_description);
        result.put("status",status);
    }
	else{
		result.put("msg",msg);
        result.put("status",status);		
	}
	out.write(result.toString());
%>