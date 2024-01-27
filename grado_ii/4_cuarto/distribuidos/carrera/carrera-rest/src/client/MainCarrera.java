package client;

import java.net.URI;
import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.client.WebTarget;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.UriBuilder;

public class MainCarrera {
  protected void infoCarrera(String s) {
    System.out.print(s);
  }

  protected void finCarrera(WebTarget target) {
    System.out.print(
        target.path("carrera100/resultados").request(MediaType.TEXT_PLAIN).get(String.class));
  }

  /**
   * Constructor de MainCarrera.
   */
  public MainCarrera(String[] args) {
    int numAtletasTotal;
    int numAtletasCrear;
    int dorsal;
    final String ipServidor;

    if (args.length < 3) {
      System.out.println("Argumentos incorrectos");
      System.out.println(
          "Uso: java MainCarrera.jar [numAtletasTotal] [numAtletasCrear] [direccionServidor]");
      System.out.println("numAtletasTotal: numero total de atletas de la carrera,"
          + " si la carrera ya tiene algun atleta este parametro es ignorado");
      System.out.println("numAtletasCrear: numero de atletas a crear por este proceso");
      System.out.println("direccionServidor: direccion IP del servidor");
      System.exit(1);
    }

    numAtletasTotal = Integer.parseInt(args[0]);
    numAtletasCrear = Integer.parseInt(args[1]);
    ipServidor = args[2];

    if (numAtletasTotal < 0 || numAtletasCrear < 0) {
      System.out.println("El numero de atletas introducido tiene que ser un entero positivo");
      System.exit(1);
    }

    Client client = ClientBuilder.newClient();
    URI uri = UriBuilder.fromUri("http://" + ipServidor + ":8080/carrera-rest").build();

    WebTarget target = client.target(uri);

    System.out.print(target.path("carrera100/reinicio").queryParam("num", "" + numAtletasTotal)
        .request(MediaType.TEXT_PLAIN).get(String.class));

    for (int i = 0; i < numAtletasCrear; i++) {
      dorsal = Integer.parseInt(
          target.path("carrera100/dorsal").request(MediaType.TEXT_PLAIN).get(String.class));
      new Thread(new Atleta(dorsal, this, target)).start();
    }
  }

  public static void main(String[] args) {
    new MainCarrera(args);
  }

}
