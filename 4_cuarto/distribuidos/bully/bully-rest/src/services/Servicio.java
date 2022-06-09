package services;

import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Queue;
import java.util.concurrent.Callable;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;
import javax.inject.Singleton;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.client.WebTarget;
import javax.ws.rs.core.MediaType;

@Singleton
@Path("")
public class Servicio {
  private final AtomicInteger id = new AtomicInteger(0);
  private final Queue<String> listaServidores = new ConcurrentLinkedQueue<>();
  private final Map<Integer, Proceso> mapaIdProceso = new ConcurrentHashMap<>();
  private final Client client = ClientBuilder.newClient();
  private String miDireccion;
  private final ExecutorService executor = Executors.newCachedThreadPool();

  // Función para mandar llamadas REST de forma asíncrona con timeouts al resto de servidores en
  // listaServidores, la salida de las llamadas se almacena en listaFutures
  // - path: dirección al método REST
  // - timeout: valor en ms del timeout
  public List<Future<String>> multicastHandler(String path, Integer timeout)
      throws InterruptedException, ExecutionException {
    List<Future<String>> listaFutures;
    Collection<Callable<String>> coleccionLlamadas = new CopyOnWriteArrayList<>();

    for (String servidor : listaServidores) {
      if (!servidor.equals(miDireccion)) {
        coleccionLlamadas.add(() -> {
          WebTarget target = client.target("http://" + servidor + ":8080/bully-rest");
          return target.path(path).request(MediaType.TEXT_PLAIN).get(String.class);
        });
      }
    }

    listaFutures = executor.invokeAll(coleccionLlamadas, timeout, TimeUnit.MILLISECONDS);
    return listaFutures;
  }

  // Función para añadir servidores a listaServidores a partir de una única String con cada
  // dirección separada por un newline, también almacena la propia dirección del servidor
  // + addresses: String con las direcciones de los servidores
  // + to: String con la dirección del propio servidor que recibe la llamada
  @Path("addservers")
  @GET
  @Produces(MediaType.TEXT_PLAIN)
  public String addServidores(@QueryParam("addresses") String direcciones,
      @QueryParam("to") String miDireccion) {
    String[] arrayDirecciones = direcciones.split("\n");

    for (String direccion : arrayDirecciones) {
      if (!listaServidores.contains(direccion)) {
        listaServidores.add(direccion);
      }
    }
    this.miDireccion = miDireccion;
    return "";
  }

  // Función para hacer la difusión a todos los servidores de la llamada que obtiene el valor
  // computar del proceso coordinador
  // - coordinador: entero con el ID del coordinador
  public Integer computar(Integer coordinador) throws InterruptedException, ExecutionException {
    int valorComputar = Integer.parseInt(getValorComputar(coordinador));

    if (valorComputar < 0) {
      List<Future<String>> listaFutures = multicastHandler("valuecomputar/" + coordinador, 1000);
      for (Future<String> future : listaFutures) {
        if (!future.isCancelled() && Integer.parseInt(future.get()) > 0) {
          valorComputar = 1;
          break;
        }
      }
    }

    return valorComputar;
  }

  // Función para obtener el valor de computar
  // - coordinador: entero con el ID del coordinador
  @Path("valuecomputar/{id}")
  @GET
  @Produces(MediaType.TEXT_PLAIN)
  public String getValorComputar(@PathParam("id") Integer coordinador) {
    if (mapaIdProceso.containsKey(coordinador)) {
      return mapaIdProceso.get(coordinador).computar().toString();
    }

    return "-1";
  }

  // Función para hacer la difusión a todos los servidores de la llamada que inicia la elección
  // - originid: entero con el ID del proceso que inicia la elección
  public void iniciarEleccionTodos(Integer originid)
      throws InterruptedException, ExecutionException {
    iniciarEleccion(originid);
    multicastHandler("startelection/" + originid, 1000);
  }

  // Función que inicia la elección en los procesos cuyo ID sea mayor al ID del proceso que inicia
  // la elección
  // - originid: entero con el ID del proceso que inicia la elección
  @Path("startelection/{originid}")
  @GET
  @Produces(MediaType.TEXT_PLAIN)
  public String iniciarEleccion(@PathParam("originid") Integer originid)
      throws InterruptedException, ExecutionException {
    for (Proceso proceso : mapaIdProceso.values()) {
      if (proceso.getId() > originid && proceso.isActivo()) {
        enviarTodosRespuesta(originid);
        proceso.eleccion();
      }
    }
    return "";
  }

  // Función para hacer la difusión a todos los servidores de la llamada que envía la respuesta "OK"
  // - id: entero con el ID del proceso al que se envía la respuesta
  public void enviarTodosRespuesta(Integer id) throws InterruptedException, ExecutionException {
    if (!enviarRespuesta(id)) {
      multicastHandler("sendrespuesta/" + id, 1000);
    }
  }

