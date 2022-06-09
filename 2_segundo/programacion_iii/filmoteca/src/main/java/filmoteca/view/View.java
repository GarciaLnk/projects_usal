package filmoteca.view;

import static java.lang.System.out;

import filmoteca.controller.Controller;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.Scanner;

public class View {

  private static final boolean IS_WINDOWS = System.getProperty("os.name").contains("Windows");
  private static final String NO_VALID = "Opción no válida\n";
  private static final String FIN_MENU = "%ns) Volver al menú principal%n%nSeleccione una opción: ";
  private static final String GUIONES =
      "------------------------------------------------------------------------------------------";
  private final Controller controller = new Controller();
  private final Scanner sc = new Scanner(System.in, IS_WINDOWS ? "ISO-8859-1" : "UTF-8");

  public void runMenu(String menu) {
    boolean salir = false;

    if (!controller.arranque()) {
      return;
    }
    do {
      out.printf("%s", menu);
      String opcion = sc.nextLine();
      switch (opcion) {
        case "1":
          menuArchivos();
          break;
        case "2":
          menuPeliculas();
          break;
        case "3":
          menuDirectores();
          break;
        case "4":
          menuActores();
          break;
        case "5":
          menuListados();
          break;
        case "s":
        case "S":
          salir = preguntarConfirmacion("¿Seguro que quiere salir?");
          break;
        default:
          out.println(NO_VALID);
          break;
      }
    } while (!salir);
    controller.salida();
  }

  private void menuArchivos() {
    boolean volver = false;
    do {
      out.printf(
          "%nArchivos"
              + "%n1) Exportar directores a directores.col"
              + "%n2) Exportar películas a películas.html"
              + FIN_MENU);

      String opcion = sc.nextLine();
      switch (opcion) {
        case "1":
          exportarDirectores();
          pulseContinuar();
          break;
        case "2":
          exportarPeliculas();
          pulseContinuar();
          break;
        case "s":
        case "S":
          volver = true;
          break;
        default:
          out.println(NO_VALID);
          break;
      }
    } while (!volver);
  }

  private void exportarDirectores() {
    controller.exportDirectoresToCol();
    out.println("\nDirectores exportados correctamente\n");
  }

  private void exportarPeliculas() {
    controller.exportPeliculasToHtml();
    out.println("\nPelículas exportadas correctamente\n");
  }

  private void menuPeliculas() {
    boolean volver = false;
    do {
      out.printf(
          "%nPelículas"
              + "%n1) Dar de alta una película"
              + "%n2) Dar de baja una película"
              + "%n3) Modificar una película"
              + "%n4) Consulta"
              + FIN_MENU);
      String opcion = sc.nextLine();
      switch (opcion) {
        case "1":
          darAltaPelicula();
          pulseContinuar();
          break;
        case "2":
          darBajaPelicula();
          pulseContinuar();
          break;
        case "3":
          modificarPelicula();
          break;
        case "4":
          consultaPelicula();
          pulseContinuar();
          break;
        case "s":
        case "S":
          volver = true;
          break;
        default:
          out.println(NO_VALID);
          break;
      }
    } while (!volver);
  }

  private void darAltaPelicula() {
    String titulo = readStringNotEmpty("Por favor, escriba el título de la película: ");
    Integer anno = readInteger("Por favor, indique el año de estreno: ");
    Integer duracion = readInteger("Por favor, indique la duración en minutos: ");
    String pais = readString("Por favor, escriba el país donde se produjo: ");
    String direccion =
        readString("Por favor, escriba el nombre de los directores (separados por comas): ");
    String guion = readString("Por favor, escriba el nombre de los guionistas: ");
    String musica = readString("Por favor, escriba el nombre de los compositores: ");
    String fotografia =
        readString("Por favor, escriba el nombre de los directores de fotografía: ");
    String reparto =
        readString("Por favor, escriba el nombre de los actores (separados por comas): ");
    String productora = readString("Por favor, escriba la productora de la película: ");
    String genero = readString("Por favor, indique el género de la película: ");
    String sinopsis = readString("Por favor, escriba una sinopsis de la trama: ");
    String delim = ", ";

    controller.darAltaPelicula(
        titulo,
        anno,
        duracion,
        pais,
        direccion,
        guion,
        musica,
        fotografia,
        reparto,
        productora,
        genero,
        sinopsis,
        delim);

    out.printf("%nLa película \"%s\" se ha añadido correctamente%n", titulo);
  }

