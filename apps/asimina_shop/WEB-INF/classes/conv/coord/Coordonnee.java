
package conv.coord;

import conv.coord.projection.ProjectionConvert;

/** 
 * Classe qui définit une coordonnée géographique défini principalement par
 * sa projection: "LAMBERT2", "UTM", "WGS84"
 * sa longitude et sa latitude
 * @author Neil MASI
 */
public class Coordonnee {
   //Projections disponibles: "LAMBERT2", "UTM", "WGS84", "GAUSS-LABORDE"
   private String _projection;

   private double _longitude, _latitude;

   //Version Degres, minutes, secondes
   private String _signe_longitude, _signe_latitude; // (W ou E, et N ou S)
   private int _degres_longitude, _degres_latitude;
   private int _minutes_longitude, _minutes_latitude;
   private double _secondes_longitude, _secondes_latitude;

   //UTM
   private int _Fuseau;
   private String _Emisphere; // "N" ou "S"
      
   /** Constructeur de Coordonnée pour les projections "WGS84", "LAMBERT2" et "GAUSS-LABORDE" uniquement
    * @param projection Définit la projection de la coordonnée = "WGS84" ou "LAMBERT2" ou "GAUSS-LABORDE" sinon renvoie une exception
    * @param longitude la longitude en degrés de la coordonnée (équivaut au X en mètres pour le système LAMBERT2 ou GAUSS-LABORDE)
    * @param latitude la latitude en degrés de la coordonnée (équivaut au Y en mètres pour le système LAMBERT2 ou GAUSS-LABORDE)
    */
   public Coordonnee(String projection, double longitude, double latitude) 
   throws Exception{
	   
	   if (!(projection.equalsIgnoreCase("WGS84") || projection.equalsIgnoreCase("LAMBERT2") || projection.equalsIgnoreCase("GAUSS-LABORDE")))
		   throw new Exception(CoordonneeBundle.getString("exception.Creation_longitude-latitude"));
	   
	   this._projection = projection.toUpperCase();
	   this._longitude = longitude;
	   this._latitude = latitude;
	   if (projection.equalsIgnoreCase("WGS84"))
	   {
		   this._signe_longitude = longitude_to_signe(longitude);
		   this._degres_longitude = longitude_to_degres(longitude);
		   this._minutes_longitude = longitude_to_minutes(longitude);
		   this._secondes_longitude = longitude_to_secondes(longitude);
		   this._signe_latitude = latitude_to_signe(latitude);
		   this._degres_latitude = latitude_to_degres(latitude);
		   this._minutes_latitude = latitude_to_minutes(latitude);
		   this._secondes_latitude = latitude_to_secondes(latitude);
	   }
   }
   
   /** Constructeur de Coordonnée pour les projections "WGS84" uniquement
    * Tous les paramètres doivent être renseignés
    * @param projection Définit la projection de la coordonnée = "WGS84" sinon renvoie une exception
    * @param signe_longitude "W" ou "E" pour Ouest ou Est
    * @param degres_longitude la valeur degrés de la longitude
    * @param minutes_longitude la valeur minutes de la longitude
    * @param secondes_longitude la valeur secondes de la longitude
    * @param signe_latitude "N" ou "S" pour Nord ou Sud
    * @param degres_latitude la valeur degrés de la longitude
    * @param minutes_latitude la valeur minutes de la longitude
    * @param secondes_latitude la valeur secondes de la longitude
    */
   public Coordonnee(String projection, String signe_longitude, int degres_longitude, int minutes_longitude, double secondes_longitude, String signe_latitude, int degres_latitude, int minutes_latitude, double secondes_latitude) 
   throws Exception{
	   
	   if (!projection.equalsIgnoreCase("WGS84"))
		   throw new Exception(CoordonneeBundle.getString("exception.Creation_degres_lon-lat"));
	   if (!(signe_longitude.toUpperCase().matches("[WE]")))
		   throw new Exception(CoordonneeBundle.getString("exception.Creation_degres_lon-lat_Signe_Long"));
	   if (!(signe_latitude.toUpperCase().matches("[NS]")))
		   throw new Exception(CoordonneeBundle.getString("exception.Creation_degres_lon-lat_Signe_Lat"));
	   
	   this._projection = projection.toUpperCase();
	   this._signe_longitude = signe_longitude.toUpperCase();
	   this._degres_longitude = degres_longitude;
	   this._minutes_longitude = minutes_longitude;
	   this._secondes_longitude = secondes_longitude;
	   this._signe_latitude = signe_latitude.toUpperCase();
	   this._degres_latitude = degres_latitude;
	   this._minutes_latitude = minutes_latitude;
	   this._secondes_latitude = secondes_latitude;
	   this._longitude = degres_to_longitude(signe_longitude, degres_longitude, minutes_longitude, secondes_longitude);
	   this._latitude = degres_to_latitude(signe_latitude, degres_latitude, minutes_latitude, secondes_latitude);
   }
   
