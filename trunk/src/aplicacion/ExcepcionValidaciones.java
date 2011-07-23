/**
 RolException.java - 07/04/2011
 Autor: Javier Pino
 */
package aplicacion;

import java.util.ArrayList;

/**
 * Descripción: Clase que representa una excepcion de validaciones
 * @author Javier Pino
 */
public class ExcepcionValidaciones extends Exception {

	private static final long serialVersionUID = 1414976852305514220L;
	ArrayList<String> validacionesIncumplidas = new ArrayList<String>();
	
	/** Constructor de excepción por validaciones incumplidas  */
	public ExcepcionValidaciones (ArrayList<String> validacionesIncumplidas) {		
		this.validacionesIncumplidas = validacionesIncumplidas;
	}

	/** Constructor de excepción por validaciones incumplidas  */
	public ExcepcionValidaciones (String validacionIncumplidas) {		
		this.validacionesIncumplidas.add(validacionIncumplidas);
	}
	
	/**
	 * @return validaciones incumplidas 
	 */
	public ArrayList<String> getValidacionesIncumplidas() {
		return validacionesIncumplidas;
	}	
	
}
