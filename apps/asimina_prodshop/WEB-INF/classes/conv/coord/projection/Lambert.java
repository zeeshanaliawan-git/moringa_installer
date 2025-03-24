package conv.coord.projection;

import conv.coord.outils.OutilConversion;

public final class Lambert {
	// ========== FONCTIONS GENERALES DE CONVERSION LAMBERT ======================
	//ALGO UTILISE: http://www.ign.fr/telechargement/MPro/geodesie/CIRCE/NTG_71.pdf
	//Avant de faire les conversions Lambert
	//Les variables suivantes doivent être initialiser par :
	//Variables_Projection_Lambert_tangent
	//ou Variables_Projection_Lambert_sécant
	//ou Variable_Projection_Lambert_1
	//ou Variable_Projection_Lambert_2
	//ou Variable_Projection_Lambert_2_Etendu
	//ou Variable_Projection_Lambert_3
	//ou Variable_Projection_Lambert_4
	//ou Variable_Projection_Lambert_93.
	//avec en paramètre lambda0, phi0, k0, X0, Y0
	//phi0 = latitude origine = 2°20'14,025'' par rapport au méridien Greenwich ou 0 grad au méridien Paris
	//k0 = facteur d'echelle a l'origine
	//lambda0 = longitude origine par rapport au méridien origine
	//X0 et Y0 coordonnée de projection du point d'origine
	protected static double DemiGrandAxe; //Demi-Grand Axe
	protected static double excEllip;	//premiere excentricité de l'ellipsoïde Clarke 1880 francais
	protected static double lambdaC;
	protected static double n;
	protected static double c;
	protected static double Xs;
	protected static double Ys;
	//La tolérance pour le calcul isometrique inverse en gauss laborde
	protected static double tolerance = 0.000000000001;
	
	//Les constantes LAMBERT
	protected static double const_DemiGrandAxe = 6378249.2; 
	protected static double const_excEllip = 0.08248325676;
	
	//Le meridien de greenwich
	protected static double Greenwich = OutilConversion.DegresToRadian(2.337229166666);
	
	//Les constantes d'initialisation pour les différents LAMBERT
	protected static double Lamb1_n = 0.7604059656;
	protected static double Lamb2_n = 0.7289686274;
	protected static double Lamb2E_n = 0.7289686274;
	protected static double Lamb3_n = 0.6959127966;
	protected static double Lamb4_n = 0.6712679322;
	protected static double Lamb93_n = 0.725607765;
	
	protected static double Lamb1_c = 11603796.98;
	protected static double Lamb2_c = 11745793.39;
	protected static double Lamb2E_c = 11745793.39;
	protected static double Lamb3_c = 11947992.52;
	protected static double Lamb4_c = 12136281.99;
	protected static double Lamb93_c = 11754255.426;
	
	protected static double Lamb1_Xs = 600000.;
	protected static double Lamb2_Xs = 600000.;
	protected static double Lamb2E_Xs = 600000.;
	protected static double Lamb3_Xs = 600000.;
	protected static double Lamb4_Xs = 234.358;
	protected static double Lamb93_Xs = 700000.;
	
	protected static double Lamb1_Ys = 5657616.674;
	protected static double Lamb2_Ys = 6199695.768;
	protected static double Lamb2E_Ys = 8199695.768;
	protected static double Lamb3_Ys = 6791905.085;
	protected static double Lamb4_Ys = 7239161.542;
	protected static double Lamb93_Ys = 12655612.05;
	
	//Définition des variables de projection dans le cas tangent (ALG0019)
	public static void Variables_Projection_Lambert_tangent(double a, double e, double lambda0, double phi0, double k0, double X0, double Y0,double la_tolerance){
		DemiGrandAxe = a;
		excEllip = e;
		lambdaC = lambda0;
		n = Math.sin(phi0);
		c = k0 * OutilConversion.Grande_Normale(phi0,DemiGrandAxe,excEllip) * (Math.cos(phi0) / Math.sin(phi0))  * Math.exp(n * OutilConversion.latitude_isometrique(phi0,excEllip));
		Xs = X0;
		Ys = Y0 + k0 * OutilConversion.Grande_Normale(phi0,DemiGrandAxe,excEllip) * (Math.cos(phi0) / Math.sin(phi0));
		tolerance = la_tolerance;
	}
	
