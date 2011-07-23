/**
	TIPO-VIVIENDA.java - 04/04/2011
	Autor: Javier Pino
*/
package enums;

/**
 * Descripción: Describe los distintos tipos de nacionalidad
 * @author Javier Pino
 */
public enum NACIONALIDAD {

	/** Venezolana */
	V,
	/** Extranjera */
	E,
	;
	
	/** Formatea el enum actual para mostrarlo*/
	public static String mostrar(NACIONALIDAD nac) {
		
		String resultado  = "";
		if (nac != null) {
			switch (nac) {
			case V:
				resultado = "Venezolana";
				break;
			case E:
				resultado = "Extranjera";
				break;		
			}
		}		
		return resultado;
	}
}
