<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.beans.app.GlobalParm, java.util.*"%>
<%@ page import="com.etn.sql.escape"%>
<%@ page import="javax.mail.internet.MimeUtility, java.io.File"%>


<%!
String parseNull(Object o) {
  if( o == null )
    return("");
  String s = o.toString();
  if("null".equals(s.trim().toLowerCase()))
    return("");
  else
    return(s.trim());
}


%>

<% 

  Set rslang = Etn.execute("select * from language ");

  String ze = null;
  if( (ze=request.getParameter("todel")) != null )
  { 
    Etn.execute("delete from mails where id="+escape.cote(ze));
  }

  if( request.getParameter("modSujet") !=null)
  {
     String ss = null;
     Set rs = Etn.execute( new String[] { 
      ss = "update mails set sujet = "+escape.cote( request.getParameter("sujet") )+
          ", sujet_lang_2 = " + escape.cote(parseNull(request.getParameter("sujet_lang_2"))) +
          ", sujet_lang_3 = " + escape.cote(parseNull(request.getParameter("sujet_lang_3"))) +
          ", sujet_lang_4 = " + escape.cote(parseNull(request.getParameter("sujet_lang_4"))) +
          ", sujet_lang_5 = " + escape.cote(parseNull(request.getParameter("sujet_lang_5"))) +
          " where id ="+escape.cote(request.getParameter("mailid")),
          "select sujet from mails where id="+escape.cote(request.getParameter("mailid"))
       } 
      );

    if(!rs.next() || Integer.parseInt(rs.value(0)) < 0 )
      out.write("Echec...");
    else { 
      rs.next(); out.write(rs.value(0)); 
    }

    return;
  }

  if( request.getParameter("sendMail") !=null)
  {
     String cmd = "/home/ronaldo/pjt/dev_engines/shop/testMail "+request.getParameter("mailid")+" "+request.getParameter("sendTo")+
      " "+request.getParameter("ordertyp") ;

    System.out.println("CMD:"+cmd);

    Process p = Runtime.getRuntime().exec(cmd);
    int r = p.waitFor();
    if( r == 0 ) out.write("Succes");
    else out.write("Echec:"+r);

    return;
  }
  
  List<String> orderTypes = new ArrayList<>();  
  if("1".equals(parseNull(GlobalParm.getParm("use_process_as_order_type"))))
  {
	  //we have to use process names as orderTypes... this was requirment of orange for another project other than asimina
	  Set _rs1 = Etn.execute("Select  process_name from processes  order by process_name");
	  while(_rs1.next())
	  {
		  orderTypes.add(_rs1.value("process_name"));
	  }
  }
  else
  {
	  orderTypes.add("Order");
  }


%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
<title>Shop - Manage SMS/Mail</title>

<%@ include file="/WEB-INF/include/headsidebar.jsp"%>
    <script type="text/javascript">
        $(function() {
            feather.replace();
        });
    </script>

<script>

function utf8_encode(str)
{
  str = str.replace(/\r\n/g,"\n");
  var utf = "";

  for (var n = 0; n < str.length; n++)
  {

   var c = str.charCodeAt(n);

  if (c < 128)
     utf += String.fromCharCode(c);
  else if((c > 127) && (c < 2048))
  {
    utf += String.fromCharCode((c >> 6) | 192);
    utf += String.fromCharCode((c & 63) | 128);
  }
  else
  {
    utf += String.fromCharCode((c >> 12) | 224);
    utf += String.fromCharCode(((c >> 6) & 63) | 128);
    utf += String.fromCharCode((c & 63) | 128);
  }

}

  return utf;
}


