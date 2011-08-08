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
	ESTADO actual = ESTADO.LISTADO;
	if (request.getParameter("estado") != null) {
		actual = ESTADO.valueOf(request.getParameter("estado"));
	}		
	if (actual.equals(ESTADO.POR_GUARDAR)) {
		
		int idDocente = 0;
		if (request.getParameter("iddocente")!=null)
			idDocente = Integer.parseInt(request.getParameter("iddocente"));
	
		try {				

			
			Docente docente = new Docente();
			int numeroContrato = 0;

			//Aqui almaceno la info necesaria hasta el ultimo momento
			FileItem archivo = null;
			ServletFileUpload fileUpload = new ServletFileUpload(new DiskFileItemFactory());
			List<FileItem> listaItems = fileUpload.parseRequest(request);
			FileItem item = null;
			Iterator<FileItem> it = listaItems.iterator();
			
			//Se leen por completo los valores
			it = listaItems.iterator();
			while (it.hasNext()) {
				item = (FileItem)it.next();
				if (item.isFormField()) {
					if (item.getFieldName().equals("nombre") ) {						
						if (item.getString() != null && !item.getString().trim().isEmpty())
							docente.setNombre(item.getString());
					} else if (item.getFieldName().equals("nacionalidad")) {
						if (item.getString() != null && !item.getString().trim().isEmpty())
							docente.setNacionalidad(item.getString());
					} else if (item.getFieldName().equals("idestado")) {
						if (item.getString() != null && !item.getString().trim().isEmpty())
							docente.setIdestado(Integer.parseInt(item.getString()));
					} else if (item.getFieldName().equals("idmunicipio")) {
						if (item.getString() != null && !item.getString().trim().isEmpty())
							docente.setIdmunicipio(Integer.parseInt(item.getString()));
					}else if (item.getFieldName().equals("idparroquia")) {
						if (item.getString() != null && !item.getString().trim().isEmpty())
							docente.setIdparroquia(Integer.parseInt(item.getString()));
					}else if (item.getFieldName().equals("idcolegio")) {
						if (item.getString() != null && !item.getString().trim().isEmpty())
							docente.setIdcolegio(Integer.parseInt(item.getString()));
					}else if (item.getFieldName().equals("proveedor")) {
						if (item.getString() != null && !item.getString().trim().isEmpty())
							docente.setProveedor(item.getString());
					}else if (item.getFieldName().equals("ciudad")) {
						if (item.getString() != null && !item.getString().trim().isEmpty())
							docente.setCiudad(item.getString());
					} else if (item.getFieldName().equals("cedula")) {
						if (item.getString() != null && !item.getString().trim().isEmpty())
							docente.setCedula(item.getString());						
					} else if (item.getFieldName().equals("equipo_serial")) {
						if (item.getString() != null && !item.getString().trim().isEmpty()) {
							
							//TODO EQUIPOS
						}
					} else if (item.getFieldName().equals("fecha_entrega")) {
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
					String ext = "." + FilenameUtils.getExtension(archivo.getName());
					if (!ext.equals(".pdf")) 
						throw new ExcepcionValidaciones("El archivo adjunto debe tener extensi&oacute;n .pdf");
				}				
			}
			
			//Verificacion de la cedula del representante
			if (docente.getCedula() == null || docente.getCedula().isEmpty())			
				docente.setNacionalidad(null);
			
			docente.setIdcreadopor(canaima.getUsuarioActual().getID());
			
			//Debe ser posible guardar los cambios						
			canaima.guardar(docente);
			
			if (numeroContrato == 0)
				throw new ExcepcionValidaciones(docente.errorEsObligatorio("Nro Contrato"));
			
			//Aqui se valida si no tiene el mismo nombre y cedula
			Connection con = canaima.solicitarConexion();
			docente.validarCedulaRepNombreDocente(con);			
			canaima.liberarConexion(con);
						
			//Variables de negocio caja, lote y contrato
			Contrato contrato = new Contrato();
			contrato.setNumero(numeroContrato);			
			caja = new Caja();
			lote = new Lote();
						
			//Se obtiene la información actual
			Usuario usuarioActual = canaima.getUsuarioActual(); 
			con = canaima.solicitarConexion();
			
			int cajaActual = Caja.getUltimaCajaRegistrada(con, usuarioActual, CAJA_TIPO.DOC);			
			if (cajaActual == 0) {
				synchronized (caja) {
					caja.asignarNuevoNumeroACaja(con, CAJA_TIPO.DOC);
					caja.setTipo(CAJA_TIPO.DOC);
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
							caja.asignarNuevoNumeroACaja(con, CAJA_TIPO.DOC);
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
					String directorio = canaima.DIRECTORIO_DOCENTE + "Caja " + caja.getNumero() + "/Lote " + lote.getNumero();
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
					docente.setIdcontrato(contrato.getID());
					canaima.actualizar(docente);							
				} else {
					throw new ExcepcionValidaciones(contrato.errorEsObligatorio("Archivo"));
				}
			}
			
			
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
<form>
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
    	</tr>
    	<tr>
    		<td class = "a">Serial Equipo:</td>
    <%
	  	//Buscar el serial de equipo
		con = canaima.solicitarConexion();
		ArrayList<Equipo> equiposAsociados = Equipo.buscarEquipos(con, docente.getID(), 0 , null);
		Equipo equipoAsociado = (equiposAsociados.size() > 0 ? equiposAsociados.get(0) : null);
		canaima.liberarConexion(con);
    %>		
    		<td> <input tabindex="15" name="equipo_serial" size="28" value="<%= (equipoAsociado != null) ? equipoAsociado.getSerial() : ""%>"></td>
    	</tr>
    	<tr>
    		<td class = "a">Proveedor:</td>
    		<td><input tabindex="18" name="proveedor" size="28" value="<%= (docente.getProveedor() != null) ? docente.getProveedor() : ""%>"></td>
    	</tr>
    	<tr>
    		<td class = "a">Observaciones:</td>
    		<td colspan="4"> <input tabindex="19" name="observacion" size="75" value="<%= (docente.getObservacion() != null) ? docente.getObservacion() : ""%>"></td>
    	</tr>
    	<tr>
    		<td colspan="4" align="center">
    			<INPUT type="hidden" value="<%= ESTADO.POR_GUARDAR %>" name="estado">
    			<INPUT type="hidden" value="<%= idDocente %>" name="iddocente">    			
    			<INPUT tabindex="20" type="submit" value="Aceptar Cambios"/>
    			<INPUT tabindex="21" type="reset"  value="Eliminar Docente" id= "botonEliminar" />
    		</td>    
    	<tr>	
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
	   		<td class = "a"> ID Donatario</td>
	   		<td class = "extralargo"><%= idDocente %></td>
	   		<td class = "a"> Nombre Docente:</td>
	   		<td class = "extralargo" ><%=(docente.getNombre() != null) ? docente.getNombre() : ""%></td>
	   		
	   	</tr>
	   	<tr>
	   		<td class = "a">Nacionalidad Rep.</td>
	   		<td class = "extralargo"><%=NACIONALIDAD.mostrar(docente.getNacionalidad())%></td>
	   		<td class = "a">Cédula:</td>
	   		<td class = "extralargo"><%= (docente.getCedula() != null) ? docente.getCedula() : ""%></td>
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