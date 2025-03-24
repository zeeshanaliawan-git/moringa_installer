package com.etn.asimina.util;

import com.etn.sql.escape;
import com.etn.util.Logger;
import com.etn.beans.app.GlobalParm;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import com.etn.asimina.data.LanguageFactory;
import com.etn.asimina.beans.*;
import com.etn.asimina.data.ConstantsFactory;
import com.etn.beans.Contexte;

import java.util.regex.Pattern;
import java.util.regex.Matcher;
import java.util.*;
import java.io.File;
import java.lang.reflect.Field;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Cookie;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;
import java.lang.NumberFormatException;

import org.apache.commons.fileupload.*;
import org.apache.commons.fileupload.servlet.*;
import org.apache.commons.fileupload.disk.*;
import org.apache.tika.*;


/**
 * This class provides some helper functions to get the prefix for URLs where
 * the content will be cached eventually Any changes to this class means it must
 * be copied in all webapps
 */
public class PortalHelper {

    public static String getCachedResourcesUrl(Contexte Etn, String menuid) {
        String url = parseNull(GlobalParm.getParm("SEND_REDIRECT_LINK"));
        if (!url.endsWith("/")) {
            url += "/";
        }

        com.etn.lang.ResultSet.Set rs = Etn.execute("select s.* from sites s, site_menus m where m.site_id = s.id and m.id = " + escape.cote(menuid));
        rs.next();

        url += getSiteFolderName(parseNull(rs.value("name"))) + "/resources/";
        return url;
    }

	public static String getMenuResourcesFolder(Contexte Etn, String menuid)
	{
		Set rs = Etn.execute("Select m.*, s.name as sitename from site_menus m, sites s where s.id = m.site_id and m.id = " + escape.cote(menuid));
		rs.next();

		String basedir = GlobalParm.getParm("BASE_DIR") + GlobalParm.getParm("DOWNLOAD_PAGES_FOLDER");
		if(basedir.endsWith("/") == false) basedir += "/";

		String path = basedir + getSiteFolderName(parseNull(rs.value("sitename"))) + "/resources/";

		Logger.debug("PortalHelper","getMenuCacheFolder::"+path);
		return path;
	}

	public static boolean isInRules(Contexte Etn, String menuid, String href, String menuVersion, String siteid)
	{
		//internal urls are always considered as in rules as we always have to cache these pages
		if(href.toLowerCase().startsWith("http://127.0.0.1/")) return true;
		boolean isinrules = false;			

		Set rs = null;
		if(menuVersion.equalsIgnoreCase("V2"))
		{
			rs = Etn.execute("select * from sites_apply_to where site_id = " + escape.cote(siteid));
		}
		else
		{
			rs = Etn.execute("select * from menu_apply_to where menu_id = " + escape.cote(menuid));
		}
		//System.out.println(">>>>>> href : " + href);
		while(rs.next())
		{
			String applyTo = parseNull(rs.value("apply_to")).toLowerCase();
			//System.out.println(">>>>>> applyTo : " + applyTo);
			if(parseNull(rs.value("apply_type")).equals("url_starting_with"))
			{
				//we must add the / to make sure its exactly the same url intended .. otherwise www.orange.cim starts with www.orange.ci which is wrong
				if(applyTo.endsWith("/") == false) applyTo += "/";
				if(href.toLowerCase().startsWith("http://" + applyTo) || href.toLowerCase().startsWith("https://" + applyTo))
				{
					isinrules = true;
					break;
				}				
			}
			else 
			{
				String thref = href;
				if(thref.indexOf("?") > -1 && applyTo.indexOf("?") < 0)
				{
					thref = thref.substring(0, thref.indexOf("?"));
				}
				//System.out.println(">>>>>> thref : " + thref);
				
				if(thref.toLowerCase().equals("http://" + applyTo) || thref.toLowerCase().equals("https://" + applyTo))
				{
					isinrules = true;
					break;
				}
			}
		}
		return isinrules;
	}

	public static String getMenuPath(Contexte Etn, String menuid)
	{
		String url = parseNull(GlobalParm.getParm("SEND_REDIRECT_LINK"));
		if(!url.endsWith("/")) url += "/";

		Set rs = Etn.execute("Select m.*, s.name as sitename from site_menus m, sites s where s.id = m.site_id and m.id = " + escape.cote(menuid));
		rs.next();

		if("1".equals(GlobalParm.getParm("IS_PRODUCTION_ENV")) && parseNull(rs.value("production_path")).length() > 0)
		{
			url += parseNull(rs.value("production_path"));
		}
		else
		{
			url += getMenuCacheFolder(Etn, menuid);
		}
		Logger.debug("PortalHelper","getMenuPath::"+url);
		return url;
	}

	public static String getMenuPathFor(Contexte Etn, String menuid, String configCode)
	{
		//for send redirect link which is basically used for creating the final urls for pages we
		//have to check for production_path always so we call the function getMenuPath
		if("SEND_REDIRECT_LINK".equals(configCode)) return getMenuPath(Etn, menuid);

		String url = parseNull(GlobalParm.getParm(configCode));
		if(!url.endsWith("/")) url += "/";

		url += getMenuCacheFolder(Etn, menuid);
		return url;
	}

