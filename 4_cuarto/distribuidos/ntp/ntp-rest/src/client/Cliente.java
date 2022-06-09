package client;

import java.net.URI;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.client.WebTarget;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.UriBuilder;

public abstract class Cliente {
  /**
   * Algoritmo de Marzullo para calcular el mejor par de tiempos.
   */
  private static String marzullo(List<Par> pares) {
    List<Par> listaTuplas = new ArrayList<>();
    double mejor = 0;
    double count = 0;
    double mejorInicio = 0;
    double mejorFin = 0;

    for (Par par : pares) {
      listaTuplas.add(new Par(par.getOffset() - par.getDelay() / 2d, -1));
      listaTuplas.add(new Par(par.getOffset() + par.getDelay() / 2d, +1));
    }
    Collections.sort(listaTuplas);

    for (int i = 0; i < listaTuplas.size() - 1; i++) {
      count = count - listaTuplas.get(i).getDelay();
      if (count > mejor) {
        mejor = count;
        mejorInicio = listaTuplas.get(i).getOffset();
        mejorFin = listaTuplas.get(i + 1).getOffset();
      }
    }

    return "" + mejorInicio + ", " + mejorFin;
  }

  /**
   * Calcula el offset y delay de cada servidor.
   */
  public static void main(String[] args) {
    if (args.length < 1) {
      System.out.println("Argumentos incorrectos");
      System.out.println("Uso: java MainCarrera.jar servidor1 [servidor2...]");
      System.out.println("servidor1: direccion del servidor1");
      System.exit(1);
    }
    System.out.println("Inicio\n");

    for (String servidor : args) {
      String[] arrTiempo;
      long tiempo0;
      long tiempo1;
      long tiempo2;
      long tiempo3;
      // Par mejorPar = new Par(Double.MAX_VALUE, Double.MAX_VALUE); // basico
      List<Par> listaPares = new ArrayList<>(); // marzullo
      double delay;
      double offset;
      Client client = ClientBuilder.newClient();
      URI uri = UriBuilder.fromUri("http://" + servidor + ":8080/ntp-rest").build();
      WebTarget target = client.target(uri);

      for (int i = 0; i < 8; i++) {
        tiempo0 = System.currentTimeMillis();
        arrTiempo =
            target.path("ntp/tiempo").request(MediaType.TEXT_PLAIN).get(String.class).split("\n");
        tiempo3 = System.currentTimeMillis();

        tiempo1 = Long.parseLong(arrTiempo[0]);
        tiempo2 = Long.parseLong(arrTiempo[1]);

        delay = tiempo1 - tiempo0 + tiempo3 - tiempo2;
        offset = (tiempo1 - tiempo0 + tiempo2 - tiempo3) / 2d;
        System.out.println(servidor + " " + (offset - delay / 2d) + ", " + (offset + delay / 2d));

        // if (delay < mejorPar.getDelay()) { // basico
        // mejorPar.setDelay(delay);
        // mejorPar.setOffset(offset);
        // }
        listaPares.add(new Par(offset, delay)); // marzullo
      }
      // System.out // basico
      // .println(servidor + " mejor par: " + (mejorPar.getOffset() - mejorPar.getDelay() / 2d)
      // + ", " + (mejorPar.getOffset() + mejorPar.getDelay() / 2d) + "\n");
      System.out.println(servidor + " mejor par: " + marzullo(listaPares) + "\n"); // marzullo
    }
  }
}
