/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.etn.asimina.authentication;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPatch;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.NameValuePair;
import org.apache.http.client.methods.HttpEntityEnclosingRequestBase;
import org.apache.http.client.methods.HttpRequestBase;
import org.apache.http.entity.StringEntity;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 *
 * @author ABJ
 */
public class OrangeAuthentication implements AsiminaAuthentication {

    Map<String, String> properties = null;

    private OrangeAuthentication() {
    }

    public OrangeAuthentication(Map<String, String> properties,AsiminaAuthenticationHelper helper) {
        this.properties = properties;
    }

    public String getProperty(String key) {
        if (properties != null) {
            return properties.get(key);
        }
        return null;
    }

    private JSONObject getJSONResponse(CloseableHttpResponse httpResponse) throws IOException, JSONException {
        String json = getJSONString(httpResponse);
        if (json != null) {            
            System.out.println("json is: " + json);
            if (json.length() > 0) {
                return new JSONObject(json);
            }
        }
        return null;
    }
    
    private String getString(JSONObject obj,String key) throws JSONException{
        if(obj != null && obj.has(key)){
            return obj.getString(key);
        }
        return "";
    }
    
    private JSONArray getJSONArray(CloseableHttpResponse httpResponse) throws IOException, JSONException {
        String json = getJSONString(httpResponse);
        if (json != null) {            
            System.out.println("json is: " + json);
            if (json.length() > 0) {
                return new JSONArray(json);
            }
        }
        return null;
    }
    
    private String getJSONString(CloseableHttpResponse httpResponse) throws IOException, JSONException {
        if (httpResponse.getEntity() != null && httpResponse.getEntity().getContent() != null) {
            StringBuilder json = new StringBuilder();
            BufferedReader reader = new BufferedReader(new InputStreamReader(httpResponse.getEntity().getContent(), Charset.forName("UTF-8")));
            String inputLine;
            while ((inputLine = reader.readLine()) != null) {
                json.append(inputLine);
            }
            reader.close();
            return json.toString();
        }
        return null;
    }
    private String getToken() throws IOException, AsiminaAuthenticationException, JSONException {
        String apiUrl = getProperty("orange_token_api_url");
        String authenticationToken = getProperty("orange_authorization_code");
        if (apiUrl != null && authenticationToken != null) {
            CloseableHttpClient httpClient = HttpClients.createDefault();
            HttpPost httpPost = new HttpPost(apiUrl);
            List<NameValuePair> params = new ArrayList<>();
            params.add(new BasicNameValuePair("grant_type", "client_credentials"));
            httpPost.setEntity(new UrlEncodedFormEntity(params, Charset.forName("UTF-8")));
            httpPost.setHeader("Authorization", "Basic " + authenticationToken);
            CloseableHttpResponse httpResponse = httpClient.execute(httpPost);
            int responseCode = httpResponse.getStatusLine().getStatusCode();
            JSONObject jsonResponse = getJSONResponse(httpResponse);
            httpClient.close();
            if (jsonResponse != null) {
                if (responseCode == 200 && jsonResponse != null) {
                    return jsonResponse.getString("access_token");
                } else {
                    throw new AsiminaAuthenticationException(new AsiminaAuthenticationResponse(false, responseCode, jsonResponse, responseCode, jsonResponse.getString("error"), jsonResponse.getString("error_description")));
                }
            } else {
                throw new AsiminaAuthenticationException(new AsiminaAuthenticationResponse(false, responseCode, jsonResponse, responseCode, "", ""));
            }
        } else {
            throw new AsiminaAuthenticationException(new AsiminaAuthenticationResponse(false, "Invalid configuration. Orange API URL not defined or auth token not defined", ""));
        }
    }

    private JSONObject getProfileJSON(String firstName, String lastName, String displayName, String birthDate, String language, String timeZone) throws JSONException {
        return new JSONObject()
                .put("civility", "1")
                .put("firstName", firstName)
                .put("lastName", lastName)
                .put("displayName", displayName)
                .put("birthdate", birthDate)
                .put("language", language)
                .put("timeZone", timeZone);
    }

