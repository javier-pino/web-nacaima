<%@page import="enums.CAJA_TIPO"%>
<%@page import="java.io.FileInputStream"%>
<%@ page import="aplicacion.ExcepcionValidaciones"%>
<%@ page import="aplicacion.Utilidades"%>
<%@ page import="beans.*"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.*" %>
<%@ page import="enums.ROL_USUARIO"%>
<%@ page import="java.util.Enumeration"%>
<%@ page import="enums.NACIONALIDAD"%>
<%@ page import="java.io.File" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.io.FilenameUtils" %>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"   pageEncoding="ISO-8859-1"%>

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
</head>

<%
	boolean mostrar = true;
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
		INICIAL,	
		POR_GUARDAR,
		GUARDANDO
		
	} 
%>
<%

	//Si los datos se pudieron almacenar, hay que verificar que se subió el archivo
	int idDonatario = 0;
	ESTADO actual = ESTADO.INICIAL;
	if (request.getParameter("estado") != null) {
		actual = ESTADO.valueOf(request.getParameter("estado"));
	}		
	if (ServletFileUpload.isMultipartContent(request)) {
		actual = ESTADO.POR_GUARDAR; 	
	}	
	if (actual.equals(ESTADO.POR_GUARDAR)) {
		
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
			
			//Buscar el serial de equipo
			Connection con = canaima.solicitarConexion();						
			ArrayList<Equipo> equiposAsociados = Equipo.buscarEquipos(con, donatario.getID(), 0 , null);
			Equipo equipoAsociado = (equiposAsociados.size() > 0 ? equiposAsociados.get(0) : null);	
			canaima.liberarConexion(con);
			
			boolean dijocedula = false, dijofirma = false, dijopartida = false;
			
			//Aqui almaceno la info necesaria hasta el ultimo momento
			FileItem archivo = null;
			
			//Se leen por completo los valores
			it = listaItems.iterator();
			while (it.hasNext()) {
				item = (FileItem)it.next();
				if (item.isFormField()) {
					if (item.getFieldName().equals("nombre")  ) {						
						if (item.getString() != null && !item.getString().trim().isEmpty()) 
							donatario.setNombre(item.getString());
					} else if (item.getFieldName().equals("representante_nac")) {
						if (item.getString() != null && !item.getString().trim().isEmpty()) 
							donatario.setRepresentante_nac(item.getString());
					} else if (item.getFieldName().equals("representante_ci")) {
						if (item.getString() != null && !item.getString().trim().isEmpty()) 
							donatario.setRepresentante_ci(item.getString());						
					} else if (item.getFieldName().equals("representante_nombre")) {
						if (item.getString() != null && !item.getString().trim().isEmpty()) 
							donatario.setRepresentante_nombre(item.getString());
					} else if (item.getFieldName().equals("equipo_serial")) {						
							if (item.getString() != null && !item.getString().trim().isEmpty()) {						
								//No hay serial asociado
								if (equipoAsociado == null) {							
										//Se verifica que no haya un donatario o docente con el mismo serial de equipo				
									Equipo equipo = new Equipo();
									equipo.setSerial(item.getString().trim());
									equipo.setIddonatario(donatario.getID());				
									canaima.guardar(equipo);								
								} else {
									equipoAsociado.setSerial(item.getString().trim());
									canaima.actualizar(equipoAsociado);
								}					
							}
						}							
					} else if (item.getFieldName().equals("fecha_entrega")) {
						if (item.getString() != null && !item.getString().trim().isEmpty()) {							
							String [] fechaA  = item.getString().trim().split("-");
							System.out.println(item.getString());
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
									donatario.setFecha_llegada(Utilidades.nuevaFecha(dia, mes, año));
									continue;
								}
							}							
							throw new ExcepcionValidaciones("El formato de la Fecha de Llegada es incorrecto.<br>"
										+ "Debe ser del estilo: DIA-MES-AÑO");
						}						
					} else if (item.getFieldName().equals("observacion")) {
						if (!item.getFieldName().isEmpty())
							donatario.setObservacion(item.getString());
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
						if (item.getString()!=null &&!item.getString().isEmpty())
								numeroContrato = Integer.parseInt(item.getString());						
					} else {
						archivo = item;
						String ext = "." + FilenameUtils.getExtension(archivo.getName());
						if (!ext.equals(".pdf")) 
							throw new ExcepcionValidaciones("El archivo adjunto debe tener extensi&oacute;n .pdf");
				}				
			}
			//Verificacion de la cedula del representante
			if (donatario.getRepresentante_ci() == null || donatario.getRepresentante_ci().isEmpty())			
				donatario.setRepresentante_nac(null);
			
			donatario.setTienecedula(dijocedula);
			donatario.setTienepartida(dijopartida);
			donatario.setTienefirma(dijofirma);
			
			//Debe ser posible guardar los cambios						
			canaima.actualizar(donatario);
			
			if (numeroContrato == 0)
				throw new ExcepcionValidaciones(donatario.errorEsObligatorio("Nro Contrato"));
			
			//Aqui se valida si no tiene el mismo nombre y cedula
			con = canaima.solicitarConexion();
			donatario.validarCedulaRepNombreDonatario(con);			
			canaima.liberarConexion(con);
			
			//Actualizo los recientes
			ArrayList<Donatario> recientes = canaima.getRecientes();
			for (int i = 0; i < recientes.size() ; i++) {
				if (recientes.get(i).getID() == donatario.getID()) {
					recientes.set(i, donatario);
					break;
				}
			}
						
			//Variables de negocio caja, lote y contrato
			Contrato contrato = new Contrato();
			contrato.setNumero(numeroContrato);			
			Caja caja = new Caja();
			Lote lote = new Lote();
						
			//Se obtiene la información actual
			Usuario usuarioActual = canaima.getUsuarioActual(); 
			con = canaima.solicitarConexion();
			
			int cajaActual = Caja.getUltimaCajaRegistrada(con, usuarioActual, CAJA_TIPO.DON);			
			if (cajaActual == 0) {
				synchronized (caja) {
					caja.asignarNuevoNumeroACaja(con, CAJA_TIPO.DON);
					caja.setIdusuario(usuarioActual.getIdusuario());					
					canaima.guardar(caja);
					cajaActual = caja.getID();
				}
			} else {
				canaima.buscarPorID(cajaActual, caja);				
			}			
			cajaActual = caja.getID();			
			int loteActual = Lote.getLoteActual(con, caja.getID());
			if (loteActual == 0) {				
				//Crear un nuevo lote
				lote.asignarNuevoNumeroALote(con,cajaActual);
				lote.setIdcaja(cajaActual);
				canaima.guardar(lote);
				loteActual = lote.getID();	
			} else {
				canaima.buscarPorID(loteActual, lote);
				int numeroContratos = Contrato.getNumeroDeContratos(con, lote.getID());				
				if (numeroContratos == canaima.MAX_CONTRATOS_X_LOTE) {					
					//Nuevo lote
					int numeroLotes = Lote.getNumeroDeLotes(con, cajaActual);
					if (numeroLotes == canaima.MAX_LOTES_X_CAJA) {												
						caja.setIncidencia("Cerrada por máximo de lotes alcanzado");
						caja.cerrarCaja(con);
						
						//Crear una caja y un lote nuevo
						synchronized (caja) { 
							caja.setIdusuario(usuarioActual.getID());						
							caja.asignarNuevoNumeroACaja(con, CAJA_TIPO.DON);
							canaima.guardar(caja);
							cajaActual = caja.getID();
						}
					}
					//Crear un nuevo lote
					lote.asignarNuevoNumeroALote(con,cajaActual);
					lote.setIdcaja(cajaActual);
					canaima.guardar(lote);
					loteActual = lote.getID();			
				}
			}
			contrato.setIdlote(loteActual);
			contrato.validarContratoUnico(con);
			canaima.liberarConexion(con);
			
			//Intentar guardar el archivo
			if (archivo != null) {
				if (archivo.getSize() > 0) {						
					
					//Crear la carpeta				
					String directorio = canaima.DIRECTORIO_DONATARIO + "Caja " + caja.getNumero() + "/Lote " + lote.getNumero();
					Utilidades.crearDirectorio(directorio);				
					boolean existe = true;
					File archivo_fisico = null;				
					
					//Si el archivo existe
					if (existe) {
						archivo_fisico = new File(directorio, contrato.getNumero()+ ".pdf");
						if (archivo_fisico.exists()) {
							archivo_fisico.delete();
							archivo_fisico = new File(directorio, contrato.getNumero()+ ".pdf");
						}
					}														
					archivo.write(archivo_fisico);				
					
					FileInputStream fi = new FileInputStream(archivo_fisico);
					byte [] bytes = new byte [(int)archivo_fisico.length()];
					fi.read(bytes);
					fi.close();
					contrato.setDireccion(directorio + "/" + contrato.getNumero()+ ".pdf");
					contrato.setPdf(bytes);				
					canaima.guardar(contrato);			
					String nombreArchivo = "" + contrato.getNumero(), ext = ".pdf";			
					donatario.setIdcontrato(contrato.getID());
					canaima.actualizar(donatario);							
				} else {
					throw new ExcepcionValidaciones(contrato.errorEsObligatorio("Archivo"));
				}
			}
			mostrar = false;
			%>
				<jsp:include page="/WEB-INF/jsp/GeneradorMensaje.jsp">
					<jsp:param value="El Contrato ha sido Guardado" name="titulo"/>				
					<jsp:param value="Cierre esta ventana y continue Registrando" name= "texto"/>							
				</jsp:include>				
				<div id = scroll align="center">
				`	<h1>Ubicaci&oacute;n Física del Contrato:   Caja = <%=caja.getNumero()%>; Lote = <%= lote.getNumero()%>.</h1>
				</div>								
			<%
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


	Donatario donatario = new Donatario(); 
	if (idDonatario == 0) {	
		if (request.getParameter("iddonatario")!=null)
			idDonatario = Integer.parseInt(request.getParameter("iddonatario"));		
	}	
    canaima.buscarPorID(idDonatario, donatario);   	
    Connection con = canaima.solicitarConexion();						
	ArrayList<Equipo> equiposAsociados = Equipo.buscarEquipos(con, donatario.getID(), 0 , null);
	Equipo equipoAsociado = (equiposAsociados.size() > 0 ? equiposAsociados.get(0) : null);	
	canaima.liberarConexion(con);
	if (donatario.getIdcontrato()==0) {
%>
<body>
<br>
<div align="center" id="editar" class = "edicion">
<form action="RegistrarContrato.jsp"
method="post" 
enctype="multipart/form-data" 
accept-charset="text/plain" >
    <br><br>
    <table border="1">
       	<tr>
    		<td class = "a"> Nombre Donatario:</td>
    		<td><input tabindex="1" size="20" name = "nombre" 
    			value="<%= (donatario.getNombre() != null) ? donatario.getNombre() : ""%>" ></td>
    		<td class = "a"> ID Donatario</td>
    		<td><%= idDonatario %></td> 
    	</tr>
    	<tr>
    		<td class = "a">Nacionalidad Rep.</td>
    		<td align="center"><select name="representante_nac" tabindex="2">
					<option value ="<%= NACIONALIDAD.V %>"
					<%=(donatario.getRepresentante_nac() == NACIONALIDAD.V ? "selected=\"selected\"" : "")%>> V </option>
					<option value ="<%= NACIONALIDAD.E %>"
					<%=(donatario.getRepresentante_nac() == NACIONALIDAD.E ? "selected=\"selected\"" : "")%>> E </option>
				</select>
			</td>
    		<td class = "a">Cédula:</td>
    		<td><input tabindex="3" maxlength="10" type="text" name="representante_ci" size="20" value="<%= (donatario.getRepresentante_ci() != null) ? donatario.getRepresentante_ci() : ""%>" onKeypress="validarNumero(this)"></td>
    	</tr>
    	<tr>
    		<td class = "a">Nombre Rep.</td>
    		<td><input tabindex="4" size="20" name = "representante_nombre" value="<%= (donatario.getRepresentante_nombre() != null) ? donatario.getRepresentante_nombre() : ""%>"></td>
    		<td class = "a">Serial Equipo:</td>
    		<td><input tabindex="5" name="equipo_serial" size="20" value="<%= (equipoAsociado != null) ? equipoAsociado.getSerial() : ""%>"></td>
    	</tr>    	
    	<tr>
    		<td class = "a">Fecha de Entrada:</td>
    		<td><input tabindex="7" size="20" name="fecha_entrega" onclick="scwShow(this, event)" value="<%= (donatario.getFecha_entrega() != null) ? Utilidades.mostrarFecha(donatario.getFecha_entrega()) : ""%> "></td>
    		<td class = "a">Fecha de Llegada:</td>
    		<td><input tabindex="8" size="20" name="fecha_llegada" onclick="scwShow(this, event)" value="<%= (donatario.getFecha_llegada() != null) ? Utilidades.mostrarFecha(donatario.getFecha_llegada()) : ""%>"/></td>
    	</tr>
    	<tr align="center">
    		<td>
    			Tiene Firma:
    			<input tabindex="9" value="true" name = "tienefirma" type="checkbox" <%=donatario.isTienefirma() ? "checked=\"checked\"" : "" %>>
    		</td>
    		<td>
    			Tiene Cédula:
    			<input tabindex="10" value="true" name = "tienecedula" type="checkbox" <%=donatario.isTienecedula() ? "checked=\"checked\"" : "" %>>
    		</td>
    		<td>
    			Tiene Partida:
    			<input tabindex="11" value="true" name = "tienepartida" type="checkbox" <%=donatario.isTienepartida() ? "checked=\"checked\"" : "" %>>
    		</td>
    	</tr>
    	<tr>
    		<td class = "a">Observaciones:</td>
    		<td colspan="3"> <input tabindex="12" name="observacion" size="60" value="<%= (donatario.getObservacion() != null) ? donatario.getObservacion() : ""%>"></td>
    	</tr>
    	<tr>
    		<td class = "a">Nro. Contrato</td>
    		<td><input tabindex="6" size="20" name = "numero"></td>
    	</tr>
    	<tr>
    		<td class = "a">Archivo:</td>
    		<td colspan="3"><input type="file" name = "pdf" tabindex="13"></td>
    	</tr>
    	<tr>
    		<td colspan="4" align="center">
    			<INPUT type="hidden" value="<%= ESTADO.POR_GUARDAR %>" name="estado">
    			<INPUT type="hidden" value="<%= idDonatario %>" name="iddonatario">
    			<INPUT tabindex="14" type="submit" value="Aceptar Cambios" onclick="return validarContrato(form)"/>
    		</td> 
    	</tr>   	
    </table>
</form>		
</div>
</body>


<%} 
else
if (mostrar)
{%>
	<jsp:include page="/WEB-INF/jsp/GeneradorMensaje.jsp">
					<jsp:param value="Este Donatario ya posee Contrato Asociado" name="titulo"/>				
					<jsp:param value="Cierre esta ventana, Si Desea Cambiar el Número de Contrato o el Adjunto, dirigase a Consultar Contrato" name= "texto"/>
				</jsp:include>
<%}%>
</html>
