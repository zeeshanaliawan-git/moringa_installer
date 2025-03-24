package com.etn.requeteur;

import java.util.*;

public class Data{
    
    public Data(){
        
    }
    
    public Data(String graphId, List<GraphId> drills){
        this.graphId=graphId;
        this.drills=drills;
    }
    
    protected String graphId;
    protected List<GraphId> drills;
    
    public String getGraphId(){
        return graphId;
    }
    
    public void setGraphId(String gid){
        this.graphId=gid;
    }
    
    public List<GraphId> getDrills() {
        return drills;
    }

    public void setDrills(List<GraphId> drills) {
        this.drills = drills;
    }    
}