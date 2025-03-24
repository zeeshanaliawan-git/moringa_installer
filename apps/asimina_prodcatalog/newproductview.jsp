<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, com.etn.beans.app.GlobalParm, java.util.*, com.google.gson.*, com.google.gson.reflect.TypeToken, java.lang.reflect.Type, org.json.*"%>
<%@ page import="com.etn.asimina.beans.Language,com.etn.asimina.data.LanguageFactory, com.etn.asimina.util.*, com.etn.asimina.util.UIHelper"%>
<%@ include file="WEB-INF/include/lib_msg.jsp"%>
<%@ include file="WEB-INF/include/constants.jsp"%>
<%@ include file="common.jsp"%>
<%@ include file="WEB-INF/include/imager.jsp"%>

<%!

    String appendKeywords(String kw, String s)
    {
        if(parseNull(s).length() == 0 ) return kw.replace("\"","&quot;");
        if(parseNull(kw).length() > 0) kw += ", ";
        kw += parseNull(s);
        return kw.replace("\"","&quot;");
    }

    String getTitle(String name, String parent)
    {
        name = parseNull(name);
        parent = parseNull(parent);
        if(name.length() == 0 && parent.length() == 0) return "";
        if(name.length() > 0 && parent.length() == 0) return name;
        if(name.length() == 0 && parent.length() > 0) return parent;
        return name +  " | " + parent;
    }

    String getSummary(com.etn.beans.Contexte Etn, HttpServletRequest request, String productid, String importSource)
	{
		String h = "";
		HashMap<String, String> deviceattrs = new HashMap<String, String>();
                Map<String, String> otherSpecs = new LinkedHashMap<String, String>();
		Set rs_cat_attribs = Etn.execute("select p.*, c.name, c.visible_to, c.migration_name from product_attribute_values p, catalog_attributes c where c.type='specs' and p.cat_attrib_id = c.cat_attrib_id and p.product_id="+escape.cote(productid)+" order by c.sort_order, p.cat_attrib_id, p.sort_order");
		while(rs_cat_attribs.next())
		{
                    String attributeName = rs_cat_attribs.value("name").toUpperCase();
                    if(!rs_cat_attribs.value("migration_name").equals("")) deviceattrs.put(attributeName,rs_cat_attribs.value("attribute_value"));
                    else otherSpecs.put(libelle_msg(Etn, request, rs_cat_attribs.value("name")), libelle_msg(Etn, request, rs_cat_attribs.value("attribute_value")));

		}

		Map<String, Map<String, String>> specs = new LinkedHashMap<String, Map<String, String>>();

		if(importSource.startsWith("phonedir_") || importSource.length()==0)
		{
				Map<String, String> slist = new LinkedHashMap<String, String>();
				specs.put(libelle_msg(Etn, request, "Dimensions et poids"), slist);

				String dimensions = "";
				if(parseNull(deviceattrs.get("HEIGHT (MM) (THICKNESS)")).length() > 0 && parseNull(deviceattrs.get("LENGTH (MM)")).length() > 0  && parseNull(deviceattrs.get("WIDTH (MM)")).length() > 0 ) dimensions = parseNull(deviceattrs.get("HEIGHT (MM) (THICKNESS)")) + " x " + parseNull(deviceattrs.get("LENGTH (MM)")) + " x " + parseNull(deviceattrs.get("WIDTH (MM)"));

				slist.put(libelle_msg(Etn, request, "Dimensions H x L x W (mm x mm x mm)"), dimensions);
				String weight = "";
				if((parseNull(deviceattrs.get("WEIGHT (G)")).replace(".0","").replace(".00","")).length() > 0) weight = parseNull(deviceattrs.get("WEIGHT (G)")).replace(".0","").replace(".00","") + "g";
				slist.put(libelle_msg(Etn, request, "Poids"), libelle_msg(Etn, request, weight, false));

				slist = new LinkedHashMap<String, String>();
				specs.put(libelle_msg(Etn, request, "Autonomie"), slist);
				slist.put(libelle_msg(Etn, request, "Type de batterie"), libelle_msg(Etn, request, parseNull(deviceattrs.get("BATTERY TYPE")), false));

				String batteryCap = "";
				if(parseNull(deviceattrs.get("BATTERY CAPACITY (MAH)")).length() > 0) batteryCap = parseNull(deviceattrs.get("BATTERY CAPACITY (MAH)")) + "mah";
				slist.put(libelle_msg(Etn, request, "Capacité de la batterie"), libelle_msg(Etn, request, batteryCap, false));
				slist.put(libelle_msg(Etn, request, "Autonomie en veille (heures)"), libelle_msg(Etn, request, parseNull(deviceattrs.get("IDLE (HOURS)")), false));
				slist.put(libelle_msg(Etn, request, "Autonomie en communication (heures)"), libelle_msg(Etn, request, parseNull(deviceattrs.get("VOICE (HOURS)")), false));
				slist.put(libelle_msg(Etn, request, "Chargement rapide"), libelle_msg(Etn, request, parseNull(deviceattrs.get("FAST CHARGING")), false));
				slist.put(libelle_msg(Etn, request, "Chargement sans-fil"), libelle_msg(Etn, request, parseNull(deviceattrs.get("WIRELESS CHARGING")), false));

				slist = new LinkedHashMap<String, String>();
				specs.put(libelle_msg(Etn, request, "Réseaux et connectivité"), slist);

				String simformat = "";
				if("2FF".equalsIgnoreCase(parseNull(deviceattrs.get("SIM CARD FORMAT")))) simformat = "mini SIM";
				else if("3FF (MicroSIM)".equalsIgnoreCase(parseNull(deviceattrs.get("SIM CARD FORMAT")))) simformat = "micro SIM";
				else if("4FF (nano SIM)".equalsIgnoreCase(parseNull(deviceattrs.get("SIM CARD FORMAT")))) simformat = "nano SIM";

				slist.put(libelle_msg(Etn, request, "Format de la carte SIM"), libelle_msg(Etn, request, simformat, false));
				slist.put(libelle_msg(Etn, request, "Multiple SIM"), libelle_msg(Etn, request, parseNull(deviceattrs.get("MULTIPLE SIM SUPPORT")), false));

				String supportedNetworks = "";
                                if("yes".equalsIgnoreCase(parseNull(deviceattrs.get("EDGE")))) supportedNetworks += "Edge,";
                                if("yes".equalsIgnoreCase(parseNull(deviceattrs.get("2G")))) supportedNetworks += "2G,";
                                if("yes".equalsIgnoreCase(parseNull(deviceattrs.get("3G")))) supportedNetworks += "3G,";
                                if("yes".equalsIgnoreCase(parseNull(deviceattrs.get("3G HSPA")))) supportedNetworks += "3G+,";
                                if("yes".equalsIgnoreCase(parseNull(deviceattrs.get("3G HSPA+")))) supportedNetworks += "H+,";
				if("yes".equalsIgnoreCase(parseNull(deviceattrs.get("LTE")))) supportedNetworks += "4G,";
				if(supportedNetworks.endsWith(",")) supportedNetworks = supportedNetworks.substring(0, supportedNetworks.length() - 1);

				slist.put(libelle_msg(Etn, request, "Réseaux"), supportedNetworks);

				String otherconnections = "";
				if(parseNull(deviceattrs.get("WI-FI")).length() > 0 && !"NO".equalsIgnoreCase(parseNull(deviceattrs.get("WI-FI")))) otherconnections += libelle_msg(Etn, request, "Wifi") + ",";
				if(parseNull(deviceattrs.get("NFC SUPPORT")).length() > 0 && !"NO".equalsIgnoreCase(parseNull(deviceattrs.get("NFC SUPPORT")))) otherconnections += libelle_msg(Etn, request, "NFC") + ",";
				if(otherconnections.endsWith(",")) otherconnections = otherconnections.substring(0, otherconnections.length() - 1);

				slist.put(libelle_msg(Etn, request, "Bluetooth"), parseNull(deviceattrs.get("BLUETOOTH")));
				slist.put(libelle_msg(Etn, request, "Autres connexions"), otherconnections);
				slist.put(libelle_msg(Etn, request, "Partage de connexion"), libelle_msg(Etn, request, parseNull(deviceattrs.get("TETHERING")), false));
				slist.put(libelle_msg(Etn, request, "DAS"), libelle_msg(Etn, request, parseNull(deviceattrs.get("SAR HEAD (WATT/KG)")), false));

				slist = new LinkedHashMap<String, String>();
				specs.put(libelle_msg(Etn, request, "Système d'exploitation, écran et mémoire"), slist);

				String os = "";
				if(parseNull(deviceattrs.get("OPERATING SYSTEM")).length() > 0 && !"other".equalsIgnoreCase(parseNull(deviceattrs.get("OPERATING SYSTEM"))) ) os = parseNull(deviceattrs.get("OPERATING SYSTEM")) + " ";
				if(parseNull(deviceattrs.get("OPERATING SYSTEM VERSION")).length() > 0 && !"other".equalsIgnoreCase(parseNull(deviceattrs.get("OPERATING SYSTEM VERSION"))) ) os += parseNull(deviceattrs.get("OPERATING SYSTEM VERSION"));

				slist.put(libelle_msg(Etn, request, "Système d'exploitation"), libelle_msg(Etn, request, parseNull(os), false));
				slist.put(libelle_msg(Etn, request, "Capacité mémoire (GB)"), libelle_msg(Etn, request, parseNull(deviceattrs.get("INTERNAL MEMORY")), false));
				slist.put(libelle_msg(Etn, request, "RAM (GB)"), libelle_msg(Etn, request, parseNull(deviceattrs.get("RAM")), false));

				String numOfCpu = "";
				if(parseNull(deviceattrs.get("NUMBER OF CPU CORES FOR MULTIMEDIA")).length() > 0 && !"0".equalsIgnoreCase(parseNull(deviceattrs.get("NUMBER OF CPU CORES FOR MULTIMEDIA"))) &&
					!"others".equalsIgnoreCase(parseNull(deviceattrs.get("NUMBER OF CPU CORES FOR MULTIMEDIA"))) ) numOfCpu = parseNull(deviceattrs.get("NUMBER OF CPU CORES FOR MULTIMEDIA"));

				slist.put(libelle_msg(Etn, request, "Nombre de cœurs CPU"), libelle_msg(Etn, request, parseNull(numOfCpu), false));

				String externalMem = "";
				if("Micro SD|Other".equalsIgnoreCase(parseNull(deviceattrs.get("EXTERNAL MEMORY")))) externalMem = "Micro SD";
				else if("Other".equalsIgnoreCase(parseNull(deviceattrs.get("EXTERNAL MEMORY")))) externalMem = "";
				else externalMem = parseNull(deviceattrs.get("EXTERNAL MEMORY"));

				slist.put(libelle_msg(Etn, request, "Mémoire extensible par MicroSD"), libelle_msg(Etn, request, externalMem, false));

				slist = new LinkedHashMap<String, String>();
				specs.put(libelle_msg(Etn, request, "Ecran"), slist);

				String screenSizeDiagnal = "";
				if("0".equalsIgnoreCase(parseNull(deviceattrs.get("SCREEN SIZE (IN INCHES) (DIAGONAL)"))) || "0.0".equalsIgnoreCase(parseNull(deviceattrs.get("SCREEN SIZE (IN INCHES) (DIAGONAL)")))) screenSizeDiagnal = "";
				else screenSizeDiagnal = parseNull(deviceattrs.get("SCREEN SIZE (IN INCHES) (DIAGONAL)"));

				slist.put(libelle_msg(Etn, request, "Taille de l'écran (pouces)"), libelle_msg(Etn, request, screenSizeDiagnal, false));

				String displayTech = "";
				if(!"other".equalsIgnoreCase(parseNull(deviceattrs.get("DISPLAY TECHNOLOGY")))) displayTech = parseNull(deviceattrs.get("DISPLAY TECHNOLOGY"));
				slist.put(libelle_msg(Etn, request, "Technologie de l'écran"), libelle_msg(Etn, request, displayTech, false));

				String resolution = "";
				if(parseNull(deviceattrs.get("WIDTH (PIXEL)")).length() > 0) resolution = parseNull(deviceattrs.get("WIDTH (PIXEL)"));
				if(parseNull(deviceattrs.get("HEIGHT (PIXEL)")).length() > 0)
				{
					if(resolution.length() > 0) resolution += "x";
					resolution += parseNull(deviceattrs.get("HEIGHT (PIXEL)"));
				}

				slist.put(libelle_msg(Etn, request, "Résolution"), resolution);

				//bad attribute name coming from oxygen data source which cannot be compared directly so have to check the starting of attribute name
				String luminous = "";
				for(String da : deviceattrs.keySet())
				{
					if(da.startsWith("BRIGHTNESS (CD/M")) luminous = parseNull(deviceattrs.get(da));
				}
				slist.put(libelle_msg(Etn, request, "Luminosité (cd/m2)"), libelle_msg(Etn, request, luminous, false));
				slist.put(libelle_msg(Etn, request, "Densité de résolution (ppi)"), libelle_msg(Etn, request, parseNull(deviceattrs.get("RESOLUTION DENSITY (PPI)")), false));
				slist.put(libelle_msg(Etn, request, "Capteur biométrique"), libelle_msg(Etn, request, parseNull(deviceattrs.get("FINGERPRINT OR OTHER BIOMETRIC SENSOR")), false));

				slist = new LinkedHashMap<String, String>();
				specs.put(libelle_msg(Etn, request, "Photo"), slist);
				slist.put(libelle_msg(Etn, request, "Résolution appareil photo avant (Mpx)"), libelle_msg(Etn, request, parseNull(deviceattrs.get("FRONT CAMERA RESOLUTION (MPX)")), false));

				String flash = "";
				if(!"other".equalsIgnoreCase(parseNull(deviceattrs.get("FLASH")))) flash = parseNull(deviceattrs.get("FLASH"));
				slist.put(libelle_msg(Etn, request, "Flash (technologie)"), libelle_msg(Etn, request, flash, false));

				slist.put(libelle_msg(Etn, request, "Zoom avant"), libelle_msg(Etn, request, parseNull(deviceattrs.get("FRONT ZOOM")), false));
				slist.put(libelle_msg(Etn, request, "Ouverture de l'objectif"), libelle_msg(Etn, request, parseNull(deviceattrs.get("LENS APERTURE")), false));

				if(!"no".equalsIgnoreCase(parseNull(deviceattrs.get("REAR CAMERA")))) slist.put(libelle_msg(Etn, request, "Appareil photo secondaire"), libelle_msg(Etn, request, parseNull(deviceattrs.get("REAR CAMERA")), false));
				slist.put(libelle_msg(Etn, request, "Résolution appareil photo arrière"), libelle_msg(Etn, request, parseNull(deviceattrs.get("REAR CAMERA 1 RESOLUTION (MPX)")), false));
				slist.put(libelle_msg(Etn, request, "Résolution appareil photo arrière 2"), libelle_msg(Etn, request, parseNull(deviceattrs.get("REAR CAMERA 2 RESOLUTION (MPX)")), false));
				slist.put(libelle_msg(Etn, request, "Zoom arrière"), libelle_msg(Etn, request, parseNull(deviceattrs.get("REAR ZOOM")), false));
				slist.put(libelle_msg(Etn, request, "Stabilisateur optique"), libelle_msg(Etn, request, parseNull(deviceattrs.get("OPTICAL STABILIZATION (OIS)")), false));

				slist = new LinkedHashMap<String, String>();
				specs.put(libelle_msg(Etn, request, "Audio et vidéo"), slist);
				slist.put(libelle_msg(Etn, request, "Prise casque Jack 3.5"), libelle_msg(Etn, request, parseNull(deviceattrs.get("JACK 3.5 SUPPORT")), false));
				slist.put(libelle_msg(Etn, request, "Prise HDMI"), libelle_msg(Etn, request, parseNull(deviceattrs.get("HDMI TYPE")), false));
				slist.put(libelle_msg(Etn, request, "Réalité virtuelle"), libelle_msg(Etn, request, parseNull(deviceattrs.get("VIRTUAL REALITY SUPPORT")), false));
				slist.put(libelle_msg(Etn, request, "Voix HD"), libelle_msg(Etn, request, parseNull(deviceattrs.get("HD VOICE SUPPORT")), false));

				slist = new LinkedHashMap<String, String>();
				specs.put(libelle_msg(Etn, request, "Fonctions"), slist);
				slist.put(libelle_msg(Etn, request, "Acceleromètre"), libelle_msg(Etn, request, parseNull(deviceattrs.get("ACCELEROMETER")), false));

				String geoloc = "";
				if(parseNull(deviceattrs.get("GEOLOCATION")).length()>0&&!"no".equalsIgnoreCase(parseNull(deviceattrs.get("GEOLOCATION")))) geoloc = "YES";
				slist.put(libelle_msg(Etn, request, "GPS"), libelle_msg(Etn, request, geoloc, false));

				slist.put(libelle_msg(Etn, request, "Gyroscope"), libelle_msg(Etn, request, parseNull(deviceattrs.get("GYROSCOPE")), false));
		}
		else
		{
			Map<String, String> slist = new LinkedHashMap<String, String>();
			specs.put(libelle_msg(Etn, request, "Dimensions et poids"), slist);
			slist.put(libelle_msg(Etn, request, "Dimensions") + " " + libelle_msg(Etn, request, parseNull(deviceattrs.get("GENERALFEATURES DIMENSIONS UNIT")), false), libelle_msg(Etn, request, parseNull(deviceattrs.get("GENERALFEATURES DIMENSIONS VALUE")), false));
			slist.put(libelle_msg(Etn, request, "Poids"), libelle_msg(Etn, request, parseNull(deviceattrs.get("GENERALFEATURES WEIGHT VALUE")).replace(".0","").replace(".00",""), false) + " " + libelle_msg(Etn, request, parseNull(deviceattrs.get("GENERALFEATURES WEIGHT UNIT")), false));
			slist.put(libelle_msg(Etn, request, "Format SIM"), libelle_msg(Etn, request, parseNull(deviceattrs.get("GENERALFEATURES SIMCARDFORMAT")), false));
			slist.put(libelle_msg(Etn, request, "Mémoire externe"), libelle_msg(Etn, request, parseNull(deviceattrs.get("HARDWARE EXTERNALMEMORY")), false));
			slist.put(libelle_msg(Etn, request, "DAS"), libelle_msg(Etn, request, parseNull(deviceattrs.get("GENERALFEATURES DAS")), false));

			slist = new LinkedHashMap<String, String>();
			specs.put(libelle_msg(Etn, request, "Autonomie"), slist);
			slist.put(libelle_msg(Etn, request, "Capacité de la batterie"), libelle_msg(Etn, request, parseNull(deviceattrs.get("HARDWARE BATTERYCAPACITY VALUE")), false) + " " + libelle_msg(Etn, request, parseNull(deviceattrs.get("HARDWARE BATTERYCAPACITY UNIT")), false));
			slist.put(libelle_msg(Etn, request, "Autonomie en veille"), libelle_msg(Etn, request, parseNull(deviceattrs.get("HARDWARE STANDBYTIME VALUE")), false) + " " + libelle_msg(Etn, request, parseNull(deviceattrs.get("HARDWARE STANDBYTIME UNIT")), false));
			slist.put(libelle_msg(Etn, request, "Autonomie en communication"), libelle_msg(Etn, request, parseNull(deviceattrs.get("HARDWARE TALKTIME VALUE")), false) + " " + libelle_msg(Etn, request, parseNull(deviceattrs.get("HARDWARE TALKTIME UNIT")), false));

			slist = new LinkedHashMap<String, String>();
			specs.put(libelle_msg(Etn, request, "Réseaux et connectivité"), slist);
			slist.put(libelle_msg(Etn, request, "Meilleur réseau"), libelle_msg(Etn, request, parseNull(deviceattrs.get("TECHRADIO TECHRADIO")), false));
			slist.put(libelle_msg(Etn, request, "Wifi"), libelle_msg(Etn, request, parseNull(deviceattrs.get("TECHRADIO WIFI")), false));
			slist.put(libelle_msg(Etn, request, "Bluetooth"), libelle_msg(Etn, request, parseNull(deviceattrs.get("TECHRADIO BLUETOOTH")), false));
			slist.put(libelle_msg(Etn, request, "NFC"), libelle_msg(Etn, request, parseNull(deviceattrs.get("TECHRADIO NFC")), false));
			slist.put(libelle_msg(Etn, request, "GPS"), libelle_msg(Etn, request, parseNull(deviceattrs.get("TECHRADIO GPS")), false));
			slist.put(libelle_msg(Etn, request, "Partage de connexion / mode modem"), libelle_msg(Etn, request, parseNull(deviceattrs.get("TECHRADIO TETHERING")), false));

			slist = new LinkedHashMap<String, String>();
			specs.put(libelle_msg(Etn, request, "Système d'exploitation, écran et mémoire"), slist);
			slist.put(libelle_msg(Etn, request, "Capacité mémoire"), libelle_msg(Etn, request, parseNull(deviceattrs.get("HARDWARE INTERNALMEMORY")), false));
			slist.put(libelle_msg(Etn, request, "Type d'écran tactile"), libelle_msg(Etn, request, parseNull(deviceattrs.get("SCREEN TOUCHSCREEN")), false));
			slist.put(libelle_msg(Etn, request, "Taille de l'écran"), libelle_msg(Etn, request, parseNull(deviceattrs.get("SCREEN SCREENDIAGONAL VALUE")), false) + " " + libelle_msg(Etn, request, parseNull(deviceattrs.get("SCREEN SCREENDIAGONAL UNIT")), false));
			slist.put(libelle_msg(Etn, request, "Technologie de l'écran"), libelle_msg(Etn, request, parseNull(deviceattrs.get("SCREEN SCREENDIAGONAL VALUE")), false) + " " + libelle_msg(Etn, request, parseNull(deviceattrs.get("SCREEN SCREENDIAGONAL UNIT")), false));
			slist.put(libelle_msg(Etn, request, "Technologie de l'écran"), libelle_msg(Etn, request, parseNull(deviceattrs.get("SCREEN SCREENTECH")), false));
			slist.put(libelle_msg(Etn, request, "Résolution"), libelle_msg(Etn, request, parseNull(deviceattrs.get("SCREEN RESOLUTION VALUE")), false) + " " + libelle_msg(Etn, request, parseNull(deviceattrs.get("SCREEN RESOLUTION UNIT")), false));

			slist = new LinkedHashMap<String, String>();
			specs.put(libelle_msg(Etn, request, "Photo"), slist);
			slist.put(libelle_msg(Etn, request, "Appareil photo"), libelle_msg(Etn, request, parseNull(deviceattrs.get("CAMERA RESOLUTION VALUE")), false) + " " + libelle_msg(Etn, request, parseNull(deviceattrs.get("CAMERA RESOLUTION UNIT")), false));
			slist.put(libelle_msg(Etn, request, "Flash (technologie du flash)"), libelle_msg(Etn, request, parseNull(deviceattrs.get("CAMERA FLASH")), false));
			slist.put(libelle_msg(Etn, request, "Zoom"), libelle_msg(Etn, request, parseNull(deviceattrs.get("CAMERA ZOOM")), false));
			slist.put(libelle_msg(Etn, request, "Autofocus"), libelle_msg(Etn, request, parseNull(deviceattrs.get("CAMERA AUTOFOCUS")), false));
			slist.put(libelle_msg(Etn, request, "Stabilisation"), libelle_msg(Etn, request, parseNull(deviceattrs.get("CAMERA STABILISATION")), false));
			slist.put(libelle_msg(Etn, request, "Appareil photo secondaire"), libelle_msg(Etn, request, parseNull(deviceattrs.get("CAMERA FRONTCAMRESOLUTION VALUE")), false) + " " + libelle_msg(Etn, request, parseNull(deviceattrs.get("CAMERA FRONTCAMRESOLUTION UNIT")), false));
			slist.put(libelle_msg(Etn, request, "Logiciel d'édition vidéo"), libelle_msg(Etn, request, parseNull(deviceattrs.get("CAMERA VIDEOSOFT")), false));

			slist = new LinkedHashMap<String, String>();
			specs.put(libelle_msg(Etn, request, "Audio et vidéo"), slist);
			slist.put(libelle_msg(Etn, request, "Radio FM"), libelle_msg(Etn, request, parseNull(deviceattrs.get("VOICE FMRADIO")), false));
			slist.put(libelle_msg(Etn, request, "Lecteur MP3"), libelle_msg(Etn, request, parseNull(deviceattrs.get("VOICE MP3READER")), false));
			slist.put(libelle_msg(Etn, request, "Enregistrement vidéo"), libelle_msg(Etn, request, parseNull(deviceattrs.get("CAMERA VIDEOCAPTURE")), false));
			slist.put(libelle_msg(Etn, request, "Prise de casque jack 3.5"), libelle_msg(Etn, request, parseNull(deviceattrs.get("VOICE JACK35")), false));
			slist.put(libelle_msg(Etn, request, "Haut-parleurs"), libelle_msg(Etn, request, parseNull(deviceattrs.get("VOICE SPEAKERS")), false));
			slist.put(libelle_msg(Etn, request, "Voix HD"), libelle_msg(Etn, request, parseNull(deviceattrs.get("VOICE VOICEHD")), false));
		}
                specs.put(libelle_msg(Etn, request, "Specifications"), otherSpecs);

		//render html
		int blocksShown = 0;
		boolean closeDiv = false;
		for(String spec : specs.keySet())
		{
			Map<String, String> slist = specs.get(spec);
			//first check if any attribute has some value then display the block
			boolean displayBlock = false;
			for(String attr : slist.keySet())
			{
				if(parseNull(slist.get(attr)).length() > 0)
				{
					displayBlock = true;
					break;
				}
			}

			if(displayBlock)
			{
				if(blocksShown == 0)
				{
					h += "<div class='row'>";
					closeDiv = true;
				}
				else if(blocksShown % 2 == 0)
				{
					h += "<div class='row'>";
					closeDiv = true;
				}

				h += "<div class='col-lg-6 col-md-6 col-sm-12 col-xs-12'>";
				String borderTop = "";
				if(blocksShown >= 2) borderTop = "border-top:1px solid black;padding-top:15px;";
				h += "<div style='border-bottom:1px solid #ddd; padding-bottom:15px;margin-bottom:15px;"+borderTop +"'><h4 style='margin-bottom:0;font-weight: bold'>"+spec+"</h4></div>";

				for(String attr : slist.keySet())
				{
					if(parseNull(slist.get(attr)).length() > 0)
					{
						h += "<div class='row' style='padding-bottom:1rem'>";
						h += "<div class='col-6 weight-normal details_rubrique_term' >"+attr+"</div>";
						h += "<div class='col-6 valeur_rubrique_term' style='font-weight:bold;'>"+parseNull(slist.get(attr))+"</div>";
						h += "</div>";
					}
				}

				h += "</div>";//end of row

				blocksShown++;
				if(blocksShown % 2 == 0)
				{
					h += "</div>";
					closeDiv = false;
				}

			}
		}
		if(closeDiv) h += "</div>";

		return h;
	}
