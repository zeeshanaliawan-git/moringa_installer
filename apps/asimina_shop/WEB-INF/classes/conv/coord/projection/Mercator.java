package conv.coord.projection;

import conv.coord.outils.Complex;
import conv.coord.outils.OutilConversion;

public final class Mercator {
//	========== FONCTIONS GENERALES DE CONVERSION MERCATOR ======================
	//ALGO UTILISE: http://www.ign.fr/telechargement/MPro/geodesie/CIRCE/NTG_76.pdf
	//Les variables de calcul
	protected static double[] Coeff_Arc_Meridien;
	protected static double[] Coeff_Transverse_Direct;
	protected static double[] Coeff_Transverse_Inverse;
	protected static double DemiGrandAxe; //Demi-Grand Axe
	protected static double excEllip;	//premiere excentricité de l'ellipsoïde Clarke 1880 francais
	protected static double lambdaC;
	protected static double n;
	protected static double Xs;
	protected static double Ys;
	protected static double tolerance = 0.000000000001;
	
	
	//Calcul variables pour calculs mercator (ALG0025)
	public static void Coeff_Arc_Meridien_Mercator(double e)
	{
		Coeff_Arc_Meridien = new double[5];
		Coeff_Arc_Meridien[0] = 1 - (1./4.)*Math.pow(e, 2) - (3./64.)*Math.pow(e, 4) - (5./256.)*Math.pow(e, 6) - (175./16384.)*Math.pow(e, 8);
		Coeff_Arc_Meridien[1] = 0 - (3./8.)*Math.pow(e, 2) - (3./32.)*Math.pow(e, 4) - (45./1024.)*Math.pow(e, 6) - (105./4096.)*Math.pow(e, 8);
		Coeff_Arc_Meridien[2] = (15./256.)*Math.pow(e, 4) + (45./1024.)*Math.pow(e, 6) + (525./16384.)*Math.pow(e, 8);
		Coeff_Arc_Meridien[3] = 0 - (35./3072.)*Math.pow(e, 6) - (175./12288.)*Math.pow(e, 8);
		Coeff_Arc_Meridien[4] = (315./131072.)*Math.pow(e, 8);
	}
	
	//Developpement de l'arc méridien (ALG0026)
	public static double Developpement_Arc_Meridien_Mercator(double phi)
	{
		double BetaEtoile = Coeff_Arc_Meridien[0] * phi;
		for (int k=1; k<5; k++)
			BetaEtoile += Coeff_Arc_Meridien[k] * Math.sin(2*k*phi);
		return BetaEtoile;
	}
	
	//Calcul variables pour calculs mercator (ALG0028)
	public static void Coeff_Direct_Mercator_Transverse(double e)
	{
		Coeff_Transverse_Direct = new double[5];
		Coeff_Transverse_Direct[0] = 1 - (1./4.)*Math.pow(e, 2) - (3./64.)*Math.pow(e, 4) - (5./256.)*Math.pow(e, 6) - (175./16384.)*Math.pow(e, 8);
		Coeff_Transverse_Direct[1] = (1./8.)*Math.pow(e, 2) - (1./96.)*Math.pow(e, 4) - (9./1024.)*Math.pow(e, 6) - (901./184320.)*Math.pow(e, 8);
		Coeff_Transverse_Direct[2] = (13./768.)*Math.pow(e, 4) + (17./5120.)*Math.pow(e, 6) - (311./737280.)*Math.pow(e, 8);
		Coeff_Transverse_Direct[3] = (61./15360.)*Math.pow(e, 6) + (899./430080.)*Math.pow(e, 8);
		Coeff_Transverse_Direct[4] = (49561./41287680.)*Math.pow(e, 8);
	}
	
	//Calcul variables pour calculs mercator (ALG0029)
	public static void Coeff_Inverse_Mercator_Transverse(double e)
	{
		Coeff_Transverse_Inverse = new double[5];
		Coeff_Transverse_Inverse[0] = 1 - (1./4.)*Math.pow(e, 2) - (3./64.)*Math.pow(e, 4) - (5./256.)*Math.pow(e, 6) - (175./16384.)*Math.pow(e, 8);
		Coeff_Transverse_Inverse[1] = (1./8.)*Math.pow(e, 2) + (1./48.)*Math.pow(e, 4) + (7./2048.)*Math.pow(e, 6) + (1./61440.)*Math.pow(e, 8);
		Coeff_Transverse_Inverse[2] = (1./768.)*Math.pow(e, 4) + (3./1280.)*Math.pow(e, 6) + (559./368640.)*Math.pow(e, 8);
		Coeff_Transverse_Inverse[3] = (17./30720.)*Math.pow(e, 6) + (283./430080.)*Math.pow(e, 8);
		Coeff_Transverse_Inverse[4] = (4397./41287680.)*Math.pow(e, 8);
	}
	