  private void darBajaPelicula() {
    String titulo = readStringNotEmpty("Por favor, escriba el título de la película a eliminar: ");
    if (preguntarConfirmacion("¿Seguro que desea eliminar esta película?")) {
      if (controller.darBajaPelicula(titulo)) {
        out.printf("La película \"%s\" se ha borrado correctamente%n", titulo);
      } else {
        out.println("No se ha encontrado la pelicula a dar de baja\n");
      }
    } else {
      out.println("Se ha cancelado la baja de la película\n");
    }
  }

  private void modificarPelicula() {
    String titulo = readStringNotEmpty("Por favor, escriba el título de la película a modificar: ");
    if (controller.buscarPelicula(titulo)) {
      menuModificarPelicula(titulo);
    } else {
      out.println("No se ha encontrado la película a modificar\n");
    }
  }

  private void menuModificarPelicula(String titulo) {
    boolean volver = false;
    do {
      out.printf(
          "%nModificar datos de la película \"%s\""
              + "%n1) Año"
              + "%n2) Duración"
              + "%n3) País"
              + "%n4) Guión"
              + "%n5) Música"
              + "%n6) Fotografía"
              + "%n7) Productora"
              + "%n8) Género"
              + "%n9) Sinopsis"
              + FIN_MENU,
          titulo);
      String opcion = sc.nextLine();
      switch (opcion) {
        case "1":
          controller.setAnnoPeli(titulo, readInteger("Indique el nuevo año de estreno: "));
          break;
        case "2":
          controller.setDuracionPeli(titulo, readInteger("Indique la nueva duración: "));
          break;
        case "3":
          controller.setPaisPeli(titulo, readString("Escriba el nuevo país: "));
          break;
        case "4":
          controller.setGuionPeli(
              titulo, readString("Escriba el nombre de los nuevos guionistas: "));
          break;
        case "5":
          controller.setMusicaPeli(
              titulo, readString("Escriba el nombre de los nuevos compositores: "));
          break;
        case "6":
          controller.setFotografiaPeli(
              titulo, readString("Escriba el nombre de los nuevos directores de fotografía: "));
          break;
        case "7":
          controller.setProductoraPeli(titulo, readString("Indique la nueva productora: "));
          break;
        case "8":
          controller.setGeneroPeli(titulo, readString("Indique el nuevo género de la película: "));
          break;
        case "9":
          controller.setSinopsisPeli(titulo, readString("Escriba la nueva sinopsis: "));
          break;
        case "s":
        case "S":
          volver = true;
          break;
        default:
          out.println(NO_VALID);
          break;
      }
    } while (!volver);
  }

  private void consultaPelicula() {
    String titulo =
        readStringNotEmpty("Por favor, escriba el título de la película que quiere consultar: ");
    if (controller.buscarPelicula(titulo)) {
      out.println(controller.getStringPeli(titulo));
    } else {
      out.println("No se ha encontrado la película\n");
    }
  }

  private void menuDirectores() {
    boolean volver = false;
    do {
      out.printf(
          "%nDirectores"
              + "%n1) Dar de alta un director"
              + "%n2) Dar de baja un director"
              + "%n3) Modificar un director"
              + FIN_MENU);
      String opcion = sc.nextLine();
      switch (opcion) {
        case "1":
          darAltaDirector();
          pulseContinuar();
          break;
        case "2":
          darBajaDirector();
          pulseContinuar();
          break;
        case "3":
          modificarDirector();
          break;
        case "s":
        case "S":
          volver = true;
          break;
        default:
          out.println(NO_VALID);
          break;
      }
    } while (!volver);
  }