   /** Constructeur de Coordonnée pour la projection "UTM"
    * Tous les paramètres doivent être renseignés
    * @param projection doit être = "UTM"
    * @param Fuseau le numéro de fuseau (de 1 à 60)
    * @param Emisphere "N" ou "S" pour Nord ou Sud
    * @param X la position X en metres dans le fuseau
    * @param Y la position Y en metres dans le fuseau
    */
   public Coordonnee(String projection, int Fuseau, String Emisphere, double X, double Y)
   throws Exception{
	   
	   if (!projection.equalsIgnoreCase("UTM"))
		   throw new Exception(CoordonneeBundle.getString("exception.Creation_UTM"));
	   if (Fuseau < 1 || Fuseau > 60)
		   throw new Exception(CoordonneeBundle.getString("exception.Creation_UTM_Fuseau"));
	   if (!(Emisphere.toUpperCase().matches("[NS]")))
		   throw new Exception(CoordonneeBundle.getString("exception.Creation_UTM_Emisphere"));
	   
	   this._projection = projection.toUpperCase();
	   this._Fuseau = Fuseau;
	   this._Emisphere = Emisphere.toUpperCase();
	   this._longitude = X;
	   this._latitude = Y;
   }
      
   //Les get
   public double get_longitude(){return _longitude;}
   public double get_latitude(){return _latitude;}
   public double get_X(){return _longitude;}
   public double get_Y(){return _latitude;}
   public String get_signe_longitude(){return _signe_longitude;}
   public String get_signe_latitude(){return _signe_latitude;}
   public int get_degres_longitude(){return _degres_longitude;}
   public int get_degres_latitude(){return _degres_latitude;}
   public int get_minutes_longitude(){return _minutes_longitude;}
   public int get_minutes_latitude(){return _minutes_latitude;}
   public double get_secondes_longitude(){return _secondes_longitude;}
   public double get_secondes_latitude(){return _secondes_latitude;}
   public String get_projection(){return _projection;}
   public int get_Fuseau(){return _Fuseau;}
   public String get_Emisphere(){return _Emisphere;}

   
   //Récupération sous différentes formes de coordonnées
   /** Retourne la Coordonnee dans la projection LAMBERT2 (en metres)
    */
   public Coordonnee get_Coord_in_Lambert2()
   throws Exception{
	   
	   if (_projection.equalsIgnoreCase("LAMBERT2"))
		   return new Coordonnee("LAMBERT2",_longitude,_latitude);
	   
	   if (_projection.equalsIgnoreCase("UTM"))
		   return ProjectionConvert.UTM_Lambert2(_Fuseau, _Emisphere, _longitude, _latitude);
	   else if (_projection.equalsIgnoreCase("WGS84"))
		   return ProjectionConvert.WGS84_Lambert2(_longitude, _latitude);
	   else if (_projection.equalsIgnoreCase("GAUSS-LABORDE")) {
		   Coordonnee test1 = ProjectionConvert.GaussLaborde_WGS84(_longitude, _latitude);
		   return ProjectionConvert.WGS84_Lambert2(test1.get_longitude(), test1.get_latitude());
	   }
		   
	   
	   throw new Exception(CoordonneeBundle.getString("exception.Projection_Inconnue"));
   }
   