%>
<%
	//in case of test environment we will add T otherwise this tag will be empty because this tag is not added by pages module
	//so to avoid change in it we add Test environment identifier
	String env = "";
	if(parseNull(GlobalParm.getParm("IS_PROD_ENVIRONMENT")).equals("0")) env = "T";
	Set rsPortalConfig = Etn.execute("Select * from "+GlobalParm.getParm("PORTAL_DB")+".config where code = 'EXTERNAL_LINK'");
	rsPortalConfig.next();
	String portalExternalLink = rsPortalConfig.value("val");
	if(portalExternalLink.endsWith("/") == false) portalExternalLink += "/";

    String id = parseNull(request.getParameter("id"));
    String lang = parseNull(request.getParameter("lang"));
    
    Language language = LanguageFactory.instance.getLanguage(lang);
    if(language == null){
        language = com.etn.asimina.util.SiteHelper.getSiteLangs(Etn,getSiteByProductId(Etn,id)).get(0);
        lang = language.getCode();        
    }

    set_lang(lang, request, Etn);
    String langDirection = getLangDirection(lang, request, Etn);

    String prefix = getProductColumnsPrefix(Etn, request, lang);
    String q = "SELECT p.*, pd.seo_title, pd.seo, pd.seo_canonical_url, pd.summary, pd.main_features,"
            +" pd.essentials_alignment, pd.video_url, pd.page_path as product_page_path, cd.folder_name catalog_folder_name, IFNULL(fv.concat_path,'') as folder_path"
            +" FROM products p "
            +" INNER JOIN product_descriptions pd on p.id = pd.product_id"
            +" INNER JOIN catalogs c ON c.id = p.catalog_id"
            +" LEFT JOIN catalog_descriptions cd ON c.id = cd.catalog_id and cd.langue_id = "+escape.cote(language.getLanguageId())
            +" LEFT JOIN products_folders_lang_path fv ON p.folder_id = fv.folder_id and fv.langue_id = "+escape.cote(language.getLanguageId())+" and fv.site_id = c.site_id"
            +" WHERE p.id  = " + escape.cote(id)+" AND pd.langue_id="+escape.cote(language.getLanguageId());
    Set rs = Etn.execute(q);

    if(rs == null || rs.rs.Rows == 0)
    {
        out.write("<div style='color:red'>Error::No product found</div>");
        return;
    }
    rs.next();


    String product_uuid = parseNull(rs.value("product_uuid"));
    String productPagePath = parseNull(rs.value("product_page_path"));
    String catalogFolderName = parseNull(rs.value("catalog_folder_name"));
    String html_variant = parseNull(rs.value("html_variant"));
    String folderPath = parseNull(rs.value("folder_path"));

    if(productPagePath.length() > 0) productPagePath += ".html";

    Set rscat = Etn.execute("select * from catalogs where id = " + escape.cote(rs.value("catalog_id")));
    rscat.next();

    String siteId = parseNull(rscat.value("site_id"));
	Set rsSite = Etn.execute("Select * from "+GlobalParm.getParm("PORTAL_DB")+".sites where id = "+escape.cote(siteId));
	rsSite.next();
	
	String _productType = parseNull(rscat.value("catalog_type"));
	if(parseNull(rs.value("device_type")).length() > 0) _productType = parseNull(rs.value("device_type"));

	String addToCartBtnLabel = "Choisir ce produit";
	if("device".equals(parseNull(rscat.value("catalog_type")))) addToCartBtnLabel = "Choisir ce mobile";

    boolean ecommerceEnabled = isEcommerceEnabled(Etn, siteId);

    Set rsshop = Etn.execute("select * from shop_parameters where site_id = " + escape.cote(siteId) );
    rsshop.next();
    String continueShoppingUrl = parseNull(rsshop.value(prefix + "continue_shop_url"));

    String listingscreenheading = parseNull(rscat.value(prefix + "heading"));

    String metakeywords = "";
    metakeywords = appendKeywords(metakeywords, parseNull(rs.value(prefix + "name")));
    metakeywords = appendKeywords(metakeywords, parseNull(rs.value(prefix + "meta_keywords")));
    String metadescription = parseNull(rs.value("seo")).replace("\"","&quot;");
    String metatitle = parseNull(rs.value("seo_title"));
    String pname = (parseNull(rs.value(prefix+"name")).startsWith(libelle_msg(Etn, request,parseNull(rs.value("brand_name"))))?"":libelle_msg(Etn, request,parseNull(rs.value("brand_name")))+" ")+parseNull(rs.value(prefix + "name"));


    String preloadImages = "";
    String ogImageSrc = "";
    String eleImageSrc = "";
    String defaultVariantPrice = "";
    ProductImageHelper imageHelper = new ProductImageHelper(id);
    HashMap<String, String> defaultAttribute = new HashMap<String, String>();
    Set rsVariants = Etn.execute("select pv.*, pvd.* from product_variants pv inner join product_variant_details pvd on pv.id=pvd.product_variant_id and pvd.langue_id="+escape.cote(language.getLanguageId())+" where pv.product_id="+escape.cote(id)+" and pv.is_active=1 order by pv.is_default desc"); // to show default images when no images found.
    boolean isFirstActiveVariant = true; // to select first variant in case of disabled default variant.
    JSONArray variants = new JSONArray();
    JSONArray variantsAlgObjectId = new JSONArray();
    while(rsVariants.next()){
        JSONObject variant = new JSONObject();
        variant.put("id",rsVariants.value("id"));
        variantsAlgObjectId.put(rsVariants.value("uuid"));
        Set rsVariantAttributes = Etn.execute("select cav.*, ca.value_type from catalog_attribute_values cav inner join product_variant_ref pvr on cav.id = pvr.catalog_attribute_value_id inner join catalog_attributes ca on ca.cat_attrib_id = cav.cat_attrib_id where pvr.product_variant_id = "+escape.cote(rsVariants.value("id")));
        while(rsVariantAttributes.next()){
            if(isFirstActiveVariant) defaultAttribute.put(rsVariantAttributes.value("cat_attrib_id"),rsVariantAttributes.value("id"));
        }
        JSONArray images = new JSONArray();
        Set rsVariantImages = Etn.execute("select * from product_variant_resources where type='image' and product_variant_id="+escape.cote(rsVariants.value("id"))+" and langue_id="+escape.cote(language.getLanguageId())+" order by sort_order");
        boolean firstImage = true;
        String imagePathPrefix = GlobalParm.getParm("PAGES_UPLOAD_DIRECTORY") + siteId + "/img/4x3/";
        String imageUrlPrefix = GlobalParm.getParm("MEDIA_LIBRARY_UPLOADS_URL") + siteId + "/img/4x3/";
        while(rsVariantImages.next()){
            String esImageActualName = rsVariantImages.value("actual_file_name");
            Set rsMedia = Etn.execute("select * from "+GlobalParm.getParm("PAGES_DB")+".files where file_name="+escape.cote(esImageActualName)+
                " and site_id="+escape.cote(siteId)+" and (COALESCE(removal_date,'') = '' or  removal_date>now())");

            if(rsMedia.rs.Rows>0){
                String imageClass = "";
                String imageName = rsVariantImages.value("path");
                String imagePath = imagePathPrefix + imageName;
                String imageUrl = imageUrlPrefix + imageName;
                String _version = getImageUrlVersion(imagePath);
                String imageSrc = imageUrl + _version;

                String imageId = "variantImage_"+rsVariants.value("id")+"_"+rsVariantImages.value("sort_order");
                JSONObject image = new JSONObject();
                image.put("small",imageId);
                image.put("big",imageId);
                images.put(image);
                if(rsVariants.value("is_default").equals("1"))
                {
                    defaultVariantPrice = parseNull(rsVariants.value("price"));
                }
                if(rsVariants.value("is_default").equals("1")  && firstImage){
                    imageClass = "default-image";
                    ogImageSrc = GlobalParm.getParm("MEDIA_LIBRARY_UPLOADS_URL") + siteId + "/img/og/" + imageName;
                    eleImageSrc = GlobalParm.getParm("MEDIA_LIBRARY_UPLOADS_URL") + siteId + "/img/4x3/" + imageName;
                }
                preloadImages += "<img id='"+imageId+"' src='"+imageSrc+"' class='"+imageClass+"'>";

                firstImage = false;
            }
        }
        preloadImages += "<a id='actionButtonDesktopUrl_"+rsVariants.value("id")+"' href='"+rsVariants.value("action_button_desktop_url")+"'></a>";
        preloadImages += "<a id='actionButtonMobileUrl_"+rsVariants.value("id")+"' href='"+rsVariants.value("action_button_mobile_url")+"'></a>";

        variant.put("images", images);
        variants.put(variant);
        isFirstActiveVariant = false;
    }

	String alltags = "";
	Set rsTags = Etn.execute("select product_id, group_concat(tag_id) as tags from product_tags where product_id = "+escape.cote(id) + " group by product_id order by tag_id");
	if(rsTags.next()) alltags = parseNull(rsTags.value("tags"));

    Set rsMetaTags = Etn.execute("select * from products_meta_tags where product_id = "+escape.cote(id) + " and langue_id = "+escape.cote(language.getLanguageId())
        +" order by id");

	String ispreview = parseNull(request.getParameter("ispreview"));
	String ___prvMuid = "";
	if("1".equals(ispreview))
	{
        Set ___rsm = Etn.execute("select * from " + GlobalParm.getParm("PORTAL_DB") + ".site_menus where site_id  = " + escape.cote(siteId));
        if( ___rsm.next()) ___prvMuid = ___rsm.value("menu_uuid");
	}