	public static boolean isLocalAsset(String url)
	{
		Logger.debug("PortalHelper", "Inside isLocalAsset " + url);

		if(parseNull(url).length() == 0) return false;

		String localResourcesUrl = "/src/";
		if(localResourcesUrl.length() == 0) return false;//path not configured

		//incoming url can be an absolute or relative url
		if(url.startsWith("http://127.0.0.1" + localResourcesUrl)
			|| url.startsWith("http://localhost" + localResourcesUrl)
			|| url.startsWith(localResourcesUrl)) return true;
		return false;
	}

	public static String getMenuCacheFolder(Contexte Etn, String menuid)
	{
		Set rs = Etn.execute("Select m.*, s.name as sitename from site_menus m, sites s where s.id = m.site_id and m.id = " + escape.cote(menuid));
		rs.next();

		String path = getSiteFolderName(parseNull(rs.value("sitename"))) + "/";
		path += parseNull(rs.value("lang")).toLowerCase() + "/";

		Logger.debug("PortalHelper","getMenuCacheFolder::"+path);
		return path;
	}

	public static boolean ignoreRelativeUrl(String[] ignoreRelUrls, String url)
	{
		if(ignoreRelUrls == null) return false;

		for(String iu : ignoreRelUrls)
		{
			if(url.toLowerCase().startsWith(iu.toLowerCase())) return true;
		}
		return false;
	}

	public static boolean isLocalResource(String url)
	{
		Logger.debug("PortalHelper", "Inside isLocalResource " + url);

		if(parseNull(url).length() == 0) return false;

		String localResourcesUrl = parseNull(GlobalParm.getParm("COMMON_RESOURCES_URL"));
		if(localResourcesUrl.length() == 0) return false;//path not configured

		//incoming url can be an absolute or relative url
		if(url.startsWith("http://127.0.0.1" + localResourcesUrl)
			|| url.startsWith("http://localhost" + localResourcesUrl)
			|| url.startsWith(localResourcesUrl)) return true;
		return false;
	}

    public static String getSiteFolderName(String s) {
        //return com.etn.asimina.util.UrlHelper.removeAccents(parseNull(s)).replaceAll("[^A-Za-z0-9]", "-").toLowerCase();
        return com.etn.asimina.util.UrlHelper.removeAccents(parseNull(s)).replaceAll("[^\\p{IsAlphabetic}\\p{Digit}]", "-").toLowerCase();
    }

    public static String formatPrice(String formatter, String roundto, String decimals, String amnt) {
		return formatPrice(formatter, roundto, decimals, amnt, false);
	}

    public static String formatPrice(String formatter, String roundto, String decimals, String amnt, boolean noformat) {
        if (formatter == null) {
            formatter = "";
        }
        formatter.trim();

        if (roundto == null) {
            roundto = "";
        }
        roundto.trim();

        if (decimals == null) {
            decimals = "";
        }
        decimals.trim();

        if (amnt == null) {
            amnt = "";
        }
        amnt.trim();

        if (amnt.length() == 0 || formatter.length() == 0) {
            return amnt;
        }

        if (Double.parseDouble(amnt) == 0) {
            return "0";
        }

        String finalpattern = "###,##0";
        java.text.DecimalFormat nf = null;
        if ("french".equals(formatter)) {
            nf = (java.text.DecimalFormat) java.text.NumberFormat.getInstance(java.util.Locale.FRANCE);
        } else if ("german".equals(formatter)) {
            nf = (java.text.DecimalFormat) java.text.NumberFormat.getInstance(java.util.Locale.GERMAN);
        } else if ("us".equals(formatter)) {
            nf = (java.text.DecimalFormat) java.text.NumberFormat.getInstance(java.util.Locale.US);
        }

        if (roundto.length() > 0) {
            String pattern = "#";
            for (int i = 0; i < Integer.parseInt(roundto); i++) {
                if (i == 0) {
                    pattern += ".";
                }
                pattern += "0";
            }
            java.text.DecimalFormat df = (java.text.DecimalFormat) java.text.NumberFormat.getNumberInstance(java.util.Locale.US);
            df.applyPattern(pattern);
            amnt = df.format(Double.parseDouble(amnt));
        }
        try {

            if (decimals.length() > 0) {

                String pattern = "#";
                for (int i = 0; i < Integer.parseInt(decimals); i++) {
                    if (i == 0) {
                        pattern += ".";
                        finalpattern += ".";
                    }
                    pattern += "0";
                    finalpattern += "0";
                }
                java.text.DecimalFormat df = (java.text.DecimalFormat) java.text.NumberFormat.getNumberInstance(java.util.Locale.US);
                df.applyPattern(pattern);
                amnt = df.format(Double.parseDouble(amnt));

            }

        } catch (Exception e) {

            e.printStackTrace();
        }

        if (noformat) {
            return amnt; // don't apply final pattern to store proper value as well in db
        }
        nf.applyPattern(finalpattern);
        amnt = nf.format(Double.parseDouble(amnt));
        return amnt;
    }

