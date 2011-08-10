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
	String colegio = request.getParameter("idcolegio");	
		
	int idestado =  -1, idcolegio = 0;
	if (estado.equals("-1")) {
		idestado = -1;
	} else if (estado.equals("0")) {
		idestado = 0;
	} else {
		idestado = Integer.parseInt(estado);
	}
	if (colegio.equals("0")) {
		idcolegio = 0;
	} else {
		idcolegio = Integer.parseInt(colegio);
	}
	
	//Realizar la Búsqueda y Generación del archivo
	Connection con = canaima.solicitarConexion();	
	String sql = 		
	"	SELECT	alias.idestado, " +
		" case when (alias.idestado = 0 ) then 'SIN ESTADO' ELSE e.nombre end estado,	\n"+
	"	alias.idcolegio,	\n"+
	"		case when (alias.codigo_dea = '' or alias.codigo_dea is null) then 'SIN DEA' ELSE alias.codigo_dea end dea,	\n"+
	"	case when (alias.nombre = '' or alias.nombre is null) then 'SIN COLEGIO' ELSE alias.nombre end colegio,	\n"+
	"	case when (alias.ano_escolar = 0 ) then 'SIN AÑO'	\n"+
	"	ELSE CONCAT(alias.ano_escolar,'-',alias.ano_escolar + 1) end año,	\n"+
	"	case when (alias.grado = 0 ) then 'SIN GRADO' ELSE CONCAT(alias.grado,'°') end grado,	\n"+
	"	case when (alias.seccion = '' ) then 'SIN SECCIÓN' ELSE alias.seccion end seccion, alias.id id,	\n"+
	"	alias.notienefirma nofirma, alias.notienecedula nocedula, alias.notienepartida nopartida,	\n"+
	"	alias.suma as suma	\n"+
	"	 FROM (	\n"+
	"	(select d.idestado, d.idcolegio, c.codigo_dea, c.nombre, d.ano_escolar, d.grado, d.seccion,	\n"+
	"	 0 as notienefirma, 0 as notienecedula, 0 as notienepartida, count(*) as suma , 1 as id	\n"+
	"	from donatario d	\n"+
	"	join usuario u on (d.idcreadopor = u.idusuario)	\n"+
	"	left join colegio c on (c.idcolegio = d.idcolegio)	\n"+
	"	group by d.idestado, d.idcolegio, c.codigo_dea, c.nombre, d.ano_escolar, d.grado, d.seccion,id)	\n"+
	"	UNION ALL	\n"+
	"	(select d.idestado, d.idcolegio, c.codigo_dea, c.nombre, d.ano_escolar, d.grado, d.seccion,	\n"+
	"	  count(*) - sum(tienefirma) as notienefirma,	\n"+
	"	  count(*) - sum(tienecedula) as notienecedula, count(*) - sum(tienepartida) notienepartida,	\n"+
	"	  count(*) as suma , 2 as id	\n"+
	"	 from donatario d	\n"+
	"	 join usuario u on (d.idcreadopor = u.idusuario)	\n"+
	"	 join contrato con on (d.idcontrato = con.idcontrato)	\n"+
	"	 left join colegio c on (c.idcolegio = d.idcolegio)	\n"+
	"	 group by d.idestado, d.idcolegio, c.codigo_dea, c.nombre, d.ano_escolar, d.grado, d.seccion,id)	\n"+
	"	UNION ALL	\n"+
	"	(select d.idestado, d.idcolegio, c.codigo_dea, c.nombre, 0 ano_escolar, 0 grado, 0 seccion,	\n"+
	"   0 as notienefirma, 0 as notienecedula, 0 notienepartida, count(*) as suma , 3 as id	\n"+
	"	 from docente d	\n"+
	"    join usuario u on (d.idcreadopor = u.idusuario)	\n"+
    "	join equipo e on (e.iddocente = d.iddocente) \n"+
	"     left join colegio c on (c.idcolegio = d.idcolegio)	\n"+
	"	 group by d.idestado, d.idcolegio, c.codigo_dea, c.nombre, ano_escolar, grado, seccion,id)	\n"+
	"	) alias	\n"+
	" 	left join estado e on (alias.idestado = e.idestado) 	\n"+	
	"	 order by alias.idestado, " + 
	"    case when (alias.idestado = 0 ) then 'SIN ESTADO' ELSE e.nombre end,	\n"+
	"    alias.idcolegio,	\n"+
	"	 case when (alias.codigo_dea = '' or alias.codigo_dea is null) then 'SIN DEA' ELSE alias.codigo_dea end,	\n"+
	"	 case when (alias.nombre = '' or alias.nombre is null) then 'SIN COLEGIO' ELSE alias.nombre end,	\n"+
	"	 case when (alias.ano_escolar = 0 ) then 'SIN AÑO' ELSE CONCAT(alias.ano_escolar,'-',alias.ano_escolar + 1) end,	\n"+
	" case when (alias.grado = 0 ) then 'SIN GRADO' ELSE CONCAT(alias.grado,'°') end, 	\n"+
	" case when (alias.seccion = '' ) then 'SIN SECCIÓN' ELSE alias.seccion end, 	\n"+
	" alias.id 		";
	System.out.println(sql);
	PreparedStatement ps = con.prepareStatement(sql);	
	ResultSet rs = ps.executeQuery();
	ArrayList<RegistroAuxiliar> registros = new ArrayList<RegistroAuxiliar>();
	Iterator<RegistroAuxiliar> iterador = null;
	RegistroAuxiliar nuevo = null, viejo = null, actual;
	
	//Esto almacena totales por estado	
	ArrayList<String> estados = new ArrayList<String>();
	ArrayList<Double> 
		donatarios = new ArrayList<Double>(),
		contratos = new ArrayList<Double>(),
		docentes = new ArrayList<Double>();
	int indice = 0;
	while (rs.next()) {		
		if (idestado != -1 ) {			
			if (rs.getInt("idestado") != idestado) {
				continue;
			}			
		}
		if (idcolegio != 0) {
			if (rs.getInt("idcolegio") != idcolegio) {
				continue;
			}
		}
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
				docentes.add(0.0);
			}	
		} else {			
			viejo = registros.get(registros.size() -1);
			indice = estados.indexOf(viejo.estado);
			if (rs.getInt("id") == 2) {
				viejo.contratos = rs.getDouble("suma");
				viejo.notienecedula = rs.getDouble("nocedula");
				viejo.notienefirma = rs.getDouble("nofirma");
				viejo.notienepartida = rs.getDouble("nopartida");
				if ( indice >= 0) {
					contratos.set(indice, contratos.get(indice) + viejo.contratos);
				}
			}  else {
				viejo.docentes = rs.getDouble("suma");
				if ( indice >= 0) {
					docentes.set(indice, docentes.get(indice) + viejo.docentes);
				}
			}			
		}		
	}
	canaima.liberarConexion( con, ps, rs);
	
	Date actualDate = Utilidades.nuevaFecha();
	DefaultCategoryDataset series = new DefaultCategoryDataset();
	for (int i = 0; i < estados.size() ; i++) {
		series.setValue(donatarios.get(i), "Donatarios", estados.get(i));
		series.setValue(contratos.get(i), "Contratos", estados.get(i));				
		series.setValue(docentes.get(i), "Docentes", estados.get(i));
	}
	JFreeChart grafico = ChartFactory.createBarChart
		("Estadísticas de Canaima","Estados", "Registros", series, PlotOrientation.HORIZONTAL, true,true,false);
	
	String nombreImagen = "GraficoDeDesempenoCanaima_" + Calendar.getInstance().getTimeInMillis() + ".png";
	File imagen = new File(canaima.DIRECTORIO_TEMPORAL, nombreImagen); 	
	
	FileOutputStream salidaImagen = new FileOutputStream(imagen);	
	ChartUtilities.writeChartAsPNG(salidaImagen,grafico,800, 800);
	salidaImagen.close();
	
	
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
	cell.setCellValue("Canaimas Registradas");
	cell.setCellStyle(style);
	cell = row.createCell(j++);
	cell.setCellValue("Contratos Escaneados");
	cell.setCellStyle(style);
	cell = row.createCell(j++);
	cell.setCellValue("Diferencia Solicitud/Contrato");
	cell.setCellStyle(style);
	cell = row.createCell(j++);
	cell.setCellValue("Equipos Docentes");
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
		row.createCell(j++).setCellValue(viejo.docentes);
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
    HSSFClientAnchor anchor = new HSSFClientAnchor(0,0,0,0, (short)0, i, (short)6, i + 45 );
    
    HSSFPatriarch patriarch=sheet.createDrawingPatriarch();
    patriarch.createPicture(anchor, pictureIdx);
    anchor.setAnchorType(HSSFClientAnchor.MOVE_DONT_RESIZE);
    
    con = canaima.solicitarConexion();
    
    //Crear la segunda hoja, que contiene información de las incidencias    		
	sql = "select d.idestado, d.idcolegio, d.iddonatario, c.numero, " + 
		" case when (d.nombre = '') then 'SIN NOMBRE' else d.nombre end nombre, tienefirma, tienecedula, tienepartida " +	  
		" from donatario d join contrato c on (d.idcontrato = c.idcontrato) " + 		
		" where not ( tienecedula and tienepartida and tienefirma) order " +
		" by d.iddonatario, c.numero ";
    
	ps = con.prepareStatement(sql);
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
		
		if (idestado != -1 ) {			
			if (rs.getInt("idestado") != idestado) {
				continue;
			}			
		}
		if (idcolegio != 0) {
			if (rs.getInt("idcolegio") != idcolegio) {
				continue;
			}
		}
		
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
	String nombreExcel = "EstadisticasDeDesempenoCanaima" + Calendar.getInstance().getTimeInMillis() + ".xls";
	File file = new File(canaima.DIRECTORIO_TEMPORAL, nombreExcel);	
	FileOutputStream fileOut = new FileOutputStream(file);
	wb.write(fileOut);
	fileOut.close();
		
