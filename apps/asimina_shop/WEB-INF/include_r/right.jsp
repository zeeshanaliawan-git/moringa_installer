
<!------ TABLEAU PRINCIPAL ------------------------------------------------------>

<table cellpadding="0" cellspacing="0" border="0" width="99%" align="center" >
	<tr valign="top">

		<!------ COLONNE DROITE : critères sélectionnés ------------------------>

		<td align="CENTER" valign="top">
		<div>
			<div class="h1_tabdr"><!-- <img src="img/circle.png" border="0"> --><b><%=libelle_msg(Etn,request,"CRITERES SELECTIONNES")%></b></div>
			<div>
			<table border="0" cellpadding="0" cellspacing="3" class="right_all" align="center" width="100%">
				<tr>
					<td class="label0" align="center">
						<table border="0" cellspacing="0" cellpadding="0" width="100%" style="background-color: #8C5B9D;border-left: 1px solid white; border-right: 1px solid #B6B7CB;">
							<tr>
								<td style="font-size: 8pt; color: white;">&nbsp;&nbsp;<%=libelle_msg(Etn,request,"FILTRE")%> </td>
								<td width="10%">

								<input type="button" id="modif_filtre" onclick="edit_filtre(0);" 	value="<%=libelle_msg(Etn,request,"Modifier")%>" class="modifselect" style="background-color: #EEE7F1;border: 3px solid #8C5B9D;"></input>
								<input type="button" id="cache_filtre" onclick="edit_filtre(1);" value="<%=libelle_msg(Etn,request,"VALIDER x")%>" class="modifselect" style="background-color: #EEE7F1;border: 3px solid #8C5B9D;display:none;color: black;text-decoration: underline;font-weight: normal;"></input>
								</td>
							</tr>
						</table>
						<div id="p2" class="lab_select0">&nbsp;</div>	<!-- Filtre : alisation -->

		              	<div id="edition_filtre" style="display:none;">	<!-- FILTRE AVANCE -->
		              		<table cellpadding="0" cellspacing="0" border="0" width="100%" class="lab_select1">
	                   			<tr>
	                   				<td>
		              				<table cellpadding="0" cellspacing="0"	border="0" width="100%">
		                  				<tr>
		                   					<td class="label">&nbsp;<b><%=libelle_msg(Etn,request,"Filtre avanc&eacute")%>; :</b>
		                   					&nbsp;<%=libelle_msg(Etn,request,"Ajouter ou modifier des crit&egrave;res")%>
		                   					</td>
		                  				</tr>
		                 				<tr>
		                   					<td align="center"><textarea class="critere_modify" id="filtre" name="filtre" cols="75" rows="3"></textarea>

		                    				</td>
		                  				</tr>
		                			</table>
		                			</td>
		                		</tr>
		                	</table>
		              </div>
		              <table border="0" cellspacing="0" cellpadding="0" width="100%" style="background-color: #EF6215;border-left: 1px solid white; border-right: 1px solid #B6B7CB;">
		              	<tr>
							<td style="font-size: 8pt; color: white;">&nbsp;&nbsp;<%=libelle_msg(Etn,request,"VALEUR/KPI")%></td>
							<td width="10%">
							<input type="button" value="<%=libelle_msg(Etn,request,"Modifier")%>" id="modif_valeur"
							onclick="edit_valeur(0);" class="modifselect" style="background-color: #FFDEBF;border: 3px solid #EF6215;"></input>
							<input type="button" value="<%=libelle_msg(Etn,request,"VALIDER x")%>" id="cache_valeur"
							onclick="edit_valeur(1);" class="modifselect" style="background-color: #FFDEBF;border: 3px solid #EF6215;display: none;color: black;text-decoration: underline;font-weight: normal;"></input>
							</td>
						</tr>
					</table>
					<div id="p3" class="lab_select1">&nbsp;</div>

	                <div id="edition_valeur" style="display:none;">
	                   <table cellpadding="0" cellspacing="0" border="0" width="100%" class="lab_select1">
	                   		<tr>
	                   			<td>

	                  		<table id="tabValeur" cellpadding="0" cellspacing="0"	border="0" width="100%">
	                    	<tr>
	                    		<td class="label">&nbsp;<b><%=libelle_msg(Etn,request,"Valeur avanc&eacute;e")%> :</b>
	                    		&nbsp;<%=libelle_msg(Etn,request,"Ajouter ou modifier des crit&egrave;res")%>
	                    		</td>
	                     		<td align="right"><!-- <input type="button" style="background-color: #EF6215;color: white;font-size: 7pt;width:80px;" value=">>VALIDER<<" onclick="mettreV(document.f_query,document.f_query,'val1');"> --></td>
	                    	</tr>
	                    	<tr>
	                     		<td colspan="2" align="center"><textarea class="critere_modify" id="val1" name="val1" cols="75" rows="10"></textarea>

	                     		</td>
	                    	</tr>
	                  		</table>
	                  			</td>
	                  		</tr>
	                  </table>
	                </div>
	               
					<table border="0" cellspacing="0" cellpadding="0" width="100%" style="background-color: #8DBE21;border-left: 1px solid white; border-right: 1px solid #B6B7CB;">
						<tr>
							<td style="font-size: 8pt; color: white;">&nbsp;&nbsp;<%=libelle_msg(Etn,request,"AGREGATION PAR LIGNES")%> </td>
							<td width="10%">
							<input type="button" onclick="edit_agreg_v(0);" value=<%=libelle_msg(Etn,request,"Modifier")%> class="modifselect" id="modif_agreg_v" style="background-color: #E5F9C0;border: 3px solid #8DBE21;"></input>
							<input type="button" onclick="edit_agreg_v(1);" value=<%=libelle_msg(Etn,request,"VALIDER x")%> id="cache_agreg_v" class="modifselect" style="background-color: #E5F9C0;border: 3px solid #8DBE21;display: none;color: black;text-decoration: underline;font-weight: normal;"></input>
							</td>
						</tr>
					</table>

					<div id="p1v" class="lab_select2">&nbsp;</div>

					<div id="edition_agreg_v" style="display:none;">
						<table cellpadding="0" cellspacing="0"	border="0" width="100%" class="lab_select2">
							<tr>
								<td>
				          			<table id="tabAgreg" cellpadding="0" cellspacing="0" border="0" width="100%">
				         				 <tr>
				         				 	<td class="label">&nbsp;<b><%=libelle_msg(Etn,request,"Agr&eacute;gation par Lignes avanc&eacute;e")%> :</b>
				         				 	&nbsp;<%=libelle_msg(Etn,request,"Ajouter ou modifier des crit&egrave;res")%>
				         				 	</td>
				            				<td class="label" align="right" valign="bottom">
				            				<!-- <input type="button" style="background-color: #8DBE21;color: white;font-size: 7pt;width:80px;" value=">>VALIDER<<" onclick="mettreGroupe(document.f_query,document.f_query,'agreg_avancee_v');"> --></td>
				                 		 </tr>
							  			<tr>
				            				<td colspan="2" align="center"><textarea class="critere_modify" id="agreg_avancee_v" name="agreg_avancee_v" cols="75" rows="3"></textarea>

				          					</td>
				          				</tr>

				          			</table>
				         		</td>
				         	</tr>
				         </table>
					</div>


					<table border="0" cellspacing="0" cellpadding="0" width="100%" style="background-color: #8DBE21;border-left: 1px solid white; border-right: 1px solid #B6B7CB;">
						<tr>
							<td style="font-size: 8pt; color: white;">&nbsp;&nbsp;<%=libelle_msg(Etn,request,"AGREGATION PAR COLONNES")%> </td>
							<td width="10%">
							<input type="button" onclick="edit_agreg_h(0);" value=<%=libelle_msg(Etn,request,"Modifier")%> id="modif_agreg_h" class="modifselect" style="background-color: #E5F9C0;border: 3px solid #8DBE21;"></input>
							<input  onclick="edit_agreg_h(1);" type="button" value=<%=libelle_msg(Etn,request,"VALIDER x")%> id="cache_agreg_h" class="modifselect" style="background-color: #E5F9C0;border: 3px solid #8DBE21;display: none;color: black;text-decoration: underline;font-weight: normal;"></input>

							</td>
						</tr>
					</table>
					<div id="p1h" class="lab_select2">&nbsp;</div>

					<div id="edition_agreg_h" style="display:none;">

						<table cellpadding="0" cellspacing="0"	border="0" width="100%" class="lab_select2">
							<tr>
								<td>
                				  	<table id="tabAgreg" cellpadding="0" cellspacing="0" border="0" width="100%">
          				 				<tr>
          				 					<td class="label">&nbsp;<b><%=libelle_msg(Etn,request,"Agr&eacute;gation par Colonnes avanc&eacute;e")%> :</b>
          				 					&nbsp;<%=libelle_msg(Etn,request,"Ajouter ou modifier des crit&egrave;res")%>
          				 					</td>
          				 					<td class="label" align="right" valign="bottom">
          				 					<!-- <input type="button" style="background-color: #8DBE21;color: white;font-size: 7pt;width:80px;" value=">>VALIDER<<" onclick="mettreGroupe(document.f_query,document.f_query,'agreg_avancee_h');"> --></td>
				         				 </tr>
				         				 <tr>
            								<td colspan="2" align="center"><textarea class="critere_modify" id="agreg_avancee_h" name="agreg_avancee_h" cols="75" rows="3"></textarea>

            								</td>
          								</tr>
          							</table>
          						</td>
          					</tr>
          				</table>
					</div>
					
					
					<table border="0" cellspacing="0" cellpadding="0" width="100%" style="background-color: #8DBE21;border-left: 1px solid white; border-right: 1px solid #B6B7CB;">
						<tr>
							<td style="font-size: 8pt; color: white;">&nbsp;&nbsp;<%=libelle_msg(Etn,request,"ORDRE")%> </td>
							<td width="10%">
							<input type="button" onclick="edit_ordre(0);" value=<%=libelle_msg(Etn,request,"Modifier")%> id="modif_ordre" class="modifselect" style="background-color: #E5F9C0;border: 3px solid #8DBE21;"></input>
							<input  onclick="edit_ordre(1);" type="button" value=<%=libelle_msg(Etn,request,"VALIDER x")%> id="cache_ordre" class="modifselect" style="background-color: #E5F9C0;border: 3px solid #8DBE21;display: none;color: black;text-decoration: underline;font-weight: normal;"></input>

							</td>
						</tr>
					</table>
					
					<div id="p_ordre" class="lab_select2">&nbsp;</div>

					<div id="edition_ordre" style="display:none;">

						<table cellpadding="0" cellspacing="0"	border="0" width="100%" class="lab_select2">
							<tr>
								<td>
                				  	<table id="tabOrder" cellpadding="0" cellspacing="0" border="0" width="100%">
          				 				<tr>
          				 					<td class="label">&nbsp;<b><%=libelle_msg(Etn,request,"ORDRE")%> :</b>
          				 					&nbsp;<%=libelle_msg(Etn,request,"Ajouter ou modifier des crit&egrave;res")%>
          				 					</td>
          				 					<td class="label" align="right" valign="bottom"></td>
				         				 </tr>
				         				 <tr>
            								<td colspan="2" align="center"><textarea class="critere_modify" id="t_ordre" name="t_ordre" cols="75" rows="3"></textarea>

            								</td>
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
			
			<div class="h2_tabdr"><b><%=libelle_msg(Etn,request,"REPRESENTATION")%></b></div>
			<div>
				<fieldset style="border: 1px solid #9B9DB1;width: 95%;">
					<legend><%=libelle_msg(Etn,request,"Consulter")%></legend>
					<table cellpadding="1" cellspacing="1" border="0" width="100%">
						<!-- <tr>
							<td rowspan="2" width="15%" align="center"><img src="img/view.png" border="0"></td>
							<td class="label">Afficher les 10 premi&egrave;res lignes du r&eacute;sultat</td>
							<td align="right"><input class="check" type="button" onclick="prev();" value="Aperçu ..."></input></td>
						</tr> -->
						<tr>
							<td width="15%" align="center"><img src="img/view.png" border="0"></td>
							<td class="label"><%=libelle_msg(Etn,request,"Afficher le r&eacute;sultat global")%> *</td>
							<td align="right"><input class="check" type="submit" value="<%=libelle_msg(Etn,request,"Visualiser ...")%>" title="<%=libelle_msg(Etn,request,"Afficher le résultat de la requ&ecirc;te afin de l'exécuter sans l'enregistrer")%>" style="width:150px;"></input></td>
						</tr>
						<tr>
							<td align="right" colspan="3"><%
							if(requete_id != null && !requete_id.equals("0"))
								//out.write("<td><a href='graph_visu.jsp?requete_id_trans="+requete_id+"' target='_blank'>Graph</a></td>");
								out.write("<input style=\"width:150px;\" class=\"check\" onclick=\" var w =window.open('chart/graph_visu.jsp?requete_id_trans="+requete_id+"','graphique','toolbar=no,location=no,status=no,menubar=no,scrollbars=yes,resizable=yes');w.focus();\" type=\"button\" value=\""+libelle_msg(Etn,request,"Editer un graphique")+"\" title=\""+libelle_msg(Etn,request,"Créer, modifier ou consulter le graphique de la requ&ecirc;te")+"\"></input>");
							%>
							</td>
						</tr>
					</table>
					 
					 <div id="affichage_resultat">
					 <table>
	                  <tr><td  class="label"><b><u><%=libelle_msg(Etn,request,"Afficher les résultats")%></u> :</b><br>
	                  <input type="radio" <%=(type_aff.equals("0")?"checked":"") %> name="type_aff" value="0" onmouseover="affiche_info('info_affichage_resultat',1,'<%=libelle_msg(Etn,request,"Valeur/KPI et agrégation en ligne")%>');" onmouseout="affiche_info('info_affichage_resultat',0,'');"><%=libelle_msg(Etn,request,"en ligne")%> 
					  <input type="radio" <%=(type_aff.equals("1")?"checked":"") %> name="type_aff" value="1" onmouseover="affiche_info('info_affichage_resultat',1,'<%=libelle_msg(Etn,request,"Valeur/KPI en colonne / agrégation en ligne/colonne")%>');"  onmouseout="affiche_info('info_affichage_resultat',0,'');" onclick="if(document.getElementById('agregations_h').value==''){alert('<%=libelle_msg(Etn,request,"Vous n avez pas sélectionnée d agréation par colonnes !")%>');this.checked=false;}"><%=libelle_msg(Etn,request,"en ligne/colonne")%> 
					  <input name="type_aff" <%=(type_aff.equals("2")?"checked":"") %> value="2" type="radio" onmouseover="affiche_info('info_affichage_resultat',1,'<%=libelle_msg(Etn,request,"Valeur/KPI en ligne / agrégation en ligne/colonne")%>');"  onmouseout="affiche_info('info_affichage_resultat',0,'');" onclick="if(document.getElementById('agregations_h').value==''){alert('<%=libelle_msg(Etn,request,"Vous n avez pas sélectionnée d agréation par colonnes !")%>');this.checked=false;}"><%=libelle_msg(Etn,request,"en ligne/colonne")%>
					  <input name="type_aff" <%=(type_aff.equals("4")?"checked":"") %> value="4" type="radio" onmouseover="affiche_info('info_affichage_resultat',1,'<%=libelle_msg(Etn,request,"Valeur/KPI en ligne / agrégation en ligne/colonne")%>');"  onmouseout="affiche_info('info_affichage_resultat',0,'');" onclick="if(document.getElementById('agregations_h').value==''){alert('<%=libelle_msg(Etn,request,"Vous n avez pas sélectionnée d agréation par colonnes !")%>');this.checked=false;}"><%=libelle_msg(Etn,request,"en ligne/colonne bis")%>
					  <input name="type_aff" <%=(type_aff.equals("3")?"checked":"") %> value="3" type="radio" onmouseover="affiche_info('info_affichage_resultat',1,'<%=libelle_msg(Etn,request,"Valeur/KPI en ligne / agrégation en ligne/colonne")%>');"  onmouseout="affiche_info('info_affichage_resultat',0,'');" onclick="if(document.getElementById('agregations_h').value==''){alert('<%=libelle_msg(Etn,request,"Vous n avez pas sélectionnée d agréation par colonnes !")%>');this.checked=false;}"><%=libelle_msg(Etn,request,"ligne/colonne Etendu")%> 
	                  </td></tr>
	                  </table>
	                  		<div id="info_affichage_resultat">
	                  		</div>
	                  </div>
					<div style="color: #5D5E7B;font-size: 7pt;padding: 5px;text-align: left;">*<%=libelle_msg(Etn,request,"Certaines requ&ecirc;tes, n&eacute;cessitant un d&eacute;lai de calcul important, peuvent vous &ecirc;tre envoy&eacute;es ult&eacute;rieurement dans vos \"Requ&ecirc;tes re&ccedil;ues\" ")%><!-- * Certaines requ&ecirc;tes, calcul&eacute;es le soir, vous seront envoy&eacute;es dans vos "Requ&ecirc;tes re&ccedil;ues" --></div>				
					</fieldset>
			</div>
				<div class="h1_tabdr" style="margin-top: 5px;"><b><%=libelle_msg(Etn,request,"SAUVEGARDE")%></b></div>
			<div>
				<fieldset style="border: 1px solid #9B9DB1;width: 95%">
					<legend><%=libelle_msg(Etn,request,"Enregistrer-sous")%></legend>
					<!-- <table cellpadding="1" cellspacing="1" border="0" width="100%">
						<tr>
							<td width="15%" align="center"><img src="img/view.png" border="0"></td>
							<td class="label"><%=libelle_msg(Etn,request,"Enregistrer-sous les crit&egrave;res s&eacute;lectionn&eacute")%>;s</td>
							<td align="right"><input class="check" type="button" onclick="saveRequete(document.f_query,0);" value="<%=libelle_msg(Etn,request,"Enregistrer-sous >>")%>"></input></td>
						</tr>
					</table> -->

					<table cellpadding="1" cellspacing="1" border="0" width="100%" style="display: none;" id="tab_enreg_s2">
						<tr>
							<td width="15%" align="center"><img src="img/view.png" border="0"></td>
							<td class="label" style="color: #0046D5;"><b><%=libelle_msg(Etn,request,"Enregistrer-sous  les crit&egrave;res")%></b></td>
							<td align="right" style="padding: 5px;">
							<input class="nextprev" type="button" id="enreg_s" onclick="voir_enreg(0,'enregistrer_sous');" value="&nbsp;<<<&nbsp;"></input>
							</td>

						</tr>
						<tr>
							
							<td class="label" colspan="3" align="right">
							<table cellpadding="0" cellspacing="0" border="0" width="100%" style="margin-left:5px;">
								<tr>
									<td class="label" colspan="2"><%=libelle_msg(Etn,request,"Nom de la requ&ecirc;te")%> :</td>
								</tr>
								<tr>
									<td colspan="2"><input type="hidden" name="requete_id2" value="0">
									<input type="text"  name="requete_name2" value="" size="75" maxlength="150">
									<%if(! requete_id.equals("0")){									
									out.write("<br><font style='color: #5D5E7B;font-size: 7pt;padding: 5px;text-align: left;'>Actuellement : "+requete_name+"</font>");
									}%>
																		
									</td>
								</tr>
								<tr>
									<td class="label" colspan="2"><%=libelle_msg(Etn,request,"Description :")%></td>
								</tr>
								<tr>
									<td colspan="2"><textarea name="requete_desc2" cols="75" rows="3"></textarea></td>
								</tr>
								<tr>
									<td class="label" colspan="2"><%=libelle_msg(Etn,request,"Partager la requ&ecirc;te ?")%> * : 
									<input type="checkbox" name="partage2" onclick="(this.checked==true?this.value=1:this.value=0)">
									<font style="color: #5D5E7B;font-size: 7pt;padding: 2px;text-align: left;"><%=libelle_msg(Etn,request,"* Cocher la case pour partager la requête")%></font>
									</td>
								</tr>
								<tr>
									<td align="center" height="40"><input class="save" type="button" onclick="saveRequete(document.f_query,'enregistrer_sous','0');" value="<%=libelle_msg(Etn,request,"Enregistrer-sous")%>" title="<%=libelle_msg(Etn,request,"Enregistrer-sous la requête sans la visualiser")%>"></input></td>
									<td align="center" width="45%"><input class="save" type="button" onclick="saveRequete(document.f_query,'enregistrer_sous','1');" value="<%=libelle_msg(Etn,request,"Enregistrer-sous/Visualiser ...")%>" style="width: 150px;" title="<%=libelle_msg(Etn,request,"Enregistrer-sous et visualiser la requête afin de l'exécuter")%>"></input></td>
								</tr>
							</table>

							</td>
						</tr>

					</table>
					<table cellpadding="1" cellspacing="1" border="0" width="100%" id="tab_enreg_s">
					<tr>
						<td width="15%" align="center"><img src="img/view.png" border="0"></td>
						<td class="label"><%=libelle_msg(Etn,request,"Enregistrer-sous  les crit&egrave;res")%></td>
						<td align="right"  style="padding: 5px;">
							<input class="nextprev" type="button" id="enreg_s2" onclick="voir_enreg(1,'enregistrer_sous');" value="&nbsp;>>>&nbsp;"></input>
							</td>
					</tr>
					<tr>
						<td height="24"></td>
						<td></td>
						<td></td>
					
					</tr>
					</table>
					<div style="color: #5D5E7B;font-size: 7pt;padding-bottom: 4px;"></div>
				</fieldset>

				<%if( requete_id.equals("0") || person_id.equals(""+user_id)){ %>

				<fieldset style="border: 1px solid #9B9DB1;width: 95%">
					<legend><%=libelle_msg(Etn,request,"Enregistrer")%></legend>

				 	<table cellpadding="1" cellspacing="1" border="0" width="100%" style="display:none;" id="tab_enreg2">
						<tr>
							<td width="15%" align="center"><img src="img/view.png" border="0"></img></td>
							<td class="label" style="color: #0046D5;"><b><%=libelle_msg(Etn,request,"Enregistrer ou modifier les crit&egrave;res")%></b></td>
							<td align="right" style="padding: 5px;"><input class="nextprev" type="button" id="enreg_s" onclick="voir_enreg(0,'enregistrer');" value="&nbsp;<<<&nbsp;"></input>
							</td>

						</tr>
						<tr>
							
							<td class="label" colspan="3" align="right">
							<table cellpadding="0" cellspacing="0" border="0" width="100%"  style="margin-left:5px;">
								<tr>
									<td class="label" valign="top" colspan="2"><%=libelle_msg(Etn,request,"Nom de la requ&ecirc;te")%> :</td>
								</tr>
								<tr>
									<td colspan="2" <%if(! requete_id.equals("0")){%> class="label"<%}%>  valign="top">
									<input type="hidden" name="requete_id" value="<%=requete_id%>">
									<%if( requete_id.equals("0")){%>
									<input type="text"  name="requete_name" value="<%=requete_name %>" size="75" maxlength="150">
									<%}else{%>
									<input type="text" name="requete_name" value="<%=requete_name%>" size="75" maxlength="150">
									<%
									out.write("<br><font style='color: #5D5E7B;font-size: 7pt;padding: 2px;text-align: left;'>Actuellement : "+requete_name+"</font>");
									}%>
									</td>
								</tr>
								<tr>
									<td class="label" colspan="2"><%=libelle_msg(Etn,request,"Description :")%></td>
								</tr>
								<tr>
									<td colspan="2"><textarea name="requete_desc" cols="75" rows="3"><%=requete_desc %></textarea></td>
								</tr>
								<tr>
									<td class="label" colspan="2"><%=libelle_msg(Etn,request,"Partager la requ&ecirc;te ?")%> * :
									<input type="checkbox" name="partage" <%if(partage.equals("1")){%>checked<%}%> value="<%=partage %>" onclick="(this.checked==true?this.value=1:this.value=0)">
									<font style="color: #5D5E7B;font-size: 7pt;padding: 5px;text-align: left;"><%=libelle_msg(Etn,request,"* Cocher la case pour partager la requête")%></font>
									</td>
								</tr>
								
								<td align="center" height="40"><input class="save" type="button" onclick="saveRequete(document.f_query,'enregistrer','0');" value="<%=libelle_msg(Etn,request,"Enregistrer")%>" title="<%=libelle_msg(Etn,request,"Enregistrer la requête sans la visualiser")%>"></input>
								<td  align="center" width="45%"><input class="save" type="button" onclick="saveRequete(document.f_query,'enregistrer','1');" value="<%=libelle_msg(Etn,request,"Enregistrer/Visualiser ...")%>" style="width: 150px;" title="<%=libelle_msg(Etn,request,"Enregistrer et visualiser la requête afin de l'exécuter")%>"></input>
								</td>
								</tr>
							</table>

							</td>
						</tr>

					</table>
					<table cellpadding="0" cellspacing="0" border="0" width="100%" id="tab_enreg">
					<tr>
						<td width="15%" align="center"><img src="img/view.png" border="0"></img></td>
						<td class="label"><%=libelle_msg(Etn,request,"Enregistrer/Modifier les crit&egrave;res")%></td>
						<td align="right"  style="padding: 5px;"><input class="nextprev" type="button" id="enreg_s2" onclick="voir_enreg(1,'enregistrer');" value="&nbsp;>>>&nbsp;"></input>
							</td>
					</tr>
					<tr>
						<td height="25"></td>
						<td></td>
						<td></td>
					
					</tr>
					</table>
					<div style="color: #5D5E7B;font-size: 7pt;padding-bottom: 4px;"></div>
				</fieldset>
					<%}else{%>
					<input type="hidden" name="requete_id" value="<%=requete_id%>">
					<input type="hidden" name="requete_name" value="<%=requete_name%>">
					<%requete_id = "0";
					//Etn.setDebug(true);%>
					<div id="tab_enreg2"></div>
					<div id="tab_enreg"></div>
				<%} %>
			</div>



		</div>
		</td>

	</tr>
</table>
