package com.etn.beans.app;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.PrintStream;
import java.net.URL;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Properties;
import com.etn.lang.ResultSet.Set;
import com.etn.beans.Contexte;

public class GlobalParm extends Hashtable
{
    private int curID = 0;
    private int increment = 10;

    protected int _nextval()
    {
        if (this.curID % this.increment == 0) 
        {
            save(this.curID + this.increment);
        }
        return ++this.curID;
    }

    protected int _curval()
    {
        return this.curID;
    }

    synchronized void save(int paramInt)
    {
        try
        {
            FileOutputStream localFileOutputStream = new FileOutputStream(this.seqfile);
            localFileOutputStream.write(("" + paramInt).getBytes());
            localFileOutputStream.close();
        }
        catch (Exception ex)
        {
            ex.printStackTrace();
        }
    }

    private boolean reinit()
    {
        InputStream inputstream = null;        
        try
        {
            inputstream = getClass().getResourceAsStream("GlobalParm.conf");
            Properties properties = new Properties();
            properties.load(inputstream);
            for(Enumeration enumeration = properties.propertyNames(); enumeration.hasMoreElements();)
            {
                String str = (String)enumeration.nextElement();
                if (str.equals("SEQ_INTERVAL")) 
                {
                    increment = Integer.parseInt(properties.getProperty(str));
                } 
                else if (str.equals("SEQUENCE")) 
                {
                    seqfile = properties.getProperty(str);
                } 
                else 
                {
                    put(str, properties.getProperty(str));
                }
            }
    
//            properties = null;
            if (this.seqfile == null)
            {
                this.seqfile = getClass().getResource("GlobalParm.conf").getPath();
                int i;
                if ((i = this.seqfile.indexOf('!')) != -1) 
                {
                    this.seqfile = this.seqfile.substring(0, i);
                }
                this.seqfile = this.seqfile.substring(1 + this.seqfile.indexOf(':'));
                this.seqfile += "_seq";
            }
            
            if (this.increment <= 0) 
            {
                this.increment = 1;
            }
            if (this.curID == 0)
            {
                byte abyte0[] = new byte[32];
                FileInputStream fileinputstream = null;
                try
                {
                    fileinputstream = new FileInputStream(seqfile);
                    int j = fileinputstream.read(abyte0);
                    curID = Integer.parseInt((new String(abyte0, 0, j)).trim());
                }
                catch(FileNotFoundException filenotfoundexception)
                {
                    _nextval();
                }
                finally
                {
                    try
                    {
                        if(fileinputstream != null) fileinputstream.close();
                    }
                    catch(Exception e) {}
                    
                }
                System.out.println("Info : GlobalParm Sequence File " + this.seqfile + "\n" + "\t curval: " + this.curID + " increment de sauvegarde " + this.increment);
            }
            
            //Load local application configurations from config table
            //These configs will overwrite the configs found from the GlobalParm.conf file
            Contexte Etn = new Contexte();
            Set rs = Etn.execute("select * from config ");
            while(rs != null && rs.next())
            {
                if(get(rs.value("code")) != null) 
                {
                    remove(rs.value("code"));
                }
                put(rs.value("code"), rs.value("val"));
            }

            //Load global configurations from config table in commons db
            //If a config is already in the hasttable before this point we will not overwrite it
            //Application configurations (from db or file) have more preference than these
            
            //first get the commons db name .. if not found we will not load global configs
            String commonsDb = (String)get("COMMONS_DB");
            if(commonsDb != null && commonsDb.length() > 0)
            {
                rs = Etn.execute("select * from "+commonsDb+".config ");
                while(rs != null && rs.next())
                {
                    if(get(rs.value("code")) == null) put(rs.value("code"), rs.value("val"));
                }
            }
            return true;
        }
        catch (Exception ex)
        {
            ex.printStackTrace();
        }
        finally
        {
            try
            {
                if(inputstream != null) inputstream.close();
            }
            catch(Exception e) {}
        }
        return false;
    }

    public static String getParm(String paramString)
    {
        return (String)glb.get(paramString);
    }

    public static Object getObj(String paramString)
    {
        return glb.get(paramString);
    }

    public static Hashtable getglb()
    {
        return (Hashtable)glb.clone();
    }

    public static synchronized int nextval()
    {
        return glb._nextval();
    }

    public static synchronized int curval()
    {
        return glb._curval();
    }

    public static void add(String paramString, Object paramObject)
    {
        glb.put(paramString, paramObject);
    }

    public static Object del(String paramString)
    {
        return glb.remove(paramString);
    }

    private GlobalParm()
    {
        reinit();
    }

    static GlobalParm glb = new GlobalParm();
    String seqfile;
}
