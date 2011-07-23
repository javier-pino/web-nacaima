/**
 Usuario.java - 04/04/2011
 Autor: Javier Pino
 */
package beans;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import aplicacion.ExcepcionValidaciones;
import enums.ROL_USUARIO;

/**
 * Descripción: 
 * @author Javier Pino
 */
public class Usuario extends ObjetoPersistente {

	private static final long serialVersionUID = 5157939048257074413L;

	//Campos del objeto persistente
	private int idusuario;
	private String usuario = null;
	private String nombre = null;
	private String contrasena = null;
	private ROL_USUARIO rol;
	private boolean activo = true;
	
	public boolean isActivo() {
		return activo;
	}

	public void setActivo(boolean activo) {
		this.activo = activo;
	}

	private static final int TAM_USUARIO = 10;
	private static final int TAM_CONTRASENA = 10;
	
	
	private static final String [] validaciones = {
		"Rol es obligatorio",
		"Usuario es obligatorio",
		"La longitud de Usuario no puede exceder los " + TAM_USUARIO + " caracteres",
		"Contraseña es obligatorio",
		"La longitud de Contraseña no puede exceder los " + TAM_CONTRASENA + " caracteres",
		"Nombre de Usuario es obligatorio",
		"La longitud de Nombre de Usuario no puede exceder los " + TINYTEXT + " caracteres"
	};
	
	/**
	 *	@see beans.ObjetoPersistente#validarCondiciones()
	 *  @return
	 */
	@Override
	public ArrayList<String> validarCondiciones() {
		ArrayList<String> validacionesIncumplidas = new ArrayList<String>(); 
		if (rol == null )
			validacionesIncumplidas.add(validaciones[0]);
		if (usuario == null || usuario.isEmpty()) {
			validacionesIncumplidas.add(validaciones[1]);
		} else {
			if (usuario.length() > TAM_USUARIO)
				validacionesIncumplidas.add(validaciones[2]);
		}
		if (nombre == null || nombre.isEmpty()) {
			validacionesIncumplidas.add(validaciones[5]);
		} else {
			if (nombre.length() > TINYTEXT)
				validacionesIncumplidas.add(validaciones[6]);
		}		
		if (contrasena == null || contrasena.isEmpty()) 
			validacionesIncumplidas.add(validaciones[3]);
		else {
			if (contrasena.length() > TAM_CONTRASENA)
				validacionesIncumplidas.add(validaciones[4]);
		}		
		return validacionesIncumplidas;
	}

	/**
	 *	@see beans.ObjetoPersistente#recargar(java.sql.ResultSet)
	 *  @param rs
	 *  @throws SQLException
	 */
	@Override
	public void recargar(ResultSet rs) throws SQLException {		
		setIdusuario(rs.getInt("idusuario"));
		setRol(ROL_USUARIO.valueOf(rs.getString("rol")));	
		setUsuario(rs.getString("usuario"));
		setNombre(rs.getString("nombre"));
		setContrasena(rs.getString("contrasena"));
		setActivo(rs.getBoolean("activo"));
	}
	
	/**
	 * @return the rol
	 */
	public ROL_USUARIO getRol() {
		return rol;
	}

	/**
	 * @param rol el rol a modificar
	 */
	public void setRol(ROL_USUARIO rol) {
		this.rol = rol;
	}

	/**
	 * @return the usuario
	 */
	public String getUsuario() {
		return usuario;
	}

	/**
	 * @param usuario el usuario a modificar
	 */
	public void setUsuario(String usuario) {
		this.usuario = usuario;
	}

	/**
	 * @return the nombre
	 */
	public String getNombre() {
		return nombre;
	}

	/**
	 * @param nombre el nombre a modificar
	 */
	public void setNombre(String nombre) {
		this.nombre = nombre;
	}

	/**
	 * @return the contrasena
	 */
	public String getContrasena() {
		return contrasena;
	}

	/**
	 * @param contrasena el contrasena a modificar
	 */
	public void setContrasena(String contrasena) {
		this.contrasena = contrasena;
	}

	public int getIdusuario() {
		return idusuario;
	}

	public void setIdusuario(int idusuario) {
		this.idusuario = idusuario;
	}

