package beans;

import java.io.Serializable;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

public class Municipio extends ObjetoPersistente implements Serializable {	
	
	private static final long serialVersionUID = 5354105797776725572L;
	private int idmunicipio;
	private String nombre;
	private int idestado;
	private boolean activo;
	private static final int TAM_NOMBRE = 45;
	
	public int getIdestado() {
		return idestado;
	}

	public void setIdestado(int idestado) {
		this.idestado = idestado;
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
	
	public int getIdmunicipio() {
		return idmunicipio;
	}

	public void setIdmunicipio(int idmunicipio) {
		this.idmunicipio = idmunicipio;
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
		if (nombre != null && nombre.length() > TAM_NOMBRE)
			resultado.add(errorTamaño("Nombre", TAM_NOMBRE));
		return resultado;			
	}

	@Override
	public void recargar(ResultSet rs) throws SQLException {
		setIdestado(rs.getInt("idestado"));
		setIdmunicipio(rs.getInt("idmunicipio"));
		setNombre(rs.getString("nombre"));
		setActivo(rs.getBoolean("activo"));		
	}

	@Override
	public void guardar(Connection con) throws SQLException {
		//No guardaremos municipios por los momentos
	}

	@Override
	public void actualizar(Connection con) throws SQLException {
		//No guardaremos municipios por los momentos
	}

	@Override
	public int getID() {
		return getIdmunicipio();
	}

	/** Retorna todos los municipios disponibles
	 * @throws SQLException */
	public static ArrayList<Municipio> listarMunicipios (Connection con, String idEstado) throws SQLException {
		ArrayList<Municipio> resultado = new ArrayList<Municipio>();
		System.out.print("LLEGOOOOO");
		String sql = "select * from `canaima`.`municipio` where idestado = "+idEstado+" order by nombre asc";
		PreparedStatement ps = null;
		ResultSet rs = null;		
		try {
			ps = con.prepareStatement(sql);
			rs = ps.executeQuery();
			Municipio municipio = null;
			while (rs.next()) {
				municipio = new Municipio();
				municipio.recargar(rs);
				resultado.add(municipio);
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
	
	/** Retorna todos los municipios disponibles de un estado  
	 * @throws SQLException */
	public static ArrayList<Municipio> listarMunicipiosPorEstado (int idestado, Connection con) throws SQLException {
		
		ArrayList<Municipio> resultado = new ArrayList<Municipio>();		
		String sql = "select * from `canaima`.`municipio` where activo and idestado = ? order by nombre asc";
		PreparedStatement ps = null;
		ResultSet rs = null;		
		try {
			ps = con.prepareStatement(sql);
			ps.setInt(1, idestado);
			rs = ps.executeQuery();
			Municipio municipio = null;
			while (rs.next()) {
				municipio = new Municipio();
				municipio.recargar(rs);
				resultado.add(municipio);
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
 