    private JSONObject getUserJSON(String userName, String email, String password, String firstName, String lastName, String displayName, String birthDate, String language, String timeZone,String mobileNumber) throws JSONException {
        JSONObject user = new JSONObject();
        user.put("identifiers", new JSONArray()
                .put(new JSONObject()
                        .put("value", userName)
                        .put("type", "LOGIN")
                )
        );
        user.put("password", new JSONObject().put("value", password));
        user.put("profile", getProfileJSON(firstName, lastName, displayName, birthDate, language, timeZone));

        
        JSONArray contactIdentifiers = new JSONArray();
        if(email != null && email.length() > 0){
            contactIdentifiers.put(new JSONObject()
                        .put("value", email)
                        .put("type", "email")
                );
        }
        
        if(mobileNumber != null && mobileNumber.length() > 0){
            contactIdentifiers.put(new JSONObject()
                        .put("value", mobileNumber)
                        .put("type", "mobile")
                );
        }
        
        if(contactIdentifiers.length() > 0){
            user.put("contactIdentifiers", contactIdentifiers);
        }
           
        return user;
    }

    @Override
    public AsiminaAuthenticationResponse getUser(String userName) {
        try {
            String token = getToken();
            if (token != null) {
                JSONObject userData = getUserObject(token, userName);                
                if (userData != null) {
                    return new AsiminaAuthenticationResponse(true, getUserProfile(token, userData));
                }
            }
            return new AsiminaAuthenticationResponse(false);
        } catch (AsiminaAuthenticationException ex) {
            return ex.getResponse();
        } catch (IOException | JSONException ex) {
            ex.printStackTrace();
            return new AsiminaAuthenticationResponse(ex);
        }
    }
    
    private JSONArray getUserIdentifiers(String token, String userId) throws IOException, AsiminaAuthenticationException, JSONException {
        String url = getProperty("orange_authentication_api_url");
        if (url != null) {
            url += "/identities/"
                    + URLEncoder.encode(userId, StandardCharsets.UTF_8.toString())
                    + "/identifiers";
            CloseableHttpClient httpClient = HttpClients.createDefault();
            HttpGet httpGet = new HttpGet(url);
            httpGet.setHeader("Authorization", "Bearer " + token);
            httpGet.setHeader("Accept", "application/json");
            CloseableHttpResponse httpResponse = httpClient.execute(httpGet);
            int httpCode = httpResponse.getStatusLine().getStatusCode();
            String json = getJSONString(httpResponse);
            httpClient.close();
            if (httpCode == 200) {
                return new JSONArray(json);
            }else{
                if(json != null && json.length() > 0){
                    JSONObject jsonResponse = new JSONObject(json);
                    throw new AsiminaAuthenticationException(new AsiminaAuthenticationResponse(false, httpCode, jsonResponse, jsonResponse.getInt("code"), jsonResponse.getString("message"), jsonResponse.getString("description")));
                }else{
                    throw new AsiminaAuthenticationException(new AsiminaAuthenticationResponse(false, httpCode, null, httpCode, "", ""));
                }
            }
        }else {
            throw new AsiminaAuthenticationException(new AsiminaAuthenticationResponse(false, "Invalid configuration. Orange API URL not defined", ""));
        }
    }
    
    private JSONObject getContactIndetifier(String token,String userId,String type)throws IOException, AsiminaAuthenticationException, JSONException {
        String url = getProperty("orange_authentication_api_url");
        if (url != null) {
            url += "/identities/"
                    + URLEncoder.encode(userId, StandardCharsets.UTF_8.toString())
                    + "/contactIdentifiers/" + type;
            
            CloseableHttpClient httpClient = HttpClients.createDefault();
            HttpGet httpGet = new HttpGet(url);
            httpGet.setHeader("Authorization", "Bearer " + token);
            httpGet.setHeader("Accept", "application/json");
            CloseableHttpResponse httpResponse = httpClient.execute(httpGet);
            int httpCode = httpResponse.getStatusLine().getStatusCode();
            String json = getJSONString(httpResponse);
            System.out.println("json for mobile is:" + json);
            httpClient.close();
            if (httpCode == 200) {
                if(json != null && json.length() > 0){
                    return new JSONObject(json);
                }else{
                    return null;
                }
            }else{
                return null;
            }
        }else {
            return null;
        }
    }
    
