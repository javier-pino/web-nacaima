package beans;
import java.io.Serializable;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import org.apache.commons.lang.StringEscapeUtils;

import aplicacion.ExcepcionValidaciones;

public class Parroquia extends ObjetoPersistente implements Serializable {

	private static final long serialVersionUID = 3545122695604484995L;
	private int idparroquia;
	 private int idmunicipio;
	 private String nombre;
	 private boolean activo;
	 

	@Override
	public String toString() {
		return "Parroquia [idparroquia=" + idparroquia + ", idmunicipio="
				+ idmunicipio + ", nombre=" + nombre + ", activo=" + activo
				+ "]";
	}

	public int getIdparroquia() {
		return idparroquia;
	}

	public void setIdparroquia(int idparroquia) {
		this.idparroquia = idparroquia;
	}

	public int getIdmunicipio() {
		return idmunicipio;
	}

	public void setIdmunicipio(int idmunicipio) {
		this.idmunicipio = idmunicipio;
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

	@Override
	public ArrayList<String> validarCondiciones() {		
		
		ArrayList<String> resultado = new ArrayList<String>();				
		if (idmunicipio == 0) {
			resultado.add(errorEsObligatorioModelo("Municipio"));
		}
		if (nombre == null || nombre.isEmpty()) {
			resultado.add(errorEsObligatorio("Nombre"));			
		} else {
			if (nombre.length() > TINYTEXT) {
				resultado.add(errorTamaño("Nombre", TINYTEXT));
			}
		}
		return resultado;
	}

	@Override
	public void recargar(ResultSet rs) throws SQLException {
		setIdparroquia(rs.getInt("idparroquia"));
		setIdmunicipio(rs.getInt("idmunicipio"));
		setNombre(rs.getString("nombre"));
		setActivo(rs.getBoolean("activo"));
	}

	@Override
	public void guardar(Connection con) throws SQLException,
			ExcepcionValidaciones {
		
		String sql_insercion = "insert into parroquia (idmunicipio, nombre) values (?, ?)";			
		PreparedStatement ps = con.prepareStatement(sql_insercion, PreparedStatement.RETURN_GENERATED_KEYS);
		ps.setInt(1, getIdmunicipio());
		ps.setString(2, (getNombre() == null ? ""  : StringEscapeUtils.unescapeHtml(getNombre().toUpperCase())));				
		ps.executeUpdate();
		ResultSet rs = ps.getGeneratedKeys();
		if (rs.next()) {
			setIdparroquia(rs.getInt(1));
		}					
		rs.close();
		ps.close();
	}

	@Override
	public void actualizar(Connection con) throws SQLException,
			ExcepcionValidaciones {
		// No se realizarán actualizaciones
	}

	@Override
	public int getID() {
		return getIdparroquia();
	}
	
public static ArrayList<Parroquia> listarParroquiasPorMunicipios (int idestado, Connection con) throws SQLException {
		
		ArrayList<Parroquia> resultado = new ArrayList<Parroquia>();		
		String sql = "select * from `canaima`.`parroquia` where activo and idmunicipio = ? order by nombre asc";
		PreparedStatement ps = null;
		ResultSet rs = null;		
		try {
			ps = con.prepareStatement(sql);
			ps.setInt(1, idestado);
			rs = ps.executeQuery();
			Parroquia parroquia = null;
			while (rs.next()) {
				parroquia = new Parroquia();
				parroquia.recargar(rs);
				resultado.add(parroquia);
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
