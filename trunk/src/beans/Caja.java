/**
 Caja.java - 09/04/2011
 Autor: Javier Pino
 */
package beans;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import org.apache.commons.lang.StringEscapeUtils;
import enums.CAJA_TIPO;
import aplicacion.ExcepcionRoles;
import aplicacion.ExcepcionValidaciones;

/**
 * Descripción: 
 * @author Javier Pino
 */
public class Caja extends ObjetoPersistente {

	private static final long serialVersionUID = 8675300290975676028L;
	private int idcaja;
	private int idusuario;
	private int numero = 0;	
	private CAJA_TIPO tipo = CAJA_TIPO.DON;
	private boolean cerrada = false;	
	private String incidencia = null;	
	private Timestamp creacion;
	
	public int getNumero() {
		return numero;
	}

	public void setNumero(int numero) {
		this.numero = numero;
	}

	public boolean isCerrada() {
		return cerrada;
	}

	public void setCerrada(boolean cerrada) {
		this.cerrada = cerrada;
	}
  
	public CAJA_TIPO getTipo() {
		return tipo;
	}

	public void setTipo(CAJA_TIPO tipo) {
		this.tipo = tipo;
	}

	private static String [] validacion = {
		"Error en el modelo: Usuario es Obligatorio",
		"La longitud de Incidencia no puede exceder los " + TINYTEXT + "caracteres",
		"Error en el modelo: Número no puede ser cero"
	};

	/**	
	 *	@see beans.ObjetoPersistente#validarCondiciones()
	 *  @return
	 */
	@Override
	public ArrayList<String> validarCondiciones() {		
		ArrayList<String> resultado = new ArrayList<String>();		
		if (idusuario == 0) 
			resultado.add(validacion[0]);
		if (incidencia != null && incidencia.length() > TEXT)
			resultado.add(validacion[1]);
		if (numero == 0)
			resultado.add(validacion[2]);
		return resultado;
	}

	/**
	 *	@see beans.ObjetoPersistente#recargar(java.sql.ResultSet)
	 *  @param rs
	 *  @throws SQLException
	 */

	@Override
	public void recargar(ResultSet rs) throws SQLException {	
		setIdcaja(rs.getInt("idcaja"));
		setIdusuario(rs.getInt("idusuario"));		
		setCreacion(rs.getTimestamp("creacion"));
		setCerrada(rs.getBoolean("cerrada"));
		setIncidencia(StringEscapeUtils.escapeHtml(rs.getString("incidencia")));
		setNumero(rs.getInt("numero"));
		setTipo(CAJA_TIPO.valueOf(rs.getString("tipo")));
	}

	public String getIncidencia() {
		return incidencia;
	}

	public void setIncidencia(String incidencia) {
		this.incidencia = incidencia;
	}

	/**
	 *	@see beans.ObjetoPersistente#guardar(java.sql.Connection)
	 *  @param con
	 *  @throws SQLException
	 */

	@Override
	public synchronized void guardar(Connection con) throws SQLException {
		
		//Se debe asignar un nuevo numero a la caja
		asignarNuevoNumeroACaja(con, (getTipo() != null) ? getTipo() : CAJA_TIPO.DON);
		
		String sql_insercion = "insert into `canaima`.`caja` (`idusuario`, `numero`, `tipo`) values (?, ?, ?)";			
		PreparedStatement ps = con.prepareStatement(sql_insercion, PreparedStatement.RETURN_GENERATED_KEYS);
		ps.setInt(1, getIdusuario());
		ps.setInt(2, getNumero());
		ps.setString(3, (getTipo() != null) ? getTipo().toString() : CAJA_TIPO.DON.toString());
		ps.executeUpdate();
		ResultSet rs = ps.getGeneratedKeys();
		if (rs.next()) {
			setIdcaja(rs.getInt(1));
		}					
		rs.close();
		ps.close();
	}

	/**
	 *	@see beans.ObjetoPersistente#actualizar(java.sql.Connection)
	 *  @param con
	 *  @throws SQLException
	 */

