# Práctica de Sistemas Distribuidos
Programa en Java que simula una carrera usando procesos que se ejecutan de forma 
paralela en múltiples hilos. Utiliza Jersey y Tomcat para implementar una API REST 
que ofrezca los servicios necesarios.

Autores: Alberto García Martín
         Víctor Rodríguez Mesonero

Para ejecutar el programa hay que usar run.sh pasando como parámetro la dirección 
del servidor, el número total de atletas de la carrera, la dirección de cada host 
y el número de atletas a crear por el host. Los archivos se desplegarán 
automáticamente donde sea necesario:

    ./run.sh -s servidor -n numAtletasTotal host1=numAtletasHost1 [host2=numAtletasHost2...]

Para desplegar los archivos por separado se puede ejecutar setup.sh pasando como 
parámetros la dirección del host servidor que alojará el servicio y luego los hosts 
donde se quiera desplegar el cliente:

    ./setup.sh -s servidor host1 [host2...]
