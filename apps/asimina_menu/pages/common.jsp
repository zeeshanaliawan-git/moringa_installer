<%@ page import="java.security.NoSuchAlgorithmException, java.security.MessageDigest, java.util.Map, java.util.List, java.io.UnsupportedEncodingException, com.etn.util.Logger"%>
<%! 
public final String semfree = "PORTAL";

public final String ORANGE = "#FF6600";

String ascii7( String  s )
{
	return com.etn.util.CommonHelper.removeAccents(s);
}

        boolean isNullOrEmpty(String str){
            return str == null || str.trim().length() == 0;
        }

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

	public int parseNullInt(String s)
	{
       	if (s == null) return 0;
	       if (s.equals("null")) return 0;
       	return Integer.parseInt(s);
	}

	public double parseNullDouble(String s)
	{
       	if (s == null) return 0;
	       if (s.equals("null")) return 0;
       	return Double.parseDouble(s);
	}

	String addSelectControl(String id, String name, Map<String,String> map, boolean isMultiSelect, int maxControlSize)
	{			
		int size = map.size();

		String html = "<select name='" + name + "' id='" + id + "' ";
		if(isMultiSelect) 
			html = html + " size='" + maxControlSize + "' MULTIPLE>";
		else
			html = html + " >";
				
		for(String key : map.keySet())
		{
			String val = map.get(key);
			html = html + "<option value='" + escapeCoteValue(key) + "'>"+escapeCoteValue(val)+"</option>";		
		}
		html = html + "</select>";
		return html;
	}


	String convertToHex(byte[] data) 
	{ 
        StringBuffer buf = new StringBuffer();
        for (int i = 0; i < data.length; i++) { 
            int halfbyte = (data[i] >>> 4) & 0x0F;
            int two_halfs = 0;
            do { 
                if ((0 <= halfbyte) && (halfbyte <= 9)) 
                    buf.append((char) ('0' + halfbyte));
                else 
                    buf.append((char) ('a' + (halfbyte - 10)));
                halfbyte = data[i] & 0x0F;
            } while(two_halfs++ < 1);
        } 
        return buf.toString();
    } 
 
    String MD5(String text) throws NoSuchAlgorithmException, UnsupportedEncodingException  
	{ 
        MessageDigest md;
        md = MessageDigest.getInstance("MD5");
        byte[] md5hash = new byte[32];
        md.update(text.getBytes("iso-8859-1"), 0, text.length());
        md5hash = md.digest();
        return convertToHex(md5hash);
    } 

	String getProcess(String ty)
	{
		String process = ty;
		if("menu".equalsIgnoreCase(ty)) process = "menus";
		else if("menuv2".equalsIgnoreCase(ty)) process = "menus";
		else if("breadcrumbs".equalsIgnoreCase(ty)) process = "breadcrumbs";
		return process;
	}

	boolean movephase(com.etn.beans.Contexte Etn, String clid, String process, String phase, String on)
	{
		boolean succ = false;
		String qrys[] = new String[3];
		qrys[0] = "set @curid = 0";
		qrys[1] = "update post_work set status = 1, id = @curid := id where status = 0 and client_key = "+com.etn.sql.escape.cote(clid)+" and proces = " +com.etn.sql.escape.cote(process);
		qrys[2] = "select @curid as lastLineId ";
		Set rs = Etn.execute(qrys);
		int lastLineId = 0;
		if(rs.next() && rs.next() && rs.next()) lastLineId = Integer.parseInt(rs.value(0));

		//check engine already started work
		if(lastLineId <= 0) 
		{
			Set rs3 = Etn.execute("select * from post_work where client_key = "+com.etn.sql.escape.cote(clid)+" and proces = " +com.etn.sql.escape.cote(process));
			//there are rows in post_work for this process and client_key so if lastLineId <= 0 means engine already started work
			if(rs3.rs.Rows > 0) return false;
		}

		String q = "insert into post_work (proces, phase, client_key, insertion_date, priority, operador) values (";
		q += com.etn.sql.escape.cote(process);
		q += "," + com.etn.sql.escape.cote(phase);
		q += "," + com.etn.sql.escape.cote(clid);
		q += ", now() ";
		if(on.equals("-1")) q += ", now() ";
		else q += ", " + com.etn.sql.escape.cote(on);
		q += "," + Etn.getId();
		q += " ) " ;
		int r = Etn.executeCmd(q);
		if(r > 0) 
		{
			succ = true;
			Etn.executeCmd("update post_work set status = 2, start = now(), end= now(), nextid = "+r+" where id = " + lastLineId);
		}
		else
		{
			Etn.executeCmd("update post_work set status = 0 where id = " + lastLineId);
		}
		return succ;
	}	

	String addSelectControl(String id, String name, Map<String,String> map, String selectedvalue, String cssclass, String scripts)
	{			
		int size = map.size();
	
		if(selectedvalue == null) selectedvalue = "";
		if(cssclass == null) cssclass = "";
		if(scripts == null) scripts= "";

	
		String html = "<select name='" + name + "' id='" + id + "' ";
		if(cssclass.length() > 0) 
			html += " class='"+cssclass+"' ";
		html += " " + scripts ;
		html += " >";
				
		for(String key : map.keySet())
		{
			String val = map.get(key);
			String selected = "";
			if(key.equalsIgnoreCase(selectedvalue)) selected = " selected ";			
			html += "<option "+selected+" value='" + escapeCoteValue(key) + "'>"+escapeCoteValue(val)+"</option>";	
		}
		html += "</select>";
		return html;
	}

    /***
    // primarily used for output inside value='' attribute
    // or any other attribute value of any tag/element
    // example :    <input type='text' value='escapeCoteValue( ... )' />
    */
    public String escapeCoteValue(String str){
		return com.etn.util.CommonHelper.escapeCoteValue(str);
	}

	String getSiteId(javax.servlet.http.HttpSession session)
	{
       	return parseNull(session.getAttribute("SELECTED_SITE_ID"));
	}

	/*List<com.etn.asimina.beans.Language> getLangs(com.etn.beans.Contexte Etn, String siteid)
	{
		return com.etn.asimina.util.SiteHelper.getSiteLangs(Etn,siteid);
	}

	List<com.etn.asimina.beans.Language> getLangs(com.etn.beans.Contexte Etn, javax.servlet.http.HttpSession session)
	{
		return getLangs(Etn,getSelectedSiteId(session));
	}*/

	boolean isEcommerceEnabled(com.etn.beans.Contexte Etn, String siteid)
	{
		boolean isEnabled = false;
		com.etn.lang.ResultSet.Set rs = Etn.execute("select * from sites where id = " +com.etn.sql.escape.cote(siteid) );
		if(rs.next())
		{
			isEnabled = "1".equals(rs.value("enable_ecommerce"));
		}
		return isEnabled;
	}

	String removeAccents(String src)
	{
		return com.etn.util.CommonHelper.removeAccents(src);
	}

	String getSiteFolderName(String s)
	{
		return removeAccents(s).replaceAll("[^\\p{IsAlphabetic}\\p{Digit}]", "-").toLowerCase();
	}

	String getDefaultMenuPath(com.etn.beans.Contexte Etn, String menuid)
	{			
		Set rs = Etn.execute("Select m.*, s.name as sitename from site_menus m, sites s where s.id = m.site_id and m.id = " + escape.cote(menuid));
		rs.next();

		String url = getSiteFolderName(parseNull(rs.value("sitename"))) + "/";
		url += parseNull(rs.value("lang")) + "/";

		return url;
	}
	
    String getProdPortalLink(com.etn.beans.Contexte Etn)
    {
        com.etn.lang.ResultSet.Set rs = Etn.execute("Select * from "+com.etn.beans.app.GlobalParm.getParm("PROD_DB")+".config where code = 'SEND_REDIRECT_LINK' ");
        rs.next();
        String v = parseNull(rs.value("val"));
        if(!v.endsWith("/")) v = v + "/";
        return v;
    }

    /***
    // check a set of arrays are of equals size
    */
    boolean areArraysEqualSize(Object[] ... arrays){

        for(int i=0; (i+1) <= arrays.length-1; i++){

            if(arrays[i].length != arrays[i+1].length){
                return false;
            }
        }

        return true;
    }
%>

