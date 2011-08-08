package beans;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.ListIterator;

import org.apache.commons.lang.StringEscapeUtils;

import enums.NACIONALIDAD;

import aplicacion.ExcepcionValidaciones;

public class Docente extends ObjetoPersistente {

	private static final long serialVersionUID = 723342237982751857L;
		
	//Identificacion del docente
	private int iddocente;
	private int idcreadopor;
	private NACIONALIDAD nacionalidad;
	private String cedula;
	private String nombre;
	
	//Direccion del docente
	private int idestado;
	private int idmunicipio;	
	private int idparroquia;	
	private int idcolegio;
	private String ciudad;
	
	//Fechas
	private Date fecha_entrega;  
	private Date fecha_llegada;
	private Timestamp fecha_carga;
	private boolean activo = true;
		
	//Datos del contrato
	private int idcontrato;
	private String observacion;
	private String proveedor;
	
	
	//Getters y Setters
	public int getIdcontrato() {
		return idcontrato;
	}

	public void setIdcontrato(int idcontrato) {
		this.idcontrato = idcontrato;
	}
	
	public int getIddocente() {
		return iddocente;
	}

	public void setIddocente(int iddocente) {
		this.iddocente = iddocente;
	}

	public int getIdcreadopor() {
		return idcreadopor;
	}

	public void setIdcreadopor(int idcreadopor) {
		this.idcreadopor = idcreadopor;
	}

	public NACIONALIDAD getNacionalidad() {
		return nacionalidad;
	}

	public void setNacionalidad(String nacionalidad) {
		if (nacionalidad != null)
			this.nacionalidad = NACIONALIDAD.valueOf(nacionalidad);
		else this.nacionalidad = null;
	}

	public String getCedula() {
		return cedula;
	}

	public void setCedula(String cedula) {
		this.cedula = cedula;
	}

	public String getNombre() {
		return nombre;
	}

	public void setNombre(String nombre) {
		this.nombre = nombre;
	}

	public int getIdestado() {
		return idestado;
	}

	public void setIdestado(int idestado) {
		this.idestado = idestado;
	}

	public int getIdmunicipio() {
		return idmunicipio;
	}

	public void setIdmunicipio(int idmunicipio) {
		this.idmunicipio = idmunicipio;
	}

	public int getIdparroquia() {
		return idparroquia;
	}

	public void setIdparroquia(int idparroquia) {
		this.idparroquia = idparroquia;
	}

	public int getIdcolegio() {
		return idcolegio;
	}

	public void setIdcolegio(int idcolegio) {
		this.idcolegio = idcolegio;
	}

	public String getCiudad() {
		return ciudad;
	}

	public void setCiudad(String ciudad) {
		this.ciudad = ciudad;
	}

	public Date getFecha_entrega() {
		return fecha_entrega;
	}

	public void setFecha_entrega(Date fecha_entrega) {
		this.fecha_entrega = fecha_entrega;
	}

	public Date getFecha_llegada() {
		return fecha_llegada;
	}

	public void setFecha_llegada(Date fecha_llegada) {
		this.fecha_llegada = fecha_llegada;
	}

	public Timestamp getFecha_carga() {
		return fecha_carga;
	}

	public void setFecha_carga(Timestamp fecha_carga) {
		this.fecha_carga = fecha_carga;
	}

	public String getObservacion() {
		return observacion;
	}

	public void setObservacion(String observacion) {
		this.observacion = observacion;
	}

	public String getProveedor() {
		return proveedor;
	}

	public void setProveedor(String proveedor) {
		this.proveedor = proveedor;
	}

	public boolean isActivo() {
		return activo;
	}

	public void setActivo(boolean activo) {
		this.activo = activo;
	}	
		
	@Override
	public ArrayList<String> validarCondiciones() {		
		ArrayList<String> resultado = new ArrayList<String>();				
		if (idcreadopor == 0)
			resultado.add(errorEsObligatorioModelo("Creado Por"));		
		if (nombre != null && nombre.length() > TINYTEXT)
			resultado.add(errorTamaño("Nombre", TINYTEXT));
		if (ciudad != null && ciudad.length() > TINYTEXT)
			resultado.add(errorTamaño("Ciudad", TINYTEXT));
		if (observacion != null && observacion.length() > TINYTEXT)
			resultado.add(errorTamaño("Observacion", TINYTEXT));
		if (proveedor != null && proveedor.length() > TINYTEXT)
			resultado.add(errorTamaño("Proveedor", TINYTEXT));
		
		//Usando el o exclusivo != 
		if ( (cedula == null || cedula.isEmpty()) != (nacionalidad == null)) {
			resultado.add("Para agregar la 'Cédula del Docente' debe indicar" +
			" 'Nacionalidad' y 'Número'");
		}
		return resultado;
	}