function gesMail(o,fc)
{
  pdata = null;
  mailid = o.parentNode.parentNode.id.substring(1);
  retId = null;
  emailtoId=null;
  conditionId=null;
  attachId = null;
  if(! mailid ) return;

  if( 1 == fc )
  {
    pdata = "getAttachs=1";
    pdata += "&mailid="+mailid;
    pdata += "&ordertyp="+o.options[o.selectedIndex].text;
    retId = "att"+mailid;
  }
  else if( 2 == fc )
  {
    pdata = "modAttachs=1";
    pdata += "&mailid="+mailid;
    with( document.getElementById("sel"+mailid) )
      pdata += "&ordertyp="+options[selectedIndex].text;

    pdata += "&attachs="+document.getElementById("att"+mailid).value;
    retId = "att"+mailid;
  }
  else if( 3 == fc )
  { pdata = "modSujet=1" ;
    pdata += "&mailid="+mailid;
    retId = "suj"+mailid;
    pdata += "&sujet="+document.getElementById(retId).value;
    <% int langcnt = 0; %>
    <% while(rslang.next()) {
  if(langcnt++ == 0) continue;
    %>
      pdata += "&sujet_lang_<%=langcnt%>="+document.getElementById("suj"+mailid+"_lang_<%=langcnt%>").value;
    <% } %>
  }
  else if( 4 == fc )
  { pdata = "sendMail=1" ;
    pdata += "&mailid="+mailid;

    s = document.getElementById("to"+mailid).value;
    if( ! s) { alert( "mailto is mandatory"); return; }
    pdata += "&sendTo="+s;
    with( document.getElementById("tsel"+mailid) )
      s = options[selectedIndex].text;
    if( ! s ) {  alert( "Tipo de orden  is mandatory"); return; }
    pdata += "&ordertyp="+s;


    retId = null;
  }
  else if( 5 == fc )
  { if( confirm( "Effacer le modèle:"+mailid) )
    {
       with( document.getElementById("delmail") )
       { value = mailid;
         form.submit();
       }
    }
    return;
  }

  else if (11 == fc || 10 == fc)
  {
  emailtoId="confemail"+mailid;
  conditionId="confcondition"+mailid;
  attachId="att"+mailid;

  if(11==fc)
  {
    pdata = "loadConfiguration=1";
    pdata += "&mailid="+mailid;
    pdata += "&ordertype="+o.options[o.selectedIndex].text;
    document.getElementById(emailtoId).value = "";
    document.getElementById(conditionId).value = "";
    document.getElementById(attachId).value = "";
  }
  else
  {
    pdata = "saveConfiguration=1";
    pdata += "&mailid="+mailid;
    pdata += "&ordertype="+document.getElementById("sel"+mailid)[document.getElementById("sel"+mailid).selectedIndex].text;
    pdata += "&emailto="+document.getElementById(emailtoId).value;
    pdata += "&whereclause="+document.getElementById(conditionId).value;
    pdata += "&attach="+document.getElementById(attachId).value;
  }
//alert(pdata);
  $.ajax({
            type: "POST",
            url: "mailconfig.jsp",
            data:  pdata,
      dataType:'json',
            success: function(resp){
        if(resp.EMAIL_TO) document.getElementById(emailtoId).value = resp.EMAIL_TO;
                if(resp.WHERE_CLAUSE) document.getElementById(conditionId).value = resp.WHERE_CLAUSE;
                if(resp.ATTACH) document.getElementById(attachId).value = resp.ATTACH;
        if(resp.MESSAGE) alert(resp.MESSAGE);
      }
  });
  pdata = null;
  }

  if( pdata == null )
      return;

  $.ajax({
            type: "POST",
            url: "modele.jsp",
            data:  pdata,
            success:
            function(retour){
                if( retId )
                document.getElementById(retId).value = retour;
                else alert(retour);
    }
        });

}

function sendModel(o,fct)
{
 sujet = "";
 mailid = "";

 if( fct == 1 )
 { mailid = o.parentNode.parentNode.id.substring(1);
   sujet =  mailid+" - ";
 }

 sujet += document.getElementById("suj"+mailid).value;

  if( sujet=="" )
  { alert( "Subject is  mandatory" );
    return;
  }

  // Case I.E/Outlook, send url encoded http.
  if( document.all)
    sujet= escape(utf8_encode(sujet));


  //window.open( "mailto:modele@etiendamovil.com?subject="+sujet );


}

</script>


<style type="text/css">
legend { font-size:120%; color : green }
fieldset { padding: 0px ; margin: 0px; padding:0px;}


</style>