    public static String getImageUrlVersion(String file)
    {
        try
        {
            java.nio.file.Path path = java.nio.file.Paths.get(file);
            java.nio.file.attribute.BasicFileAttributes attr = java.nio.file.Files.readAttributes(path, java.nio.file.attribute.BasicFileAttributes.class);

            if(parseNull(attr.lastModifiedTime().toString()).length() > 0)
            {
                    return "?ts="+ parseNull(attr.lastModifiedTime().toString()).replaceAll("[^0-9]", "");
            }
        }
        catch(Exception e) {}
        return "";
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

    public static String encodeJSONStringDB(String str){
        return str.replaceAll("\\\\", "#slash#");
    }

    public static String decodeJSONStringDB(String str){
        return str.replaceAll("#slash#","\\\\");
    }

    /***
    * updated escape cote to preserve slashes (\)
    * which are removed by escape.cote() function
    */
    public static String escapeCote2(String str){
        if(str == null || str.trim().length() == 0){
            return escape.cote(str);
        }

        String retStr = escape.cote(encodeJSONStringDB(str));
        retStr = retStr.replaceAll("#slash#","#slash##slash#");
        retStr = decodeJSONStringDB(retStr);

        return retStr;
    }

    public static String getExtension(String fileName)
	{
        String extension = "";
        int i = fileName.lastIndexOf('.');
        if (i > 0) {
            extension = fileName.substring(i+1);
        }
        return extension;
    }

    public static String getContentType(String fileName)
	{
        return "image/" + getExtension(fileName);
    }

    public static String getBase64Image(String fileName)
	{
        try
		{
			if(parseNull(fileName).length() == 0) return "";

            java.nio.file.Path path = java.nio.file.Paths.get(fileName);
            if(java.nio.file.Files.exists(path) && java.nio.file.Files.isRegularFile(path))
			{
                byte[] fileContent = java.nio.file.Files.readAllBytes(path);
                String content = javax.xml.bind.DatatypeConverter.printBase64Binary(fileContent);
                return "data:" + getContentType(fileName) + ";base64," + content;
            }
			else
			{
                return "";
            }
        }
		catch(Exception ex)
		{
            ex.printStackTrace();
            return "";
        }
    }

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
                    parseNull(rs.value("langue_id"))
                )) {
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
        }
        else {
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

    public static String getLangFields(String field) {
        StringBuilder html = new StringBuilder();
        String tagName = getTagName(field);
        if (tagName != null) {
            List<Language> langs = LanguageFactory.instance.get();
            for (int i = 0; i < langs.size(); i++) {
                String newField = String.format(field, langs.get(i).getLanguageId());
                if (i > 0) {
                    html.append(newField.replace("<" + tagName + " ", "<" + tagName + " style='display:none;'"));
                }
                else {
                    html.append(newField.replace("<" + tagName + " ", "<" + tagName + " multilingual='true'"));
                }
            }
        }
        return html.toString();
    }

    public static String getLangInput(int index, String languageId, String id, String name, String value) {
        return getLangInput(index, languageId, id, name, value, "");
    }

    public static String getLangInput(int index, String languageId, String id, String name, String value, String className) {
        StringBuilder html = new StringBuilder();
        html.append("<input type='text' class='form-control ").append(className).append("' ")
        .append("data-language-id='").append(languageId).append("' ");
        if (index == 0) {
            html.append("multilingual='true'");
        }
        else {
            html.append("style='display:none;'");
        }
        html.append("id='").append(id).append("'").append(" name='").append(name).append("' value='").append(escapeCoteValue(value)).append("'>");

        return html.toString();
    }


    public static String getLangInputs(String id, String name, String colName, Set rs) {
        return getLangInputs(id, name, colName, rs, "");
    }

    public static String getLangInputs(String id, String name, String colName, Set rs , String className) {
        StringBuilder html = new StringBuilder();
        List<Language> langs = LanguageFactory.instance.get();
        for (int i = 0; i < langs.size(); i++) {
            html.append(
                getLangInput(
                    i,
                    langs.get(i).getLanguageId(),
                    String.format(id, langs.get(i).getLanguageId()),
                    String.format(name, langs.get(i).getLanguageId()),
                    getRsValue(
                        rs,
                        String.format(colName, langs.get(i).getLanguageId())
                    )
                    , className
                )
            );
        }
        return html.toString();
    }

    public static String getLangInputsRowWise(String id, String name, String colName, Set rs) {
        return getLangInputsRowWise(id, name, colName, rs, "");
    }

    public static String getLangInputsRowWise(String id, String name, String colName, Set rs, String className) {
        StringBuilder html = new StringBuilder();
        List<Language> langs = LanguageFactory.instance.get();
        for (int i = 0; i < langs.size(); i++) {
            String languageId = langs.get(i).getLanguageId();
            html.append(
                getLangInput(
                    i,
                    langs.get(i).getLanguageId(),
                    String.format(id, languageId),
                    String.format(name, languageId),
                    getRsValueForLang(rs, colName, languageId),
                    className
                )
            );
        }
        return html.toString();
    }

    public static String getLangCheckBoxRowWise(String id, String name, String selectedVal, String colName, Set rs) {
        return getLangCheckBoxRowWise(id, name, selectedVal, colName, rs, "");
    }

    public static String getLangCheckBoxRowWise(String id, String name, String selectedVal, String colName, Set rs, String className) {
        StringBuilder html = new StringBuilder();
        List<Language> langs = LanguageFactory.instance.get();
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
                    className
                )
            );
        }
        return html.toString();
    }

    public static String getLangCheckBox(int index, String languageId, String id, String name, String selectedVal, String value, String className) {
        StringBuilder html = new StringBuilder();
		if(className == null) className = "";
        html.append("<input type='checkbox' ");

		if(parseNull(className).length() > 0 ) html.append(" class='").append(className).append("' ");

		if(selectedVal.equals(value)) html.append(" checked ");

        html.append("data-language-id='").append(languageId).append("' ");
        if (index == 0) {
            html.append("multilingual='true'");
        }
        else {
            html.append("style='display:none;'");
        }
        html.append("id='").append(id).append("'").append(" name='").append(name).append("' value='").append(escapeCoteValue(selectedVal)).append("'>");

        return html.toString();
    }


    public static String getLangTextArea(int index, String languageId, String id, String name, String value) {
        return getLangTextArea(index, languageId, id, name, value, "");
    }

    public static String getLangTextArea(int index, String languageId, String id, String name, String value, String className) {
        StringBuilder html = new StringBuilder();
        //as most textareas are converted to ckeditor, it overrides display mechanism of textarea
        //need to enclose them inside divs.
        html.append("<div class='asimina-multilingual-block' ").append(" id='").append(id + "_container").append("' ")
            .append(" data-language-id='").append(languageId).append("' ");
        if (index == 0) {
            html.append(" multilingual='true' ");
        }
        else {
            html.append(" style='display:none;' ");
        }
        html.append(" >");

        html.append("<textarea class='form-control ").append(className).append("' ")
            .append(" id='").append(id).append("' ")
            .append(" data-language-id='").append(languageId).append("' ");
        if (index == 0) {
            html.append(" multilingual='true' ");
        }
        else {
            html.append(" style='display:none;' ");
        }
        html.append(" name='").append(name).append("' >")
            .append(value).append("</textarea>").append("</div>");

        return html.toString();
    }

    public static String getLangTextAreas(String rows, String id, String name, String colName, Set rs) {
        return getLangTextAreas(rows, id, name, colName, rs, "");
    }

    public static String getLangTextAreas(String rows, String id, String name, String colName, Set rs, String className) {
        StringBuilder html = new StringBuilder();
        List<Language> langs = LanguageFactory.instance.get();
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
                        String.format(colName, languageId)
                    ),
                    className
                )
            );
        }
        return html.toString();
    }

    public static String getLangTextAreasRowWise(String id, String name, String colName, Set rs) {

        return getLangTextAreasRowWise(id, name, colName, rs, "");
    }

    public static String getLangTextAreasRowWise(String id, String name, String colName, Set rs, String className) {
        StringBuilder html = new StringBuilder();
        List<Language> langs = LanguageFactory.instance.get();
        for (int i = 0; i < langs.size(); i++) {
            String languageId = langs.get(i).getLanguageId();
            html.append(
                getLangTextArea(
                    i,
                    langs.get(i).getLanguageId(),
                    String.format(id, languageId),
                    String.format(name, languageId),
                    getRsValueForLang(rs, colName, languageId),
                    className
                )
            );
        }
        return html.toString();
    }

    public static String getLangSelect(int index, String languageId, String id, String name, String constantGroup, String parentKey, String cssClass, String attributes, String selectedValue) {
        if (attributes == null) {
            attributes = "";
        }
        attributes += " data-language-id='" + languageId + "'";
        if (index == 0) {
            attributes += " multilingual='true'";
        }
        else {
            attributes += " style='display:none;'";
        }
        return getSelectControl(id, name, constantGroup, parentKey, selectedValue, cssClass, attributes);
    }

    public static String getLangSelect(int index, String languageId, String id, String name, List<KeyValuePair<String, String>> options, String cssClass, String attributes, String selectedValue) {
        if (attributes == null) {
            attributes = "";
        }
        attributes += " data-language-id='" + languageId + "'";
        if (index == 0) {
            attributes += " multilingual='true'";
        }
        else {
            attributes += " style='display:none;'";
        }
		return getSelectControl(id, name, options, selectedValue, cssClass, attributes);
    }

    public static String getLangSelectsRowWise(String id, String name, List<KeyValuePair<String, String>> options, String cssClass, String attributes, String colName, Set rs) {
        StringBuilder html = new StringBuilder();
        List<Language> langs = LanguageFactory.instance.get();
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
                    getRsValueForLang(rs, colName, languageId)
                )
            );
        }
        return html.toString();
	}

    public static String getLangSelectsRowWise(String id, String name, String constantGroup, String parentKey, String cssClass, String attributes, String colName, Set rs) {
        StringBuilder html = new StringBuilder();
        List<Language> langs = LanguageFactory.instance.get();
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
                    getRsValueForLang(rs, colName, languageId)
                )
            );
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
            html += "<option " + selected + " value='" + escapeCoteValue(option.getKey()) + "'>" + escapeCoteValue(option.getValue()) + "</option>";
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
            html += "<option " + selected + " value='" + escapeCoteValue(key) + "'>" + escapeCoteValue(val) + "</option>";
        }
        html += "</select>";
        return html;
    }

	//When calling this function in the javascript function call parameters, normally we don't know if developer
	//is passing the parameter inside double qoutes or single qoutes .. so developer will pass the skipChar and 
	//in that case we cannot replace it with its html notation but have to escape the character itself
    public static String escapeCoteValue(String str, String skipChar) 
	{
		skipChar = parseNull(skipChar);
        if (str != null && str.length() > 0) 
		{
			str = str.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("/", "&#x2F;").replace("`", "&#x60;").replace("=", "&#x3D;").replace("\\","&#92;");
			if(skipChar.equals("\"")) str = str.replace("\"","\\\"").replace("'", "&#39;");
			else if(skipChar.equals("'")) str = str.replace("'","\'").replace("\"", "&#34;");
			else str = str.replace("'", "&#39;").replace("\"", "&#34;");
            return str;
        }
        else 
		{
            return str;
        }
    }

    public static String escapeCoteValue(String str) 
	{
		return escapeCoteValue(str, null);
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
            }
            else {
                isValid = false;
            }
        }
        return isValid;
    }


	public static int parseNullInt(Object o)
	{
		String s = parseNull(o);
		if(s.length() > 0 ){
			try{
				return Integer.parseInt(s);
			}
			catch(Exception e){
				return 0;
			}
		}
		else{
			return 0;
		}
	}

	public static double parseNullDouble(Object o)
	{
		String s = parseNull(o);
		if(s.length() > 0 ){
			try{
				return Double.parseDouble(s);
			}
			catch(Exception e){
				return 0;
			}
		}
		else{
			return 0;
		}
	}

	public static long parseNullLong(Object o)
	{
		String s = parseNull(o);
		if(s.length() > 0 ){
			try{
				return Long.parseLong(s);
			}
			catch(Exception e){
				return 0;
			}
		}
		else{
			return 0;
		}
	}

    public static String toProperCase(String s){
         return s.substring(0, 1).toUpperCase() + s.substring(1).toLowerCase();
    }

    public static String toCamelCase(String name){
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
	
	private static boolean listHasColumn(List<String> list, String column)
	{
		if(list == null) return false;
		for(String c : list)
		{			
			if(parseNull(column).equalsIgnoreCase(parseNull(c))) return true;
		}
		return false;
	}
	
	public static JSONObject toJSONObject(com.etn.lang.ResultSet.Set rs, boolean ignoreLangCols){
		return toJSONObject(rs, null, ignoreLangCols);
    }

    public static JSONObject toJSONObject(com.etn.lang.ResultSet.Set rs, List<String> jsonColumns){
		return toJSONObject(rs, jsonColumns, false);
	}

    public static JSONObject toJSONObject(com.etn.lang.ResultSet.Set rs){
		return toJSONObject(rs, null, false);
    }
	
    public static JSONObject toJSONObject(com.etn.lang.ResultSet.Set rs, List<String> jsonColumns, boolean ignoreLangCols){
        String [] colNames = rs.ColName;
        JSONObject data = new JSONObject();
        try
		{
            for(String colName : colNames)
			{
        		if(ignoreLangCols && colName.startsWith("LANG_") == true)
				{
					continue;
				}
				else
				{
					if(listHasColumn(jsonColumns, colName))
					{
						com.etn.util.Logger.debug("PortalHelper","Check for json column : " + colName);
						String val = rs.value(colName);
						if(parseNull(val).length() == 0) data.put(toCamelCase(colName), new JSONObject());
						else if(parseNull(val).startsWith("[")) data.put(toCamelCase(colName), new JSONArray(rs.value(colName)));
						else data.put(toCamelCase(colName), new JSONObject(rs.value(colName)));
					}
					else data.put(toCamelCase(colName),rs.value(colName));
				}
            }
        }catch(org.json.JSONException ex){
            com.etn.util.Logger.error("PortalHelper", ex.toString());
			ex.printStackTrace();
        }
        return data;
    }

    public static org.json.JSONArray toJSONArray(Contexte Etn,String query){
		return toJSONArray(Etn, query, null, false);
	}
	
    public static org.json.JSONArray toJSONArray(Contexte Etn,String query, List<String> jsonColumns){
		return toJSONArray(Etn, query, jsonColumns, false);
	}
	
    public static org.json.JSONArray toJSONArray(Contexte Etn,String query, boolean ignoreLangCols){
		return toJSONArray(Etn, query, null, ignoreLangCols);
	}
	
    public static org.json.JSONArray toJSONArray(Contexte Etn,String query, List<String> jsonColumns, boolean ignoreLangCols){
        org.json.JSONArray data = new org.json.JSONArray();

        com.etn.lang.ResultSet.Set rs = Etn.execute(query);
        if(rs != null){
            while(rs.next()){
                data.put(toJSONObject(rs, jsonColumns, ignoreLangCols));
            }
        }
        return data;
    }

    public static int getNumber(Contexte Etn,String query){
        int num = 0;
        com.etn.lang.ResultSet.Set rs = Etn.execute(query);
        if(rs != null && rs.next()){
            num = Integer.parseInt(rs.value(0));
        }
        return num;
    }

	public static String getcurrencyfrequency(String defaultcurrency, String currency, String frequency)
	{
		String s = "";
		if(parseNull(currency).length() > 0) s = parseNull(currency);
		else if(parseNull(defaultcurrency).length() > 0) s = parseNull(defaultcurrency);

		if(parseNull(frequency).length() > 0)
		{
			if(s.length() > 0) s += "/";
			s += parseNull(frequency);
		}
		return s;
	}

	public static String getcurrencyfrequency(Contexte Etn, String defaultcurrency, String frequency)
	{
		String s = "";
		if(parseNull(defaultcurrency).length() > 0) s = com.etn.asimina.util.LanguageHelper.getInstance().getTranslation(Etn, parseNull(defaultcurrency));

		if(parseNull(frequency).length() > 0)
		{
			if(s.length() > 0) s += "/";
			s += com.etn.asimina.util.LanguageHelper.getInstance().getTranslation(Etn, parseNull(frequency));
		}
		return s;
	}

	public static String hashMe(String str)
    {
        StringBuffer sb=null;
        try
        {
            MessageDigest md = MessageDigest.getInstance("SHA-512");
            md.update(str.getBytes());
            byte byteData[] = md.digest();
            sb= new StringBuffer();
            for (int i = 0; i < byteData.length; i++)
            {
                sb.append(Integer.toString((byteData[i] & 0xff) + 0x100, 16).substring(1));
            }
        }
        catch(NoSuchAlgorithmException e)
        {

        }
        return sb.toString();
    }

    public static String getCurrencyPosition(Contexte Etn, HttpServletRequest request, String siteId, int langId, String price, String currency)
    {
        String position = getCurrencyPosition(Etn, request, siteId, langId +"");
        if(position.equals("before")){
            return currency +" "+price;
        } else{
            return   price +" "+ currency;
        }
    }

    public static String getCurrencyPosition(Contexte Etn, HttpServletRequest request, String siteId, String langCode, String price, String currency)
    {
        String position = getCurrencyPosition(Etn, request, siteId, langCode);
        if(position.equals("before")){
            return currency +" "+price;
        } else{
            return   price +" "+ currency;
        }
    }

    public static String getCurrencyPosition(Contexte Etn, HttpServletRequest request, String siteId, String lang)
    {
        String currencyPosition = "after"; //default
        try{
            Set rs = null;
            String catalogDb = GlobalParm.getParm("PREPROD_CATALOG_DB");
            boolean isAlphabetic = lang.matches("[a-zA-Z]+");
            String langId = lang;
            if(isAlphabetic){
                rs = Etn.execute("SELECT langue_id FROM "+catalogDb+".language where langue_code = " + escape.cote(lang));
                rs.next(); // if any error occur it will show the default value
                langId = rs.value(0);
            }

            Object cp = request.getSession().getAttribute("cp_"+siteId+"_"+langId);

            if(cp != null){
                currencyPosition = (String)cp;
            } else{
                rs = Etn.execute("SELECT lang_"+langId+"_currency_position FROM "+catalogDb+".shop_parameters WHERE site_id = "+escape.cote(siteId));
                if(rs.next()){
                   currencyPosition =  rs.value(0);
                   request.getSession().setAttribute("cp_"+siteId+"_"+langId, currencyPosition);
                }
            }
        } catch(Exception ex){
            ex.printStackTrace();
        }
        return currencyPosition;
    }
	
	public static Map<String, String> loadAlgoliaSettings(Contexte Etn, String siteid)
	{
		Set rsAlg = Etn.execute("select * from "+GlobalParm.getParm("CATALOG_DB")+".algolia_settings where site_id = " + escape.cote(siteid) );
		String appId = "";
		String searchKey = "";
		String writeKey = "";
		if(rsAlg.next())
		{
			appId = parseNull(rsAlg.value("application_id"));
			searchKey = parseNull(rsAlg.value("search_api_key"));
			writeKey = parseNull(rsAlg.value("write_api_key"));
		}	
		Map<String, String> alg = new HashMap<>();
		alg.put("app_id", appId);
		alg.put("search_key", searchKey);
		alg.put("write_key", writeKey);
		return alg;
	}

    public static JSONObject LinkedJSONObject() throws JSONException 
	{
		JSONObject jsonObject = new JSONObject() 
		{
			@Override
			public JSONObject put(String key, Object value) throws JSONException 
			{
				try 
				{
					Field map = JSONObject.class.getDeclaredField("map");
					map.setAccessible(true);
					Object mapValue = map.get(this);
					if (!(mapValue instanceof LinkedHashMap)) 
					{
						map.set(this, new LinkedHashMap<>());
					}
				} 
				catch (NoSuchFieldException | IllegalAccessException e) 
				{
					throw new RuntimeException(e);
				}
				return super.put(key, value);
			}
		};
		return jsonObject;
    }

    public static JSONObject LinkedJSONObject(String var) throws JSONException 
	{
        JSONObject jsonObject = new JSONObject(var) 
		{
			@Override
            public JSONObject put(String key, Object value) throws JSONException 
			{
                try 
				{
                    Field map = JSONObject.class.getDeclaredField("map");
                    map.setAccessible(true);
                    Object mapValue = map.get(this);
                    if (!(mapValue instanceof LinkedHashMap)) 
					{
                        map.set(this, new LinkedHashMap<>());
                    }
                } 
				catch (NoSuchFieldException | IllegalAccessException e) 
				{
                    throw new RuntimeException(e);
                }
                return super.put(key, value);
            }
        };
        return jsonObject;
    }

	public static JSONArray saveAdditionalFileToDisk(String uploadDir, String baseUrl, AdditionalInfoField aif, List<FileItem> files) throws Exception
	{
		if(files == null || aif == null || files.size() == 0) return null;
		JSONArray jValues = new JSONArray();
		
		for(FileItem fi : files)
		{
			String filename = PortalHelper.parseNull(fi.getName());
			filename = filename.replace("/","").replace("\\","");
			if(filename.length() == 0) continue;
			com.etn.util.Logger.info("PortalHelper", "<<<<<<<< " + aif.name + " : " + filename);
						
			String _type = new Tika().detect(org.apache.commons.io.IOUtils.toByteArray(fi.getInputStream()));
			
			JSONObject jVal = PortalHelper.LinkedJSONObject();
			jVal.put("filename", filename);
			jVal.put("base_url", baseUrl);
			jVal.put("base_dir", uploadDir);
			jVal.put("content_type", _type);

			Logger.info("updatecheckout.jsp", "saveFileToDisk::"+uploadDir+filename);
			File destFile = new File(uploadDir+filename);
			fi.write(destFile);
			jValues.put(jVal);
		}
		return jValues;
	}

	public static boolean isAdditionalFileValid(AdditionalInfoField aif, List<FileItem> files) throws Exception
	{
		if(aif == null || files == null || files.size() == 0 || aif.allowedTypes == null || aif.allowedTypes.size() == 0) return true;
		for(FileItem fileItem : files)
		{
			if(fileItem.getName().length() == 0) continue;
			String _type = new Tika().detect(org.apache.commons.io.IOUtils.toByteArray(fileItem.getInputStream()));

			if (aif.allowedTypes.contains(_type) == false) 
			{
				return false;
			}
		}
		return true;
	}
	
	public static JSONObject addAdditionalInfoField(JSONObject jAddInfo, AdditionalInfoField aif, JSONArray jValues) throws Exception
	{
		com.etn.util.Logger.info("PortalHelper", ">>>>>>>>>>>>> "+aif.name + " jValues : "+jValues.length());
		JSONObject jSection = null;
		if(jAddInfo.has("sections") == false)
		{
			jAddInfo.put("sections", new JSONArray());
		}
		for(int i=0;i<jAddInfo.getJSONArray("sections").length();i++)
		{
			if(PortalHelper.parseNull(jAddInfo.getJSONArray("sections").getJSONObject(i).getString("name")).equals(aif.sectionName))
			{
				jSection = jAddInfo.getJSONArray("sections").getJSONObject(i);
				jSection.remove("display_name");
				jSection.put("display_name", aif.sectionDisplayName);//just updating the display name if its changed in db
				break;
			}
		}
		if(jSection == null) 
		{
			jSection = PortalHelper.LinkedJSONObject();
			jSection.put("name", aif.sectionName);
			jSection.put("display_name", aif.sectionDisplayName);
			jAddInfo.getJSONArray("sections").put(jSection);
		}
		if(jSection.has("fields") == false)
		{
			jSection.put("fields", new JSONArray());
		}
		if(jValues.length() == 0)
		{
			//lets remove this field from the json
			boolean found = false;
			int i=0;
			for(i=0;i<jSection.getJSONArray("fields").length();i++)
			{			
				if(PortalHelper.parseNull(jSection.getJSONArray("fields").getJSONObject(i).getString("name")).equals(aif.name))
				{
					found = true;
					break;
				}
			}
			if(found)
			{
				com.etn.util.Logger.info("PortalHelper", ">>>><<<< remove field " + aif.name);
				jSection.getJSONArray("fields").remove(i);
			}
		}
		else
		{
			JSONObject jField = null;
			for(int i=0;i<jSection.getJSONArray("fields").length();i++)
			{			
				if(PortalHelper.parseNull(jSection.getJSONArray("fields").getJSONObject(i).getString("name")).equals(aif.name))
				{
					jField = jSection.getJSONArray("fields").getJSONObject(i);
					jField.remove("display_name");
					jField.remove("type");
					jField.put("display_name", aif.displayName);//just updating the display name if its changed in db
					jField.put("type", aif.ftype);//just updating the display name if its changed in db
					break;
				}
			}
			if(jField == null)
			{
				jField = PortalHelper.LinkedJSONObject();
				jField.put("name", aif.name);
				jField.put("type", aif.ftype);
				jField.put("display_name", aif.displayName);
				jSection.getJSONArray("fields").put(jField);
			}
			if(jField.has("value")) jField.remove("value");
			jField.put("value", jValues);
		}
		return jAddInfo;
	}

    public static Map<String, String> getHeadersInfo(HttpServletRequest request) 
	{
        Map<String, String> map = new HashMap<String, String>();
        Enumeration headerNames = request.getHeaderNames();
    
        while (headerNames.hasMoreElements()) 
		{
            String key = (String) headerNames.nextElement();
            String value = request.getHeader(key);
            map.put(key, value);
        }

        return map;
    }

	public static String getSiteConfig(Contexte Etn, String siteId, String code)
	{
		Set rs = Etn.execute("select * from sites_config where site_id = "+escape.cote(siteId)+" and code = "+escape.cote(code));
		if(rs.next())
		{
			return parseNull(rs.value("val"));
		}
		return "";
	}
	
	//keep this static
	public static boolean isFrequencyApplicable(String productType, String productVersion)
	{
		//frequency is only applicable for these type of products but in database all products have a default value set so we must use it accordingly
		if("offer_postpaid".equals(productType)) 
		{
			return true;
		}
		if("V1".equals(productVersion) == false)
		{
			return true;
		}
		
		return false;
	}
	
	public static String getV2ProductContentData(Contexte Etn, String productId, String langId)
	{
		String pagesDb = GlobalParm.getParm("PAGES_DB");
		String catalogDb = GlobalParm.getParm("CATALOG_DB");
		Set rs = Etn.execute("select * from "+pagesDb+".products_map_pages where product_id = "+escape.cote(productId));
		if(rs.next())
		{
			String contentId = rs.value("page_id");
			Set rsC = Etn.execute("select content_data from "+pagesDb+".structured_contents_details where content_id = "+escape.cote(contentId)+" and langue_id = "+escape.cote(langId));
			if(rsC.next())
			{
				return decodeJSONStringDB(rsC.value("content_data"));
			}
		}
		return null;		
	}
	
	public static JSONArray getV2ProductVariantAttributes(Contexte Etn, String productId, String langId, String variantUuid)
	{
		try
		{
			String contentData = getV2ProductContentData(Etn, productId, langId);
			if(parseNull(contentData).length() > 0)
			{
				JSONObject jData = new JSONObject(contentData);

				if(jData.has("product_variants"))
				{
					for(int i=0;i<jData.getJSONArray("product_variants").length();i++)
					{
						for(int j=0;j<jData.getJSONArray("product_variants").getJSONObject(i).getJSONArray("product_variants_variant_x").length();j++)
						{
							JSONObject jVariant = jData.getJSONArray("product_variants").getJSONObject(i).getJSONArray("product_variants_variant_x").getJSONObject(j);

							if(jVariant.has("product_variants_variant_x_attributes") && jVariant.getJSONArray("product_variants_variant_x_uuid").optString(0,"").equals(variantUuid))
							{
								return jVariant.getJSONArray("product_variants_variant_x_attributes");
							}
						}
					}
				}
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();			
		}
		return null;
	}

	public static JSONArray getV2ProductVariantImages(Contexte Etn, String productId, String langId, String variantUuid)
	{
		try
		{
			String contentData = getV2ProductContentData(Etn, productId, langId);
			if(parseNull(contentData).length() > 0)
			{
				JSONObject jData = new JSONObject(contentData);

				if(jData.has("product_variants"))
				{
					for(int i=0;i<jData.getJSONArray("product_variants").length();i++)
					{
						for(int j=0;j<jData.getJSONArray("product_variants").getJSONObject(i).getJSONArray("product_variants_variant_x").length();j++)
						{
							JSONObject jVariant = jData.getJSONArray("product_variants").getJSONObject(i).getJSONArray("product_variants_variant_x").getJSONObject(j);

							if(jVariant.has("product_variants_variant_x_image") && jVariant.getJSONArray("product_variants_variant_x_uuid").optString(0,"").equals(variantUuid))
							{
								return jVariant.getJSONArray("product_variants_variant_x_image");
							}
						}
					}
				}
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();			
		}
		return null;
	}

	public static JSONArray getV2ProductImage(Contexte Etn, String productId, String langId)
	{
		try
		{
			String contentData = getV2ProductContentData(Etn, productId, langId);
			if(parseNull(contentData).length() > 0)
			{
				JSONObject jData = new JSONObject(contentData);
				if(jData.has("product_general_informations") && jData.getJSONArray("product_general_informations").length() > 0)
				{
					JSONObject jGeneralInfo = jData.getJSONArray("product_general_informations").getJSONObject(0);
					if(jGeneralInfo.has("product_general_informations_image")) return jGeneralInfo.getJSONArray("product_general_informations_image");
				}
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();			
		}
		return null;
	}
	
	public static JSONArray getProductCategories(Contexte Etn, String productId) throws Exception
	{
		String catalogDb = GlobalParm.getParm("CATALOG_DB");
		Set rs = Etn.execute(" select c.* "
					+ " from "+catalogDb+".products p "
					+ " join "+catalogDb+".products_definition pd on pd.id = p.product_definition_id "
					+ " join "+catalogDb+".product_types_v2 pt on pt.id = pd.product_type "
					+ " join "+catalogDb+".product_v2_categories_and_attributes pa on pa.product_type_uuid = pt.uuid and pa.reference_type = 'category' "
					+ " join "+catalogDb+".categories_v2 c on c.uuid = pa.reference_uuid "
					+ " where p.id = "+escape.cote(productId));
					
		JSONArray jCategories = new JSONArray();
		while(rs.next())
		{
			String parent = "";
			if(parseNullInt(rs.value("parent_id")) > 0)
			{
				Set rsP = Etn.execute("select * from "+catalogDb+".categories_v2 where id = "+escape.cote(rs.value("parent_id")));
				if(rsP.next())
				{
					parent = rsP.value("name");
				}
			}
			JSONObject jCategory = new JSONObject();
			jCategory.put("name", rs.value("name"));
			if(parent.length() > 0)
			{
				jCategory.put("parent", parent);
			}
			jCategories.put(jCategory);
		}
		
		return jCategories;
	}
	
	public static boolean isProduct(String productType)
	{
		if("product".equals(productType) || "simple_product".equals(productType) || "configurable_product".equals(productType))
		{
			return true;
		}
		return false;
	}

	public static boolean isOffer(String productType)
	{
		if("offer_prepaid".equals(productType) || "offer_postpaid".equals(productType) || "simple_virtual_product".equals(productType) || "configurable_virtual_product".equals(productType))
		{
			return true;
		}
		return false;
	}
}
