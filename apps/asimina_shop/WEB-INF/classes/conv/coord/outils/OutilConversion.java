package conv.coord.outils;

public final class OutilConversion {
	//========== FONCTIONS GENERALES DE CONVERSION  =========================

	//Conversion de degres en radians
	public static double DegresToRadian(double val)
	{	return Math.PI * (val / 180.); }
	
	//Conversion de radians en degres
	public static double RadianToDegres(double val)
	{	return 180 * (val / Math.PI); }
	
	//Calcul latitude isometrique (ALG0001)
	public static double latitude_isometrique(double phi, double e){
		 return Math.log((Math.tan((Math.PI/4) + (phi/2))) * (Math.pow((1 - (e * Math.sin(phi)))/(1 + (e * Math.sin(phi))), e / 2)));
	}

	//Calcul latitude isometrique inverse (ALG0002)
	public static double latitude_rad_depuis_isometrique(double lat_iso, double e, double tolerance){
		 double ecart = 1; 
		 double Phi = 2 * Math.atan(Math.exp(lat_iso)) - (Math.PI / 2);
		 while (ecart > tolerance) 
			{ 	double Phi_1 = 2 * Math.atan((Math.pow((1 + e * Math.sin(Phi))/(1 - e * Math.sin(Phi)), (e / 2))) * Math.exp(lat_iso)) - (Math.PI / 2) ; 
				ecart = Math.abs(Phi - Phi_1); 
				Phi = Phi_1;} 
		 return Phi;
	}
	
	//Calcul de la grande Normale (ALG0021)
	public static double Grande_Normale(double phi, double a, double e)
	{  return a / Math.sqrt(1 - Math.pow(e, 2) * Math.pow(Math.sin(phi),2));}
	
	//ALGO UTILISE: http://www.ign.fr/telechargement/MPro/geodesie/CIRCE/NTG_80.pdf
	//Transformation de coordonnée Géographique en cartésiennes (ALG0009)
	public static double[] Geo_en_Cartesien(double lambda, double phi, double a, double e, double he)
	{
		double N = Grande_Normale(phi,a,e);
		double X = (N + he) * Math.cos(phi) * Math.cos(lambda);
		double Y = (N + he) * Math.cos(phi) * Math.sin(lambda);
		double Z = (N * (1 - Math.pow(e,2) + he)) * Math.sin(phi);
		
		double[] retour = {X,Y,Z};
		return retour;
	}
	
	//Transformation de coordonnée cartésiennes en Géographique (ALG0012)
	public static double[] Cartesien_en_Geo(double X, double Y, double Z, double a, double e, double tolerance)
	{
		
		double e2 = Math.pow(e,2);
		double sqrtX2Y2 = Math.sqrt(Math.pow(X,2)+Math.pow(Y, 2));
		
		double lambda = Math.atan(Y/X);
		double phi0 = Math.atan(Z / (sqrtX2Y2 * (1  - (a * e2) / Math.sqrt(Math.pow(X,2)+Math.pow(Y, 2)+Math.pow(Z, 2)))));
		
		double ecart = 1;
		double phi = phi0;
		while (ecart > tolerance)
		{
			double phi_1 = Math.atan( (Z + (a * e2 * Math.sin(phi)) / Math.sqrt(1 - e2 * Math.pow(Math.sin(phi), 2))) / sqrtX2Y2 );
			ecart = Math.abs(phi - phi_1); 
			phi = phi_1;
		}

		double he = ( sqrtX2Y2 / Math.cos(phi) ) - ( a / Math.sqrt(1 - e2 * Math.pow(Math.sin(phi), 2)));
		
		double[] retour = {lambda,phi,he};
		return retour;
		
	}
	
	//Transformation de coordonnée shérique en cartésiennes (ALG0015)
	public static double[] Sperique_en_Cartesien(double LAMBDA, double PHI)
	{
		double U1 = Math.cos(PHI) * Math.cos(LAMBDA);
		double U2 = Math.cos(PHI) * Math.sin(LAMBDA);
		double U3 = Math.sin(PHI);
		
		double[] retour = {U1,U2,U3};
		return retour;
	}
	
	//Transformation de coordonnée cartésiennes en shérique (ALG0016)
	public static double[] Sperique_en_Cartesien(double V1, double V2, double V3)
	{
		double p = Math.sqrt(Math.pow(V1, 2) + Math.pow(V2, 2));
		double LAMBDA;
		double PHI;
		
		if (p != 0)
		{	LAMBDA = 2 * Math.atan(V2 / (V1+p));
			PHI = Math.atan(V3/p);
		}
		else
		{	LAMBDA = 0;
			PHI = Math.PI / 2;
			if (V3 < 0) PHI = - PHI; 
		}
		
		double[] retour = {LAMBDA,PHI};
		return retour;
	}
	
	//Transformation de coordonnées à 7 paramètres entre deux systèmes geodosiques (ALG0063)
	//http://www.ign.fr/telechargement/MPro/geodesie/CIRCE/alg0063.pdf
	public static double[] Transforme_Coordonnees_Geodesique(double Tx, double Ty,double Tz,double D,double Rx, double Ry,double Rz,double Vx, double Vy, double Vz){
		
		Vx = Vx - Tx;
		Vy = Vy - Ty;
		Vz = Vz - Tz;
		double e = 1 + D;
		double det = e * (Math.pow(e, 2) + Math.pow(Rx, 2) + Math.pow(Ry, 2) + Math.pow(Rz, 2));
		
		double Ux = ( (Math.pow(e,2) + Math.pow(Rx,2))*Vx  + (e*Rz + Rx*Ry)*Vy + (Rx*Rz - e*Ry)*Vz ) / det;
		double Uy = ( ((0-e)*Rz + Rx*Ry)*Vx + (Math.pow(e, 2)+ Math.pow(Ry, 2))*Vy + (e*Rx + Ry*Rz)*Vz ) / det;
		double Uz = ( ( e*Ry + Rx*Rz)*Vx + ((0-e)*Rx + Ry*Rz)*Vy + (Math.pow(e, 2)+ Math.pow(Rz, 2))*Vz) / det;
		
		double[] retour = {Ux,Uy,Uz};
		return retour;
	}
	

}
