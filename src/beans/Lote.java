package beans;

import java.io.Serializable;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import aplicacion.ExcepcionValidaciones;

public class Lote extends ObjetoPersistente  implements Serializable {

	private static final long serialVersionUID = -4086982825506620641L;	  
	private int idlote;
	private int idcaja;
	private int numero;
	
	public int getIdlote() {
		return idlote;
	}

	public void setIdlote(int idlote) {
		this.idlote = idlote;
	}

	public int getIdcaja() {
		return idcaja;
	}

	public void setIdcaja(int idcaja) {
		this.idcaja = idcaja;
	}

	public int getNumero() {
		return numero;
	}

	public void setNumero(int numero) {
		this.numero = numero;
	}

	@Override
	public ArrayList<String> validarCondiciones() {
		ArrayList<String> resultado = new ArrayList<String>();		
		if (idcaja == 0)
			resultado.add(errorEsObligatorioModelo("Caja"));		
		if (numero == 0)
			resultado.add(errorEsObligatorio("Número de Caja"));			
		return resultado;		
	}

	@Override
	public void recargar(ResultSet rs) throws SQLException {
		setIdcaja(rs.getInt("idcaja"));
		setIdlote(rs.getInt("idlote"));
		setNumero(rs.getInt("numero"));
	}

	@Override
	public void guardar(Connection con) throws SQLException,
			ExcepcionValidaciones {
		
		String sql_insercion = "insert into lote (idcaja, numero) values (?, ?)";			
		PreparedStatement ps = con.prepareStatement(sql_insercion, PreparedStatement.RETURN_GENERATED_KEYS);
		ps.setInt(1, getIdcaja());
		ps.setInt(2, getNumero());		
		ps.executeUpdate();
		ResultSet rs = ps.getGeneratedKeys();
		if (rs.next()) {
			setIdlote(rs.getInt(1));
		}					
		rs.close();
		ps.close();
		

	}

	@Override
	public String toString() {
		return "Lote [idlote=" + idlote + ", idcaja=" + idcaja + ", numero="
				+ numero + "]";
	}

	@Override
	public void actualizar(Connection con) throws SQLException,
			ExcepcionValidaciones {
		
		
	}

	@Override
	public int getID() {
		return getIdlote();
	}

	
	/** Obtiene el lote actual registrado por el usuario 
	 * @throws SQLException */
	public static int getLoteActual (Connection con, int idcaja) throws SQLException {		
		String sql = " select coalesce(max(idlote), 0) from lote where idcaja = ? " ;
		PreparedStatement ps =  null; 
		ResultSet rs = null;
		try {			
			ps = con.prepareStatement(sql);
			ps.setInt(1, idcaja);		
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
	
	/** Obtiene el lote actual registrado por el usuario 
	 * @throws SQLException */
	public static int getNumeroDeLotes (Connection con, int idcaja) throws SQLException {		
		String sql = " select count(*) from lote where idcaja = ? " ;
		PreparedStatement ps =  null; 
		ResultSet rs = null;
		try {			
			ps = con.prepareStatement(sql);
			ps.setInt(1, idcaja);		
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
	
	/** Asigna el numero que corresponde a la caja automaticamente 
	 * @throws SQLException */
	public void asignarNuevoNumeroALote(Connection con, int idcaja) throws SQLException {		
		PreparedStatement ps = null;
		ResultSet rs = null;
		try {			
			String sqlMaxCaja = "select coalesce(max(numero) + 1, 1) from lote where idcaja = ?";
			ps = con.prepareStatement(sqlMaxCaja);
			ps.setInt(1, idcaja);
			rs = ps.executeQuery();
			rs.next();
			setNumero(rs.getInt(1));		
		} finally {
			if (rs != null)
				rs.close();
			if (ps != null)
				ps.close();
		}
	}
}
