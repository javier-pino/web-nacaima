/**
 RolException.java - 07/04/2011
 Autor: Javier Pino
 */
package aplicacion;

/**
 * Descripci�n: Clase que representa una excepcion de ejecucion de roles
 * @author Javier Pino
 */
public class ExcepcionRoles extends Exception {

	private static final long serialVersionUID = -5387296513488836435L;

	/** Constructor de excepci�n */
	public ExcepcionRoles (String razon) {		
		super(razon);		
	}	
}
