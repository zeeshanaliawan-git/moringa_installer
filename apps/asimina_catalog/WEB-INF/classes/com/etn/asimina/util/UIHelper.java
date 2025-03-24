package com.etn.asimina.util;

import com.etn.asimina.data.LanguageFactory;
import com.etn.asimina.beans.Language;
import java.util.regex.Pattern;
import java.util.regex.Matcher;
import java.util.List;
import java.util.Map;
import com.etn.lang.ResultSet.Set;
import com.etn.asimina.beans.KeyValuePair;
import com.etn.asimina.data.ConstantsFactory;
import java.util.regex.*;
import javax.servlet.http.HttpServletRequest;

import com.etn.beans.Contexte;
import com.etn.beans.app.GlobalParm;
import com.etn.sql.escape;

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

    public static String getLangFields(List<Language> langsList, String field) {
        StringBuilder html = new StringBuilder();
        String tagName = getTagName(field);
        if (tagName != null) {
            List<Language> langs = langsList;
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

    public static String getLangInput(int index, String languageId, String id, String name,
            String value) {
        return getLangInput(index, languageId, id, name, value, "", "");
    }

    public static String getLangClosedTagElements(List<Language> langsList, String element, String id, String name,
            String colName, Set rs,
            String className) {
        StringBuilder html = new StringBuilder();
        List<Language> langs = langsList;
        for (int i = 0; i < langs.size(); i++) {
            String languageId = langs.get(i).getLanguageId();
            html.append(
                    getLangClosedTagElement(
                            i,
                            element,
                            langs.get(i).getLanguageId(),
                            String.format(id, languageId),
                            String.format(name, languageId),
                            getRsValueForLang(rs, colName, languageId),
                            className));
        }
        return html.toString();
    }

    public static String getLangInput(int index, String languageId, String id, String name,
            String value,
            String className, String atributes) {
        StringBuilder html = new StringBuilder();
        if (name.contains("cat_desc_folder_name") || name.contains("page_path")) {
            html.append(
                    "<input type='text' onkeyup='onPathKeyup(this,true)' onblur='onPathBlur(this,true)' class='form-control ")
                    .append(className).append("' ")
                    .append("data-language-id='").append(languageId).append("' ");
        } else {
            html.append("<input type='text' class='form-control ").append(className).append("' ")
                    .append("data-language-id='").append(languageId).append("' ");
        }
        if (index == 0) {
            html.append("multilingual='true'");
        } else {
            html.append("style='display:none;'");
        }

        if (atributes.length() > 0) {
            html.append(" " + atributes + " ");
        }
        html.append("id='").append(id).append("'").append(" name='").append(name).append("' value='")
                .append(escapeCoteValue(value)).append("'>");

        return html.toString();
    }

    public static String getLangInput(int index, String languageId, String id, String name,
            String value,
            String className) {
        return getLangInput(index, languageId, id, name, value, className, "");
    }

    public static String getLangClosedTagElement(int index, String element, String languageId, String id, String name,
            String value, String className) {
        StringBuilder html = new StringBuilder();
        html.append("<").append(element)
                .append(" type='text' class='form-control ")
                .append(className).append("' ")
                .append("data-language-id='")
                .append(languageId).append("' ");

        if (index == 0) {
            html.append("multilingual='true'");
        } else {
            html.append("style='display:none;'");
        }
        html.append("id='").append(id).append("'")
                .append(" name='").append(name)
                .append("'>")
                .append(escapeCoteValue(value))
                .append("</")
                .append(element).append(">");

        return html.toString();
    }

    public static String getLangInputs(List<Language> langsList, String id, String name, String colName, Set rs) {
        return getLangInputs(langsList, id, name, colName, rs, "");
    }

    public static String getLangInputs(List<Language> langsList, String id, String name, String colName, Set rs,
            String className) {
        StringBuilder html = new StringBuilder();
        List<Language> langs = langsList;
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

    public static String getLangInputsRowWise(List<Language> langsList, String id, String name, String colName,
            Set rs) {
        return getLangInputsRowWise(langsList, id, name, colName, rs, "", "");
    }

    public static String getLangInputsRowWise(List<Language> langsList, String id, String name, String colName, Set rs,
            String className,
            String atributes) {
        StringBuilder html = new StringBuilder();
        List<Language> langs = langsList;
        for (int i = 0; i < langs.size(); i++) {
            String languageId = langs.get(i).getLanguageId();
            html.append(
                    getLangInput(
                            i,
                            langs.get(i).getLanguageId(),
                            String.format(id, languageId),
                            String.format(name, languageId),
                            getRsValueForLang(rs, colName, languageId),
                            className,
                            atributes));
        }
        return html.toString();
    }

    public static String getLangInputsRowWise(List<Language> langsList, String id, String name, String colName, Set rs,
            String className) {
        return getLangInputsRowWise(langsList, id, name, colName, rs, className, "");
    }

    public static String getLangCheckBoxRowWise(List<Language> langsList, String id, String name, String selectedVal,
            String colName, Set rs) {
        return getLangCheckBoxRowWise(langsList, id, name, selectedVal, colName, rs, "");
    }

    public static String getLangCheckBoxRowWise(List<Language> langsList, String id, String name, String selectedVal,
            String colName, Set rs,
            String className) {
        StringBuilder html = new StringBuilder();
        List<Language> langs = langsList;
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

    public static String getLangCheckBox(int index, String languageId, String id, String name,
            String selectedVal,
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

    public static String getLangTextArea(int index, String languageId, String id, String name,
            String value) {
        return getLangTextArea(index, languageId, id, name, value, "");
    }

    public static String getLangTextArea(int index, String languageId, String id, String name,
            String value,
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

    public static String getLangTextAreas(List<Language> langsList, String rows, String id, String name, String colName,
            Set rs) {
        return getLangTextAreas(langsList, rows, id, name, colName, rs, "");
    }

    public static String getLangTextAreas(List<Language> langsList, String rows, String id, String name, String colName,
            Set rs,
            String className) {
        StringBuilder html = new StringBuilder();
        List<Language> langs = langsList;
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

    public static String getLangTextAreasRowWise(List<Language> langsList, String id, String name, String colName,
            Set rs) {

        return getLangTextAreasRowWise(langsList, id, name, colName, rs, "");
    }

    public static String getLangTextAreasRowWise(List<Language> langsList, String id, String name, String colName,
            Set rs, String className) {
        StringBuilder html = new StringBuilder();
        List<Language> langs = langsList;
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

    public static String getLangSelectsRowWise(List<Language> langsList, String id, String name,
            List<KeyValuePair<String, String>> options,
            String cssClass, String attributes, String colName, Set rs) {
        StringBuilder html = new StringBuilder();
        List<Language> langs = langsList;
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

    public static String getLangSelectsRowWise(List<Language> langsList, String id, String name, String constantGroup,
            String parentKey,
            String cssClass, String attributes, String colName, Set rs) {
        StringBuilder html = new StringBuilder();
        List<Language> langs = langsList;
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
            String cssClass, String scripts, boolean multiple){
                return getSelectControl(id, name, map, svals, cssClass, scripts, multiple,false);
            } 

    public static String getSelectControl(String id, String name,
            java.util.Map<String, String> map, java.util.ArrayList svals,
            String cssClass, String scripts, boolean multiple, boolean isDisabled) {
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
        if (isDisabled) {
            html += " disabled ";
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

    public static boolean validatePass(String password) {
        String pattern = "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*])(?=.{12,})";
        Pattern r = Pattern.compile(pattern);
        Matcher m = r.matcher(password);
        if (m.find())
            return true;
        else
            return false;
    }
	
	public static String getWebappAuthToken(Contexte Etn, HttpServletRequest request)
	{
		String commonsdb = GlobalParm.getParm("COMMONS_DB");
		//lets clear expired ones
		Etn.executeCmd("delete from "+commonsdb+".webapps_auth_tokens where expiry < now() ");
		
		com.etn.lang.ResultSet.Set rs = Etn.execute("select * from login where pid = " + escape.cote(""+Etn.getId()));
        if(rs.next())
		{
			String accessid = parseNull(rs.value("access_id"));
			if (accessid.length() == 0) 
			{
				accessid = java.util.UUID.randomUUID().toString();
				Etn.executeCmd("update login set access_id = " + escape.cote(accessid) + " where pid = " + escape.cote(""+Etn.getId()));
			}
			
			String token = java.util.UUID.randomUUID().toString();
			int i = Etn.executeCmd("insert into "+commonsdb+".webapps_auth_tokens (id, expiry, access_id, catalog_session_id) value ("+escape.cote(token)+", adddate(now(), interval 5 minute), "+escape.cote(accessid)+", "+escape.cote(request.getSession().getId())+") ");
			if(i > 0)
			{
				return token;
			}
		}
		return "";
	}
}
