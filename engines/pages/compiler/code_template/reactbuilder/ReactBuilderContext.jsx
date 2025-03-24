import React, { Component } from "react";

import ReactBuilderUtil from "./ReactBuilderUtil.jsx"

class ReactBuilderContext extends React.Component {    
    constructor(props) {
        super(props);        
        this.key = "____reactBuilderContext";
        this.get = this.get.bind(this);
        this.set = this.set.bind(this);
        if(props.__context){
            this.set(props.__context);
        }
    }    
    componentDidMount(){        
        window[this.key] = window[this.key] || {};     
    }
    get(args){
        let data = window[this.key];
        if(data){
            if(typeof args === 'string' || args instanceof String){
                data = data[args];
            }else if(Array.isArray(args)){
                for(let i=0; i < args.length; i++){
                    if(args[i] in data){
                        data = data[args[i]];
                    }else{
                        break;
                    }
                }
            }            
        }
        return data;
    }
    set(__context){
        console.log("setting context");
        console.log(__context);
        window[this.key] = {...window[this.key],...__context};
    }
    render(){
        return null;
    }
}

export default ReactBuilderContext;