    private JSONObject getUserProfile(String token,JSONObject userData)throws IOException, AsiminaAuthenticationException, JSONException {
        JSONArray identifiers = getUserIdentifiers(token, userData.getString("id"));
        JSONObject profile = getUserProfileOnly(token,userData.getString("id"));
        JSONObject mobile = getContactIndetifier(token, userData.getString("id"),"mobile");
        if(identifiers != null && profile != null){
            String isActive = "1";
            if("activated".equals(userData.getString("status"))){
                isActive = "1";
            }else if("deactivated".equals(userData.getString("status"))){
                isActive = "0";
            }
            JSONObject response = new JSONObject();
            response.put("username", identifiers.getJSONObject(0).getString("value"));
            response.put("orange_id", userData.getString("id"));
            response.put("status",userData.getString("status"));
            response.put("email",getString(profile,("email")));
            response.put("mobile_number",getString(mobile,("mobile")));
            response.put("name",getString(profile,"firstName"));
            response.put("surname",getString(profile,"lastName"));
            response.put("display_name",getString(profile,"displayName"));
            response.put("language",getString(profile,"language"));
            response.put("time_zone",getString(profile,"timeZone")); 
            response.put("birthdate", getString(profile,"birthdate"));
            response.put("is_verified", "1");
            response.put("is_active",isActive);
            return response;
        }
        return null;
    }

    private JSONObject getUserProfileOnly(String token, String userId) throws IOException, AsiminaAuthenticationException, JSONException {
        String url = getProperty("orange_authentication_api_url");
        if (url != null) {
            url += "/identities/"
                    + URLEncoder.encode(userId, StandardCharsets.UTF_8.toString())
                    + "/profile?info=civility,firstName,lastName,displayName,birthdate,language,timeZone,email,mobile";
            CloseableHttpClient httpClient = HttpClients.createDefault();
            HttpGet httpGet = new HttpGet(url);
            httpGet.setHeader("Authorization", "Bearer " + token);
            httpGet.setHeader("Accept", "application/json");
            CloseableHttpResponse httpResponse = httpClient.execute(httpGet);
            int httpCode = httpResponse.getStatusLine().getStatusCode();
            JSONObject jsonResponse = getJSONResponse(httpResponse);
            httpClient.close();
            if (jsonResponse != null) {
                if (httpCode == 200) {
                    return jsonResponse;
                } else {
                    throw new AsiminaAuthenticationException(new AsiminaAuthenticationResponse(false, httpCode, jsonResponse, jsonResponse.getInt("code"), jsonResponse.getString("message"), jsonResponse.getString("description")));
                }
            } else {
                throw new AsiminaAuthenticationException(new AsiminaAuthenticationResponse(false, httpCode, jsonResponse, httpCode, "", ""));
            }
        } else {
            throw new AsiminaAuthenticationException(new AsiminaAuthenticationResponse(false, "Invalid configuration. Orange API URL not defined", ""));
        }
    }
    
    
    
