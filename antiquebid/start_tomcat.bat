@echo off
set "JAVA_HOME=D:\Java"
set "CATALINA_HOME=D:\Setup\apache-tomcat-11.0.20-windows-x64\apache-tomcat-11.0.20"
cd /d "D:\Setup\apache-tomcat-11.0.20-windows-x64\apache-tomcat-11.0.20\bin"
call catalina.bat run
