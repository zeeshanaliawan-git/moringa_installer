import React, { Component } from "react";
import ReactBuilderUtil from "./ReactBuilderUtil.jsx"
import ReactBuilderContext from "./ReactBuilderContext.jsx"

class ReactBuilderParent extends React.Component {
    constructor(props) {
        super(props);        
        this.reactContext = React.createRef();
        this.state = {
            __dataLoaded: 0
        };
    }        
    
    componentDidMount(){   
        //let __self = this;
        if(Array.isArray(this.props.__initContext)){
            this.props.__initContext.forEach((__init) => {                
                if(__init.url){
                    let url = __init.url;
                    let key = __init.key;
                    fetch(url)
                        .then(res => res.json())
                        .then(
                            (data) => {   
                                let obj = data;
                                if(key){
                                    obj = {};
                                    obj[key] = data;
                                }
                                this.reactContext.current.set(obj);
                            },
                            // Note: it's important to handle errors here
                            // instead of a catch() block so that we don't swallow
                            // exceptions from actual bugs in components.
                            (error) => {
                                   
                            }
                        )
                        .then(
                            () => {                                
                                this.setState({__dataLoaded: this.state.__dataLoaded+1});
                            }
                        )
                }
            });
        }
    }
    
    render() {
        let urlsToLoad = 0;
        if(Array.isArray(this.props.__initContext)){
            urlsToLoad = this.props.__initContext.length;
        }
        let html = null;
        if(this.state.__dataLoaded === urlsToLoad){
            html = this.props.children;
        }else{
            html = <div>Loading....</div>;
        }        
        return (            
            <React.Fragment>
                <ReactBuilderContext ref={this.reactContext} __context={this.props.__context}/>
                {html}
            </React.Fragment>
        );
    }
    
    
}

export default ReactBuilderParent;