
/* Ad-hoc JavaScript functions that are used in more than one JSP in project Guizmo Spain Mobile. */


function client(customerId, post_work_id, url)
{
	 var x , y;
	 if(  window.innerWidth )
	 {  x  = .8 * window.innerWidth;
	    y  =   window.innerHeight ;
	 }
	 else
	 {
	    x = .9 * document.body.offsetWidth ;
	    y = document.body.offsetHeight ;
	 }

	  nouvelleFenetre(url+".jsp?customerId="+customerId+"&post_work_id="+post_work_id);

	 return( false);
 }

function genericFromClient(formId, post_work_id, url)
{
	 var x , y;
	 if(  window.innerWidth )
	 {  x  = .8 * window.innerWidth;
	    y  =   window.innerHeight ;
	 }
	 else
	 {
	    x = .9 * document.body.offsetWidth ;
	    y = document.body.offsetHeight ;
	 }

	  nouvelleFenetre(url+".jsp?form_id="+formId+"&post_work_id="+post_work_id);

	 return( false);
 }

 function clientConsultation(customerId, post_work_id)
{
	 var x , y;
	 if(  window.innerWidth )
	 {  x  = .8 * window.innerWidth;
	    y  =   window.innerHeight ;
	 }
	 else
	 {
	    x = .9 * document.body.offsetWidth ;
	    y = document.body.offsetHeight ;
	 }

	  nouvelleFenetre("../customerEdit.jsp?customerId="+customerId+"&post_work_id="+post_work_id);

	 return( false);
 }

function nouvelleFenetre(url) {
//	propriete = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
//	propriete += "scrollbars=yes, menubar=no, location=no, statusbar=no" ;
//	propriete += ",width=900" + ",height=800";  //propriete += ",width=" + screen.availWidth + ",height=" + screen.availHeight;
//	win = window.open(url,"ton_titre", propriete);
//	win.focus();
        $("#customerEditIframe").attr("src", url);
		  $("#customerEditCard").show();
        $("#customerEditParameters").hide();
        $("#customerEditTable").hide();
}

function client2(customerId)
{
	 var x , y;
	 if(  window.innerWidth )
	 {  x  = .8 * window.innerWidth;
	    y  =   window.innerHeight ;
	 }
	 else
	 {
	    x = .9 * document.body.offsetWidth ;
	    y = document.body.offsetHeight ;
	 }

	  nouvelleFenetre2("customerEdit.jsp?customerId="+customerId);

	 return( false);
 }

function nouvelleFenetre2(url) {
	propriete = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=yes, toolbar=no,";
	propriete += "scrollbars=yes, menubar=no, location=yes, statusbar=no" ;
	propriete += ",width=900" + ",height=800";  //propriete += ",width=" + screen.availWidth + ",height=" + screen.availHeight;
	win = window.open(url,"ton_titre", propriete);
	win.focus();
}
function showTable()
{
	refreshScreen();
//	$("#customerEditCard").hide();
//	$("#customerEditParameters").show();
//	$("#customerEditTable").show();
}






