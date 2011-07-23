
package beans;
import java.io.Serializable;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import aplicacion.ExcepcionValidaciones;

/**
 * Descripcion: Clase que representa un contrato de la base de datos 
 */
public class Contrato extends ObjetoPersistente  implements Serializable {

	private static final long serialVersionUID = 161674587549653974L;
	private int idcontrato;
	private int numero = 0;
	private String direccion = "";
	private byte [] pdf;
	private int idlote;
	

	/* (non-Javadoc)
	 * @see beans.ObjetoPersistente#validarCondiciones()
	 */
	@Override
	public ArrayList<String> validarCondiciones() {
		
		ArrayList<String> resultado = new ArrayList<String>();		
		if (idlote == 0)
			resultado.add(errorEsObligatorioModelo("Lote"));
		if (numero == 0)
			resultado.add(errorEsObligatorio("Número de Contrato"));			
		return resultado;
	}

	/* (non-Javadoc)
	 * @see beans.ObjetoPersistente#recargar(java.sql.ResultSet)
	 */
	@Override
	public void recargar(ResultSet rs) throws SQLException {
		
		setDireccion(rs.getString("direccion"));
		setIdcontrato(rs.getInt("idcontrato"));
		setNumero(rs.getInt("numero"));				
		setPdf(rs.getBytes("pdf"));
		setIdlote(rs.getInt("idlote"));
	}

	@Override
	public String toString() {
		return "Contrato [idcontrato=" + idcontrato + ", numero=" + numero
				+ ", direccion=" + direccion + "]";
	}

	/* (non-Javadoc)
	 * @see beans.ObjetoPersistente#guardar(java.sql.Connection)
	 */
	@Override
	public void guardar(Connection con) throws SQLException,
			ExcepcionValidaciones { 
		
		validarContratoUnico(con);
		
		String sql_insercion = "insert into contrato (numero, direccion, pdf, idlote) values (?, ?, ?, ?)";			
		PreparedStatement ps = con.prepareStatement(sql_insercion, PreparedStatement.RETURN_GENERATED_KEYS);
		ps.setInt(1, getNumero());
		ps.setString(2, getDireccion());		
		ps.setBytes(3, getPdf());		
		ps.setInt(4, getIdlote());
		ps.executeUpdate();
		ResultSet rs = ps.getGeneratedKeys();
		if (rs.next()) {
			setIdcontrato(rs.getInt(1));
		}					
		rs.close();
		ps.close();		
	}

	/* (non-Javadoc)
	 * @see beans.ObjetoPersistente#actualizar(java.sql.Connection)
	 */
	@Override
	public void actualizar(Connection con) throws SQLException,
			ExcepcionValidaciones {
		
		//Se esta actualizando un contrato previamente existente
		validarContratoUnico(con);
		
		String update = "SELECT numero, direccion, pdf, idlote, idcontrato FROM contrato where idcontrato = ?";
		PreparedStatement ps = con.prepareStatement(update, ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_UPDATABLE);
		ps.setInt(1, getID());
		ResultSet rs = ps.executeQuery();
		if (rs.next()) {									
			rs.updateInt(1, getNumero());			
			rs.updateString(2, getDireccion());
			rs.updateBytes(3, getPdf());
			rs.updateInt(4, getIdlote());
			rs.updateRow();			
		}
		rs.close();
		ps.close();
	}

	/* (non-Javadoc)
	 * @see beans.ObjetoPersistente#getID()
	 */
	@Override
	public int getID() {
		// TODO Auto-generated method stub
		return getIdcontrato();
	}
	
	public int getIdcontrato() {
		return idcontrato;
	}

	public void setIdcontrato(int idcontrato) {
		this.idcontrato = idcontrato;
	}

	public int getNumero() {
		return numero;
	}

	public void setNumero(int numero) {
		this.numero = numero;
	}

	public String getDireccion() {
		return direccion;
	}

	public void setDireccion(String direccion) {
		this.direccion = direccion;
	}

	public byte [] getPdf() {
		return pdf;
	}

	public void setPdf(byte [] pdf) {
		this.pdf = pdf;		
	}
	
	public int getIdlote() {
		return idlote;
	}

	public void setIdlote(int idlote) {
		this.idlote = idlote;
	}
	
	/** Obtiene el ultimo contrato registrado por el usuario 
	 * @throws SQLException */
	public static int getUltimoContratoRegistrado (Usuario actual, Connection con) throws SQLException {		
		
		String sql = " SELECT coalesce(max(c.numero), 0) FROM contrato c join donatario d on (d.idcontrato = c.idcontrato )" +
				" and d.activo and d.idcreadopor = ? order by fecha_act desc;" ;
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
	
	
	/** Obtiene el numero de contratos registrados para un lote 
	 * @throws SQLException */
	public static int getNumeroDeContratos (Connection con, int idlote) throws SQLException {		
		String sql = " select count(*) from contrato where idlote = ? " ;
		PreparedStatement ps =  null; 
		ResultSet rs = null;
		try {			
			ps = con.prepareStatement(sql);
			ps.setInt(1, idlote);		
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
	
	/** Verifica que la restriccion de integridad de serial unico se mantenga 
	 * @throws SQLException 
	 * @throws ExcepcionValidaciones */
	public void validarContratoUnico (Connection con) throws SQLException, ExcepcionValidaciones {
		
		if (getNumero() == 0)
			return;
		
		String sqlSerialUnico = "select * from contrato where numero = ? and idcontrato != ?" ;
		PreparedStatement ps =  null; 
		ResultSet rs = null;
		try {
			ps = con.prepareStatement(sqlSerialUnico);
			ps.setInt(1, getNumero());
			ps.setInt(2, getID());				
			rs = ps.executeQuery();
			if (rs.next()) {				
				throw new ExcepcionValidaciones(
						"El N&uacute;mero de Contrato fue ingresado previamente en el sistema.");
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
