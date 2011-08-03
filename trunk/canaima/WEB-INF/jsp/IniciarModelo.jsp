<%@page import="beans.Usuario"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" %>
<%@ page session="true" %>

<%--  
	El modelo se declara para que una sóla vez en la sesión se cree un modelo.
	Nos aseguramos al incluir esto en todas las páginas de la aplicación
	Dejandola disponible en caso de que ya haya sido creada.
--%> 
<jsp:useBean id="canaima" class="aplicacion.ModeloCanaima" scope="session"/>


	