  private void darAltaDirector() {
    String nombre = readStringNotEmpty("Por favor, escriba el nombre del director: ");
    LocalDate fechaNac = readLocalDate("Por favor, indique la fecha de nacimiento: ");
    String nacion = readString("Por favor, indique la nacionalidad: ");
    String ocupacion = readString("Por favor, escriba las ocupaciones del director: ");
    String peliculas =
        readString("Por favor, escriba las películas que ha dirigido (separadas por comas): ");
    String delim = ", ";

    controller.darAltaDirector(nombre, fechaNac, nacion, ocupacion, peliculas, delim);

    out.printf("%nEl director \"%s\" se ha añadido correctamente%n", nombre);
  }

  private void darBajaDirector() {
    String nombre = readStringNotEmpty("Por favor, escriba el nombre del director a eliminar: ");
    if (preguntarConfirmacion("¿Seguro que desea eliminar este director?")) {
      String resultadoEliminar = controller.darBajaDirector(nombre);
      if (!resultadoEliminar.equals("_noEncontrado")) {
        if (!resultadoEliminar.equals("_exito")) {
          out.printf(
              "No se ha podido borrar el director porque aparece en las siguientes películas: %s",
              resultadoEliminar);
        } else {
          out.printf("El director \"%s\" se ha borrado correctamente%n", nombre);
        }
      } else {
        out.println("No se ha encontrado el director a dar de baja\n");
      }
    } else {
      out.println("\nSe ha cancelado la baja del director\n");
    }
  }

  private void modificarDirector() {
    String nombre = readStringNotEmpty("Por favor, escriba el nombre del director a modificar: ");
    if (controller.buscarDirector(nombre)) {
      menuModificarDirector(nombre);
    } else {
      out.println("No se ha encontrado el director a modificar\n");
    }
  }

  private void menuModificarDirector(String nombre) {
    boolean volver = false;
    do {
      out.printf(
          "%nModificar datos del director \"%s\""
              + "%n1) Fecha de nacimiento"
              + "%n2) Nacionalidad"
              + "%n3) Ocupación"
              + FIN_MENU,
          nombre);
      String opcion = sc.nextLine();
      switch (opcion) {
        case "1":
          controller.setFechaNacDire(
              nombre, readLocalDate("Indique la nueva fecha de nacimiento: "));
          break;
        case "2":
          controller.setNacionDire(nombre, readString("Indique la nueva nacionalidad: "));
          break;
        case "3":
          controller.setOcupacionDire(
              nombre, readString("Escriba la nueva ocupación del director: "));
          break;
        case "s":
        case "S":
          volver = true;
          break;
        default:
          out.println(NO_VALID);
          break;
      }
    } while (!volver);
  }

  private void menuActores() {
    boolean volver = false;
    do {
      out.printf(
          "%nActores"
              + "%n1) Dar de alta un actor"
              + "%n2) Dar de baja un actor"
              + "%n3) Modificar un actor"
              + "%n4) Películas de un actor"
              + FIN_MENU);
      String opcion = sc.nextLine();
      switch (opcion) {
        case "1":
          darAltaActor();
          pulseContinuar();
          break;
        case "2":
          darBajaActor();
          pulseContinuar();
          break;
        case "3":
          modificarActor();
          break;
        case "4":
          listadoPeliculasActor();
          pulseContinuar();
          break;
        case "s":
        case "S":
          volver = true;
          break;
        default:
          out.println(NO_VALID);
          break;
      }
    } while (!volver);
  }

  private void darAltaActor() {
    String nombre = readStringNotEmpty("Por favor, escriba el nombre del actor: ");
    LocalDate fechaNac = readLocalDate("Por favor, indique la fecha de nacimiento: ");
    String nacion = readString("Por favor, indique la nacionalidad: ");
    Integer annoDebut = readInteger("Por favor, escriba el año de debut del actor: ");
    String peliculas =
        readString(
            "Por favor, escriba las películas en las que ha actuado (separadas por comas): ");
    String delim = ", ";

    controller.darAltaActor(nombre, fechaNac, nacion, annoDebut, peliculas, delim);

    out.printf("%nEl actor \"%s\" se ha añadido correctamente%n", nombre);
  }

