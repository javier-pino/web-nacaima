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

import joins.DonatarioContrato;
import beans.Contrato;
import beans.Donatario;
import beans.Docente;
import beans.ObjetoPersistente;
import beans.Usuario;

/**
 * Descripci�n: Clase que almacena los m�todos de visitante 
 * @author Javier Pino
 */  
public class ModeloCanaima implements Serializable, HttpSessionBindingListener {

	private static final long serialVersionUID = 9185150137525148591L;
	
	//************************** M�todos de Binding/Unbinding de sesiones 
	
	/**
	 * Se debe verificar si este modelo es agregado a una sesi�n, entonces deber�a iniciar la conexion.
	 * Inicia la aplicacion, garantiza la conexion y configura las variables de sistema
	 *  
	 *	@see javax.servlet.http.HttpSessionBindingListener#valueBound(javax.servlet.http.HttpSessionBindingEvent)
	 *  @param arg0
	 */	
	@Override
	public void valueBound(HttpSessionBindingEvent arg0) {
		
		//Crear un usuario por defecto
		setUsuarioNulo();
		
		//Aplicaci�n actual de la sesi�n
		ServletContext application = arg0.getSession().getServletContext();
		
		//Se debe iniciar la conexion con una nueva instancia		
		setPoolConexiones(Conexion.getInstance(application));
		
		//Inicializar con los parametros
		configurarAplicacion(application);
		
	}

	/**
	 * Si este modelo es liberado de una sesi�n, pues debe liberar las conexiones  
	 * 
	 *	@see javax.servlet.http.HttpSessionBindingListener#valueUnbound(javax.servlet.http.HttpSessionBindingEvent)
	 *  @param arg0
	 */	
	@Override
	public void valueUnbound(HttpSessionBindingEvent arg0) {
		
		//Finalizar 
		if (poolConexiones != null)
			poolConexiones.finalizar();
	} 

	/** Se deben tomar en cuenta los par�metros de inicializacion que corresponden al negocio, max lotes y max contratos */ 
	public void configurarAplicacion (ServletContext application) {		
		MAX_CONTRATOS_X_LOTE = 
			Integer.parseInt(application.getInitParameter("maxContratosXLote").trim());
		MAX_LOTES_X_CAJA = 
			Integer.parseInt(application.getInitParameter("maxLotesXCaja").trim());
		DIRECTORIO_TEMPORAL = 
			application.getInitParameter("directorioTemporal");		
		DIRECTORIO_DONATARIO =  
			application.getInitParameter("directorioGuardado");
		DIRECTORIO_DOCENTE =  
			application.getInitParameter("directorioDocente");
	}
	
	//**************** P�rametros y M�todos de la aplicaci�n 
	
		/** Cuanto dura la sesi�n */
	protected static final int TIMEOUT = 5000; 	
		/** Pool de Conexiones que utiliza el sistema */
	protected transient Conexion poolConexiones = null;			
	protected Usuario usuarioActual = null;
	
	/** M�todo que se encarga de crear los visitantes */
	public void setUsuarioNulo () {		
		usuarioActual = null;
	} 
	
	/** Guarda un objeto persistente en la base de datos creando la conexion 
	 * y usando sus metodos para validar y actualizar */
	public void guardar(ObjetoPersistente obj) throws ExcepcionRoles, SQLException, ExcepcionValidaciones {
			
		//Crear los objetos
		Connection con = null;
	
		//Crear la conexion y si hubo error rla
		con = solicitarConexion();
		if (!Conexion.esValida(con)) {
			liberarConexion(con);
			throw new SQLException("No se ha iniciado conexion");
		}		
		try {			
			ObjetoPersistente.guardar(con, obj);
			if (obj.isIdentificado()) {
				buscarPorID(obj.getID(), obj);
			} else 
				throw new ExcepcionValidaciones("No se insert� el objeto deseado");
		} finally {
			liberarConexion(con, null, null);
		}	
	}
	
