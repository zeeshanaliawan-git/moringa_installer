
var strtrim = function(){
    //Match spaces at beginning and end of text and replace
    //with null strings
    return this.replace(/^\s+/,'').replace(/\s+$/,'');
};
String.prototype.trim = strtrim;

var ListGeneric = function(params){

    this.canUpdt = (params && params.canUpdt)? params.canUpdt:false;

    this.cur = null;    // curr cell
    this.otext = null;  // orig text of cur cell
    this.inp = null;           // input flottant pour la saisie
    this.updts = ""; // les cellules modifiées


    this.trash = document.createElement("img");
    this.trash.src = "img/trash.gif";
    this.trash.style.verticalAlign = "middle";

};

ListGeneric.prototype.editChange = function( o , postProcessFunc)
{
    if( this.text.nodeValue != jQuery(o).val() )
    {
        var oval = "";
        var row = this.cur.parentNode;
        var datas = row.getAttribute("valeur");
        // BUG IE8/IE7 hasAttribute inexistant !!!
        if( this.cur.hasAttribute ) // sauf IE8 IE7
        {
            if( this.cur.hasAttribute("_oval") )
                oval = this.cur.getAttribute("_oval");
            else
            {
                this.cur.setAttribute("_oval",this.text.nodeValue);
                oval = this.text.nodeValue;
            }
        }
        else
        {  // IE8..IE7  IE6?
            if( null == (oval =  this.cur.getAttribute("_oval")) )
            {
                this.cur.setAttribute("_oval",this.text.nodeValue);
                oval = this.text.nodeValue;
            }
        }

        var s = "_"+this.cur.cellIndex+"=" ;

        var newVal = jQuery(o).val();
        if (postProcessFunc){
            newVal = postProcessFunc(o);
        }
        if( !datas ) datas = s+newVal+"\t";
        else
        {
            var i = datas.indexOf(s);
            if( i != -1)
                datas = datas.substring(0,i)+
                datas.substring(datas.indexOf('\t',i+1)+1);

            if( oval != newVal )
                datas += s+newVal+"\t"
        }

        row.setAttribute("valeur" , datas);
        jQuery(this.cur).removeClass("val_error");
//        if(datas.length>0){
//            jQuery(row).addClass("lg_odd");
//        }
//        else{
//            jQuery(row).removeClass("lg_odd");
//        }
        row.className = (datas.length>0)?"lg_odd":"";
        this.text.nodeValue = newVal;
    //document.getElementById("dbg").value += "\n"+datas;

    }

    //var dv = document.getElementById("lg_D1");
    //dv.appendChild( this.cur.replaceChild(this.text, o));
    var tdumy = this.cur.replaceChild(this.text, o);
    this.cur.normalize();
    //dv.normalize();
    return(true);

};

ListGeneric.prototype.del = function( cm )
{
    var tx=true;
    if(cm.hasChildNodes() )
    {
        var w = cm.removeChild(cm.lastChild);
        tx = (w.nodeType == 3 ) // TextNode
    }

    var p = cm.parentNode;
    if( tx )
    {
        cm.appendChild( this.trash.cloneNode(false) );
        p.className = "del";
        p.setAttribute("valeur","__DEL");
    }
    else
    {
        cm.appendChild( document.createTextNode(" ") );
        p.className = "";
        p.removeAttribute("valeur");
    }


};

ListGeneric.prototype.edit = function(obj, extraProcessingFunc)
{
    if( obj.length != 1 ) return false;
    this.cur = obj[0];

    if( this.cur.cellIndex == 0 ){
        // del
        return this.del(this.cur);
    }

    if( this.canUpdt.indexOf(","+this.cur.cellIndex+",") == -1 ){
        return false;
    }

    this.inp = document.getElementById('lg_inp').cloneNode(true);
    this.inp.id = "";
    if(!this.cur.firstChild)
        this.cur.appendChild( document.createTextNode("") );

    this.text = this.cur.replaceChild(this.inp,this.cur.firstChild);
    this.inp.value = this.text.nodeValue;

    if(extraProcessingFunc){
        this.inp = extraProcessingFunc(this.inp);
    }

    this.cur.normalize();
    this.inp.focus();
    return false;
};

ListGeneric.prototype.getDatas = function(tbodyId)
{
    var s = "";

    var b = document.getElementById(tbodyId);
    for( var i = 0 ; i < b.rows.length ; i++ ){
        var valeur = b.rows[i].getAttribute("valeur")
        if( valeur ){
            s +=  b.rows[i].getAttribute("id")+":"+valeur+"\001";
        }
    }
    return s;
};

