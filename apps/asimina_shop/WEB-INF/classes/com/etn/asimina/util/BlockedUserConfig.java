package com.etn.asimina.util;

import com.etn.beans.Contexte;
import com.etn.sql.escape;
import com.etn.lang.ResultSet.Set;
import java.util.Map;
import java.util.HashMap;

//This class is to load config for Blocked User/Ip(s)
public class BlockedUserConfig{
    BlockedUserConfig(){
        loadConfig();
    }

    public Map<String, String> userConfig;
    public Map<String, String> ipConfig;

    public static BlockedUserConfig instance = new BlockedUserConfig();

    public void loadConfig(){
        Contexte Etn = new Contexte();
        userConfig = new HashMap();
        ipConfig = new HashMap();

        Set rs =  Etn.execute("select * from user_block_config");
        while(rs.next()){
            if(rs.value("type").equals("user")){
                userConfig.put("nAttempts", rs.value("number_of_tries"));
                userConfig.put("blockTime", rs.value("block_time"));
                userConfig.put("blockTimeUnit", rs.value("block_time_unit"));
            }else if(rs.value("type").equals("ip")){
                ipConfig.put("nAttempts", rs.value("number_of_tries"));
                ipConfig.put("blockTime", rs.value("block_time"));
                ipConfig.put("blockTimeUnit", rs.value("block_time_unit"));
            }
        }
    }
}