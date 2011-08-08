package beans;

import java.io.Serializable;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import org.apache.commons.lang.StringEscapeUtils;

import aplicacion.ExcepcionValidaciones;

public class Colegio extends ObjetoPersistente implements Serializable {	
	
	private static final long serialVersionUID = 1L;
	
	private int idcolegio;
	private String nombre;
	private String codigo_dea;
	private int idestado;
	private int idmunicipio;
	private int idparroquia;
	private String direccion;
	private int idCreadoPor;
	private boolean activo;
	
		public int getIdCreadoPor() {
		return idCreadoPor;
	}

	public void setIdCreadoPor(int idCreadoPor) {
		this.idCreadoPor = idCreadoPor;
	}

	public String getDireccion() {
		return direccion;
	}

	public void setDireccion(String direccion) {
		this.direccion = direccion;
	}
	
	public void setIdcolegio(int idcolegio) {
		this.idcolegio = idcolegio;
	}

	public int getIdcolegio() {
		return idcolegio;
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
	
	public void setIdparroquia(int idparroquia) {
		this.idparroquia = idparroquia;
	}

	public int getIdparroquia() {
		return idparroquia;
	}

	public boolean isActivo() {
		return activo;
	}

	public void setActivo(boolean activo) {
		this.activo = activo;
	}

	public String getNombre() {
		return nombre;
	}

	public void setNombre(String nombre) {
		this.nombre = nombre;
	}
	
	public void setCodigo_dea(String codigo_dea) {
		this.codigo_dea = codigo_dea;
	}

	public String getCodigo_dea() {
		return codigo_dea;
	}
	
	
	/**	
	 *	@see beans.ObjetoPersistente#validarCondiciones()
	 *  @return
	 */
	@Override
	public ArrayList<String> validarCondiciones() {		
		
		ArrayList<String> resultado = new ArrayList<String>();		
		if (idestado == 0)
			resultado.add(errorEsObligatorio("Estado"));		
		if ((nombre == null) ||(nombre.compareTo("")== 0))
			resultado.add(errorEsObligatorio("Nombre"));
		
		if ((codigo_dea == null) || (codigo_dea.compareTo("")== 0))
			resultado.add(errorEsObligatorio("codigo_dea"));
		
		if (nombre != null && nombre.length() > TINYTEXT)
			resultado.add(errorTamaño("Nombre", TINYTEXT));
		return resultado;			
	}

	@Override
	public void recargar(ResultSet rs) throws SQLException {
		
		setIdcolegio(rs.getInt("idcolegio"));
		setIdestado(rs.getInt("idestado"));
		setIdmunicipio(rs.getInt("idmunicipio"));
		setIdparroquia(rs.getInt("idparroquia"));
		setNombre(StringEscapeUtils.escapeHtml(rs.getString("nombre")));
		setActivo(rs.getBoolean("activo"));
		setCodigo_dea(StringEscapeUtils.escapeHtml(rs.getString("codigo_dea")));	
		setDireccion(StringEscapeUtils.escapeHtml(rs.getString("direccion")));
	}

	@Override
	public void guardar(Connection con) throws SQLException,
			ExcepcionValidaciones {
		
		String sql_insercion = "insert into colegio (idestado, idmunicipio, idparroquia, nombre, codigo_dea, direccion, idcreadopor) " +
													"values (?, ?, ?, ?, ?, ?, ?)";			
		PreparedStatement ps = con.prepareStatement(sql_insercion, PreparedStatement.RETURN_GENERATED_KEYS);
		
		ps.setInt(1, getIdestado());
		ps.setInt(2, getIdmunicipio());
		ps.setInt(3, getIdparroquia());
		ps.setString(4, (nombre == null ? ""  : StringEscapeUtils.unescapeHtml(nombre.toUpperCase())));
		ps.setString(5, (codigo_dea == null ? "" : StringEscapeUtils.unescapeHtml(codigo_dea.toUpperCase())));
		ps.setString(6, (direccion == null ? ""  : StringEscapeUtils.unescapeHtml(direccion.toUpperCase())));
		ps.setInt(7, getIdCreadoPor());
		ps.executeUpdate();
		
		ResultSet rs = ps.getGeneratedKeys();
		if (rs.next()) {
			setIdcolegio(rs.getInt(1));
		}					
		rs.close();
		ps.close();
	}

	@Override
	public synchronized void actualizar(Connection con) throws SQLException, ExcepcionValidaciones 
	{
		
		//Se esta actualizando un colegio previamente existente
		validarColegioUnico(con);
		
		String update = "SELECT idestado, idmunicipio, idparroquia, nombre, activo, codigo_dea, direccion, idcolegio FROM colegio where idcolegio = ?";
		PreparedStatement ps = con.prepareStatement(update, ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_UPDATABLE);
		ps.setInt(1, getID());
		ResultSet rs = ps.executeQuery();
		if (rs.next()) {									
			rs.updateInt(1, getIdestado());			
			rs.updateInt(2, getIdmunicipio());
			rs.updateInt(3, getIdparroquia());
			rs.updateString(4, nombre == null ? ""  : StringEscapeUtils.unescapeHtml(nombre.toUpperCase()));
			rs.updateBoolean(5, isActivo());
			rs.updateString(6, (codigo_dea == null ? "" : StringEscapeUtils.unescapeHtml(codigo_dea.toUpperCase())));
			rs.updateString(7, (direccion == null ? ""  : StringEscapeUtils.unescapeHtml(direccion.toUpperCase())));
			rs.updateRow();			
		}
		rs.close();
		ps.close();
	}

	@Override
	public int getID() {
		return getIdcolegio();
	}

	/** Verifica que la restriccion de integridad de codigo dea unico se mantenga 
	 * @throws SQLException 
	 * @throws ExcepcionValidaciones */
	public void validarColegioUnico (Connection con) throws SQLException, ExcepcionValidaciones 
	{
	
		String sqlSerialUnico = "select * from canaima.colegio where activo and (codigo_dea = ? or ( idestado = ? and idmunicipio = ? and idparroquia = ? and nombre = ? ) ) and idcolegio != ? " ;
		PreparedStatement ps =  null; 
		ResultSet rs = null;
		try {
			ps = con.prepareStatement(sqlSerialUnico);
			ps.setString(1, getCodigo_dea());
			ps.setInt(2, getIdestado());
			ps.setInt(3, getIdmunicipio());
			ps.setInt(4, getIdparroquia());
			ps.setString(5, getNombre());
			ps.setInt(6, getIdcolegio());
			
			rs = ps.executeQuery();
			if (rs.next()) {
				Colegio repetido = new Colegio();
				repetido.recargar(rs);
				
				if(repetido.getCodigo_dea().equals(getCodigo_dea()))
					throw new ExcepcionValidaciones(
							"El colegio 'ID = " + repetido.getID() + "' posee el mismo Codigo Dea ('" +	
							repetido.getCodigo_dea() + "') que el colegio ingresado");
				else					
					throw new ExcepcionValidaciones(
						"El colegio 'ID = " + repetido.getID() + "' posee el mismo Estado, Municipio, Parroquia que el colegio ingresado");		
			}
		}
		finally {
			if (rs != null)
				rs.close();
			if (ps != null)
				ps.close();
		}
	}
	
	public static ArrayList<Colegio> listarColegio (Connection con) throws SQLException {
		ArrayList<Colegio> resultado = new ArrayList<Colegio>();
		
		String sql = "select * from `canaima`.`colegio` order by nombre asc";
		PreparedStatement ps = null;
		ResultSet rs = null;		
		try {
			ps = con.prepareStatement(sql);
			rs = ps.executeQuery();
			Colegio colegio = null;
			while (rs.next()) {
				colegio = new Colegio();
				colegio.recargar(rs);
				resultado.add(colegio);
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
	
	public static ArrayList<Colegio> listarColegioPorNombre (Connection con, String nombre) throws SQLException {
		ArrayList<Colegio> resultado = new ArrayList<Colegio>();
		
		String sql = "select * from `canaima`.`colegio` " +
				     "where nombre like ? " +
				     "OR codigo_dea like ? and activo " +
				     "order by nombre asc LIMIT 0, 30";
		PreparedStatement ps = null;
		ResultSet rs = null;		
		try {
			ps = con.prepareStatement(sql);
			ps.setString(1, "%"+nombre+"%");
			ps.setString(2, "%"+nombre+"%");
			rs = ps.executeQuery();
			Colegio colegio = null;
			while (rs.next()) {
				colegio = new Colegio();
				colegio.recargar(rs);
				resultado.add(colegio);
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
	
	public static ArrayList<Colegio> ultimosColegios (Connection con) throws SQLException {
		
		Colegio resultado = new Colegio();
		ArrayList<Colegio> ultimosColegios = new ArrayList<Colegio>();
		String sql = "select * from `canaima`.`colegio` order by idcolegio desc limit 10";
		PreparedStatement ps = null;
		ResultSet rs = null;		
		try {
			ps = con.prepareStatement(sql);
			rs = ps.executeQuery();		
			while (rs.next()) {			
				resultado.recargar(rs);	
				ultimosColegios.add(resultado);
				resultado = new Colegio();
			}
		}
		finally {			
			if (rs != null)
				rs.close();
			if (ps != null)
				ps.close();
		}
		return ultimosColegios; 
	}
	
	public static ArrayList<Colegio> listarColegios(Connection con,
			int estado, 
			int municipio, 
			int idParroquia,
			int idColegio,
			int idColegioo 
			
		) throws SQLException, ExcepcionValidaciones {
			
			final int ESTADO = 0, MUNICIPIO = 1, IDPARROQUIA = 2, IDCOLEGIO = 3, IDCOLEGIOO = 4;		
			boolean [] parametrosPresentes = {false, false, false, false, false};
			
			if (estado > 0)
				parametrosPresentes[ESTADO] = true;
			if (municipio> 0)
				parametrosPresentes[MUNICIPIO] = true;
			if (idParroquia > 0)
				parametrosPresentes[IDPARROQUIA] = true;
			if (idColegio > 0)
				parametrosPresentes[IDCOLEGIO] = true;
			if (idColegioo > 0)
				parametrosPresentes[IDCOLEGIOO] = true;
			
			ArrayList<Colegio> resultado = new ArrayList<Colegio>();		
			int parametrosUsados = 1;
			
			//Crear el string de búsqueda
			String sqlDonatarios = 
				"select * from colegio where activo ";
			if (parametrosPresentes[ESTADO]) {
				sqlDonatarios += " and idestado = ? ";
			}
			if (parametrosPresentes[MUNICIPIO]) {
				sqlDonatarios += " and idmunicipio = ? ";
			}
			if (parametrosPresentes[IDPARROQUIA]) {
				sqlDonatarios += " and idparroquia = ?";
			}
			if (parametrosPresentes[IDCOLEGIO]) {
				sqlDonatarios += " and idcolegio = ?";
			}
			if (parametrosPresentes[IDCOLEGIOO]) {
				sqlDonatarios += " and idcolegio = ?";
			}	
						
			sqlDonatarios += " order by idcolegio, nombre";
			
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
				if (parametrosPresentes[IDPARROQUIA]) {
					ps.setInt(parametrosUsados++, idParroquia);
				}
				if (parametrosPresentes[IDCOLEGIO]) {
					ps.setInt(parametrosUsados++, idColegio);
				}
				if (parametrosPresentes[IDCOLEGIOO]) {
					ps.setInt(parametrosUsados++, idColegioo);
				}
				
				
				rs = ps.executeQuery();
				Colegio retornado = null;
				while (rs.next()) {
					retornado = new Colegio();
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
		

}
