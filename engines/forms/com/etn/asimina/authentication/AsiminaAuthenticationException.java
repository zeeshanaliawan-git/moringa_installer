/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.etn.asimina.authentication;

/**
 *
 * @author ABJ
 */
public class AsiminaAuthenticationException extends Exception{
    AsiminaAuthenticationResponse response = null;
    public AsiminaAuthenticationException(AsiminaAuthenticationResponse response){
       super(response.getMessage());
       this.response = response;
   }
   public AsiminaAuthenticationResponse getResponse(){
       return response;
   }
}
