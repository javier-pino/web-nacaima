package beans;

import java.io.Serializable;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

public class Estado extends ObjetoPersistente implements Serializable {	
	
	private static final long serialVersionUID = 4741376024336750387L;

	private int idestado;
	private String nombre;
	private boolean activo;
	
	public int getIdestado() {
		return idestado;
	}

	public void setIdestado(int idestado) {
		this.idestado = idestado;
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

	/**	
	 *	@see beans.ObjetoPersistente#validarCondiciones()
	 *  @return
	 */
	@Override
	public ArrayList<String> validarCondiciones() {		
		
		ArrayList<String> resultado = new ArrayList<String>();		
		
		if (nombre != null && nombre.length() > TINYTEXT)
			resultado.add(errorTamaño("Nombre", TINYTEXT));
				return resultado;			
	}

	@Override
	public void recargar(ResultSet rs) throws SQLException {
		setIdestado(rs.getInt("idestado"));
		setNombre(rs.getString("nombre"));
		setActivo(rs.getBoolean("activo"));		
	}

	@Override
	public void guardar(Connection con) throws SQLException {
		//No guardaremos estados por los momentos
	}

	@Override
	public void actualizar(Connection con) throws SQLException {
		//No guardaremos estados por los momentos
	}

	@Override
	public int getID() {
		return getIdestado();
	}

	/** Retorna todos los estados disponibles
	 *  
	 * @throws SQLException */
	public static ArrayList<Estado> listarEstados (Connection con) throws SQLException {
		ArrayList<Estado> resultado = new ArrayList<Estado>();
		
		String sql = "select * from `canaima`.`estado` order by nombre asc";
		PreparedStatement ps = null;
		ResultSet rs = null;		
		try {
			ps = con.prepareStatement(sql);
			rs = ps.executeQuery();
			Estado estado = null;
			while (rs.next()) {
				estado = new Estado();
				estado.recargar(rs);
				resultado.add(estado);
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
	
	public Estado buscarEstado (Connection con) throws SQLException
	{
		Estado estado = null;
		String sql = "select * from `canaima`.`estado` where idestado = ?";
		PreparedStatement ps = null;
		ResultSet rs = null;		
		try {
			ps = con.prepareStatement(sql);
			ps.setInt(1,getID());
			rs = ps.executeQuery();
			while (rs.next()) {
				estado = new Estado();
				estado.recargar(rs);
			}
		}
		finally {			
			if (rs != null)
				rs.close();
			if (ps != null)
				ps.close();
		}
		return estado;
	}
}

 