	@Override
	public void actualizar(Connection con) throws SQLException {
		
		//Se esta actualizando un evento previamente existente
		String update = "SELECT * FROM `canaima`.`caja` where idcaja = ?";
		PreparedStatement ps = con.prepareStatement(update, ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_UPDATABLE);
		ps.setInt(1, getIdcaja());
		ResultSet rs = ps.executeQuery();
		if (rs.next()) {		
			rs.updateInt("idusuario", getIdusuario());			
			rs.updateBoolean("cerrada", isCerrada());
			rs.updateString("incidencia", (incidencia == null ? "" : StringEscapeUtils.unescapeHtml(incidencia.toUpperCase())));
			rs.updateString("tipo", (getTipo() != null) ? getTipo().toString() : CAJA_TIPO.DON.toString());
			rs.updateRow();
		}
		rs.close();
		ps.close();
	}

	/**
	 * @return the idcaja
	 */
	public int getIdcaja() {
		return idcaja;
	}

	/**
	 * @param idcaja el idcaja a modificar
	 */
	public void setIdcaja(int idcaja) {
		this.idcaja = idcaja;
	}

	/**
	 * @return the idusuario
	 */
	public int getIdusuario() {
		return idusuario;
	}

	/**
	 * @param idusuario el idusuario a modificar
	 */
	public void setIdusuario(int idusuario) {
		this.idusuario = idusuario;
	}

	/**
	 * @return the creacion
	 */
	public Timestamp getCreacion() {
		return creacion;
	}

	/**
	 * @param creacion el creacion a modificar
	 */
	public void setCreacion(Timestamp creacion) {
		this.creacion = creacion;
	}

	@Override
	public String toString() {
		return "Caja [idcaja=" + idcaja + ", idusuario=" + idusuario
				+ ", numero=" + numero + ", tipo=" + tipo + ", cerrada="
				+ cerrada + ", incidencia=" + incidencia + ", creacion="
				+ creacion + "]";
	}

	@Override
	public int getID() {
		return getIdcaja();
	}
	
	/** Asigna el numero que corresponde a la caja automaticamente 
	 * @throws SQLException */
	public void asignarNuevoNumeroACaja(Connection con, CAJA_TIPO caja) throws SQLException {		
		PreparedStatement ps = null;
		ResultSet rs = null;
		try {			
			String sqlMaxCaja = 
				"select coalesce(max(numero) + 1, 1) as NUMERO from `canaima`.`caja` " +
				" where tipo = ? ";
			ps = con.prepareStatement(sqlMaxCaja);
			ps.setString(1, (caja != null) ? caja.toString() : CAJA_TIPO.DON.toString());
			rs = ps.executeQuery();
			rs.next();
			setNumero(rs.getInt("NUMERO"));		
		} finally {
			if (rs != null)
				rs.close();
			if (ps != null)
				ps.close();
		}
	}
	
	/** Método para cerrar cajas 
	 * @throws ExcepcionRoles 
	 * @throws ExcepcionValidaciones 
	 * @throws SQLException */	
	public void cerrarCaja(Connection con ) throws ExcepcionRoles, ExcepcionValidaciones, SQLException {		
			
		if (getIncidencia() == null)
			throw new ExcepcionValidaciones("Para cerrar una caja, Incidencia es obligatoria");		
		setCerrada(true);
		actualizar(con);		
	}
	
	/** Obtiene la ultimo caja registrada por el usuario 
	 * @throws SQLException 
	 * @throws ExcepcionValidaciones
	 */
	public static int getUltimaCajaRegistrada (Connection con, Usuario actual, CAJA_TIPO tipo) 
		throws SQLException, ExcepcionValidaciones {				
		
		String sql = " select coalesce(max(c.idcaja),0) from caja c where not c.cerrada and idusuario = ? and tipo = ?" ;
		PreparedStatement ps =  null; 
		ResultSet rs = null;
		try {
			ps = con.prepareStatement(sql);
			ps.setInt(1, actual.getID());
			ps.setString(2, (tipo != null) ? tipo.toString() : CAJA_TIPO.DON.toString());					
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
}