<%-- Reviewed By Awais --%>
<%@ include file="/WEB-INF/include_r/lib_msg.jsp"%>
<%@include file="/WEB-INF/include_r/i_top.jsp" %>
<%@include file="/WEB-INF/include_r/inc_variable_constante.jsp" %>
<%@ page import="com.etn.util.Decode64"%>
<%@ page import="com.etn.sql.escape"%>
<%

String titre =  GlobalParm.getParm("APPLI");
titre = titre.toUpperCase();
boolean isAdmin = false;

if( Etn.getId() == 0 )
{
  String auth = request.getHeader("Authorization");

  if(auth == null )
  {
   response.setStatus(401);
   response.setHeader("Pragma","No-cache");
   response.setHeader("Cache-Control","no-cache");
   response.setHeader("Expires",new Date(System.currentTimeMillis()+60000).toString());
   response.setHeader("WWW-Authenticate","Basic realm=\""+titre+"\"");

   return;
  }

  StringTokenizer st = new StringTokenizer(auth);
  String mode = st.nextToken();

  ByteArrayOutputStream b = new ByteArrayOutputStream();
  Decode64 d = new Decode64(b,st.nextToken());

  st = new StringTokenizer(b.toString(),":");

 String n = null;
 String p = null;

 if(st.hasMoreElements() ) n = st.nextToken();
 if(st.hasMoreElements() ) p = st.nextToken();

 if( n!= null && p != null )
 {
   if( Etn.getId() == 0 );
   //GlobalParm.init(session.getServletContext().getInitParameter("etnconf")  );
   else
     Etn.close();
   if( n.length() < 64 && p.length() < 64 )
   { n = escape.sql(n.trim()); p = escape.sql(p.trim());
     if( n.length() > 0 && p.length() > 0 )
      Etn.setContexte(n,p) ;
   }

 }
 else
   Etn.close();

if( Etn.getId() == 0 )
 {
	
	
	response.setStatus(401);
   response.setHeader("Pragma","No-cache");
   //response.setHeader("WWW-Authenticate","Basic realm=\""+ur+"\"");
   response.setHeader("WWW-Authenticate","Basic realm=\""+titre+"\"");
 //  return;
 
   
 
 }
}

int user_id=0;

//Etn.debug=true;
if( Etn.getId() != 0){
	
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