%>
<!DOCTYPE html>
<% if(parseNull(lang).length() > 0) { %>
<html lang="<%=parseNull(lang)%>" dir="<%=langDirection%>">
    <% } else { %>
<html>
<% } %>
<head>


    <meta charset="UTF-8">
    <!--[if IE]>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/><![endif]-->
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <% if(parseNull(metakeywords).length() > 0) { %>
    <meta name="keywords" content="<%=metakeywords.replace("\"","&quot;")%>">
    <% } %>

    <% if(parseNull(metadescription).length() > 0) { %>
    <meta name="description" content="<%=metadescription%>">
    <% } %>

    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/orangeHelvetica.min.css">
    <% if("rtl".equalsIgnoreCase(langDirection)) { %>
	    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/newui/style.css">
    <% } else { %>
	    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/newui/style.css">
    <% } %>

    <meta name="title" content="<%=metatitle.replace("\"","&quot;")%>">
    <meta name="etn:pname" content="<%=pname.replace("\"","&quot;")%>">
    <meta name="etn:eletype" content="commercialcatalog">
    <meta name="etn:ctype" content="<%=parseNull(rscat.value("catalog_type")).replace("\"","&quot;")%>">
    <meta name="etn:cname" content="<%=parseNull(rscat.value("name")).replace("\"","&quot;")%>">
    <meta name="etn:eleimage" content="<%=eleImageSrc%>">
    <meta name="etn:eleprice" content="<%=defaultVariantPrice%>">
    <meta name="etn:elebrand" content="<%=parseNull(rs.value("brand_name")).replace("\"","&quot;")%>">
    <meta name="etn:eleid" content="<%=id%>">
    <meta name="etn:eleisnew" content="<%=parseNull(rs.value("is_new"))%>">
    <meta name="etn:elecurrency" content="<%=parseNull(rsshop.value("lang_1_currency"))%>">
    <meta name="etn:eletaglabel" content="<%=alltags%>">

    <%
        for (int i = 0; i < variantsAlgObjectId.length(); i++) {
    %>
        <meta name="alg:variant_objectid" content="<%=variantsAlgObjectId.getString(i)%>">
    <%
        }
    %>

	<%if(env.length() > 0){ %>
		<meta name="etn:eleenv" content="<%=env%>">
	<% } %>

    <% while(rsMetaTags.next()){%>
        <meta name="<%=rsMetaTags.value("meta_name")%>" content="<%=rsMetaTags.value("content")%>">
    <%}%>

    <%  if(productPagePath.length() > 0) {
            String html_variant_path = "";

            if(html_variant.equals("logged")){
                html_variant_path =  html_variant+"/";
            }

            if(catalogFolderName.length()>0){
                html_variant_path = html_variant_path + catalogFolderName + "/";
            }
            if(folderPath.length()>0){
                html_variant_path = html_variant_path + folderPath + "/";
            }
    %>
        <meta name="etn:eleurl" content="<%=html_variant_path%><%=productPagePath.replaceAll("\"","&quot;")%>">
    <%  } %>



    <title><%=getTitle(pname, listingscreenheading)%></title>

