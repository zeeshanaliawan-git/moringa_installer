 <%@ page import="java.util.Map"%>
<%@ page import="java.util.LinkedHashMap"%>
<%@ page import="java.io.UnsupportedEncodingException"%>
<%@ page import="java.security.MessageDigest"%>
<%@ page import="java.security.NoSuchAlgorithmException"%>

<%!

String parseNull(Object o) {
  if( o == null )
    return("");
  String s = o.toString();
  if("null".equals(s.trim().toLowerCase()))
    return("");
  else
    return(s.trim());
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
			html = html + "<option value='" + key + "'>"+val+"</option>";	
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

	String replaceQoute(String str)
	{
		if(str == null || str.trim().length() == 0) return "";
		str = str.trim();
		String tmp = com.etn.sql.escape.cote(str).trim();
		if(tmp.startsWith("'")) tmp = tmp.substring(1);
		if(tmp.endsWith("'")) tmp = tmp.substring(0, tmp.length() - 1);
		return tmp;
	}

%>

