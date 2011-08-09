<%@page import="beans.*"%>
<%@page import="java.sql.Connection"%>
<%@page import = "java.util.ArrayList"%>
<%@page import="java.util.*" %>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"   pageEncoding="ISO-8859-1"%>
<%@page import="enums.ROL_USUARIO"%>
<%@page import="java.util.Enumeration"%>
<%@page import="enums.NACIONALIDAD"%>
<%@page import="aplicacion.ExcepcionValidaciones"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.io.File" %>
<%@page import="org.apache.commons.fileupload.*" %>
<%@page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%@page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@page import="org.apache.commons.io.FilenameUtils" %>
<%@ page import="aplicacion.Utilidades"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<!-- Iniciar Modelo -->
<%@include file="/WEB-INF/jsp/IniciarModelo.jsp"%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link href="estilos.css" rel="stylesheet" type="text/css">
<link rel="stylesheet" type="text/css" href="css.css" >
<script language="JavaScript" type="text/javascript" src="js/jquery-1.5.2.js"></script>
<script language="JavaScript" type="text/javascript" src="codigo.js"></script>
<script language="JavaScript" type="text/javascript" src="scw.js"></script>

<script type='text/javascript' src='js/jquery.autocomplete.js'></script>
<link rel="stylesheet" type="text/css" href="style/jquery.autocomplete.css" />

<script type="text/javascript">
		$().ready(function() {;
		
		$("#colegiotexto").autocomplete("autocompletar_colegio.jsp", {
				width: 460,
				height: 500,
				matchContains: true,
				max: 30,
				minChars: 2,
				multiple: false
			});
		});
		
</script>

</head>

<%
	if (canaima.getUsuarioActual() == null || canaima.getUsuarioActual().getRol().equals(ROL_USUARIO.VIS)) {
	%>
	<jsp:include page="/WEB-INF/jsp/GeneradorMensaje.jsp">
		<jsp:param value="Acceso No Autorizado" name="titulo"/>
		<jsp:param value="No est&aacute autorizado a entrar en esta ventana con su perfil" name= "texto"/>		
		<jsp:param value="Cierre esta ventana y verifique si su sesión ha expirado" name= "texto"/>
	</jsp:include>	
	<% 	
	return;
}
%>

<%!
	public enum ESTADO {
		LISTADO,	
		POR_GUARDAR
	} 