    public JSONObject getUserObject(String token, String userName) throws IOException, AsiminaAuthenticationException, JSONException {
        String url = getProperty("orange_authentication_api_url");
        if (url != null) {
            url += "/identities?login=" + userName;
            CloseableHttpClient httpClient = HttpClients.createDefault();
            HttpGet httpGet = new HttpGet(url);
            httpGet.setHeader("Authorization", "Bearer " + token);
            httpGet.setHeader("Accept", "application/json");
            CloseableHttpResponse httpResponse = httpClient.execute(httpGet);
            JSONObject jsonResponse = getJSONResponse(httpResponse);
            int httpCode = httpResponse.getStatusLine().getStatusCode();
            httpClient.close();
            if (jsonResponse != null) {
                if (httpCode == 200) {                    
                    return jsonResponse;
                } else {
                    throw new AsiminaAuthenticationException(new AsiminaAuthenticationResponse(false, httpCode, jsonResponse, jsonResponse.getInt("code"), jsonResponse.getString("message"), jsonResponse.getString("description")));
                }
            } else {
                throw new AsiminaAuthenticationException(new AsiminaAuthenticationResponse(false, httpCode, jsonResponse, httpCode, "", ""));
            }
        } else {
            throw new AsiminaAuthenticationException(new AsiminaAuthenticationResponse(false, "Invalid configuration. Orange API URL not defined", ""));
        }
    }
    
    
    public String getUserId(String token, String userName) throws IOException, AsiminaAuthenticationException, JSONException {
        String url = getProperty("orange_authentication_api_url");
        if (url != null) {
            url += "/identities?login=" + userName;
            CloseableHttpClient httpClient = HttpClients.createDefault();
            HttpGet httpGet = new HttpGet(url);
            httpGet.setHeader("Authorization", "Bearer " + token);
            httpGet.setHeader("Accept", "application/json");
            CloseableHttpResponse httpResponse = httpClient.execute(httpGet);
            JSONObject jsonResponse = getJSONResponse(httpResponse);
            int httpCode = httpResponse.getStatusLine().getStatusCode();
            httpClient.close();
            if (jsonResponse != null) {
                if (httpCode == 200) {
                    return jsonResponse.getString("id");
                } else {
                    throw new AsiminaAuthenticationException(new AsiminaAuthenticationResponse(false, httpCode, jsonResponse, jsonResponse.getInt("code"), jsonResponse.getString("message"), jsonResponse.getString("description")));
                }
            } else {
                throw new AsiminaAuthenticationException(new AsiminaAuthenticationResponse(false, httpCode, jsonResponse, httpCode, "", ""));
            }
        } else {
            throw new AsiminaAuthenticationException(new AsiminaAuthenticationResponse(false, "Invalid configuration. Orange API URL not defined", ""));
        }
    }

    @Override
    public AsiminaAuthenticationResponse createUser(
            String userName,
            String email,
            String password,
            String firstName,
            String lastName,
            String displayName,
            String mobileNumber,
            String isVerified,
            String signupMenuUUID,
            String additionalInfo,
            String avatar,
            String gender,
            String birthDate,
            String language,
            String timeZone,
            boolean autoVerify
    ) {
        try {
            if (userName == null || "".equals(userName)) {
                userName = email;
            }
            String url = getProperty("orange_authentication_api_url");
            if (url != null) {
                JSONObject user = getUserJSON(userName, email, password, firstName, lastName, displayName, birthDate, language, timeZone,mobileNumber);
                String token = getToken();
                if (token != null) {
                    CloseableHttpClient httpClient = HttpClients.createDefault();
                    HttpPost httpPost = new HttpPost(url + "/identities");
                    httpPost.setEntity(new StringEntity(user.toString()));
                    httpPost.setHeader("Authorization", "Bearer " + token);
                    httpPost.setHeader("Content-type", "application/json");
                    httpPost.setHeader("Accept", "application/json");
                    CloseableHttpResponse httpResponse = httpClient.execute(httpPost);
                    int httpCode = httpResponse.getStatusLine().getStatusCode();
                    JSONObject jsonResponse = getJSONResponse(httpResponse);
                    httpClient.close();
                    if (httpCode == 201) {
                        return new AsiminaAuthenticationResponse(true);
                    } else {
                        if (jsonResponse != null) {
                            return new AsiminaAuthenticationResponse(false, httpCode, jsonResponse, jsonResponse.getInt("code"), jsonResponse.getString("message"), jsonResponse.getString("description"));
                        } else {
                            return new AsiminaAuthenticationResponse(false, httpCode, jsonResponse, httpCode, "", "");
                        }
                    }
                }
                return new AsiminaAuthenticationResponse(false);
            } else {
                return new AsiminaAuthenticationResponse(false, "Invalid configuration. Orange API URL not defined", "");
            }
        } catch (AsiminaAuthenticationException ex) {
            return ex.getResponse();
        } catch (IOException | JSONException ex) {
            ex.printStackTrace();
            return new AsiminaAuthenticationResponse(ex);
        }
    }

    @Override
    public AsiminaAuthenticationResponse authenticate(String userName, String password) {
        try {
            String token = getToken();
            return new AsiminaAuthenticationResponse(authenticateWithToken(userName, password, token));
        } catch (AsiminaAuthenticationException ex) {
            return ex.getResponse();
        } catch (IOException | JSONException ex) {
            ex.printStackTrace();
            return new AsiminaAuthenticationResponse(ex);
        }
    }

