/**
 * 
 */
package aplicacion;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.sql.Date;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Enumeration;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

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
}
