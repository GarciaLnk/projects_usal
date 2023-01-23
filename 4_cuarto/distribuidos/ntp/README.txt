# Práctica de Sistemas Distribuidos
Programa en Java que implementa el algoritmo de sincronización de reloj empleado 
por NTP y el filtrado de pares de Marzullo. Utiliza Jersey y Tomcat para implementar 
una API REST que ofrezca los servicios necesarios.

Autores: Alberto García Martín
         Víctor Rodríguez Mesonero

Para ejecutar el programa hay que usar run.sh pasando como parámetro la dirección 
del cliente y la dirección de cada servidor. Los archivos se desplegarán 
automáticamente donde sea necesario:

    ./run.sh -c cliente servidor1 [servidor2...]

Para desplegar los archivos por separado se puede ejecutar setup.sh pasando como 
parámetros la dirección del cliente y luego los servidores deseados:

    ./setup.sh -l cliente servidor1 [servidor2...]
