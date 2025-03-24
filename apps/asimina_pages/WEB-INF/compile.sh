cd /home/etn/tomcat/webapps/dev_pages/WEB-INF/classes
javac -Xlint:unchecked -cp /home/etn/tomcat/lib/servlet-api.jar:../lib/*:/home/etn/tomcat/webapps/dev_pages/WEB-INF/classes/ $(find . -name '*.java')
# for javac version <1.6 , does not support * in classpath
# javac -Xlint:unchecked -cp /home/ronaldo/tomcat/lib/servlet-api.jar:../lib/gson-2.3.jar:../lib/etnutf8.jar:../lib/commons-codec-1.9.jar:/home/tomcat/webapps/dev_pages/WEB-INF/classes/ $(find . -name '*.java')