    public boolean authenticateWithToken(String userName, String password, String token) throws IOException, AsiminaAuthenticationException, JSONException {
        String url = getProperty("orange_authentication_api_url");
        if (url != null) {
            if (token != null) {
                CloseableHttpClient httpClient = HttpClients.createDefault();
                HttpPost httpPost = new HttpPost(url + "/authenticate");
                httpPost.setHeader("Authorization", "Bearer " + token);
                httpPost.setHeader("Content-type", "application/x-www-form-urlencoded");
                httpPost.setHeader("Accept", "application/json");
                List<NameValuePair> params = new ArrayList<>();
                params.add(new BasicNameValuePair("login", userName));
                params.add(new BasicNameValuePair("password", password));
                params.add(new BasicNameValuePair("responseType", "200"));
                httpPost.setEntity(new UrlEncodedFormEntity(params));
                CloseableHttpResponse httpResponse = httpClient.execute(httpPost);
                int httpCode = httpResponse.getStatusLine().getStatusCode();
                httpClient.close();
                if (httpCode == 200) {
                    return true;
                } else {
                    JSONObject jsonResponse = getJSONResponse(httpResponse);
                    if (jsonResponse != null) {
                        throw new AsiminaAuthenticationException(new AsiminaAuthenticationResponse(false, httpCode, jsonResponse, jsonResponse.getInt("code"), jsonResponse.getString("message"), jsonResponse.getString("description")));
                    } else {
                        throw new AsiminaAuthenticationException(new AsiminaAuthenticationResponse(false, httpCode, jsonResponse, httpCode, "", ""));
                    }
                }
            }
            return false;
        } else {
            throw new AsiminaAuthenticationException(new AsiminaAuthenticationResponse(false, "Invalid configuration. Orange API URL not defined", ""));
        }
    }

    @Override
    public AsiminaAuthenticationResponse forceChangePassword(String userName, String newPassword) {
        try {
            String url = getProperty("orange_authentication_api_url");
            if (url != null) {
                String token = getToken();
                String userId = getUserId(token, userName);
                if (userId != null) {
                    url += "/identities/"
                            + URLEncoder.encode(userId, StandardCharsets.UTF_8.toString())
                            + "/password";

                    CloseableHttpClient httpClient = HttpClients.createDefault();
                    HttpPatch httpPatch = new HttpPatch(url);
                    JSONObject passwordObj = new JSONObject().put("password", new JSONObject().put("value", newPassword));
                    httpPatch.setEntity(new StringEntity(passwordObj.toString()));
                    httpPatch.setHeader("Authorization", "Bearer " + token);
                    httpPatch.setHeader("Content-type", "application/json");
                    httpPatch.setHeader("Accept", "application/json");
                    CloseableHttpResponse httpResponse = httpClient.execute(httpPatch);
                    int httpCode = httpResponse.getStatusLine().getStatusCode();
                    JSONObject jsonResponse = getJSONResponse(httpResponse);
                    if (httpCode == 204) {
                        return new AsiminaAuthenticationResponse(true);
                    } else {
                        if (jsonResponse != null) {
                            return new AsiminaAuthenticationResponse(false, httpCode, jsonResponse, jsonResponse.getInt("code"), jsonResponse.getString("message"), jsonResponse.getString("description"));
                        } else {
                            return new AsiminaAuthenticationResponse(false, httpCode, jsonResponse, httpCode, "", "");
                        }
                    }
                }
                return new AsiminaAuthenticationResponse(false);
            } else {
                return new AsiminaAuthenticationResponse(false, "Invalid configuration. Orange API URL not defined", "");
            }
        } catch (AsiminaAuthenticationException ex) {
            return ex.getResponse();
        } catch (IOException | JSONException ex) {
            ex.printStackTrace();
            return new AsiminaAuthenticationResponse(ex);
        }
    }

