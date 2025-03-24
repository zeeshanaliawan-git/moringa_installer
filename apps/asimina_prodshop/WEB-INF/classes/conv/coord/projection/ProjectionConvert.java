package conv.coord.projection;

import conv.coord.Coordonnee;
import conv.coord.outils.OutilConversion;

/**
 * Classe qui effectue des projections de coordonnées géographique
 * projections gérées: "LAMBERT2", "UTM", "WGS84"
 * @author Neil MASI
 */
public final class ProjectionConvert {

	//Constantes Ellipsoïde Hayford
	private static double Hayford_a = 6378388.00;
	private static double Hayford_e = 0.08199188998;
				
	//Constantes Ellipsoïde Iagrs reporté GPS WGS84 
	private static double WGS_a = 6378137;
	//La valeur f d origine Iagrs est 298.2572221010 
	private static double WGS_f = 298.257223563;
	private static double WGS_b = WGS_a - (WGS_a / WGS_f); 
	private static double WGS_e2 = (Math.pow(WGS_a,2) - Math.pow(WGS_b,2)) / Math.pow(WGS_a,2); 
	private static double WGS_e = Math.sqrt(WGS_e2);

	//==================== LES CONVERSIONS EMPLOYEES ========================
	
	/** Converti une Coordonnée LAMBERT2 en WGS84
	 * @param Lamb_EE le X de la coordonnée LAMBERT2 (en metres)
	 * @param Lamb_NN le Y de la coordonnée LAMBERT2 (en metres)
     * @return La Coordonne au format WGS84 (en degrés)
     */
	public static Coordonnee Lambert2_WGS84(double Lamb_EE, double Lamb_NN)
	throws Exception{
		
		//Initialisation de l'environnement Lambert2 Etendu
		Lambert.Variable_Projection_Lambert_2_Etendu();
		double geographique[] = Lambert.Lambert_en_Geo(Lamb_EE, Lamb_NN) ;
		
		//Passage en coordonnées cartésiennes pour la translation
		double[] cartesien = OutilConversion.Geo_en_Cartesien(geographique[0], geographique[1], Lambert.DemiGrandAxe, Lambert.excEllip, 0);
		
		//Translation lambert sur l ecliptique WGS84
		double x = cartesien[0] - 168;
		double y = cartesien[1] - 60;
		double z = cartesien[2] + 320;
		
		//Retour en coordonnées géographique
		double geographique2[] = OutilConversion.Cartesien_en_Geo(x,y,z,WGS_a,WGS_e,Lambert.tolerance);
		
		Coordonnee Result = new Coordonnee("WGS84",OutilConversion.RadianToDegres(geographique2[0]), OutilConversion.RadianToDegres(geographique2[1]));
		return Result;
	}
	
	/** Converti une Coordonnée Gauss Laborde en WGS84
	 * @param Gauss_X le X de la coordonnée WGS84 (en metres)
	 * @param Gauss_Y le Y de la coordonnée WGS84 (en metres)
     * @return La Coordonne au format WGS84 (en degrés)
     */
	public static Coordonnee GaussLaborde_WGS84(double Gauss_X, double Gauss_Y)
	throws Exception{
		
		//Initialisation de l'environnement GaussLaborde pour la Réunion
		GaussLaborde.Variable_Projection_GaussLaborde_Sphere_Courbure();
		//GaussLaborde.Variable_Projection_GaussLaborde_Sphere_Equatoriale();
		double geographique[] = GaussLaborde.GaussLaborde_en_Geo(Gauss_X, Gauss_Y);
		
		//Passage en cartésien pour la translation
		double[] cartesien = OutilConversion.Geo_en_Cartesien(geographique[0], geographique[1], Hayford_a, Hayford_e, 0);
		
		//Translation vers ecliptique hayford à WGS84
		double x = cartesien[0] - 168 + 84;
		double y = cartesien[1] - 60 - 37;
		double z = cartesien[2] + 320 - 437;
		
		//double[] testb = OutilConversion.Transforme_Coordonnees_Geodesique(789.524, -626.486, -89.904, -32.3241, ((0.6006*Math.PI)/(3600.*180.)), ((76.7946*Math.PI)/(3600.*180.)), ((-10.5788*Math.PI)/(3600.*180.)), cartesien[0], cartesien[1], cartesien[2]);
		
		//Retour en coordonnées géographiques
		double geographique2[] = OutilConversion.Cartesien_en_Geo(x,y,z, WGS_a, WGS_e,Mercator.tolerance);
		
		Coordonnee Result = new Coordonnee("WGS84",OutilConversion.RadianToDegres(geographique2[0]), OutilConversion.RadianToDegres(geographique2[1]));
		return Result;
	}
	
