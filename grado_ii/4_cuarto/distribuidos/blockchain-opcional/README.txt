# Práctica de Sistemas Distribuidos
Proof-of-concept de una implementación de una red blockchain privada en una empresa para llevar un 
registro distribuido de su cadena de suministros.

Autores: Alberto García Martín
         Víctor Rodríguez Mesonero

Dependencias requeridas:
- Docker y Docker Compose
- Node.js
- Truffle
- cURL

* Red blockchain:
  Para iniciar la red blockchain hay que abrir el directorio network y ejecutar el script run.sh,
  ésto desplegará una red privada de Ethereum, usando como cliente Hyperledger Besu. Como protocolo
  de consenso utiliza un protocolo de autoridad (PoA) tolerante a fallas bizantinas llamado QBFT.

  cd network && ./run.sh

  La red estará compuesta por cinco nodos desplegados en contenedores Docker de los cuales cuatro serán
  nodos validadores y uno no-validador. Para parar y reanudar la blockchain almacenando su estado se
  pueden usar los scripts stop.sh y resume.sh.

* Smart contract:
  Se ha incluido un smart contract para ejemplificar el posible uso de una blockchain en una cadena de
  suministros (como puede ser la de una cadena de jamones, ya que es un producto de denominación de 
  origen cuya tracabilidad es importante). 

  Dentro del directorio de smart_contract se puede compilar el smart contract y desplegarlo en nuestra
  blockchain con los siguientes comandos:

    trufle compile
    truffle migrate --network wallet1

  Una vez desplegado podemos conectarlos a la blockchain usando una de las wallets predefinidas e
  interactuar con el contrato:

    # Para conectarnos como el fabricante (quien desplegó el contrato)
    truffle console --network wallet1

    # Para conectarnos como otro participante
    truffle console --network wallet2
    truffle console --network wallet3

  Desde la consola se pueden ejecutar las funciones del smart contract, por ejemplo para añadir
  un producto:

    let instance = await ProductContract.deployed()
    instance.addProduct("001","Jamón Ibérico","Bien",[""],"Guijuelo",["0xfe3b557e8fb62b89f4916b721be55ceb828dbd73","0x627306090abaB3A6e1400e9345bC60c78a8BEf57","0xf17f52151EbEF6C7334FAD080c5704D77216b732"])
