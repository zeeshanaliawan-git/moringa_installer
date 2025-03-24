/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.etn.asimina.authentication;

import java.io.IOException;
import org.json.JSONObject;

/**
 *
 * @author ABJ
 */
public interface AsiminaAuthentication {
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
    );
    
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
    ) ;
    
    public AsiminaAuthenticationResponse authenticate(
        String userName,
        String password
    );
    
    public AsiminaAuthenticationResponse getUser(
        String userName
    );
	
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
    );
    
    public AsiminaAuthenticationResponse changePassword(
        String userName,
        String password,
        String newPassword
    ) ;
    
    public AsiminaAuthenticationResponse forceChangePassword(
        String userName,
        String newPassword
    ) ;
    
    public AsiminaAuthenticationResponse activate(
        String userName
    );
    
    public AsiminaAuthenticationResponse deactivate(
        String userName
    );
    
   
}