	public static Coordonnee WGS84_GaussLaborde(double longitude, double latitude)
	throws Exception{

		//Initialisation de l'environnement GaussLaborde pour la Réunion
		GaussLaborde.Variable_Projection_GaussLaborde_Sphere_Courbure();
		
		//Passage en cartésien pour la translation
		double[] cartesien = OutilConversion.Geo_en_Cartesien(OutilConversion.DegresToRadian(longitude), OutilConversion.DegresToRadian(latitude), WGS_a, WGS_e, 0);
		
		//Translation inverse depuis le WGS84 vers hayford
		double x = cartesien[0] + 168 - 84;
		double y = cartesien[1] + 60 + 37;
		double z = cartesien[2] - 320 + 437;
		
		//Retour en coordonnées géographique
		double geographique[] = OutilConversion.Cartesien_en_Geo(x,y,z,Hayford_a,Hayford_e,Mercator.tolerance);
				
		double[] geographique2 =GaussLaborde.Geo_en_GaussLaborde(geographique[0], geographique[1]);
		
		Coordonnee Result = new Coordonnee("GAUSS-LABORDE",geographique2[0], geographique2[1]);
		return Result;
		
	}
		
	/** Converti une Coordonnée LAMBERT2 en UTM
	 * @param Lamb_EE le X de la coordonnée LAMBERT2 (en metres)
	 * @param Lamb_NN le Y de la coordonnée LAMBERT2 (en metres)
     * @return La Coordonne au format UTM  (en degrés)
     */
	public static Coordonnee Lambert2_UTM(double Lamb_EE, double Lamb_NN)
	throws Exception{
		
		//Initialisation de l'environnement Lambert2 Etendu
		Lambert.Variable_Projection_Lambert_2_Etendu();
		double[] geographique = Lambert.Lambert_en_Geo(Lamb_EE, Lamb_NN);
		
		//Passage en coordonnées cartésiennes pour la translation
		double[] cartesien = OutilConversion.Geo_en_Cartesien(geographique[0], geographique[1], Lambert.DemiGrandAxe, Lambert.excEllip, 0);
		
		//Translation de lambert sur l'ecliptique Hayford
		double x = cartesien[0] - 84;
		double y = cartesien[1] + 37;
		double z = cartesien[2] + 437;
		
		//Retour en coordonnées géographique
		double geographique2[] = OutilConversion.Cartesien_en_Geo(x,y,z,Hayford_a,Hayford_e,Mercator.tolerance);
				
		//initialisation des variables de conversion pour la projection en UTM
		Mercator.Variables_Projection_UTM(Hayford_a, Hayford_e, geographique2[0], geographique2[1],Mercator.tolerance);		
		double[] utm =Mercator.Geo_en_Mercator_Transverse(geographique2[0], geographique2[1]);
		
		Coordonnee C_utm = new Coordonnee("UTM",Mercator.calc_Fuseau_UTM(geographique2[0]),Mercator.calc_Emisphere_UTM( geographique2[1]),utm[0],utm[1]);
		return C_utm;
	}
	
	/** Converti une Coordonnée WGS84 en Lambert2
	 * @param longitude la longitude de la coordonnée WGS84 (en degrés)
	 * @param latitude la latitude de la coordonnée WGS84 (en degrés)
     * @return La Coordonne au format Lambert2 (en metres)
     */
	public static Coordonnee WGS84_Lambert2(double longitude, double latitude)
	throws Exception{
		
		//Passage en cartésien pour la translation
		double[] cartesien = OutilConversion.Geo_en_Cartesien(OutilConversion.DegresToRadian(longitude), OutilConversion.DegresToRadian(latitude), WGS_a, WGS_e, 0);
		
		//Translation inverse depuis le WGS84 vers Lambert
		double x = cartesien[0] + 168;
		double y = cartesien[1] + 60;
		double z = cartesien[2] - 320;
		
		//Initialisation de l'environnement Lambert2 Etendu
		Lambert.Variable_Projection_Lambert_2_Etendu();
		
		//Retour en coordonnées géographiques
		double[] geographique = OutilConversion.Cartesien_en_Geo(x,y,z,Lambert.DemiGrandAxe,Lambert.excEllip,Lambert.tolerance);
		double[] result = Lambert.Geo_en_Lambert(geographique[0], geographique[1]);
		
		Coordonnee Result = new Coordonnee("LAMBERT2",result[0], result[1]);
		return Result;
	}
	
