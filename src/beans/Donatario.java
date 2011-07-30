/**
 Caja.java - 09/04/2011
 Autor: Javier Pino
 */
package beans;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import aplicacion.ExcepcionValidaciones;
import enums.NACIONALIDAD;
import org.apache.commons.lang.StringEscapeUtils;

/**
 * Descripción: 
 * @author Javier Pino
 */
public class Donatario extends ObjetoPersistente {

	private static final long serialVersionUID = 6076024731178013298L;
	
	private int iddonatario; 
	private int idcreadopor; 	
	private String nombre;	
	private boolean activo = true;
	
	//Direccion del Donatario
	private String direccion;
	private int idestado; 
	private int idmunicipio;
	private String ciudad; 
	
	//Datos escolares	
	private String colegio;
	private String codigo_dea; 
	private String director_nombre; 
	private int ano_escolar;
	private int grado;
	private String seccion;
	
	//Datos del representante
	private NACIONALIDAD representante_nac;
	private String representante_ci;
	private String representante_nombre; 
	private String representante_tlf; 

	//Datos del Contrato
	private int idcontrato;
	private String equipo_serial;
	private String proveedor; 
	private Date fecha_entrega;  
	private Date fecha_llegada;
	private Date fecha_act;
	
	//Datos de identificacion del donatario
	private String partidanacimiento; 
	private NACIONALIDAD nacionalidad;
	private String cedula;
	
	//Observacion
	private String observacion;
	private Timestamp fecha_carga;
	private boolean tienefirma = true;
	private boolean tienecedula = true;
	private boolean tienepartida = true;
	
	private static final int TAM_SERIAL = 20;
	
	/**	
	 *	@see beans.ObjetoPersistente#validarCondiciones()
	 *  @return
	 */
	@Override
	public ArrayList<String> validarCondiciones() {		
		
		ArrayList<String> resultado = new ArrayList<String>();		
		if (idcreadopor == 0)
			resultado.add(errorEsObligatorioModelo("Creado Por"));
		if (nombre != null && nombre.length() > TINYTEXT)
			resultado.add(errorTamaño("Nombre", TINYTEXT));
		if (ciudad != null && ciudad.length() > TINYTEXT)
			resultado.add(errorTamaño("Ciudad", TINYTEXT));
		if (colegio != null && colegio.length() > TINYTEXT)
			resultado.add(errorTamaño("Colegio", TINYTEXT));
		if (codigo_dea != null && codigo_dea.length() > TINYTEXT)
			resultado.add(errorTamaño("Código DEA", TINYTEXT));
		if (director_nombre != null && director_nombre.length() > TINYTEXT)
			resultado.add(errorTamaño("Director", TINYTEXT));
		if (seccion != null && seccion.length() > TINYTEXT)
			resultado.add(errorTamaño("Sección", TINYTEXT));
		if (representante_ci != null && representante_ci.length() > TINYTEXT)
			resultado.add(errorTamaño("Cédula Rep.", TINYTEXT));
		if (cedula != null && cedula.length() > TINYTEXT)
			resultado.add(errorTamaño("Cédula", TINYTEXT));
				
		if ( (representante_ci == null || representante_ci.isEmpty()) != (representante_nac == null)) {
			resultado.add("Para agregar la 'Cédula del Representante' debe indicar" +
			" 'Nacionalidad' y 'Número'");
		}
		if ( (cedula == null || cedula.isEmpty()) != (nacionalidad == null)) {
			resultado.add("Para agregar la 'Cédula del Donatario' debe indicar" +
			" 'Nacionalidad' y 'Número'");
		}
		if (representante_nombre != null && representante_nombre.length() > TINYTEXT)
			resultado.add(errorTamaño("Representante - Nombre", TINYTEXT));
		if (representante_tlf != null && representante_tlf.length() > TINYTEXT)
			resultado.add(errorTamaño("Representante - Télefono", TINYTEXT));
		if (equipo_serial != null && equipo_serial.length() > TAM_SERIAL)
			resultado.add(errorTamaño("Serial Equipo", TAM_SERIAL));
		if (proveedor != null && proveedor.length() > TINYTEXT)
			resultado.add(errorTamaño("Proveedor", TINYTEXT));
		if (partidanacimiento != null && partidanacimiento.length() > TINYTEXT)
			resultado.add(errorTamaño("Partida de Nacimiento", TINYTEXT));
		if (observacion != null && observacion.length() > TINYTEXT)
			resultado.add(errorTamaño("Observación", TINYTEXT));
		return resultado;			
	}