<%
        //by default we will show share bar ... for portals where we have to disable it we just add entry to global param and set it non empty or not 1
        if(parseNull(com.etn.beans.app.GlobalParm.getParm("SHOW_SHARE_BAR")).length() == 0 || parseNull(com.etn.beans.app.GlobalParm.getParm("SHOW_SHARE_BAR")).equals("1"))
        {
            String tempSummary = rs.value("summary");
    %>

    <jsp:include page="WEB-INF/include/sharebar.jsp">
        <jsp:param name="prefix" value="<%=prefix%>" />
        <jsp:param name="ptype" value="<%=PRODUCT_SHAREBAR_TYPE%>" />
        <jsp:param name="id" value="<%=id%>" />
        <jsp:param name="ogImage" value="<%=ogImageSrc%>" />
        <jsp:param name="productName" value="<%=pname%>" />
        <jsp:param name="description" value="<%=metadescription%>" />
        <jsp:param name="summary" value="<%=tempSummary%>" />
    </jsp:include>

<% } %>
<style>
    .hide_important{
        display: none !important;
    }
    @media(min-width:960px){
        .TerminauxDetailsPreview-imgWrapper > img.image-preview {
            max-width: 185px;
        }
        .TerminauxLightbox .TerminauxDetailsPreview-imgWrapper > img.image-lightbox-preview{
            max-width: 500px;
            max-height: 400px;
        }

    }
    @media(max-width:960px){
        .TerminauxDetailsPreview-imgWrapper > img.image-preview {
            max-width: 155px;
        }
        .TerminauxLightbox .TerminauxDetailsPreview-imgWrapper > img.image-lightbox-preview{
            max-width: 100%;
            max-height: 400px;
        }

    }

	.TerminauxImageChoice-variations > div {
		-webkit-box-flex: 1;
		-ms-flex: 1;
		flex: 1;
		padding: 14px 0;
	}

	.TerminauxImageChoice-cellTitle {
		padding: 0 14px 14px 20px;
	}

	.TerminauxImageChoice-inner {
		margin: 0 15px;
	}
</style>
	<script type="text/javascript">
		var asmPageInfo = asmPageInfo || {};
		asmPageInfo.apiBaseUrl = "<%=portalExternalLink%>";
		asmPageInfo.clientApisUrl = "<%=portalExternalLink%>clientapis/";
		asmPageInfo.expSysUrl = "<%=GlobalParm.getParm("EXP_SYS_EXTERNAL_URL")%>";
		asmPageInfo.environment = "<%=(env.equals("")?"P":env)%>";
		asmPageInfo.suid = "<%=rsSite.value("suid")%>";
		asmPageInfo.lang = "<%=lang%>";		
	</script> 	
</head>
<body>

    <div class="PageTitle">
        <div class="container">
            <h1 class="h1-like"><%=(parseNull(rs.value(prefix+"name")).startsWith(libelle_msg(Etn, request,parseNull(rs.value("brand_name"))))?"":libelle_msg(Etn, request,parseNull(rs.value("brand_name"))))%> <%=parseNull(rs.value(prefix+"name"))%></h1>

        </div>
    </div>

<div class="container">

    <div class="row">
        <div class="col-md-12 col-lg-7">
            <div class="TerminauxInformations-mainTab">
            </div>
            <div id="_preloadImages" style="display: none;">
                <%=preloadImages%>
            </div>
            <div class="row">
                <div class="col-custom-45">
                  <div id="TerminauxDetailsPreview-default" class="TerminauxDetailsPreview TerminauxDetailsPreview-default" data-details='<%=variants.toString()%>'>
    <div class="TerminauxDetailsPreview-mainImg swiper-container">
        <div class="swiper-wrapper">
        </div>

    </div>
    <div class="TerminauxDetailsPreview-thumbnail-list d-none d-md-flex">

    </div>

    <div class="TerminauxDetailsPreview-videoBtn d-none d-md-block" style="<%=rs.value("video_url").equals("")?"display:none !important;":""%>" data-toggle="modal" data-target="#productLightbox" data-slide="4">
        <span data-svg="<%=request.getContextPath()%>/assets/icons/icon-play.svg"></span><%=libelle_msg(Etn, request, "Voir la vidéo")%>
    </div>

</div>

                </div>
                <div class="col-custom-55">
                  <div class="TerminauxInformations">


    <div class="TerminauxInformations-description text-md-left">
        <%=rs.value("summary")%>    </div>
        <div id="TerminauxInformations-specifications"><%=rs.value("main_features")%></div>
    <div class="TerminauxInformations-seeMoreBtn d-md-none">
        <span class="TerminauxInformations-seeMoreBtn-plus" data-svg="<%=request.getContextPath()%>/assets/icons/icon-more-add.svg"></span>
        <%=UIHelper.escapeCoteValue(libelle_msg(Etn, request, "Voir plus"))%>
        <span class="TerminauxInformations-seeMoreBtn-dropdown" data-svg="<%=request.getContextPath()%>/assets/icons/icon-bottom.svg"></span>
    </div>

