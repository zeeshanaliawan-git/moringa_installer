class ReactBuilderUtil {
    static isFunction(functionToCheck) {
        return functionToCheck && {}.toString.call(functionToCheck) === '[object Function]';
    }
    
    static isObjectArray(arr) {
        return (Array.isArray(arr) && arr.length && arr[0] !== null && typeof arr[0] === 'object');
    }
    
    static random(length) {
        if(!length) length = 5;
        var result           = '';
        var characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        var charactersLength = characters.length;
        for ( var i = 0; i < length; i++ ) {
            result += characters.charAt(Math.floor(Math.random() * charactersLength));
        }
        return result;        
    }
    static setAppContext(component,data){
        if(ReactBuilderUtil.isFunction(component.props.__setAppContext)){
            component.props.__setAppContext(data);
        }
    }
    static getAppContext(component,fields){
        let data;
        if(ReactBuilderUtil.isFunction(component.props.__getAppContext)){
            data = component.props.__getAppContext();
            if(data && Array.isArray(fields)){
                for(let i=0; i < fields.length; i++){
                    if(data[fields[i]]){
                        data = data[fields[i]];
                    }else{
                        break;
                    }
                }
            }
        }
        return data;
    }
}

export default ReactBuilderUtil;