	@Override
	public void recargar(ResultSet rs) throws SQLException {		
		
		iddocente = rs.getInt("iddocente");
		idcreadopor = rs.getInt("idcreadopor");
		if (rs.getString("nacionalidad") != "")
			  nacionalidad = NACIONALIDAD.valueOf(rs.getString("nacionalidad"));
		cedula = StringEscapeUtils.escapeHtml(rs.getString("cedula"));
		nombre = StringEscapeUtils.escapeHtml(rs.getString("nombre"));
		idestado = rs.getInt("idestado");
		idmunicipio = rs.getInt("idmunicipio");
		idparroquia = rs.getInt("idparroquia");
		idcolegio = rs.getInt("idcolegio");
		ciudad = StringEscapeUtils.escapeHtml(rs.getString("ciudad"));
		fecha_entrega = rs.getDate("fecha_entrega");
		fecha_llegada = rs.getDate("fecha_llegada");
		fecha_carga = rs.getTimestamp("fecha_carga");
		activo = rs.getBoolean("activo");
		proveedor = StringEscapeUtils.escapeHtml(rs.getString("proveedor"));
		observacion = StringEscapeUtils.escapeHtml(rs.getString("observacion"));
		idcontrato = rs.getInt("idcontrato");
	}

	@Override
	public void guardar(Connection con) throws SQLException, ExcepcionValidaciones {
		
		//Se esta creando un donatario previamente existente				
		String sql_insercion = "insert into `canaima`.`docente` (" +				
			" `idcolegio`, `idestado`, `idmunicipio`, `idparroquia`, `ciudad`, `nacionalidad`, `cedula`, `nombre`, " +
			" `fecha_entrega`, `fecha_llegada`, `observacion`, `proveedor`, `idcreadopor`, `idcontrato` " +
			" ) values (?, ?, ?, ?, ?, ? , ?, ?, ?, ?, ?, ?, ?, ?) ";			
		PreparedStatement ps = con.prepareStatement(sql_insercion, PreparedStatement.RETURN_GENERATED_KEYS);
		ps.setInt(1, idcolegio);
		ps.setInt(2, idestado);
		ps.setInt(3, idmunicipio);
		ps.setInt(4, idparroquia);
		ps.setString(5, (ciudad == null ? ""  : StringEscapeUtils.unescapeHtml(ciudad.toUpperCase())));
		ps.setString(6, (nacionalidad != null) ? nacionalidad.toString() : "");		
		ps.setString(7, (cedula == null ? "" : StringEscapeUtils.unescapeHtml(cedula.toUpperCase())));
		ps.setString(8, (nombre == null ? "" : StringEscapeUtils.unescapeHtml(nombre.toUpperCase())));
		ps.setDate(9, fecha_entrega);
		ps.setDate(10, fecha_llegada);
		ps.setString(11, (observacion == null ? "" : StringEscapeUtils.unescapeHtml(observacion.toUpperCase())));
		ps.setString(12, (proveedor == null ? "" : StringEscapeUtils.unescapeHtml(proveedor.toUpperCase())));
		ps.setInt(13, idcreadopor);
		ps.setInt(14, idcontrato); 	
		ps.executeUpdate();
		ResultSet rs = ps.getGeneratedKeys();
		if (rs.next()) {
			setIddocente(rs.getInt(1));
		}				
		rs.close();
		ps.close();
	}

