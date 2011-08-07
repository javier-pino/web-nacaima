package beans;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import org.apache.commons.lang.StringEscapeUtils;

import aplicacion.ExcepcionValidaciones;

public class Equipo extends ObjetoPersistente {

	private static final long serialVersionUID = -8033463617554196864L;
	
	private int idequipo;
	private String serial;
	private int iddocente;
	private int iddonatario;
	private boolean activo;
	private Timestamp fecha_carga;
		
	private static final int TAM_SERIAL = 20;
	
	@Override
	public ArrayList<String> validarCondiciones() {
		ArrayList<String> validaciones = new ArrayList<String>();
		if (iddonatario == 0 && iddocente == 0) {
			validaciones.add(errorEsObligatorioModelo("Donatario' o 'Docente"));			
		}
		if (serial == null || serial.isEmpty()) {
			validaciones.add(errorEsObligatorio("Serial Equipo"));
		}
		if (serial != null && serial.length() > TAM_SERIAL)
			validaciones.add(errorTamaño("Serial Equipo", TAM_SERIAL));
		return validaciones;
	}
	
	public int getIdequipo() {
		return idequipo;
	}

	public void setIdequipo(int idequipo) {
		this.idequipo = idequipo;
	}

	public String getSerial() {
		return serial;
	}

	public void setSerial(String serial) {
		this.serial = serial;
	}

	public int getIddocente() {
		return iddocente;
	}

	public void setIddocente(int iddocente) {
		this.iddocente = iddocente;
	}

	public int getIddonatario() {
		return iddonatario;
	}

	public void setIddonatario(int iddonatario) {
		this.iddonatario = iddonatario;
	}

	public boolean isActivo() {
		return activo;
	}

	public void setActivo(boolean activo) {
		this.activo = activo;
	}

	public Timestamp getFecha_carga() {
		return fecha_carga;
	}

	public void setFecha_carga(Timestamp fecha_carga) {
		this.fecha_carga = fecha_carga;
	}


	@Override
	public void recargar(ResultSet rs) throws SQLException {
		iddocente = rs.getInt("iddocente");
		iddonatario = rs.getInt("iddonatario");
		fecha_carga = rs.getTimestamp("fecha_carga");
		activo = rs.getBoolean("activo");		
		serial = StringEscapeUtils.escapeHtml(rs.getString("serial"));
		idequipo = rs.getInt("idequipo");
	}

	@Override
	public void guardar(Connection con) throws SQLException, ExcepcionValidaciones {
		
		validarSerialUnico(con);
		
		String sql_insercion = "insert into `canaima`.`equipo` (`serial`, `iddocente`, `iddonatario` ) values (?, ?, ? ) ";			
		PreparedStatement ps = con.prepareStatement(sql_insercion, PreparedStatement.RETURN_GENERATED_KEYS);
		ps.setString(1, (serial == null ? ""  : StringEscapeUtils.unescapeHtml(serial.toUpperCase())));
		ps.setInt(2, iddocente);
		ps.setInt(3, iddonatario);		 
		ps.executeUpdate();
		ResultSet rs = ps.getGeneratedKeys();
		if (rs.next()) {
			setIdequipo(rs.getInt(1));
		}				
		rs.close();
		ps.close();
	}

	@Override
	public String toString() {
		return "Equipo [idequipo=" + idequipo + ", serial=" + serial
				+ ", iddocente=" + iddocente + ", iddonatario=" + iddonatario
				+ ", activo=" + activo + ", fecha_carga=" + fecha_carga + "]";
	}

	@Override
	public void actualizar(Connection con) throws SQLException, ExcepcionValidaciones {
		
		validarSerialUnico(con);
		
		String update = "SELECT `iddocente`, `iddonatario`, `activo`, `serial`,`idequipo` FROM `canaima`.`equipo` where idequipo = ?";
		PreparedStatement ps = con.prepareStatement(update, ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_UPDATABLE);
		ps.setInt(1, getID());
		ResultSet rs = ps.executeQuery();
		if (rs.next()) {		
			rs.updateInt(1, iddocente);
			rs.updateInt(2, iddonatario);			
			rs.updateBoolean(3, activo);
			rs.updateString(4, (serial == null ? ""  : StringEscapeUtils.unescapeHtml(serial.toUpperCase())));
			rs.updateRow();
		}
		rs.close();
		ps.close();
	}

	@Override
	public int getID() {
		return getIdequipo();
	}
	
	/** Verifica que la restriccion de integridad de serial unico se mantenga 
	 * @throws SQLException 
	 * @throws ExcepcionValidaciones */
	public void validarSerialUnico (Connection con) throws SQLException, ExcepcionValidaciones {
		
		if (serial == null || serial.isEmpty())
			return;
		
		String sqlSerialUnico = "select * from canaima.equipo where activo and serial = ? and idequipo != ? " ;
		PreparedStatement ps =  null; 
		ResultSet rs = null;
		try {
			ps = con.prepareStatement(sqlSerialUnico);
			ps.setString(1, serial);
			ps.setInt(2, idequipo);
			rs = ps.executeQuery();
			if (rs.next()) {
				if (rs.getInt("iddonatario") > 0){
					throw new ExcepcionValidaciones(
							"El Donatario 'ID = " + rs.getInt("iddonatario") + "' posee el mismo Serial de Equipo ('" +	
							serial + "') que el ingresado )");
				} else if (rs.getInt("iddocente") > 0) {
					throw new ExcepcionValidaciones(
							"El Docente 'ID = " + rs.getInt("iddocente") + "' posee el mismo Serial de Equipo ('" +	
							serial + "') que el ingresado )");
				} else {
					throw new SQLException("No es posible realizar la operación, informe a los desarrolladores");
				}				
			}
		}
		finally {
			if (rs != null)
				rs.close();
			if (ps != null)
				ps.close();
		}
	}
}