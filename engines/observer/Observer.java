
import java.io.*;
import java.net.URL;

import javax.mail.*;
import javax.mail.internet.*;
import java.util.*;
import java.util.Properties;
import java.util.stream.*;

import com.etn.lang.ResultSet.Set;
import com.etn.Client.Impl.ClientSql;
import com.etn.Client.Impl.ClientDedie;
import com.etn.sql.escape;
import com.etn.util.ItsDate;

public class Observer
{
    private Properties env;
    private ClientSql Etn;
    private String[] enginesList;
    String engineTime="";
    String engineNames="";

    public Observer() throws Exception
    {
        

        env = new Properties();
        env.load(new InputStreamReader( getClass().getResourceAsStream("Observer.conf") , "UTF-8" )) ;
        
        Etn = new ClientDedie(  "MySql", env.getProperty("CONNECT_DRIVER"), env.getProperty("CONNECT") );

        //load config from db
        Set rs = Etn.execute("SELECT code,val FROM config");
        while (rs.next()) 
        {
            env.setProperty(rs.value("code"), rs.value("val"));
        }
        
        enginesList=env.getProperty("OBSERVER_ENGINES").toUpperCase().split(",");
        engineTime=env.getProperty("OBSERVER_ENGINE_TIME_MINS");
    }

    private String parseNull(Object o)
    {
            if( o == null ) return("");
            String s = o.toString();
            if("null".equals(s.trim().toLowerCase())) return("");
            else return(s.trim());
    }

    public void run() {
        try{
            ObserverMail sm= new ObserverMail();
            String dbEnginesList[];
            java.util.Set<String> enginesSet = new HashSet<>(Arrays.asList(enginesList));

            Set rs =Etn.execute("select e.engine_name,e.start_date,e.end_date,TIMESTAMPDIFF(MINUTE,e.start_date,NOW()) >"+
                escape.cote(engineTime)+" as 'st',TIMESTAMPDIFF(MINUTE,e.end_date,NOW()) >"+
                escape.cote(engineTime)+" as 'et' from engines_status e");
            
            dbEnginesList = new String[rs.rs.Rows];
            
            int i=0;
            while(rs.next()){
                dbEnginesList[i]=rs.value("engine_name").toUpperCase();
                i++;
            }
            
            java.util.Set<String> dbEnginesSet = new HashSet<>(Arrays.asList(dbEnginesList));
            enginesSet.removeAll(dbEnginesSet);

            for(String engines : enginesSet){
                if(engineNames.length()>0){
                    engineNames+="<br>"+engines;
                }else{
                    engineNames=engines;
                }
            }
            rs =Etn.execute("select e.engine_name,e.start_date,e.end_date,TIMESTAMPDIFF(MINUTE,e.start_date,NOW()) >"+
                escape.cote(engineTime)+" as 'st',TIMESTAMPDIFF(MINUTE,e.end_date,NOW()) >"+
                escape.cote(engineTime)+" as 'et' from engines_status e");
            while(rs.next()){
                if(Arrays.asList(enginesList).contains(rs.value("engine_name").toUpperCase())){
                    
                    if((rs.value("end_date").length()<=0 && rs.value("st").equalsIgnoreCase("1"))||(rs.value("end_date").length()>0 && rs.value("et").equalsIgnoreCase("1"))){
                        if(engineNames.length()>0){
                            engineNames+="<br>"+rs.value("engine_name");
                        }else{
                            engineNames=rs.value("engine_name");
                        }
                    }
                }
            }
            
            if(engineNames.length()>0){
                sm.send(engineNames);
            }
        }
        catch (Exception ee) {
            ee.printStackTrace();
        }
    }

    public static void main(  String a[]) throws Exception
    {
        new Observer().run();
        
    }
        
}
