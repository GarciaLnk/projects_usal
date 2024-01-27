package client;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Scanner;
import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.client.WebTarget;
import javax.ws.rs.core.MediaType;

public abstract class Gestor {
  private static final Scanner sc = new Scanner(System.in);
  private static final Client client = ClientBuilder.newClient();
  private static final Object lock = new Object();
  private static boolean exit = false;
  private static boolean deadServer;
  private static String info;

  // Función auxiliar para obtener de forma asíncrona información (una String) del servidor
  // - target: WebTarget del servidor
  // - path: dirección al método REST
  private static String getInfoAsync(WebTarget target, String path) {
    info = "";
    new Thread(() -> {
      info = target.path(path).request(MediaType.TEXT_PLAIN).get(String.class);
      synchronized (lock) {
        lock.notifyAll();
      }
    }).start();

    synchronized (lock) {
      try {
        lock.wait(2000);
      } catch (InterruptedException e) {
        e.printStackTrace();
      }
    }
    return info;
  }

  public static void main(String[] args) {
    List<String> listaDirecciones = new ArrayList<>();

    // Comprobación de argumentos
    if (args.length < 1) {
      System.out.println("Introduce al menos un servidor al que se conecte el gestor");
      return;
    }

    // Modo monitor
    if ("-monitor".equalsIgnoreCase(args[0])) {
      if (args.length < 2) {
        System.out.println("Introduce al menos un servidor al que se conecte el gestor");
        return;
      }

      // Añadir de args[1] a args[x] a listaDirecciones
      listaDirecciones.addAll(Arrays.asList(args).subList(1, args.length));
      WebTarget target = client.target("http://" + listaDirecciones.get(0) + ":8080/bully-rest");

      // Nuevo hilo para salir del modo monitor de forma elegante
      new Thread(() -> {
        sc.nextLine();
        exit = true;
      }).start();

      while (!exit) {
        // Cada 100ms imprime la información de los procesos que obtiene de forma asíncrona hasta
        // que se sale
        String printInfo = getInfoAsync(target, "listainfoprocesos");
        System.out.print("\033[H\033[2J");
        System.out.println(printInfo);

        try {
          Thread.sleep(100);
        } catch (InterruptedException e) {
          e.printStackTrace();
        }
      }

      // Salida del programa
      return;
    } // Fin modo monitor

    // Unir las direcciones en una sola String para pasarselas al servidor en una única llamada REST
    StringBuilder direcciones = new StringBuilder();
    for (String direccion : args) {
      listaDirecciones.add(direccion);
      direcciones.append(direcciones).append(direccion).append("\n");
    }

    // Para cada servidor mandar la String con las direcciones de forma asíncrona
    // si la llamada no tiene éxito pasado 2s se elimina el servidor de la lista
    for (String direccion : listaDirecciones) {
      WebTarget thisTarget = client.target("http://" + direccion + ":8080/bully-rest");
      deadServer = true;
      new Thread(() -> {
        thisTarget.path("addservers").queryParam("addresses", direcciones)
            .queryParam("to", direccion).request(MediaType.TEXT_PLAIN).get(String.class);
        deadServer = false;
        synchronized (lock) {
          lock.notifyAll();
        }
      }).start();

      synchronized (lock) {
        try {
          lock.wait(2000);
        } catch (InterruptedException e) {
          e.printStackTrace();
        }
      }

      if (deadServer) {
        listaDirecciones.remove(direccion);
      }
    }

    // Servidor con el que se comunicará el Gestor
    // + Se podría implementar una lógica para iterar entre servidores si se reciben timeouts
    WebTarget target = client.target("http://" + listaDirecciones.get(0) + ":8080/bully-rest");

    String opcion;
    String proceso;
    boolean salir = false;

    // Menú del gestor
    while (!salir) {
      System.out.println("GESTOR DE PROCESOS");
      System.out.println("1) Crear proceso");
      System.out.println("2) Consultar procesos");
      System.out.println("3) Parar proceso");
      System.out.println("4) Arrancar proceso");
      System.out.println("s) Salir");
      System.out.println("x) Salir y eliminar los procesos\n");
      System.out.print("Seleccione una opcion: ");
      opcion = sc.nextLine();

      switch (opcion) {
        case "1":
          // Muestra los servidores disponibles
          System.out.println("\nSERVIDORES DISPONIBLES:");
          int i = 1;
          for (String direccion : listaDirecciones) {
            System.out.println(" " + i++ + ") " + direccion);
          }
          System.out.print("\nSelecciona el servidor donde crear el proceso: ");
          try {
            int numServidor = Integer.parseInt(sc.nextLine());
            if (numServidor > 0 && numServidor < listaDirecciones.size() + 1) {
              String servidor = listaDirecciones.get(numServidor - 1);
              // Si el número introducido es correcto se hace una llamada REST asíncrona para crear
              // el proceso
              new Thread(() -> client.target("http://" + servidor + ":8080/bully-rest")
                  .path("createprocess").request(MediaType.TEXT_PLAIN).get()).start();
            } else {
              System.out.println("Servidor incorrecto\n");
            }
          } catch (Exception e) {
            System.out.println("Servidor incorrecto\n");
          }
          break;
        case "2":
          // Pide la información de los procesos de forma asíncrona al servidor y la imprime
          String printInfo = getInfoAsync(target, "listainfoprocesos");
          System.out.println(printInfo);
          break;
        case "3":
          System.out.println("\nPROCESOS ACTIVOS:");
          // Pide la lista de los procesos activos de forma asíncrona al servidor y la imprime
          String listaProcesosActivos = getInfoAsync(target, "listaprocesos/true");
          System.out.println(listaProcesosActivos);
          System.out.print("Selecciona un proceso a parar: ");
          try {
            proceso = sc.nextLine();
            Integer numProcesoActivo = Integer.parseInt(proceso);
            if (listaProcesosActivos.contains(proceso)) {
              // Hace una llamada REST de forma asíncrona para parar el proceso
              new Thread(() -> target.path("stop").queryParam("id", numProcesoActivo)
                  .request(MediaType.TEXT_PLAIN).get()).start();
            } else {
              System.out.println("Proceso incorrecto\n");
            }
          } catch (Exception e) {
            System.out.println("Proceso incorrecto\n");
          }
          break;
        case "4":
          System.out.println("\nPROCESOS INACTIVOS:");
          // Pide la lista de los procesos inactivos de forma asíncrona al servidor y la imprime
          String listaProcesosInactivos = getInfoAsync(target, "listaprocesos/false");
          System.out.println(listaProcesosInactivos);
          System.out.print("Selecciona un proceso a arrancar: ");
          try {
            proceso = sc.nextLine();
            Integer numProcesoInactivo = Integer.parseInt(proceso);
            if (listaProcesosInactivos.contains(proceso)) {
              // Hace una llamada REST de forma asíncrona para volver a arrancar el proceso
              new Thread(() -> target.path("start").queryParam("id", numProcesoInactivo)
                  .request(MediaType.TEXT_PLAIN).get()).start();
            } else {
              System.out.println("Proceso incorrecto\n");
            }
          } catch (Exception e) {
            System.out.println("Proceso incorrecto\n");
          }
          break;
        case "s":
        case "S":
          // Cierra el gestor
          System.out.println("Saliendo");
          salir = true;
          break;
        case "x":
        case "X":
          System.out.println("Saliendo y eliminando procesos");
          // Cierra el gestor y hace una llamada asíncrona para parar y eliminar los procesos de los
          // servidores
          new Thread(() -> target.path("resetall").request(MediaType.TEXT_PLAIN).get()).start();
          salir = true;
          break;
        default:
          System.out.println("Opcion no valida");
          break;
      }
    }
  }

}
