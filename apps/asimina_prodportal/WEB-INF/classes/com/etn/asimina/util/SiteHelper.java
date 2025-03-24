package com.etn.asimina.util;

import com.etn.beans.Contexte;
import com.etn.beans.app.GlobalParm;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import java.util.List;
import java.util.ArrayList;
import com.etn.asimina.beans.Language;

public class SiteHelper {

    static String COMMONS_DB = GlobalParm.getParm("COMMONS_DB");
    static String CATALOG_DB = GlobalParm.getParm("CATALOG_DB");

    public static List<Language> getSiteLangs(Contexte Etn, String siteId) {
        Set rs = Etn.execute("SELECT lang.* FROM " + CATALOG_DB + ".language lang JOIN " + COMMONS_DB
                + ".sites_langs sl ON sl.langue_id=lang.langue_id WHERE sl.site_id=" + escape.cote(siteId)+" ORDER BY lang.langue_id");
        List<Language> langList = new ArrayList<>();
        while (rs.next()) {
            Language lang = new Language(rs);
            langList.add(lang);
        }
        return langList;
    }
}