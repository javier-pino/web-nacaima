<%@page import="enums.CAJA_TIPO"%>
<%@page import="java.io.FileInputStream"%>
<%@ page import="java.io.File" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.io.FilenameUtils" %>
<%@ page import="beans.*"%>
<%@page import="java.sql.Connection"%>
<%@page import="aplicacion.ModeloCanaima"%>
<%@ page import="aplicacion.Utilidades"%>
<%@page import="java.sql.SQLException"%>
<%@page import="aplicacion.ExcepcionRoles"%>
<%@page import="aplicacion.ExcepcionValidaciones"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@page import="java.util.*" %>
<%@page import="enums.NACIONALIDAD"%>

<%@include file="/WEB-INF/jsp/IniciarModelo.jsp"%>

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

<%!
	public enum ESTADO {
		LISTADO,	
		POR_GUARDAR
	} 
%>
<%
	int idDocente = 0;
	boolean mostrar = false;
	Caja caja = null;
	Lote lote = null;
	ESTADO actual = ESTADO.LISTADO;
		
	if (request.getParameter("estado") != null) {
		actual = ESTADO.valueOf(request.getParameter("estado"));
	}		
	if (ServletFileUpload.isMultipartContent(request)) {
		actual = ESTADO.POR_GUARDAR; 	
	}	
	
	if (actual.equals(ESTADO.POR_GUARDAR)) {
		try {

			Docente docente = new Docente();
			int numeroContrato = 0;

			//Aqui almaceno la info necesaria hasta el ultimo momento
			FileItem archivo = null;
			ServletFileUpload fileUpload = new ServletFileUpload(new DiskFileItemFactory());
			List<FileItem> listaItems = fileUpload.parseRequest(request);
			FileItem item = null;
			FileItem item_serial = null;
			Iterator<FileItem> it = listaItems.iterator();
			Iterator<FileItem> it_seriales = listaItems.iterator();
			
			//Se leen por completo los valores
			ArrayList<String> equipos = new ArrayList<String>();
			
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
					} else if (item.getFieldName().startsWith("serial_")) {
						if (item.getString() != null && !item.getString().trim().isEmpty()) {
							equipos.add(item.getString());
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

					if(archivo.getSize()>0){
						String ext = "." + FilenameUtils.getExtension(archivo.getName());
						if (!ext.equals(".pdf")) 
							throw new ExcepcionValidaciones("El archivo adjunto debe tener extensi&oacute;n .pdf");
					}
				}				
			}
			//Si el docente tiene un colegio no importa lo demas
			if (docente.getIdcolegio() > 0) {
				Colegio col = new Colegio();
				canaima.buscarPorID(docente.getIdcolegio(), col);
				docente.setIdestado(col.getIdestado());
				docente.setIdmunicipio(col.getIdmunicipio());
				docente.setIdparroquia(col.getIdparroquia());
			}
			
			//Verificacion de la cedula del representante
			if (docente.getCedula() == null || docente.getCedula().isEmpty())			
				docente.setNacionalidad(null);
			
			docente.setIdcreadopor(canaima.getUsuarioActual().getID());
			
			//if (equipos.size()<=0)
				//throw new ExcepcionValidaciones(docente.errorEsObligatorio("Nro de Serial de equipo > 0"));
			
			//TODO VERIFICAR SERIALES REPETIDOS
			Equipo equipo = null;
			Connection con = canaima.solicitarConexion();
			for(int i=0; i<equipos.size(); i++){
				equipo = new Equipo();
				equipo.setSerial(equipos.get(i));
				equipo.validarSerialUnico(con);
			}
			canaima.liberarConexion(con);
			
			//Debe ser posible guardar los cambios						
			canaima.guardar(docente);
			
			//Guardar Equipos
			for(int i=0; i<equipos.size(); i++){
				
				equipo = new Equipo();
				equipo.setIddocente(docente.getID());
				equipo.setSerial(equipos.get(i));
				canaima.guardar(equipo);
			}
			
			//if (numeroContrato == 0)
				//throw new ExcepcionValidaciones(docente.errorEsObligatorio("Nro Contrato"));
			
			//Aqui se valida si no tiene el mismo nombre y cedula
			con = canaima.solicitarConexion();
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
					//canaima.guardar(contrato);			
					String nombreArchivo = "" + contrato.getNumero(), ext = ".pdf";			
					//docente.setIdcontrato(contrato.getID());
					//canaima.actualizar(docente);							
				} else {
					//throw new ExcepcionValidaciones(contrato.errorEsObligatorio("Archivo"));
				}
			}
			
			canaima.guardar(contrato);
			docente.setIdcontrato(contrato.getID());
			canaima.actualizar(docente);
			
			%>		
				<jsp:include page="/WEB-INF/jsp/GeneradorMensaje.jsp">
					<jsp:param value="El Docente ha sido Guardado" name="titulo"/>				
					<jsp:param value="Cierre esta ventana y continue Registrando" name= "texto"/>							
				</jsp:include>						
			<%
			
		mostrar = true;	
			
		} catch (ExcepcionValidaciones val) {
			request.setAttribute("validaciones", val.getValidacionesIncumplidas());
			pageContext.include("/WEB-INF/jsp/GeneradorMensaje.jsp", true);					
		} catch (Exception exc) {	
			exc.printStackTrace();		
			request.setAttribute("excepcion", exc);
			pageContext.include("/WEB-INF/jsp/GeneradorMensaje.jsp", true);
		}		
	}
	Docente ultimo = canaima.getUltimoDocen();
