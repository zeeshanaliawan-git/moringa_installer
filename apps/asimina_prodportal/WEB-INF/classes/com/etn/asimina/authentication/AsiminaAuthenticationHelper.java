/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.etn.asimina.authentication;

import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import java.util.Map;
import java.util.HashMap;

/**
 *
 * @author ABJ
 */
public class AsiminaAuthenticationHelper {

    private ClientSql Etn = null;
    private String siteId = null;
    private String authenticationType = null;
    private Map<String, String> properties = null;
    private AsiminaAuthentication authenticationObject = null;
    private AsiminaAuthentication defaultAuthenticationObject = null;
    private String dbName = null;
    private String clientPasswordSalt = null;

    private AsiminaAuthenticationHelper() {
    }

    public AsiminaAuthenticationHelper(ClientSql Etn, String siteId,String clientPasswordSalt) {
        this.Etn = Etn;
        this.siteId = siteId;
        this.dbName = null;
        this.clientPasswordSalt = clientPasswordSalt;
        init();
    }
    
    public AsiminaAuthenticationHelper(ClientSql Etn, String siteId,String dbName,String clientPasswordSalt) {
        this.Etn = Etn;
        this.siteId = siteId;
        this.dbName = dbName;
        this.clientPasswordSalt = clientPasswordSalt;
        init();
    }
    
    public ClientSql getEtn(){
        return this.Etn;
    }
    
    public String getSiteId(){
        return this.siteId;
    }
    
    public String getClientPasswordSalt(){
        return this.clientPasswordSalt;
    }
    
    public String getTableName(String tableName){
        if(this.dbName != null){
            return dbName + "." + tableName;
        }
        return tableName;
    }

    private void init() {
        Set rs = Etn.execute("select authentication_type,orange_authentication_api_url,orange_token_api_url,orange_authorization_code from " + getTableName("sites")  + " where id = " + escape.cote(siteId));
        if (rs != null && rs.next()) {
            authenticationType = rs.value("authentication_type");
            properties = new HashMap<>();
            properties.put("orange_authentication_api_url", rs.value("orange_authentication_api_url"));
            properties.put("orange_token_api_url", rs.value("orange_token_api_url"));
            properties.put("orange_authorization_code", rs.value("orange_authorization_code"));
            authenticationObject = getAuthenticationObject(authenticationType, properties);
            defaultAuthenticationObject = getAuthenticationObject("default", properties);
        }
    }

    public AsiminaAuthentication getAuthenticationObject() {
        return authenticationObject;
    }

    public AsiminaAuthentication getDefaultAuthenticationObject() {
        return defaultAuthenticationObject;
    }

    public boolean isDefaultAuthentication() {
        return "default".equals(authenticationType);
    }

    /*
    public static final String ASIMINA_AUTHENTICATION_COOKIE = "asimina-authentication-cookie";
    public static final String SESSION_TIMEOUT = "30";
    
    public static String login(Contexte db, String authType,String userName,String password,String siteId){
        AsiminaAuthentication auth = getAuthenticationClass(authType);
        if(auth != null){
            AsiminaAuthenticationResponse resp = auth.authenticate(userName, password, siteId);
            if(resp.isDone()){
                String sessionId = (UUID.randomUUID().toString().replace("-", "") 
                                    + UUID.randomUUID().toString().replace("-", "")).substring(0, 50);
                int rows = db.executeCmd(
                    "insert into sessions(session_id,user_name,site_id,authentication_type,start_ts,end_ts,last_update_ts) " +
                    " values ("+ escape.cote(sessionId) + "," + escape.cote(userName) + "," + escape.cote(siteId) 
                    + "," + escape.cote(authType) + ",NOW(),DATE_ADD(now(),interval " + SESSION_TIMEOUT + " MINUTE),NOW())" 
                );
                if(rows > 0){
                    return sessionId;
                }else{
                    return null;
                }
            }
        }
        return null;
    }
    
    public static boolean isLogin(Contexte db,String sessionId,String siteId ){
        Set rs = db.execute("select 1 from sessions where session_id = " + escape.cote(sessionId) 
                + " and site_id = " + escape.cote(siteId) + " and end_ts > NOW() ");
        
        if(rs != null && rs.next()){
            db.execute("update sessions set end_ts = date_add(now(),interval " + SESSION_TIMEOUT + " minute),last_update_ts=now()" +
                        " where session_id = " + escape.cote(sessionId)
                );
            return true;
        }else{
            return false;
        }
    }*/
    private AsiminaAuthentication getAuthenticationObject(String authType, Map<String, String> properties) {
        if ("default".equals(authType)) {
            return new AsiminaDefaultAuthentication(properties,this);
        } else if ("orange".equals(authType)) {
            return new OrangeAuthentication(properties,this);
        }
        return null;
    }
}