  // Función que envía la respuesta al proceso indicado, al enviar la respuesta hace un notify sobre
  // el lock indicado, liberándolo
  // - id: entero con el ID del proceso al que se envía la respuesta
  @Path("sendrespuesta/{id}")
  @GET
  @Produces(MediaType.TEXT_PLAIN)
  public boolean enviarRespuesta(@PathParam("id") Integer id) {
    if (mapaIdProceso.containsKey(id)) {
      Proceso proceso = mapaIdProceso.get(id);
      proceso.setRespuesta(true);
      synchronized (proceso.respuestaLock) {
        proceso.respuestaLock.notifyAll();
      }
      return true;
    }
    return false;
  }

  // Función para hacer la difusión a todos los servidores de la llamada que envía el mensaje
  // coordinador
  // - id: entero con el ID del proceso que será el nuevo coordinador
  public void setTodosCoordinador(Integer coordinador)
      throws InterruptedException, ExecutionException {
    setCoordinador(coordinador);
    multicastHandler("setcoordinador/" + coordinador, 1000);
  }

  // Función que envía el mensaje coordinador a todos los procesos del servidor y actualiza el valor
  // IdCoordinador de cada proceso
  // - id: entero con el ID del proceso que será el nuevo coordinador
  @Path("setcoordinador/{coordinador}")
  @GET
  @Produces(MediaType.TEXT_PLAIN)
  public String setCoordinador(@PathParam("coordinador") Integer coordinador) {
    for (Proceso proceso : mapaIdProceso.values()) {
      if (proceso.isActivo()) {
        synchronized (proceso.coordinadorLock) {
          proceso.setCoordinador(coordinador);
          proceso.setIdCoordinador(coordinador);
          proceso.coordinadorLock.notifyAll();
        }
      }
    }
    return "";
  }

  // Función para obtener el valor del ID más alto entre todos los servidores, una vez obtenido
  // refresca la variable id del servidor
  public Integer getMaxId() {
    int idMax = Integer.parseInt(getCurrentId());
    try {
      List<Future<String>> listaFutures = multicastHandler("currentid", 1000);
      for (Future<String> future : listaFutures) {
        if (!future.isCancelled() && Integer.parseInt(future.get()) > idMax) {
          idMax = Integer.parseInt(future.get());
        }
      }
    } catch (InterruptedException | ExecutionException e) {
      e.printStackTrace();
    }
    id.set(idMax);

    return idMax;
  }

  // Función para obtener el valor actual de la variable del servidor id
  @Path("currentid")
  @GET
  @Produces(MediaType.TEXT_PLAIN)
  public String getCurrentId() {
    return "" + id.get();
  }

  // Función para crear un nuevo proceso, el nuevo proceso tendrá un ID igual al valor ID más alto
  // entre todos los servidores, más uno. También se inicia el hilo del proceso.
  @Path("createprocess")
  @GET
  @Produces(MediaType.TEXT_PLAIN)
  public String crearProceso() {
    Integer id = getMaxId() + 1;
    this.id.set(id);
    Proceso newProceso = new Proceso(id, this);
    mapaIdProceso.put(id, newProceso);
    new Thread(newProceso).start();
    return "";
  }

  // Función que hace la difusión a todos los servidores de la llamada que obtiene la lista de
  // procesos activos o inactivos, y concatena la información de cada uno de los servidores
  // - active: true si se quiere obtener los procesos activos, false para los inactivos
  @Path("listaprocesos/{active}")
  @GET
  @Produces(MediaType.TEXT_PLAIN)
  public String getListaProcesos(@PathParam("active") Boolean activos) {
    StringBuilder sb = new StringBuilder();
    sb.append(getProcesos(activos));

    try {
      List<Future<String>> listaFutures = multicastHandler("procesos/" + activos, 1000);
      for (Future<String> future : listaFutures) {
        if (!future.isCancelled()) {
          sb.append(future.get());
        }
      }
    } catch (InterruptedException | ExecutionException e) {
      e.printStackTrace();
    }

    return sb.toString();
  }

  // Función que obtiene la lista de procesos activos o inactivos del servidor
  // - active: true si se quiere obtener los procesos activos, false para los inactivos
  @Path("procesos/{active}")
  @GET
  @Produces(MediaType.TEXT_PLAIN)
  public String getProcesos(@PathParam("active") Boolean activos) {
    StringBuilder sb = new StringBuilder();
    for (Proceso proceso : mapaIdProceso.values()) {
      if (activos && proceso.isActivo()) {
        sb.append(proceso.getId()).append("\n");
      } else if (!activos && !proceso.isActivo()) {
        sb.append(proceso.getId()).append("\n");
      }
    }

    return sb.toString();
  }

