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

int parseNullInt(Object o)
        {
            if (o == null) return 0;
            String s = o.toString();
            if (s.equals("null")) return 0;
            if (s.equals("")) return 0;
            return Integer.parseInt(s);
        }


        double parseNullDouble(Object o)
        {
            if (o == null) return 0;
            String s = o.toString();
            if (s.equals("null")) return 0;
            if (s.equals("")) return 0;
            return Double.parseDouble(s);
        }

	String addSelectControl(String id, String name, Map<String,String> map, boolean isMultiSelect, int maxControlSize, String type,int i)
	{
		int size = map.size();

		String html = "<select class='form-control' onchange='changeProfile(this,\""+type+"\","+i+")' name='" + name + "' id='" + id + "' ";
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
	String addSelectControl(String id, String name, Map<String,String> map, boolean isMultiSelect, int maxControlSize)
	{
		int size = map.size();

		String html = "<select class='form-control' name='" + name + "' id='" + id + "' ";
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

    public String escapeHtml(String str) 
	{
		return com.etn.asimina.util.UIHelper.escapeCoteValue(str);
    }

   	String escapeCoteValue(String str)
	{
		return com.etn.asimina.util.UIHelper.escapeCoteValue(str);
	}
	
    String getMimeType(String filename)
    {
        if(filename == null || filename.length() == 0) return null;
        filename = filename.toLowerCase();
        int index= filename.lastIndexOf(".");
        String ext=filename.substring(index+1,filename.length());

        if(ext.equals("txt")) return "text/plain";
        if(ext.equals("jpg") || ext.equals("jpeg") || ext.equals("png")) return "image/jpeg";
        if(ext.equals("pdf")) return "application/pdf";
        if(ext.equals("doc") || ext.equals("docx")) return "application/msword";
        if(ext.equals("xls") || ext.equals("xlsx")) return "application/excel";
        else return null;
    }
            String toProperCase(String s){
         return s.substring(0, 1).toUpperCase() + s.substring(1).toLowerCase();
    }

    String toCamelCase(String name){
        String [] parts = name.split("_");

        String camelCase = null;

        for(String part : parts){
            if(camelCase == null){
                camelCase = part.toLowerCase();
            }else{
                camelCase = camelCase + toProperCase(part);
            }
        }
        return camelCase;
    }
	
    boolean validatePass(String password)
    {
        String pattern = "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*])(?=.{12,})";
        java.util.regex.Pattern r = java.util.regex.Pattern.compile(pattern);
        java.util.regex.Matcher m = r.matcher(password);
        if (m.find())
            return true;
        else
            return false;
    }
	
%>