	/** Actualiza un objeto persistente en la base de datos creando la conexion y usando 
	 * sus metodos para validar y actualizar*/
	public void actualizar(ObjetoPersistente obj) throws ExcepcionRoles, SQLException, ExcepcionValidaciones {
			
		//Crear los objetos
		Connection con = null;
		
		//Crear la conexion y si hubo error cerrarla
		con = solicitarConexion();
		if (!Conexion.esValida(con)) {
			liberarConexion(con);
			throw new SQLException("No se ha iniciado conexion");
		}		
		try {			
			ObjetoPersistente.actualizar(con, obj);
		} finally {
			liberarConexion(con, null, null);
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
		con = solicitarConexion();
		if (!Conexion.esValida(con)) {
			liberarConexion(con, ps, rs);
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
			liberarConexion(con, ps, rs);;
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
		con = solicitarConexion();
		if (!Conexion.esValida(con)) {
			liberarConexion(con, ps, null);
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
			liberarConexion(con, ps, null);
		}		
	}
		
	public int MAX_LOTES_X_CAJA, MAX_CONTRATOS_X_LOTE;
	public String DIRECTORIO_TEMPORAL, DIRECTORIO_DONATARIO, DIRECTORIO_DOCENTE;
	public String DIRECTORIO_TEMPORAL_SUFIJO =  "/canaima/temp/";
	
	/*** Verifica si se puede hacer login */
	public Usuario iniciarSesion(String login, String contrasena) throws SQLException {
		
		//Crear los objetos
		Connection con = null;
		PreparedStatement ps = null;
		ResultSet rs = null;	
		
		//Crear la conexion y si hubo error cerrarla
		con = solicitarConexion();
		if (!Conexion.esValida(con)) {
			liberarConexion(con, ps, rs);
			throw new SQLException("No se ha iniciado conexion");
		}
		
		//Usarla
		try {
			
			/*Date finalPrueba = Utilidades.nuevaFecha(MAXDIA, MAXMES, MAXA�O);
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
					// Utilidades.encriptarContrase�a( //TODO Poner de nuevo en produccion
					contrasena);
			rs = ps.executeQuery();			
			if (rs.next()) {
				Usuario retornado = new Usuario();
				retornado.recargar(rs);
				return retornado;
			}			
			return null;			
		} finally {
			liberarConexion(con, ps, rs);
		}
	}
	
	//********************  Los getters y setters  	
	
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
		con = poolConexiones.obtenerConexion(TIMEOUT);
		if (!Conexion.esValida(con)) {
			liberarConexion(con);
			throw new SQLException("No se ha iniciado conexion");
		}
		return con;
	}
	
	/** Solicita al modelo cerrar su conexion, y la devuelve*/
	public void liberarConexion (Connection con) throws SQLException {
		poolConexiones.cerrarConexion(con);
	}
	
	/** Solicita al modelo cerrar su conexion, statement y resultado y la devuelve al pool*/
	public void liberarConexion (Connection con, PreparedStatement ps, ResultSet rs) throws SQLException {
		poolConexiones.cerrarConexion(con, ps, rs);
	}
			
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
	
	private final ArrayList<Docente> recientesDocen = new ArrayList<Docente>();
	private Docente ultimoDocen = new Docente();
	
	/** Agregar Docente a la lista de recientes */	
	public void agregarDocente (Docente reciente) {
		if (recientesDocen.size() > TAM_RECIENTES)
			recientesDocen.remove(0);
		recientesDocen.add(reciente);
		ultimoDocen = reciente;
	}
	
	public Docente getUltimoDocen() {
		return ultimoDocen;
	}

	public void setUltimoDocen(Docente ultimo) {
		this.ultimoDocen = ultimo;
	}

	public ArrayList<Docente> getRecientesDocentes() {
		return recientesDocen;
	}
	
	/** Retorna 
	 * @throws SQLException */
	public DonatarioContrato buscarDonatarioContrato (int donatario, int numero) throws SQLException {
		
		int idcontrato = 0, iddonatario = 0;
		
		//Buscar por numero de contrato
		PreparedStatement ps = null;
		ResultSet rs = null;
			
		//Crear la conexion y si hubo error cerrarla
		Connection con = solicitarConexion();
		if (!Conexion.esValida(con)) {
			liberarConexion(con, ps, rs);
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
			liberarConexion(con, ps, rs);;
		}
	}	
	
	/** Retorna los ids de los estados y municipios dados
	 * @throws SQLException */
	public int[] buscarIDsEstadoMunicipio (String estado, String municipio) throws SQLException {
				
		int[] par = new int[2];
		
		//Buscar por nombre de estado y municipio
		PreparedStatement ps = null;
		ResultSet rs = null;
			
		//Crear la conexion y si hubo error cerrarla
		Connection con = solicitarConexion();
		if (!Conexion.esValida(con)) {
			liberarConexion(con, ps, rs);
			throw new SQLException("No se ha iniciado conexion");
		}			
		
		//Realizar la busqueda
		try {
			String sql = " select m.idestado, m.idmunicipio from municipio m join estado e on (m.idestado = e.idestado) where m.activo and m.idestado > 0 " ;			
			if (estado != null)
				sql += " and e.nombre = ?";
			if (municipio != null)
				sql += " and m.nombre = ? ";			
			if(estado == null || municipio == null)
				throw new SQLException("ESTADO/MUNICIPIO NULL");
			
			ps = con.prepareStatement(sql);
			ps.setString(1, estado);
			ps.setString(2, municipio);			
			rs = ps.executeQuery();			
			if (rs.next()) {
				par[0] = rs.getInt(1);
				par[1] = rs.getInt(2);			
			}
			else
				throw new SQLException("NO ENCONTRO ESTADO/MUNICIPIO (" + estado +", " + municipio +")" );
										
			return par;			
		
		} finally {
			liberarConexion(con, ps, rs);;
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