  // Función que hace la difusión a todos los servidores de la llamada que obtiene la información de
  // los procesos, y concatena la información de cada uno de los servidores
  @Path("listainfoprocesos")
  @GET
  @Produces(MediaType.TEXT_PLAIN)
  public String getListaInfoProcesos() {
    StringBuilder sb =
        new StringBuilder("\nID\tACTIVO\tCOORDINADOR\tESTADO ELECCION      SERVIDOR\n");
    sb.append(getInfoProcesos());

    try {
      List<Future<String>> listaFutures = multicastHandler("infoprocesos", 1000);
      for (Future<String> future : listaFutures) {
        if (!future.isCancelled()) {
          sb.append(future.get());
        }
      }
    } catch (InterruptedException | ExecutionException e) {
      e.printStackTrace();
    }

    return sb.toString();
  }

  // Función que obtiene la información de los procesos del servidor
  @Path("infoprocesos")
  @GET
  @Produces(MediaType.TEXT_PLAIN)
  public String getInfoProcesos() {
    StringBuilder sb = new StringBuilder();
    for (Proceso proceso : mapaIdProceso.values()) {
      sb.append(proceso.getId()).append("\t").append(proceso.isActivo()).append("\t")
          .append(proceso.getIdCoordinador()).append("\t\t").append(proceso.getEstadoEleccion())
          .append("\t\t").append(miDireccion).append("\n");
    }

    return sb.toString();
  }

  // Función que hace la difusión a todos los servidores de la llamada de parada de un proceso
  // - id: entero con el ID del proceso a parar
  @Path("stop")
  @GET
  @Produces(MediaType.TEXT_PLAIN)
  public String parar(@QueryParam("id") Integer id) {
    if (!pararProceso(id)) {
      try {
        multicastHandler("stopprocess/" + id, 1000);
      } catch (InterruptedException | ExecutionException e) {
        e.printStackTrace();
      }
    }
    return "";
  }

  // Función que para el proceso indicado, al marcarlo como inactivo finaliza la ejecución de su
  // hilo
  // - id: entero con el ID del proceso a parar
  @Path("stopprocess/{id}")
  @GET
  @Produces(MediaType.TEXT_PLAIN)
  public boolean pararProceso(@PathParam("id") Integer id) {
    if (mapaIdProceso.containsKey(id)) {
      mapaIdProceso.get(id).setActivo(false);
      return true;
    }
    return false;
  }

  // Función que hace la difusión a todos los servidores de la llamada de arranque de un proceso
  // - id: entero con el ID del proceso a arrancar
  @Path("start")
  @GET
  @Produces(MediaType.TEXT_PLAIN)
  public String arrancar(@QueryParam("id") Integer id) {
    if (!arrancarProceso(id)) {
      try {
        multicastHandler("startprocess/" + id, 1000);
      } catch (InterruptedException | ExecutionException e) {
        e.printStackTrace();
      }
    }
    return "";
  }

  // Función que arranca el proceso indicado, marcándolo como activo y volviendo a iniciar su hilo
  // - id: entero con el ID del proceso a arrancar
  @Path("startprocess/{id}")
  @GET
  @Produces(MediaType.TEXT_PLAIN)
  public boolean arrancarProceso(@PathParam("id") Integer id) {
    if (mapaIdProceso.containsKey(id)) {
      mapaIdProceso.get(id).setActivo(true);
      new Thread(mapaIdProceso.get(id)).start();
      return true;
    }
    return false;
  }

  // Función que hace la difusión a todos los servidores de la llamada de finalización y eliminación
  // de los procesos
  @Path("resetall")
  @GET
  @Produces(MediaType.TEXT_PLAIN)
  public String resetAll() throws InterruptedException {
    try {
      multicastHandler("reset", 500);
    } catch (InterruptedException | ExecutionException e) {
      e.printStackTrace();
    }

    reset();
    return "";
  }

  // Función que finaliza los procesos del servidor, limpia sus variables y finaliza de forma
  // asíncrona los hilos activos del executor, dándoles un tiempo de gracia de 1s en caso de estar
  // ocupados
  @Path("reset")
  @GET
  @Produces(MediaType.TEXT_PLAIN)
  public String reset() throws InterruptedException {
    for (Proceso proceso : mapaIdProceso.values()) {
      proceso.setActivo(false);
    }
    mapaIdProceso.clear();
    listaServidores.clear();
    id.set(0);
    executor.awaitTermination(1000, TimeUnit.MILLISECONDS);
    return "";
  }
}