	public int getIddonatario() {
		return iddonatario;
	}

	public void setIddonatario(int iddonatario) {
		this.iddonatario = iddonatario;
	}

	public int getIdcreadopor() {
		return idcreadopor;
	}

	public void setIdcreadopor(int idcreadopor) {
		this.idcreadopor = idcreadopor;
	}

	public String getNombre() {
		return nombre;
	}

	public void setNombre(String nombre) {
		this.nombre = nombre;
	}

	public boolean isActivo() {
		return activo;
	}

	public void setActivo(boolean activo) {
		this.activo = activo;
	}

	public String getDireccion() {
		return direccion;
	}

	public void setDireccion(String direccion) {
		this.direccion = direccion;
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

	public String getCiudad() {
		return ciudad;
	}

	public void setCiudad(String ciudad) {
		this.ciudad = ciudad;
	}

	public String getColegio() {
		return colegio;
	}

	public void setColegio(String colegio) {
		this.colegio = colegio;
	}

	public String getCodigo_dea() {
		return codigo_dea;
	}

	public void setCodigo_dea(String codigo_dea) {
		this.codigo_dea = codigo_dea;
	}

	public String getDirector_nombre() {
		return director_nombre;
	}

	public void setDirector_nombre(String director_nombre) {
		this.director_nombre = director_nombre;
	}

	public int getAno_escolar() {
		return ano_escolar;
	}

	public void setAno_escolar(int ano_escolar) {
		this.ano_escolar = ano_escolar;
	}

	public int getGrado() {
		return grado;
	}

	public void setGrado(int grado) {
		this.grado = grado;
	}

	public String getSeccion() {
		return seccion;
	}

	public void setSeccion(String seccion) {
		this.seccion = seccion;
	}

	public NACIONALIDAD getRepresentante_nac() {
		return representante_nac;
	}
	
	public void setRepresentante_nac(String representante_nac) {
		if (representante_nac != null)
			this.representante_nac = NACIONALIDAD.valueOf(representante_nac);
		else this.representante_nac = null;
	}

	public String getRepresentante_ci() {
		return representante_ci;
	}

	public void setRepresentante_ci(String representante_ci) {
		this.representante_ci = representante_ci;
	}

	public String getRepresentante_nombre() {
		return representante_nombre;
	}

	public void setRepresentante_nombre(String representante_nombre) {
		this.representante_nombre = representante_nombre;
	}

	public String getRepresentante_tlf() {
		return representante_tlf;
	}

	public void setRepresentante_tlf(String representante_tlf) {
		this.representante_tlf = representante_tlf;
	}

	public int getIdcontrato() {
		return idcontrato;
	}

	public void setIdcontrato(int idcontrato) {
		this.idcontrato = idcontrato;
	}

	public String getEquipo_serial() {
		return equipo_serial;
	}

	public void setEquipo_serial(String equipo_serial) {
		this.equipo_serial = equipo_serial;
	}

	public String getProveedor() {
		return proveedor;
	}

	public void setProveedor(String proveedor) {
		this.proveedor = proveedor;
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

	public Date getFecha_act() {
		return fecha_act;
	}

	public void setFecha_act(Date fecha_act) {
		this.fecha_act = fecha_act;
	}

	public String getPartidanacimiento() {
		return partidanacimiento;
	}

	public void setPartidanacimiento(String partidanacimiento) {
		this.partidanacimiento = partidanacimiento;
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

	public String getObservacion() {
		return observacion;
	}

	public void setObservacion(String observacion) {
		this.observacion = observacion;
	}

	public Timestamp getFecha_carga() {
		return fecha_carga;
	}

	public void setFecha_carga(Timestamp fecha_carga) {
		this.fecha_carga = fecha_carga;
	}

	public boolean isTienefirma() {
		return tienefirma;
	}

	public void setTienefirma(boolean tienefirma) {
		this.tienefirma = tienefirma;
	}

	public boolean isTienecedula() {
		return tienecedula;
	}

	public void setTienecedula(boolean tienecedula) {
		this.tienecedula = tienecedula;
	}

	public boolean isTienepartida() {
		return tienepartida;
	}

	public void setTienepartida(boolean tienepartida) {
		this.tienepartida = tienepartida;
	}

	/**
	 *	@see beans.ObjetoPersistente#recargar(java.sql.ResultSet)
	 *  @param rs
	 *  @throws SQLException
	 */
	@Override
	public void recargar(ResultSet rs) throws SQLException {
		
		  iddonatario = rs.getInt("iddonatario"); 
		  idcreadopor = rs.getInt("idcreadopor"); 	
		  nombre = StringEscapeUtils.escapeHtml(rs.getString("nombre")); 		  
		  activo = rs.getBoolean("activo");
		  direccion = StringEscapeUtils.escapeHtml(rs.getString("direccion"));
		  idestado = rs.getInt("idestado"); 
		  idmunicipio = rs.getInt("idmunicipio");		  
		  ciudad = StringEscapeUtils.escapeHtml(rs.getString("ciudad"));	
		  colegio = StringEscapeUtils.escapeHtml(rs.getString("colegio"));
		  codigo_dea = StringEscapeUtils.escapeHtml(rs.getString("codigo_dea")); 
		  director_nombre = StringEscapeUtils.escapeHtml(rs.getString("director_nombre")); 
		  ano_escolar = rs.getInt("ano_escolar");
		  grado = rs.getInt("grado");
		  seccion = StringEscapeUtils.escapeHtml(rs.getString("seccion"));
		  
		  if (rs.getString("representante_nac") != "")
			  representante_nac = NACIONALIDAD.valueOf(rs.getString("representante_nac"));			
		  else 
			  representante_nac = null;					  
		  
		  representante_ci = StringEscapeUtils.escapeHtml(rs.getString("representante_ci"));
		  representante_nombre = StringEscapeUtils.escapeHtml(rs.getString("representante_nombre"));		  
		  representante_tlf = StringEscapeUtils.escapeHtml(rs.getString("representante_tlf"));  
		  idcontrato = rs.getInt("idcontrato");
		  equipo_serial = StringEscapeUtils.escapeHtml(rs.getString("equipo_serial"));
		  proveedor = StringEscapeUtils.escapeHtml(rs.getString("proveedor")); 
		  fecha_entrega  = rs.getDate("fecha_entrega");
		  fecha_llegada = rs.getDate("fecha_llegada");
		  fecha_act = rs.getDate("fecha_act");
		  partidanacimiento = StringEscapeUtils.escapeHtml(rs.getString("partidanacimiento"));
		  if (rs.getString("nacionalidad") != "")
			  nacionalidad = NACIONALIDAD.valueOf(rs.getString("nacionalidad"));			
		  else 
			  nacionalidad = null;			
		  cedula = StringEscapeUtils.escapeHtml(rs.getString("cedula"));		
		  observacion  = StringEscapeUtils.escapeHtml(rs.getString("observacion"));
		  fecha_carga = rs.getTimestamp("fecha_carga"); 
		  tienefirma = rs.getBoolean("tienefirma");
		  tienecedula = rs.getBoolean("tienecedula");
		  tienepartida = rs.getBoolean("tienepartida");
	}

	/**
	 *	@see beans.ObjetoPersistente#guardar(java.sql.Connection)
	 *  @param con
	 *  @throws SQLException
	 * @throws ExcepcionValidaciones 
	 */

	@Override
	public synchronized void guardar(Connection con) throws SQLException, ExcepcionValidaciones {
		
		//Se esta creando un donatario previamente existente		
		validarSerialUnico(con);
		validarContratoUnico(con);
		
		String sql_insercion = "insert into `canaima`.`donatario` " +				
			"(`idcreadopor`, `nombre`, `direccion`, " +
			"`idestado`, `idmunicipio`, `ciudad`, `colegio`, " +
			"`ano_escolar`, `grado`, " +
			"`seccion`, `representante_nac`, `representante_ci`, `representante_nombre`, `representante_tlf`, `idcontrato`, " +
			"`equipo_serial`, `fecha_entrega`, `fecha_llegada`, `partidanacimiento`, `cedula`, `nacionalidad`, `observacion`, " +
			"`tienefirma`, `tienecedula`, `tienepartida`,`codigo_dea`, `director_nombre`, `proveedor`, `fecha_act`, `activo`) " +
			" values (?, ?, ?, ?, ?, ?, ? , ?, ?, ?,?, ?, ?, ?, ?, ?, ? , ?, ?, ?,?, ?, ?, ?, ?, ?, ? , ?, ?, ?)";			
		PreparedStatement ps = con.prepareStatement(sql_insercion, PreparedStatement.RETURN_GENERATED_KEYS);
		ps.setInt(1, idcreadopor); 	
		ps.setString(2, (nombre == null ? ""  : StringEscapeUtils.unescapeHtml(nombre.toUpperCase())));
		ps.setString(3, (direccion == null ? "" : StringEscapeUtils.unescapeHtml(direccion.toUpperCase())));
		ps.setInt(4, idestado); 
		ps.setInt(5, idmunicipio);		  
		ps.setString(6, (ciudad == null ? "" : StringEscapeUtils.unescapeHtml(ciudad.toUpperCase())));	
		ps.setString(7, (colegio == null ? "" : StringEscapeUtils.unescapeHtml(colegio.toUpperCase())));
		ps.setInt(8,ano_escolar);
		ps.setInt(9, grado);
		ps.setString(10, (seccion == null ? "" : StringEscapeUtils.unescapeHtml(seccion.toUpperCase())));		
		ps.setString(11, (representante_nac != null) ? representante_nac.toString() : "");		
		ps.setString(12, (representante_ci == null ? "" : StringEscapeUtils.unescapeHtml(representante_ci.toUpperCase())));
		ps.setString(13, (representante_nombre == null ? "" : StringEscapeUtils.unescapeHtml(representante_nombre.toUpperCase())));		  
		ps.setString(14, (representante_tlf == null ? "" : StringEscapeUtils.unescapeHtml(representante_tlf.toUpperCase())));  
		ps.setInt(15, idcontrato);
		ps.setString(16, (equipo_serial == null ? "" : StringEscapeUtils.unescapeHtml(equipo_serial.toUpperCase())));
		ps.setDate(17,fecha_entrega);
		ps.setDate(18, fecha_llegada);		  
		ps.setString(19, (partidanacimiento == null) ? "" : StringEscapeUtils.unescapeHtml(partidanacimiento.toUpperCase()));
		ps.setString(20, cedula);		
		ps.setString(21, (nacionalidad != null) ? nacionalidad.toString(): "");		
		ps.setString(22, (observacion == null ? "" : StringEscapeUtils.unescapeHtml(observacion.toUpperCase())));
		ps.setBoolean(23,tienefirma);
		ps.setBoolean(24, tienecedula);
		ps.setBoolean(25, tienepartida);
		ps.setString(26, (codigo_dea == null ? "" : StringEscapeUtils.unescapeHtml(codigo_dea.toUpperCase()))); 
		ps.setString(27, (director_nombre == null ? "" : StringEscapeUtils.unescapeHtml(director_nombre.toUpperCase())));
		ps.setString(28, (proveedor == null ? "" : StringEscapeUtils.unescapeHtml(proveedor.toUpperCase())));
		ps.setDate(29, fecha_act);
		ps.setBoolean(30, activo);		  
		ps.executeUpdate();
		ResultSet rs = ps.getGeneratedKeys();
		if (rs.next()) {
			setIddonatario(rs.getInt(1));
		}				
		rs.close();
		ps.close();
	}

	/**
	 *	@see beans.ObjetoPersistente#actualizar(java.sql.Connection)
	 *  @param con
	 *  @throws SQLException
	 * @throws ExcepcionValidaciones 
	 */

	@Override
	public synchronized void actualizar(Connection con) throws SQLException, ExcepcionValidaciones {
		
		//Se esta actualizando un donatario previamente existente		
		validarSerialUnico(con);
		validarContratoUnico(con);
		
		String update = "SELECT " +
				"`idcreadopor`, `nombre`, `direccion`, " +
				"`idestado`, `idmunicipio`, `ciudad`, `colegio`, " +
				"`ano_escolar`, `grado`, " +
				"`seccion`, `representante_nac`, `representante_ci`, `representante_nombre`, `representante_tlf`, `idcontrato`, " +
				"`equipo_serial`, `fecha_entrega`, `fecha_llegada`, `partidanacimiento`, `cedula`, `nacionalidad`, `observacion`, " +
				"`tienefirma`, `tienecedula`, `tienepartida`,`codigo_dea`, `director_nombre`, " +				
				"`proveedor`, `fecha_act`, `activo`, `iddonatario` FROM `canaima`.`donatario` where iddonatario = ?";
		PreparedStatement ps = con.prepareStatement(update, ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_UPDATABLE);
		ps.setInt(1, getIddonatario());
		ResultSet rs = ps.executeQuery();
		if (rs.next()) {		
			rs.updateInt(1, idcreadopor); 	
			rs.updateString(2, (nombre == null ? ""  : nombre.toUpperCase()));
			rs.updateString(3, (direccion == null ? "" : direccion.toUpperCase()));
			rs.updateInt(4, idestado); 
			rs.updateInt(5, idmunicipio);		  
			rs.updateString(6, (ciudad == null ? "" : ciudad.toUpperCase()));	
			rs.updateString(7, (colegio == null ? "" : colegio.toUpperCase()));
			rs.updateInt(8,ano_escolar);
			rs.updateInt(9, grado);
			rs.updateString(10, (seccion == null ? "" : seccion.toUpperCase()));
			rs.updateString(11, (representante_nac != null)? representante_nac.toString() : "");			
			rs.updateString(12, representante_ci);
			rs.updateString(13, (representante_nombre == null ? "" : representante_nombre.toUpperCase()));		  
			rs.updateString(14, (representante_tlf == null ? "" : representante_tlf.toUpperCase()));  
			rs.updateInt(15, idcontrato);
			rs.updateString(16, (equipo_serial == null ? "" : equipo_serial.toUpperCase()));
			rs.updateDate(17,fecha_entrega);
			rs.updateDate(18, fecha_llegada);		  
			rs.updateString(19, (partidanacimiento == null) ? "" : partidanacimiento.toUpperCase());
			rs.updateString(20, cedula);	
			rs.updateString(21, (nacionalidad != null) ? nacionalidad.toString(): "");
			rs.updateString(22, (observacion == null ? "" : observacion.toUpperCase()));
			rs.updateBoolean(23,tienefirma);
			rs.updateBoolean(24, tienecedula);
			rs.updateBoolean(25, tienepartida);
			rs.updateString(26, (codigo_dea == null ? "" : codigo_dea.toUpperCase())); 
			rs.updateString(27, (director_nombre == null ? "" : director_nombre.toUpperCase()));
			rs.updateString(28, (proveedor == null ? "" : proveedor.toUpperCase()));
			rs.updateDate(29, fecha_act);
			rs.updateBoolean(30, activo);
			rs.updateRow();
		}
		rs.close();
		ps.close();
	}
	
	@Override
	public String toString() {
		return "Donatario [iddonatario=" + iddonatario + ", idcreadopor="
				+ idcreadopor + ", nombre=" + nombre + ", activo=" + activo
				+ ", direccion=" + direccion + ", idestado=" + idestado
				+ ", idmunicipio=" + idmunicipio + ", ciudad=" + ciudad
				+ ", colegio=" + colegio + ", codigo_dea=" + codigo_dea
				+ ", director_nombre=" + director_nombre + ", ano_escolar="
				+ ano_escolar + ", grado=" + grado + ", seccion=" + seccion
				+ ", representante_nac=" + representante_nac
				+ ", representante_ci=" + representante_ci
				+ ", representante_nombre=" + representante_nombre
				+ ", representante_tlf=" + representante_tlf + ", idcontrato="
				+ idcontrato + ", equipo_serial=" + equipo_serial
				+ ", proveedor=" + proveedor + ", fecha_entrega="
				+ fecha_entrega + ", fecha_llegada=" + fecha_llegada
				+ ", fecha_act=" + fecha_act + ", partidanacimiento="
				+ partidanacimiento + ", nacionalidad=" + nacionalidad
				+ ", cedula=" + cedula + ", observacion=" + observacion
				+ ", fecha_carga=" + fecha_carga + ", tienefirma=" + tienefirma
				+ ", tienecedula=" + tienecedula + ", tienepartida="
				+ tienepartida + "]";
	}

	@Override
	public int getID() {
		return getIddonatario();
	}
	
	
	/** Verifica que la restriccion de integridad de serial unico se mantenga 
	 * @throws SQLException 
	 * @throws ExcepcionValidaciones */
	public void validarSerialUnico (Connection con) throws SQLException, ExcepcionValidaciones {
		
		if (getEquipo_serial() == null || getEquipo_serial().isEmpty())
			return;
		
		String sqlSerialUnico = "select * from canaima.donatario where activo and equipo_serial = ? and iddonatario != ? " ;
		PreparedStatement ps =  null; 
		ResultSet rs = null;
		try {
			ps = con.prepareStatement(sqlSerialUnico);
			ps.setString(1, getEquipo_serial());
			ps.setInt(2, getIddonatario());		
			rs = ps.executeQuery();
			if (rs.next()) {
				Donatario repetido = new Donatario();
				repetido.recargar(rs);
				throw new ExcepcionValidaciones(
						"El donatario 'ID = " + repetido.getID() + "' posee el mismo Serial de Equipo('" +	
						repetido.getEquipo_serial() + "') que el donatario ingresado )");
			}
		}
		finally {
			if (rs != null)
				rs.close();
			if (ps != null)
				ps.close();
		}
	}
	
	/** Verifica que la restriccion de integridad de serial unico se mantenga 
	 * @throws SQLException 
	 * @throws ExcepcionValidaciones */
	public void validarContratoUnico (Connection con) throws SQLException, ExcepcionValidaciones {
		
		if (getIdcontrato() == 0)
			return;
		
		String sqlSerialUnico = "select * from canaima.donatario where activo and idcontrato = ? and iddonatario != ? " ;
		PreparedStatement ps =  null; 
		ResultSet rs = null;
		try {
			ps = con.prepareStatement(sqlSerialUnico);
			ps.setInt(1, getIdcontrato());
			ps.setInt(2, getIddonatario());		
			rs = ps.executeQuery();
			if (rs.next()) {
				Donatario repetido = new Donatario();
				repetido.recargar(rs);
				throw new ExcepcionValidaciones(
						"El donatario 'ID = " + repetido.getID() + "' posee el mismo Contrato('" +	
						repetido.getIdcontrato() + "') que el donatario ingresado )");
			}
		}
		finally {
			if (rs != null)
				rs.close();
			if (ps != null)
				ps.close();
		}
	}

	/** Aunque no es una validacion en si misma la regla del negocio, implica que debe alertarse por 
	 * donatarios con misma cedula y mismo nombre  
	 * @throws SQLException 
	 * @throws ExcepcionValidaciones */
	public void validarCedulaRepNombreDonatario (Connection con) throws SQLException, ExcepcionValidaciones {
		
		if (getRepresentante_ci() == null || getRepresentante_ci().isEmpty())
			return;
		else {
			if (getNombre() == null || getNombre().isEmpty())
				return;
		}		
		String sqlSerialUnico = " select * from canaima.donatario where activo " +
				" and representante_nac = ? and representante_ci = ? and nombre = ? and iddonatario != ? " ;
		PreparedStatement ps =  null; 
		ResultSet rs = null;
		try {
			ps = con.prepareStatement(sqlSerialUnico);
			ps.setString(1, (getRepresentante_nac() != null ) ? getRepresentante_nac().toString() : "");		
			ps.setString(2, getRepresentante_ci());
			ps.setString(3, getNombre());
			ps.setInt(4, getIddonatario());		
			rs = ps.executeQuery();
			if (rs.next()) {
				Donatario repetido = new Donatario();
				repetido.recargar(rs);
				throw new ExcepcionValidaciones(
						"El donatario 'ID = " + repetido.getID() + "' <br>posee la misma cédula de representante " +
						"('" +	repetido.getRepresentante_nac() + "-" + repetido.getRepresentante_ci()
						+ "')<br> y nombre de donatario ('" + repetido.getNombre() + "') que el donatario ingresado" +
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
	/** Verifica que la restriccion de integridad de serial unico se mantenga 
	 * @throws SQLException 
	 * @throws ExcepcionValidaciones */
	public static ArrayList<Donatario> listarDonatarios(Connection con,
		int estado, 
		int municipio, 
		String ciudad, 
		String colegio, 
		int grado, 
		String nombreDonatario, 
		String cedulaRepresentante,
		int idDonatario,
		int idCreadoPor,
		int idColegio,
		int idParroquia
		
	) throws SQLException, ExcepcionValidaciones {
		
		final int ESTADO = 0, MUNICIPIO = 1, CIUDAD = 2, COLEGIO = 3,
			GRADO = 4, NOMBREDONATARIO = 5, CEDULAREP = 6, IDDONATARIO = 7, IDCREADOPOR = 8, IDCOLEGIO = 9, IDPARROQUIA = 10;		
		boolean [] parametrosPresentes = {false, false, false, false,
				false, false, false, false, true, false, false};
		
		if (estado > 0)
			parametrosPresentes[ESTADO] = true;
		if (municipio> 0)
			parametrosPresentes[MUNICIPIO] = true;
		if (ciudad != null && !ciudad.isEmpty())
			parametrosPresentes[CIUDAD] = true;
		if (colegio != null && !colegio.isEmpty())
			parametrosPresentes[COLEGIO] = true;
		if (grado > 0)
			parametrosPresentes[GRADO] = true;
		if (nombreDonatario != null && !nombreDonatario.isEmpty())
			parametrosPresentes[NOMBREDONATARIO] = true;
		if (cedulaRepresentante != null && !cedulaRepresentante.isEmpty())
			parametrosPresentes[CEDULAREP] = true;
		if (idDonatario > 0)
			parametrosPresentes[IDDONATARIO] = true;
		if (idColegio > 0)
			parametrosPresentes[IDCOLEGIO] = true;
		if (idParroquia > 0)
			parametrosPresentes[IDPARROQUIA] = true;
		
		ArrayList<Donatario> resultado = new ArrayList<Donatario>();		
		int parametrosUsados = 1;
		
		//Crear el string de búsqueda
		String sqlDonatarios = 
			"select * from donatario where activo ";
		if (parametrosPresentes[ESTADO]) {
			sqlDonatarios += " and idestado = ? ";
		}
		if (parametrosPresentes[MUNICIPIO]) {
			sqlDonatarios += " and idmunicipio = ? ";
		}
		if (parametrosPresentes[CIUDAD]) {
			sqlDonatarios += " and ciudad like ? ";
		}
		if (parametrosPresentes[COLEGIO]) {
			sqlDonatarios += " and colegio like ? ";
		}
		if (parametrosPresentes[GRADO]) {
			sqlDonatarios += " and grado = ? ";
		}
		if (parametrosPresentes[NOMBREDONATARIO]) {
			sqlDonatarios += " and nombre like ? ";
		}
		if (parametrosPresentes[CEDULAREP]) {
			sqlDonatarios += " and representante_ci like ? ";
		}
		if (parametrosPresentes[IDDONATARIO]) {
			sqlDonatarios += " and iddonatario = ?";
		}
		if (parametrosPresentes[IDCREADOPOR]) {
			//sqlDonatarios += " and idcreadopor = ?";			
			//Los usuarios solicitaron que esta restricción se eliminara.
		}
		if (parametrosPresentes[IDCOLEGIO]) {
			sqlDonatarios += " and idcolegio = ?";
		}
		if (parametrosPresentes[IDPARROQUIA]) {
			sqlDonatarios += " and idparroquia = ?";
		}
		
		
		sqlDonatarios += " order by ciudad, colegio, grado, nombre";
		
		PreparedStatement ps =  null; 
		ResultSet rs = null;		
		try {
			ps = con.prepareStatement(sqlDonatarios);		
			if (parametrosPresentes[ESTADO]) {
				ps.setInt(parametrosUsados++, estado);				
			}
			if (parametrosPresentes[MUNICIPIO]) {
				ps.setInt(parametrosUsados++, municipio);
			}
			if (parametrosPresentes[CIUDAD]) {
				ps.setString(parametrosUsados++, "%"+ciudad+"%");
			}
			if (parametrosPresentes[COLEGIO]) {
				ps.setString(parametrosUsados++, "%"+colegio+"%");
			}
			if (parametrosPresentes[GRADO]) {
				ps.setInt(parametrosUsados++, grado);
			}
			if (parametrosPresentes[NOMBREDONATARIO]) {
				ps.setString(parametrosUsados++, "%"+nombreDonatario+"%");
			}
			if (parametrosPresentes[CEDULAREP]) {
				ps.setString(parametrosUsados++, "%"+cedulaRepresentante+"%");
			}
			if (parametrosPresentes[IDDONATARIO]) {
				ps.setInt(parametrosUsados++, idDonatario);
			}	
			if (parametrosPresentes[IDCREADOPOR]) {
				//ps.setInt(parametrosUsados++, idCreadoPor);
				//Los usuarios solicitaron que esta restricción se eliminara
			}
			if (parametrosPresentes[IDCOLEGIO]) {
				ps.setInt(parametrosUsados++, idColegio);
			}
			if (parametrosPresentes[IDPARROQUIA]) {
				ps.setInt(parametrosUsados++, idParroquia);
			}
			
			rs = ps.executeQuery();
			Donatario retornado = null;
			while (rs.next()) {
				retornado = new Donatario();
				retornado.recargar(rs);
				resultado.add(retornado);
			}
		}
		finally {
			if (rs != null)
				rs.close();
			if (ps != null)
				ps.close();
		}
		return resultado;
	}
	
	/** Obtiene el ultimo donatario registrado por el usuario 
	 * @throws SQLException 
	 * @throws ExcepcionValidaciones */
	public static int getUltimoDonatarioRegistrado (Usuario actual, Connection con) throws SQLException, ExcepcionValidaciones {		
		
		String sql = " select coalesce(max(iddonatario), 0) from donatario where activo and idcreadopor = ?" ;
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
	
	/** Retorna 
	 * @throws SQLException */
	public static Donatario primerDonatarioRegistrado (Connection con) throws SQLException {
						
		//Buscar por numero de contrato
		PreparedStatement ps = null;
		ResultSet rs = null;
		Donatario resultado = new Donatario();
		
		//Realizar la busqueda
		try {
			String sql = " select * from donatario d order by iddonatario asc " ;						
			ps = con.prepareStatement(sql);
			rs = ps.executeQuery();
			if (rs.next()) {
				resultado.recargar(rs);
			}			
		} finally {
			if (ps != null) 
				ps.close();
			if (rs != null)
				rs.close();
		}
		return resultado;
	}	
		
}