    @Override
    public AsiminaAuthenticationResponse changePassword(String userName, String password, String newPassword) {
        try {
            String url = getProperty("orange_authentication_api_url");
            if (url != null) {
                String token = getToken();
                if (authenticateWithToken(userName, password, token)) {
                    String userId = getUserId(token, userName);
                    if (userId != null) {
                        url += "/identities/"
                                + URLEncoder.encode(userId, StandardCharsets.UTF_8.toString())
                                + "/password";

                        CloseableHttpClient httpClient = HttpClients.createDefault();
                        HttpPatch httpPatch = new HttpPatch(url);
                        JSONObject passwordObj = new JSONObject().put("password", new JSONObject().put("value", newPassword));
                        httpPatch.setEntity(new StringEntity(passwordObj.toString()));
                        httpPatch.setHeader("Authorization", "Bearer " + token);
                        httpPatch.setHeader("Content-type", "application/json");
                        httpPatch.setHeader("Accept", "application/json");
                        CloseableHttpResponse httpResponse = httpClient.execute(httpPatch);
                        int httpCode = httpResponse.getStatusLine().getStatusCode();
                        JSONObject jsonResponse = getJSONResponse(httpResponse);
                        if (httpCode == 204) {
                            return new AsiminaAuthenticationResponse(true);
                        } else {
                            if (jsonResponse != null) {
                                return new AsiminaAuthenticationResponse(false, httpCode, jsonResponse, jsonResponse.getInt("code"), jsonResponse.getString("message"), jsonResponse.getString("description"));
                            } else {
                                return new AsiminaAuthenticationResponse(false, httpCode, jsonResponse, httpCode, "", "");
                            }
                        }
                    }
                }
                return new AsiminaAuthenticationResponse(false);
            } else {
                return new AsiminaAuthenticationResponse(false, "Invalid configuration. Orange API URL not defined", "");
            }
        } catch (AsiminaAuthenticationException ex) {
            return ex.getResponse();
        } catch (IOException | JSONException ex) {
            ex.printStackTrace();
            return new AsiminaAuthenticationResponse(ex);
        }
    }

    private void updateContactIdentifier(String url,String token,String userId,String type,String value) throws JSONException,UnsupportedEncodingException,IOException,AsiminaAuthenticationException{
        
        
        
        
        JSONObject contactData = getContactIndetifier(token, userId, type);
        HttpEntityEnclosingRequestBase method = null; 
        JSONArray contactIdentifiers = new JSONArray();
        if(contactData != null){            
            String newUrl = url + "/identities/"
                    + URLEncoder.encode(userId, StandardCharsets.UTF_8.toString())
                    + "/contactIdentifiers/" + type;
            method = new HttpPatch(newUrl);
            contactIdentifiers.put(new JSONObject().put("value",value).put("isPassword",false));
        }else{            
            String newUrl = url + "/identities/"
                    + URLEncoder.encode(userId, StandardCharsets.UTF_8.toString())
                    + "/contactIdentifiers";
            method = new HttpPost(newUrl);
            contactIdentifiers.put(new JSONObject().put("value",value).put("isPassword",false).put("type",type));
        }
        CloseableHttpClient httpClient = HttpClients.createDefault();
        method.setEntity(new StringEntity(new JSONObject().put("contactIdentifiers",contactIdentifiers).toString()));
        method.setHeader("Authorization", "Bearer " + token);
        method.setHeader("Content-type", "application/json");
        method.setHeader("Accept", "application/json");
        CloseableHttpResponse httpResponse = httpClient.execute(method);
        int httpCode = httpResponse.getStatusLine().getStatusCode();
        JSONObject jsonResponse = getJSONResponse(httpResponse);
    }
    