  private void darBajaActor() {
    String nombre = readStringNotEmpty("Por favor, escriba el nombre del actor a eliminar: ");
    if (preguntarConfirmacion("¿Seguro que desea eliminar este actor?")) {
      String resultadoEliminar = controller.darBajaActor(nombre);
      if (!resultadoEliminar.equals("_noEncontrado")) {
        if (!resultadoEliminar.equals("_exito")) {
          out.printf(
              "No se ha podido borrar el actor porque aparece en las siguientes películas: %s",
              resultadoEliminar);
        } else {
          out.printf("El actor \"%s\" se ha borrado correctamente%n", nombre);
        }
      } else {
        out.println("No se ha encontrado el actor a dar de baja\n");
      }
    } else {
      out.println("\nSe ha cancelado la baja del actor\n");
    }
  }

  private void modificarActor() {
    String nombre = readStringNotEmpty("Por favor, escriba el nombre del actor a modificar: ");
    if (controller.buscarActor(nombre)) {
      menuModificarActor(nombre);
    } else {
      out.println("No se ha encontrado el actor a modificar\n");
    }
  }

  private void menuModificarActor(String nombre) {
    boolean volver = false;
    do {
      out.printf(
          "%nModificar datos del actor \"%s\""
              + "%n1) Fecha de nacimiento"
              + "%n2) Nacionalidad"
              + "%n3) Año de debut"
              + FIN_MENU,
          nombre);
      String opcion = sc.nextLine();
      switch (opcion) {
        case "1":
          controller.setFechaNacActor(
              nombre, readLocalDate("Indique la nueva fecha de nacimiento: "));
          break;
        case "2":
          controller.setNacionActor(nombre, readString("Indique la nueva nacionalidad: "));
          break;
        case "3":
          controller.setAnnoDebutActor(nombre, readInteger("Indique el nuevo año de debut: "));
          break;
        case "s":
        case "S":
          volver = true;
          break;
        default:
          out.println(NO_VALID);
          break;
      }
    } while (!volver);
  }

  private void listadoPeliculasActor() {
    String nombre =
        readStringNotEmpty(
            "Por favor, escriba el nombre del actor cuyas películas desea consultar: ");
    if (controller.buscarActor(nombre)) {
      String peliculasActor = controller.getPeliculasActorAsTable(nombre);
      if (!peliculasActor.isEmpty()) {
        String formato = "+-%.65s-+-%.4s-+-%.8s-+-%.25s-+-%.15s-+%n";
        out.printf("%nPELÍCULAS DE %s%n", nombre);
        imprimirCabeceraPelicula(formato);
        out.println(peliculasActor);
        out.printf(formato, GUIONES, GUIONES, GUIONES, GUIONES, GUIONES);
      } else {
        out.printf("%n%s no aparece en ninguna película%n", nombre);
      }
    } else {
      out.println("No se ha encontrado el actor\n");
    }
  }

  private void menuListados() {
    boolean volver = false;
    do {
      out.printf(
          "%nListados"
              + "%n1) Listado de películas"
              + "%n2) Listado de directores"
              + "%n3) Listado de actores"
              + FIN_MENU);

      String opcion = sc.nextLine();
      switch (opcion) {
        case "1":
          listadoPeliculas();
          pulseContinuar();
          break;
        case "2":
          listadoDirectores();
          pulseContinuar();
          break;
        case "3":
          listadoActores();
          pulseContinuar();
          break;
        case "s":
        case "S":
          volver = true;
          break;
        default:
          out.println(NO_VALID);
          break;
      }
    } while (!volver);
  }

  private void listadoPeliculas() {
    String peliculas = controller.getPeliculasAsTable();
    if (!peliculas.isEmpty()) {
      String formato = "+-%.65s-+-%.4s-+-%.8s-+-%.25s-+-%.15s-+%n";
      out.println("\nPELÍCULAS");
      imprimirCabeceraPelicula(formato);
      out.println(peliculas);
      out.printf(formato, GUIONES, GUIONES, GUIONES, GUIONES, GUIONES);
    } else {
      out.println("\nNo hay ninguna película guardada");
    }
  }

