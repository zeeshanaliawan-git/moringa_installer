package conv.coord.projection;

import conv.coord.outils.OutilConversion;

public final class GaussLaborde {
	// =============== FONCTIONS GENERALES DE GAUSS - LABORDE ===============================
	// ALGO UTILISE: http://www.ign.fr/telechargement/MPro/geodesie/CIRCE/NTG_73.pdf
	//Avant de faire les conversions Gauss-Laborde
	//Les variables suivantes doivent être initialiser par :
	//Variables_Projection_GaussLaborde_Sphere_Courbure()
	//ou Variables_Projection_GaussLaborde_Sphere_Equatoriale()
	//ou Variables_Projection_GaussLaborde_Sphere_Bitangente()
	//avec en paramètre lambda0, phi0, k0, X0, Y0
	protected static double DemiGrandAxe; //Demi-Grand Axe
	protected static double excEllip;		//premiere excentricité de l'ellipsoïde
	protected static double excEllip2;		//premiere excentricité de l'ellipsoïde au carré
	protected static double lambdaC;
	protected static double n1;
	protected static double phiC;
	protected static double c;
	protected static double n2;
	protected static double Xs;
	protected static double Ys;
	//La tolérance pour le calcul isometrique inverse en gauss laborde
	public static double tolerance = 0.000000000001;
	
	
	//Constantes d'initialisation
	protected static double const_DemiGrandAxe=6378388.0; 
	protected static double const_excEllip=0.08199188998;
	
	//En projection par sphère de courbure
	protected static double const_lambda0_courb=0.96923951127;
	protected static double const_phi0_courb=-0.36855536038;
	protected static double const_k0_courb=1.0;
	protected static double const_X0_courb=160000.0;
	protected static double const_Y0_courb=50000.0;
	
	//En projection par sphère équatoriale
	protected static double const_lambda0_equa=-0.92502450356;
	protected static double const_phi0_equa=0.0;
	protected static double const_k0_equa=0.999;
	protected static double const_X0_equa=300000.0;
	protected static double const_Y0_equa=0.0;
	
	protected static double const_tolerance = 0.000000000001;
	
	
	//Mise en place des constantes de projection par spère de courbure
	public static void Variable_Projection_GaussLaborde_Sphere_Courbure()
	{
		Variables_Projection_GaussLaborde_Sphere_Courbure(const_DemiGrandAxe, 
														const_excEllip, 
														const_lambda0_courb, 
														const_phi0_courb,
														const_k0_courb,
														const_X0_courb,
														const_Y0_courb,
														const_tolerance);
	}
	
	//Mise en place des constantes de projection par spère équatoriale
	public static void Variable_Projection_GaussLaborde_Sphere_Equatoriale()
	{
		Variables_Projection_GaussLaborde_Sphere_Equatoriale(const_DemiGrandAxe, 
														const_excEllip, 
														const_lambda0_equa, 
														const_phi0_equa,
														const_k0_equa,
														const_X0_equa,
														const_Y0_equa,
														const_tolerance);
	}
	
	//Définition des variables de projection dans le cas de la spère de courbure (ALG0046)
	public static void Variables_Projection_GaussLaborde_Sphere_Courbure(double a, double e, double lambda0, double phi0, double k0, double X0, double Y0,double la_tolerance){
		DemiGrandAxe = a;
		excEllip = e;
		excEllip2 = Math.pow(excEllip, 2);
		lambdaC = lambda0;
		n1 = Math.sqrt(1 + (excEllip2/(1-excEllip2)) * Math.pow(Math.cos(phi0),4 ));
		phiC = Math.asin(Math.sin(phi0)/n1);
		c = OutilConversion.latitude_isometrique(phiC,0) - n1 * OutilConversion.latitude_isometrique(phi0,e);
		n2 = k0 * DemiGrandAxe * ((Math.sqrt(1 - excEllip2))/(1 - excEllip2 * Math.pow(Math.sin(phi0), 2)));
		Xs = X0;
		Ys = Y0 - n2 * phiC;
		tolerance = la_tolerance;
	}
	
	//Définition des variables de projection dans le cas de la spère de équatoriale (ALG0046)
	public static void Variables_Projection_GaussLaborde_Sphere_Equatoriale(double a, double e,double lambda0, double phi0, double k0, double X0, double Y0, double la_tolerance){
		DemiGrandAxe = a;
		excEllip = e;
		excEllip2 = Math.pow(excEllip, 2);
		lambdaC = lambda0;
		n1 = 1;
		phiC = OutilConversion.latitude_rad_depuis_isometrique(OutilConversion.latitude_isometrique(phi0,e),0,tolerance);
		c = 0;
		n2 = k0 * (DemiGrandAxe / Math.sqrt(1 - excEllip2 * Math.pow(Math.sin(phi0), 2))) * (Math.cos(phi0)/Math.cos(phiC));
		Xs = X0;
		Ys = Y0;
		tolerance = la_tolerance;
	}
	
	//Définition des variables de projection dans le cas de la spère bitangente (ALG0046)
	public static void Variables_Projection_GaussLaborde_Sphere_Bitangente(double a, double e, double lambda0, double phi0, double k0, double X0, double Y0,double la_tolerance){
		DemiGrandAxe = a;
		excEllip = e;
		excEllip2 = Math.pow(excEllip, 2);
		lambdaC = lambda0;
		n1 = 1;
		phiC = phi0;
		c = OutilConversion.latitude_isometrique(phiC,0) - n1 * OutilConversion.latitude_isometrique(phi0,e);
		n2 = k0 * DemiGrandAxe  * (1 / Math.sqrt(1 - excEllip2 * Math.pow(Math.sin(phi0), 2)));
		Xs = X0;
		Ys = Y0;
		tolerance = la_tolerance;
	}
	
	//Coordonnes géographique en Gauss-Laborde (ALG0034)
	//Tout est calculé en radian
	public static double[] Geo_en_GaussLaborde(double lambda, double phi) 
	throws Exception{
		double LAMBDA = n1 * (lambda - lambdaC);
		double lat_iso = c + n1  * OutilConversion.latitude_isometrique(phi,excEllip);
	
		double X = Xs + n2 * OutilConversion.latitude_isometrique(Math.asin(Math.sin(LAMBDA)/ Math.cosh(lat_iso)),0);
		double Y = Ys + n2 * Math.atan(Math.sinh(lat_iso)/Math.cos(LAMBDA));
		
		double[] retour = {X,Y};
		return retour;
	}
	
	//Gauss-Laborde en Coordonnes géographique (ALG0035)
	//Tout est calculé en radian
	public static double[] GaussLaborde_en_Geo(double X, double Y) 
	throws Exception{
		
		double LAMBDA = Math.atan((Math.sinh((X-Xs)/n2))/(Math.cos((Y-Ys)/n2)));
		double lat_iso = OutilConversion.latitude_isometrique(Math.asin((Math.sin((Y-Ys)/n2))/(Math.cosh((X-Xs)/n2))),0);
		
		double lambda = lambdaC + (LAMBDA / n1);
		double phi = OutilConversion.latitude_rad_depuis_isometrique((lat_iso - c)/n1,excEllip,tolerance);		
				
		double[] retour = {lambda,phi};
		return retour;
	}
	
}