	@Override
	public synchronized void guardar(Connection con) throws SQLException, ExcepcionValidaciones {
		
		//Se esta creando un objeto
		validarLoginUnico(con);
		
		String sql_insercion = "insert into `canaima`.`usuario` " +
				" (usuario, nombre, contrasena, rol) VALUES (?, ?, ?, ?)" ;			
		PreparedStatement ps = con.prepareStatement(sql_insercion, PreparedStatement.RETURN_GENERATED_KEYS);
		ps.setString(1, getUsuario().toLowerCase());
		ps.setString(2, getNombre().toUpperCase());
		ps.setString(3, getContrasena());
		ps.setString(4, getRol().toString());
		ps.executeUpdate();
		ResultSet rs = ps.getGeneratedKeys();
		if (rs.next()) {
			setIdusuario(rs.getInt(1));
		}			
		rs.close();
		ps.close();
	}
	
	@Override
	public synchronized void actualizar(Connection con) throws SQLException, ExcepcionValidaciones {
		
		//Se esta actualizando un objeto previamente existente
		validarLoginUnico(con);
		
		String update = "SELECT * FROM `canaima`.`usuario` where idusuario = ?";
		PreparedStatement ps = con.prepareStatement(update, ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_UPDATABLE);
		ps.setInt(1, getIdusuario());
		ResultSet rs = ps.executeQuery();
		if (rs.next()) {		
			rs.updateInt("idusuario", getIdusuario());
			rs.updateString("usuario", getUsuario().toLowerCase());
			rs.updateString("nombre", getNombre().toUpperCase());			
			rs.updateString("contrasena", getContrasena());
			rs.updateString("rol", getRol().toString());
			rs.updateBoolean("activo", isActivo());
			rs.updateRow();
		}
		rs.close();
		ps.close();
		
	}

	@Override
	public String toString() {
		return "Usuario [idusuario=" + idusuario + ", usuario=" + usuario
				+ ", nombre=" + nombre + ", contrasena=" + contrasena
				+ ", rol=" + rol + ", activo=" + activo + "]";
	}

	@Override
	public int getID() {		
		return getIdusuario();
	}
	
	/** Valida que un usuario no se ingrese incorrectamente en la base de datos 
	 * repitiendo un login 
	 * @throws SQLException 
	 * @throws ExcepcionValidaciones */
	public void validarLoginUnico (Connection con) throws SQLException, ExcepcionValidaciones {
		
		String sqlUsuarioUnico = "select count(*) from `canaima`.`usuario` where usuario = ? and idusuario != ?";
		PreparedStatement ps = null;
		ResultSet rs = null;
		try {
			ps = con.prepareStatement(sqlUsuarioUnico);
			ps.setString(1, getUsuario());
			ps.setInt(2, getIdusuario());
			rs = ps.executeQuery();
			rs.next();
			if (rs.getInt(1) > 0)
				throw new ExcepcionValidaciones("Existe en el sistema un usuario con ese Login");		
		} finally {
			if (rs != null)
				rs.close();
			if (ps != null)
				ps.close();
		}		
	}
	
	/** Retorna todos los estados disponibles
	 *  
	 * @throws SQLException */
	public static ArrayList<Usuario> listarUsuarios (Connection con) throws SQLException {
		
		ArrayList<Usuario> resultado = new ArrayList<Usuario>();
		
		String sql = "select * from `canaima`.`usuario` order by nombre asc";
		PreparedStatement ps = null;
		ResultSet rs = null;		
		try {
			ps = con.prepareStatement(sql);
			rs = ps.executeQuery();
			Usuario usuario = null;
			while (rs.next()) {
				usuario = new Usuario();
				usuario.recargar(rs);
				resultado.add(usuario);
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

/** Retorna el ultimo usuario registrado
 *  
 * @throws SQLException */
public static Usuario ultimoRegistrado (Connection con) throws SQLException {
	
	Usuario resultado = new Usuario();
	
	String sql = "select * from `canaima`.`usuario` order by idusuario desc";
	PreparedStatement ps = null;
	ResultSet rs = null;		
	try {
		ps = con.prepareStatement(sql);
		rs = ps.executeQuery();		
		if (rs.next()) {			
			resultado.recargar(rs);			
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