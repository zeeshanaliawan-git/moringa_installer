import React, { Component } from "react";

class ReactBuilderParentComponent extends React.Component {    
    constructor(props) {
        super(props);
        this.__events = {}; //all the events data. Ideally child class should not use this
        this.__onReactBuilderEvent = this.__onReactBuilderEvent.bind(this); //the default function called and react builder event is triggered. Again child class should not use this
        this.addReactBuilderEventListener = this.addReactBuilderEventListener.bind(this); //this is the function used to add event handlers to events. Events can be generic or componentId can be appended with hash. Handler should be a string and name of the function. 
        if(Array.isArray(props.eventsToHandle)){
            props.eventsToHandle.forEach((eventToHandle) => {  
                this.addReactBuilderEventListener(eventToHandle);
            });
        }        
        this.isFunction = this.isFunction.bind(this);//util function
    }
    
    isFunction(functionToCheck){
        return functionToCheck && {}.toString.call(functionToCheck) === '[object Function]';
    }
    
    addReactBuilderEventListener(completeName,childEventHandler){
        console.log("adding event listener",completeName);
        let eventName = null;
        let componentId = null;
        if(completeName.indexOf("#") > -1){
            eventName = completeName.substring(0,completeName.indexOf("#"));
            componentId = completeName.substring(completeName.indexOf("#") + 1);
        }else{
            eventName = completeName;
            componentId = null;
        }
        if(!childEventHandler){
            childEventHandler = "defaultEventHandler";
        }
        if(!this.__events[eventName]){
            this.__events[eventName] = {handler:this.__onReactBuilderEvent,childEventHandler,ids:{}};
        }
        if(componentId){
            delete this.__events[eventName].childEventHandler;
            this.__events[eventName].ids[componentId] = childEventHandler;           
        }        
        window.addEventListener(eventName,this.__onReactBuilderEvent);
    }
    
    __onReactBuilderEvent(e){   
        console.log("event called");     
        let __reactBuilderEvent = this.__events[e.type];
        if(__reactBuilderEvent){
            //if a component is listening to AutoComplete.select and AutoComplete.select#123 then AutoComplete.select will not work and it will listen to select from specific id only
            if(Object.keys(__reactBuilderEvent.ids).length === 0 && this.isFunction(this[__reactBuilderEvent.childEventHandler])){
                this[__reactBuilderEvent.childEventHandler](e);
            }else if(__reactBuilderEvent.ids[e.detail.componentId] && this.isFunction(this[__reactBuilderEvent.ids[e.detail.componentId]])){
                this[__reactBuilderEvent.ids[e.detail.componentId]](e);
            }
        }        
    }
    
    componentWillUnmount() {
        if(this.isFunction(this["componentWillUnmountChild"])){
            this["componentWillUnmountChild"]();
        }
        if(Array.isArray(this.__events)){
            this.__events.forEach((event) => {
                window.removeEventListener(event, this.__onReactBuilderEvent);
            });
        }        
    }
    
    trigger(data,name,reactEvent){
        let componentId = this.props.componentId || null;        
        let nativeEvent;
        if(reactEvent){
            nativeEvent = reactEvent.nativeEvent;
        }
        let detail = {data,componentId,nativeEvent};
        var event = new CustomEvent(name, {detail});        
        window.dispatchEvent(event);        
    }
    
}

export default ReactBuilderParentComponent;