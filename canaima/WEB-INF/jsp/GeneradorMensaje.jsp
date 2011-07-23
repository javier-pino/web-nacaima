<%@page import="java.beans.Visibility"%>
<%@page import="java.util.ArrayList"%>
<%@page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>

<%	
	final int MAX_VALIDACIONES = 7;
	if (request.getAttribute("validaciones") != null) {		
		ArrayList<String> validaciones = (ArrayList<String>)request.getAttribute("validaciones");			
		for (int visitados = 0; visitados < validaciones.size() ; visitados++ ) {
			if (visitados % MAX_VALIDACIONES == 0) {
				if (visitados == 0) { 
					out.println("<div class=\"TopPart\" id= \"toppart\">");
					out.println("<h2>Las siguientes validaciones fueron incumplidas</h2><br>");
				} else {
					out.println("</div>");
					out.println("<div class=\"TopPart\" id= \"toppart\" >");
				}
			}
			out.println("<p class = \"Larger\">" + validaciones.get(visitados)+ "</p>");
		}		
		out.println("</div>");		
	} else if (request.getAttribute("excepcion") != null){
		Exception e = (Exception)request.getAttribute("excepcion");
		out.println("<div class=\"TopPart\" id= \"toppart\">");
		out.println("<h2>Error</h2><br>");
		out.println("<p class = \"Larger\">" +  e.getMessage() + "</p>");		
		out.println("</div>");
	} else if (request.getAttribute("excepcioncapturada") != null){		
		out.println("<div class=\"TopPart\" id= \"toppart\">");
		out.println("<h2> " + request.getAttribute("excepcioncapturada") +"</h2><br>");
		out.println("<p class = \"Larger\">" + request.getAttribute("excepcioncapturadatexto")  + "</p>");		
		out.println("</div>");
	} else {
		String titulo = request.getParameter("titulo");
		String texto[] = request.getParameterValues("texto");
		
		for (int visitados = 0; visitados < texto.length ; visitados++ ) {
			if (visitados % MAX_VALIDACIONES == 0) {
				if (visitados == 0) { 
					out.println("<div class=\"TopPart\" id= \"toppart\" >");
					out.println("<h2>" + titulo + "</h2><br>");
				} else {
					out.println("</div>");
					out.println("<div class=\"TopPart\" id= \"toppart\" >");
				}
			}
			out.println("<p class = \"Larger\">" + texto[visitados]+ "</p>");
		}		
		out.println("</div>");
	}
%>
<p id = "espacio">&nbsp;</p>
<script>
	$('#toppart').click(function() {
	  $('#toppart').hide('slow');
	  $('#espacio').hide('slow');
	});
</script>	