	@Override
	public void actualizar(Connection con) throws SQLException,
			ExcepcionValidaciones {
		
		//Se esta actualizando un donatario previamente existente		
		//validarSerialUnico(con);
		//validarContratoUnico(con);
			
		String update = "SELECT " +
			" `idcolegio`, `idestado`, `idmunicipio`, `idparroquia`, `ciudad`, `nacionalidad`, `cedula`, `nombre`, " +
			" `fecha_entrega`, `fecha_llegada`, `observacion`, `proveedor`, `idcreadopor`, `activo`, " +
			" `idcontrato`, `iddocente` FROM `canaima`.`docente` where iddocente = ?";
		PreparedStatement ps = con.prepareStatement(update, ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_UPDATABLE);
		ps.setInt(1, getID());
		ResultSet rs = ps.executeQuery();
		if (rs.next()) {		
			rs.updateInt(1, idcolegio);
			rs.updateInt(2, idestado); 
			rs.updateInt(3, idmunicipio);
			rs.updateInt(4, idparroquia);
			rs.updateString(5, (ciudad == null ? "" : StringEscapeUtils.unescapeHtml(ciudad.toUpperCase())));
			rs.updateString(6, (nacionalidad != null)? nacionalidad.toString() : "");			
			rs.updateString(7, cedula);			
			rs.updateString(8, (nombre == null ? ""  : StringEscapeUtils.unescapeHtml(nombre.toUpperCase())));			
			rs.updateDate(9,fecha_entrega);
			rs.updateDate(10, fecha_llegada);		  		  
			rs.updateString(11, (observacion == null ? "" : StringEscapeUtils.unescapeHtml(observacion.toUpperCase())));
			rs.updateString(12, (proveedor == null ? "" : StringEscapeUtils.unescapeHtml(proveedor.toUpperCase())));
			rs.updateInt(13, idcreadopor);
			rs.updateBoolean(14, activo);
			rs.updateInt(15, idcontrato);			
			rs.updateRow();
		}
		rs.close();
		ps.close();
	}
	
	/** Obtiene el ultimo donatario registrado por el usuario 
	 * @throws SQLException 
	 * @throws ExcepcionValidaciones */
	public static int getUltimoDocenteRegistrado (Usuario actual, Connection con) throws SQLException, ExcepcionValidaciones {		
		
		String sql = " select coalesce(max(iddocente), 0) from docente where activo and idcreadopor = ?" ;
		PreparedStatement ps =  null; 
		ResultSet rs = null;
		try {			
			ps = con.prepareStatement(sql);		
			ps.setInt(1, actual.getID());		
			rs = ps.executeQuery();
			rs.next();
			return rs.getInt(1);
		}
		finally {
			if (rs != null)
				rs.close();
			if (ps != null)
				ps.close();
		}		
	}

	@Override
	public int getID() {	
		return getIddocente();
	}
	
	/** Aunque no es una validacion en si misma la regla del negocio, implica que debe alertarse por 
	 * docentes con misma cedula y mismo nombre  
	 * @throws SQLException 
	 * @throws ExcepcionValidaciones */
	public void validarCedulaRepNombreDocente (Connection con) throws SQLException, ExcepcionValidaciones {
		
		if (getCedula() == null || getCedula().isEmpty())
			return;
		else {
			if (getNombre() == null || getNombre().isEmpty())
				return;
		}		
		String sqlNombreCedula = " select * from canaima.docente where activo " +
				" and nacionalidad = ? and cedula = ? and nombre = ? and iddocente != ? " ;
		PreparedStatement ps =  null; 
		ResultSet rs = null;
		try {
			ps = con.prepareStatement(sqlNombreCedula);
			ps.setString(1, (getCedula() != null ) ? getNacionalidad().toString() : "");
			ps.setString(2, getCedula());
			ps.setString(3, getNombre());
			ps.setInt(4, getIddocente());
			rs = ps.executeQuery();
			if (rs.next()) {
				Docente repetido = new Docente();
				repetido.recargar(rs);
				throw new ExcepcionValidaciones(
						"El docente 'ID = " + repetido.getID() + "' <br>posee la misma cédula " +
						"('" +	repetido.getNacionalidad() + "-" + repetido.getCedula()
						+ "')<br> y nombre ('" + repetido.getNombre() + "') que el docente ingresado" +
						"<br><br>El mismo fue almacenado, verifique y si hay alguna inconsistencia elimine el registro"
					);
			}
		}
		finally {
			if (rs != null)
				rs.close();
			if (ps != null)
				ps.close();
		}		
	}
	
	/** Ultimos 20 docentes registrados
	 *  
	 * @throws SQLException 
	 * @throws ExcepcionValidaciones */
	public static ArrayList<Docente> getRecientes(Connection con) throws SQLException, ExcepcionValidaciones {
			
		ArrayList<Docente> recientes = new ArrayList<Docente>();
		
		String sql = " select * from canaima.docente " +
								 "order by iddocente LIMIT 0, 20" ;
		PreparedStatement ps =  null; 
		ResultSet rs = null;
		Docente resultado = new Docente();
		try {
			ps = con.prepareStatement(sql);
			rs = ps.executeQuery();
			while (rs.next()) {
				resultado.recargar(rs);	
				recientes.add(resultado);
				resultado = new Docente();
			}
		}
		finally {
			if (rs != null)
				rs.close();
			if (ps != null)
				ps.close();
		}	
		
		return recientes;
	}
	
}
