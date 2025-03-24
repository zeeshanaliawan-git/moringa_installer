package com.etn.pages;

import com.etn.Client.Impl.ClientDedieEtn;
import com.etn.beans.Etn;
import com.etn.beans.app.GlobalParm;
import com.etn.lang.ResultSet.Set;
import com.etn.util.ItsDate;

import java.io.File;
import java.io.FileReader;
import java.io.InputStreamReader;
import java.util.Map;
import java.util.Properties;

/**
 * Engine for the Asimina : pages module
 * To perform frequent and automatic tasks related to pages module
 * for example: generating and publishing scheduled pages, updating RSS feeds, etc
 *
 * @author Ali Adnan
 * @since 2019-04-01
 */
public class SchedulerImportExport {

    protected Properties env;
    protected Etn Etn;
    protected boolean stop = false;

    protected final int wait_timeout;
    protected final boolean debug;
    protected final String semaphore;

    public static final String PAGE_TYPE_FREEMARKER = "freemarker";
    public static final String PAGE_TYPE_REACT = "react";
    public static final String PAGE_TYPE_STRUCTURED = "structured";

    public SchedulerImportExport(String parm[]) throws Exception {
        env = new Properties();

        boolean envLoaded = false;
        if (parm.length > 0) {
            File confFile = new File(parm[0]);
            if (confFile.exists() && confFile.isFile()) {
                env.load(new FileReader(confFile));
                envLoaded = true;
            }
        }

        if (!envLoaded) {
            throw new Exception("Error: No .conf file provided!!");
        }
        Etn = new ClientDedieEtn("MySql", env.getProperty("CONNECT_DRIVER"), env.getProperty("CONNECT"));
        Etn.setSeparateur(2, '\001', '\002');

        //load config from db
        Set rs = Etn.execute("SELECT code,val FROM config");
        while (rs.next()) {
            env.setProperty(rs.value("code"), rs.value("val"));
        }
        String commonsDb = env.getProperty("COMMONS_DB");
        if (commonsDb.trim().length() > 0) {
            //load from commons db but don't override local config
            rs = Etn.execute("SELECT code,val FROM " + commonsDb + ".config");
            while (rs.next()) {
                if (!env.containsKey(rs.value("code"))) {
                    env.setProperty(rs.value("code"), rs.value("val"));
                }
            }
        }

        semaphore = env.getProperty("IMPORT_SEMAPHORE");

        if (env.getProperty("WAIT_TIMEOUT") == null) {
            wait_timeout = 300;
        }
        else {
            int k = Integer.parseInt(env.getProperty("WAIT_TIMEOUT"));
            wait_timeout = (k == 0 ? 300 : k);
        }

        debug = env.getProperty("DEBUG") != null || env.getProperty("SCHED_DEBUG") != null;
        //fill GlobalParm
        for (Map.Entry<Object, Object> curEntry : this.env.entrySet()) {
            GlobalParm.add(curEntry.getKey().toString(), curEntry.getValue());
        }

    }

    public String getTime() {
        return (ItsDate.getWith(System.currentTimeMillis(), true));
    }

    public void run() {
        //System.out.println("globalparm:" + GlobalParm.getglb().toString()); //debug

        Set rs;

        File toStop = new File("_stopImpExp");
        toStop.delete();

        System.out.println("*****************\nStart SchedulerImportExport (" + getTime() + ")");
        System.out.println("Timeout:" + wait_timeout);

        try {

            LoadImportFile li = new LoadImportFile(Etn, env, debug);
            ExportData exp = new ExportData(Etn, env, debug);
            while (!stop) {

                if (toStop.exists()) {
                    break;
                }

                Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".engines_status (engine_name,start_date,end_date) VALUES('ImportExport',NOW(),null) ON DUPLICATE KEY update start_date=NOW(),end_date=null");
				
                Set rsSites=Etn.execute("select * from "+GlobalParm.getParm("PREPROD_PORTAL_DB")+".sites;");
                while(rsSites.next()){

                    try{
                        exp.ExportFile(rsSites.value("id"));
                    }catch(Exception e){
                        System.out.println("==================Error in exporting file==================");
                        e.printStackTrace();
                    }

                    try{
                        li.importFile(rsSites.value("id"));
                    }catch(Exception e){
                        System.out.println("==================Error in importing file==================");
                        e.printStackTrace();
                    }

                    try{
                        li.loadFile(rsSites.value("id"));
                    }catch(Exception e){
                        System.out.println("==================Error in loading file==================");
                        e.printStackTrace();
                    }
                }

				Etn.executeCmd("update "+env.getProperty("COMMONS_DB")+".engines_status set end_date=NOW() where engine_name='ImportExport'");

                if (debug) {
                    System.out.println("Wait " + semaphore + "(" + getTime() + ")");
                }
                while (true) {
                    rs = Etn.execute("select semwait('" + semaphore + "'," + wait_timeout + ")");
                    if (rs == null) {
                        refreshTun();
                    }
                    else {
                        break;
                    }
                }

            }

        }
        catch (Exception db) {
            db.printStackTrace();
        }
        finally {
            System.out.println("Stop SchedulerImportExport (" + getTime() + ")");
        }

    }

    public void refreshTun() {
        if (env.getProperty("TUNNEL") == null) {
            return;
        }

        System.out.println("refreshTun");
        try {
            Process p = Runtime.getRuntime().exec(env.getProperty("TUNNEL"));
            p.waitFor();
        }
        catch (Exception z) {
            z.printStackTrace();
        }

        try {
            Thread.currentThread().sleep(60000);
        }
        catch (Exception inutile) {
            inutile.printStackTrace();
        }
    }

    public static void main(String a[]) throws Exception {
        new SchedulerImportExport(a).run();
    }

}