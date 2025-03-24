package com.etn.pages;

import com.etn.beans.Etn;
import com.etn.beans.app.GlobalParm;

import java.util.Properties;

/**
 * @author Ali Adnan
 * Base class for where the class needs Etn and either properties or globalparm
 */
public abstract class BaseClass {

    protected Etn Etn;
    protected Properties env = null;

    protected boolean debug = false;

    public BaseClass(Etn Etn, Properties env, boolean debug) {
        this.Etn = Etn;
        this.env = env;
        this.debug = debug;
    }

    public BaseClass(Etn Etn) {
        this.Etn = Etn;
    }

    public void setDebug(boolean debug) {
        this.debug = debug;
    }

    public void log(String str) {
        if (debug) {
            System.out.println(str);
        }
    }

    public String getParm(String key) {
        if (env != null) {
            return env.getProperty(key);
        }
        else {
            return GlobalParm.getParm(key);
        }
    }

}
