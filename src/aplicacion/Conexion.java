package aplicacion;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletContext;

public class Conexion {
		
	private static Conexion singleton = null;
	private PoolConexiones conexiones = new PoolConexiones();
	private static int clientes = 0;
		
	/** Constructor vacio privado */
	private Conexion () {
		
	}
	
	/** Constructor de Conexion Privado */
	private Conexion (ServletContext aplicacion) {
        try {
			iniciar(aplicacion);
		} catch (SQLException e) { 
			e.printStackTrace();
		}
    }

	/** Crea una instancia de conexion */
	public static synchronized Conexion getInstance(ServletContext app) {
        if (singleton == null) {
            singleton = new Conexion(app);
        }
        clientes++;
        return singleton;
    }
	
	/** Cierra el pool de conexiones después de usarla */
	public synchronized void finalizar() {
		clientes--;
	}
	
	/** Crea la fuente de datos de donde se obtendran las conexiones 
	 * @throws SQLException */
	public void iniciar ( ServletContext aplicacion ) throws SQLException {
		conexiones.preparar(aplicacion);				
	}
	
	/** Cierra una conexion solicitada al pool y en orden el result set  y prepared statement*/
	public void cerrarConexion(Connection con, PreparedStatement ps, ResultSet rs) {
		
		//Cerrar el resultset
		if (rs != null) {
			try {
				rs.close();			
			} catch (Exception e) {}
		}		
		//Cerrar el preparedstatement
		if (ps != null) {
			try {
				ps.close();				
			} catch (Exception e) {}
		}		
        // Liberar la conexion 
        conexiones.liberarConexion(con);        
	}
	
	/** Cierra una conexion solicitada al pool y en orden el result set  y prepared statement*/
	public void cerrarConexion(Connection con) {	
        // Liberar la conexion 
        conexiones.liberarConexion(con);        
	}

	/** Indica que la conexion es utilizable */
	public static boolean esValida (Connection con) {
		
		if (con != null) {
			try {
				if (!con.isClosed()) {
					return true;
				}
			} catch (SQLException e) {				
			}
		}		
		return false;
	}
		
	/** Obtiene una conexion del pool  */
	public Connection obtenerConexion(long timeout) {        
        if (conexiones != null) {
            return conexiones.obtenerConexion(timeout);
        }
        return null;
    }
	
	/** Libera todas las conexiones, si ya no hay clientes conectados*/
	public synchronized void liberarConexiones () {
		
		//Solo hay un pool, liberarlo
		conexiones.liberarTodas();
	}

	public int numeroClientes() {
		return clientes;
	}
	
	public int numeroConexiones() {
		return conexiones.conexionesCreadas();
	}
}