    @Override
    public AsiminaAuthenticationResponse updateUser(String userName, String email, String firstName, String lastName, String displayName, String mobileNumber, String additionalInfo, String avatar, String gender, String birthDate, String language, String timeZone) {
        try {
            String url = getProperty("orange_authentication_api_url");
            if (url != null) {
                String token = getToken();
                String userId = getUserId(token, userName);
                if (userId != null) {
                    updateContactIdentifier(url, token, userId, "email", email);
                    updateContactIdentifier(url, token, userId, "mobile", mobileNumber);
                    
                    url += "/identities/"
                            + URLEncoder.encode(userId, StandardCharsets.UTF_8.toString())
                            + "/profile";

                    CloseableHttpClient httpClient = HttpClients.createDefault();
                    HttpPatch httpPatch = new HttpPatch(url);
                    JSONObject passwordObj = new JSONObject().put("profile", getProfileJSON(firstName, lastName, displayName, birthDate, language, timeZone));
                    httpPatch.setEntity(new StringEntity(passwordObj.toString()));
                    httpPatch.setHeader("Authorization", "Bearer " + token);
                    httpPatch.setHeader("Content-type", "application/json");
                    httpPatch.setHeader("Accept", "application/json");
                    CloseableHttpResponse httpResponse = httpClient.execute(httpPatch);
                    int httpCode = httpResponse.getStatusLine().getStatusCode();
                    JSONObject jsonResponse = getJSONResponse(httpResponse);
                    if (httpCode == 204) {
                        return new AsiminaAuthenticationResponse(true);
                    } else {
                        if (jsonResponse != null) {
                            return new AsiminaAuthenticationResponse(false, httpCode, jsonResponse, jsonResponse.getInt("code"), jsonResponse.getString("message"), jsonResponse.getString("description"));
                        } else {
                            return new AsiminaAuthenticationResponse(false, httpCode, jsonResponse, httpCode, "", "");
                        }
                    }
                }
                return new AsiminaAuthenticationResponse(false);
            } else {
                return new AsiminaAuthenticationResponse(false, "Invalid configuration. Orange API URL not defined", "");
            }
        } catch (AsiminaAuthenticationException ex) {
            return ex.getResponse();
        } catch (IOException | JSONException ex) {
            ex.printStackTrace();
            return new AsiminaAuthenticationResponse(ex);
        }
    }

    @Override
    public AsiminaAuthenticationResponse getOrCreateUser(String userName, String email, String password, String firstName, String lastName, String displayName, String mobileNumber, String isVerified, String signupMenuUUID, String additionalInfo, String avatar, String gender, String birthDate, String language, String timeZone, boolean autoVerify) {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    
    private AsiminaAuthenticationResponse setActive(String userName,String active){        
        try {            
            String token = getToken();
            if (token != null) {
                String userId = getUserId(token, userName);
                if (userId != null) {
                    String url = getProperty("orange_authentication_api_url");
                    if (url != null) {
                        url += "/identities/" + URLEncoder.encode(userId, StandardCharsets.UTF_8.toString());
                        CloseableHttpClient httpClient = HttpClients.createDefault();
                        HttpPatch httpPatch = new HttpPatch(url);
                        JSONObject statusObj = new JSONObject().put("status",active );
                        httpPatch.setEntity(new StringEntity(statusObj.toString()));
                        httpPatch.setHeader("Authorization", "Bearer " + token);
                        httpPatch.setHeader("Content-type", "application/json");
                        httpPatch.setHeader("Accept", "application/json");
                        CloseableHttpResponse httpResponse = httpClient.execute(httpPatch);
                        int httpCode = httpResponse.getStatusLine().getStatusCode();
                        JSONObject jsonResponse = getJSONResponse(httpResponse);
                        if (httpCode == 204) {
                            return new AsiminaAuthenticationResponse(true);
                        } else {
                            if (jsonResponse != null) {
                                return new AsiminaAuthenticationResponse(false, httpCode, jsonResponse, jsonResponse.getInt("code"), jsonResponse.getString("message"), jsonResponse.getString("description"));
                            } else {
                                return new AsiminaAuthenticationResponse(false, httpCode, jsonResponse, httpCode, "", "");
                            }
                        }
                    }
                }
            }
            return new AsiminaAuthenticationResponse(false);
        } catch (AsiminaAuthenticationException ex) {
            return ex.getResponse();
        } catch (IOException | JSONException ex) {
            ex.printStackTrace();
            return new AsiminaAuthenticationResponse(ex);
        }
    }
    
    @Override
    public AsiminaAuthenticationResponse activate(String userName) {
        return setActive(userName,"activated");
    }

    @Override
    public AsiminaAuthenticationResponse deactivate(String userName) {
        return setActive(userName,"deactivated");
    }
}
