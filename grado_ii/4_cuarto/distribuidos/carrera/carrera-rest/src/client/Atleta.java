package client;

import java.util.Random;

import javax.ws.rs.client.WebTarget;
import javax.ws.rs.core.MediaType;

public class Atleta implements Runnable {
  private int dorsal;
  private int numRandom;
  private WebTarget target;
  private MainCarrera carrera;

  /**
   * Constructor de Atleta.
   */
  public Atleta(int dorsal, MainCarrera carrera, WebTarget target) {
    Random rand = new Random();
    numRandom = rand.nextInt(2200) + 9560;
    this.dorsal = dorsal;
    this.carrera = carrera;
    this.target = target;
  }

  @Override
  public void run() {
    carrera.infoCarrera(
        target.path("carrera100/preparado").request(MediaType.TEXT_PLAIN).get(String.class));
    carrera.infoCarrera(
        target.path("carrera100/listo").request(MediaType.TEXT_PLAIN).get(String.class));

    try {
      Thread.sleep(numRandom);
    } catch (InterruptedException e) {
      e.printStackTrace();
    }

    String ultimoAtleta = target.path("carrera100/llegada").queryParam("dorsal", "" + dorsal)
        .request(MediaType.TEXT_PLAIN).get(String.class);

    if (ultimoAtleta.contains("true")) {
      carrera.finCarrera(target);
    }
  }

}
