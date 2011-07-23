<%@page import="beans.Donatario, 
org.jfree.chart.plot.*,
org.jfree.chart.*,
org.jfree.chart.title.TextTitle,
org.jfree.data.general.DefaultPieDataset,
org.jfree.data.general.PieDataset,
org.jfree.data.category.DefaultCategoryDataset,
org.jfree.ui.ApplicationFrame,
org.jfree.ui.RefineryUtilities,
java.io.*,
java.awt.*" %>
<%@page import="java.util.Calendar"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.util.Hashtable"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Collections"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Iterator"%>
<%@page import="enums.ROL_USUARIO"%>
<%@ page import="aplicacion.ExcepcionValidaciones"%>
<%@ page import="aplicacion.Utilidades"%>
<%@ page import="java.sql.Date"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="org.apache.poi.hssf.usermodel.*"%>
<%@ page import="org.apache.poi.hssf.util.*"%>
<%@ page import="org.apache.poi.util.IOUtils"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>

<%@include file="/WEB-INF/jsp/IniciarModelo.jsp"%>

<%
	String fechaInicial = request.getParameter("fechaInicial");
	String fechaFinal = request.getParameter("fechaFinal");	
	String inicialRequest = request.getParameter("inicial");
	String finalRequest = request.getParameter("final");
	
	if (fechaInicial == null)
		fechaInicial = inicialRequest;
	if (fechaFinal == null)
		fechaFinal = finalRequest;
	
	String [] fechaInicialArreglo  = fechaInicial.trim().split("-");
	String [] fechaFinalArreglo  = fechaFinal.trim().split("-");
	Date inicialDate = null;
	Date finalDate = null;
	
	if (fechaInicialArreglo.length == 3){
		int dia = 0, mes = 0, año = 0;
		try {
			dia = Integer.parseInt(fechaInicialArreglo[0]);
			mes = Integer.parseInt(fechaInicialArreglo[1]);
			año = Integer.parseInt(fechaInicialArreglo[2]);									
		} catch (Exception e) {									
		}
		if (dia != 0 && mes != 0 && año != 0) {
			inicialDate = Utilidades.nuevaFecha(dia, mes, año);			
		} else {
			throw new ExcepcionValidaciones("El formato de la Fecha Inicial es incorrecto.<br>"
					+ "Debe ser del estilo: DIA-MES-AÑO");		
		}
	}	
	if (fechaFinalArreglo.length == 3){
		int dia = 0, mes = 0, año = 0;
		try {
			dia = Integer.parseInt(fechaFinalArreglo[0]);
			mes = Integer.parseInt(fechaFinalArreglo[1]);
			año = Integer.parseInt(fechaFinalArreglo[2]);									
		} catch (Exception e) {									
		}
		if (dia != 0 && mes != 0 && año != 0) {
			finalDate = Utilidades.nuevaFecha(dia, mes, año);			
		} else {
			throw new ExcepcionValidaciones("El formato de la Fecha Inicial es incorrecto.<br>"
					+ "Debe ser del estilo: DIA-MES-AÑO");		
		}
	}	
	
	//Realizar la Búsqueda y Generación del archivo
	Connection con = canaima.solicitarConexion();	
	String sql =
		
		" select nombre, idusuario, id , sum(suma) total from " +
		" (select u.idusuario, u.nombre as nombre, 1 as suma ,  1 as id " +
		" from donatario d join usuario u on (d.idcreadopor = u.idusuario) " +
		" where date(d.fecha_carga) between ? and ? " +
		" UNION ALL" +
		" select u.idusuario, u.nombre as nombre , 1 as suma, 2 as id " +
		" from donatario d join usuario u on (d.idcreadopor = u.idusuario) join contrato c on (d.idcontrato = c.idcontrato) " +
		" where date(d.fecha_carga) between ? and ? " +
		" ) alias " +
		" group by nombre, idusuario, id " +
		" order by nombre, id ";

	PreparedStatement ps = con.prepareStatement(sql);
	ps.setDate(1, inicialDate);
	ps.setDate(2, finalDate);
	ps.setDate(3, inicialDate);
	ps.setDate(4, finalDate);
	ResultSet rs = ps.executeQuery();
	ArrayList<UsuarioAuxiliar> usuarios = new ArrayList<UsuarioAuxiliar>();
	Iterator<UsuarioAuxiliar> iterador = null;
	UsuarioAuxiliar aux = null;
	boolean encontrado = false;
	while (rs.next()) {		
		iterador = usuarios.iterator();
		encontrado = false;
		while (iterador.hasNext()) {
			aux = iterador.next();
			if (aux.idusuario == rs.getInt("idusuario")) {
				if (rs.getInt("id") == 1)
					aux.donatarios = rs.getDouble("total"); 
				else
					aux.contratos = rs.getDouble("total");				
				encontrado = true;
			}
		}
		if (!encontrado) {
			UsuarioAuxiliar nuevo = new UsuarioAuxiliar();
			nuevo.idusuario = rs.getInt("idusuario");
			nuevo.nombre = rs.getString("nombre");
			if (rs.getInt("id") == 1)
				nuevo.donatarios = rs.getDouble("total"); 
			else
				nuevo.contratos = rs.getDouble("total");
			usuarios.add(nuevo);			
		}
	}
	
	DefaultCategoryDataset series = new DefaultCategoryDataset();
	iterador = usuarios.iterator();
	while (iterador.hasNext()) {
		aux = iterador.next();
		series.setValue(aux.donatarios, "Donatarios", aux.nombre);
		series.setValue(aux.contratos, "Contratos", aux.nombre);		
	}
	
	JFreeChart grafico = ChartFactory.createBarChart
		("Estadísticas de Desempeño","Usuario","Cantidad", series, PlotOrientation.HORIZONTAL, true,true,false);
	
	File imagen = new File(canaima.DIRECTORIO_TEMPORAL, 
				"GraficoDeDesempeno_" + Calendar.getInstance().getTimeInMillis() + ".png"); 
	
	FileOutputStream salidaImagen = new FileOutputStream(imagen);	
	ChartUtilities.writeChartAsPNG(salidaImagen,grafico,800, 800);
	salidaImagen.close();
	canaima.getPoolConexiones().cerrarConexion(con, ps, rs);
	
	HSSFWorkbook wb = new HSSFWorkbook();
	HSSFSheet sheet = wb.createSheet("Estadísticas de Desempeño");		
	HSSFRow row = null;
	HSSFCell cell = null;
	HSSFCellStyle style = null;
	
 	//Colocar el nombre y los datos de las estadísticas: 		
	sheet.createRow(0).createCell(0).setCellValue("Estadísticas de Desempeño de Canaima");
	
	row = sheet.createRow(2);
	row.createCell(1).setCellValue("Fecha Inicio");
	row.createCell(2).setCellValue("Fecha Fin");
	
	row = sheet.createRow(3);
	row.createCell(1).setCellValue(fechaInicial);	
	row.createCell(2).setCellValue(fechaFinal);
	
	style = wb.createCellStyle();	
	style.setBorderTop((short) 6);	
	style.setBorderBottom((short) 6); 
	style.setBorderRight((short)6);
	style.setBorderLeft((short)6);
	
	style.setFillBackgroundColor(HSSFColor.GREY_25_PERCENT.index);
	
	HSSFFont font = wb.createFont();
	font.setFontName(HSSFFont.FONT_ARIAL);
	font.setFontHeightInPoints((short) 12);
	font.setBoldweight(HSSFFont.BOLDWEIGHT_BOLD);
	font.setColor(HSSFColor.BLUE.index);	
	style.setFont(font);
	
	row = sheet.createRow(6);
	cell = row.createCell(0);
	cell.setCellValue("Usuario");
	cell.setCellStyle(style);
	cell = row.createCell(1);
	cell.setCellValue("Donatarios Registrados");
	cell.setCellStyle(style);
	cell = row.createCell(2);
	cell.setCellValue("Contratos Registrados");
	cell.setCellStyle(style);
	cell = row.createCell(3);
	cell.setCellValue("Total");
	cell.setCellStyle(style);
	
	int i = 7;
	iterador = usuarios.iterator();
	while (iterador.hasNext()) {
		aux = iterador.next();
		row = sheet.createRow(i++);
		row.createCell(0).setCellValue(aux.nombre);
		row.createCell(1).setCellValue(aux.donatarios);
		row.createCell(2).setCellValue(aux.contratos);
		row.createCell(3).setCellValue(aux.donatarios + aux.contratos);		
	}
	
	sheet.autoSizeColumn((short) 0);
	sheet.autoSizeColumn((short) 1);
	sheet.autoSizeColumn((short) 2);
	sheet.autoSizeColumn((short) 3);
	
	i += 2;		
	sheet.createRow(i++).createCell(0);
	//add picture data to this workbook.
    InputStream is = new FileInputStream(imagen);
    byte[] bytes = IOUtils.toByteArray(is);
    int pictureIdx = wb.addPicture(bytes, HSSFWorkbook.PICTURE_TYPE_JPEG);
    is.close();    
    imagen.delete();

    HSSFClientAnchor anchor = new HSSFClientAnchor(0,0,0,0, (short)0, i, (short)8, i + 45 );
    
    HSSFPatriarch patriarch=sheet.createDrawingPatriarch();
    patriarch.createPicture(anchor, pictureIdx);
    anchor.setAnchorType(HSSFClientAnchor.MOVE_DONT_RESIZE);
    
  	//Crear reporte en excel
	String nombre = "EstadisticasDeDesempeno" + Calendar.getInstance().getTimeInMillis() + ".xls";
	File file = new File(canaima.DIRECTORIO_TEMPORAL, nombre);	
	FileOutputStream fileOut = new FileOutputStream(file);
	wb.write(fileOut);
	fileOut.close();
%>		

	<div id = scroll align="center">
		<br> 
		<h1>El reporte fue generado exitosamente</h1>
		<br>
		<p> Puede descargarlo en este link:</p>
		<br>
		<p><a href="/canaima/temp/<%=nombre%>">Descargue aqu&iacute;</a> </p>	
	</div>
	
<%! 
	private class UsuarioAuxiliar {
		int idusuario;
		String nombre;
		Double donatarios = 0.0, contratos = 0.0;
		
		public String toString () {
			return "[" + idusuario + " " + nombre + " " + donatarios + " " + contratos + "]";
		}
	}

%>