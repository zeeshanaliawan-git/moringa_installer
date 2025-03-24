package com.etn.asimina.util;

import com.etn.asimina.data.LanguageFactory;
import com.etn.asimina.beans.Language;
import com.etn.beans.app.GlobalParm;
import com.etn.lang.ResultSet.Set;
import com.etn.asimina.beans.KeyValuePair;
import com.etn.asimina.data.ConstantsFactory;

import java.util.regex.Pattern;
import java.util.regex.Matcher;
import java.util.*;
import javax.servlet.http.HttpServletRequest;

public class UIHelper {

    public static String getRsValue(Set rs, String col) {
        if (rs == null) {
            return "";
        }
        return parseNull(rs.value(col));
    }

    public static String getRsValueForLang(Set rs, String col, String languageId) {
        if (rs != null) {
            rs.moveFirst();
            while (rs.next()) {
                if (languageId.equals(
                        parseNull(rs.value("langue_id")))) {
                    return parseNull(rs.value(col));
                }
            }
        }
        return "";
    }

    public static String parseNull(Object o) {
        if (o == null) {
            return ("");
        }
        String s = o.toString();
        if ("null".equals(s.trim().toLowerCase())) {
            return ("");
        } else {
            return (s.trim());
        }
    }

    public static String getTagName(String html) {
        String patternString = "<([A-Za-z]*) ";

        Pattern pattern = Pattern.compile(patternString);
        Matcher matcher = pattern.matcher(html);

        if (matcher.find()) {
            return matcher.group(1);
        }
        return null;
    }

    public static String getLangFields(LanguageFactory languageFactory, String field) {
        StringBuilder html = new StringBuilder();
        String tagName = getTagName(field);
        if (tagName != null) {
            List<Language> langs = languageFactory.get();
            for (int i = 0; i < langs.size(); i++) {
                String newField = String.format(field, langs.get(i).getLanguageId());
                if (i > 0) {
                    html.append(newField.replace("<" + tagName + " ", "<" + tagName + " style='display:none;'"));
                } else {
                    html.append(newField.replace("<" + tagName + " ", "<" + tagName + " multilingual='true'"));
                }
            }
        }
        return html.toString();
    }

    public static String getLangInput(int index, String languageId, String id, String name, String value) {
        return getLangInput(index, languageId, id, name, value, "");
    }

    public static String getLangInput(int index, String languageId, String id, String name, String value,
            String className) {
        StringBuilder html = new StringBuilder();
        html.append("<input type='text' class='form-control ").append(className).append("' ")
                .append("data-language-id='").append(languageId).append("' ");
        if (index == 0) {
            html.append("multilingual='true'");
        } else {
            html.append("style='display:none;'");
        }
        html.append("id='").append(id).append("'").append(" name='").append(name).append("' value='")
                .append(escapeCoteValue(value)).append("'>");

        return html.toString();
    }

    public static String getLangInputs(LanguageFactory languageFactory, String id, String name, String colName,
            Set rs) {
        return getLangInputs(languageFactory, id, name, colName, rs, "");
    }

    public static String getLangInputs(LanguageFactory languageFactory, String id, String name, String colName, Set rs,
            String className) {
        StringBuilder html = new StringBuilder();
        List<Language> langs = languageFactory.get();
        for (int i = 0; i < langs.size(); i++) {
            html.append(
                    getLangInput(
                            i,
                            langs.get(i).getLanguageId(),
                            String.format(id, langs.get(i).getLanguageId()),
                            String.format(name, langs.get(i).getLanguageId()),
                            getRsValue(
                                    rs,
                                    String.format(colName, langs.get(i).getLanguageId())),
                            className));
        }
        return html.toString();
    }

    public static String getLangInputsRowWise(LanguageFactory languageFactory, String id, String name, String colName,
            Set rs) {
        return getLangInputsRowWise(languageFactory, id, name, colName, rs, "");
    }

    public static String getLangInputsRowWise(LanguageFactory languageFactory, String id, String name, String colName,
            Set rs, String className) {
        StringBuilder html = new StringBuilder();
        List<Language> langs = languageFactory.get();
        for (int i = 0; i < langs.size(); i++) {
            String languageId = langs.get(i).getLanguageId();
            html.append(
                    getLangInput(
                            i,
                            langs.get(i).getLanguageId(),
                            String.format(id, languageId),
                            String.format(name, languageId),
                            getRsValueForLang(rs, colName, languageId),
                            className));
        }
        return html.toString();
    }

