/**
 ObjetoPersistente.java - 30/03/2011
 Autor: Javier Pino
 */
package beans;

import java.io.Serializable;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import aplicacion.ExcepcionValidaciones;

/**
 * Descripción: 
 * @author Javier Pino
 */
public abstract class ObjetoPersistente implements Serializable {
	
	private static final long serialVersionUID = 200311265883260868L;
	public static final int TINYTEXT = 255;
	public static final int TEXT = 65535;	
	
	//****	Métodos que deben heredar las clases hijas para mantener la consistencia del modelo 
	
	/**
	 * Este método valida las condiciones para la clase y retorna una lista con las condiciones 
	 * del modelo que no cumple
	 * */
	public abstract ArrayList<String> validarCondiciones();
				
	/** Metodo Factoria que permite recargar una instancia. Obteniendola de una fila de resultado de base de datos */
	public abstract void recargar (ResultSet rs) throws SQLException;
	
	/** Los hijos deben sobreescribir este método para su guardado 
	 * @throws ExcepcionValidaciones */
	public abstract void guardar(Connection con) throws SQLException, ExcepcionValidaciones ;
		
	/** Los hijos deben sobreescribir este metodos para su actualizacion 
	 * @throws ExcepcionValidaciones */
	public abstract void actualizar(Connection con)	throws SQLException, ExcepcionValidaciones ;
		
	/** Los hijos deben sobreescribir este metodos para su actualizacion */
	public boolean isIdentificado() {
		return (getID() > 0);
	}
	
	public abstract int getID();
	
	//**** Métodos que se pueden usar para guardar o actualizar un objeto persistente 
	
	/** Almacena en la base de datos un objeto persistente. Validandolo primero  
	 * @throws SQLException 
	 * @throws ExcepcionValidaciones */
	public final static void guardar(Connection con, ObjetoPersistente obj) 
		throws SQLException, ExcepcionValidaciones {			
		ObjetoPersistente.verificar(obj);
		obj.guardar(con);
	}
	
	/** Almacena en la base de datos un objeto persistente. Validandolo primero  
	 * @throws SQLException 
	 * @throws ExcepcionValidaciones */
	public final static void actualizar(Connection con, ObjetoPersistente obj) 
		throws SQLException, ExcepcionValidaciones {	
				
		ObjetoPersistente.verificar(obj);
		if (!obj.isIdentificado()) {
			throw new ExcepcionValidaciones("El objeto no está identificado en la base de datos");
		}
		obj.actualizar(con);
	}


	/** Método que debe ser usuados para verificar que las condiciones se cumplen */
	private static void verificar (ObjetoPersistente e) throws ExcepcionValidaciones {
		
		//Verificar que el objeto es almacenable
		ArrayList<String> res = new ArrayList<String>();					
		if (e == null)
			res.add("El objeto solicitado es nulo");
		else {
			res = e.validarCondiciones();
		}		
		if (res.size() > 0	)
			throw new ExcepcionValidaciones(res);		
	}
	
	/** Agiliza la descripcion de validaciones 
	 *  Mensaje de Error */
	public final String errorEsObligatorioModelo(String campo) {
		return "Error en el modelo: '" + campo + "' es Obligatorio"; 
	}
	
	/** Agiliza la descripcion de validaciones 
	 *  Mensaje de Error */	
	public final String errorEsObligatorio(String campo) {
		return "El campo '" + campo + "' es Obligatorio"; 
	}
	
	/** Agiliza la descripcion de validaciones 
	 * Mensaje de Error */
	public final String errorTamaño(String campo, int tamaño) {
		return "La longitud de '" + campo +	"' no puede exceder los " 
			+ tamaño + "caracteres";
	}
}