%>
<%
	ArrayList<String> equipos = new ArrayList<String>();

	ESTADO actual = ESTADO.LISTADO;
	if (request.getParameter("estado") != null) {
		actual = ESTADO.valueOf(request.getParameter("estado"));
	}		
	
	if (ServletFileUpload.isMultipartContent(request)) {
		actual = ESTADO.POR_GUARDAR; 	
	}	
	
	if (actual.equals(ESTADO.POR_GUARDAR)) {
		
		int idDocente = 0;
		if (request.getParameter("iddocente")!=null)
			idDocente = Integer.parseInt(request.getParameter("iddocente"));
	
		try {				

			
			Docente docente = new Docente();
			int numeroContrato = 0;

			//Si se subio el archivo			
			ServletFileUpload fileUpload = new ServletFileUpload(new DiskFileItemFactory());
			List<FileItem> listaItems = fileUpload.parseRequest(request);			
			FileItem item = null;
			Iterator<FileItem> it = listaItems.iterator();				
			while (it.hasNext()) {
				item = (FileItem)it.next();
				if (item.isFormField()) 
					if (item.getFieldName().equals("iddocente")) { 
						if (item.getString() != null)  
							idDocente = Integer.parseInt(item.getString());
						break;
					}				
			}
			
			//Se recarga el docente para actualizarlo
			if (idDocente == 0) 
				throw new ExcepcionValidaciones("Error en el modelo: Docente es obligatorio");
			canaima.buscarPorID(idDocente, docente);
			
			//Buscar el serial de equipo
			Connection con = canaima.solicitarConexion();						
			//Aqui almaceno la info necesaria hasta el ultimo momento
			FileItem archivo = null;
		
			boolean dijocedula = false, dijofirma = false, dijopartida = false;
			String nac = "";
			//Se leen por completo los valores
			it = listaItems.iterator();
			while (it.hasNext()) {
				item = (FileItem)it.next();
				if (item.isFormField()) {
					if (item.getFieldName().equals("nombre") ) {						
						if (item.getString() != null)
							docente.setNombre(item.getString());
					} else if (item.getFieldName().equals("nacionalidad")) {
						if (item.getString() != null)
							docente.setNacionalidad(item.getString());
							nac = item.getString();
						    if ((docente.getCedula() == null) || (docente.getCedula().equals("")))
						    	docente.setNacionalidad(null);
					} else if (item.getFieldName().equals("idestado")) {
						if (item.getString() != null)
							docente.setIdestado(Integer.parseInt(item.getString()));
					} else if (item.getFieldName().equals("idmunicipio")) {
						if (item.getString() != null)
							docente.setIdmunicipio(Integer.parseInt(item.getString()));
					}else if (item.getFieldName().equals("idparroquia")) {
						if (item.getString() != null)
							docente.setIdparroquia(Integer.parseInt(item.getString()));
					}else if (item.getFieldName().equals("idcolegio")) {
						if (item.getString() != null)
							docente.setIdcolegio(Integer.parseInt(item.getString()));
					}else if (item.getFieldName().equals("proveedor")) {
						if (item.getString() != null)
							docente.setProveedor(item.getString());
					}else if (item.getFieldName().equals("ciudad")) {
						if (item.getString() != null)
							docente.setCiudad(item.getString());
					} else if (item.getFieldName().equals("cedula")) {
						if (item.getString() != null){
							docente.setCedula(item.getString());
							if (docente.getCedula().equals(""))
						    		docente.setNacionalidad(null);
							else
								docente.setNacionalidad(nac);
						}else
						    docente.setNacionalidad(null);
						
					}  else if (item.getFieldName().startsWith("serial_")) {
						if (item.getString() != null && !item.getString().trim().isEmpty()) {
							equipos.add(item.getString());
						}
					}
						else if (item.getFieldName().equals("fecha_entrega")) {
						if (item.getString() != null && !item.getString().trim().isEmpty()) {							
							String [] fechaA  = item.getString().trim().split("-");
							if (fechaA.length == 3){
								int dia = 0, mes = 0, año = 0;
								try {
									dia = Integer.parseInt(fechaA[0]);
									mes = Integer.parseInt(fechaA[1]);
									año = Integer.parseInt(fechaA[2]);									
								} catch (Exception e) {									
								}
								if (dia != 0 && mes != 0 && año != 0) {
									docente.setFecha_entrega(Utilidades.nuevaFecha(dia, mes, año));
									continue;
								}
							}							
							throw new ExcepcionValidaciones("El formato de la Fecha de Entrega es incorrecto.<br>"
										+ "Debe ser del estilo: DIA-MES-AÑO");
						}						
					} else if (item.getFieldName().equals("fecha_llegada")) {
						if (item.getString() != null && !item.getString().trim().isEmpty()) {
							String [] fechaA  = item.getString().trim().split("-");
							if (fechaA.length == 3){
								int dia = 0, mes = 0, año = 0;
								try {
									dia = Integer.parseInt(fechaA[0]);
									mes = Integer.parseInt(fechaA[1]);
									año = Integer.parseInt(fechaA[2]);									
								} catch (Exception e) {									
								}
								if (dia != 0 && mes != 0 && año != 0) {
									docente.setFecha_llegada(Utilidades.nuevaFecha(dia, mes, año));
									continue;
								}
							}							
							throw new ExcepcionValidaciones("El formato de la Fecha de Llegada es incorrecto.<br>"
										+ "Debe ser del estilo: DIA-MES-AÑO");
						}						
					} else if (item.getFieldName().equals("observacion")) {
						if (item.getString() != null && !item.getString().trim().isEmpty())
							docente.setObservacion(item.getString());
					} else if (item.getFieldName().equals("numero")) {						
						if (item.getString() != null && !item.getString().trim().isEmpty())
								numeroContrato = Integer.parseInt(item.getString());
					}
				}	else {
					archivo = item;
					}				
			}
			
			if (equipos.size()<=0)
				throw new ExcepcionValidaciones(docente.errorEsObligatorio("Nro de Serial de equipo > 0"));
			
			Equipo equipo = null;
			
			// eliminar los asociados del docente
			con = canaima.solicitarConexion();
		 	ArrayList<Equipo> equiposAsociados = Equipo.buscarEquipos(con, 0 ,docente.getID(), null);
			Equipo equipoAsociado = null;
			
			for(int i=0; i<equiposAsociados.size(); i++){
				equipoAsociado = equiposAsociados.get(i);
				canaima.eliminarPorID(equipoAsociado);
				
			}
			canaima.liberarConexion(con);
			//Guardar Equipos
			for(int i=0; i<equipos.size(); i++){
				
				equipo = new Equipo();
				equipo.setIddocente(docente.getID());
				equipo.setSerial(equipos.get(i));
				canaima.guardar(equipo);
			}
			//Debe ser posible guardar los cambios						
			canaima.actualizar(docente);
			Contrato cont = new Contrato();
			canaima.buscarPorID(docente.getIdcontrato(), cont);
						
			boolean cambiarContrato = false;	
			if (numeroContrato !=  cont.getNumero()) {
				if (numeroContrato == 0)
					throw new ExcepcionValidaciones(docente.errorEsObligatorio("Nro Contrato"));
										
				cont.setNumero(numeroContrato);
				cambiarContrato = true;			
			}					
			
						
			//Variables de negocio caja, lote y contrato			
			Lote lote = new Lote();
			canaima.buscarPorID(cont.getIdlote(), lote);
			
			Caja caja = new Caja();
			canaima.buscarPorID(lote.getIdcaja(), caja);
								
			//Se obtiene la información actual
			
			if (cambiarContrato) {
				con = canaima.solicitarConexion();			
				cont.validarContratoUnico(con);				
				canaima.liberarConexion(con);				
			}
					
			//Intentar guardar el archivo
			if (archivo != null) {
				if (archivo.getSize() > 0) {
			
					String ext = "." + FilenameUtils.getExtension(archivo.getName());
					if (!ext.equals(".pdf")) 
						throw new ExcepcionValidaciones("El archivo adjunto debe tener extensi&oacute;n .pdf");
							
					File viejo = new File(cont.getDireccion());
					viejo.delete();	
													
					//Crear la carpeta				
					String directorio = canaima.DIRECTORIO_DONATARIO + "Caja " + caja.getNumero() + "/Lote " + lote.getNumero();
					Utilidades.crearDirectorio(directorio);								
					File archivo_fisico = new File(directorio, cont.getNumero()+ ".pdf");								
					archivo.write(archivo_fisico);				
					
					FileInputStream fi = new FileInputStream(archivo_fisico);
					byte [] bytes = new byte [(int)archivo_fisico.length()];
					fi.read(bytes);
					fi.close();
					cont.setDireccion(directorio + "/" + cont.getNumero()+ ".pdf");
					cont.setPdf(bytes);				
					canaima.actualizar(cont);
				} 
			}
			idDocente = docente.getID(); 
			
			
		} catch (ExcepcionValidaciones val) {
			request.setAttribute("validaciones", val.getValidacionesIncumplidas());
			pageContext.include("/WEB-INF/jsp/GeneradorMensaje.jsp", true);					
		} catch (Exception exc) {					
			request.setAttribute("excepcion", exc);
			pageContext.include("/WEB-INF/jsp/GeneradorMensaje.jsp", true);
		} 
	}
