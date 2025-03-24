package com.etn.pages;


import com.etn.beans.Etn;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import freemarker.cache.StringTemplateLoader;
import freemarker.template.Configuration;
import freemarker.template.Template;
import freemarker.template.TemplateMethodModelEx;
import freemarker.template.TemplateModel;
import freemarker.template.TemplateModelException;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import java.util.*;

public class TranslateLang implements TemplateMethodModelEx{

    private String langId;
    private Etn Etn;
    private Map<String, String> langMap = new HashMap<String, String>();

    public TranslateLang(String langId,Etn Etn){
        this.langId=langId;
        this.Etn=Etn;
        Set rs = Etn.execute("select LANGUE_REF,LANGUE_"+langId + " as LANGUE from langue_msg");			
        while(rs.next())
        {
            langMap.put(com.etn.asimina.util.UrlHelper.removeAccents(rs.value("LANGUE_REF")).toUpperCase(),rs.value("LANGUE"));
        }
    }

    public String exec(List args) throws TemplateModelException {
        
        String lib="";

        if(args.size()==1){
            lib=args.get(0).toString();
        }
        
        String msg="";
        boolean voir = false;
        
        if(lib == null || lib.trim().length() == 0) return "";

        Map<String,String> h_msg = langMap;
        
        if(h_msg != null)
        {
            String lib2 = com.etn.asimina.util.UrlHelper.removeAccents(lib).toUpperCase().trim();
            if( h_msg.get(lib2)!=null)
            {
                if(! h_msg.get(lib2).toString().trim().equals(""))
                {
                    msg = h_msg.get(lib2).toString();
                }
                else
                {
                    msg =  lib;
                }
            }
            else
            {
                msg = lib;
                Etn.execute("insert IGNORE into langue_msg(LANGUE_REF) values("+ com.etn.sql.escape.cote(lib.trim())+")");
            }
        }
        else
        {
            msg = lib;
        }
        return(msg);
        
    }
    
}   
