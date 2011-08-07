<%@page import="joins.DonatarioContrato"%>
<%@page import="enums.ROL_USUARIO"%>
<%@page import="java.util.*" %>
<%@ page import="beans.*"%>
<%@page import="enums.NACIONALIDAD"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.sql.Connection"%>
<%@page import="aplicacion.*"%>
<%@ page import="java.io.File" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.io.FilenameUtils" %>
<%@page import="java.io.FileInputStream"%>
<%@ page import="aplicacion.ExcepcionValidaciones"%>
<%@ page import="aplicacion.Utilidades"%>
<%@page import="enums.ROL_USUARIO"%>
<%@page import="java.util.*" %>
<%@page import="beans.*"%>
<%@page import="enums.NACIONALIDAD"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.sql.Connection"%>

<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<!-- Iniciar Modelo -->
<%@include file="/WEB-INF/jsp/IniciarModelo.jsp"%>

<!-- Incluir la cabecera -->
<%@include file="/WEB-INF/jsp/GeneradorCabecera.jsp"%>

<%!
	public enum ESTADO {
		INICIAL,
		BUSCAR,
		POR_GUARDAR,
		GUARDANDO
		
	} 
%>

<%
	ESTADO actual = ESTADO.INICIAL;

	//Verificamos roles, sino mandamos a su página merecida
	if (canaima.getUsuarioActual() == null) {
		response.sendRedirect("login.jsp");
		return;
	} else if (canaima.getUsuarioActual().getRol().equals(ROL_USUARIO.VIS)) {
		response.sendRedirect(response.encodeRedirectURL("visitante.jsp"));
		return;
	}
	//Incluir el menu de acuerdo al rol
	request.setAttribute("rolActual", canaima.getUsuarioActual().getRol());	
	pageContext.include("/WEB-INF/jsp/GeneradorMenu.jsp", true);