%>
<div class="Part" >
<h2>Registrar</h2>

&nbsp;			
	<%	if(mostrar){
	%>
				<div id ="estadisticas" align="center">
					<br>
					<h1>Ubicaci&oacute;n Física del Contrato:   Caja = <%=caja.getNumero()%>; Lote = <%= lote.getNumero()%>.</h1>
				</div>
	<% 	}		
	%>	

&nbsp;  
<div align="left" id="scroll2">
<form name="lista" action="agregarDocente.jsp" method="post" 
enctype="multipart/form-data" 
autocomplete="off">
<table id="fila_direccion">
	<tr class="a">
		<td>Estado</td>
		<td>Municipio</td>
		<td>Parroquia</td>
		<td>Ciudad</td>		
	</tr>	
	<tr >
		<td>			
			<SELECT tabindex="1" name="idestado" title="estado" style="width: 150px;"  onchange="javascript:mostrarMunicipios(this.value);">
			<%
				int idEstado;
				String nombreEstado = null;
				Estado estado = new Estado();
				Connection con = canaima.solicitarConexion();				
				ArrayList<Estado> estados = Estado.listarEstados(con);
				canaima.liberarConexion(con);
				out.write("<option value=\"" + 0 + "\">--Seleccione--</option>");
				for (int i=0; i < estados.size(); i++) {
					if (ultimo.getIdestado() > 0 && ultimo.getIdestado() == estados.get(i).getID())
						out.write("<option value=\"" + estados.get(i).getID() + "\" selected=\"selected\" >" + estados.get(i).getNombre()  + "</option>");
					else 
						out.write("<option value=\"" + estados.get(i).getID() + "\" >" + estados.get(i).getNombre()  + "</option>");
	   			}
        	%>
			</SELECT>
		</td>
		<td id= "municipios">
			<SELECT tabindex="2" id="idmunicipio" name="idmunicipio" title="municipio" style="width: 150px;" onchange="javascript:mostrarParroquias(this.value);">
			<%					
			if (ultimo.getID() > 0 && ultimo.getIdestado() > 0) {
				con = canaima.solicitarConexion();				
				ArrayList<Municipio> municipios = Municipio.listarMunicipiosPorEstado(ultimo.getIdestado(), con);
				canaima.liberarConexion(con);
				out.write("<option value=\"" + 0 + "\">--Seleccione--</option>");
				for (int i=0; i < municipios.size(); i++) {
					if (ultimo.getIdmunicipio() > 0 && ultimo.getIdmunicipio() == municipios.get(i).getID())
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
		<td id= "parroquias">
			<SELECT tabindex="3" name="idparroquia" title="parroquia" style="width: 150px;" >
			<%					
			if (ultimo.getID() > 0 && ultimo.getIdmunicipio() > 0) {
				con = canaima.solicitarConexion();				
				ArrayList<Parroquia> parroquias = Parroquia.listarParroquiasPorMunicipios(ultimo.getIdmunicipio(), con);
				canaima.liberarConexion(con);
				out.write("<option value=\"" + 0 + "\">--Seleccione--</option>");
				for (int i=0; i < parroquias.size(); i++) {
					if (ultimo.getIdparroquia() > 0 && ultimo.getIdparroquia() == parroquias.get(i).getID())
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
		<td>
			<input tabindex="4" name="ciudad" size="36" value="<%= (ultimo.getCiudad() != null) ? ultimo.getCiudad() : ""%>">
		</td>
		</tr>
</table>
<br>
<table id="fila_colegio">		
	<tr class="a"> 
		<td>Colegio</td>
		<td class="b">Nombre</td>
		<td class="b" height="10" width="80">Nacionalidad</td>
		<td class="b" height="10" width="80">Cédula</td>
	</tr>
	<tr>
		<td>
				<input type="text" size="71" name="colegiotexto" id="colegiotexto" />
				<input type="hidden" name="idcolegio" id="idcolegio" />
		</td>
		<td class="b" height="15" width="90">
			<input tabindex="12" type="text"  size="28"	name="nombre">
		</td>
		<td align="center">
			<select tabindex="13" name="nacionalidad">
				<option value ="<%= NACIONALIDAD.V %>"> V </option>
				<option value ="<%= NACIONALIDAD.E %>"> E </option>
			</select></td>
		<td class="b">
			<input tabindex="14" maxlength="10" size="15" type="text" name="cedula" size="8" onKeypress="validarNumero(this)"></td>
	</tr>
</table>
<br>
<table id="fila_fechas">
	<tr>
		<td class = "a">Proveedor</td>
    	<td class = "a">Fecha de Entrega:</td>
    	<td class = "a">Fecha de Llegada:</td>
    	<td class = "a">Observaciones:</td>
    </tr>
    <tr>
   	 	<td class="b">
			<input tabindex="18" type="text" name="proveedor" size="25" value="<%= (ultimo.getProveedor() != null) ? ultimo.getProveedor() : ""%>">
		</td>
     	<td>
     		<input tabindex="7" size="20" name="fecha_entrega" onclick="scwShow(this, event)" value="">
     	</td>
    	<td>
    		<input tabindex="8" size="20" name="fecha_llegada" onclick="scwShow(this, event)" value="">
    	</td>
		<td>
			<input tabindex="12" name="observacion" size="60" value="">
		</td>   
    </tr>
</table>
<br>
<table id="fila_fechas">
    <tr>
    	<td class = "a">Nro. Contrato</td>
    	<td class = "a">Archivo:</td>
    	<td class = "a"></td>
    	<td class = "a"></td>
    </tr>
    <tr>

    	<td>
    		<input tabindex="6" size="20" name = "numero" value="" onKeypress="validarNumero(this)">
    	</td>
    	<td>
    		<input type="file" name = "pdf" tabindex="13">
    	</td>
    	<td align="center">
			<INPUT type="hidden" value="<%= ESTADO.POR_GUARDAR %>" name="estado">
			<INPUT tabindex="19" type="submit" value="Aceptar" name="aceptar">
			<INPUT tabindex="20" type="button" value="Limpiar Colegio" name="limpiar" onclick="limpiarColegio(form)">
		</td> 
    </tr>
</table>
<br>
<table id="fila_fechas">
	<tr>
		<td class = "a">Serial Equipo</td>
	</tr>
	<tr>
		<td>
 			<div id="attachment_container">
				<input type="hidden" value="1" id="serial_contador" />
    				<div id="attachment_1" class="attachment">
    					<input type="text" size="24" name="serial_1"/><a href="" onClick="removeAttachmentElement(1);return false;"><img id="RemoveButton_1" src="img/minusButton.png" onMouseDown="this.src='img/minusButtonDown.png';" onMouseUp="this.src='img/minusButton.png';" alt="Remove" /></a>
    				</div>
			</div>
			<a href="" onClick="addAttachmentElement();return false;"><img id="AddButton_1" src="img/plusButton.png" onMouseDown="this.src='img/plusButtonDown.png';" onMouseUp="this.src='img/plusButton.png';" alt="Add" /></a>
    	</td>
	</tr>
</table>
</form>
</div>
<br>
<script type="text/javascript">
$(document).ready(function() {
	$("a.docente_link").fancybox({
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

<div id="scroll">
<table id="fila_docente">
	<tr>
		<td class="a" colspan="12" >&Uacute;LTIMOS <%= ModeloCanaima.TAM_RECIENTES%> DOCENTES REGISTRADOS</td>
	</tr>
	<tr class="w" align="center">
		<td class = "largo">ID</td>
		<td class = "largo">Nombre</td>
		<td class = "largo">Colegio</td>		
		<td class = "largo">Cédula</td>
	</tr>
	<% 	
	Docente d = null;
	Colegio cole = null;
		
	ListIterator<Docente> recientes = Docente.getRecientes(con).listIterator(Docente.getRecientes(con).size());
	
	while (recientes.hasPrevious()) {
		d = recientes.previous();
		cole = new Colegio();
		canaima.buscarPorID(d.getIdcolegio(),cole);
		if (!d.isActivo()) 
			continue;
	%>
	<tr class = "largo">
		<td class = "largo"><%=aFancyBox(response, "" + d.getID(), d.getID())%> </td>
		<td class = "largo"><%=aFancyBox(response, d.getNombre(), d.getID())%> </td>
		
		<%
			if (cole.getID() > 0)	{			
		%>		
		<td class = "largo"><%=aFancyBox(response, cole.getNombre(), d.getID())%> </td>
		<%
			} else {
		%>	
		<td class = "largo"> </td>
		<%
			}
		%>
		<%		
			if (d.getCedula() != null && !d.getCedula().isEmpty()) {		
		%>		
		<td class = "largo"><%=aFancyBox(response, d.getNacionalidad() + "-" + d.getCedula(), d.getID())%> </td>
		<%}else{ %><td class = "largo"> </td> <% } %>
	</tr>
	<%		
	}
	%>
</table>
</div>
&nbsp;
</div>

<%! 
	public String aFancyBox (HttpServletResponse response, String texto, int id) {
		String resultado = 			
			"<a href = \"" + response.encodeURL("editarDocente.jsp?iddocente=" + id) 
				+ 	"\" class = \"docente_link\">" + texto +"</a>"
			;
		return resultado;
	} 
%>