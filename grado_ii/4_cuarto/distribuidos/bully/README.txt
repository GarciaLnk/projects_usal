# Práctica de Sistemas Distribuidos
Programa en Java que implementa el algoritmo de elección distribuida bully para 
elegir un proceso coordinador entre un conjunto de procesos. Utiliza Jersey y Tomcat 
para implementar una API REST que ofrezca los servicios necesarios.

Autores: Alberto García Martín
         Víctor Rodríguez Mesonero

INSTRUCCIONES DE USO

Para ejecutar el programa hay que usar run.sh pasando como parámetros la dirección 
del gestor, y la dirección de cada servidor. Los archivos se desplegarán 
automáticamente donde sea necesario:

    ./run.sh -g gestor servidor1 [servidor2...]

Para desplegar los archivos por separado se puede ejecutar setup.sh pasando como 
parámetros la dirección del gestor y luego las direcciones de los servidores:

    ./setup.sh -g gestor servidor1 [servidor2...]
