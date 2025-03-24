package com.etn.Client.Impl;

import com.etn.beans.Etn;

public class ClientDedieEtn extends ClientDedie implements Etn {

    int id = 1; //pid initialize, 0 is not logically valid

    public ClientDedieEtn() {
    }

    public ClientDedieEtn(String s, String s1, String s2) throws Exception {
        super(s, s1, s2);
    }

    public void setId(int id) {
        this.id = id;
    }

    @Override
    public int getId() {
        return id;
    }

    @Override
    public int setContexte(String s, String s1) {
        return id;
    }

    @Override
    public int getUpdateCount() {
        return this.UpdateCount;
    }
}