%>	

	<div id="CanaimaFecha">
		<table align="left" >
			<tr class="a">
				<td>Fecha de Solicitud</td>
				<td></td>				
				<td></td>
				<td></td>
			</tr>
			<tr class = "w">				
				<td><%= Utilidades.mostrarFecha(actualDate)%>
				<td><input tabindex="1" value = "Reporte Tabulado" id="botonTabla" type="button" ></td>				
				<td><input tabindex="2" value = "Exportar a Excel" id="botonExcel" type="button" ></td>
				<td><input tabindex="3" value = "Graficar Reporte" id="botonImagen" type="button" ></td>				
			</tr>		
		</table>	
	</div>
	<br>

	<div id="CanaimaTabla">
		<table align="left" border="0">			
			<tr align="center">
				<td colspan="5" class = "a">TABLA DE DESEMPE&Ntilde;O</td>
			</tr>
			<tr class = "w" align="center">
				<td class = "largo">Estado</td>		
				<td class = "largo">Código DEA</td>
				<td class = "largo">Colegio</td>				
				<td class = "largo">Año escolar</td>			
				<td class = "largo">Grado</td>				
				<td class = "largo">Sección</td>				
				<td class = "largo">Canaimas Registradas</td>			
				<td class = "largo">Contratos Escaneados</td>			
				<td class = "largo">Diferencia Solicitud/Contrato</td>				
				<td class = "largo">Equipos Docentes</td>				
				<td class = "largo">Sin Firma</td>				
				<td class = "largo">Sin Cédula</td>				
				<td class = "largo">Sin Partida</td>				
			</tr>
	<%
		iterador = registros.iterator();
		while (iterador.hasNext()) {
			viejo = iterador.next();
	%>
			<tr class = "largo">
				<td class = "largo"> <%=viejo.estado%></td>		
				<td class = "largo"> <%=viejo.coddea%></td>		
				<td class = "largo"> <%=viejo.colegio%></td>		
				<td class = "largo"> <%=viejo.año_escolar%></td>		
				<td class = "largo"> <%=viejo.grado%></td>		
				<td class = "largo"> <%=viejo.seccion%></td>				
				<td class = "largo"> <%=viejo.donatarios.longValue()%></td>
				<td class = "largo"> <%=viejo.contratos.longValue()%></td>
				<td class = "largo"> <%=viejo.donatarios.longValue() - viejo.contratos.longValue()%></td>
				<td class = "largo"> <%=viejo.docentes.longValue()%></td>
				<td class = "largo"> <%=viejo.notienefirma.longValue()%></td>
				<td class = "largo"> <%=viejo.notienecedula.longValue()%></td>
				<td class = "largo"> <%=viejo.notienepartida.longValue()%></td>				
			</tr>	
	<% 	}	
	%>
		</table>		
	</div>

	<div id="DesempeñoImagen" >
		<table align="left" border="0">			
			<tr align="center"><td colspan="5" class = "a">GR&Aacute;FICO DE DESEMPE&Ntilde;O</td></tr>
			<tr><td><img alt="Gr&aacute;fico de Desempe&ntilde;o" src="<%=canaima.DIRECTORIO_TEMPORAL_SUFIJO + nombreImagen%>"></td></tr>
		</table>			
	</div>
	
	<div id="DesempeñoExcel">
		<br> 
		<h1>El reporte fue generado exitosamente</h1>
		<br>
		<p> Puede descargarlo en este link:</p>
		<br>
		<p><a href="/canaima/temp/<%=nombreExcel%>">Descargue aqu&iacute;</a> </p>	
	</div>
	
	<script>
		$('#botonTabla').click(function() {
			$('#CanaimaTabla').show('fast');
			$('#DesempeñoExcel').hide('fast');
			$('#DesempeñoImagen').hide('fast');
			
		});
	</script>
	<script>
		$('#botonImagen').click(function() {
			$('#DesempeñoImagen').show('fast');
			$('#CanaimaTabla').hide('fast');
			$('#DesempeñoExcel').hide('fast');
		});
	</script>
	<script>
		$('#botonExcel').click(function() {
			$('#DesempeñoExcel').show('fast');
			$('#CanaimaTabla').hide('fast');
			$('#DesempeñoImagen').hide('fast');
		});
	</script>
<%!
	private class RegistroAuxiliar {		
		String estado = null;
		String coddea = null;
		String colegio = null;
		String año_escolar = null;
		String grado = null;
		String seccion = null;
		Double donatarios = 0.0, contratos = 0.0, docentes = 0.0, 
		notienefirma = 0.0, notienecedula = 0.0, notienepartida = 0.0;		
	}
%>
	