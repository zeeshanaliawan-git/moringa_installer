<div class="aide_info" id="info_critere" style="position: absolute;left: 0%;z-index: 100;"></div>
<form name="f_query">
    <div><!--  style="font-family: trebuchet MS;" -->
    <div style="position: absolute;top: 10px;right: 10px;background: #EEE7F1;"><%--<input class="titre filterButton" type="button" value="<%=libelle_msg(Etn,request,"VALIDER")%>" onclick="saveTimeFilter(document.f_query);" />--%></div>
                
                <table cellpadding="0" cellspacing="0"	border="0" width="100%">                 
                  <tr>
                    <td valign="top" width="40%">
                        <%
                    /*PERIMETRE TEMPS*/
                    //put the variable for fill filtre
                    java.util.HashMap verifTemps = new java.util.HashMap();
					int cpt_date = 0;
					boolean  date_f = false;
					int q = -1;

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
                     <div style="position: absolute;top: 30px;left: 400px;width: 300px;background: #F0F0F6;">
                     <table cellpadding="0" cellspacing="0" border="0" width="100%" align="right" style="margin-top: 5px;margin-bottom: 5px;">
                        <tr>
           	               	<td class="label2" height="20" align="left">&nbsp; <%=libelle_msg(Etn,request,"Le cas &eacute;ch&eacute;ant")%>, <%=libelle_msg(Etn,request,"pr&eacute;ciser le p&eacute;rim&egrave;tre")%> ?</td>
           	            </tr>
           	            <tr>                         
                          	<td class="texte" valign="top">&nbsp; <input type="checkbox" id="filtresemaine"  name="filtresemaine" <%if( verifTemps.get("filtresemaine")!=null){%>checked<%}%> value="<%=filtresemaine%>"></input>
                         	<label for="filtresemaine"><%=libelle_msg(Etn,request,"Semaine sans WE")%></label></td>
                        </tr>
                        <tr>                        	
                        	<td class="texte" valign="top">&nbsp; <input type="checkbox" id="filtreWE"  name="filtreWE" <%if( verifTemps.get("filtreWE")!=null){%>checked<%}%> value="<%=filtreWE%>"></input>
                         	<label for="filtreWE"><%=libelle_msg(Etn,request,"Seulement WE")%></label> 
                         	<font class="texteaide">(<%=libelle_msg(Etn,request,"en diff&eacute;r&eacute; ouvrable sans jours f&eacute;ri&eacute;s")%>)</font></td>
                        </tr>
                     </table>
                     </div>
                     
                     <table cellpadding="0" cellspacing="0" border="0" width="100%" >
                        <tr>
                          <td colspan="2" class="label2" height="20"><b><%=libelle_msg(Etn,request,"S&eacute;lectionner le p&eacute;rim&egrave;tre Temps")%></b>
                          <!-- &nbsp;<input type="button" value=">>" onclick="mettreTemps(document.f_query);">
                          busyhour1 -->

                          </td>
                        </tr>
                        <tr>
                          <td class="texte" colspan="2" style="/*background: #DDCFE3;*/"><font color="#C7AED2">&#9632;</font>&nbsp;<input type="radio" <%if(cpt_date==0){%>checked<%}%> name="r_temps" id="select_r"></input>&nbsp;<label for="select_r"><%=libelle_msg(Etn,request,"Pas de filtre de temps")%></label>
                          </td>
                         </tr>
                        </table>                        
                    </td>
                    <td valign="top" width="60%" >
                 
                      
                    
                    </td>

                  </tr>
                </table>
                 <table cellpadding="0" cellspacing="0"	border="0" width="100%">
                  <tr>
                      <td>
                        
                    

                    <div>


                      <table cellpadding="0" cellspacing="0" border="0" width="600">                        
 						<tr>
                          <td colspan="4" class="label" height="20"><font color="#C7AED2">&#9632;</font>&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript://" onclick="affiche_date(0);"><%=libelle_msg(Etn,request,"Date fixe")%> &#187;</a><br>
                          </td>
                        </tr>
                        <tr id="tr_date_f1" <%if(date_f==false){%>style="display:none;"<%}%>>
                          <td class="texte" >&nbsp;&nbsp;<input type="radio" <%if( verifTemps.get("month")!=null){%>checked<%}%> name="r_temps"></input>&nbsp;<%=libelle_msg(Etn,request,"Mois")%>
                          </td>
                          <td><select name="month">
                            <%String monthName[] = {"","Janvier","Février","Mars","Avril","Mai","Juin","Juillet","Août","Septembre","Octobre","Novembre","Décembre"}; %>
                            <option value="">--- <%=libelle_msg(Etn,request,"sélection")%> ---</option>
                            <%for(int i2=1; i2 < monthName.length; i2++){%>
                            <option <%if( verifTemps.get("month")!=null){if( verifTemps.get("month").equals("month(psdate)="+i2)){
                            %>selected<%}}%> value="<%=i2%>"><%=libelle_msg(Etn,request,monthName[i2])%></option>

                            <%} %>
                            </select>
                           </td>
                           <td></td>
							<td rowspan="4" class="texte" align="center" valign="top" nowrap="nowrap"><%=libelle_msg(Etn,request,"Année")%><br>
                           <%String annee =  (verifTemps.get("year")==null?null:(""+verifTemps.get("year")));
                           if(annee==null){
                        	   annee = "";
                           }else{
                        	   if(annee.indexOf("=")!=-1){ annee = annee.substring(annee.indexOf("=")+1); }
                           }
                           %>
                           <input type="text" size="2" name="year" value="<%=annee%>"><br>
                           <font class="texteaide"><%=libelle_msg(Etn,request,"en cours")%> <%=libelle_msg(Etn,request,"par défaut")%></font>
                           </td>
                         </tr>
                         <tr id="tr_date_f2" <%if(date_f==false){%>style="display:none;"<%}%>>
                          <td class="texte" height="30">&nbsp;&nbsp;<input type="radio" <%if( verifTemps.get("week")!=null){%>checked<%}%>  name="r_temps"></input>&nbsp;Semaine&nbsp;
                          </td>
                          <td><select name="week">
                            <option value="">--- <%=libelle_msg(Etn,request,"sélection")%> ---</option>
                            <%for(int i2=1; i2 <= 52; i2++){%>
                            <option <%if( verifTemps.get("week")!=null){if( verifTemps.get("week").equals("week(psdate)="+i2)){%>selected<%}}%>  value="<%=i2%>"><%=i2%></option>
                            <%}%>
                            </select>
                           </td>
                           <td></td>
                          
                         </tr>
                         <%
                         String psdate[] = {"","","",""};
						    if( verifTemps.get("psdate")!=null){
                         	for(int v=0; v < verifTemps.get("psdate").toString().split(" ").length;v++){
								psdate[v] = verifTemps.get("psdate").toString().split(" ")[v];
                         	}


                         } %>
                          <tr id="tr_date_f3" <%if(date_f==false){%>style="display:none;"<%}%>>
                          <td class="texte">&nbsp;&nbsp;<input type="radio" <%if( verifTemps.get("psdate")!=null){%>checked<%}%> name="r_temps"></input>&nbsp;<%=libelle_msg(Etn,request,"Date du")%>
                          </td>
                          <td class="texte" ><input id="date1" type="text" readonly="readonly" size="8" value="<%=psdate[0]%>" name="date1"> à <input type="text" name="h1" value="<%=psdate[1]%>" size="2"></input>&nbsp;<font class="texteaide"><%=libelle_msg(Etn,request,"hh:mm")%></font></td>
                          <td valign="bottom">
                          	<table width="100%">
	                        	 <tr id="tr_date_f5" <%if(date_f==false){%>style="display:none;"<%}%>>
			                          <td class="texte" align="right">au&nbsp;&nbsp;&nbsp;</td>
			                          <td class="texte" height="20" ><input id="date2" type="text" readonly="readonly" size="8" value="<%=psdate[2]%>" name="date2"> à <input type="text" name="h2" value="<%=psdate[3]%>" size="2"></input>&nbsp;<font class="texteaide"><%=libelle_msg(Etn,request,"hh:mm")%></font></td>
			                        </tr>
			                         
	                        	</table>     
	                        </td>
                          
                        </tr>
                        <tr id="tr_date_f4" <%if(date_f==false){%>style="display:none;"<%}%>>
                        	<td class="texte" valign="top"></td>
                        	<td class="texte" valign="top"><!-- <//%=libelle_msg(Etn,request,"jj/mm/aaaa")%> &nbsp; &nbsp; &nbsp; &nbsp; <//%=libelle_msg(Etn,request,"hh:mm")%> --></td>
                        	<td><table width="100%">	                        	
			                         <tr id="tr_date_f6" <%if(date_f==false){%>style="display:none;"<%}%>>
			                        	<td class="texte" height="0" valign="top"></td>
			                        	<td class="texte" height="0" valign="top"><!-- <//%=libelle_msg(Etn,request,"jj/mm/aaaa")%> &nbsp; &nbsp; &nbsp; &nbsp; <//%=libelle_msg(Etn,request,"hh:mm")%> --></td>
			                        </tr>
	                        	</table></td>
                        	
                        </tr>
                       
						<tr id="tr_date_f7" <%if(date_f==false){%>style="display:none;"<%}%>>
                        	<td class="texte" valign="bottom">&nbsp;&nbsp;<input type="radio" <%if( verifTemps.get("multi_psdate")!=null){%>checked<%}%> name="r_temps"></input>&nbsp;<%=libelle_msg(Etn,request,"Dates")%> <%=libelle_msg(Etn,request,"multiples")%></td>
                        	<td  colspan="3" class="label2" valign="bottom"><input id="multi_psdate" type="text" readonly="readonly" size="60" value="" name="multi_psdate"> <font class="texteaide"><%=libelle_msg(Etn,request,"dates séparées par des virgules")%></font></td>
                        </tr>
                        <tr id="tr_date_f8" <%if(date_f==false){%>style="display:none;"<%}%>>
                        <td class="texte" height="0" valign="top"></td>
                        <td colspan="3" class="texte" height="0" valign="top"></td>
                        </tr>
                      </table>
                    </div>
                  
                      </td>
                  </tr>

               <!--   <tr>

                  	<td colspan="3"><div class="label">&nbsp;<b><%//=libelle_msg(Etn,request,"Période Glissante")%> : </b></div></td>

                 

                  </tr>-->
				<tr>
                          <td colspan="3" class="label" height="20"><font color="#C7AED2">&#9632;</font>&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript://" onclick="affiche_date(1);"><%=libelle_msg(Etn,request,"Période glissante")%> &#187;</a><br>                       
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
<table cellpadding="0" cellspacing="0" border="0" width="550">
 	 	                <!-- <tr>
 	 	                <td colspan="5" class="label2" height="30" valign="bottom">&nbsp;<b><%//=libelle_msg(Etn,request,"Période glissante")%></b> </td>
 	 	                 </tr> -->
 	 	                
 	 	                 
 	 	                  <tr>
 	 	                	<td class="texte" height="20" valign="bottom" width="150">&nbsp;&nbsp;<input type="radio" <%if( verifTemps.get("periode_mois(psdate)")!=null){%>checked<%}%> name="r_temps" id="m_glisant"></input><label for="m_glisant">&nbsp;<%=libelle_msg(Etn,request,"Mois")%></label></td>
	 	 	                <td class="texte" align="right" nowrap="nowrap" width="100"><%=libelle_msg(Etn,request,"de M-")%>&nbsp;</td>
	 	 	                <td class="texte" width="100"><input type="text" size="4" name="mois_glissant1" value="<%=p_psdate3[1]%>" onfocus="affiche_msg_date('mois');" onblur="affiche_msg_date('');"></td>
	 	 	                <td class="texte" align="right" nowrap="nowrap"><%=libelle_msg(Etn,request,"à M-")%>&nbsp;</td>
	 	 	                <td class="texte" width="100"><input type="text" size="4" name="mois_glissant2" value="<%=p_psdate3[2]%>" onfocus="affiche_msg_date('mois');" onblur="affiche_msg_date('');"></td>
	 	 	                
 	 	                 </tr>
 	 	                  <tr>
	 	 	                <td class="texte" height="20" valign="bottom">&nbsp;&nbsp;<input type="radio" <%if( verifTemps.get("periode_semaine(psdate)")!=null){%>checked<%}%> name="r_temps" id="s_glisant"></input><label for="s_glisant">&nbsp;<%=libelle_msg(Etn,request,"Semaine")%></label></td>
	 	 	                <td class="texte" align="right"><%=libelle_msg(Etn,request,"de S-")%>&nbsp;</td>
 	 	                 	<td class="texte"><input type="text" size="4" name="semaine_glissante1" value="<%=p_psdate2[1]%>" onfocus="affiche_msg_date('semaine');" onblur="affiche_msg_date('');"></td>
 	 	                 	<td class="texte" align="right"><%=libelle_msg(Etn,request,"à S-")%>&nbsp;</td>
 	 	                 	<td class="texte"><input type="text" size="4" name="semaine_glissante2" value="<%=p_psdate2[2]%>" onfocus="affiche_msg_date('semaine');" onblur="affiche_msg_date('');"></td>
 	 	                 	
 	 	                 </tr>
 	 	                <tr>
	 	 	                <td class="texte" height="20" valign="bottom">&nbsp;&nbsp;<input type="radio" <%if( verifTemps.get("periode_jour(psdate)")!=null){%>checked<%}%> name="r_temps" id="j_glisant"></input><label for="j_glissant">&nbsp;<%=libelle_msg(Etn,request,"Jour")%></label></td>
	 	 	                <td class="texte" align="right"><%=libelle_msg(Etn,request,"de J-")%>&nbsp;</td>
 	 	                 	<td class="texte"><input type="text" size="4" name="jour_glissant1" value="<%=p_psdate1[1]%>" onfocus="affiche_msg_date('jour');" onblur="affiche_msg_date('');"></td>
 	 	                 	<td class="texte" align="right"><%=libelle_msg(Etn,request,"à J-")%>&nbsp;</td>
 	 	                 	<td class="texte"><input type="text" size="4" name="jour_glissant2" value="<%=p_psdate1[2]%>" onfocus="affiche_msg_date('jour');" onblur="affiche_msg_date('');"></td>
 	 	                 </tr>
 	 	                  <tr>
 	 	                <td colspan="5" class="texteaide" height="20" valign="bottom">
 	 	                &nbsp;<%=libelle_msg(Etn,request,"exemple : de M-0 à M-3 = le mois en cours et les 3 derniers mois;")%>
 	 	 	 	                
 	 	                </td>
 	 	                 </tr> 	 	                 
 	 	             </table>

                  	</td>
                  </tr>
                </table>
    </div>
</form>