	/** Converti une Coordonnée WGS84 en UTM
	 * @param longitude la longitude de la coordonnée WGS84 (en degrés)
	 * @param latitude la latitude de la coordonnée WGS84 (en degrés)
     * @return La Coordonnée au format UTM (en metres)
     */
	public static Coordonnee WGS84_UTM(double longitude, double latitude)
	throws Exception{
		
		//Passage en cartésien pour la translation
		double[] cartesien = OutilConversion.Geo_en_Cartesien(OutilConversion.DegresToRadian(longitude), OutilConversion.DegresToRadian(latitude), WGS_a, WGS_e, 0);
		
		//Translation inverse depuis le WGS84 vers hayford
		double x = cartesien[0] + 168 - 84;
		double y = cartesien[1] + 60 + 37;
		double z = cartesien[2] - 320 + 437;
		
		//Retour en coordonnées géographique
		double geographique[] = OutilConversion.Cartesien_en_Geo(x,y,z,Hayford_a,Hayford_e,Mercator.tolerance);
				
		//initialisation des variables de conversion pour la projection en UTM
		Mercator.Variables_Projection_UTM(Hayford_a, Hayford_e, geographique[0], geographique[1],Mercator.tolerance);		
		double[] utm =Mercator.Geo_en_Mercator_Transverse(geographique[0], geographique[1]);
		
		Coordonnee C_utm = new Coordonnee("UTM",Mercator.calc_Fuseau_UTM(geographique[0]),Mercator.calc_Emisphere_UTM( geographique[1]),utm[0],utm[1]);
		return C_utm;
	}
		
	/** Converti une Coordonnée UTM en LAMBERT2
	 * @param Fuseau le fuseau de la coordonnée UTM
	 * @param Emisphere l'émisphère de la coordonnée UTM
	 * @param X le X de la coordonnée UTM (en metres)
	 * @param Y le Y de la coordonnée UTM (en metres)
     * @return La Coordonne au format LAMBERT2 (en metres)
     */
	public static Coordonnee UTM_Lambert2(int Fuseau, String Emisphere, double X, double Y)
	throws Exception{
		
		//Initialisation de l'environnement UTM
		Mercator.Variables_Projection_UTM(Hayford_a, Hayford_e, Fuseau, Emisphere,Mercator.tolerance);
		double[] geographique =Mercator.Mercator_Transverse_en_Geo(X, Y);
		
		//Passage en cartésien pour la translation
		double[] cartesien = OutilConversion.Geo_en_Cartesien(geographique[0], geographique[1], Hayford_a, Hayford_e, 0);
		
		//Translation de hayford sur l'eliptique lambert
		double x = cartesien[0] + 84;
		double y = cartesien[1] - 37;
		double z = cartesien[2] - 437;
		
		//Retour en coordonnées géographiques
		double geographique2[] = OutilConversion.Cartesien_en_Geo(x,y,z,Lambert.DemiGrandAxe,Lambert.excEllip,Lambert.tolerance);
		
		//Initialisation de l'environnement Lambert2 Etendu pour la projection en Lambert
		Lambert.Variable_Projection_Lambert_2_Etendu();
		double[] lambert = Lambert.Geo_en_Lambert(geographique2[0], geographique2[1]);
		
		Coordonnee Result = new Coordonnee("LAMBERT2",lambert[0], lambert[1]);
		return Result;
	}
	
	/** Converti une Coordonnée UTM en WGS84
	 * @param Fuseau le fuseau de la coordonnée UTM
	 * @param Emisphere l'émisphère de la coordonnée UTM
	 * @param X le X de la coordonnée UTM (en metres)
	 * @param Y le Y de la coordonnée UTM (en metres)
     * @return La Coordonne au format WGS84 (en degrés)
     */
	public static Coordonnee UTM_WGS84(int Fuseau, String Emisphere, double X, double Y)
	throws Exception{

		//Initialisation de l'environnement UTM
		Mercator.Variables_Projection_UTM(Hayford_a, Hayford_e, Fuseau, Emisphere,Mercator.tolerance);
		double[] geographique = Mercator.Mercator_Transverse_en_Geo(X, Y);
		
		//Passage en cartésien pour la translation
		double[] cartesien = OutilConversion.Geo_en_Cartesien(geographique[0], geographique[1], Hayford_a, Hayford_e, 0);
		
		//Translation vers ecliptique hayford à WGS84
		double x = cartesien[0] - 168 + 84;
		double y = cartesien[1] - 60 - 37;
		double z = cartesien[2] + 320 - 437;
		
		//Retour en coordonnées géographiques
		double geographique2[] = OutilConversion.Cartesien_en_Geo(x,y,z, WGS_a, WGS_e,Mercator.tolerance);
		
		Coordonnee Result = new Coordonnee("WGS84",OutilConversion.RadianToDegres(geographique2[0]), OutilConversion.RadianToDegres(geographique2[1]));
		return Result;
	}
	

		
}
