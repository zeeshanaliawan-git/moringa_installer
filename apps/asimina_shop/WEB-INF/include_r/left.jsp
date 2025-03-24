
<!-- TABLEAU PRINCIPAL -->

<table cellpadding="0" cellspacing="0" border="0" width="98%" align="center" style="margin-top: 0px;" class="tabgauche">
  <tr valign="top">

  <!--  COLONNE GAUCHE -->
    <td valign="top">

    <!-- Div principale de toute la colonne gauche -->

    <div>

      <table id="tab_onglet" longeur="3" width="100%" cellpadding="1" cellspacing="1" border="0">
  <!-- FILTRE -->
        <tr>
    <!-- TITRE FILTRE (ouvert/fermé) -->
          <td class="label" width="33%">
          <div id="onglet0" onclick="toPage(0,'tab_onglet');"><b><%=libelle_msg(Etn,request,"Filtre")%></b></div>
          </td>

    	<!-- TITRE VALEUR (ouvert/fermé) -->
        	<td class="label" width="33%">
        	<div id="onglet1" onclick="toPage(1,'tab_onglet');"><b><%=libelle_msg(Etn,request,"Valeur")%></b></div>
          	</td>
        <!-- lien Agrégation -->
          <td class="label" width="33%">
          <div id="onglet2" onclick="toPage(2,'tab_onglet');"><b><%=libelle_msg(Etn,request,"Agr&eacute;gation")%></b></div>
          </td>
        </tr>