</div>
                </div>
            </div>

        </div>
        <div class="col-md-12 col-lg-5">

        <div id="TerminauxDetailsChoice" class="TerminauxDetailsChoice" data-details=''>

		<%
		String datalayerClass = " etn-data-layer-event ";
		String tooltipAttributes = "";
		String tooltipText = libelle_msg(Etn, request, "Merci de sélectionner un choix");
		if("attributes".equals(parseNull(rs.value("select_variant_by"))) || parseNull(rs.value("select_variant_by")).length() == 0) {%>
    <div class="TerminauxDetailsChoice-variations">
        <%
            int variantCount = 0;
            int tooltipAttributeCount = 0;
            Set rs_cat_attrib = Etn.execute("select * from catalog_attributes where catalog_id="+escape.cote(rs.value("catalog_id"))+" and type='selection' order by sort_order");
            while(rs_cat_attrib.next()){

                if(variantCount==2){
                    variantCount = 0;
        %>

                </div><div class="TerminauxDetailsChoice-variations">
        <%
                }
                boolean showAttribute = true;
                Set rs_check_none = Etn.execute("select pvr.* from catalog_attribute_values cav right join product_variant_ref pvr on cav.id=pvr.catalog_attribute_value_id inner join product_variants pv on pvr.product_variant_id=pv.id and pv.product_id="+escape.cote(id)+" where pv.is_active=1 and pvr.cat_attrib_id="+escape.cote(rs_cat_attrib.value("cat_attrib_id"))+" and pvr.catalog_attribute_value_id='0' group by pvr.catalog_attribute_value_id order by sort_order;");
                if(rs_check_none.rs.Rows>0) showAttribute = false;

                if(showAttribute&&tooltipAttributeCount<2){
                    if(!tooltipAttributes.equals("")) tooltipAttributes += ", ";
                    tooltipAttributes += libelle_msg(Etn, request, rs_cat_attrib.value("name"));
                    tooltipAttributeCount++;
                }
                if(rs_cat_attrib.value("value_type").equals("color")){
        %>
            <div class="TerminauxDetailsChoice-colors" style="<%=(showAttribute?"":"display: none;")%>">
                <div class="TerminauxDetailsChoice-cellTitle"><%=libelle_msg(Etn, request, rs_cat_attrib.value("name"))%> : <span id="colorSpan_<%=rs_cat_attrib.value("cat_attrib_id")%>"></span></div>
                <div class="TerminauxDetailsChoice-colors-inner attributes" data-attribute="<%=rs_cat_attrib.value("cat_attrib_id")%>">
        <%
                }
                else if(rs_cat_attrib.value("value_type").equals("text")){
        %>
            <div class="TerminauxDetailsChoice-stockage" style="<%=(showAttribute?"":"display: none;")%>">
                <div class="TerminauxDetailsChoice-cellTitle"><%=libelle_msg(Etn, request, rs_cat_attrib.value("name"))%></div>
                <div class="TerminauxDetailsChoice-stockage-inner attributes" data-attribute="<%=rs_cat_attrib.value("cat_attrib_id")%>">
                <%if(false){ // for IDE help, balancing the closing divs%>
            </div></div>
        <%
            }%>
        <%
                }
                else{
        %>
            <div class="TerminauxDetailsChoice-stockage" style="<%=(showAttribute?"":"display: none;")%>">
                <div class="TerminauxDetailsChoice-cellTitle"><%=libelle_msg(Etn, request, rs_cat_attrib.value("name"))%></div>
                <div class="TerminauxDetailsChoice-colors-inner"><select class="custom-select attributes" data-attribute="<%=rs_cat_attrib.value("cat_attrib_id")%>">
                    <option value="">-- <%=libelle_msg(Etn, request, "Select")%> <%=libelle_msg(Etn, request, rs_cat_attrib.value("name"))%> --</option>
                    <%if(false){%>
                    </select></div></div>
        <%
            }%>

        <%
                }

                Set rs_product_attrib = Etn.execute("select cav.attribute_value, cav.color, cav.small_text, pvr.* from catalog_attribute_values cav right join product_variant_ref pvr on cav.id=pvr.catalog_attribute_value_id inner join product_variants pv on pvr.product_variant_id=pv.id and pv.product_id="+escape.cote(id)+" where pv.is_active=1 and pvr.cat_attrib_id="+escape.cote(rs_cat_attrib.value("cat_attrib_id"))+" group by pvr.catalog_attribute_value_id order by sort_order;");

                while(rs_product_attrib.next()){
                    String datalayerAttributes = " data-dl_event_category='device_details' data-dl_event_action=\""+UIHelper.escapeCoteValue(libelle_msg(Etn, request, rs_cat_attrib.value("name")))+"_click\" data-dl_event_label=\""+UIHelper.escapeCoteValue((rs_cat_attrib.value("value_type").equals("color")?libelle_msg(Etn, request, rs_product_attrib.value("attribute_value")):libelle_msg(Etn, request, rs_product_attrib.value("small_text"))))+"\"";
                    boolean selected = rs_product_attrib.rs.Rows==1||rs_product_attrib.value("catalog_attribute_value_id").equals("0")||defaultAttribute.get(rs_product_attrib.value("cat_attrib_id")).equals(rs_product_attrib.value("catalog_attribute_value_id"))&&GlobalParm.getParm("SELECT_DEFAULT_VARIANT").equals("1");
                    if(rs_cat_attrib.value("value_type").equals("color")){
        %>
                <div style="background-color: <%=rs_product_attrib.value("color")%>;" class="attribute ColorCircle <%=(selected?"isActive":"")%> <%=datalayerClass%>" <%=datalayerAttributes%> data-name="<%=libelle_msg(Etn, request, rs_product_attrib.value("attribute_value"))%>" data-attribute="<%=rs_product_attrib.value("cat_attrib_id")%>" data-value="<%=rs_product_attrib.value("catalog_attribute_value_id")%>" data-type="<%=rs_cat_attrib.value("value_type")%>">
                    <div class="ColorCircle-externe"></div>
                    <span></span>
                </div>
        <%
                    }
                    else if(rs_cat_attrib.value("value_type").equals("text")){
        %>
                <div class="attribute item <%=(selected?"active":"")%> <%=datalayerClass%>" <%=datalayerAttributes%> data-attribute="<%=rs_product_attrib.value("cat_attrib_id")%>" data-value="<%=rs_product_attrib.value("catalog_attribute_value_id")%>" data-type="<%=rs_cat_attrib.value("value_type")%>"><span></span><%=libelle_msg(Etn, request, rs_product_attrib.value("small_text"))%></div>
        <%
                    }
                    else{
        %>
                <option class="attribute <%=(selected?"active":"")%> <%=datalayerClass%>" <%=datalayerAttributes%> <%=(selected?"selected":"")%> data-attribute="<%=rs_product_attrib.value("cat_attrib_id")%>" data-value="<%=rs_product_attrib.value("catalog_attribute_value_id")%>" data-type="<%=rs_cat_attrib.value("value_type")%>" value="<%=rs_product_attrib.value("id")%>"><span></span><%=libelle_msg(Etn, request, rs_product_attrib.value("small_text"))%></option>
        <%
                    }
                }
        %>

                <%=(rs_cat_attrib.value("value_type").equals("select")?"</select>":"")%></div>
            </div>
        <%
            if(showAttribute) variantCount++;
            }

			if(tooltipAttributes.length() > 0)
			{
				tooltipText += "("+tooltipAttributes+"...)";
			}

                        %>
            </div>
			<%} else {//selection by image%>
				<div class="TerminauxDetailsChoice-variations">
					<%
					Set _rsV = Etn.execute("select * from product_variants where is_active=1 and product_id = " + parseNull(rs.value("id")));
					out.write("<div class='TerminauxImageChoice-stockage'>");
					out.write("<div class='TerminauxImageChoice-cellTitle'><strong>"+libelle_msg(Etn, request, "Selected")+" : </strong><span id='prod_variant_choice'></span></div>");
					out.write("<div class='TerminauxImageChoice-inner'>");
					out.write("<div class='row'>");
					while(_rsV.next())
					{
						String variantImage = "";
						Set rsVr = Etn.execute("select * from product_variant_resources where `type` = 'image' and langue_id = "+escape.cote(language.getLanguageId()) + " and product_variant_id = "+escape.cote(_rsV.value("id"))+ " order by sort_order  limit 1 ");
						if(rsVr.next()) {
                            String esImageActualName = rsVr.value("actual_file_name");
                            Set rsMedia = Etn.execute("select * from "+GlobalParm.getParm("PAGES_DB")+".files where file_name="+escape.cote(esImageActualName)+
                                " and site_id="+escape.cote(siteId)+" and (COALESCE(removal_date,'') = '' or  removal_date>now())");

                            if(rsMedia.rs.Rows>0){
                                variantImage = GlobalParm.getParm("MEDIA_LIBRARY_UPLOADS_URL") + siteId + "/img/thumb/" + rsVr.value("path");
                            }
                        }

						Set rs_product_attrib = Etn.execute("select cav.attribute_value, cav.color, cav.small_text, pvr.* from catalog_attribute_values cav right join product_variant_ref pvr on cav.id=pvr.catalog_attribute_value_id where pvr.product_variant_id = "+escape.cote(_rsV.value("id"))+" order by cav.sort_order");
						String attribString = "";
						while(rs_product_attrib.next())
						{
							attribString += " " + parseNull(rs_product_attrib.value("attribute_value"));
						}
						out.write("<div class='variantimageselection border border-light col-2 col-sm-3 mb-2 mr-1' style='padding:2px;cursor:pointer;text-align:center' data-variant_id='"+_rsV.value("id")+"' data-variant_desc='"+UIHelper.escapeCoteValue(parseNull(attribString))+"'><img src='"+variantImage+"' style='max-height:50px;width:auto;' ></div>");
					}
					out.write("</div>");//row
					out.write("</div>");//TerminauxImageChoice-inner
					out.write("</div>");//TerminauxImageChoice-stockage
					%>
				</div>
			<%}%>
			<div class="TerminauxDetailsChoice-variations"></div>
            <div id="variantHtmlContainer">

            </div>
</div>
        </div>
    </div>
</div>

<%
    Set rsEssentials = Etn.execute("select * from product_essential_blocks where product_id="+escape.cote(id)+" and langue_id="+escape.cote(language.getLanguageId())+" order by order_seq;");
    if(rsEssentials.rs.Rows!=0){

%>
<div class="Essentiel">
    <div class="container">
        <h2><%=libelle_msg(Etn, request, "L'essentiel")%></h2>

        <div class="Essentiel-swiper swiper-container">
            <div class="Essentiel-list swiper-wrapper">
            <%
                String essentialsAlign = "";

                if(rs.value("essentials_alignment").contains("_right")) essentialsAlign = "align-reverse";

                while(rsEssentials.next()){
                    String esImageActualName = rsEssentials.value("actual_file_name");
                    Set rsMedia = Etn.execute("select * from "+GlobalParm.getParm("PAGES_DB")+".files where file_name="+escape.cote(esImageActualName)+
                        " and site_id="+escape.cote(siteId)+" and (COALESCE(removal_date,'') = '' or  removal_date>now())");

                    if(rsMedia.rs.Rows>0){
                        String esImageName = rsEssentials.value("file_name");
                        String esImageUrl = GlobalParm.getParm("MEDIA_LIBRARY_UPLOADS_URL") + siteId + "/img/" + esImageName;
            %>
                        <div class="Essentiel-item swiper-slide <%=essentialsAlign%>">
                            <div class="Essentiel-photo">
                                <img src="<%=esImageUrl%>" alt="<%=rsEssentials.value("image_label")%>">
                            </div>
                            <div class="Essentiel-content">
                                <%=rsEssentials.value("block_text")%>
                            </div>
                        </div>

            <%
                        if(rs.value("essentials_alignment").startsWith("zig_zag")){
                            if(essentialsAlign.equals("")) essentialsAlign = "align-reverse";
                            else essentialsAlign = "";
                        }
                    }
                }
            %>
            </div>
        </div>

        <div class="swiper-pagination"></div>
    </div>
</div>
<%}%>
<div class="Onglets">
    <div class="container">
        <div class="o-tab-container accordion-layout">
            <%
                String oactive = " show ";

            if(rscat.value("catalog_type").equals("device")){
                String specs = getSummary(Etn, request, rs.value("id"), parseNull(rs.value("import_source")));
                if(!specs.equals("")){
                    String datalayerAttributes = " data-dl_event_category='tab_details' data-dl_event_action='tab_click' data-dl_event_label=\""+UIHelper.escapeCoteValue(libelle_msg(Etn, request, "Fiche technique"))+"\"";
            %>
            <a class="o-tab-heading <%=datalayerClass%>" <%=datalayerAttributes%> data-toggle="tab" href="" id="tab1"><%=libelle_msg(Etn, request, "Fiche technique")%></a>
            <div class="o-tab-content show" id="tab-1-content">
                <%out.write(specs);%>
            </div>

            <%
                oactive = "";
                }
                }
                 Set rstabs = Etn.execute("select * from product_tabs where product_id = " + escape.cote(id) + " and  langue_id = " + escape.cote(language.getLanguageId()) + " order by case coalesce(order_seq,'') when '' then 999999 else order_seq end ");
                while(rstabs.next()){
                    String datalayerAttributes = " data-dl_event_category='tab_details' data-dl_event_action='tab_click' data-dl_event_label=\""+UIHelper.escapeCoteValue(parseNull(rstabs.value("name")))+"\"";
            %>
            <a class="o-tab-heading <%=datalayerClass%>" <%=datalayerAttributes%> data-toggle="tab" href="" ><%=parseNull(rstabs.value("name"))%></a>
            <div class="o-tab-content <%=oactive%>" id="<%=fixTabname(parseNull(rstabs.value("name")))%>">
                <%=parseNull(rstabs.value("content"))%>
            </div>
            <%
                    oactive = "";
                }
                String datalayerAttributes = " data-dl_event_category='tab_details' data-dl_event_action='tab_click' data-dl_event_label=\""+UIHelper.escapeCoteValue(libelle_msg(Etn, request, "Avis clients"))+"\"";
            %>
        </div>
    </div>
</div>

<div class="container">
        <div id='__sharebar' class='__sharebar'>
            <div id="sharebar"></div>
        </div>
    <div class="pageStyle-hr-line"></div>
    <div class="prixTaxesComprises">
        <div class="btn-50 left">
            <a href="javascript:goBack();" ><img src="<%=request.getContextPath()%>/assets/icons/icon-angle-left.svg" alt="">
          <%=libelle_msg(Etn, request, "Retour")%></a>
        </div>

        <div class="btn-50 right" id="pricestaxincludediv" style="display:none"><%=libelle_msg(Etn, request, "Prix toutes taxes comprises")%></div>
        <div class="btn-50 right" id="pricestaxexclusivediv" style="display:none"><%=libelle_msg(Etn, request, "Les prix sont affichés hors taxes")%></div>

    </div>
</div>

<div class="container">
    <div class="pageStyle-hr-line"></div>
</div>



<div class="modal fade TerminauxLightbox" id="productLightbox" tabindex="-1" role="dialog"
     aria-labelledby="productLightboxTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">

            <div class="TerminauxLightbox-innerWrapper">
                <div class="TerminauxLightbox-close" data-dismiss="modal">
                    <img src="<%=request.getContextPath()%>/assets/icons/icon-close.svg" alt="">
                </div>

                <div class="TerminauxDetailsPreview TerminauxDetailsPreview-lightbox">
                    <div class="TerminauxDetailsPreview-mainImg swiper-container">
                        <div class="swiper-wrapper">
                                <div class="swiper-slide" data-slide-video="true" style="<%=rs.value("video_url").equals("")?"display:none !important;":""%>">
                                <div class="gabarit-video">
                                    <img src="<%=request.getContextPath()%>/assets/illustrations/gabarit-16-9.gif"
                                         alt="">
                                    <%if(!rs.value("video_url").equals("")){%>
                                    <iframe class="TerminauxDetailsPreview-iframe" width="560" height="315"
                                            src="<%=rs.value("video_url")+(rs.value("video_url").contains("?")?"&enablejsapi=1":"?enablejsapi=1")%>"
                                            frameborder="0"
                                            allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture"
                                            allowfullscreen></iframe>
                                    <%}%>
                                </div>
                            </div>

                        </div>

                    </div>
                    <div class="TerminauxDetailsPreview-thumbnail-list d-flex">
                        <div class="TerminauxDetailsPreview-thumbnail-item">
                            <div class="item-inside"></div>
                        </div>
                        <div class="TerminauxDetailsPreview-thumbnail-item">
                            <div class="item-inside"></div>
                        </div>
                        <div class="TerminauxDetailsPreview-thumbnail-item">
                            <div class="item-inside"></div>
                        </div>
                        <%if(!rs.value("video_url").equals("")){%>
                        <div class="TerminauxDetailsPreview-thumbnail-item" data-slide-video="true" >
                            <div class="item-inside">
                                <div class="TerminauxDetailsPreview-playIcon">
                                    <span data-svg="<%=request.getContextPath()%>/assets/icons/icon-play.svg"></span>
                                </div>
                            </div>
                        </div>
                        <%}%>
                    </div>

                </div>

            </div>

        </div>
    </div>
</div>