%>
<body>
<br>
<div align="center" id="editar" class = "edicion">
<form method="post"
	enctype="multipart/form-data" 
	accept-charset="text/plain">
	<%  int idDocente = 0;
		if (request.getParameter("iddocente")!=null)
			idDocente = Integer.parseInt(request.getParameter("iddocente"));
		
		Docente docente = new Docente(); 
        canaima.buscarPorID(idDocente, docente);
    %>
    <br><br>
    <table border="1">

    	<tr>
    		<td class = "a"> Nombre Docente:</td>
    		<td><input tabindex="2" size="28" name = "nombre" value="<%= (docente.getNombre() != null) ? docente.getNombre() : ""%>" ></td>
    		<td class = "a"> ID Docente</td>
    		<td><%= idDocente %></td> 
    	</tr>
    	<tr>
    		<td class = "a">Nacionalidad</td>
    		<td align="center"><select name="nacionalidad" tabindex="3">
					<option value ="<%= NACIONALIDAD.V %>"
					<%=(docente.getNacionalidad() == NACIONALIDAD.V ? "selected=\"selected\"" : "")%>> V </option>
					<option value ="<%= NACIONALIDAD.E %>"
					<%=(docente.getNacionalidad() == NACIONALIDAD.E ? "selected=\"selected\"" : "")%>> E </option>
				</select>
			</td>
    		<td class = "a">Cédula:</td>
    		<td><input tabindex="4" maxlength="10" type="text" name="cedula" size="28" value="<%= (docente.getCedula() != null) ? docente.getCedula() : ""%>" onKeypress="validarNumero(this)"></td>
    	</tr>
    	<tr>
   
    	</tr>
    	<tr>
    		<td class = "a">Estado:</td>
    		<td><SELECT tabindex="7" name="idestado" title="estado" style="width: 150px;" onchange="javascript:mostrarMunicipios(this.value);">
			<%
				int idEstado;
				String nombreEstado = null;
				Estado estado = new Estado();
				Connection con = canaima.solicitarConexion();				
				ArrayList<Estado> estados = Estado.listarEstados(con);
				canaima.liberarConexion(con);
				out.write("<option value=\"" + 0 + "\">--Seleccione--</option>");
				for (int i=0; i < estados.size(); i++) {
					if (docente.getIdestado() > 0 && docente.getIdestado() == estados.get(i).getID())
						out.write("<option value=\"" + estados.get(i).getID() + "\" selected=\"selected\" >" + estados.get(i).getNombre()  + "</option>");
					else 
						out.write("<option value=\"" + estados.get(i).getID() + "\" >" + estados.get(i).getNombre()  + "</option>");
	   			}
        	%>
				</SELECT>
			</td>
    		<td class = "a">Municipio:</td>
    		<td id= "municipios"> 
    			<SELECT tabindex="8" name="idmunicipio" title="municipio" style="width: 150px;" onchange="javascript:mostrarParroquias(this.value);">
				<%					
					if (docente.getIdestado() > 0) {
						con = canaima.solicitarConexion();				
						ArrayList<Municipio> municipios = Municipio.listarMunicipiosPorEstado(docente.getIdestado(), con);
						canaima.liberarConexion(con);
						out.write("<option value=\"" + 0 + "\">--Seleccione--</option>");
						for (int i=0; i < municipios.size(); i++) {
							if (docente.getIdmunicipio() > 0 && docente.getIdmunicipio() == municipios.get(i).getID())
								out.write("<option value=\"" + municipios.get(i).getID() + "\" selected=\"selected\" >" + municipios.get(i).getNombre()  + "</option>");
							else 
								out.write("<option value=\"" + municipios.get(i).getID() + "\" >" + municipios.get(i).getNombre()  + "</option>");
			   			}		
					} else {
						out.write("<option value=\"" + 0 + "\">--Seleccione--</option>");
					}			
				%>			
				</SELECT>
			</td>
    	</tr>
    	<tr>
    		<td class = "a">Parroquia:</td>
    		<td id= "parroquias">
			<SELECT tabindex="3" name="idparroquia" title="parroquia" style="width: 150px;" >
			<%					
			if (docente.getIdmunicipio() > 0) {
				con = canaima.solicitarConexion();
				ArrayList<Parroquia> parroquias = Parroquia.listarParroquiasPorMunicipios(docente.getIdmunicipio(), con);
				canaima.liberarConexion(con);
				out.write("<option value=\"" + 0 + "\">--Seleccione--</option>");
				for (int i=0; i < parroquias.size(); i++) {
					if (docente.getIdparroquia() > 0 && docente.getIdparroquia() == parroquias.get(i).getID())
						out.write("<option value=\"" + parroquias.get(i).getID() + "\" selected=\"selected\" >" + parroquias.get(i).getNombre()  + "</option>");
					else 
						out.write("<option value=\"" + parroquias.get(i).getID() + "\" >" + parroquias.get(i).getNombre()  + "</option>");
	   			}		
			} else {
				out.write("<option value=\"" + 0 + "\">--Seleccione--</option>");
			}			
			%>			
			</SELECT>
			</td>
			<td class = "a">Ciudad:</td>
    		<td><input tabindex="9" size="28" name = "ciudad" value="<%= (docente.getCiudad() != null) ? docente.getCiudad() : ""%>"></td>
    	</tr>
    	<tr>
    		<td class = "a">Colegio:</td> 		
    		<td>
 			
			<%					
			
			if (docente.getIdcolegio() > 0) {
				
				Colegio cole = new Colegio();
				canaima.buscarPorID(docente.getIdcolegio(), cole);
				
				out.write("<input tabindex=\"11\" size=\"28\" id=\"colegiotexto\" name=\"colegiotexto\" value=\"" + cole.getNombre() + "\">");
	    		out.write("<input type=\"hidden\" name=\"idcolegio\" id=\"idcolegio\" value=\"" + cole.getIdcolegio() + "\">");
				
			} else {
				out.write("<input tabindex=\"11\" size=\"28\" id=\"colegiotexto\" name=\"colegiotexto\" value=\"\">");
				out.write("<input type=\"hidden\" name=\"idcolegio\" id=\"idcolegio\">");
			}			
			%>			
    		
    		</td>
    		<td class = "a">Fecha de Entrega:</td>
    		<td><input tabindex="9" size="28" name = "fecha_entrega" value="<%= (docente.getFecha_entrega() != null) ? Utilidades.mostrarFecha(docente.getFecha_entrega()) : ""%>" onclick="scwShow(this, event)"></td>
    	</tr>

    	<tr>
    		<td class = "a">Proveedor:</td>
    		<td><input tabindex="18" name="proveedor" size="28" value="<%= (docente.getProveedor() != null) ? docente.getProveedor() : ""%>"></td>
    		<td class = "a">Fecha de Llegada:</td>
    		<td><input tabindex="9" size="28" name = "fecha_llegada" value="<%= (docente.getFecha_llegada() != null) ? Utilidades.mostrarFecha(docente.getFecha_llegada()) : ""%>" onclick="scwShow(this, event)"></td>
    	</tr>
    	<tr>
    		<td class = "a">Observaciones:</td>
    		<td colspan="4"> <input tabindex="19" name="observacion" size="87" value="<%= (docente.getObservacion() != null) ? docente.getObservacion() : ""%>"></td>
    	</tr>
    	
    	<% 
    	Contrato contrato = null;
    	if (docente.getIdcontrato() > 0) {
				
			contrato = new Contrato();
			canaima.buscarPorID(docente.getIdcontrato(), contrato);
		}
    	
    	%>
    	<tr>
    		<td class = "a">Contrato:</td>
    		<td> <input tabindex="19" name="numero" size="28" value="<%= (contrato != null) ? contrato.getNumero() : ""%>"></td> 
    		<td class = "a">Archivo:</td> 	
    		<td> <input type="file" name = "pdf" tabindex="13"></td>
    	</tr>
    	<tr>
    		<td class = "a">Serial Equipo:</td>
    	<td>
    	<div id="attachment_container">
    <%
	  	//Buscar el serial de equipo
		con = canaima.solicitarConexion();
		ArrayList<Equipo> equiposAsociados = Equipo.buscarEquipos(con, 0 ,docente.getID(), null);
		Equipo equipoAsociado = null;
		
		for(int i=0; i<equiposAsociados.size(); i++){
			equipoAsociado = equiposAsociados.get(i);	
			%>
				
						<input type="hidden" value="<%= equiposAsociados.size() %>" id="serial_contador" />
    					<div id="attachment_<%= i+1 %>" class="attachment">
    						<input type="text" size="24" value= "<%= equipoAsociado.getSerial()  %>" name="serial_<%= i+1 %>"/><a href="" onClick="removeAttachmentElement(<%= i+1 %>);return false;"><img id="RemoveButton_<%= i+1 %>" src="img/minusButton.png" onMouseDown="this.src='img/minusButtonDown.png';" onMouseUp="this.src='img/minusButton.png';" alt="Remove" /></a>
    					</div>
			<%
		}
		canaima.liberarConexion(con);
    %>		
    	</div>
    				<a href="" onClick="addAttachmentElement();return false;"><img id="AddButton_1" src="img/plusButton.png" onMouseDown="this.src='img/plusButtonDown.png';" onMouseUp="this.src='img/plusButton.png';" alt="Add" /></a>
    			</td>
    			<td class = "a">Documento:</td>
    			<td align="center">
    			<script type="text/javascript">
					$(document).ready(function() {
						$("a.ar_link").fancybox({
							'transitionIn'	:	'elastic',
							'transitionOut'	:	'elastic',
							'speedIn'		:	200, 
							'speedOut'		:	200, 
							'overlayShow'	:	false,
							'autoDimensions':	false,
							'width'			:	820,
							'height'		:	480,
							'type'			:	'iframe'			
						});
					});
				</script>
    			<%=aFancyBox(response, "Visualizar", response.encodeURL("mostrarArchivo.jsp"))%>
				</td>	
    	</tr>
    	<tr>
    		<td colspan="4" align="center">
    			<INPUT type="hidden" value="<%= ESTADO.POR_GUARDAR %>" name="estado">
    			<INPUT type="hidden" value="<%= idDocente %>" name="iddocente">    			
    			<INPUT tabindex="20" type="submit" value="Aceptar Cambios"/>
    			<INPUT tabindex="21" type="reset"  value="Eliminar Docente" id= "botonEliminar" />
    		</td>    
    	</tr>	
    </table>
