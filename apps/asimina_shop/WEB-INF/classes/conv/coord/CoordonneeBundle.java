package conv.coord;

import java.util.MissingResourceException;
import java.util.ResourceBundle;

/** 
 * Classe qui permet de récupérer les messages d'erreur
 * provenants du fichier error.properties
 * @author Neil MASI
 */
public class CoordonneeBundle {

	private static final String BUNDLE_NAME = "conv.coord.error";

	private static final ResourceBundle RESOURCE_BUNDLE = ResourceBundle.getBundle(BUNDLE_NAME);

	private CoordonneeBundle() {
	}

	/**
	 * Permet de récupérer les messages d'erreur
	 * provenants du fichier error.properties
	 * @param key la clé du message désiré présent dans error.properties
	 * @return Le message correspondant. Si n'existe pas, alors retourne !key!
	 */
	public static String getString(String key) {
		try {
			return RESOURCE_BUNDLE.getString(key);
		} catch (MissingResourceException e) {
			return '!' + key + '!';
		}
	}

}