</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
        <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
			<h1 class="h2">Manage SMS/Mails</h1>
		</div>
        <div class="animated fadeIn">
          <div class="card">
            <div class="card-header">Manage SMS / Mail</div>
            <div class="card-body">
              <h3>Attachments to existing emails</h3>
                <table class="table table-responsive-sm resultat table-hover table-striped" style="table-layout:fixed">
                    <thead>
                        <tr>
                            <th>Id</th>
                            <th>Sujet</th>
                            <th>Order Type</th>
                            <th>Attachments</th>
                            <th>Email To</th>
                            <th>Condition</th>
                            <th>&nbsp;</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        Set rsM = Etn.execute("select * from mails order by id");
                        while(rsM.next())
                        { %>
                        <tr id='s<%=rsM.value("id")%>'>
                            <td>
                                <%=rsM.value("id")%>
                            </td>
                            <td id='b<%=rsM.value("id")%>'><%=MimeUtility.decodeText(rsM.value("sujet"))%>
                            </td>
                            <td><select id='sel<%=rsM.value("id")%>' onchange="gesMail(this,11)" class="form-control">
                                    <option selected value=0>
                                    <%for(String oType : orderTypes){
										out.write("<option value='"+oType+"'>"+oType+"</option>");
									}%>
                                </select>
                            </td>
                            <td>
                                <input type="text" id='att<%=rsM.value("id")%>' value="" class="form-control">
                            </td>
                            <td>
                                <input type="text" id='confemail<%=rsM.value("id")%>' value="" class="form-control">
                            </td>
                            <td>
                                <input type="text" id='confcondition<%=rsM.value("id")%>' value="" class="form-control">
                            </td>
                            <td>
                              <!-- <input type="button" value="Save"onclick="gesMail(this,10)"> -->
                              <button class="btn btn-success" onclick="gesMail(this,10)" title="Save">
                                <i class="fa fa-save"></i>
                              </button>
                            </td>
                            <% } %>
                    </tbody>
                </table>


                <h3>Creating/Editing an email</h3>
                <table class="table table-responsive-sm resultat table-hover table-striped" style="table-layout:fixed">
                    <thead style="border-bottom: solid 1px #edf">
                        <tr>
                            <th>Id</th>
                            <th>Subject</th>
                                <% rslang.moveFirst();
                                langcnt = 0;
                                while(rslang.next()) {
                                        if(langcnt++ == 0) continue;
                                %>
                            <th>Subject (<%=rslang.value("langue")%>)</th>
                                <% } %>
                            <th>&nbsp;</th>
                            <th>Templates</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        rsM = Etn.execute("select * from mails order by id");
                        while(rsM.next())
                        {
                            boolean fileExists = false;
                            String fileName = com.etn.beans.app.GlobalParm.getParm("MAIL_UPLOAD_PATH")+"mail"+rsM.value("id");
                            File f = new File(fileName);
                            if(f.exists() && !f.isDirectory()) {
                                fileExists = true;
                            }
                        %>
                        <tr id="c<%=rsM.value("id")%>">
                            <td nowrap><%=rsM.value("id")%>
                            </td>
                            <td>
                                <input class="form-control" type="text" id="suj<%=rsM.value("id")%>" value="<%=MimeUtility.decodeText(rsM.value("sujet"))%>" ><br>

                                <button class="btn" title="Upload Template" onclick='showuploaddialog("<%=rsM.value("id")%>","");'><i class="fa fa-upload"></i></button>

                                <button class="btn" title="Download Template" onclick='window.location="downloadMail.jsp?mailId=<%=rsM.value("id")%>"' style="<%=fileExists?"":"display:none;"%>"><i class="fa fa-download"></i></button>
                            </td>
                            <% rslang.moveFirst();
                            langcnt = 0;
                            while(rslang.next()) {
                                    if(langcnt++ == 0) continue;
                                    fileExists = false;
                                    fileName = com.etn.beans.app.GlobalParm.getParm("MAIL_UPLOAD_PATH")+"mail"+rsM.value("id")+"_"+parseNull(rslang.value("langue_code"));
                                    f = new File(fileName);
                                    if(f.exists() && !f.isDirectory()) {
                                        fileExists = true;
                                    }
                            %>
                            <td>
                                <input class="form-control" type="text" id="suj<%=rsM.value("id")%>_lang_<%=langcnt%>" value="<%=MimeUtility.decodeText(parseNull(rsM.value("sujet_lang_"+langcnt)))%>" >
                                <br>
                              

                               <button class="btn" title="Download Template" onclick='window.location="downloadMail.jsp?mailId=<%=rsM.value("id")%>&lang=<%=parseNull(rslang.value("langue_code"))%>"' style="<%=fileExists?"":"display:none;"%>"><i class="fa fa-download"></i></button>

                                <button class="btn" title="Upload Template" id='uploadBtn_<%=rsM.value("id")%>' onclick='showuploaddialog("<%=rsM.value("id")%>","<%=parseNull(rslang.value("langue_code"))%>");'><i class="fa fa-upload"></i></button>
                            </td>
                            <%}%>
                            <td valign='top'>
                                <button class="btn " title="Modify Subject" onclick="gesMail(this,3)"><i class="fa fa-pencil"></i></button>
                                <button class="btn btn-danger"  title="Delete Template" onclick="gesMail(this,5)"><i class="fa fa-times"></i></button>
                            </td>
                            <td>
                            </td>
                            <% } %>
                        <tr>
                            <td>
                            </td>
                            <td>&nbsp;</td>
                            <td>&nbsp;</td>
                            <td>&nbsp;</td>
                            <td colspan="2"><input class="form-control"type="text" id="suj" value=""
                                       title="Note: Subject is limited to 64 characters">
                            </td>
                            <td>
                                <button class="btn btn-primary uploadNewBtn">Create new Email</button>
                            </td>
                        </tr>

                    </tbody>
                </table>


                    <h3>Test an existing email</h3>
                    <table class="table table-responsive-sm resultat table-hover table-striped" style="table-layout:fixed">
                        <thead style="border-bottom: solid 1px #edf">
                            <tr>
                                <th>Id</th>
                                <th>Subject</th>
                                <th>Order</th>
                                <th>Order Type</th>
                                <th>Send To</th>
                                <th>&nbsp;</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            rsM = Etn.execute("select * from mails order by id");
                            while(rsM.next())
                            {
                            %>
                            <tr id='t<%=rsM.value("id")%>'>
                                <td>
                                    <%=rsM.value("id")%>
                                </td>
                                <td><%=MimeUtility.decodeText(rsM.value("sujet"))%>
                                </td>
                                <td>1</td>
                                <td><select id='tsel<%=rsM.value("id")%>' onchange="gesMail(this,0)" class="form-control">
                                        <option selected value=0>
                                    <%for(String oType : orderTypes){
										out.write("<option value='"+oType+"'>"+oType+"</option>");
									}%>
                                    </select>
                                </td>
                                <td>
                                    <input type="text" id='to<%=rsM.value("id")%>' value="" class="form-control">
                                </td>
                                <td>
                                  <!-- <input type="button" value="Send a text email"onclick="gesMail(this,4)" > -->
                                   <button class="btn btn-secondary" onclick="gesMail(this,4)">Send a text email</button>
                                </td>
                                <% } %>
                        </tbody>
                    </table>