	//Détermination des paramètres de calcul pour projection Mercator (ALG0052)
	public static void Variables_Projection_Mercator_Transverse (double a, double e, double k0, double lambda0, double phi0,double X0, double Y0, double la_tolerance)
	{
		DemiGrandAxe = a;
		excEllip = e;
		lambdaC = lambda0;
		n = k0 * DemiGrandAxe;
		Xs = X0;
		Coeff_Arc_Meridien_Mercator(excEllip);
		Ys = Y0 - n * Developpement_Arc_Meridien_Mercator(phi0);
		tolerance = la_tolerance;
	}
	
	//Détermination des paramètres de calcul pour projection UTM a partir d'un fuseau et émisphère
	public static void Variables_Projection_UTM (double a, double e, int fuseau, String emisphere, double la_tolerance)
	{
		Coeff_Direct_Mercator_Transverse(e);
		Coeff_Inverse_Mercator_Transverse(e);
		DemiGrandAxe = a;
		excEllip = e;
		lambdaC = OutilConversion.DegresToRadian(6 * fuseau - 183);
		n = 0.9996 * DemiGrandAxe;
		Xs = 500000;
		if(emisphere.equalsIgnoreCase("N"))
			Ys = 0;
		else			
			Ys = 10000000;
		tolerance = la_tolerance;
	}

	//Détermination des paramètres de calcul pour projection UTM a partir d'une longitude et latitude
	public static void Variables_Projection_UTM (double a, double e, double longitude, double latitude, double tolerance)
	{	Variables_Projection_UTM (a, e, calc_Fuseau_UTM(longitude), calc_Emisphere_UTM(latitude), tolerance);
	}

	public static int calc_Fuseau_UTM(double longitude_rad)
	{	return (int) Math.floor((OutilConversion.RadianToDegres(longitude_rad) + 186) / 6.);
	}
		
	public static String calc_Emisphere_UTM(double latitude_rad)
	{	if(OutilConversion.RadianToDegres(latitude_rad) >= 0)	return "N";
		return "S";
	}
	
	//Transformation coordonnée géographique en mercator transverse (ALG0030)
	public static double[] Geo_en_Mercator_Transverse(double lambda, double phi)
	{	
		double lat_iso = OutilConversion.latitude_isometrique(phi, excEllip);
		double PHI = Math.asin(Math.sin(lambda - lambdaC)/Math.cosh(lat_iso));
		double lat_isoS = OutilConversion.latitude_isometrique(PHI, 0);
		double LAMBDA = Math.atan(Math.sinh(lat_iso) / Math.cos(lambda - lambdaC));
		
		//Attention calcul de complexes z avec partie réelle = LAMBDA, partie imaginaire lat_isoS
		//Nombre complexe intermédiaire z = (LAMBDA + i * lat_isoS)
		// Z = n * C [0] * z + n * somme C[k] * sin(2*k*x) 
		Complex z = new Complex(LAMBDA, lat_isoS);
		Complex Z = z.times(Coeff_Transverse_Direct[0]).times(n);
		for (int k=1; k < 5; k++)
			Z = Z.plus( z.times(2 * k).sin().times(n * Coeff_Transverse_Direct[k]));
				
		double X = Z.im() + Xs;
		double Y = Z.re() + Ys;
				
		double[] retour = {X,Y};
		return retour;
	}
	
	//Transformation mercator transverse en coordonnée géographique (ALG0031)
	public static double[] Mercator_Transverse_en_Geo(double X, double Y)
	{	//Attention calcul de complexes z avec partie réelle = (Y - Ys) / (n * C[0]), partie imaginaire (X - Xs) / (n * C[0])
		Complex zprime = new Complex((Y - Ys) / (n * Coeff_Transverse_Inverse[0]), (X - Xs) / (n * Coeff_Transverse_Inverse[0]));

		Complex z = zprime;
		for (int k=1; k < 5; k++)
			z = z.minus(zprime.times(2 * k).sin().times(Coeff_Transverse_Inverse[k]));
		
		double lat_iso = z.re();
		double lat_isoS = z.im();
		
		double lambda = lambdaC + Math.atan(Math.sinh(lat_isoS)/Math.cos(lat_iso));
		double PHI = Math.asin(Math.sin(lat_iso) / Math.cosh(lat_isoS));
		lat_iso =  OutilConversion.latitude_isometrique(PHI, 0);
		double phi = OutilConversion.latitude_rad_depuis_isometrique(lat_iso,excEllip,tolerance);
		
		double[] retour = {lambda,phi};
		return retour;
	}
}
