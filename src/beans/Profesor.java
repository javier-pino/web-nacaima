package beans;

import java.sql.Connection;
import java.sql.Date;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;

import enums.NACIONALIDAD;

import aplicacion.ExcepcionValidaciones;

public class Profesor extends ObjetoPersistente {

	//Identificacion del profesor
	private int idprofesor;
	private int idcreadopor;
	private NACIONALIDAD nacionalidad;
	private String cedula;
	private String nombre;
	
	//Direccion del profesor
	private int idestado;
	private int idmunicipio;	
	private int idparroquia;	
	private int idcolegio;
	private String ciudad;
	
	//Fechas
	private Date fecha_entrega;  
	private Date fecha_llegada;
	private Timestamp fecha_carga;
	 
	
	//Datos del contrato	
	private int numero = 0;
	private String direccion = "";
	private byte [] pdf;
	private int nro_equipos = 0;	
	private String observacion;
	private String proveedor;
	
	public int getIdprofesor() {
		return idprofesor;
	}

	public void setIdprofesor(int idprofesor) {
		this.idprofesor = idprofesor;
	}

	public int getIdcreadopor() {
		return idcreadopor;
	}

	public void setIdcreadopor(int idcreadopor) {
		this.idcreadopor = idcreadopor;
	}

	public NACIONALIDAD getNacionalidad() {
		return nacionalidad;
	}

	public void setNacionalidad(NACIONALIDAD nacionalidad) {
		this.nacionalidad = nacionalidad;
	}

	public String getCedula() {
		return cedula;
	}

	public void setCedula(String cedula) {
		this.cedula = cedula;
	}

	public String getNombre() {
		return nombre;
	}

	public void setNombre(String nombre) {
		this.nombre = nombre;
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

	public int getIdparroquia() {
		return idparroquia;
	}

	public void setIdparroquia(int idparroquia) {
		this.idparroquia = idparroquia;
	}

	public int getIdcolegio() {
		return idcolegio;
	}

	public void setIdcolegio(int idcolegio) {
		this.idcolegio = idcolegio;
	}

	public String getCiudad() {
		return ciudad;
	}

	public void setCiudad(String ciudad) {
		this.ciudad = ciudad;
	}

	public Date getFecha_entrega() {
		return fecha_entrega;
	}

	public void setFecha_entrega(Date fecha_entrega) {
		this.fecha_entrega = fecha_entrega;
	}

	public Date getFecha_llegada() {
		return fecha_llegada;
	}

	public void setFecha_llegada(Date fecha_llegada) {
		this.fecha_llegada = fecha_llegada;
	}

	public Timestamp getFecha_carga() {
		return fecha_carga;
	}

	public void setFecha_carga(Timestamp fecha_carga) {
		this.fecha_carga = fecha_carga;
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

	public byte[] getPdf() {
		return pdf;
	}

	public void setPdf(byte[] pdf) {
		this.pdf = pdf;
	}

	public int getNro_equipos() {
		return nro_equipos;
	}

	public void setNro_equipos(int nro_equipos) {
		this.nro_equipos = nro_equipos;
	}

	public String getObservacion() {
		return observacion;
	}

	public void setObservacion(String observacion) {
		this.observacion = observacion;
	}

	public String getProveedor() {
		return proveedor;
	}

	public void setProveedor(String proveedor) {
		this.proveedor = proveedor;
	}

	public boolean isActivo() {
		return activo;
	}

	public void setActivo(boolean activo) {
		this.activo = activo;
	}

	private boolean activo = true;
	
	private static final long serialVersionUID = -7896956557589201232L;

	@Override
	public ArrayList<String> validarCondiciones() {
		ArrayList<String> resultado = new ArrayList<String>();		
		if (idcreadopor == 0)
			resultado.add(errorEsObligatorioModelo("Creado Por"));
		if (nombre != null && nombre.length() > TINYTEXT)
			resultado.add(errorTamaño("Nombre", TINYTEXT));
		
		return null;
	}

	@Override
	public void recargar(ResultSet rs) throws SQLException {
		// TODO Auto-generated method stub

	}

	@Override
	public void guardar(Connection con) throws SQLException,
			ExcepcionValidaciones {
		// TODO Auto-generated method stub

	}

	@Override
	public void actualizar(Connection con) throws SQLException,
			ExcepcionValidaciones {
		// TODO Auto-generated method stub

	}

	@Override
	public int getID() {
		// TODO Auto-generated method stub
		return 0;
	}

}