</table>
<table>

    <!-- CONTENU FILTRE -->
        <tr id="liste0" style="display:none;">

    <!-- ONGLETS FILTRE (méthode) -->
          <td class="contentrequete">
          <div class="onglets" style="width: 100%;"  >
          <table class="subonglet" width="100%" bgcolor="#8C5B9D" cellpadding="0" cellspacing="0" border="0" align="center" >
            <tr valign="top">
          <%for (int b = 0; b < onglet_filtre.length; b++) {%>
              <td id="onglet_filtre<%=b%>" width="<%=(100.0/onglet_filtre.length)%>%" style="cursor:pointer;" onclick="toPage2('<%=b%>','tab_onglet_filtre');" ><b><%=libelle_msg(Etn,request,onglet_filtre[b])%></b>
              </td>
          <%} %>
            </tr>
          </table>
          </div>

    <!-- CONTENU ONGLETS FILTRE -->
          <div>
        <!-- Tableau principal de tous les contenus des onglets Filtre -->
          <table  id="tab_onglet_filtre" class="onglet_all" cellpadding="0" cellspacing="0" border="0" style="background-color: white;border-left: 1px solid #B6B7CB;border-right: 1px solid #B6B7CB;border-bottom: 1px solid #B6B7CB" align="center">
            <tr valign="top">
          <!-- FILTRE CONSTRUCTEUR / UR -->
              <td id="liste_filtre0" style="display:none;">
              <div>


                <table cellpadding="0" cellspacing="0"	border="0" width="95%" align="center">
                  <tr>
                    <td valign="top">
                      <table cellpadding="0" cellspacing="0" border="0">
                        <tr>
                          <td class="label" height="25" align="right" ></td>
                        </tr>
                       <tr>
                          <td class="label" height="30">&nbsp;<b><%=libelle_msg(Etn,request,str_filtres1[2])%><div id='str_onglet1' style="display: inline;"><%=onglet_filtre[0].toLowerCase()%></div></b></td>
                        </tr>
						<%
						int q=-1;
						String filtre_s="";
						/* java.util.HashMap verifC = new java.util.HashMap();
			              int q = RetourneIndex(filtres.split(";"),"type");
			              String filtre_s="";

			              if( q > -1){
			                filtre_s = RetourneChaine(filtres,q);
			                String s= RetourneChaine(filtres,q);
			                for(int n=0; n < s.split(",").length;n++){
			                  verifC.put( s.split(",")[n].toUpperCase(),"");
			                  filtre_s = s.split(",")[n];
			                }
			                //out.write("constructeur " + s);
			                //out.write("quoi ca ? " + RetourneChaine(filtres,q));
			              }

			              //out.write("quoi ca ? " + (RetourneChaine(filtres,q)==-1?"":(RetourneChaine(filtres,q))));
			              */
			              %>

                        <%
                        Set rs1 = Etn.execute(ri.getListContexte(Etn,request,h_query)); 
                        //for(int i = 0; i < type.length ;i++){
                          int cpt_type=0;
                        while(rs1.next()){
                      
                        %>
                        <tr>
                          <td class="label"><input <%if(type_elt.toUpperCase().equals(rs1.value("dbtable").toUpperCase())){%>checked<%}%> type="radio" value="<%=rs1.value("dbtable").toUpperCase()%>" name="type1" onclick="filtre2('type1',document.f_query,document.f_query,'type','quoi3');"></input>
                          <div style="display: inline;" id="lab_type<%=cpt_type%>"><%=rs1.value("nom_table_ihm").toUpperCase()%></div>
                          </td>
                        </tr>
                        <%cpt_type++;
                        } %>
                         <tr>
                        	<td class="label" height="10">&nbsp;</td>
                      </table>
                    </td>
                      
                  </tr>
                  </table>
              </div>

		      </td>

          <!-- FILTRE TOPO -->

              <td id="liste_filtre1"  style="display:none;">
              <div>
                <table cellpadding="0" cellspacing="0"	border="0" width="100%">
                  <tr>
                    <td valign="top">
                    <div>
                      <table cellpadding="0" cellspacing="0" border="0" width="100%">
                        <tr>
                          <td class="label" height="10" align="right" valign="bottom"></td>
                        </tr>
                        <tr>
                          <td class="label" height="30"><b>&nbsp; &nbsp; <%=libelle_msg(Etn,request,"1 - S&eacute;lectionner le niveau de Filtre")%></b></td>
                        </tr>
                      </table>
                    <center><iframe src="<%=url_requeteur%>vide0.jsp" style="background-color: transparent;" width="100%" id="ifr_filtres" name="ifr_filtres" height="400" frameborder="0"></iframe></center>
                    </div>
                    </td>
                    <td width="60%" valign="top">
                    <div>
                      <table cellpadding="0" cellspacing="0" border="0" width="100%">
                        <tr>
                          <td class="label" height="10" align="right" valign="bottom"></td>
                        </tr>
                         <tr>
                          <td class="label" height="30"><b>&nbsp; &nbsp; <%=libelle_msg(Etn,request,"2 - R&eacute;sultat de la s&eacute;lection")%></b>
                          </td>
                        </tr>
                      </table>
                      <!-- style="padding-bottom: 100%;" -->
                      <center><iframe src="<%=url_requeteur%>vide0.jsp" width="100%" id="ifr_liste" name="ifr_liste" height="400" frameborder="0"></iframe></center>
                    </div>
                    </td>
                  </tr>
                </table>
              </div>
              </td>

          <!-- FILTRE TEMPS -->

              <td id="liste_filtre2"  style="display:none;">
              <div>
                <table cellpadding="0" cellspacing="0"	border="0" width="100%">
                  <tr>
                  	<td colspan="3">
                  	<div>
                  		<table cellpadding="0" cellspacing="0"	border="0" width="100%" align="center">
                  			<tr>
                  				<td valign="bottom" class="label" align="right"><br>
                        		<input class="valide_critere0" type="button" value="<%=libelle_msg(Etn,request,"VALIDER")%>" onclick="mettreTemps(document.f_query);"></input>
                        		</td>
                  			</tr>
                  		</table>

                  	</div>
                  	</td>

                  </tr>
                  <tr>
                    <td valign="top" width="50%">
                    <div>
                    <%
                    /*PERIMETRE TEMPS*/
                    java.util.HashMap verifTemps = new java.util.HashMap();
					int cpt_date = 0;	
					boolean  date_f = false;
                    
					/*		DATE FIXE		*/
                    
					String p[] = {"month","week","psdate","year"};
					for(int p3=0; p3 < p.length; p3++){

                    q = RetourneIndex(filtres.split(";"),p[p3]);
                        if( q > -1){
                          String s = RetourneChaine(filtres,q);
                          verifTemps.put(p[p3],""+ s.split(",")[1]);
                          cpt_date++;
                          date_f = true;
                        }
					}

                        /*AUTRE OPTION DE TEMPS*/
                         String p2[] = {"filtresemaine","filtreWE"};
                        for(int p4=0; p4 < p2.length; p4++){

                            q = RetourneIndex(filtres.split(";"),p2[p4]);
                                if( q > -1){
                                  String s = RetourneChaine(filtres,q);
                                  verifTemps.put(p2[p4],""+ s.split(",")[1]);
                                  cpt_date++;
                                }
        					}
                        
                      //Période : date du au
                        String psdate2[] = {"","","",""};
					    if( verifTemps.get("psdate")!=null){
                     	for(int v=0; v < verifTemps.get("psdate").toString().split(" ").length;v++){
							psdate2[v] = verifTemps.get("psdate").toString().split(" ")[v];
							 date_f = true;
                     	}
                     }
					    
					 //plusieurs psdate
					 String multi_psdate = "";
					 q = RetourneIndex(filtres.split(";"),"multi_psdate");
					 
					 if( q > -1){
						 String s = RetourneChaine(filtres,q);
						 verifTemps.put("multi_psdate",""+ s.replaceAll("multi_psdate,",""));
						 if( verifTemps.get("multi_psdate")!=null){
							 multi_psdate = (String) verifTemps.get("multi_psdate");
							 verifTemps.put("multi_psdate",multi_psdate);
							 date_f = true;
						 }
					 }   
                        
                        /*		DATE FIXE		*/
                        
                        /*		PERIODE GLISSANTE  		*/
                        
                   /*     String t = "";
                      	String p_psdate[] = {"","",""};

                      	q = RetourneIndex(filtres.split(";"),"periode_mois(psdate)");
                        if( q > -1){
                          String s = RetourneChaine(filtres,q);
                      		for(int v=1; v < s.split(",").length;v++){
                      			p_psdate[v] = s.split(",")[v];
                      			verifTemps.put("periode_mois(psdate)",""+ p_psdate[v]);
                      			cpt_date++;
                      	 }
                        } */
                        
                        /*		PERIODE GLISSANTE  		*/ 
                        
                        /*		PERIODE GLISSANTE  		*/
                        
                        String t = "";
                      	String p_psdate1[] = {"","",""};
                      	String p_psdate2[] = {"","",""};
                      	String p_psdate3[] = {"","",""};
						String p_glissante[]={"periode_jour(psdate)","periode_semaine(psdate)","periode_mois(psdate)"};
                      	
						//for(int i=0;i<p_glissante.length;i++){
							q = RetourneIndex(filtres.split(";"),p_glissante[0]);
	                        if( q > -1){
	                          String s = RetourneChaine(filtres,q);
	                      		for(int v=1; v < s.split(",").length;v++){
	                      			p_psdate1[v] = s.split(",")[v];
	                      			verifTemps.put(""+p_glissante[0],""+ p_psdate1[v]);
	                      			date_f = false; 
	                      	 }
	                        }
	                        q = RetourneIndex(filtres.split(";"),p_glissante[1]);
	                        if( q > -1){
	                          String s = RetourneChaine(filtres,q);
	                      		for(int v=1; v < s.split(",").length;v++){
	                      			p_psdate2[v] = s.split(",")[v];
	                      			verifTemps.put(""+p_glissante[1],""+ p_psdate2[v]);
	                      			date_f = false; 
	                      	 }
	                        }
	                        q = RetourneIndex(filtres.split(";"),p_glissante[2]);
	                        if( q > -1){
	                          String s = RetourneChaine(filtres,q);
	                      		for(int v=1; v < s.split(",").length;v++){
	                      			p_psdate3[v] = s.split(",")[v];
	                      			verifTemps.put(""+p_glissante[2],""+ p_psdate3[v]);
	                      			date_f = false; 
	                      	 }
	                        }
	                        
	                        
	                        
						//}
                        /*		PERIODE GLISSANTE  		*/  
                        
                     %>

                    <div>
                      

                      <table cellpadding="0" cellspacing="0" border="0" >

                        <tr>
                          <td colspan="2" class="label" height="30">&nbsp;<b><%=libelle_msg(Etn,request,"S&eacute;lectionner le p&eacute;rim&egrave;tre Temps")%></b>
                          <!-- &nbsp;<input type="button" value=">>" onclick="mettreTemps(document.f_query);">
                          busyhour1 -->

                          </td>
                        </tr>
                        <tr>
                          <td class="select_label" height="40" colspan="2">&nbsp;&nbsp;<input type="radio" <%if(cpt_date==0){%>checked<%}%> name="r_temps"></input>&nbsp;<%=libelle_msg(Etn,request,"Pas de filtre de temps")%>
                          </td>
                         </tr>
 <tr>
                          <td colspan="3" class="label" height="20">&nbsp;<i><a href="javascript://" onclick="affiche_date(0);"> >> <b><%=libelle_msg(Etn,request,"Date fixe")%></b></a></i><br>                       
                          </td>
                        </tr>
                        <tr id="tr_date_f1" <%if(date_f==false){%>style="display:none;"<%}%>>
                          <td class="select_label" height="40">&nbsp;&nbsp;<input type="radio" <%if( verifTemps.get("month")!=null){%>checked<%}%> name="r_temps"></input>&nbsp;<%=libelle_msg(Etn,request,"Mois")%>
                          </td>
                          <td><select name="month">
                            <%String monthName[] = {"","Janvier","Février","Mars","Avril","Mai","Juin","Juillet","Août","Septembre","Octobre","Novembre","Décembre"}; %>
                            <option value="">--- <%=libelle_msg(Etn,request,"sélection")%> ---</option>
                            <%for(int i=1; i < monthName.length; i++){%>
                            <option <%if( verifTemps.get("month")!=null){if( verifTemps.get("month").equals("month(psdate)="+i)){
                            %>selected<%}}%> value="<%=i%>"><%=libelle_msg(Etn,request,monthName[i])%></option>

                            <%} %>
                            </select>
                           </td>
							<td rowspan="3" class="label" align="center" valign="top"><%=libelle_msg(Etn,request,"Année")%><br>
                           <%String annee =  (verifTemps.get("year")==null?null:(""+verifTemps.get("year")));
                           if(annee==null){
                        	   annee = "";
                           }else{
                        	   if(annee.indexOf("=")!=-1){ annee = annee.substring(annee.indexOf("=")+1); }
                           }
                           %>
                           <input type="text" size="2" name="year" value="<%=annee%>"><br>
                           <font class="select_label">(<%=libelle_msg(Etn,request,"en cours")%><br><%=libelle_msg(Etn,request,"par défaut")%>)</font>
                           </td>
                         </tr>
                         <tr id="tr_date_f2" <%if(date_f==false){%>style="display:none;"<%}%>>
                          <td class="select_label" height="40">&nbsp;&nbsp;<input type="radio" <%if( verifTemps.get("week")!=null){%>checked<%}%>  name="r_temps"></input>&nbsp;Semaine&nbsp;
                          </td>
                          <td><select name="week">
                            <option value="">--- <%=libelle_msg(Etn,request,"sélection")%> ---</option>
                            <%for(int i=1; i <= 52; i++){%>
                            <option <%if( verifTemps.get("week")!=null){if( verifTemps.get("week").equals("week(psdate)="+i)){%>selected<%}}%>  value="<%=i%>"><%=i%></option>
                            <%}%>
                            </select>
                           </td>
                         </tr>
                         <%
                         String psdate[] = {"","","",""};
						    if( verifTemps.get("psdate")!=null){
                         	for(int v=0; v < verifTemps.get("psdate").toString().split(" ").length;v++){
								psdate[v] = verifTemps.get("psdate").toString().split(" ")[v];
                         	}


                         } %>
                          <tr id="tr_date_f3" <%if(date_f==false){%>style="display:none;"<%}%>>
                          <td class="select_label" height="30" valign="bottom">&nbsp;&nbsp;<input type="radio" <%if( verifTemps.get("psdate")!=null){%>checked<%}%> name="r_temps"></input>&nbsp;<%=libelle_msg(Etn,request,"Date du")%> 
                          </td>
                          <td class="select_label" height="30" align="right" valign="bottom"><%=calendrier("date1",psdate[0],"","date1") %> à <input type="text" name="h1" value="<%=psdate[1]%>" size="2"></input></td>
                        </tr>
                        <tr id="tr_date_f4" <%if(date_f==false){%>style="display:none;"<%}%>>
                        	<td class="select_label" height="20" valign="top"></td>
                        	<td class="select_label" height="20" align="center" valign="top"><%=libelle_msg(Etn,request,"jj/mm/aaaa")%> &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <%=libelle_msg(Etn,request,"hh:mm")%></td>
                        </tr>
                        <tr id="tr_date_f5" <%if(date_f==false){%>style="display:none;"<%}%>>
                          <td class="select_label" align="right" valign="bottom">au&nbsp;&nbsp;&nbsp;</td>
                          <td class="select_label" height="20" align="right" valign="bottom"><%=calendrier("date2",psdate[2],"","date2") %> à <input type="text" name="h2" value="<%=psdate[3]%>" size="2"></input></td>
                        </tr>
                         <tr id="tr_date_f6" <%if(date_f==false){%>style="display:none;"<%}%>>
                        	<td class="select_label" height="20" valign="top"></td>
                        	<td class="select_label" height="20" align="center" valign="top"><%=libelle_msg(Etn,request,"jj/mm/aaaa")%> &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <%=libelle_msg(Etn,request,"hh:mm")%></td>
                        </tr>
						<tr id="tr_date_f7" <%if(date_f==false){%>style="display:none;"<%}%>>
                        	<td class="select_label" height="30" valign="bottom">&nbsp;&nbsp;<input type="radio" <%if( verifTemps.get("multi_psdate")!=null){%>checked<%}%> name="r_temps"></input>&nbsp;<%=libelle_msg(Etn,request,"Dates")%><br>
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=libelle_msg(Etn,request,"multiples")%></td>
                        	<td  colspan="2" class="label" height="30" valign="bottom"><%=calendrier3("multi_psdate",multi_psdate," onmouseout=\"affiche_multi_date(0,this);\" onmouseover=\"affiche_multi_date(1,this);\"","multi_psdate") %></td>
                        </tr>
                        <tr id="tr_date_f8" <%if(date_f==false){%>style="display:none;"<%}%>>
                        <td class="select_label" height="20" valign="top"></td>
                        <td colspan="2" class="select_label" height="20" valign="top"><%=libelle_msg(Etn,request,"dates séparées par des virgules")%></td>
                        </tr>
                      </table>
                    </div>

                    </div>
                    </td>
                    <td valign="top" style="border-left: 1px solid silver;">
                    <div>
                      <table cellpadding="0" cellspacing="0" border="0" width="95%" align="right">

                        <tr>
           	               <td colspan="2" class="label" height="30"><b>&nbsp;<%=libelle_msg(Etn,request,"Pr&eacute;ciser le p&eacute;rim&egrave;tre")%> ?</b></td>
                        </tr>
                         <tr>
                          	<td colspan="2" class="label" style="padding-left: 10px;"><br>&nbsp;<%=libelle_msg(Etn,request,"selon Semaine/WE :")%>
                         	</td>
                        </tr>
                        <tr>
                          <td class="label" align="right" valign="top"><input type="checkbox" id="filtresemaine"  name="filtresemaine" <%if( verifTemps.get("filtresemaine")!=null){%>checked<%}%> value="<%=filtresemaine%>"></input>
                          </td>
                          <td class="select_label" height="30" valign="top">&nbsp;<label for="filtresemaine">"<%=libelle_msg(Etn,request,"Semaine (sans WE)")%></label></td>
                        </tr>
                         <tr>
                          <td class="label" align="right" valign="top"><input type="checkbox" id="filtreWE"  name="filtreWE" <%if( verifTemps.get("filtreWE")!=null){%>checked<%}%> value="<%=filtreWE%>"></input>
                          </td>
                          <td class="select_label" height="30" valign="top">&nbsp;<label for="filtreWE"><%=libelle_msg(Etn,request,"Seulement WE")%></label><br>(<small><i><%=libelle_msg(Etn,request,"en diff&eacute;r&eacute; ouvrable (sans jours f&eacute;ri&eacute;s)")%>"</i></small>)</td>
                        </tr>

                      </table>
                    </div>
                    </td>

                  </tr>

               <!--   <tr>

                  	<td colspan="3"><div class="label">&nbsp;<b><%=libelle_msg(Etn,request,"Période Glissante")%> : </b></div></td>

                 

                  </tr>-->
		<tr>
                          <td colspan="3" class="label" height="20">&nbsp;<i><a href="javascript://" onclick="affiche_date(1);"> >> <b><%=libelle_msg(Etn,request,"Date Relative")%></b></a></i><br>                       
                          </td>
                        </tr>

                   <tr  id="tr_date_r" <%if(date_f){%>style="display:none;"<%}%>>
                  	<td colspan="3">
                  		<!-- <table cellpadding="0" cellspacing="0" border="0" width="95%">
 	 	              
 	 	                  <tr>
 	 	                  	 <td colspan="2" class="label" height="30">&nbsp;Mois en cours = 0</td>
 	 	                </tr>
 	 	                 <tr>
 	 	                <td class="select_label" height="30" valign="bottom">&nbsp;&nbsp;<input type="radio" <%if( verifTemps.get("periode_mois(psdate)")!=null){%>checked<%}%> name="r_temps"></input>&nbsp;<%=libelle_msg(Etn,request,"Mois glissant")%>
                          </td>
 	 	                 	<td class="label">de moins <input type="text" size="4" name="periode_mois_1" value="<%=p_psdate3[1]%>">&nbsp;<%=libelle_msg(Etn,request,"à moins")%> <input type="text" size="4" name="periode_mois_2" value="<%=p_psdate3[2]%>"></td>
 	 	                 </tr>
 	 	                 


 	 	                 </table>
-->
<table cellpadding="2" cellspacing="0" border="0" width="100%">
 	 	                <tr>
 	 	                <td colspan="5" class="select_label" height="30" valign="bottom"><%=libelle_msg(Etn,request,"Période glissante")%> </td>
 	 	                 </tr>
 	 	                
 	 	                 
 	 	                  <tr>
 	 	                	<td class="label" height="30" valign="bottom">&nbsp;&nbsp;<input type="radio" <%if( verifTemps.get("periode_mois(psdate)")!=null){%>checked<%}%> name="r_temps" id="m_glisant"></input><label for="m_glisant">&nbsp;<%=libelle_msg(Etn,request,"Mois")%></label></td>
	 	 	                <td class="select_label" align="right" valign="bottom" nowrap="nowrap"><%=libelle_msg(Etn,request,"de M-")%></td>
	 	 	                <td class="label"><input type="text" size="4" name="mois_glissant1" value="<%=p_psdate3[1]%>" onfocus="affiche_msg_date('mois');" onblur="affiche_msg_date('');"></td>
	 	 	                <td class="select_label" valign="bottom" nowrap="nowrap"><%=libelle_msg(Etn,request,"à M-")%></td>
	 	 	                <td class="label"><input type="text" size="4" name="mois_glissant2" value="<%=p_psdate3[2]%>" onfocus="affiche_msg_date('mois');" onblur="affiche_msg_date('');"></td>
	 	 	                
 	 	                 </tr>
 	 	                  <tr>
	 	 	                <td class="label" height="30" valign="bottom">&nbsp;&nbsp;<input type="radio" <%if( verifTemps.get("periode_semaine(psdate)")!=null){%>checked<%}%> name="r_temps" id="s_glisant"></input><label for="s_glisant">&nbsp;<%=libelle_msg(Etn,request,"Semaine")%></label></td>
	 	 	                <td class="select_label" align="right" valign="bottom"><%=libelle_msg(Etn,request,"de S-")%></td>
 	 	                 	<td class="label"><input type="text" size="4" name="semaine_glissante1" value="<%=p_psdate2[1]%>" onfocus="affiche_msg_date('semaine');" onblur="affiche_msg_date('');"></td>
 	 	                 	<td class="select_label" valign="bottom"><%=libelle_msg(Etn,request,"à S-")%></td>
 	 	                 	<td class="label"><input type="text" size="4" name="semaine_glissante2" value="<%=p_psdate2[2]%>" onfocus="affiche_msg_date('semaine');" onblur="affiche_msg_date('');"></td>
 	 	                 	
 	 	                 </tr>
 	 	                <tr>
	 	 	                <td class="label" height="30" valign="bottom">&nbsp;&nbsp;<input type="radio" <%if( verifTemps.get("periode_jour(psdate)")!=null){%>checked<%}%> name="r_temps" id="j_glisant"></input><label for="j_glissant">&nbsp;<%=libelle_msg(Etn,request,"Jour")%></label></td>
	 	 	                <td class="select_label" align="right" valign="bottom"><%=libelle_msg(Etn,request,"de J-")%></td>
 	 	                 	<td class="label"><input type="text" size="4" name="jour_glissant1" value="<%=p_psdate1[1]%>" onfocus="affiche_msg_date('jour');" onblur="affiche_msg_date('');"></td>
 	 	                 	<td class="select_label" valign="bottom"><%=libelle_msg(Etn,request,"à J-")%></td>
 	 	                 	<td class="label"><input type="text" size="4" name="jour_glissant2" value="<%=p_psdate1[2]%>" onfocus="affiche_msg_date('jour');" onblur="affiche_msg_date('');"></td>
 	 	                 </tr>
 	 	                  <tr>
 	 	                <td colspan="5" class="select_label" height="30" valign="bottom">
 	 	                <br><%=libelle_msg(Etn,request,"exemple : de M-0 à M-3 (le mois en cours et les 3 derniers mois")%></td>
 	 	                 </tr>
 	 	               
 	 	               
 	 	                 
 	 	                 </table>

                  	</td>
                  </tr>
                </table>
              </div>
              </td>




          </tr>
          </table>

            </div>

        <!-- Fin du contenu de Filtre -->
          </td>
        </tr>

  <!------ VALEUR ----------------------------------------------------------------------------->



    <!-- CONTENU VALEUR -->
        <tr id="liste1" style="display:none;">

    <!-- ONGLETS VALEUR (méthode) -->
          <td class="contentrequete">

          <div class="onglets" style="width: 100%;">
            <table width="100%" bgcolor="#EF6215" cellpadding="0" cellspacing="0"	border="0" align="center" style="color: white;border-top: 1px solid white;border-right: 1px solid white;border-left: 1px solid white;">
              <tr valign="top">
              <%for (int b = 0; b < onglet_valeur.length; b++) {%>
                <td id="onglet_valeur<%=b%>" width="<%=(100.0/onglet_valeur.length)%>%" style="cursor:pointer;" onclick="toPage3('<%=b%>','tab_onglet_valeur');"><b><%=libelle_msg(Etn,request,onglet_valeur[b])%></b></td>
              <%} %>
              </tr>
            </table>
          </div>

    <!-- CONTENU ONGLETS VALEUR -->
          <div>

        <!-- Tableau principal de tous les contenus des onglets Valeur -->
            <table  id="tab_onglet_valeur" class="onglet_all" cellpadding="0" cellspacing="0" border="0" style="background-color: white;border-left: 1px solid #B6B7CB;border-right: 1px solid #B6B7CB;border-bottom: 1px solid #B6B7CB" align="center">
              <tr valign="top">

          <!------ VALEUR 0 : KPI ------------------------>
                <td id="liste_valeur0" align="center"  style="display:none;">
               <div>
                <iframe src="<%=url_requeteur%>vide1.jsp" id="ifr_compteur" name="ifr_compteur" width="100%" height="420" frameborder="0" ></iframe>
	  			<%=calculatrice("liste_c1")%>
               	</div>
                </td>

          <!------  CHAMPS ------------------------>
                <td id="liste_valeur1"  style="display:none;">

                <!-- ***** Liste des champs des tables du catalogue *****-->
                <div>

                <iframe src="<%=url_requeteur%>vide1.jsp" id="ifr_compteur2" name="ifr_compteur2" width="100%" height="420" frameborder="0" ></iframe>
	  			<%=calculatrice("liste_c2")%>
               	</div>

                </td>

 		<!------  COMPTEUR - VALEUR  ------------------------>
                <td id="liste_valeur2"  style="display:none;">

                <!-- ***** Liste des champs des tables du catalogue *****-->
                <div>
                <center><iframe src="<%=url_requeteur%>vide1.jsp" id="ifr_kpi" name="ifr_kpi" width="100%"  height="420" frameborder="0"></iframe></center>
               	<%=calculatrice("liste_c3")%>
                </div>

                </td>


              </tr>
            </table>

          </div>
          </td>
        </tr>

      <!------***** AGREGATION *****----------------------------------------------------------------------------->
        <tr id="liste2" style="display:none;">
        <!-- contenu Agrégation -->
          <td class="contentrequete">
            <div class="onglets" style="width: 100%;">
              <table width="100%" bgcolor="#8DBE21" cellpadding="0" cellspacing="0"	border="0" align="center" style="color: white;border-top: 1px solid white;border-right: 1px solid white;border-left: 1px solid white;">
                <tr valign="top">
              <%for (int b = 0; b < onglet_agregation.length; b++) {%>
                <td id="onglet_agregation<%=b%>" width="<%=(100.0/onglet_agregation.length)%>%" style="cursor:pointer;" onclick="toPage4('<%=b%>','tab_onglet_agregation');"><b><%=libelle_msg(Etn,request,onglet_agregation[b])%></b></td>							<%} %>
                </tr>
              </table>
            </div>

                <div>
        <!-- les onglets AGREGATION-->

          <table  id="tab_onglet_agregation" class="onglet_all" cellpadding="0" cellspacing="0" border="0" style="background-color: white;border-left: 1px solid #B6B7CB;border-right: 1px solid #B6B7CB;border-bottom: 1px solid #B6B7CB" align="center">
          <tr valign="top">

          <!------ ONGLET AGREGATION 0 ------------------------>
			<%
			String p5[] = {"annee(psdate)","mois(psdate)","semaine(psdate)","jour(psdate)","heure(psdate)","minute(psdate)"};
			String p7[] = {"Année","Mois","Semaine","Jour","Heure","Minute"}; 
			String p8[] = {"AAAA (ou AA)","MM/AAAA","AAAA-S.","JJ/MM/AAAA","JJ/MM/AAAA HH","JJ/MM/AAAA HH:MM"};

			//String p5[] = {"hour(psdate)","day(psdate)","week(psdate)","month(psdate)","year(psdate)"};
			//String p7[] = {"Heure","Jour","Semaine","Mois","Année"};


			java.util.HashMap verifAgregation_h = new java.util.HashMap();
			java.util.HashMap verifAgregation_v = new java.util.HashMap();

                String a_h[] =  agregations_h.split(",");
				for(int a2=0;a2 < a_h.length;a2++){
					verifAgregation_h.put(""+a_h[a2],""+a_h[a2]);
                    // out.write("a)"+a[a2]);
				}
				 String a_v[] =  agregations_v.split(",");
					for(int a2=0;a2 < a_v.length;a2++){
						verifAgregation_v.put(""+a_v[a2],""+a_v[a2]);
	                    // out.write("a)"+a[a2]);
					}
			%>
          <td id="liste_agregation0"  style="display:none;">
          <div>
            	<table cellpadding="0" cellspacing="0"	border="0" width="100%" style="padding-left: 10px;">
             		<tr>
                		<td colspan="2" class="label" height="25" align="right" valign="bottom"></td>
             		</tr>
              		<tr>
                		<td class="label" height="30" ><b>&nbsp;&nbsp;<%=libelle_msg(Etn,request,"Grouper par p&eacute;riode")%> ?</b></td>
                		<td class="label" align="right"><input class="valide_critere2" type="button" value="<%=libelle_msg(Etn,request,"VALIDER")%>" onclick="mettreGroupe(document.f_query,document.f_query,'agreg');"></td>

              		</tr>
              	</table>
              	<br>
              	<table cellpadding="0" cellspacing="0"	border="0" width="100%" style="padding-left: 10px;">
             		<tr>
             <% for(int p6=0; p6 < p5.length; p6++){ %>
              		<tr>
                		<td width="30%" class="select_label" height="25" style="padding-left: 30px;">&nbsp;<input type="checkbox" onclick="mettreD('<%=p6%>','<%=p5[p6]%>');" name="agreg" id="agreg<%=p6%>" <%if( verifAgregation_h.get(""+p5[p6])!=null){%>checked<%}%> <%if( verifAgregation_v.get(""+p5[p6])!=null){%>checked<%}%>  value="<%=p5[p6]%>" ></input>&nbsp;<label for="agreg<%=p6%>"><%=libelle_msg(Etn,request,p7[p6])%></label></td>
                		<td class="label" align="left">
               				<select name="type_aff_agreg" id="type_aff_agreg">
								<option <%if( verifAgregation_v.get(""+p5[p6])!=null){%>selected<%}%> value="vertical"><%=libelle_msg(Etn,request,"Ligne")%></option>
								<option <%if( verifAgregation_h.get(""+p5[p6])!=null){%>selected<%}%> value="horizontal"><%=libelle_msg(Etn,request,"Colonne")%></option>
							</select>
                		</td>
                		<td class="label">
                		<small><u><%=libelle_msg(Etn,request,"Format")%> </u> : <%=libelle_msg(Etn,request,p8[p6])%></small>
                		</td>
              		</tr>
			<%} %>
	        <tr>
	        	<td class="label"><small></small></td>
	        </tr>
	        </table>


          </div>



          </td>

          <!------ ONGLET AGREGATION 1 : EQUIPEMENT ------------------------>

          <td id="liste_agregation1"  style="display:none;">
            <div>

              <table cellpadding="0" cellspacing="0" border="0" width="100%">
              <tr>
                <td class="label" height="25" align="right" valign="bottom"></td>
              </tr>
              <tr>
                <td class="label" height="30" style="padding-left: 10px;">&nbsp;&nbsp;<b><%=libelle_msg(Etn,request,"Grouper par  ?")%></b></td>
              </tr>
              </table>
              <div>

                <center><iframe src="<%=url_requeteur%>vide2.jsp" id="ifr_equipement" name="ifr_equipement" width="100%"  height="400" frameborder="0"></iframe></center>

                </div>
              <table cellpadding="0" cellspacing="0"	border="0" width="100%">
              <tr>
                <td class="label" height="5" align="right" valign="bottom"></td>
              </tr>
              </table>

            </div>
          </td>
          
          
          <td id="liste_agregation2"  style="display:none;">
            <div>

              <table cellpadding="0" cellspacing="0" border="0" width="100%">
              <tr>
                <td class="label" height="25" align="right" valign="bottom"></td>
              </tr>
              <tr>
                <td class="label" height="30" style="padding-left: 10px;">&nbsp;&nbsp;<b><%=libelle_msg(Etn,request,"Ordonner par  ?")%></b></td>
              </tr>
              </table>
              <div>

                <center><iframe src="<%=url_requeteur%>vide2.jsp" id="ifr_ordre" name="ifr_ordre" width="100%"  height="400" frameborder="0"></iframe></center>

                </div>
              <table cellpadding="0" cellspacing="0"	border="0" width="100%">
              <tr>
                <td class="label" height="5" align="right" valign="bottom"></td>
              </tr>
              </table>

            </div>
          </td>

          </tr>
          </table>

            </div>

          </td>
        </tr>


      </table>

    <!-- Fin Div principale -->
    </div>
    <!-- Fin Colonne gauche -->
    </td>


  </tr>
</table>

