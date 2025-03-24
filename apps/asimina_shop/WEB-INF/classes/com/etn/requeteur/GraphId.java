package com.etn.requeteur;

public class GraphId{
    public GraphId(){
    
    }
    
    public GraphId(String graphId){
        this.graphId=graphId;
    }
    
    protected String graphId;
    public void setGraphId(String graphId){
        this.graphId=graphId;
    }
    public String getGraphId(){
        return graphId;
    }    
}