<div id="associatedProductLightBoxContainer">
</div>


<div class="BasketModal modal fade" id="addModal" tabindex="-1" role="dialog" aria-labelledby="addModalTitle"
     aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-body">
                <div class="BasketModal-title" id="addModalTitle">
                    <span class="BasketModal-iconTitle"
                          data-svg="/src/assets/icons/icon-valid.svg"></span>
                    <span class="BasketModal-titleWrapper h2"><%=libelle_msg(Etn, request, "Cet article a bien été ajouté à votre panier")%></span>
                </div>
                <div class="BasketModal-actions BasketModal-section">				
                    <button type="button" class="btn btn-secondary etn-data-layer-event asm-continue-shop-btn" data-continue_url="<%=continueShoppingUrl%>" data-dl_event_action="button_click" data-dl_event_category="popin_add_products" data-dl_event_label="continue_buy" data-dismiss="modal" data-bs-dismiss="modal" onclick="continueShopping(this);"><%=libelle_msg(Etn, request, "Continuer les achats")%></button>
                    <button type="button" class="btn btn-primary etn-data-layer-event" data-dl_event_action="button_click" data-dl_event_category="popin_add_products" data-dl_event_label="see_cart" onclick="proceedToCart();"><%=libelle_msg(Etn, request, "Voir le panier")%></button>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="BasketModal modal fade" id="quantityLimitModal" tabindex="-1" role="dialog" aria-labelledby="errorDeliveryTitle"
     aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-body">
                <div class="BasketModal-title">
                    <span class="BasketModal-iconTitle"
                          data-svg="/src/assets/icons/icon-alert.svg"></span>
                    <span class="BasketModal-titleWrapper h2"><%=libelle_msg(Etn, request, "Quantity limit reached")%></span>
                </div>

                <div class="BasketModal-section">
                    <p><%=libelle_msg(Etn, request, "You have reached the quantity authorized for that product")%></p>
                </div>

                <div class="BasketModal-actions BasketModal-section">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal" data-bs-dismiss="modal"><%=libelle_msg(Etn, request, "OK")%></button>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="BasketModal modal fade" id="stockLimitModal" tabindex="-1" role="dialog" aria-labelledby="errorDeliveryTitle"
     aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-body">
                <div class="BasketModal-title">
                    <span class="BasketModal-iconTitle"
                          data-svg="/src/assets/icons/icon-alert.svg"></span>
                    <span class="BasketModal-titleWrapper h2"><%=libelle_msg(Etn, request, "Stock limit reached")%></span>
                </div>

                <div class="BasketModal-section">
                    <p><%=libelle_msg(Etn, request, "You have reached the maximum stock for that product")%></p>
                </div>

                <div class="BasketModal-actions BasketModal-section">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal" data-bs-dismiss="modal"><%=libelle_msg(Etn, request, "OK")%></button>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="<%=request.getContextPath()%>/js/newui/TweenMax.min.js"></script> <!-- removed at time of caching -->
<script src="<%=request.getContextPath()%>/js/newui/swiper.min.js"></script>
<script src="<%=request.getContextPath()%>/js/newui/bundle.js"></script>
<script src="<%=request.getContextPath()%>/js/bootbox.min.js"></script>
<script src="<%=request.getContextPath()%>/js/nocache/variant.js"></script>

