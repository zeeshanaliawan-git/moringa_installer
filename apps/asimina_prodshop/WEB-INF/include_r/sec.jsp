<%-- Reviewed By Awais --%>
<%@ include file="/WEB-INF/include_r/lib_msg.jsp"%>
<%@include file="/WEB-INF/include_r/i_top.jsp" %>
<%@include file="/WEB-INF/include_r/inc_variable_constante.jsp" %>
<%
String str_var = "#";

int user_id=0;
boolean isAdmin = false;
Etn.debug=false;
req_ihm ri = new req_ihm();
java.util.HashMap h_query = new java.util.HashMap();
if( Etn.getId() == 0){
response.sendRedirect(com.etn.beans.app.GlobalParm.getParm("URL_REQUETEUR")+"/index.jsp");
if(1==1)return;
}else{

	
	
	user_id =  Etn.getId();

	Variable v = new Variable();
	v.init_variable(request,Etn);
	//init_variable(request,Etn);
	
	
	init_msg(request,Etn);
	
	
	
	if( session.getValue("right_def")==null){
		String str_droit = "";
		com.etn.lang.ResultSet.Set rsF = Etn.execute("select etn_function,r.etn_function_id from responsibility r,etn_function f where r.etn_function_id = f.etn_function_id and r.person_id =" + escape.cote(""+Etn.getId())+ " order by 1 desc ");//change
	while(rsF.next()){
		//session.putValue("func",rsF.value(0));
	
		if( rsF.value(0).equals("admin")){
			session.putValue("isAdmin","1");
		}else{
			session.putValue("isAdmin","0");
		}
		
		str_droit += (str_droit.equals("")?"":",")+rsF.value(0);
	}
	
	String sqlD = "select profil from profilperson p,profil p2 where p.profil_id = p2.profil_id and person_id =" + escape.cote(""+Etn.getId())+ "";//change
	//out.write(sqlD);
	rsF = Etn.execute(sqlD);
	rsF.moveFirst();
	
	while(rsF.next()){
		//session.putValue("func",rsF.value(0));
		//out.write("ici==>"+rsF.value(0));
		str_droit += (str_droit.equals("")?"":",")+rsF.value(0);
	}
	
	session.putValue("right_def","OK");
	//out.write("ici="+str_droit);
	session.setAttribute("str_droit",""+str_droit);
	}

	

	if(session.getValue("isAdmin")!=null){
		if(session.getValue("isAdmin").equals("1")){
			isAdmin = true;
		}
	}else{
		isAdmin = false;
	}


}
%>
<%
//session.putValue("isAdmin","1");

%>
