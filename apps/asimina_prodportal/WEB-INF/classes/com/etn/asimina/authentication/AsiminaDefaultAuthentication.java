/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.etn.asimina.authentication;

import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import org.json.JSONObject;
import java.util.Map;
import org.json.JSONException;

/**
 *
 * @author ABJ
 */
public class AsiminaDefaultAuthentication implements AsiminaAuthentication {

    private AsiminaAuthenticationHelper helper = null;
    private AsiminaDefaultAuthentication() {
    }

    public AsiminaDefaultAuthentication(Map<String, String> properties,AsiminaAuthenticationHelper helper) {
        this.helper = helper;
    }
    
    private String getPassword(String password,String clientUUID){
        String newPassword = escape.cote("");
        if(password != null && "".equals(password) == false){
           
            newPassword = "SHA2(" + escape.cote(this.helper.getClientPasswordSalt() + "#" + password+ "#" + clientUUID) + ",256)";
        }
        return newPassword;
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
            String sendEmail = "0";
            if (autoVerify) {
                sendEmail = "0";
                isVerified = "1";
            } else {
                sendEmail = "1";
            }
            ClientSql db = this.helper.getEtn();
            String clientUUID = java.util.UUID.randomUUID().toString();
            String query =
                "insert into " + helper.getTableName("clients")  + "(username,email,name,surname,mobile_number,pass,is_verified,client_uuid,created_date,site_id,send_verification_email, signup_menu_uuid, additional_info, avatar, civility) values( "
                    + escape.cote(userName) + "," + escape.cote(email) + "," + escape.cote(firstName)
                    + "," + escape.cote(lastName) + "," + escape.cote(mobileNumber) + "," + getPassword(password,clientUUID) + ","
                    + escape.cote(isVerified) + "," + escape.cote(clientUUID) + ",NOW()," + escape.cote(this.helper.getSiteId())
                    + "," + escape.cote(sendEmail) + "," + escape.cote(signupMenuUUID) + "," + escape.cote(additionalInfo)
                    + "," + escape.cote(avatar) + "," + escape.cote(gender) + ")";
            System.out.println("Query:" + query);
            int clientId = db.executeCmd(query);
            System.out.println("---- client id:" + clientId);
            if (clientId > 0) {
                JSONObject response = new JSONObject();
                response.put("client_id", String.valueOf(clientId));
                response.put("client_uuid", clientUUID);
                return new AsiminaAuthenticationResponse(true, response);
            } else {
                return new AsiminaAuthenticationResponse(false);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            return new AsiminaAuthenticationResponse(ex);
        }
    }

    @Override
    public AsiminaAuthenticationResponse getOrCreateUser(
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
        AsiminaAuthenticationResponse getUserResponse = getUser(userName);
        if (getUserResponse.isDone()) {
            return getUserResponse;
        } else {
            AsiminaAuthenticationResponse createUserResponse = createUser(userName, email, password, firstName, lastName, displayName, mobileNumber, isVerified, signupMenuUUID, additionalInfo, avatar, gender, birthDate, language, timeZone, true);
            if (createUserResponse.isDone()) {
                return getUser(userName);
            }
        }
        return new AsiminaAuthenticationResponse(false);
    }