<script>
    var showBasket = "<%=parseNull(rs.value("show_basket"))%>";
    var ecommerceEnabled = <%=ecommerceEnabled%>;
    var variantsData = [];
    var cartUrl = "<%=GlobalParm.getParm("CART_URL")%>";
    var portalUrl = "<%=GlobalParm.getParm("PORTAL_URL")%>";
    var buyStatus = "<%=rscat.value("buy_status")%>";
    var product_uuid = "<%=product_uuid%>";
    var selectedComewithVariant = "";

	var addtocartid = "";
	var addtocartincrement = "";
    <%if("1".equals(ispreview))
    {%>
        var ______muid = "<%=___prvMuid%>";
    <%}%>
    $(document).ready(function() {
        var postData = 'product_uuid=<%=product_uuid%>&lang=<%=lang%>&menu_uuid='+______muid;
        initializeVariants(postData,'<%=request.getContextPath()%>').then(()=>{
            var detailChoice = document.getElementById("TerminauxDetailsChoice");
            if(!urlSearchParams()){
                var url = new URL(window.location);
                Array.from(detailChoice.querySelectorAll("[class*=active i][data-dl_event_action]")).forEach((e)=>{
                    url.searchParams.set(e.dataset.dl_event_action.replace("_click","").toLowerCase(),e.dataset.dl_event_label.toLowerCase());
                });
                window.history.replaceState(null,"",url);
            }
            
            Array.from(detailChoice.querySelectorAll("[data-dl_event_action][class*=attribute i]")).forEach((e)=>{
                e.addEventListener("click",function(){
                    var url = new URL(window.location);
                    let flag=false;
                    e.classList.forEach((e)=>{
                        if(flag) return;
                        flag = e.toLowerCase().includes("active") ;
                    });
                    if(flag){
                        url.searchParams.set(e.dataset.dl_event_action.replace("_click","").toLowerCase(),e.dataset.dl_event_label.toLowerCase());
                    }else{
                        url.searchParams.delete(e.dataset.dl_event_action.replace("_click","").toLowerCase());
                    }
                    window.history.replaceState(null,"",url);
                });
            })
            
        }).catch(console.error);
        initSharebar(".__sharebar","<%=libelle_msg(Etn, request, "Partager sur")%>");
    });

    function urlSearchParams()
    {
        let isParam = false;
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        var detailChoice = document.getElementById("TerminauxDetailsChoice");        
        for (const [key, value] of urlParams.entries()) {
            isParam = true;
            let cssSelector = "[data-dl_event_action='"+key+"_click' i][data-dl_event_label='"+value+"' i]";
            let ele = detailChoice.querySelector(cssSelector);
            if(ele){
                if(!(ele.classList.contains("isActive") || ele.classList.contains("active") || ele.classList.contains("disabled")) ){                    
                    if(ele.dataset.type=='select')
                    {
                        ele.selected=true;
                        ele.parentElement.dispatchEvent(new Event("change"));
                    }else{
                        ele.click();
                    }
                }
            }
        }
        return isParam;
    }

	function getVariantImpressionAttributes(variant, extra_attrs)
	{
		if(variant.id=="0") return "";
		//add all variant impression attributes
		var h = " data-pi_category='"+variant.productCategory.replace("\"","&#34;").replace("'","&#39;")+"' ";
		h += " data-pi_brand='"+variant.productBrand.replace("\"","&#34;").replace("'","&#39;")+"' ";
		h += " data-pi_id='"+variant.sku.replace("\"","&#34;").replace("'","&#39;")+"' ";
		h += " data-pi_name='"+variant.productName.replace("\"","&#34;").replace("'","&#39;")+"' ";
		h += " data-pi_variant='"+variant.variantName.replace("\"","&#34;").replace("'","&#39;")+"' ";
		h += " data-pi_price='"+(variant.baseRate.dlNewPrice+"").replace("\"","&#34;").replace("'","&#39;")+"' "

		var extraImpAttr = new Object();
		for (var key in variant.extraImpressionAttrs)
		{
			var val = variant.extraImpressionAttrs[key] +"";
			h += " data-extra_" + key + "='"+val.replace("\"","&#34;").replace("'","&#39;")+"'";
			extraImpAttr["data-extra_"+key] = val;
		}
		//after setting all attributes check if attributes coming in dimensionX, dimensionXX, metricXX exists in html then add these attributes as well

		for(var key in extra_attrs)
		{
			var val = "";
			if(extraImpAttr[extra_attrs[key]] != null ) val = extraImpAttr[extra_attrs[key]] + "";

			h += " data-pi_" + key + "='"+val.replace("\"","&#34;").replace("'","&#39;")+"'";
		}
		return h;
	};

    function generateVariantsHtml(json, contextPath)
	{
        var html = "";
        var discountCardHtml = "";
        for(var i=0; i<json.variants.length; i++)
        {
            var etnVarCls = " etn-products-variants ";

            if(json.variants[i].id=="0")
			{
				etnVarCls = "";

                if(json.variants[i].showamountwithtax===true)
                {
                    $("#pricestaxexclusivediv").hide();
                    $("#pricestaxincludediv").show();
                }
                else
                {
                    $("#pricestaxincludediv").hide();
                    $("#pricestaxexclusivediv").show();
                }
            }

            var count = i+1;
            html+="<div id='product_variant_"+json.variants[i].id+"' class=\"price text-md-left "+etnVarCls+" "+(json.variants[i].is_default=="1"?"default-variant":"")+"\" data-linkedvariant=\""+json.variants[i].id+"\""
				+ " " + getVariantImpressionAttributes(json.variants[i], json.extra_product_impression_attrs) + " "
                +">"
                +"       <div class=\"forfait-mobile d-md-none\">"
                +"  <div class=\"forfait-mobile-row\" style='"+(json.variants[i].flatRate.newPrice==""?"display:none":"")+"'>"
                +"    <div class=\"forfait-mobile-with active\" data-increment=\""+count+"\">"
                +"      <span class=\"forfait-mobile-svg\""
                +"           data-svg=\""+contextPath+"/assets/icons/icon-sim.svg\"></span>"
                +"       <span class=\"forfait-mobile-title\"><%=libelle_msg(Etn, request, "Avec forfait")%></span>"
                +"       <div class=\"active-line\"></div>"
                +"    </div>"
                +"      <div class=\"forfait-mobile-without\" data-increment=\""+count+"\">"
                +"       <span class=\"forfait-mobile-svg\""
                +"            data-svg=\""+contextPath+"/assets/icons/icon-no-sim.svg\"></span>"
                +"        <span class=\"forfait-mobile-title\"><%=libelle_msg(Etn, request, "Sans forfait")%></span>"
                +"        <div class=\"active-line\"></div>"
                +"    </div>"
                +"  </div>"
                +"  <div class=\"forfait-mobile-baseline\"></div>"
                +"  </div>"
                +"     <div class=\"TerminauxDetailsChoice-aPArtirDe\" style=\""+(json.variants.length<2?"":"")+"\">"
                +json.variants[i].baseRate.text+"</div>"
                +" <div class=\"d-none d-md-block pageStyle-boldOrange\">"+json.variants[i].baseRate.newPrice+"</div>"
                +" <div class=\"d-none d-md-block pageStyle-through\">"+(json.variants[i].baseRate.oldPrice==json.variants[i].baseRate.newPrice?"":json.variants[i].baseRate.oldPrice)+"</div>"
                +"<div class=\"d-md-none\">"
                +"  <div class=\"pageStyle-boldOrange prix-mobile-avec-forfait\">"+json.variants[i].flatRate.newPrice+"</div>"
                +"  <div class=\"pageStyle-boldOrange prix-mobile-sans-forfait\">"+json.variants[i].baseRate.newPrice+"</div>"
                +"  <div class=\"pageStyle-through prix-mobile-avec-forfait\">"+(json.variants[i].flatRate.oldPrice==json.variants[i].flatRate.newPrice?"":json.variants[i].flatRate.oldPrice)+"</div>"
                +" <div class=\"pageStyle-through prix-mobile-sans-forfait\">"+(json.variants[i].baseRate.oldPrice==json.variants[i].baseRate.newPrice?"":json.variants[i].baseRate.oldPrice)+"</div>"
                +"   </div>";
                if(ecommerceEnabled && json.variants[i].id!="0"){
                    if(json.variants[i].inStock){
                    html+="     <div class=\"stock available\">"
                        +"   <span data-svg=\""+contextPath+"/assets/icons/icon-check.svg\"></span>"
                        +"    <%=libelle_msg(Etn, request, "En stock")%>"
                        +"  </div>";
                    }
                    else{
                    }
					<% if(rsshop.value("show_product_detail_delivery_fee").equals("1")){%>
                    if(json.variants[i].deliveryFee != ""){
                    html+="     <div class=\"deliveryfee   d-flex flex-row\"  style=\"font-weight:bold;\">"
                    +"   <span  data-svg=\""+contextPath+"/assets/icons/icon-fast-delivery.svg\"></span><p style=\"margin-top:8px;margin-left:10px;\">"+json.variants[i].deliveryFee+"</p>"
                        +"  </div>";
                    }
					<%}%>
                }
                if(json.variants[i].id!="0" && json.variants[i].flatRate.newPrice!=""){
                    html+="<div class=\"forfait d-none d-md-block\">"
                        +"<table><thead><tr>"
                        +"<td width=\"99%\"></td>"
                        +"<td><div class=\"caption\"><%=libelle_msg(Etn, request, "À partir de")%></div></td>"
                        +"</tr></thead><tbody><tr><td>"
                        +"<div class=\"custom-control custom-radio\">"
                        +"<input type=\"radio\" id=\"customRadio1-"+count+"\" name=\"customRadio"+count+"\" class=\"forfaitRadio custom-control-input\" checked data-url=\""+json.variants[i].flatRate.url+"\" value=\"with\">"
                        +"<label class=\"custom-control-label\" for=\"customRadio1-"+count+"\">"
                        +"<span class=\"option-title\"><%=libelle_msg(Etn, request, "Avec forfait")%></span>"
                        +"</label></div></td><td>"
                        +"<span class=\"option-price\">"+json.variants[i].flatRate.newPrice+"</span>"
                        +"</td></tr><tr><td>"
                        +"<div class=\"custom-control custom-radio\">"
                        +"<input type=\"radio\" id=\"customRadio2-"+count+"\" name=\"customRadio"+count+"\" class=\"forfaitRadio custom-control-input\" value=\"without\">"
                        +"<label class=\"custom-control-label\" for=\"customRadio2-"+count+"\">"
                        +"<span class=\"option-title\"><%=libelle_msg(Etn, request, "Sans forfait")%></span>"
                        +"</label></div></td><td>"
                        +"<span class=\"option-price\">"+json.variants[i].baseRate.newPrice+"</span>"
                        +"</td></tr></tbody></table></div>";
                }

                var datalayerAttributes = " data-dl_event_category='product_page'";

                html+="<div id='TerminauxInformations-mainTab_"+json.variants[i].id+"' style='display:none;'>";
                if(ecommerceEnabled && !json.variants[i].inStock){
					if(showBasket=="1") html+="<div class=\"Tab Tab-red\"><div class=\"Tab-left\"><%=libelle_msg(Etn, request, "Indisponible")%><div class=\"Tab-triangle\"></div></div><div class=\"Tab-right\"></div></div>";
                }
                else if(!(Object.entries(json.variants[i].promotion).length === 0 && json.variants[i].promotion.constructor === Object)){
                    html+="<div class=\"Tab Tab-orange\"><div class=\"Tab-left\">";

                    if(json.variants[i].promotion.flash_sale!="no"){
                        html+="<div class=\"Tab-icon\" data-svg=\"<%=request.getContextPath()%>/assets/icons/icon-timer.svg\"></div><%=libelle_msg(Etn, request, "Vente flash")%>";
                    }
                    else{
                        html+="<%=libelle_msg(Etn, request, "Promotion")%>";
                    }

                    html+="<div class=\"Tab-triangle\"></div></div><div class=\"Tab-right\">";

                    if(json.variants[i].promotion.flash_sale=="time" && json.variants[i].promotion.end_date!="0000-00-00 00:00:00"){
                        html+="<div class=\"Counter\" data-timestamp=\""+Math.round((new Date(json.variants[i].promotion.end_date)).getTime() / 1000)+"\"><div class=\"Counter-display Counter-days\">00</div>"
                        +"<div class=\"Counter-separator\">:</div><div class=\"Counter-display Counter-hours\">00</div>"
                        +"<div class=\"Counter-separator\">:</div><div class=\"Counter-display Counter-minutes\">00</div>"
                        +"<div class=\"Counter-separator\">:</div><div class=\"Counter-display Counter-seconds\">00</div>"
                        +"<div class=\"Counter-hline\"></div></div>";
                    }
                    else if(json.variants[i].promotion.flash_sale=="quantity"){
                        html+="<div class=\"Tab-additional\">"+"<%=libelle_msg(Etn, request, "Plus que <qty> articles")%>".replace("<qty>",json.variants[i].promotion.flash_sale_quantity)+"</div>";
                    }
                    html+="</div></div>";

                }
                else if(json.variants[i].sticker!=""&&json.variants[i].sticker!="none"){

                    if(json.variants[i].sticker=="new") html+="<div class=\"Tab\" style=\"border-bottom: 2px solid "+json.variants[i].stickerColor+"\"><div class=\"Tab-left\" style=\"background-color: "+json.variants[i].stickerColor+"\">"+json.variants[i].stickerDisplayName+"<div class=\"Tab-triangle\"></div></div><div class=\"Tab-right\"></div></div>";
                    else if(json.variants[i].sticker=="web") html+="<div class=\"Tab\" style=\"border-bottom: 2px solid "+json.variants[i].stickerColor+"\"><div class=\"Tab-left\" style=\"background-color: "+json.variants[i].stickerColor+"\">"+json.variants[i].stickerDisplayName+"<div class=\"Tab-triangle\"></div></div><div class=\"Tab-right\"></div></div>";
                    else html+="<div class=\"Tab\" style=\"border-bottom: 2px solid "+json.variants[i].stickerColor+"\"><div class=\"Tab-left\" style=\"background-color: "+json.variants[i].stickerColor+"\">"+json.variants[i].stickerDisplayName+"<div class=\"Tab-triangle\"></div></div><div class=\"Tab-right\"></div></div>";
                }
                else{
                    html+="<div class=\"Tab Tab-hidden\"><div class=\"Tab-left\"><div class=\"Tab-triangle\"></div></div><div class=\"Tab-right\"></div></div>";
                }
                html+="</div>";


                discountCardHtml = "<div class='TerminauxDetailsChoice-discounts-gifts-wrapper' data-linkedvariant=\""+json.variants[i].id+"\"><div>";
                if(!(Object.entries(json.variants[i].promotion).length === 0 && json.variants[i].promotion.constructor === Object)){
                    discountCardHtml+="<div class='DiscountCard etn-data-layer-event' data-dl_event_category='promo' data-dl_event_action='tab_click' data-dl_event_label='"+json.variants[i].promotion.description.replace("\"","&#34;").replace("'","&#39;")+"' ><div class='DiscountCard-header collapsed' data-toggle='collapse' data-target='#DiscountCard_"+json.variants[i].id+"' aria-expanded='false'><div class='DiscountCard-colLeft'><div class='DiscountCard-title'>";
                    if(json.variants[i].promotion.flash_sale!="no"){
                        discountCardHtml+="<%=libelle_msg(Etn, request, "Vente flash")%> : ";
                    }
                    else{
                        discountCardHtml+="<%=libelle_msg(Etn, request, "Promo")%> : ";
                    }
                    discountCardHtml+=json.variants[i].promotion.title.replace("<amount>",json.variants[i].promotion.discountAmount).replace("<currency>",json.variants[i].promotion.currency).replace("<duration>",json.variants[i].promotion.duration)+"</div><div class='DiscountCard-subtitle'>";
                    if(json.variants[i].promotion.promotion_start_date!="") discountCardHtml+="<%=libelle_msg(Etn, request, "à partir du <start_date>")%> ".replace("<start_date>",json.variants[i].promotion.promotion_start_date);
                    if(json.variants[i].promotion.promotion_end_date!="") discountCardHtml+="<%=libelle_msg(Etn, request, "jusqu'au <end_date>")%>".replace("<end_date>",json.variants[i].promotion.promotion_end_date);
                    discountCardHtml+="</div>";

                    if(json.variants[i].promotion.flash_sale=="time" && json.variants[i].promotion.end_date!="0000-00-00 00:00:00"){

                        discountCardHtml+="<div class=\"DiscountCard-subtitle\"><div class=\"Counter\" data-timestamp=\""+Math.round((new Date(json.variants[i].promotion.end_date)).getTime() / 1000)+"\"><div class=\"Counter-display Counter-days\">00</div>"
                        +"<div class=\"Counter-separator\">:</div><div class=\"Counter-display Counter-hours\">00</div>"
                        +"<div class=\"Counter-separator\">:</div><div class=\"Counter-display Counter-minutes\">00</div>"
                        +"<div class=\"Counter-separator\">:</div><div class=\"Counter-display Counter-seconds\">00</div>"
                        +"<div class=\"Counter-hline\"></div></div></div>";
                    }
                    discountCardHtml+='</div><div class="DiscountCard-colRight"><span><svg width="30px" height="30px" viewBox="0 0 30 30" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><g stroke="none" stroke-width="1" fill="none" fill-rule="evenodd"><polygon fill="#000000" points="8 11 15.5002121 19 23 11.0002263 23 11"></polygon></g></svg></span></div></div>';
                    discountCardHtml+="<div class='DiscountCard-body collapse' id='DiscountCard_"+json.variants[i].id+"'><div class='collapse-content'>"+json.variants[i].promotion.description+"</div></div></div>"; // discountCard ends

                }

                discountCardHtml+="</div>";

                var associatedProductLightBoxHtml = "";
                for(var j=0; j<json.variants[i].comewith.length; j++){
                    var typeText = (json.variants[i].comewith[j].comewith=="gift"?"<%=libelle_msg(Etn, request, "Offert")%>":"<%=libelle_msg(Etn, request, "Inclus")%>");
                    discountCardHtml+="<div class='AssociatedProduct-container etn-data-layer-event' data-dl_event_category='comes-with' data-dl_event_action='tab_click' data-dl_event_label='"+json.variants[i].comewith[j].title.replace("\"","&#34;").replace("'","&#39;")+"'>";
                    discountCardHtml+="<div class='Tab Tab-yellow'>";
                    discountCardHtml+="<div class='Tab-left'>";
                    discountCardHtml+=typeText+"<div class='Tab-triangle'></div>";
                    discountCardHtml+="</div><div class='Tab-right'></div></div>";

                    discountCardHtml+="<div class='AssociatedProduct' data-toggle='modal' data-target='#blocAssociatedProductLightbox"+count+"_"+j+"'>";
                    if(json.variants[i].comewith[j].imageUrl!=""&&json.variants[i].comewith[j].comewith!="label"){
                        discountCardHtml+="<div class='photo'>";
                        discountCardHtml+="<img id='comewithImage_"+json.variants[i].comewith[j].id+"' src='"+json.variants[i].comewith[j].selectableVariants[0].imageUrl+"' alt=''>";
                        discountCardHtml+="</div>";
                    }
                    discountCardHtml+="<div class='texte'>";
                    discountCardHtml+="<div class='pageStyle-bold'>"+typeText+"</div>";
                    discountCardHtml+="<div>"+json.variants[i].comewith[j].title+"</div>";
                    discountCardHtml+="</div></div></div>";


                    associatedProductLightBoxHtml+="<div class='modal fade BlocAssociatedProductLightbox "+(json.variants[i].comewith[j].selectableVariants.length>1?"BlocAssociatedProductLightbox_"+json.variants[i].id:"")+"' id='blocAssociatedProductLightbox"+count+"_"+j+"' tabindex='-1' role='dialog' aria-labelledby='blocAssociatedProductLightboxTitle' aria-hidden='true'>";
                    associatedProductLightBoxHtml+="<div class='modal-dialog modal-dialog-centered' role='document'>";
                    associatedProductLightBoxHtml+="<div class='modal-content'>";
                    if(json.variants[i].comewith[j].comewith!="label" && json.variants[i].comewith[j].selectableVariants.length>1 && json.variants[i].comewith[j].variant_type=="select"){
                        associatedProductLightBoxHtml+="<div class='modal-header showComeWithVariantSelection'>";
                        associatedProductLightBoxHtml+="<h5 class='modal-title'><%=libelle_msg(Etn, request, "Choose")%> : <span class='text-muted'>"+json.variants[i].comewith[j].productName+"</span> </h5>";
                        associatedProductLightBoxHtml+="<button type='button' class='close' data-dismiss='modal' data-bs-dismiss='modal' style=\"background: url(&quot;data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 30 30'%3e%3cpath d='M15 17.121l-8.132 8.132-2.121-2.12L12.879 15 4.747 6.868l2.12-2.121L15 12.879l8.132-8.132 2.12 2.121L17.122 15l8.132 8.132-2.121 2.12L15 17.123z'/%3e%3c/svg%3e&quot;) no-repeat 50%/1.875rem; margin: 0;\"> <span class='sr-only'>Close static modal demo</span> </button>";
                        associatedProductLightBoxHtml+="</div>";
                        associatedProductLightBoxHtml+="<div class='modal-body'>";
                        associatedProductLightBoxHtml+="<p> <%=libelle_msg(Etn, request, "Selected")%> : <span class='text-muted selectedcomewithvarianttext'></span></p>";
                        associatedProductLightBoxHtml+="<div class='mb-3 row'>";
                        for(var k=0; k<json.variants[i].comewith[j].selectableVariants.length; k++){
                            associatedProductLightBoxHtml+="<div class='col-3 mb-3 "+((json.variants[i].comewith[j].selectableVariants[k].stock>0 || json.variants[i].comewith[j].selectableVariants[k].product_type.startsWith("offer_"))?"selectableVariant":"")+"' data-variant_id='"+json.variants[i].comewith[j].selectableVariants[k].variant_id
                                                            +"' data-variant_name='"+json.variants[i].comewith[j].selectableVariants[k].variantName+"' data-stock='"+json.variants[i].comewith[j].selectableVariants[k].stock+"' data-comewith_id='"+json.variants[i].comewith[j].id+"'>";
                            associatedProductLightBoxHtml+="<a href='javascript:void(0)'><img src='"+json.variants[i].comewith[j].selectableVariants[k].imageUrl+"' class='border border-light selectableVariantImage' style='"+((json.variants[i].comewith[j].selectableVariants[k].stock==0&&json.variants[i].comewith[j].selectableVariants[k].product_type.startsWith("offer_")==false)?"opacity: 0.5; cursor: default":"")+"'></a>";
                            associatedProductLightBoxHtml+="</div>";
                        }
                        associatedProductLightBoxHtml+="</div></div>";
                        associatedProductLightBoxHtml+="<div class='modal-footer'>";
                        associatedProductLightBoxHtml+="<button type='button' class='btn btn-primary' data-dismiss='modal' data-bs-dismiss='modal' onclick='comewithselectionconfirm()'><%=libelle_msg(Etn, request, "Confirm")%></button>";
                        associatedProductLightBoxHtml+="</div>";
                    }
                    else{
                        associatedProductLightBoxHtml+="<div class='BlocAssociatedProductLightbox-innerWrapper'>";
                        if(json.variants[i].comewith[j].imageUrl!=""&&json.variants[i].comewith[j].comewith!="label"){
                            associatedProductLightBoxHtml+="<div class='BlocAssociatedProductLightbox-image' >";
                            associatedProductLightBoxHtml+="<img src='"+json.variants[i].comewith[j].imageUrl+"' alt=''>";
                            associatedProductLightBoxHtml+="</div>";
                        }
                        associatedProductLightBoxHtml+="<div class='BlocAssociatedProductLightbox-texte'>";
                        associatedProductLightBoxHtml+="<h2>"+(json.variants[i].comewith[j].comewith!="label"?json.variants[i].comewith[j].productName:"<%=libelle_msg(Etn, request, "Inclus")%>")+"</h2>";
                        associatedProductLightBoxHtml+="<div class='pageStyle-bold'>";
                        associatedProductLightBoxHtml+=json.variants[i].comewith[j].title;
                        associatedProductLightBoxHtml+="</div>";
                        associatedProductLightBoxHtml+="<div>";
                        associatedProductLightBoxHtml+=json.variants[i].comewith[j].description;
                        associatedProductLightBoxHtml+="</div></div>";
                        associatedProductLightBoxHtml+="<div class='BlocAssociatedProductLightbox-close' data-bs-dismiss='modal' data-dismiss='modal'>";
                        associatedProductLightBoxHtml+="<img src='<%=request.getContextPath()%>/assets/icons/icon-close.svg' alt=''></div>";
                        associatedProductLightBoxHtml+="</div>";
                    }
                    associatedProductLightBoxHtml+="</div></div></div>";
                }
                $("#associatedProductLightBoxContainer").append(associatedProductLightBoxHtml);

                discountCardHtml+="</div>";

                for(var j=0; j<json.variants[i].additionalFee.length; j++){
                    html+="   <div class=\"Warning\">"
                    +" <div class=\"Warning-title\">"
                    +" <span data-svg=\""+contextPath+"/assets/icons/icon-info.svg\"></span>"
                    +json.variants[i].additionalFee[j].name+"</div>"
                    +"<div class=\"Warning-content\">"
                    +json.variants[i].additionalFee[j].description
                    +"</div></div>";
                }
                html+="</div>";
                var datalayerClass = " etn-data-layer-event ";

                if(showBasket=="1" && ecommerceEnabled){
                    datalayerAttributes += " data-dl_event_action='button_click'";
                    if(json.variants[i].inStock || json.variants[i].id=="0"){
                        datalayerAttributes+= " data-dl_event_label=\"<%=UIHelper.escapeCoteValue(libelle_msg(Etn, request, addToCartBtnLabel))%>\"";
                        html+="    <div tabindex=\"0\" "+(json.variants[i].id=="0"?" data-toggle='tooltip' data-placement='bottom' title='<%=UIHelper.escapeCoteValue(tooltipText)%> ' ":"")+" ><button type=\"button\" class=\"btn btn-primary pageStyle-btn-forfait "+(buyStatus=="logged"?"logged":"")+" "+(json.variants[i].is_default=="1"?"default-variant":"")+"\" "+(json.variants[i].id=="0"?"disabled style='pointer-events: none;' ":"")+" onclick=\"addToCart('"+json.variants[i].id+"','"+count+"')\" data-linkedvariant=\""
                            +json.variants[i].id+"\"><%=libelle_msg(Etn, request, addToCartBtnLabel)%>"
                            +"</button></div>";
                    }
                    else{
                        datalayerAttributes+= " data-dl_event_label=\"<%=UIHelper.escapeCoteValue(parseNull(rsshop.value(prefix + "stock_alert_button")))%>\"";
                        html+="<div class=\"TerminauxDetailsChoice-alertSubscription "+(json.variants[i].is_default=="1"?"default-variant":"")+"\" data-linkedvariant=\""+json.variants[i].id+"\""
                            +">"
                            +"<form>"
                            +"<div class=\"TerminauxDetailsChoice-alertSubscription-input form-group\">"
                            +"<label for=\"exampleInputEmail1\"><%=UIHelper.escapeCoteValue(libelle_msg(Etn, request, "Recevoir une alerte sur la disponibilité du produit par email"))%></label>"
                            +"<input type=\"email\" class=\"form-control\" id=\"exampleInputEmail1\" aria-describedby=\"emailHelp\">"
                            +"</div>"
                            +"<div class=\"TerminauxDetailsChoice-alertSubscription-success\">"
                            +"<div class=\"TerminauxDetailsChoice-alertSubscription-success-title\">"
                            +"<span data-svg=\""+contextPath+"/assets/icons/icon-check.svg\"></span>"
                            +"<%=UIHelper.escapeCoteValue(libelle_msg(Etn, request, "Votre demande a bien été prise en compte."))%>"
                            +"</div>"
                            +"<div class=\"TerminauxDetailsChoice-alertSubscription-success-content\">"
                            +"<%=parseNull(rsshop.value(prefix + "stock_alert_text"))%> : <span></span>"
                            +"</div>"
                            +"</div>"
                            +"<p class=\"TerminauxDetailsChoice-alertSubscription-info\">"
                            +"<%=UIHelper.escapeCoteValue(libelle_msg(Etn, request, "Vos coordonnées seront exclusivement utilisées dans le cadre du service « recevoir une alerte dés que le produit est disponible » et ne seront pas utilisées à d'autres fins."))%>"
                            +"</p>"
                            +"<input class=\"btn btn-primary TerminauxDetailsChoice-alertSubscription-submit "+datalayerClass+"\" "+datalayerAttributes+" type=\"submit\""
                            +"value=\"<%=parseNull(rsshop.value(prefix + "stock_alert_button"))%>\">"
                            +"</form>"
                            +"</div>";
                    }
                }
                else{
                    datalayerAttributes+=" data-dl_event_action='link_click'";
                    if(json.variants[i].actionButtonDesktop!="" && json.variants[i].actionButtonDesktopUrl!=""){
                        var openType = json.variants[i].actionButtonDesktopUrlOpentype;
                        var targetBlank = (openType === "new_tab" || openType === "new_window")?" target='_blank' ":"";
                        html+="  <div tabindex=\"0\" "+(json.variants[i].id=="0"?" data-toggle='tooltip' data-placement='bottom' title='<%=UIHelper.escapeCoteValue(tooltipText)%> ' ":"")
                            +"><a href=\""+(json.variants[i].id=="0"?"javascript:void(0)":$("#actionButtonDesktopUrl_"+json.variants[i].id).attr("href"))
                                +"\" class=\"action-btn-desktop btn btn-primary pageStyle-btn-forfait "
                                +datalayerClass+(json.variants[i].id=="0"?" disabled":"")
                                +(json.variants.is_default=="1"?" default-variant":"")+" d-none d-md-block\" "
                                +datalayerAttributes+"  data-dl_event_label=\""+json.variants[i].actionButtonDesktop+"\" data-linkedvariant=\""
                                +json.variants[i].id + "\" "
                                + targetBlank
                                + ((openType==="new_window")?" onclick='openNewWindow(event,this)' ":"")
                            +">"+json.variants[i].actionButtonDesktop
                            +"</a></div>";
                    }
                    if(json.variants[i].actionButtonMobile!="" && json.variants[i].actionButtonMobileUrl!=""){
                        var openType = json.variants[i].actionButtonMobileUrlOpentype;
                        var targetBlank = (openType === "new_tab" || openType === "new_window")?" target='_blank' ":"";
                        html+="    <div tabindex=\"0\" "+(json.variants[i].id=="0"?" data-toggle='tooltip' data-placement='bottom' title='<%=UIHelper.escapeCoteValue(tooltipText)%> ' ":"")
                            +"><a href=\""+(json.variants[i].id=="0"?"javascript:void(0)":$("#actionButtonMobileUrl_"+json.variants[i].id).attr("href"))
                            +"\" class=\"btn btn-primary pageStyle-btn-forfait "
                            +datalayerClass+(json.variants[i].id=="0"?" disabled":"")
                            +(json.variants.is_default=="1"?" default-variant":"")+" d-md-none\" "
                            +datalayerAttributes+" data-dl_event_label=\""+json.variants[i].actionButtonMobile+"\" data-linkedvariant=\""
                            +json.variants[i].id + "\" "
                            + targetBlank
                            + ((openType==="new_window")?" onclick='openNewWindow(event,this)' ":"")
                            +">"+json.variants[i].actionButtonMobile
                            +"</a></div>";
                    }
                }

                html+=discountCardHtml;

        }
        $("#variantHtmlContainer").html(html);
        $('[data-toggle="tooltip"]').tooltip();

        $(".selectableVariant").click(function()
        {
            $(".selectableVariantImage").removeClass("border-primary").addClass("border-light");
            $(this).find(".selectableVariantImage").addClass("border-primary").removeClass("border-light");
            selectedComewithVariant = $(this).data("variant_id");
            $(this).parent().parent().find(".text-muted").html($(this).data("variant_name"));
            $("#comewithImage_"+$(this).data("comewith_id")).attr("src",$(this).find(".selectableVariantImage").attr("src"));
        });

		$(".BlocAssociatedProductLightbox").on("hidden.bs.modal", function () {
			//there can be case when this modal was opened when user clicked on the addToCart
			//in that case if user makes selection and click confirm then we call addtocart function
			//otherwise if user closes the modal, then we have to reset these variables so that next time if user clicks
			//on comeswith box and modal opens then clicking on confirm does not call addtocart
			//these 2 global variables are used to know if we have to call addtocart on confirm
			addtocartid = "";
			addtocartincrement = "";

		});

    }

	function goBack()
	{
		var _ref = document.referrer;
		var _domain = document.domain;
		if(_ref.indexOf("//" + _domain) > -1)
		{
			history.go(-1);
		}
	}

    function openNewWindow(event, ele) {
        event.preventDefault(); //prevent <a> default click behavior
        var url = ele.href;

        if (window.innerWidth <= 640) {
            // if on mobile, open new tab not window
            // if width is smaller then 640px, create a temporary a elm that will open the link in new tab
            var a = document.createElement('a');
            a.setAttribute("href", url);
            a.setAttribute("target", "_blank");
            a.click();
        }
        else {
            var width = window.innerWidth * 0.66 ;
            var height = width * window.innerHeight / window.innerWidth ;
            // Ratio the hight to the width as the user screen ratio
            window.open(url , url, 'width=' + width + ', height=' + height
                + ', top=' + ((window.innerHeight - height) / 2)
                + ', left=' + ((window.innerWidth - width) / 2));
        }
        return false;
    }

</script>
</body>
</html>
