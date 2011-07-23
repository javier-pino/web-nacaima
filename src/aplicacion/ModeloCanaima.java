/**
 ModeloVisitante.java - 05/04/2011
 Autor: Javier Pino
 */
package aplicacion;

import java.io.Serializable;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Connection;
import java.util.ArrayList;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpSessionBindingEvent;
import javax.servlet.http.HttpSessionBindingListener;

import beans.Contrato;
import beans.Donatario;
import beans.DonatarioContrato;
import beans.ObjetoPersistente;
import beans.Usuario;

/**
 * Descripción: Clase que almacena los métodos de visitante 
 * @author Javier Pino
 */  
public class ModeloCanaima implements Serializable, HttpSessionBindingListener {

	private static final long serialVersionUID = 9185150137525148591L;
	
	//************************** Métodos de Binding/Unbinding de sesiones 
	
	/**
	 * Se debe verificar si este modelo es agregado a una sesión, entonces debería iniciar la conexion.
	 * Inicia la aplicacion, garantiza la conexion y configura las variables de sistema
	 *  
	 *	@see javax.servlet.http.HttpSessionBindingListener#valueBound(javax.servlet.http.HttpSessionBindingEvent)
	 *  @param arg0
	 */	
	@Override
	public void valueBound(HttpSessionBindingEvent arg0) {
		
		//Crear un usuario por defecto
		setUsuarioNulo();
		
		//Aplicación actual de la sesión
		ServletContext application = arg0.getSession().getServletContext();
		
		//Se debe iniciar la conexion con una nueva instancia		
		setPoolConexiones(Conexion.getInstance(application));
		
		//Inicializar con los parametros
		configurarAplicacion(application);
		
	}

	/**
	 * Si este modelo es liberado de una sesión, pues debe liberar las conexiones  
	 * 
	 *	@see javax.servlet.http.HttpSessionBindingListener#valueUnbound(javax.servlet.http.HttpSessionBindingEvent)
	 *  @param arg0
	 */	
	@Override
	public void valueUnbound(HttpSessionBindingEvent arg0) {
		
		//Finalizar 
		if (getPoolConexiones() != null)
			getPoolConexiones().finalizar();
	} 

	/** Se deben tomar en cuenta los parámetros de inicializacion que corresponden al negocio, max lotes y max contratos */ 
	public void configurarAplicacion (ServletContext application) {
		
		MAX_CONTRATOS_X_LOTE = 
			Integer.parseInt(application.getInitParameter("maxContratosXLote").trim());
		MAX_LOTES_X_CAJA = 
			Integer.parseInt(application.getInitParameter("maxLotesXCaja").trim());
		DIRECTORIO_TEMPORAL = 
			application.getInitParameter("directorioTemporal");		
		DIRECTORIO_GUARDADO =  
			application.getInitParameter("directorioGuardado");
	}
	
	//**************** Párametros y Métodos de la aplicación 
	
		/** Cuanto dura la sesión */
	protected static final int TIMEOUT = 5000; 	
		/** Pool de Conexiones que utiliza el sistema */
	protected transient Conexion poolConexiones = null;			
	protected Usuario usuarioActual = null;
	
	/** Método que se encarga de crear los visitantes */
	public void setUsuarioNulo () {		
		usuarioActual = null;
	} 
	
	/** Guarda un objeto persistente en la base de datos creando la conexion 
	 * y usando sus metodos para validar y actualizar */
	public void guardar(ObjetoPersistente obj) throws ExcepcionRoles, SQLException, ExcepcionValidaciones {
			
		//Crear los objetos
		Connection con = null;
	
		//Crear la conexion y si hubo error rla
		con = getPoolConexiones().obtenerConexion(TIMEOUT);
		if (!Conexion.esValida(con)) {
			getPoolConexiones().cerrarConexion(con);
			throw new SQLException("No se ha iniciado conexion");
		}		
		try {			
			ObjetoPersistente.guardar(con, obj);
			if (obj.isIdentificado()) {
				buscarPorID(obj.getID(), obj);
			} else 
				throw new ExcepcionValidaciones("No se insertó el objeto deseado");
		} finally {
			getPoolConexiones().cerrarConexion(con, null, null);
		}	
	}
	
