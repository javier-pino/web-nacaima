/**
 * 
 */
package aplicacion;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.poifs.filesystem.POIFSFileSystem;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;

import beans.Colegio;
import beans.Parroquia;

import sun.misc.BASE64Encoder;

/**
 * Clase que almcacena utilidades genericas de la aplicacion
 */
public class Utilidades {
	
	private static SimpleDateFormat FORMATO_FECHA = new SimpleDateFormat("yyyy-MM-dd");
	private static SimpleDateFormat FORMATO_FECHA_HORA = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");	
	private static SimpleDateFormat HUMANA_FECHA = new SimpleDateFormat("dd-MM-yyyy");
	
	/** Convierte un dato de tipo Date a Timestamp */ 
	public static Timestamp dateToTimestamp (Date date) {
		if (date == null) 
			return null;
		return new Timestamp(date.getTime());
	}
	
	/** Formatea un timestamp para hacerla accesible a las personas */
	public static String mostrarFecha(Date fecha) {
		return HUMANA_FECHA.format(fecha);
	}
	
	/** Formatea la fecha para hacerla entendible a las personas */
	public static String mostrarFecha(Timestamp fecha) {
		return HUMANA_FECHA.format(fecha);
	} 
	
	/** Convertir fecha en formato sql */
	public static String formatearTimestamp(Timestamp timestamp) {
		if (timestamp== null) 
			return null;
		return FORMATO_FECHA_HORA.format(timestamp);
	}
	
	/** Convertir fecha en formato sql */
	public static String formatearDate(Date date) {
		if (date == null) 
			return null;
		return FORMATO_FECHA.format(date);
	}
	
	/** Crear una fecha dado unos parametros */
	public static Date nuevaFecha(int dia_del_mes, int mes, int año ) {
		Calendar calendario = Calendar.getInstance();
		calendario.set(Calendar.MONTH, mes - 1);
		calendario.set(Calendar.DAY_OF_MONTH, dia_del_mes);
		calendario.set(Calendar.YEAR, año);
		return (new Date(calendario.getTimeInMillis()));
	}
	
	/** Crear una fecha dado unos parametros */
	public static Date nuevaFecha() {
		Calendar calendario = Calendar.getInstance();		
		return (new Date(calendario.getTimeInMillis()));
	}
	
	/** Encripta un texto usando el algoritmo SHA */
	public static String encriptarContraseña (String contraseña) {
		
		MessageDigest sha = null; 
		try {
			sha = MessageDigest.getInstance("SHA");
		} catch (Exception e) {
			return null;
		}
		try  {
			sha.update(contraseña.getBytes("UTF-8")); 
		} catch(UnsupportedEncodingException e) {
		      return null;
		}
	    byte raw[] = sha.digest(); //step 4
	    return (new BASE64Encoder()).encode(raw); //step 5		
	}
	
	/** Método que sirve para almacenar un archivo de datos */
	public static void guardarArchivo (String directorio, String nombre, String ext,  byte [] archivo ) throws IOException {		
		File ar = new File(directorio + nombre + ext);
		FileOutputStream os = new FileOutputStream(ar);
		BufferedOutputStream bo = new BufferedOutputStream(os);
		bo.write(archivo);
		bo.close();
		os.close();		
	}
	