<form name="f1" method="post">
<input id="delmail" type="hidden" name="todel" value="">
</form>
<!-- Modal -->
<div class="modal fade" id="modalWindow" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="exampleModalLabel">Upload</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
      </div>
	  <div class="modal-footer">
      </div>
    </div>
  </div>
</div>
</div>
</div>
</div>
  </main>
    </div>
</body>
</html>

 <script LANGUAGE="JavaScript" TYPE="text/javascript">
  jQuery(document).ready(function() {
    

    showuploaddialog=function(mailId, lang)
    {
      
      jQuery("#modalWindow").find(".modal-body").html("<form name='uploadForm' id='uploadForm' method='post' enctype='multipart/form-data' action='uploadMail.jsp'><input type='hidden' name='lang' value='"+lang+"'/><input type='hidden' name='mailId' value='"+mailId+"'/><div class='custom-file'><input type='file' class='custom-file-input' id='uploadFile' name='uploadFile'><label class='custom-file-label' for='inputGroupFile02'>Choose file</label></div></form>");
      jQuery("#modalWindow").find(".modal-footer").html("<input type='button' class='btn btn-primary' value='Upload' onclick='onUploadFile()'/>");
      jQuery("#modalWindow").modal('show');
    };

    jQuery(".uploadNewBtn").click(function(){
      //mailId 0 means we need to create a new email and then upload file
      var _suj = jQuery("#suj").val();
      _suj = jQuery.trim(_suj);
      if(_suj == '')
      {
        alert("Subject is mandatory");
        return;
      }
      var mailId = 0;
      jQuery("#modalWindow").find(".modal-body").html("<form name='uploadForm' id='uploadForm' method='post' enctype='multipart/form-data' action='uploadMail.jsp'><input type='hidden' name='subject' value='"+_suj+"'/><input type='hidden' name='mailId' value='"+mailId+"'/><div class='custom-file'><input type='file' class='custom-file-input' id='uploadFile' name='uploadFile'><label class='custom-file-label' for='inputGroupFile02'>Choose file</label></div></form>");
      jQuery("#modalWindow").find(".modal-footer").html("<input type='button' class='btn btn-primary' value='Upload' onclick='onUploadFile()'/>");
      jQuery("#modalWindow").modal('show');

    });

    onUploadFile=function()
    {
      if(jQuery("#uploadFile").val() == '')
      {
        alert("Select a file to upload");
        return;
      }
      jQuery("#uploadForm").submit();
    }

    <%
      String s = request.getParameter("s");
      if (s == null) s = "";
      if(s.equals("0"))
      {
    %>
        alert("Email created successfully");
    <%
      }
      else if(s.equals("1"))
      {
    %>
        alert("Error creating email");
    <%
      }
      else if(s.equals("2"))
      {
    %>
        alert("Email with the given subject already exists");
    <%
      }
	  else if(s.equals("3"))
	  {
		  out.write("alert('Invalid file uploaded.')");
	  }
    %>
  });

</script>