    public static String getLangCheckBoxRowWise(LanguageFactory languageFactory, String id, String name,
            String selectedVal, String colName, Set rs) {
        return getLangCheckBoxRowWise(languageFactory, id, name, selectedVal, colName, rs, "");
    }

    public static String getLangCheckBoxRowWise(LanguageFactory languageFactory, String id, String name,
            String selectedVal, String colName, Set rs,
            String className) {
        StringBuilder html = new StringBuilder();
        List<Language> langs = languageFactory.get();
        for (int i = 0; i < langs.size(); i++) {
            String languageId = langs.get(i).getLanguageId();
            html.append(
                    getLangCheckBox(
                            i,
                            langs.get(i).getLanguageId(),
                            String.format(id, languageId),
                            String.format(name, languageId),
                            selectedVal,
                            getRsValueForLang(rs, colName, languageId),
                            className));
        }
        return html.toString();
    }

    public static String getLangCheckBox(int index, String languageId, String id, String name, String selectedVal,
            String value, String className) {
        StringBuilder html = new StringBuilder();
        if (className == null)
            className = "";
        html.append("<input type='checkbox' ");

        if (parseNull(className).length() > 0)
            html.append(" class='").append(className).append("' ");

        if (selectedVal.equals(value))
            html.append(" checked ");

        html.append("data-language-id='").append(languageId).append("' ");
        if (index == 0) {
            html.append("multilingual='true'");
        } else {
            html.append("style='display:none;'");
        }
        html.append("id='").append(id).append("'").append(" name='").append(name).append("' value='")
                .append(escapeCoteValue(selectedVal)).append("'>");

        return html.toString();
    }

    public static String getLangTextArea(int index, String languageId, String id, String name, String value) {
        return getLangTextArea(index, languageId, id, name, value, "");
    }

    public static String getLangTextArea(int index, String languageId, String id, String name, String value,
            String className) {
        StringBuilder html = new StringBuilder();
        // as most textareas are converted to ckeditor, it overrides display mechanism
        // of textarea
        // need to enclose them inside divs.
        html.append("<div class='asimina-multilingual-block' ").append(" id='").append(id + "_container").append("' ")
                .append(" data-language-id='").append(languageId).append("' ");
        if (index == 0) {
            html.append(" multilingual='true' ");
        } else {
            html.append(" style='display:none;' ");
        }
        html.append(" >");

        html.append("<textarea class='form-control ").append(className).append("' ")
                .append(" id='").append(id).append("' ")
                .append(" data-language-id='").append(languageId).append("' ");
        if (index == 0) {
            html.append(" multilingual='true' ");
        } else {
            html.append(" style='display:none;' ");
        }
        html.append(" name='").append(name).append("' >")
                .append(value).append("</textarea>").append("</div>");

        return html.toString();
    }

    public static String getLangTextAreas(LanguageFactory languageFactory, String rows, String id, String name,
            String colName, Set rs) {
        return getLangTextAreas(languageFactory, rows, id, name, colName, rs, "");
    }

    public static String getLangTextAreas(LanguageFactory languageFactory, String rows, String id, String name,
            String colName, Set rs, String className) {
        StringBuilder html = new StringBuilder();
        List<Language> langs = languageFactory.get();
        for (int i = 0; i < langs.size(); i++) {
            String languageId = langs.get(i).getLanguageId();
            html.append(
                    getLangTextArea(
                            i,
                            languageId,
                            String.format(id, languageId),
                            String.format(name, languageId),
                            getRsValue(
                                    rs,
                                    String.format(colName, languageId)),
                            className));
        }
        return html.toString();
    }

    public static String getLangTextAreasRowWise(LanguageFactory languageFactory, String id, String name,
            String colName, Set rs) {

        return getLangTextAreasRowWise(languageFactory, id, name, colName, rs, "");
    }

