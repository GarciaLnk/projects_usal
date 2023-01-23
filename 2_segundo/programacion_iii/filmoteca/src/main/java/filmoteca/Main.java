package filmoteca;

import filmoteca.view.View;
import java.util.logging.Level;
import java.util.logging.LogManager;

final class Main {

  private Main() {
    throw new AssertionError("Instantiating utility class...");
  }

  public static void main(String[] args) {
    View view = new View();

    // ejecutar con la opción "-debug" para mostrar todos los mensajes del logger
    if (args.length == 0 || !args[0].equals("-debug")) {
      LogManager.getLogManager().getLogger("").setLevel(Level.WARNING);
    }

    view.runMenu("\nFILMOTECA\n" + "\n1) Archivos" + "\n2) Películas" + "\n3) Directores"
        + "\n4) Actores" + "\n5) Listados" + "\ns) Salir" + "\n\nSeleccione una opción: ");
  }
}