%>
<jsp:include page="/WEB-INF/jsp/GeneradorMenuAnalista.jsp" flush="true"></jsp:include>
<div id="Middle">
       <div id="Page">
           <div id="Content">
           	 <div class="Part" >
				<h2>Consultar Contratos</h2>
				&nbsp; 
				<div id = "estadisticas">				
				<form method="post">
				<table align="left"">
				
					<tr class="a">
						<td>ID Donatario</td>
						<td>N&uacute;mero de Contrato</td>
						<td></td>
											
					</tr>				
					<tr>
						<td><input size="20" maxlength="10" name = "iddonatario" onKeypress="validarNumero(this)"></td>
						<td><input size="20" maxlength="10" name = "numero" onKeypress="validarNumero(this)"></td>															
						<td colspan="7">
						<input type="hidden" name = "estado" value = "<%=ESTADO.BUSCAR%>">
						<input value = "Aceptar" name = "Aceptar" type="submit" onclick="return buscarContrato(form)"></td>					
					</tr>				
				</table>
				</form>
				&nbsp;				
				</div>				
				&nbsp;			
	<% 
	if (request.getParameter("estado") != null ) {
		actual = ESTADO.valueOf(request.getParameter("estado"));		
	}	
	
	int idDonatario = 0; int numero = 0;
	boolean mostrar = true;	

	if (ServletFileUpload.isMultipartContent(request)) {
		actual = ESTADO.POR_GUARDAR; 	
	}

	if (actual == ESTADO.BUSCAR) {
		
		String snumero = "", sdonatario;	
	    if (request.getParameter("iddonatario") != null) {
		   sdonatario = (request.getParameter("iddonatario"));
		   try {
			 	idDonatario = Integer.parseInt(sdonatario);  
		   } catch (Exception e) {
		   } 
	    }
	    if (request.getParameter("numero") != null) {
	 	  snumero = (request.getParameter("numero"));
	 	  try {
			 	numero = Integer.parseInt(snumero);  
		   } catch (Exception e) {		   		  
		   } 
	    } 
		
	} else  if (actual == ESTADO.POR_GUARDAR){
		try {				
			int numeroContrato = 0;
			Donatario donatario = new Donatario();
			
			//Si se subio el archivo			
			ServletFileUpload fileUpload = new ServletFileUpload(new DiskFileItemFactory());
			List<FileItem> listaItems = fileUpload.parseRequest(request);			
			FileItem item = null;
			Iterator<FileItem> it = listaItems.iterator();				
			while (it.hasNext()) {
				item = (FileItem)it.next();
				if (item.isFormField()) 
					if (item.getFieldName().equals("iddonatario")) { 
						if (item.getString() != null)  
							idDonatario = Integer.parseInt(item.getString());
						break;
					}				
			}
			
			//Se recarga el donatario para actualizarlo
			if (idDonatario == 0) 
				throw new ExcepcionValidaciones("Error en el modelo: Donatario es obligatorio");
			canaima.buscarPorID(idDonatario, donatario);
			
			//Aqui almaceno la info necesaria hasta el ultimo momento
			FileItem archivo = null;
		
			boolean dijocedula = false, dijofirma = false, dijopartida = false;
			//Se leen por completo los valores
			it = listaItems.iterator();
			while (it.hasNext()) {
				item = (FileItem)it.next();
				if (item.isFormField()) {
					if (item.getFieldName().equals("equipo_serial")) {
						if (!item.getFieldName().isEmpty())
							donatario.setEquipo_serial(item.getString());	
					} else if (item.getFieldName().equals("fecha_entrega")) {
						if (item.getString() != null && !item.getString().trim().isEmpty()) {							
							String [] fechaA  = item.getString().split("-");
							if (fechaA.length == 3){
								int dia = 0, mes = 0, año = 0;
								try {
									dia = Integer.parseInt(fechaA[0]);
									mes = Integer.parseInt(fechaA[1]);
									año = Integer.parseInt(fechaA[2]);									
								} catch (Exception e) {									
								}
								if (dia != 0 && mes != 0 && año != 0) {
									donatario.setFecha_entrega(Utilidades.nuevaFecha(dia, mes, año));
									continue;
								}
							}							
							throw new ExcepcionValidaciones("El formato de la Fecha de Entrega es incorrecto.<br>"
										+ "Debe ser del estilo: DIA-MES-AÑO");
						} else donatario.setFecha_entrega(null);						
					} else if (item.getFieldName().equals("fecha_llegada")) {
						if (item.getString() != null && !item.getString().trim().isEmpty()) {
							String [] fechaA  = item.getString().split("-");
							if (fechaA.length == 3){
								int dia = 0, mes = 0, año = 0;
								try {
									dia = Integer.parseInt(fechaA[0]);
									mes = Integer.parseInt(fechaA[1]);
									año = Integer.parseInt(fechaA[2]);									
								} catch (Exception e) {									
								}
								if (dia != 0 && mes != 0 && año != 0) {
									donatario.setFecha_llegada(Utilidades.nuevaFecha(dia, mes, año));
									continue;
								}
							}							
							throw new ExcepcionValidaciones("El formato de la Fecha de Llegada es incorrecto.<br>"
										+ "Debe ser del estilo: DIA-MES-AÑO");
						} else donatario.setFecha_llegada(null);						
					} else if (item.getFieldName().equals("tienefirma")) {
						if (item.getString() != null && item.getString().equals("true"))							
						    dijofirma = true;
					} else if (item.getFieldName().equals("tienecedula")) {
						if (item.getString() != null && item.getString().equals("true"))
							dijocedula = true;						
					} else if (item.getFieldName().equals("tienepartida")) {
						if (item.getString() != null && item.getString().equals("true"))
							dijopartida = true;						
					} else if (item.getFieldName().equals("numero")) {						
						if (item.getString()!=null) {				
							if (!item.getString().isEmpty())
								numeroContrato = Integer.parseInt(item.getString());						
						}						
					}
				}	else {
					archivo = item;					
				}				
			}
			
			donatario.setTienecedula(dijocedula);
			donatario.setTienepartida(dijopartida);
			donatario.setTienefirma(dijofirma);
			
			//Debe ser posible guardar los cambios						
			canaima.actualizar(donatario);
			Contrato cont = new Contrato();
			canaima.buscarPorID(donatario.getIdcontrato(), cont);
						
			boolean cambiarContrato = false;	
			if (numeroContrato !=  cont.getNumero()) {
				if (numeroContrato == 0)
					throw new ExcepcionValidaciones(donatario.errorEsObligatorio("Nro Contrato"));
										
				cont.setNumero(numeroContrato);
				cambiarContrato = true;			
			}
				
			//Aqui se valida si no tiene el mismo nombre y cedula
			Connection con = null;
			
			//Actualizo los recientes
			ArrayList<Donatario> recientes = canaima.getRecientes();
			for (int i = 0; i < recientes.size() ; i++) {
				if (recientes.get(i).getID() == donatario.getID()) {
					recientes.set(i, donatario);
					break;
				}
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
					String directorio = canaima.DIRECTORIO_GUARDADO + "Caja " + caja.getNumero() + "/Lote " + lote.getNumero();
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
			idDonatario = donatario.getID();
			numero = cont.getNumero();
		
		} catch (ExcepcionValidaciones val) {
			val.printStackTrace();
			request.setAttribute("validaciones", val.getValidacionesIncumplidas());
			pageContext.include("/WEB-INF/jsp/GeneradorMensaje.jsp", true);					
		} catch (Exception exc) {	
			exc.printStackTrace();
			request.setAttribute("excepcion", exc);
			pageContext.include("/WEB-INF/jsp/GeneradorMensaje.jsp", true);
		}			
	} 
	
	if (idDonatario > 0 || numero > 0) {			
	    DonatarioContrato donCon = canaima.buscarDonatarioContrato(idDonatario, numero);
	    
	    if (donCon.isValido()) {
	    	
	    	String nombre = "temp" + Calendar.getInstance().getTimeInMillis(), ext = ".pdf";
	    	
	    	//Generar el archivo temporal	    	
	    	File archivo = new File(canaima.DIRECTORIO_TEMPORAL, nombre + ext);
	    	synchronized (archivo) {
	    		while (archivo.exists()) {
		    		nombre = "temp" + Calendar.getInstance().getTimeInMillis();
		    		archivo = new File(canaima.DIRECTORIO_TEMPORAL, nombre + ext);
		    	}
	    		Utilidades.guardarArchivo(canaima.DIRECTORIO_TEMPORAL, nombre, ext, donCon.getContrato().getPdf());
		    	canaima.setArchivoTemporal(nombre + ext);
	    	}	    	
	    	Lote lote = new Lote();
	    	canaima.buscarPorID(donCon.getContrato().getIdlote(), lote);	    	    
	    	Caja caja = new Caja();
	    	canaima.buscarPorID(lote.getIdcaja(), caja);
	%>
	<div id = "busqueda">
	<form 
	method="post"
	enctype="multipart/form-data" 
	accept-charset="text/plain">	
		<table border = "1">
			<tr class="a">
				<td width="70">Nro. Caja</td>
				<td width="70">Nro. Lote</td>
				<td height="10" width="90">Id Donatario</td>
				<td height="10" width="120">Nombre</td>
				<td height="10" width="100">Cédula. Rep.</td>
				<td height="10" width="120">Nombre. Rep.</td>
				<td>Serial Equipo</td>
			</tr>	
			<tr>
				<td><%= caja.getNumero()%></td>
				<td><%= lote.getNumero()%></td>
				<td><%=donCon.getDonatario().getIddonatario()%></td>
				<td class="b" height="10" width="90">
				<%= (donCon.getDonatario().getNombre() != null) ? donCon.getDonatario().getNombre() : ""%>
				</td>
				<td class="b" height="10" width="80">
				<%
				if (donCon.getDonatario().getRepresentante_ci() != null && 
					!donCon.getDonatario().getRepresentante_ci().isEmpty()) {		
				%>
				<%=donCon.getDonatario().getRepresentante_nac() + "-" +donCon.getDonatario().getRepresentante_ci()%>
				<%}			
				 %>
				</td>
				<td class="b" height="10" width="90">
				<%=donCon.getDonatario().getRepresentante_nombre()%>
				</td>
				<td><input tabindex="1" name="equipo_serial" size="20" value="<%= (donCon.getDonatario().getEquipo_serial() != null) ? donCon.getDonatario().getEquipo_serial() : ""%>"></td>
		</tr>
		</table>
		&nbsp;
		<table border = "1">
			<tr>
				<td class="a">Fecha Entrega</td>
				<td><input tabindex="2" size="20" name="fecha_entrega" onclick="scwShow(this, event)" value="<%= (donCon.getDonatario().getFecha_entrega() != null) ? Utilidades.mostrarFecha(donCon.getDonatario().getFecha_entrega()) : ""%>"/></td>
				<td class="a">Fecha LLegada</td>
				<td><input tabindex="3" size="20" name="fecha_llegada" onclick="scwShow(this, event)" value="<%= (donCon.getDonatario().getFecha_llegada() != null) ? Utilidades.mostrarFecha(donCon.getDonatario().getFecha_llegada()) : ""%>"></td>
				<td class="a">Documento</td>
				<td width="100" align="center">
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
		</table>
		&nbsp;
		<table border = "1">		
		<tr class="a">
			<td>
				Nro. Contrato
			</td> 
			<td>
				Asignar Contrato
			</td>
			<td>
	    		Tiene Firma:
	    	</td>
	    	<td>
	    		Tiene Cédula:
	    	</td>
	    	<td>
	    		Tiene Partida:
	    	</td>
		</tr>
		<tr align="center">
		    <td><input tabindex="4" size="20" name="numero" value="<%= (donCon.getContrato().getNumero() != 0) ? donCon.getContrato().getNumero() : ""%>"/></td>
			<td><input tabindex="5" type="file" name = "pdf"></td>
			<td><input tabindex="6" name="tienefirma" value="true" type="checkbox" <%=donCon.getDonatario().isTienefirma() ? "checked=\"checked\"" : "" %>/></td>
			<td><input tabindex="7" name="tienecedula" value="true" type="checkbox" <%=donCon.getDonatario().isTienecedula() ? "checked=\"checked\"" : "" %>/></td>	
		    <td><input tabindex="8" name="tienepartida" value="true" type="checkbox" <%=donCon.getDonatario().isTienepartida() ? "checked=\"checked\"" : "" %>/></td>
		</tr>
	</table>
	<table width="100%">		
		<tr>
	    		<td colspan="1" align="center">	    			    	
	    			<INPUT type="hidden" value="<%= ESTADO.POR_GUARDAR %>" name="estado">
	    			<INPUT type="hidden" value="<%= idDonatario %>" name="iddonatario">
	    			<br>
	    			<INPUT tabindex="9" type="submit" value="Aceptar Cambios" onclick="return validarContratoActualizado(form, <%= donCon.getContrato().getNumero()%>)"/>
	    		</td> 
	    	</tr>
	</table>
	</form>
	<br>
	<%
	    } else {
	%>
		<jsp:include page="/WEB-INF/jsp/GeneradorMensaje.jsp">
						<jsp:param value="Este Donatario no posee Contrato Asociado o no se encuentra Registrado " name="titulo"/>				
						<jsp:param value="Verifique el ID del Donatario o el número del Contrato" name= "texto"/>
					</jsp:include>
	<%   	
	    }
	%>

	</div>
	</body>
	<%
	}
	%>	
	
	<%!
		public String aFancyBox (HttpServletResponse response, String texto, String direccion) {
			String resultado = 			
				"<a href = \"" + response.encodeURL(direccion) 
					+ 	"\" class = \"ar_link\">" + texto +"</a>"
				;
			return resultado;
		} 
	%>