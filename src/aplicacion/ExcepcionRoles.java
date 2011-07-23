/**
 RolException.java - 07/04/2011
 Autor: Javier Pino
 */
package aplicacion;

/**
 * Descripción: Clase que representa una excepcion de ejecucion de roles
 * @author Javier Pino
 */
public class ExcepcionRoles extends Exception {

	private static final long serialVersionUID = -5387296513488836435L;

	/** Constructor de excepción */
	public ExcepcionRoles (String razon) {		
		super(razon);		
	}	
}
