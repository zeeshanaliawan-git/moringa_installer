import React, { Component } from "react";
import ReactDOM from "react-dom";
import { Responsive, WidthProvider } from 'react-grid-layout';
import '../../node_modules/react-grid-layout/css/styles.css';
import '../../node_modules/react-resizable/css/styles.css';
const ResponsiveGridLayout = WidthProvider(Responsive);

/*Ali Bin Jamil*/

/***___IMPORTS___***/

class /***___CLASS_NAME___***/ extends React.Component {
    constructor(props) {
        super(props);
        this.addStyle = this.addStyle.bind(this);
        this.changeLayout = this.changeLayout.bind(this);
        this.gotoDefaultLayout = this.gotoDefaultLayout.bind(this);
        this.isHidden = this.isHidden.bind(this);
        this.state = {
                layout:/***___LAYOUT___***/
            };
            this.state.defaultLayout = JSON.parse(JSON.stringify(this.state.layout));
    }
    
    addStyle(){
        let styles = /***___STYLES___***/;
        for(var divId in styles){
            for(var property in styles[divId]){
                var el = document.getElementById(divId);//added this check as the element might be hidden in a layout
                if(el){
                    el.style[property] = styles[divId][property];
                }
            }
        }        
    }
    
    componentDidMount(){
        this.addStyle();
    }
    
    componentDidUpdate(){
        this.addStyle();
    }
    
    changeLayout(layout){        
        this.setState({layout});
    }
    gotoDefaultLayout(){
        this.setState({layout: this.state.defaultLayout});
    }
    isHidden(index){     
        for(var i=0; i < this.state.layout.length; i++){
            if(this.state.layout[i].i === index){                
                return false;
            }
        }        
        return true;
    }
    
    
    render() {        
        let layouts = {xl: this.state.layout, lg: this.state.layout, md: this.state.layout, sm: this.state.layout, xs: this.state.layout};
        let defaultLayoutProps = {
            autoSize: false,
            rowHeight: /***___ROW_HEIGHT___***/,
            margin: [/***___PAGE_MARGIN_X___***/, /***___PAGE_MARGIN_Y___***/],
            containerPadding: [/***___CONTAINER_PADDING_X___***/, /***___CONTAINER_PADDING_Y___***/],
            compactType: "vertical", 
            className:"layout",
            layouts:layouts,
            breakpoints:{xl: 1200, lg: 992, md: 768, sm: 576, xs: 0},
            cols:{xl: 12, lg: 12, md: 8, sm: 6, xs: 4}
        };
        return (
            /***___RENDER___***/
        );
    }
}

export default /***___CLASS_NAME___***/;
const wrapper = document.getElementById("root");
wrapper ? ReactDOM.render(</***___CLASS_NAME___***/ />, wrapper) : false;