    @Override
    public AsiminaAuthenticationResponse updateUser(
            String userName,
            String email,
            String firstName,
            String lastName,
            String displayName,
            String mobileNumber,
            String additionalInfo,
            String avatar,
            String gender,
            String birthDate,
            String language,
            String timeZone
    ) {
        try {
            ClientSql db = this.helper.getEtn();
            int updatedRows = db.executeCmd(
                    "update " + helper.getTableName("clients")  + " set email = " + escape.cote(email) + ",name = " + escape.cote(firstName)
                    + ",surname = " + escape.cote(lastName) + ",mobileNumber = " + escape.cote(mobileNumber)
                    + ",additional_info = " + escape.cote(additionalInfo) + ",avatar = " + escape.cote(avatar)
                    + ",civility = " + escape.cote(gender)
                    + " where username = " + escape.cote(userName) + " and site_id = " + escape.cote(this.helper.getSiteId())
            );
            if (updatedRows > 0) {
                return new AsiminaAuthenticationResponse(true);
            } else {
                return new AsiminaAuthenticationResponse(false);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            return new AsiminaAuthenticationResponse(ex);
        }
    }

    @Override
    public AsiminaAuthenticationResponse authenticate(String userName, String password) {
        try {
            return authenticateUser(userName, password);
        } catch (Exception ex) {
            ex.printStackTrace();
            return new AsiminaAuthenticationResponse(ex);
        }
    }

    private AsiminaAuthenticationResponse authenticateUser(String userName, String password)  throws JSONException{
   
		ClientSql db = this.helper.getEtn();
		Set rs = db.execute(
				"select is_verified,is_active from " + helper.getTableName("clients")  + " where username = " + escape.cote(userName)
				+ " and ( pass = SHA2(CONCAT(" + escape.cote(this.helper.getClientPasswordSalt()) + ",'#'," + escape.cote(password) + ",'#',client_uuid),256) or pass = md5(" + escape.cote(password) + ") )"
				+ " and site_id = " + escape.cote(this.helper.getSiteId())
		);
		if (rs != null && rs.next()) {
			if (rs.value("is_active").equals("0")) {
				return new AsiminaAuthenticationResponse(false, "Your account is not activated. Contact administrator", "");
			} else if (rs.value("is_verified").equals("0")) {
				return new AsiminaAuthenticationResponse(false, "Your account is not verified yet", "");
			} else {
				return this.getUser(userName);
			}
		}else{
            return new AsiminaAuthenticationResponse(false, "Wrong username or password entered", "");
        }        
    }

    @Override
    public AsiminaAuthenticationResponse getUser(String userName) {
        try {
            ClientSql db = this.helper.getEtn();
            String query
                    = "select * from " + helper.getTableName("clients")  + " where username = " + escape.cote(userName)
                    + " and site_id = " + escape.cote(this.helper.getSiteId());
            System.out.println("--get user query:" + query);
            Set rs = db.execute(query);
            if (rs != null && rs.next()) {
                System.out.println("--get user found:" + rs.value("id"));
                JSONObject response = new JSONObject();
                for (String col : rs.ColName) {
                    response.put(col.toLowerCase(), rs.value(col));
                }
                String isActive = rs.value("is_active");
                if("1".equals(isActive)){
                    response.put("status", "activated");
                }else if("0".equals(isActive)){
                    response.put("status", "deactivated");
                }
                return new AsiminaAuthenticationResponse(true, response);
            } else {
                return new AsiminaAuthenticationResponse(false);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            return new AsiminaAuthenticationResponse(ex);
        }
    }

    @Override
    public AsiminaAuthenticationResponse changePassword(String userName, String password, String newPassword) {
        try {
            AsiminaAuthenticationResponse response = authenticateUser(userName, password);
            if (response.isDone()) {
                String clientUUID = response.getHttpResponse().getString("client_uuid");                
                ClientSql db = this.helper.getEtn();
                int updatedRows = db.executeCmd(
                        "update " + helper.getTableName("clients")  + " set pass = " + getPassword(newPassword,clientUUID) 
                        + " where username = " + escape.cote(userName) + " and site_id = " + escape.cote(this.helper.getSiteId())
                );
                if (updatedRows > 0) {
                    return new AsiminaAuthenticationResponse(true);
                } else {
                    return new AsiminaAuthenticationResponse(false);
                }
            } else {
                return new AsiminaAuthenticationResponse(false);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            return new AsiminaAuthenticationResponse(ex);
        }
    }

    @Override
    public AsiminaAuthenticationResponse forceChangePassword(String userName, String newPassword) {
        try {
            System.out.println("---changing password");
            AsiminaAuthenticationResponse getUserResponse = this.getUser(userName);
            if(getUserResponse.isDone()){
                System.out.println("----user response is:" + getUserResponse.getHttpResponse().toString());
                String clientUUID = getUserResponse.getHttpResponse().getString("client_uuid");
                System.out.println("----client uuid is:" + clientUUID);
                if(clientUUID != null && "".equals(clientUUID) == false){
                    ClientSql db = this.helper.getEtn();
                    int updatedRows = db.executeCmd(
                        "update " + helper.getTableName("clients")  + " set pass = " + getPassword(newPassword,clientUUID) 
                        + " where username = " + escape.cote(userName) + " and site_id = " + escape.cote(this.helper.getSiteId())
                    );
                    System.out.println("updated rows:" + updatedRows);
                    if (updatedRows > 0) {                        
                        return new AsiminaAuthenticationResponse(true);
                    } else {
                        return new AsiminaAuthenticationResponse(false);
                    }
                }else{
                    return new AsiminaAuthenticationResponse(false, "Client uuid not present. Please contact administrator", "");
                }
            }else{
                return new AsiminaAuthenticationResponse(false, "Your account does not exist. Contact administrator", "");
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            return new AsiminaAuthenticationResponse(ex);
        }
    }
    
    private AsiminaAuthenticationResponse setActive(String userName,String active){
        try {
            ClientSql db = this.helper.getEtn();
            int updatedRows = db.executeCmd(
                    "update " + helper.getTableName("clients")  + " set is_active = " + escape.cote(active)
                    + " where username = " + escape.cote(userName) + " and site_id = " + escape.cote(this.helper.getSiteId())
            );
            if (updatedRows > 0) {
                return new AsiminaAuthenticationResponse(true);
            } else {
                return new AsiminaAuthenticationResponse(false);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            return new AsiminaAuthenticationResponse(ex);
        }
    }

    @Override
    public AsiminaAuthenticationResponse activate(String userName) {
        return setActive(userName,"1");
    }

    @Override
    public AsiminaAuthenticationResponse deactivate(String userName) {
        return setActive(userName,"0");
    }
}