	/** Actualiza un objeto persistente en la base de datos creando la conexion y usando 
	 * sus metodos para validar y actualizar*/
	public void actualizar(ObjetoPersistente obj) throws ExcepcionRoles, SQLException, ExcepcionValidaciones {
			
		//Crear los objetos
		Connection con = null;
		
		//Crear la conexion y si hubo error cerrarla
		con = getPoolConexiones().obtenerConexion(TIMEOUT);
		if (!Conexion.esValida(con)) {
			getPoolConexiones().cerrarConexion(con);
			throw new SQLException("No se ha iniciado conexion");
		}		
		try {			
			ObjetoPersistente.actualizar(con, obj);
		} finally {
			getPoolConexiones().cerrarConexion(con, null, null);
		}	
	}
	
	/** Busca un objeto persistente desde la base de datos dado un id */
	public void buscarPorID(int id, ObjetoPersistente obj) throws SQLException {
			
		if (id == 0) {
			return ;
		}		
					
		//Crear los objetos
		Connection con = null;
		PreparedStatement ps = null;
		ResultSet rs = null;
			
		//Crear la conexion y si hubo error cerrarla
		con = getPoolConexiones().obtenerConexion(TIMEOUT);
		if (!Conexion.esValida(con)) {
			getPoolConexiones().cerrarConexion(con, ps, rs);
			throw new SQLException("No se ha iniciado conexion");
		}			
		//Realizar la busqueda
		try {
			String sql = "select * from `canaima`.`" +
				obj.getClass().getSimpleName().toLowerCase() 
				+ "` where id" + obj.getClass().getSimpleName().toLowerCase()
				+ " = ? ";			
			ps = con.prepareStatement(sql);
			ps.setInt(1, id);		
			rs = ps.executeQuery();
			if (rs.next()) {
				obj.recargar(rs);					
			} else return;
		} finally {
			getPoolConexiones().cerrarConexion(con, ps, rs);;
		}		
	}
	
	/** Busca un objeto persistente desde la base de datos dado un id 
	 * @throws ExcepcionValidaciones */
	public void eliminarPorID(ObjetoPersistente obj) throws SQLException, ExcepcionValidaciones {
			
		if (obj == null)
			throw new ExcepcionValidaciones("Error en el Modelo: El objeto es nulo");
		if (!obj.isIdentificado()) {
			throw new ExcepcionValidaciones("Error en el Modelo: El objeto es nulo");
		}		
			
		//Crear los objetos
		Connection con = null;
		PreparedStatement ps = null;		
			
		//Crear la conexion y si hubo error cerrarla
		con = getPoolConexiones().obtenerConexion(TIMEOUT);
		if (!Conexion.esValida(con)) {
			getPoolConexiones().cerrarConexion(con, ps, null);
			throw new SQLException("No se ha iniciado conexion");
		}			
		//Realizar la busqueda
		try {
			String sql = "delete from `canaima`.`" + obj.getClass().getSimpleName().toLowerCase() 
				+ "` where id" + obj.getClass().getSimpleName().toLowerCase() + " = ? ";
			ps = con.prepareStatement(sql);
			ps.setInt(1, obj.getID());		
			ps.executeUpdate();			
		} finally {
			getPoolConexiones().cerrarConexion(con, ps, null);
		}		
	}
		
	public int MAX_LOTES_X_CAJA, MAX_CONTRATOS_X_LOTE;
	public String DIRECTORIO_TEMPORAL, DIRECTORIO_GUARDADO;
	
	/*** Verifica si se puede hacer login */
	public Usuario iniciarSesion(String login, String contrasena) throws SQLException {
		
		//Crear los objetos
		Connection con = null;
		PreparedStatement ps = null;
		ResultSet rs = null;	
		
		//Crear la conexion y si hubo error cerrarla
		con = getPoolConexiones().obtenerConexion(TIMEOUT);
		if (!Conexion.esValida(con)) {
			getPoolConexiones().cerrarConexion(con, ps, rs);
			throw new SQLException("No se ha iniciado conexion");
		}
		
		//Usarla
		try {
			
			/*Date finalPrueba = Utilidades.nuevaFecha(MAXDIA, MAXMES, MAXAÑO);
			Calendar inicialCal = Calendar.getInstance(), 
			finalCal = Calendar.getInstance();
			finalCal.setTime(finalPrueba);			
			if (inicialCal.compareTo(finalCal) >= 0 ) {
				return null;
			}*/			
			String sql_login = "select * from `canaima`.`usuario` where `usuario` = ? and `contrasena` = ?";
			ps = con.prepareStatement(sql_login );	
			ps.setString(1, login );
			ps.setString(2, 
					// Utilidades.encriptarContraseña( //TODO Poner de nuevo en produccion
					contrasena);
			rs = ps.executeQuery();			
			if (rs.next()) {
				Usuario retornado = new Usuario();
				retornado.recargar(rs);
				return retornado;
			}			
			return null;			
		} finally {
			getPoolConexiones().cerrarConexion(con, ps, rs);
		}
	}
	