	/** Guardar un directorio solicitado @throws FileNotFoundException */
	public static void crearDirectorio (String direccion) throws FileNotFoundException {
		File directorio = new File(direccion);		
		if (!directorio.exists()) {
			if (!directorio.mkdirs()) {
				throw new FileNotFoundException("No se pudo crear el directorio " + direccion);				
			}
		}
	} 
	
	
	/** Método para leer un archivo físico que es de tipo zip de un directorio temporal 
	 * @throws IOException */
	public static ArrayList<byte []> leerZIP(String nombre) throws IOException {
		
		ArrayList<byte []> resultado = new ArrayList<byte[]>();		
		ZipFile zf = new ZipFile(nombre);
		for (Enumeration<? extends ZipEntry> e = zf.entries(); e.hasMoreElements();) {
		    ZipEntry ze = e.nextElement();
		    String name = ze.getName();
		    if (name.endsWith(".jpg")) {
		    	InputStream in = zf.getInputStream(ze);
		    	BufferedInputStream fi = new BufferedInputStream(in);
		    	byte [] temp = new byte [(int)ze.getSize()];
		    	fi.read(temp);
		    	resultado.add(temp);
		    	in.close();
		    }
		}
		zf.close();
		return resultado;
	}

/**
* Lee un archivo de excel
* @param canaima - Modelo canaima que sirve para obetener conexiones
* @param archivo - Name of the excel file.
 * @throws SQLException 
*/
	public static void leerArchivoExcel(ModeloCanaima canaima, String archivo) throws SQLException {
		
		/** Create a new instance for cellDataList */
		PreparedStatement psEliminarColegio = null;
		PreparedStatement psEliminarParroquia  = null;
		Connection con = null;
		try {			
			FileInputStream fileInputStream = new FileInputStream(archivo);
			POIFSFileSystem fsFileSystem = new POIFSFileSystem(fileInputStream);
			HSSFWorkbook workBook = new HSSFWorkbook(fsFileSystem);
			HSSFSheet hssfSheet = workBook.getSheetAt(0);
			HSSFRow fila = null;
			HSSFCell celda = null;
			Iterator<Row> filas = hssfSheet.rowIterator();
			Iterator<Cell> columnasFilas = null;
			
			con = canaima.solicitarConexion();
			psEliminarColegio = con.prepareStatement("delete from colegio");
			psEliminarParroquia = con.prepareStatement("delete from parroquia");
			
			String colegioDea = null, colegioNombre = null, estado = null, municipio = null, parroquia = null;
			Parroquia parroquiaBean = null;
			Colegio colegioBean = null;						
			Parroquia ultimaParroquia = null;
			while (filas.hasNext()) {			
				fila = (HSSFRow) filas.next();
				if (fila.getRowNum() == 0) {
					continue;
				}				
				columnasFilas = fila.cellIterator();				
				colegioDea = null;
				colegioNombre = null; 
				estado = null; 
				municipio = null; 
				parroquia = null;
				while (columnasFilas.hasNext()) {
					celda = (HSSFCell)columnasFilas.next();
					switch (celda.getColumnIndex()) {
					case 0: 
						{
							if (celda.getCellType()  == HSSFCell.CELL_TYPE_NUMERIC) {
								Double valor = celda.getNumericCellValue();
								if (valor.intValue() < valor) 
									throw new Exception("Error de Casteo");
								colegioDea = "" + valor.intValue();								
							} else
								colegioDea = celda.getStringCellValue();
						}
						break;
					case 1:
						estado = celda.getStringCellValue();
						break;
					case 2:
						municipio = celda.getStringCellValue();
						break;	
					case 3:
						parroquia = celda.getStringCellValue();
						break;
					case 4:
						colegioNombre = celda.getStringCellValue();
						break;
					default:
						break;
					}					
				}
				
				if (colegioDea != null && colegioDea.trim().equals("FIN")) 
					break;
				
				if (estado == null || municipio == null || colegioDea == null || colegioNombre == null) { 
					System.out.println("Esta fila dio error : " + fila.getRowNum() + " " + 
							estado + " " + municipio + " " + parroquia + " " + colegioDea +" " + colegioNombre);										
					throw new ExcepcionValidaciones("Error en el archivo");
				} 				
				System.out.println(fila.getRowNum() + " " + 
						estado + " " + municipio + " " + parroquia + " " + colegioDea +" " + colegioNombre);
								
				//Buscar el estado y municipio correspondiente a los del excel
				int [] ids = canaima.buscarIDsEstadoMunicipio(estado.trim(), municipio.trim());
				
				//Crear la parroquia y municipio
				parroquiaBean = null; 
				colegioBean = null;
				
				//Guardar la parroquia				
				if (parroquia != null) { 						
					if (ultimaParroquia == null || !parroquia.trim().equalsIgnoreCase(ultimaParroquia.getNombre())) {						
						parroquiaBean = new Parroquia();
						parroquiaBean.setIdmunicipio(ids[1]);
						parroquiaBean.setNombre(parroquia.trim());
						canaima.guardar(parroquiaBean);						
						ultimaParroquia = parroquiaBean;						
					} else {						
						parroquiaBean = ultimaParroquia;						
					}
				}  else {					
					ultimaParroquia = null;					
				} 
				
				//Guardar el colegio
				colegioBean = new Colegio();
				colegioBean.setCodigo_dea(colegioDea.trim());
				colegioBean.setNombre(colegioNombre.trim());
				colegioBean.setIdestado(ids[0]);
				colegioBean.setIdmunicipio(ids[1]);
				if (parroquiaBean != null) {
					colegioBean.setIdparroquia(parroquiaBean.getID());
				}				
				canaima.guardar(colegioBean);				
			}
		}
		catch (Exception e) {
			psEliminarColegio.executeUpdate();
			psEliminarParroquia.executeUpdate();
			e.printStackTrace();
		} finally {
			if (psEliminarColegio != null )
				try {
					psEliminarColegio.close();
				} catch (SQLException e) {
					e.printStackTrace();
				}
			if (psEliminarParroquia != null )
				try {
					psEliminarParroquia.close();
				} catch (SQLException e) {					
					e.printStackTrace();
				}
			canaima.getPoolConexiones().cerrarConexion(con);
		}
	}
}

