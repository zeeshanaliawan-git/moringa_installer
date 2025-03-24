

function showLoader(msg, ele){

    if(typeof ele === "undefined") ele = $('body');

    ele.addClass('loading2');

    $(ele).find('div.loading2msg').remove();
    var msgEle = $('<div>').addClass('loading2msg');
    $(ele).append(msgEle);

    if(typeof msg !== 'undefined'){
        msgEle.html(msg);
    }
    else{
        msgEle.html("");
    }

}

function hideLoader(){
    $('.loading2').removeClass('loading2');
}

function show(z)
{
	var s = "" ;

	w = open("_blank","aide",'height=360,width=400,top=100,left=140,scrollbars=yes,resizable');
	w.document.open();

 	for( var i in z )
		{
			s = "";
				c = ("" + i).charAt(0);
				if(c < '0' || c > '9' )
						s += " <font color=blue>" + i + "</font>->" + eval( "z." +i) ;
				else
						s += " " + i + "-> void ptr ";
				s += "<br>";
				w.document.write(s);
	}
	w.document.close();
	return(false);
}

function isdoublevalue(e)
{
	var unicode = e.charCode ? e.charCode : e.keyCode;

	if(unicode == 46)
	{
	      	var targ;
		if (e.target) targ = e.target;
		else if (e.srcElement) targ = e.srcElement;
		if(targ.value.indexOf(".") > -1) return false;
		return true;
	}

	if (e.which != 8 && e.which != 0 && (e.which < 48 || e.which > 57))
	{
       	return false;
	}

}

function isvalidimage(fname)
{
	if($.trim(fname) == '') return false;
	var ext = $.trim(fname);
	if(ext.indexOf(".") > -1) ext = ext.substring(ext.lastIndexOf(".") + 1);
	else return false;

	if(ext.toLowerCase() != "png" && ext.toLowerCase() != "jpg" && ext.toLowerCase() != "jpeg" && ext.toLowerCase() != "tif" && ext.toLowerCase() != "gif")
		return false;
	return true;
}

function getContextPath(){
	var l = ""+location.pathname;
	l = l.substring(1);
	var i = l.indexOf("/");
	l = l.substring(0,i);
	return("/"+l+"/");
}


function allowNumberOnly(ele){
    $(ele).val($(ele).val().replace(/[^\d]/g,''));
}

function allowFloatOnly(ele){
    var val = $(ele).val().replace(/[^\d.,]/g,'');
    //keep only one decimal point, remove extras
    if(val.indexOf(".")>=0){
        var valArr = val.split(".");
        val = valArr[0] + "." + valArr.splice(1).join("");
    }
    if(val.indexOf(",")>=0){
        var valArr = val.split(",");
        val = valArr[0] + "." + valArr.splice(1).join("");
    }
    $(ele).val(val);
}

function formatNumber(ele, precision){
	var val = $(ele).val();

	if(precision >= 0 && parseFloat(val)){
		val = parseFloat(val).toFixed(precision);
		$(ele).val(val);
	}
}


// simple replace all for javascript for simple strings
//  if searchTerm has regexp special characters
//  use escapeRegExp(str) function to escape it before calling
function strReplaceAll(str , searchTerm, replacement){

    return str.replace(new RegExp(searchTerm, 'g'), replacement);
}

function escapeRegExp(str) {
  return str.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"); // $& means the whole matched string
}

function bootConfirm(message, callback) {
    //callback(result) , where result = true/false

    bootbox.confirm({
        size: 'small',
        animate: false,
        message: message,
        callback: callback
    });
}

function bootAlert(message, callback) {
    //NOTE: unlike builtin "alert()" this does not stop execution
    //for workaround, you can use callback
    //callback(result) , where result = true/false

    bootbox.alert({
        size: 'small',
        animate: false,
        message: message,
        callback: callback
    });
}

/*
  toast-like , growl-like notification
  which auto close after some time
*/

function bootNotifyError(msg){
  bootNotify(msg, "danger");
}

function bootNotify(msg, type) {

    if (typeof type == 'undefined') {
        type = "success";
    }
    var settings = {
        type: type,
        delay: 2000,
        placement: {
            from: "top",
            align: "center"
        },
        offset : {
            y : 10,
        },
        z_index : 1500,//to show above bootstrap modal
        // animate: {
        //     enter: 'animated fadeInDown',
        //     exit: 'animated fadeOutRight'
        // }
    };

    $.notify(msg, settings);
}

function getRandomInt(max) {
    return Math.floor(Math.random() * Math.floor(max));
}