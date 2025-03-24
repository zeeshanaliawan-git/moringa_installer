<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape" %>
<%@page import="com.etn.sql.escape, java.io.BufferedReader,java.io.InputStreamReader,java.net.URL,javax.net.ssl.HttpsURLConnection, java.io.DataOutputStream, java.nio.charset.StandardCharsets, org.jsoup.nodes.Document, org.jsoup.Jsoup, org.jsoup.select.Elements,org.jsoup.nodes.Element, java.sql.*,org.json.*,java.util.regex.Pattern,java.util.regex.Matcher, com.etn.beans.Contexte, java.util.*, org.jsoup.nodes.Attributes, org.jsoup.nodes.Attribute" %>

<%!
    HashMap<Integer, String> dataToTranslate = new HashMap<Integer, String>();

    void requestYandex(HttpsURLConnection https, String data) throws Exception {

        byte[] postData = data.getBytes(StandardCharsets.UTF_8);
        try (DataOutputStream wr = new DataOutputStream(https.getOutputStream())) {
            wr.write(postData);
        }
    }

    String responseYandex(HttpsURLConnection https) throws Exception {
        BufferedReader br = null;
		try {
			if (https.getResponseCode() >= 200 && https.getResponseCode() <= 299) {
				br = new BufferedReader(new InputStreamReader((https.getInputStream()), StandardCharsets.UTF_8));
			}
			else {
				br = new BufferedReader(new InputStreamReader((https.getErrorStream()), StandardCharsets.UTF_8));
			}

			StringBuilder sb = new StringBuilder();
			String output;
			while ((output = br.readLine()) != null) {
				sb.append(output);
			}
		
			return sb.toString();
		} catch (Exception e) {
			throw e;
		} finally {
			if(br != null) {
				try {
					br.close();
				} catch (Exception e) {}
			}
		}
    }

    HttpsURLConnection getConnection(String urlStr) throws Exception {
        URL url = new URL(urlStr);

        HttpsURLConnection https = (HttpsURLConnection) url.openConnection();
        https.setDoInput(true);
        https.setDoOutput(true);
        https.setUseCaches(false);

        return https;
    }

    String yandexToken() throws Exception {
        String iamToken = null;
        String postData = "{\"yandexPassportOauthToken\":\"AQAAAABbx2QLAATuwZh07pKe00QEiD8NdiGVglA\"}";
        int postDataLength = postData.getBytes(StandardCharsets.UTF_8).length;

        HttpsURLConnection https = getConnection("https://iam.api.cloud.yandex.net/iam/v1/tokens");
        https.setRequestMethod("POST");
        https.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        requestYandex(https, postData);

        if (https.getResponseCode() == 200) {
            JSONObject tokenJSON = new JSONObject(responseYandex(https));
            iamToken = tokenJSON.getString("iamToken");
        }
        return iamToken;
    }

    String yandex(String token, String text, String targetLanguage) throws Exception {
        JSONObject postData = new JSONObject();
        postData.put("folderId", "b1gmp631qu7n80bbi6v7");
        postData.put("texts", new JSONArray());
        postData.getJSONArray("texts").put(text);
        postData.put("targetLanguageCode", targetLanguage);
        HttpsURLConnection https = getConnection("https://translate.api.cloud.yandex.net/translate/v2/translate");

        https.setRequestMethod("POST");
        https.setRequestProperty("Content-Type", "application/json");
        https.setRequestProperty("Authorization", "Bearer " + token);
        requestYandex(https, postData.toString());
        if (https.getResponseCode() == 200) {
            JSONObject json = new JSONObject(responseYandex(https));
            text = json.getJSONArray("translations").getJSONObject(0).getString("text");
        }
        return text;
    }

    boolean isNumeric(String strNum) {
	    if (strNum == null) {
	        return false;
	    }
	    try {
	        double d = Double.parseDouble(strNum);
	    } catch (NumberFormatException nfe) {
	        return false;
	    }
	    return true;
	}

    String translateHtml(String text, String lang) {
        int count = 1000;
        Map<Integer, String> tags = new HashMap<>();
        try {
            Document doc = Jsoup.parse(text);
            Elements elements = doc.getAllElements();

            for (Element ele : elements) {
				Elements elementsByTag = doc.getElementsByTag(ele.nodeName());
				for(Element e1:elementsByTag){
				    if(!isNumeric( ele.nodeName())) {
                        tags.put(count, e1.nodeName() + " " + e1.attributes());
                        Attributes at = e1.attributes();
                        for (Attribute a : at) {
                            e1.removeAttr(a.getKey());
                        }
                        e1.tagName(count + "");
                        count++;
                    }
                }
            }

            String token = yandexToken();

            if (token != null) {

                String translatedText = yandex(token, doc.toString(), lang);
                for (int i = 1000; i < tags.size() + 1000; i++) {
                    translatedText = translatedText.replaceAll(i+"", tags.get(i));
                }
                doc = Jsoup.parse(translatedText);
                text = doc.body().html();
            }

        }
        catch (Exception ex) {
            ex.printStackTrace();
        }
        return text;

    }


    boolean translateForm(String form_id, Contexte Etn) throws Exception {

        LinkedHashMap<String, String> langInfoMap = new LinkedHashMap<String, String>();

        String HTML_PATTERN = "<(\"[^\"]*\"|'[^']*'|[^'\">])*>";
        try {
            Pattern pattern = Pattern.compile(HTML_PATTERN);

            Set rsLang = Etn.execute("SELECT * FROM language ORDER BY langue_id asc");
			String defaultLangId = "";
			int i=0;
            while (rsLang.next()) {
				if(i++ == 0) 
				{
					defaultLangId = rsLang.value("langue_id");
				}
                else
				{
					langInfoMap.put(rsLang.value("langue_id"), rsLang.value("langue_code"));
				}
            }
            Set rsFields = Etn.execute("select d.label, d.field_id , d.value , f.type from process_form_field_descriptions_unpublished d, process_form_fields_unpublished f where f.field_id =d.field_id and f.form_id = d.form_id and f.form_id =" + escape.cote(form_id) + "and d.langue_id = "+escape.cote(defaultLangId));

            while (rsFields.next()) {
                String label = rsFields.value("label");
                String value = rsFields.value("value");
                for (String k : langInfoMap.keySet()) {
					String translation = "";
					String hyperLinkTranslation = value;
					Matcher matcher = pattern.matcher(label);
					if (matcher.find()) {
						translation = translateHtml(label, langInfoMap.get(k));
					}
					else {
						translation = yandex(yandexToken(), label, langInfoMap.get(k));
					}
					if(escape.cote(rsFields.value("type")).equals(escape.cote("hyperlink"))){
					    matcher = pattern.matcher(value);
					    if (matcher.find()) {
						    hyperLinkTranslation = translateHtml(value, langInfoMap.get(k));
                        }
                        else {
                            hyperLinkTranslation = yandex(yandexToken(), value, langInfoMap.get(k));
                        }
                    }
					Etn.executeCmd("INSERT INTO process_form_field_descriptions_unpublished (form_id,field_id,langue_id,label,value,options) "
									   + "VALUES (" + escape.cote(form_id) + ","
									   + escape.cote(rsFields.value("field_id")) + ","
									   + escape.cote(k) + ","
									   + escape.cote(translation) + ","
                                        + escape.cote(hyperLinkTranslation) + ","
									   + escape.cote(rsFields.value("options")) +
                                        ") ON DUPLICATE KEY UPDATE label =" + escape.cote(translation) +
                                        ", value=" + escape.cote(hyperLinkTranslation));

                }
            }
            return true;
        }catch (Exception ex) {
            return false;
        }
    }

%>
<%
    boolean resp=translateForm(request.getParameter("form_id"),Etn);
    out.write("{\"status\":"+resp+"}");
%>