</form>		
</div>
<div align="center" id = "eliminar" class = "edicion" style="display:none;">

	<br><br> 
	<form action="<%= "javascript:eliminarDocente(" + idDocente + ");"%>">
	
	<h1>¿Est&aacute; seguro que desea eliminar al docente?</h1>
	<br>
	<table border="1">
	   	<tr>
	   		<td class = "a"> ID Docente</td>
	   		<td class = "extralargo"><%= idDocente %></td>
	   		<td class = "a"> Nombre Docente:</td>
	   		<td class = "extralargo" ><%=(docente.getNombre() != null) ? docente.getNombre() : ""%></td>
	   		
	   	</tr>
	   	<tr>
	   		<td class = "a">Nacionalidad Rep.</td>
	   		<td class = "extralargo"><%=NACIONALIDAD.mostrar(docente.getNacionalidad())%></td>
	   		<td class = "a">Cédula:</td>
	   		<td class = "extralargo"><%=(docente.getCedula() != null) ? docente.getCedula() : ""%></td>
	   	</tr>
	   	<tr>
	   	</tr>
	   	<tr>
		   	<td colspan="4" align="center">			   	
				<INPUT tabindex="1" type="reset" value="Cancelar" id = "botonCancelar"/>
				<INPUT tabindex="2" type="submit" value="Eliminar Docente" />
		   	</td>	  
	   	</tr>    
	   </table>			
	</form>
</div>
<script>
	$('#botonEliminar').click(function() {
	  $('#editar').hide('fast');	  
	  $('#eliminar').show('fast');
	});	
</script>
<script>
	$('#botonCancelar').click(function() {
	  $('#editar').show('fast');  
	  $('#eliminar').hide('fast');  
	});	
</script>
</body>
</html>

<%!
		public String aFancyBox (HttpServletResponse response, String texto, String direccion) {
			String resultado = 			
				"<a href = \"" + response.encodeURL(direccion) 
					+ 	"\" class = \"ar_link\">" + texto +"</a>"
				;
			return resultado;
		} 
%>