	//********************  Los getters y setters  	
	/**
	 * @return the poolConexiones
	 */
	public Conexion getPoolConexiones() {
		return poolConexiones;
	}
	
	/**
	 * @param poolConexiones el poolConexiones a modificar
	 */
	public void setPoolConexiones(Conexion poolConexiones) {
		this.poolConexiones = poolConexiones;
	}
	
	public Usuario getUsuarioActual() {
		return usuarioActual;
	}

	public void setUsuarioActual(Usuario usuarioActual) {
		this.usuarioActual = usuarioActual;
	}
		
	/** Solicita una conexion al modelo de su pool de conexiones 
	 * @throws SQLException */
	public Connection solicitarConexion () throws SQLException {
		Connection con = null;		
		//Crear la conexion y si hubo error cerrarla
		con = getPoolConexiones().obtenerConexion(TIMEOUT);
		if (!Conexion.esValida(con)) {
			getPoolConexiones().cerrarConexion(con);
			throw new SQLException("No se ha iniciado conexion");
		}
		return con;
	}
		
	/**
	<td class = "largo">&Uacute;ltimo Donatario Registrado</td>									
	<td class = "largo">&Uacute;ltimo Contrato Registrado</td>
	<td class = "largo"></td>
	<td class = "largo">Lote Actual</td>
	<td class = "largo">#Contratos en Lote</td>
	<td class = "largo">M&aacute;ximo</td>
	<td class = "largo"></td>
	<td class = "largo">Caja Actual</td>
	<td class = "largo">#Lotes en Caja</td>
	<td class = "largo">M&aacute;ximo</td>
	*/
	
	public static final int TAM_RECIENTES = 20;
	private final ArrayList<Donatario> recientes = new ArrayList<Donatario>();
	private Donatario ultimo = new Donatario();
	
	/** Agregar Donatario a la lista de recientes */	
	public void agregarDonatario (Donatario reciente) {
		if (recientes.size() > TAM_RECIENTES)
			recientes.remove(0);
		recientes.add(reciente);
		ultimo = reciente;
	}

	public Donatario getUltimo() {
		return ultimo;
	}

	public void setUltimo(Donatario ultimo) {
		this.ultimo = ultimo;
	}

	public ArrayList<Donatario> getRecientes() {
		return recientes;
	}
	
	/** Retorna 
	 * @throws SQLException */
	public DonatarioContrato buscarDonatarioContrato (int donatario, int numero) throws SQLException {
		
		int idcontrato = 0, iddonatario = 0;
		
		//Buscar por numero de contrato
		PreparedStatement ps = null;
		ResultSet rs = null;
			
		//Crear la conexion y si hubo error cerrarla
		Connection con = getPoolConexiones().obtenerConexion(TIMEOUT);
		if (!Conexion.esValida(con)) {
			getPoolConexiones().cerrarConexion(con, ps, rs);
			throw new SQLException("No se ha iniciado conexion");
		}			
		//Realizar la busqueda
		try {
			String sql = " select d.iddonatario, d.idcontrato from donatario d left join contrato c on (d.idcontrato = c.idcontrato) where d.activo and d.idcontrato > 0 " ;			
			if (donatario > 0)
				sql += " and d.iddonatario = ?";
			if (numero > 0)
				sql += " and c.numero = ? ";	
			ps = con.prepareStatement(sql);
			int p= 1;
			if (donatario > 0)
				ps.setInt(p++, donatario);
			if (numero > 0)
				ps.setInt(p++, numero);			
			rs = ps.executeQuery();
			if (rs.next()) {
				iddonatario = rs.getInt(1);
				idcontrato = rs.getInt(2);			
			}			
			Donatario donat = new Donatario();
			Contrato contrato = new Contrato();
			DonatarioContrato doncon = new DonatarioContrato();
			
			//Buscar el donatario
			if (iddonatario > 0) {
				buscarPorID(iddonatario, donat);				
				doncon.setDonatario(donat);
			}
			//Buscar el contrato
			if (idcontrato > 0) {
				buscarPorID(idcontrato, contrato);
				doncon.setContrato(contrato);
			}							
			return doncon;			
		} finally {
			getPoolConexiones().cerrarConexion(con, ps, rs);;
		}
	}	
	
	private String archivoTemporal;

	public String getArchivoTemporal() {
		return archivoTemporal;
	}

	public void setArchivoTemporal(String archivoTemporal) {
		this.archivoTemporal = archivoTemporal;
	} 
}