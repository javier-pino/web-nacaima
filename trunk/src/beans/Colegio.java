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
	private boolean activo;
	
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
			resultado.add(errorEsObligatorioModelo("Estado"));
		if (idmunicipio == 0)
			resultado.add(errorEsObligatorioModelo("Municipio"));
		
		if (nombre == null)
			resultado.add(errorEsObligatorioModelo("Nombre"));
		
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
		setNombre(rs.getString("nombre"));
		setActivo(rs.getBoolean("activo"));
		setCodigo_dea(rs.getString("codigo_dea"));	
	}

	@Override
	public void guardar(Connection con) throws SQLException,
			ExcepcionValidaciones {
		
		String sql_insercion = "insert into colegio (idestado, idmunicipio, idparroquia, nombre, codigo_dea) values (?, ?, ?, ?, ?)";			
		PreparedStatement ps = con.prepareStatement(sql_insercion, PreparedStatement.RETURN_GENERATED_KEYS);
		
		ps.setInt(1, getIdestado());
		ps.setInt(2, getIdmunicipio());
		ps.setInt(3, getIdparroquia());
		ps.setString(4, (nombre == null ? ""  : StringEscapeUtils.unescapeHtml(nombre.toUpperCase())));
		ps.setString(5, (codigo_dea == null ? "" : StringEscapeUtils.unescapeHtml(codigo_dea.toUpperCase())));
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
		
		String update = "SELECT idestado, idmunicipio, idparroquia, nombre, activo, codigo_dea FROM colegio where idcolegio = ?";
		PreparedStatement ps = con.prepareStatement(update, ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_UPDATABLE);
		ps.setInt(1, getID());
		ResultSet rs = ps.executeQuery();
		if (rs.next()) {									
			rs.updateInt(1, getIdestado());			
			rs.updateInt(2, getIdmunicipio());
			rs.updateInt(3, getIdparroquia());
			rs.updateString(4, getNombre());
			rs.updateBoolean(5, isActivo());
			rs.updateString(6, getCodigo_dea());
			rs.updateRow();			
		}
		rs.close();
		ps.close();
	}

	@Override
	public int getID() {
		return getIdmunicipio();
	}

	/** Verifica que la restriccion de integridad de codigo dea unico se mantenga 
	 * @throws SQLException 
	 * @throws ExcepcionValidaciones */
	public void validarColegioUnico (Connection con) throws SQLException, ExcepcionValidaciones 
	{
		
		if (getIdcolegio() == 0)
			return;
		
		String sqlSerialUnico = "select * from canaima.colegio where activo and (codigo_dea = ? or ( idestado = ? and idmunicipio = ? and idparroquia = ? ) ) and nombre = ? and idcolegio != ? " ;
		PreparedStatement ps =  null; 
		ResultSet rs = null;
		try {
			ps = con.prepareStatement(sqlSerialUnico);
			ps.setString(1, getCodigo_dea());
			ps.setInt(2, getIdestado());
			ps.setInt(3, getIdmunicipio());
			ps.setInt(4, getIdparroquia());
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
}
