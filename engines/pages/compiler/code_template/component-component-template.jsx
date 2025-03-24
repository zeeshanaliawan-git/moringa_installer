import React, { Component } from "react";
import ReactDOM from "react-dom";

/***___IMPORTS___***/

class ____ComponentParent extends React.Component {
    constructor(props) {
        super(props);
    }   
    
    render() {        
        return (
            <div id="____componentParent" style={{height:"768px",width:"1024px"}}>/***___RENDER___***/</div>
        );
    }
}

export default ____ComponentParent;
const wrapper = document.getElementById("root");
wrapper ? ReactDOM.render(<____ComponentParent />, wrapper) : false;