  private void listadoDirectores() {
    String directores = controller.getDirectoresAsTable();
    if (!directores.isEmpty()) {
      String formato = "+-%.20s-+-%.16s-+-%.15s-+-%.65s-+-%.75s%.75s-+%n";
      out.println("\nDIRECTORES");
      out.printf(formato, GUIONES, GUIONES, GUIONES, GUIONES, GUIONES, GUIONES);
      out.printf(
          "| %-20s | %-16s | %-15s | %-65s | %-150s |%n",
          "NOMBRE", "FECHA NACIMIENTO", "NACIONALIDAD", "OCUPACIÓN", "PELÍCULAS");
      out.printf(formato, GUIONES, GUIONES, GUIONES, GUIONES, GUIONES, GUIONES);
      out.println(directores);
      out.printf(formato, GUIONES, GUIONES, GUIONES, GUIONES, GUIONES, GUIONES);
    } else {
      out.println("\nNo hay ningún director guardado");
    }
  }

  private void listadoActores() {
    String actores = controller.getActoresAsTable();
    if (!actores.isEmpty()) {
      String formato = "+-%.20s-+-%.16s-+-%.15s-+-%.9s-+-%.75s%.75s-+%n";
      out.println("\nACTORES");
      out.printf(formato, GUIONES, GUIONES, GUIONES, GUIONES, GUIONES, GUIONES);
      out.printf(
          "| %-20s | %-16s | %-15s | %-9s | %-150s |%n",
          "NOMBRE", "FECHA NACIMIENTO", "NACIONALIDAD", "AÑO DEBUT", "PELÍCULAS");
      out.printf(formato, GUIONES, GUIONES, GUIONES, GUIONES, GUIONES, GUIONES);
      out.println(actores);
      out.printf(formato, GUIONES, GUIONES, GUIONES, GUIONES, GUIONES, GUIONES);
    } else {
      out.println("\nNo hay ningún actor guardado");
    }
  }

  private void imprimirCabeceraPelicula(String formato) {
    out.printf(formato, GUIONES, GUIONES, GUIONES, GUIONES, GUIONES);
    out.printf(
        "| %-65s | %-4s | %-8s | %-25s | %-15s |%n", "TÍTULO", "AÑO", "DURACIÓN", "PAÍS", "GÉNERO");
    out.printf(formato, GUIONES, GUIONES, GUIONES, GUIONES, GUIONES);
  }

  private String readString(String prompt) {
    String temp;
    out.println(prompt);
    temp = sc.nextLine();

    if (temp.isEmpty()) {
      temp = controller.getNoAvailable();
    }

    return temp;
  }

  private String readStringNotEmpty(String prompt) {
    String temp;
    do {
      out.println(prompt);
      temp = sc.nextLine();
      if (temp.isEmpty()) {
        out.printf("%nError: no se admiten cadenas vacías.%n");
      }
    } while (temp.isEmpty());
    return temp;
  }

  private Integer readInteger(String prompt) {
    Integer tempNumber = null;
    String temp;
    boolean numberOkay;
    do {
      temp = readString(prompt);
      if (temp.equals(controller.getNoAvailable())) {
        return null;
      }

      try {
        tempNumber = Integer.parseInt(temp);
        numberOkay = true;
      } catch (NumberFormatException e) {
        out.printf("%nPerdón, ese número no es correcto. Pruebe de nuevo.%n");
        numberOkay = false;
      }
    } while (!numberOkay);
    return tempNumber;
  }

  private LocalDate readLocalDate(String prompt) {
    LocalDate fecha = null;
    String temp;
    boolean repetir = true;
    do {
      temp = readString(prompt);
      if (temp.equals(controller.getNoAvailable())) {
        return null;
      }

      try {
        fecha = LocalDate.parse(temp);
        repetir = false;
      } catch (DateTimeParseException e) {
        out.println("Introduzca una fecha válida\n");
      }
    } while (repetir);
    return fecha;
  }

  private void pulseContinuar() {
    out.printf("%nPulse ENTER para continuar...");
    sc.nextLine();
  }

  private boolean preguntarConfirmacion(String prompt) {
    String opcion;

    do {
      out.printf("%n%s [s/N] ", prompt);
      opcion = sc.nextLine();
    } while (!"sSnN".contains(opcion));
    out.println();

    return (!opcion.isEmpty() && "sS".contains(opcion));
  }
}