    public static String getLangTextAreasRowWise(LanguageFactory languageFactory, String id, String name,
            String colName, Set rs, String className) {
        StringBuilder html = new StringBuilder();
        List<Language> langs = languageFactory.get();
        for (int i = 0; i < langs.size(); i++) {
            String languageId = langs.get(i).getLanguageId();
            html.append(
                    getLangTextArea(
                            i,
                            langs.get(i).getLanguageId(),
                            String.format(id, languageId),
                            String.format(name, languageId),
                            getRsValueForLang(rs, colName, languageId),
                            className));
        }
        return html.toString();
    }

    public static String getLangSelect(int index, String languageId, String id, String name, String constantGroup,
            String parentKey, String cssClass, String attributes, String selectedValue) {
        if (attributes == null) {
            attributes = "";
        }
        attributes += " data-language-id='" + languageId + "'";
        if (index == 0) {
            attributes += " multilingual='true'";
        } else {
            attributes += " style='display:none;'";
        }
        return getSelectControl(id, name, constantGroup, parentKey, selectedValue, cssClass, attributes);
    }

    public static String getLangSelect(int index, String languageId, String id, String name,
            List<KeyValuePair<String, String>> options, String cssClass, String attributes, String selectedValue) {
        if (attributes == null) {
            attributes = "";
        }
        attributes += " data-language-id='" + languageId + "'";
        if (index == 0) {
            attributes += " multilingual='true'";
        } else {
            attributes += " style='display:none;'";
        }
        return getSelectControl(id, name, options, selectedValue, cssClass, attributes);
    }

    public static String getLangSelectsRowWise(LanguageFactory languageFactory, String id, String name,
            List<KeyValuePair<String, String>> options,
            String cssClass, String attributes, String colName, Set rs) {
        StringBuilder html = new StringBuilder();
        List<Language> langs = languageFactory.get();
        for (int i = 0; i < langs.size(); i++) {
            String languageId = langs.get(i).getLanguageId();
            html.append(
                    getLangSelect(
                            i,
                            languageId,
                            String.format(id, languageId),
                            String.format(name, languageId),
                            options,
                            cssClass,
                            attributes,
                            getRsValueForLang(rs, colName, languageId)));
        }
        return html.toString();
    }

    public static String getLangSelectsRowWise(LanguageFactory languageFactory, String id, String name,
            String constantGroup, String parentKey,
            String cssClass, String attributes, String colName, Set rs) {
        StringBuilder html = new StringBuilder();
        List<Language> langs = languageFactory.get();
        for (int i = 0; i < langs.size(); i++) {
            String languageId = langs.get(i).getLanguageId();
            html.append(
                    getLangSelect(
                            i,
                            languageId,
                            String.format(id, languageId),
                            String.format(name, languageId),
                            constantGroup,
                            parentKey,
                            cssClass,
                            attributes,
                            getRsValueForLang(rs, colName, languageId)));
        }
        return html.toString();
    }

    @SuppressWarnings("unchecked")
    public static String getSelectControl(String id, String name,
            java.util.Map<String, String> map, String selectedValue,
            String cssClass, String scripts) {

        if (selectedValue == null) {
            selectedValue = "";
        }
        java.util.ArrayList svals = new java.util.ArrayList();
        svals.add(selectedValue);

        return getSelectControl(id, name, map, svals, cssClass, scripts, false);

    }

    public static String getSelectControl(String id, String name,
            String constantGroup, String parentKey, String selectedValue,
            String cssClass, String attributes) {
        List<KeyValuePair<String, String>> data = ConstantsFactory.instance.get(constantGroup, parentKey);
        return getSelectControl(id, name, data, selectedValue, cssClass, attributes);
    }

    public static String getSelectControl(String id, String name,
            List<KeyValuePair<String, String>> options, String selectedValue,
            String cssClass, String attributes) {

        if (selectedValue == null) {
            selectedValue = "";
        }
        if (cssClass == null) {
            cssClass = "";
        }
        if (attributes == null) {
            attributes = "";
        }

        String html = "<select name='" + name + "' ";
        if (id.length() > 0) {
            html += " id='" + id + "' ";
        }
        if (cssClass.length() > 0) {
            html += " class='" + cssClass + "' ";
        }
        html += " " + attributes;
        html += " >";

        for (KeyValuePair<String, String> option : options) {
            String selected = "";
            if (option.getKey().equals(selectedValue)) {
                selected = " selected='selected' ";
            }
            html += "<option " + selected + " value='" + escapeCoteValue(option.getKey()) + "'>"
                    + escapeCoteValue(option.getValue()) + "</option>";
        }
        html += "</select>";
        return html;
    }