   /** Retourne la Coordonnee dans la projection WGS84 (en degres)
    */
   public Coordonnee get_Coord_in_WGS84()
   throws Exception{
	   if (_projection.equalsIgnoreCase("WGS84"))
		   return new Coordonnee("WGS84",_longitude,_latitude);
	   
	   if (_projection.equalsIgnoreCase("UTM"))
		   return ProjectionConvert.UTM_WGS84(_Fuseau, _Emisphere, _longitude, _latitude);
	   else if (_projection.equalsIgnoreCase("LAMBERT2"))
		   return ProjectionConvert.Lambert2_WGS84(_longitude, _latitude);
	   else if (_projection.equalsIgnoreCase("GAUSS-LABORDE"))
		   return ProjectionConvert.GaussLaborde_WGS84(_longitude, _latitude);
		   
	   throw new Exception(CoordonneeBundle.getString("exception.Projection_Inconnue"));
   }
   
    
   /** Retourne la Coordonnee dans la projection UTM (en degres)
    */
   public Coordonnee get_Coord_in_UTM()
   throws Exception{
	   
	   if (_projection.equalsIgnoreCase("UTM"))
		   return new Coordonnee("UTM",_Fuseau, _Emisphere, _longitude, _latitude);
	  
	   if (_projection.equalsIgnoreCase("WGS84"))
		   return ProjectionConvert.WGS84_UTM(_longitude, _latitude);
	   else if (_projection.equalsIgnoreCase("LAMBERT2"))
		   return ProjectionConvert.Lambert2_UTM(_longitude, _latitude);
	   else if (_projection.equalsIgnoreCase("GAUSS-LABORDE")) {
		   Coordonnee test1 = ProjectionConvert.GaussLaborde_WGS84(_longitude, _latitude);
		   return ProjectionConvert.WGS84_UTM(test1.get_longitude(), test1.get_latitude());
	   }
		   
	   throw new Exception(CoordonneeBundle.getString("exception.Projection_Inconnue"));
   }
   
   /** Retourne la Coordonnee dans la projection Gauss Laborde (en degres)
    */
   public Coordonnee get_Coord_in_GaussLaborde()
   throws Exception{
	   //TODO
	   if (_projection.equalsIgnoreCase("GAUSS-LABORDE"))
		   return new Coordonnee("GAUSS-LABORDE",_longitude,_latitude);
	   
	   if (_projection.equalsIgnoreCase("WGS84"))
		   return ProjectionConvert.WGS84_GaussLaborde(_longitude, _latitude);
	   else if (_projection.equalsIgnoreCase("LAMBERT2")){
		   Coordonnee test1=ProjectionConvert.Lambert2_WGS84(_longitude, _latitude);
		  return ProjectionConvert.WGS84_GaussLaborde(test1.get_longitude(), test1.get_latitude());
	   }
	   else if (_projection.equalsIgnoreCase("UTM")) {
		   Coordonnee test1 = ProjectionConvert.UTM_WGS84(_Fuseau, _Emisphere, _longitude, _latitude);
		   return ProjectionConvert.WGS84_UTM(test1.get_longitude(), test1.get_latitude());
	   }
	   
	   throw new Exception(CoordonneeBundle.getString("exception.Convertion_GaussLaborde_Impossible"));
   }
   
   /** Calcul de la valeur de longitude d'après les degrés
    * @param signe_longitude doit être = "E" ou "W"
    * @param degres_longitude le degres de la longitude
    * @param minutes_longitude les minutes de la longitude
    * @param secondes_longitude les secondes de la longitude
    * @return un double représentant la longitude
    */
   public double degres_to_longitude(String signe_longitude, int degres_longitude, int minutes_longitude, double secondes_longitude)
   {
	   double result = (double)degres_longitude + ((double)minutes_longitude / (double)60) + (secondes_longitude / (double)3600);
	   //E positif, W négatif
	   if ( signe_longitude.toUpperCase().equalsIgnoreCase("W")) result = result * -1;
	   return result;
   }

   /** Calcul de la valeur de latitude d'après les degrés
    * @param signe_latitude doit être = "N" ou "S"
    * @param degres_latitude le degres de la latitude
    * @param minutes_latitude les minutes de la latitude
    * @param secondes_latitude les secondes de la latitude
    * @return un double représentant la latitude
    */
   public double degres_to_latitude(String signe_latitude, int degres_latitude, int minutes_latitude, double secondes_latitude)
   {
	   double result = degres_latitude + (minutes_latitude / (double)60) + (secondes_latitude / (double)3600);
	   //N positif, S négatif
	   if ( signe_latitude.toUpperCase().equalsIgnoreCase("S")) result = result * -1;
	   return result;
   }
   
   /** Retourne le signe de la longitude
    * @param longitude la longitude en degres dont on veut obtenir le signe
    * @return le signe de la longitude: "E" ou "W" 
    */
   public String longitude_to_signe(double longitude)
   {   if (longitude>=0) return "E";
	   else return "W";
   }
   
   /** Retourne le signe de la latitude
    * @param latitude la latitude en degres dont on veut obtenir le signe
    * @return le signe de la latitude: "N" ou "S" 
    */
   public String latitude_to_signe(double latitude)
   {   if (latitude>=0) return "N";
	   else return "S";
   }
   
