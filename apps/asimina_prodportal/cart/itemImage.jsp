<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="image/png; charset=utf-8" pageEncoding="utf-8"%>
<%request.setCharacterEncoding("utf-8");response.setCharacterEncoding("utf-8");%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape, java.util.*, org.json.*"%>
<%@ page import="java.io.*"%>
<%!

	String parseNull(Object o) 
	{
		if( o == null )
			return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase()))
			return("");
		else
			return(s.trim());
	}


%>

<%
    String id = parseNull(request.getParameter("id"));
    String parent_id = parseNull(request.getParameter("parent_id"));
    
    Set rsOrderItems = Etn.execute("select product_snapshot from "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".order_items where id="+escape.cote(id)+" and parent_id="+escape.cote(parent_id));
    if(rsOrderItems.next())
	{
        JSONObject productSnapshot = new JSONObject(rsOrderItems.value("product_snapshot"));
		//previously we were saving variant image as base64 in the database so we keep this condition
		//in new approach we are not saving base64 variant image in db as it was making db heavy
        String base64Image = productSnapshot.optString("variantImage","");
		if(base64Image.length() == 0)
		{
			String imagePath = productSnapshot.optString("original_image_path","");
			if(imagePath.length() > 0)//new approach were we do not keep base64 image in db but we copy that to shop variant images directory
			{
				base64Image = com.etn.asimina.util.PortalHelper.getBase64Image(imagePath);				
			}
		}
		String patternString = "data:(image\\/[^;]*);base64,?";
		java.util.regex.Pattern pattern = java.util.regex.Pattern.compile(patternString);
		java.util.regex.Matcher matcher = pattern.matcher(base64Image);       
		if(base64Image.length()>0&&matcher.find())
		{
			//System.out.println(base64Image.replaceFirst(matcher.group(0),""));
			byte[] b = com.etn.util.Base64.decode(base64Image.replaceFirst(matcher.group(0),""));
			OutputStream o = response.getOutputStream();
			o.write(b);
			o.flush();
			o.close();
		}
    }
    
        
%>