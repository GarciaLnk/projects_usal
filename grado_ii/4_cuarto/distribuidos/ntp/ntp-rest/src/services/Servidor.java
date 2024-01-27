package services;

import java.util.Random;
import javax.inject.Singleton;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

@Singleton
@Path("ntp")
public class Servidor {
  Random rand = new Random();
  Object lock = new Object();

  /**
   * Devuelve el tiempo.
   */
  @Path("tiempo")
  @GET
  @Produces(MediaType.TEXT_PLAIN)
  public String getTiempo() {
    synchronized (lock) {
      long tiempo1;
      long tiempo2;
      int numRandom = rand.nextInt(1000);

      tiempo1 = System.currentTimeMillis();
      try {
        Thread.sleep(numRandom);
      } catch (InterruptedException e) {
        e.printStackTrace();
      }
      tiempo2 = System.currentTimeMillis();

      return "" + tiempo1 + "\n" + tiempo2;
    }
  }
}