   /** Retourne la valeur degres d'une longitude
    * @param longitude la longitude en degres dont on veut obtenir les degres
    * @return les degres de la longitude 
    */
   public int longitude_to_degres(double longitude)
   {   return (int)Math.floor(Math.abs(longitude));}
   
   /** Retourne la valeur minutes d'une longitude
    * @param longitude la longitude en degres dont on veut obtenir les minutes
    * @return les degres de la longitude 
    */
   public int longitude_to_minutes(double longitude)
   {	return (int) Math.floor((Math.abs(longitude) - longitude_to_degres(longitude)) * 60);}
   
   /** Retourne la valeur secondes d'une longitude
    * @param longitude la longitude en degres dont on veut obtenir les secondes
    * @return les secondes de la longitude 
    */
   public double longitude_to_secondes(double longitude)
   {	double result = Math.abs(longitude) - longitude_to_degres(longitude) - ((double)longitude_to_minutes(longitude) / (double)60);
		return result * 3600;}
   
   //Pour la latitude c'est les meme conversions que pour la longitude
   /** Retourne la valeur degres d'une latitude
    * @param latitude la latitude en degres dont on veut obtenir le degres
    * @return le degres de la latitude 
    */
   public int latitude_to_degres(double latitude)
   {   return longitude_to_degres(latitude);  }
   
   /** Retourne la valeur minutes d'une latitude
    * @param latitude la latitude en degres dont on veut obtenir les minutes
    * @return les degres de la latitude 
    */
   public int latitude_to_minutes(double latitude)
   {   return longitude_to_minutes(latitude);  }
   
   /** Retourne la valeur secondes d'une latitude
    * @param latitude la latitude en degres dont on veut obtenir les secondes
    * @return les secondes de la latitude 
    */
   public double latitude_to_secondes(double latitude)
   {   return longitude_to_secondes(latitude);  }
   
   /** Retourne une représentation en String de la latitude de la coordonnée
    * @return la réprésentation de la latitude sous forme [NS]Degres°Minutes'Secondes'' 
    */
   public String Coordonnee_latitude()
   {
	   String result="";
	   String N_S_Lat;
	   //Tranformation Degrés décimaux Latitude arrivée en degré minute seconde avec reconnaissance N S 
	   if (_latitude > 0) N_S_Lat = "N"; 
	   else N_S_Lat = "S"; 
	    
	   double Lat_Dec = Math.abs(_latitude); 
	   int Deg_Lat = (int) Math.floor(Lat_Dec); 
	   int Min_Lat = (int) Math.floor((Lat_Dec - Deg_Lat) * 60); 
	   double Sec_Lat1 = (double)Min_Lat / (double)60;
	   double Sec_Lat2 = Lat_Dec - (double)Deg_Lat - Sec_Lat1;
	   double Sec_Lat3 = Math.round((Sec_Lat2 * 3600)*1000);
	   double Sec_Lat = Sec_Lat3/1000;
	   
	   result = N_S_Lat + String.valueOf(Deg_Lat) + "°" + String.valueOf(Min_Lat) + "'" + String.valueOf(Sec_Lat) + "''";
	   return result;
   }
   
   /** Retourne une représentation en String de la longitude de la coordonnée
    * @return la réprésentation de la latitude sous forme [EW]Degres°Minutes'Secondes'' 
    */
   public String Coordonnee_longitude()
   {
	   String result="";
	   String E_W_Long;
	   //Tranformation Degrés décimaux Longitude arrivée en degré minute seconde avec reconnaissance E W 
	   if (_longitude > 0) E_W_Long = "E"; 
	   else E_W_Long = "W"; 
	   
	   double Long_Dec = Math.abs(_longitude); 
	   int Deg_Long = (int)Math.abs(Math.floor(Long_Dec)); 
	   int Min_Long = (int)Math.floor((Long_Dec - Deg_Long) * 60); 
	   double Sec_Long1 = (double)Min_Long / (double)60;
	   double Sec_Long2 = Long_Dec - (double)Deg_Long - Sec_Long1;
	   double Sec_Long3 = Math.round((Sec_Long2*3600)*1000);
	   double Sec_Long = Sec_Long3/1000;
	   
	   result = E_W_Long + String.valueOf(Deg_Long) + "°" + String.valueOf(Min_Long) + "'" + String.valueOf(Sec_Long) + "''"; 
	   return result;
   }
   

};

