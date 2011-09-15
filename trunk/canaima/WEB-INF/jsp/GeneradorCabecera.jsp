<%@page import="java.util.Calendar"%>
<%@page import="java.util.Date"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
	
<!doctype html public "-//W3C//DTD HTML 4.01//EN">
<head>
<meta http-equiv="Content-language" content="cs" >
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" >
<meta name="description" content="" >
<meta name="keywords" content="" >
<title>Canaima - Intranet</title>
<link rel="stylesheet" type="text/css" href="css.css" >
<link href="estilos.css" rel="stylesheet" type="text/css">
<script language="JavaScript" type="text/javascript" src="scw.js"></script>
<script language="JavaScript" type="text/javascript" src="codigo.js"></script>
<script language="JavaScript" type="text/javascript" src="js/jquery-1.5.2.js"></script>
<script language="JavaScript" type="text/javascript" src="js/jquery.fancybox/jquery.fancybox-1.3.1.pack.js"></script>

 <script language="javascript" type="text/javascript">  
   
		var RelojID12 = null;
		var RelojEjecutandose12 = false;  
  
		function DetenerReloj12 () {  
    		if(RelojEjecutandose12)  
       		 clearTimeout(RelojID12);  
    		RelojEjecutandose12 = false;  
		}  
  
		function MostrarHora12 () {  
    		var ahora = new Date()  
    		var horas = ahora.getHours()  
    		var minutos = ahora.getMinutes()  
    		var segundos = ahora.getSeconds()  
    		var meridiano;  
   
   			 if (horas > 12) {  
        		horas -= 12;  
        		meridiano = " P.M."  
    		 } else {  
        		meridiano = " A.M."  
        	}  
              
    		 
    		if (horas < 10)  
        		ValorHora = "0" + horas  
    		else  
        		ValorHora = "" + horas  
  
    		  
    		if (minutos < 10)  
        		ValorHora += ":0" + minutos  
    		else  
        		ValorHora += ":" + minutos  
              
    		 
    		if (segundos < 10)  
        		ValorHora += ":0" + segundos  
    		else  
        		ValorHora += ":" + segundos  
          
    		ValorHora += meridiano  
    		document.reloj12.digitos.value = ValorHora  
  
    		RelojID12 = setTimeout("MostrarHora12()",1000)  
    		RelojEjecutandose12 = true  
		}  
  
		function IniciarReloj12 () {  
    	DetenerReloj12()  
    	MostrarHora12()  
	}  
  
	window.onload = IniciarReloj12;  
	if (document.captureEvents) {           
    	document.captureEvents(Event.LOAD)  
	}  
  
  
</script>

<script language="javascript" type="text/javascript">

	function obtiene_fecha() {
		
		var fecha_actual = new Date()
	
		var dia = fecha_actual.getDate()
		var mes = fecha_actual.getMonth() + 1
		var anio = fecha_actual.getFullYear()
	
		if (mes < 10)
			mes = '0' + mes
	
		if (dia < 10)
			dia = '0' + dia
	
		return (dia + "/" + mes + "/" + anio)
	}
	
	function MostrarFecha() {
	   document.write ( obtiene_fecha() )
	}

</script>

<link rel="stylesheet" href="js/jquery.fancybox/jquery.fancybox-1.3.1.css" type="text/css" media="screen" />
</head>
	<body>

<div id=WholePage>

	<div id="Container">
	
	    <div id="Top">
	    	    
	        <div id="Header">
	        <div id="RightHeader">        
	       <table>
	       <tr>
	       <td><h2> <font color="white"> Cooperativa Telgeclap r.s. </font></h2></td>
	       <td rowspan="3"><img src="img/fotoTelg.png" class="foto" /></td>
	       </tr>
	       <tr>
	       <td>
		  		<!-- Para visualizar el reloj -->    
				<div class="recuadro3">  
				<form name="reloj12">  
				<font color="white" >
				Hora:
				<input type="text" size="09" name="digitos"  style="border: none; color: #FFFFFF ; background-color: #4BBFFF">  
				Fecha:
				<script language="JavaScript" type="text/javascript">
				MostrarFecha();
				
				</script> 
				</font>
				</form> 		
				</div>
	       </td>
	       </tr>
	       <tr>
	       <td><span class="adress"><%= application.getInitParameter("servidorAplicacion") %></span></td>
	       </tr>
	       </table>
	        
	        </div>
	        
			<img src="img/fotoCanaima.png" class="foto" /> 
			<br/>
	        <span class="adress">cooptelgeclap@gmail.com.ve</span>

	    	</div>	    	
	    	<div id="Inter">
	    	<ul>
	    		<li> </li>
		        <li>Proyecto Canaima: </li>
		        <li>Uso Educativo de las Tecnolog&iacute;as de la Informaci&oacute;n y la Comunicaci&oacute;n (TIC).</li>       
        	</ul>
        	</div> 
        	