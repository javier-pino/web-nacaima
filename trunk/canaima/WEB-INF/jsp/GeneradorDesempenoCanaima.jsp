<%@page import="com.sun.media.sound.MidiUtils.TempoCache"%>
<%@page import="beans.Donatario,org.jfree.chart.plot.*,org.jfree.chart.*,org.jfree.chart.title.TextTitle,org.jfree.data.general.DefaultPieDataset,org.jfree.data.general.PieDataset,org.jfree.data.category.DefaultCategoryDataset,org.jfree.ui.ApplicationFrame,org.jfree.ui.RefineryUtilities,java.io.*,java.awt.*" %>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.util.Hashtable"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Collections"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.Calendar"%>
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
	String estado = request.getParameter("idestado");
	String coddea = request.getParameter("coddea");	
	
	int idestado =  -1;
	if (estado.equals("-1")) {
		estado = "%";
	}	
	if (coddea == null || coddea.isEmpty() || coddea.equalsIgnoreCase("TODOS")) {
		coddea = "%";
	} else 
		coddea = "%" + coddea +"%";
	
	//Realizar la Búsqueda y Generación del archivo
	Connection con = canaima.solicitarConexion();	
	String sql =
	
		"SELECT " +
		"case when (alias.idestado = 0 ) then 'SIN ESTADO' ELSE e.nombre end estado," +
		"case when (alias.codigo_dea = '' ) then 'SIN DEA' ELSE alias.codigo_dea end dea," +
		"case when (alias.colegio = '' ) then 'SIN NOMBRE' ELSE alias.colegio end colegio," +
		"case when (alias.ano_escolar = 0 ) then 'SIN AÑO' "+
		"ELSE alias.ano_escolar||'-'||alias.ano_escolar+1 end año, " +
		"case when (alias.grado = 0 ) then 'SIN GRADO' ELSE alias.grado||'°' end grado," +
		"case when (alias.seccion = '' ) then 'SIN SECCIÓN' ELSE alias.seccion end seccion, alias.id id," + 
		" alias.notienefirma nofirma, alias.notienecedula nocedula, alias.notienepartida nopartida," +
		"alias.suma as suma" + 
		" FROM ( " +
		"(select d.idestado, d.codigo_dea, d.colegio, d.ano_escolar, d.grado, d.seccion," +
		" 0 as notienefirma, 0 as notienecedula, 0 as notienepartida, count(*) as suma , 1 as id " +
		"from donatario d join usuario u on (d.idcreadopor = u.idusuario) " +
		" group by d.idestado, d.codigo_dea, d.colegio, d.ano_escolar, d.grado, d.seccion,id) "+	
		"UNION ALL " +
		"(select d.idestado, d.codigo_dea, d.colegio, d.ano_escolar, d.grado, d.seccion,"+			
		  "count(*) - sum(tienefirma) as notienefirma,"+
		  "count(*) - sum(tienecedula) as notienecedula, count(*) - sum(tienepartida) notienepartida," +	  
		  "count(*) as suma , 2 as id " +	  
		" from donatario d join usuario u on (d.idcreadopor = u.idusuario)" +
		" join contrato c on (d.idcontrato = c.idcontrato)" +
		" group by d.idestado, d.codigo_dea, d.colegio, d.ano_escolar, d.grado, d.seccion,id)"+
		") alias left join estado e on (alias.idestado = e.idestado) " +
		" where alias.idestado like ? and alias.codigo_dea like ? " +
		" order by case when (alias.idestado = 0 ) then 'SIN ESTADO' ELSE e.nombre end,"+
		" case when (alias.codigo_dea = '' ) then 'SIN DEA' ELSE alias.codigo_dea end,"+
		" case when (alias.colegio = '' ) then 'SIN NOMBRE' ELSE alias.colegio end," +
		" case when (alias.ano_escolar = 0 ) then 'SIN AÑO' ELSE alias.ano_escolar||'-'||alias.ano_escolar+1 end,"+
		"case when (alias.grado = 0 ) then 'SIN GRADO' ELSE alias.grado||'°' end," +
		"case when (alias.seccion = '' ) then 'SIN SECCIÓN' ELSE alias.seccion end," +
		"alias.id";
	
	PreparedStatement ps = con.prepareStatement(sql);
	ps.setString(1, estado);
	ps.setString(2, coddea);

	ResultSet rs = ps.executeQuery();
	ArrayList<RegistroAuxiliar> registros = new ArrayList<RegistroAuxiliar>();
	Iterator<RegistroAuxiliar> iterador = null;
	RegistroAuxiliar nuevo = null, viejo = null, actual;
	
	//Esto almacena totales por estado	
	ArrayList<String> estados = new ArrayList<String>();
	ArrayList<Double> donatarios = new ArrayList<Double>(),
		contratos = new ArrayList<Double>();
	int indice = 0;
	while (rs.next()) {
		if (rs.getInt("id") == 1) {
			nuevo = new RegistroAuxiliar();
			nuevo.estado = rs.getString("estado");
			nuevo.coddea = rs.getString("dea");
			nuevo.colegio = rs.getString("colegio");
			nuevo.año_escolar = rs.getString("año");
			nuevo.grado = rs.getString("grado");
			nuevo.seccion = rs.getString("seccion");
			nuevo.donatarios = rs.getDouble("suma");
			registros.add(nuevo);
		
			indice = estados.indexOf(nuevo.estado); 
			if ( indice >= 0) {
				donatarios.set(indice, donatarios.get(indice) + nuevo.donatarios);					
			} else {
				estados.add(nuevo.estado);
				donatarios.add(nuevo.donatarios);
				contratos.add(0.0);
			}	
		} else {
			viejo = registros.get(registros.size() -1);
			viejo.contratos = rs.getDouble("suma");
			viejo.notienecedula = rs.getDouble("nocedula");
			viejo.notienefirma = rs.getDouble("nofirma");
			viejo.notienepartida = rs.getDouble("nopartida");			
			indice = estados.indexOf(viejo.estado); 
			if ( indice >= 0) {
				contratos.set(indice, contratos.get(indice) + viejo.contratos);					
			}			
		}		
	}
	
	DefaultCategoryDataset series = new DefaultCategoryDataset();
	for (int i = 0; i < estados.size() ; i++) {
		series.setValue(donatarios.get(i), "Donatarios", estados.get(i));
		series.setValue(contratos.get(i), "Contratos", estados.get(i));				
	}
	
	JFreeChart grafico = ChartFactory.createBarChart
		("Estadísticas de Canaima","Estados", "Registros", series, PlotOrientation.HORIZONTAL, true,true,false);
	
	File imagen = new File(canaima.DIRECTORIO_TEMPORAL, 
				"GraficoDeDesempeno_" + Calendar.getInstance().getTimeInMillis() + ".png"); 	
	FileOutputStream salidaImagen = new FileOutputStream(imagen);	
	ChartUtilities.writeChartAsPNG(salidaImagen,grafico,800, 800);
	salidaImagen.close();
	canaima.liberarConexion(null, ps, rs);
		
	HSSFWorkbook wb = new HSSFWorkbook();
	HSSFSheet sheet = wb.createSheet("Estadísticas de Canaima");		
	HSSFRow row = null;
	HSSFCell cell = null;
	HSSFCellStyle style = null;
	
 	//Colocar el nombre y los datos de las estadísticas: 		
	sheet.createRow(0).createCell(0).setCellValue("Estadísticas de Desempeño de Canaima");
	
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
	
	int j = 0;
	row = sheet.createRow(4);
	cell = row.createCell(j++);
	cell.setCellValue("Estado");
	cell.setCellStyle(style);
	cell = row.createCell(j++);
	cell.setCellValue("Código DEA");
	cell.setCellStyle(style);
	cell = row.createCell(j++);
	cell.setCellValue("Colegio");
	cell.setCellStyle(style);
	cell = row.createCell(j++);
	cell.setCellValue("Año escolar");
	cell.setCellStyle(style);
	cell = row.createCell(j++);
	cell.setCellValue("Grado");
	cell.setCellStyle(style);
	cell = row.createCell(j++);
	cell.setCellValue("Sección");
	cell.setCellStyle(style);
	cell = row.createCell(j++);
	cell.setCellValue("Solicitudes Registradas");
	cell.setCellStyle(style);
	cell = row.createCell(j++);
	cell.setCellValue("Contratos Escaneados");
	cell.setCellStyle(style);
	cell = row.createCell(j++);
	cell.setCellValue("Diferencia Solicitud/Contrato");
	cell.setCellStyle(style);
	cell = row.createCell(j++);
	cell.setCellValue("Sin Firma");
	cell.setCellStyle(style);
	cell = row.createCell(j++);
	cell.setCellValue("Sin Cédula");
	cell.setCellStyle(style);
	cell = row.createCell(j++);
	cell.setCellValue("Sin Partida");
	cell.setCellStyle(style);
	
	int i = 5;
	iterador = registros.iterator();
	while (iterador.hasNext()) {
		viejo = iterador.next();
		row = sheet.createRow(i++);
		j = 0;
		row.createCell(j++).setCellValue(viejo.estado);
		row.createCell(j++).setCellValue(viejo.coddea);
		row.createCell(j++).setCellValue(viejo.colegio);
		row.createCell(j++).setCellValue(viejo.año_escolar);
		row.createCell(j++).setCellValue(viejo.grado);
		row.createCell(j++).setCellValue(viejo.seccion);		
		row.createCell(j++).setCellValue(viejo.donatarios);
		row.createCell(j++).setCellValue(viejo.contratos);
		row.createCell(j++).setCellValue(viejo.donatarios - viejo.contratos);
		row.createCell(j++).setCellValue(viejo.notienefirma);
		row.createCell(j++).setCellValue(viejo.notienecedula);
		row.createCell(j++).setCellValue(viejo.notienepartida);
	}
	
	while (j >= 0) {
		sheet.autoSizeColumn(j--);
	}
	
	i += 2;		
	sheet.createRow(i++).createCell(0);
	//add picture data to this workbook.
    InputStream is = new FileInputStream(imagen);
    byte[] bytes = IOUtils.toByteArray(is);
    int pictureIdx = wb.addPicture(bytes, HSSFWorkbook.PICTURE_TYPE_JPEG);
    is.close();    
    imagen.delete();

    HSSFClientAnchor anchor = new HSSFClientAnchor(0,0,0,0, (short)0, i, (short)6, i + 45 );
    
    HSSFPatriarch patriarch=sheet.createDrawingPatriarch();
    patriarch.createPicture(anchor, pictureIdx);
    anchor.setAnchorType(HSSFClientAnchor.MOVE_DONT_RESIZE);
    
    //Crear la segunda hoja, que contiene información de las incidencias    		
	sql = "select d.iddonatario, c.numero, " + 
		" case when (d.nombre = '') then 'SIN NOMBRE' else d.nombre end nombre, tienefirma, tienecedula, tienepartida " +	  
		" from donatario d join contrato c on (d.idcontrato = c.idcontrato) " + 		
		" where d.idestado like ? and d.codigo_dea like ? " +
		" and not ( tienecedula and tienepartida and tienefirma) order " +
		" by d.iddonatario, c.numero ";
    
	ps = con.prepareStatement(sql);
	ps.setString(1, estado);
	ps.setString(2, coddea);
	rs = ps.executeQuery();
    sheet = wb.createSheet("Incidencias Reportadas");  	 	
	sheet.createRow(0).createCell(0).setCellValue("Incidencias Reportadas");
	
	j = 0;	
	row = sheet.createRow(4);
	cell = row.createCell(j++);
	cell.setCellValue("ID Donatario");
	cell.setCellStyle(style);
	cell = row.createCell(j++);
	cell.setCellValue("Contrato");
	cell.setCellStyle(style);
	cell = row.createCell(j++);
	cell.setCellValue("Nombre");
	cell.setCellStyle(style);
	cell = row.createCell(j++);
	cell.setCellValue("¿Tiene Firma?");
	cell.setCellStyle(style);
	cell = row.createCell(j++);
	cell.setCellValue("¿Tiene Cédula?");
	cell.setCellStyle(style);
	cell = row.createCell(j++);
	cell.setCellValue("¿Tiene Partida?");
	cell.setCellStyle(style);
    
	i = 5;	
	while (rs.next()) {	
		row = sheet.createRow(i++);
		j = 0;
		row.createCell(j++).setCellValue(rs.getInt("iddonatario"));
		row.createCell(j++).setCellValue(rs.getInt("numero"));
		row.createCell(j++).setCellValue(rs.getString("nombre"));
		row.createCell(j++).setCellValue(rs.getBoolean("tienefirma"));
		row.createCell(j++).setCellValue(rs.getBoolean("tienecedula"));
		row.createCell(j++).setCellValue(rs.getBoolean("tienepartida"));		
	}	
	canaima.liberarConexion( con, ps, rs);
	
	while (j >= 0) {
		sheet.autoSizeColumn(j--);
	}
	
  	//Crear reporte en excel
	String nombre = "EstadisticasDeDesempenoCanaima" + Calendar.getInstance().getTimeInMillis() + ".xls";
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
	private class RegistroAuxiliar {
		
		String estado = null;
		String coddea = null;
		String colegio = null;
		String año_escolar = null;
		String grado = null;
		String seccion = null;
		Double donatarios = 0.0, contratos = 0.0, notienefirma = 0.0, notienecedula = 0.0, notienepartida = 0.0;
		
	}%>
	