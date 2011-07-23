package aplicacion;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Date;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.Vector;

import javax.servlet.ServletContext;
public class PoolConexiones {
	
	//Atributos de conexion
	private String 
		manejadorConexion = null,
		nombreConexion = null,
		servidorConexion = null,
		baseDeDatosConexion = null,		
		usuarioConexion = null,
		constraseñaConexion = null,
		driverConexion = null;
	
	private int puertoConexion = 0,
		inicialConexion = 0,
		maxConexion = 0,
		checkedOut = 0;
			
	//Las conexiones disponibles
	private Vector<Connection> conexionesLibres = new Vector<Connection> ();
	
	/** Carga todos los drivers */
	private void cargarDriver() throws SQLException  {	        	              	    
		
		try {
			//Cargar el driver
			Class.forName(driverConexion);							
		} catch (ClassNotFoundException c) {
			throw new SQLException("No se pudo cargar la clase " + driverConexion);
		}   	        
	}
	
	public int conexionesCreadas() {
		return (conexionesLibres.size() + checkedOut);
	}
	
	/** */ 
	
	
	@SuppressWarnings("unchecked")
	public void preparar (ServletContext aplicacion) {
		
		Enumeration<String> parametros = aplicacion.getInitParameterNames();
		String parametro = null;
		while (parametros.hasMoreElements()) {
			parametro = parametros.nextElement();
			if (aplicacion.getInitParameter(parametro) != null) {
				if (parametro.equals("manejadorConexion"))
					setManejadorConexion(aplicacion.getInitParameter(parametro));
				if (parametro.equals("nombreConexion"))
					setNombreConexion(aplicacion.getInitParameter(parametro));
				if (parametro.equals("servidorConexion"))
					setServidorConexion(aplicacion.getInitParameter(parametro));
				if (parametro.equals("baseDeDatosConexion"))
					setBaseDeDatosConexion(aplicacion.getInitParameter(parametro));
				if (parametro.equals("usuarioConexion"))
					setUsuarioConexion(aplicacion.getInitParameter(parametro));
				if (parametro.equals("constraseñaConexion"))
					setConstraseñaConexion(aplicacion.getInitParameter(parametro));
				if (parametro.equals("driverConexion")) {
					setDriverConexion(aplicacion.getInitParameter(parametro));
				}
				if (parametro.equals("puertoConexion")) {
					try {
						setPuertoConexion(
							Integer.parseInt(aplicacion.getInitParameter(parametro))
						);							
					} catch (Exception e) {}
				}
				if (parametro.equals("inicialConexion")) {
					try {
						setInicialConexion(
							Integer.parseInt(aplicacion.getInitParameter(parametro))
						);							
					} catch (Exception e) {}
				}
				if (parametro.equals("maxConexion")) {
					try {
						setMaxConexion(
							Integer.parseInt(aplicacion.getInitParameter(parametro))
						);							
					} catch (Exception e) {
						
						e.printStackTrace();
						
					}
				}
			}
		}
		
		//Verificar que está preparada
		if (manejadorConexion == null
			|| nombreConexion == null 
			|| servidorConexion == null
			|| baseDeDatosConexion == null 
			|| usuarioConexion == null
			|| constraseñaConexion == null 
			|| puertoConexion <= 0 
			|| inicialConexion <= 0
			|| maxConexion <= 0) {
			
		} else {
			try {
				cargarDriver();				
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}		
		
	}
	
	public synchronized Connection obtenerConexion(long timeout) {
         long startTime = new Date().getTime();
         Connection con = null;
         while ((con = obtenerConexion()) == null) {
             try {
                 wait(timeout);
             }
             catch (InterruptedException e) {}
             if ((new Date().getTime() - startTime) >= timeout) {
                 // Timeout has expired
                 return null;
             }
         }
         return con;
     }
	
	/** El metodo que otorga la conexion **/ 
	private synchronized Connection obtenerConexion() {
		
		Connection con = null;
        if (conexionesLibres.size() > 0) {
            // Pick the first Connection in the Vector
            // to get round-robin usage
            con = (Connection) conexionesLibres.firstElement();
            conexionesLibres.removeElementAt(0);
            try {
                if (con.isClosed()) {                     
                    con = obtenerConexion();
                }
            }
            catch (SQLException e) {                 
                con = obtenerConexion();
            }
        }
        else if (maxConexion == 0 || checkedOut < maxConexion) {
            con = nuevaConexion();
        }
        if (con != null) {
            checkedOut++;
        }
        return con;	
	}
	
	/** Crea una conexion nueva */ 
	private Connection nuevaConexion() {
        Connection con = null;
        String URL = "jdbc:" + manejadorConexion + 
        	"://" + servidorConexion +":"+ puertoConexion +
        	"/" + baseDeDatosConexion;
        try {                     	  
             con = DriverManager.getConnection(URL, usuarioConexion, constraseñaConexion);
        } catch (SQLException e) { 
        	e.printStackTrace();
            return null;
        }
        return con;
    }
	
	public String getManejadorConexion() {
		return manejadorConexion;
	}

	public void setManejadorConexion(String manejadorConexion) {
		this.manejadorConexion = manejadorConexion;
	}

	/** Libera una conexion y la coloca en conexiones disponibles */
	public synchronized void liberarConexion(Connection con) {
		
         conexionesLibres.addElement(con);
         checkedOut--;
         notifyAll();
    }
	 	
	 /** Libera todas las conexiones utilizadas */
	public synchronized void liberarTodas() {
		Iterator<Connection> allConnections = conexionesLibres.iterator();
		while (allConnections.hasNext()) {
			Connection con = allConnections.next();
			try {				
				if (!con.isClosed()) {
					con.close();
				}
				con.close();
			} catch (SQLException e) {
			} finally {
				try {					
					con.close();					
				} catch (SQLException e) {				
				}
			}
		}
		conexionesLibres.removeAllElements();
	}
	 
	/** Crea tantas conexiones iniciales como le sea posible*/ 
	public synchronized void crearConexionesIniciales() {
		
		Connection con = null;
		for (int i = 0 ; i < inicialConexion ; i++) {
			con = nuevaConexion();
			if (con != null) {
				conexionesLibres.add(con);
			}
		}			
	}

	/*************************************** Setters y Getters ******************************************/

	/**
	 * @return the nombreConexion
	 */
	public String getNombreConexion() {
		return nombreConexion;
	}

	/**
	 * @param nombreConexion the nombreConexion to set
	 */
	public void setNombreConexion(String nombreConexion) {
		this.nombreConexion = nombreConexion;
	}

	/**
	 * @param servidorConexion the servidorConexion to set
	 */
	public void setServidorConexion(String servidorConexion) {
		this.servidorConexion = servidorConexion;
	}

	/**
	 * @param baseDeDatosConexion the baseDeDatosConexion to set
	 */
	public void setBaseDeDatosConexion(String baseDeDatosConexion) {
		this.baseDeDatosConexion = baseDeDatosConexion;
	}

	/**
	 * @param usuarioConexion the usuarioConexion to set
	 */
	public void setUsuarioConexion(String usuarioConexion) {
		this.usuarioConexion = usuarioConexion;
	}

	/**
	 * @param constraseñaConexion the constraseñaConexion to set
	 */
	public void setConstraseñaConexion(String constraseñaConexion) {
		this.constraseñaConexion = constraseñaConexion;
	}

	/**
	 * @param puertoConexion the puertoConexion to set
	 */
	public void setPuertoConexion(int puertoConexion) {
		this.puertoConexion = puertoConexion;
	}

	/**
	 * @param inicialConexion the inicialConexion to set
	 */
	public void setInicialConexion(int inicialConexion) {
		this.inicialConexion = inicialConexion;
	}

	/**
	 * @param maxConexion the maxConexion to set
	 */
	public void setMaxConexion(int maxConexion) {
		this.maxConexion = maxConexion;
	}
	
	/**
	 * @param driverConexion the driverConexion to set
	 */
	public void setDriverConexion(String driverConexion) {
		this.driverConexion = driverConexion;
	}	
}