    public static String getSelectControl(String id, String name,
            java.util.Map<String, String> map, java.util.ArrayList svals,
            String cssClass, String scripts, boolean multiple) {
        int size = map.size();

        if (svals == null) {
            svals = new java.util.ArrayList();
        }
        if (cssClass == null) {
            cssClass = "";
        }
        if (scripts == null) {
            scripts = "";
        }

        String html = "<select name='" + name + "' ";
        if (id.length() > 0) {
            html += " id='" + id + "' ";
        }
        if (cssClass.length() > 0) {
            html += " class='" + cssClass + "' ";
        }
        html += " " + scripts;
        if (multiple) {
            html += " multiple ";
        }
        html += " >";

        for (String key : map.keySet()) {
            String val = map.get(key);
            String selected = "";
            if (svals.contains(key)) {
                selected = " selected='selected' ";
            }
            html += "<option " + selected + " value='" + escapeCoteValue(key) + "'>" + escapeCoteValue(val)
                    + "</option>";
        }
        html += "</select>";
        return html;
    }

    public static String escapeCoteValue(String str) {

        if (str != null && str.length() > 0) {
			return str.replace("&", "&amp;").replace("'", "&#39;").replace("\"", "&#34;").replace("<", "&lt;").replace(">", "&gt;").replace("/", "&#x2F;").replace("`", "&#x60;").replace("=", "&#x3D;").replace("\\","&#92;");
        } else {
            return str;
        }
    }

    public static boolean areListsValid(final String[]... lists) {
        boolean isValid = true;
        if (lists.length > 0) {
            if (lists[0] != null) {
                for (int i = 1; i < lists.length; i++) {
                    if (lists[i] == null || lists[i].length != lists[0].length) {
                        isValid = false;
                    }
                }
            } else {
                isValid = false;
            }
        }
        return isValid;
    }

    public static int convertTimeUnitToMinutes(int quantity, String timeUnit) {
        if (timeUnit.equals("minutes")) {
            return quantity;
        } else if (timeUnit.equals("hours")) {
            return quantity * 60;
        } else if (timeUnit.equals("days")) {
            return quantity * 1440;
        } else if (timeUnit.equals("weeks")) {
            return quantity * 10080;
        } else
            return 0;
    }
	
	public static String getIP(HttpServletRequest request)
	{
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("x-real-ip");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_CLIENT_IP");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_X_FORWARDED_FOR");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
		
		ip = parseNull(ip);

		//X-fowarded-for has chain of IPs ( comma separated list ) where first one is the client's IP, then comes the load balancer IP
		//if load balancer sends the request to server 2 and server 2 sends it back to server 1 then this chain will
		//have server 2 IP as well.
		//If user adds the x-fowarded-for header in request, then that information will always be at the start of this chain

		//this is the list of IPs we have to filter out from the x-fowarded-for chain
		List<String> filterIps = Arrays.asList(parseNull(GlobalParm.getParm("X_FORWARDED_FOR_IPS_CHAIN")).split("\\s*,\\s*"));
		
		List<String> ipList = Arrays.asList(ip.split("\\s*,\\s*"));
		if(ipList != null)
		{
			//we always traverse this list from right as load balancer and all reverse proxy server IPs are at the end of this list
			for(int i=(ipList.size()-1);i>=0;i--)
			{
				//here we are checking if this IP is either load balancer's ip or second server ip
				if(filterIps.contains(parseNull(ipList.get(i)))) continue;
				//first IP we get which is not in filterIps list is the client's IP
				ip = parseNull(ipList.get(i));
				break;
			}
		}
		
		//some countries are sending %2 or %1 with the IP .. seems like that is sent depending on which server the load balancer
		//sends the request
		String newIp = "";
		for(int i=0;i<ip.length();i++)
		{
			char charAt = ip.charAt(i);
			if('0' == charAt || 
				'1' == charAt || 
				'2' == charAt || 
				'3' == charAt || 
				'4' == charAt || 
				'5' == charAt || 
				'6' == charAt || 
				'7' == charAt || 
				'8' == charAt || 
				'9' == charAt || 
				'.' == charAt ) newIp += charAt;
			else break;
		}
		
		//System.out.println("IP:"+ip);
        return newIp;
	}
}