	//Définition des variables de projection dans le cas sécant (ALG0054)
	public static void Variables_Projection_Lambert_sécant(double a, double e, double lambda0, double phi0, double phi1, double phi2, double X0, double Y0,double la_tolerance){
		DemiGrandAxe = a;
		excEllip = e;
		lambdaC = lambda0;
		double tmp1 =  (OutilConversion.Grande_Normale(phi2,DemiGrandAxe,excEllip) * Math.cos(phi2)) / (OutilConversion.Grande_Normale(phi1,DemiGrandAxe,excEllip) * Math.cos(phi1));
		n = Math.log(tmp1)/(OutilConversion.latitude_isometrique(phi1,excEllip) - OutilConversion.latitude_isometrique(phi2,excEllip));
		c = ((OutilConversion.Grande_Normale(phi1,DemiGrandAxe,excEllip) * Math.cos(phi1))/n) * Math.exp(n * OutilConversion.latitude_isometrique(phi1,excEllip));
		Xs = X0;
		Ys = Y0;
		
		if (Math.abs(phi0 - (Math.PI / 2)) > 0.00001)
		{	Ys = Y0 + c * Math.exp(-n * OutilConversion.latitude_isometrique(phi0,excEllip));	}
		tolerance = la_tolerance;
	}
	
	//Mise en place des constantes de projection Lambert 1
	public static void Variable_Projection_Lambert_1()
	{
		DemiGrandAxe = const_DemiGrandAxe;
		excEllip = const_excEllip;
		lambdaC = Greenwich;
		n = Lamb1_n;
		c = Lamb1_c;
		Xs = Lamb1_Xs;
		Ys = Lamb1_Ys;
	}
	
	//Mise en place des constantes de projection Lambert 2
	public static void Variable_Projection_Lambert_2()
	{
		DemiGrandAxe = const_DemiGrandAxe;
		excEllip = const_excEllip;
		lambdaC = Greenwich;
		n = Lamb2_n;
		c = Lamb2_c;
		Xs = Lamb2_Xs;
		Ys = Lamb2_Ys;
	}
	
	//Mise en place des constantes de projection Lambert 2 Etendu
	public static void Variable_Projection_Lambert_2_Etendu()
	{
		DemiGrandAxe = const_DemiGrandAxe;
		excEllip = const_excEllip;
		lambdaC = Greenwich;
		n = Lamb2E_n;
		c = Lamb2E_c;
		Xs = Lamb2E_Xs;
		Ys = Lamb2E_Ys;
	}
	
	//Mise en place des constantes de projection Lambert 3
	public static void Variable_Projection_Lambert_3()
	{
		DemiGrandAxe = const_DemiGrandAxe;
		excEllip = const_excEllip;
		lambdaC = Greenwich;
		n = Lamb3_n;
		c = Lamb3_c;
		Xs = Lamb3_Xs;
		Ys = Lamb3_Ys;
	}
	
	//Mise en place des constantes de projection Lambert 4
	public static void Variable_Projection_Lambert_4()
	{
		DemiGrandAxe = const_DemiGrandAxe;
		excEllip = const_excEllip;
		lambdaC = Greenwich; 
		n = Lamb4_n;
		c = Lamb4_c;
		Xs = Lamb4_Xs;
		Ys = Lamb4_Ys;
	}
	
	//Mise en place des constantes de projection Lambert -933
	public static void Variable_Projection_Lambert_93()
	{
		DemiGrandAxe = const_DemiGrandAxe;
		excEllip = const_excEllip;
		lambdaC = Greenwich; 
		n = Lamb93_n;
		c = Lamb93_c;
		Xs = Lamb93_Xs;
		Ys = Lamb93_Ys;
	}
	
	//Transformation coordonnées géographique en Lambert (ALG003)
	//Tout est calculé en radians
	public static double[] Geo_en_Lambert(double lambda, double phi) 
	{
		double Lat_iso = OutilConversion.latitude_isometrique(phi,excEllip);
		double X = Xs + c*Math.exp(-n*Lat_iso)*Math.sin(n*(lambda - lambdaC));
		double Y = Ys - c*Math.exp(-n*Lat_iso)*Math.cos(n*(lambda - lambdaC));
		
		double[] retour = {X,Y};
		return retour;
	}
	
	//Transformation Lambert en coordonnées géographique (ALG004)
	public static double[] Lambert_en_Geo(double X, double Y) 
	{
		double R = Math.sqrt(Math.pow(X - Xs,2) + Math.pow(Y - Ys,2));
		double Gamma = Math.atan((X - Xs)/(Ys - Y));
		double lambda = lambdaC + Gamma / n;
		double lat_iso = (-1 / n) * Math.log(Math.abs(R/c));
		double phi = OutilConversion.latitude_rad_depuis_isometrique(lat_iso,excEllip,tolerance);
		
		double[] retour = {lambda,phi};
		return retour;
	}
		
}
