/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.etn.asimina.authentication;

import java.io.PrintWriter;
import java.io.StringWriter;
import org.json.JSONObject;

/**
 *
 * @author ABJ
 */
public class AsiminaAuthenticationResponse {
    
    public AsiminaAuthenticationResponse(boolean done,JSONObject httpResponse){
        this.done = done;
        this.httpResponse = httpResponse;
    }
    
    public AsiminaAuthenticationResponse(boolean done){
        this.done = done;
    }
    
    public AsiminaAuthenticationResponse(boolean done,String message,String description){
        this.done = done;
        this.message = message;
        this.description = description;
    }
    
    public AsiminaAuthenticationResponse(Exception ex){
        this.done = false;
        this.message = ex.getMessage();
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);
        ex.printStackTrace(pw);
        this.description = pw.toString();
    }
    
    public AsiminaAuthenticationResponse(boolean done,int httpCode,JSONObject httpResponse,int errorCode,String message,String description){
        this.done = done;
        this.httpCode = httpCode;
        this.httpResponse = httpResponse;
        this.errorCode = errorCode;
        this.message = message;
        this.description = description;
    }
    
    private boolean done = false;

    private String message = null;

    private int httpCode = 0;

    private JSONObject httpResponse = null;

    private Exception exception = null;

    private int errorCode = 0;

    private String description;

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public int getErrorCode() {
        return errorCode;
    }

    public void setErrorCode(int errorCode) {
        this.errorCode = errorCode;
    }

    public Exception getException() {
        return exception;
    }

    public void setException(Exception exception) {
        this.exception = exception;
    }

    public JSONObject getHttpResponse() {
        return httpResponse;
    }

    public void setHttpResponse(JSONObject httpResponse) {
        this.httpResponse = httpResponse;
    }

    public int getHttpCode() {
        return httpCode;
    }

    public void setHttpCode(int httpCode) {
        this.httpCode = httpCode;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public boolean isDone() {
        return done;
    }

    public void setDone(boolean done) {
        this.done = done;
    }

}
