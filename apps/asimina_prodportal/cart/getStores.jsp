<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, com.etn.beans.app.GlobalParm, java.util.*, org.apache.commons.lang3.*, com.google.gson.*, com.google.gson.reflect.TypeToken, java.lang.reflect.Type"%>
<%@ include file="lib_msg.jsp"%>
<%@ include file="common.jsp"%>
<%!
int parseNullInt(String s)
{
    if (s == null) return 0;
    if (s.equals("null")) return 0;
    if (s.equals("")) return 0;
    return Integer.parseInt(s);
}
%>
<%
    String city = parseNull(request.getParameter("city"));
    int num = parseNullInt(request.getParameter("num"))-1;
    //System.out.println("select * from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".product_comments where product_id="+escape.cote(product_id)+" limit "+num*5+",5");
    Set rsStores = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".stores where city like "+escape.cote("%"+city+"%")+";");
    if(rsStores.rs.Rows==0){
%>
<div class="store o-row" style="display: none;">
  <div class="o-col-sm-12 option">
      <div class="border-light border-top border-bottom" style="padding-top: 15px;padding-bottom: 15px; text-align: center;">
          <%=libelle_msg(Etn, request, "Votre recherche n'affiche aucun résultat")%>
      </div>
  </div>
</div>
<%
    }
    while(rsStores.next()){
%>
<div class="store o-row border-light border-top" style="display: none;">
  <div class="o-col-sm-8 option">
      <div class="" style="padding-top: 15px;padding-bottom: 15px;;">
        <div>
            <div class="custom-control custom-radio custom-control-inline ">
                <input name="store" id="store_<%=rsStores.value("id")%>" class="custom-control-input" value="<%=rsStores.value("id")%>" type="radio" onclick="$('.submit_button').hide();$('#submit_<%=rsStores.value("id")%>').show();">
                <label class="custom-control-label" for="store_<%=rsStores.value("id")%>" style='max-width:400px;'>
                    <strong><%=rsStores.value("location")%></strong><br>
                    <span><%=rsStores.value("address")%></span> <br>
                    <span><%=rsStores.value("city")%></span> <br> <br>
                </label>
            </div>

        </div>
        <div style="padding-left: 30px;">
                  <strong><%=libelle_msg(Etn, request, "Horaires d'ouverture")%></strong>
                  <div style="position:relative;display:inline-block">
                      <span class="o-glyphicon o-glyphicon-info-sign text-info" ></span>
                      <div class="tiny_modal">
                          <%=libelle_msg(Etn, request, "Lundi")%>:<%=(rsStores.value("monday").equals("")?"-":rsStores.value("monday"))%> <br>
                          <%=libelle_msg(Etn, request, "Mardi")%>: <%=(rsStores.value("tuesday").equals("")?"-":rsStores.value("tuesday"))%> <br>
                          <%=libelle_msg(Etn, request, "Mercredi")%>: <%=(rsStores.value("wednesday").equals("")?"-":rsStores.value("wednesday"))%> <br>
                          <%=libelle_msg(Etn, request, "Jeudi")%>: <%=(rsStores.value("thursday").equals("")?"-":rsStores.value("thursday"))%> <br>
                          <%=libelle_msg(Etn, request, "Vendredi")%>: <%=(rsStores.value("friday").equals("")?"-":rsStores.value("friday"))%><br>
                          <%=libelle_msg(Etn, request, "Samedi")%>: <%=(rsStores.value("saturday").equals("")?"-":rsStores.value("saturday"))%><br>
                          <%=libelle_msg(Etn, request, "Dimanche")%>: <%=(rsStores.value("sunday").equals("")?"-":rsStores.value("sunday"))%><br>
                      </div>
                  </div>
        </div>
      </div>
  </div>
  <div class="o-col-sm-4" style="text-align: right;">
         <div class="">
              <i class="o-hidden-xs o-glyphicon o-glyphicon-map-marker"></i>
             <a href="#" style="color:black;margin-top:15px;margin-bottom:40px;display:inline-block;" class="o-hidden-xs "><span class="" style="font-size: 15px; font-weight: bold;"><%=libelle_msg(Etn, request, "Voir la carte")%> </span></a><br>
             <button id="submit_<%=rsStores.value("id")%>" type="button" class="submit_button btn btn-primary o-pull-right" style="display: none;margin-bottom:15px;"><%=libelle_msg(Etn, request, "Étape suivante")%></button>
         </div>
    </div>
</div>
<%
    }
%>