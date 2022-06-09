package filmoteca.data;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.InvalidKeyException;
import java.security.KeyFactory;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.NoSuchAlgorithmException;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.Signature;
import java.security.SignatureException;
import java.security.SignedObject;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.X509EncodedKeySpec;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class Model {

  private static final Logger LOGGER = Logger.getLogger(Model.class.getName());
  private static final String HASH_ALGORITHM = "MD5withRSA";
  private static final String NO_AVAILABLE = Pelicula.NO_AVAILABLE;
  private final Filmoteca filmoteca = new Filmoteca();

  public Path getPathFilmoteca() {
    return FileSystems.getDefault()
        .getPath(
            System.getProperty("user.home"),
            File.separator + "Desktop" + File.separator + filmoteca.getNombreCarpeta())
        .toAbsolutePath();
  }

  public Path getPathPeliculasBin() {
    return pathDesktopFolderFile(filmoteca.getNombreCarpeta(), Filmoteca.BIN_PELICULAS);
  }

  public Path getPathDirectoresBin() {
    return pathDesktopFolderFile(filmoteca.getNombreCarpeta(), Filmoteca.BIN_DIRECTORES);
  }

  public Path getPathActoresBin() {
    return pathDesktopFolderFile(filmoteca.getNombreCarpeta(), Filmoteca.BIN_ACTORES);
  }

  public Path getPathPeliculasTxt() {
    return pathDesktopFolderFile(filmoteca.getNombreCarpeta(), Filmoteca.TXT_PELICULAS);
  }

  public Path getPathDirectoresTxt() {
    return pathDesktopFolderFile(filmoteca.getNombreCarpeta(), Filmoteca.TXT_DIRECTORES);
  }

  public Path getPathActoresTxt() {
    return pathDesktopFolderFile(filmoteca.getNombreCarpeta(), Filmoteca.TXT_ACTORES);
  }

  private Path getPathKey(String s) {
    return pathDesktopFolderFile(filmoteca.getNombreCarpeta(), ".pubkey_" + s);
  }

  private Path pathDesktopFolderFile(String nombreCarpeta, String nombreArchivo) {
    return FileSystems.getDefault()
        .getPath(
            System.getProperty("user.home"),
            File.separator
                + "Desktop"
                + File.separator
                + nombreCarpeta
                + File.separator
                + nombreArchivo);
  }

  public boolean importPeliculasFromTxt(Path pathPeliculasTxt) {
    List<String> tmp;

    try {
      tmp = Files.readAllLines(pathPeliculasTxt);
    } catch (IOException e) {
      LOGGER.log(Level.INFO, "no se pudo leer peliculas.txt");
      return false;
    }

    if (tmp.isEmpty()) {
      return false;
    }

    for (String s : tmp) {
      if (!s.isEmpty()) {
        String[] campo = splitLine(s);

        try {
          filmoteca.crearPelicula(
              campo[0],
              parseInteger(campo[1]),
              parseInteger(campo[2]),
              campo[3],
              campo[4],
              campo[5],
              campo[6],
              campo[7],
              campo[8],
              campo[9],
              campo[10],
              campo[11],
              "\t");
        } catch (ArrayIndexOutOfBoundsException ex) {
          LOGGER.log(Level.INFO, String.format("película: la línea \"%s\" está malformada", s));
        }
      }
    }

    return true;
  }

  public boolean importDirectoresFromTxt(Path pathDirectoresTxt) {
    List<String> tmp;

    try {
      tmp = Files.readAllLines(pathDirectoresTxt);
    } catch (IOException e) {
      LOGGER.log(Level.INFO, "no se pudo leer directores.txt");
      return false;
    }

    if (tmp.isEmpty()) {
      return false;
    }

    for (String s : tmp) {
      if (!s.isEmpty()) {
        String[] campo = splitLine(s);

        try {
          filmoteca.crearDirector(
              campo[0], parseDate(campo[1]), campo[2], campo[3], campo[4], "\t");
        } catch (ArrayIndexOutOfBoundsException ex) {
          LOGGER.log(Level.INFO, String.format("director: la línea \"%s\" está malformada", s));
        }
      }
    }

    return true;
  }

  public boolean importActoresFromTxt(Path pathActoresTxt) {
    List<String> tmp;

    try {
      tmp = Files.readAllLines(pathActoresTxt);
    } catch (IOException e) {
      LOGGER.log(Level.INFO, "no se pudo leer actores.txt");
      return false;
    }

    if (tmp.isEmpty()) {
      return false;
    }

    for (String s : tmp) {
      if (!s.isEmpty()) {
        String[] campo = splitLine(s);

        try {
          filmoteca.crearActor(
              campo[0], parseDate(campo[1]), campo[2], parseInteger(campo[3]), campo[4], "\t");
        } catch (ArrayIndexOutOfBoundsException ex) {
          LOGGER.log(Level.INFO, String.format("actor: la línea \"%s\" está malformada", s));
        }
      }
    }

    return true;
  }

  private String[] splitLine(String linea) {
    String[] campo = linea.split("#");
    for (int i = 0; i < campo.length; i++) {
      if (campo[i].isEmpty() || campo[i] == null) {
        campo[i] = NO_AVAILABLE;
      }
    }

    if (!campo[0].equals(NO_AVAILABLE)) {
      return campo;
    } else {
      return new String[0];
    }
  }

  private Integer parseInteger(String s) {
    try {
      return Integer.parseInt(s);
    } catch (NumberFormatException ignored) {
      return null;
    }
  }

  private LocalDate parseDate(String s) {
    try {
      return LocalDate.parse(s);
    } catch (DateTimeParseException ignored) {
      return null;
    }
  }

  @SuppressWarnings("unchecked")
  public boolean loadPeliculasFromBin(Path pathPeliculasBin) {
    try (FileInputStream fisPeliculas = new FileInputStream(pathPeliculasBin.toFile());
        BufferedInputStream bisPeliculas = new BufferedInputStream(fisPeliculas);
        ObjectInputStream oisPeliculas = new ObjectInputStream(bisPeliculas)) {

      SignedObject signedPeliculas = (SignedObject) oisPeliculas.readObject();
      Signature sign = Signature.getInstance(HASH_ALGORITHM);

      if (signedPeliculas.verify(loadPublicKey("Peliculas"), sign)) {
        ArrayList<Pelicula> tmpPeliculas = (ArrayList<Pelicula>) signedPeliculas.getObject();
        if (tmpPeliculas.isEmpty()) {
          LOGGER.log(Level.INFO, "peliculas.bin vacío");
          return false;
        }
        filmoteca.setPeliculas(tmpPeliculas);
        return true;
      } else {
        LOGGER.log(Level.WARNING, "la clave pública de peliculas.bin es incorrecta");
        return false;
      }
    } catch (IOException | ClassNotFoundException e) {
      LOGGER.log(Level.INFO, "no se pudo leer peliculas.bin");
      return false;
    } catch (NoSuchAlgorithmException | InvalidKeyException | SignatureException e) {
      LOGGER.log(Level.WARNING, "la clave pública de peliculas.bin es inválida");
      return false;
    }
  }

  @SuppressWarnings("unchecked")
  public boolean loadDirectoresFromBin(Path pathDirectoresBin) {
    try (FileInputStream fisDirectores = new FileInputStream(pathDirectoresBin.toFile());
        BufferedInputStream bisDirectores = new BufferedInputStream(fisDirectores);
        ObjectInputStream oisDirectores = new ObjectInputStream(bisDirectores)) {

      SignedObject signedDirectores = (SignedObject) oisDirectores.readObject();
      Signature sign = Signature.getInstance(HASH_ALGORITHM);

      if (signedDirectores.verify(loadPublicKey("Directores"), sign)) {
        ArrayList<Director> tmpDirectores = (ArrayList<Director>) signedDirectores.getObject();
        if (tmpDirectores.isEmpty()) {
          LOGGER.log(Level.INFO, "directores.bin vacío");
          return false;
        }
        filmoteca.setDirectores(tmpDirectores);
        return true;
      } else {
        LOGGER.log(Level.WARNING, "la clave pública de directores.bin es incorrecta");
        return false;
      }
    } catch (IOException | ClassNotFoundException e) {
      LOGGER.log(Level.INFO, "no se pudo leer directores.bin");
      return false;
    } catch (NoSuchAlgorithmException | InvalidKeyException | SignatureException e) {
      LOGGER.log(Level.WARNING, "la clave pública de directores.bin es inválida");
      return false;
    }
  }

  @SuppressWarnings("unchecked")
  public boolean loadActoresFromBin(Path pathActoresBin) {
    try (FileInputStream fisActores = new FileInputStream(pathActoresBin.toFile());
        BufferedInputStream bisActores = new BufferedInputStream(fisActores);
        ObjectInputStream oisActores = new ObjectInputStream(bisActores)) {

      SignedObject signedActores = (SignedObject) oisActores.readObject();
      Signature sign = Signature.getInstance(HASH_ALGORITHM);

      if (signedActores.verify(loadPublicKey("Actores"), sign)) {
        ArrayList<Actor> tmpActores = (ArrayList<Actor>) signedActores.getObject();
        if (tmpActores.isEmpty()) {
          LOGGER.log(Level.INFO, "actores.bin vacío");
          return false;
        }
        filmoteca.setActores(tmpActores);
        return true;
      } else {
        LOGGER.log(Level.WARNING, "la clave pública de actores.bin es incorrecta");
        importActoresFromTxt(getPathActoresTxt());
        return false;
      }
    } catch (IOException | ClassNotFoundException e) {
      LOGGER.log(Level.INFO, "no se pudo leer actores.bin");
      return false;
    } catch (NoSuchAlgorithmException | InvalidKeyException | SignatureException e) {
      LOGGER.log(Level.WARNING, "la clave publica de actores.bin es inválida");
      return false;
    }
  }

  public void saveToBin() {
    try (FileOutputStream fosPeliculas = new FileOutputStream(getPathPeliculasBin().toFile());
        FileOutputStream fosDirectores = new FileOutputStream(getPathDirectoresBin().toFile());
        FileOutputStream fosActores = new FileOutputStream(getPathActoresBin().toFile());
        BufferedOutputStream bosPeliculas = new BufferedOutputStream(fosPeliculas);
        BufferedOutputStream bosDirectores = new BufferedOutputStream(fosDirectores);
        BufferedOutputStream bosActores = new BufferedOutputStream(fosActores);
        ObjectOutputStream oosPeliculas = new ObjectOutputStream(bosPeliculas);
        ObjectOutputStream oosDirectores = new ObjectOutputStream(bosDirectores);
        ObjectOutputStream oosActores = new ObjectOutputStream(bosActores)) {

      Signature sign = Signature.getInstance(HASH_ALGORITHM);
      PrivateKey privKeyPeliculas = createPrivateKey("Peliculas");
      PrivateKey privKeyDirectores = createPrivateKey("Directores");
      PrivateKey privKeyActores = createPrivateKey("Actores");
      SignedObject soPeliculas =
          new SignedObject((ArrayList<Pelicula>) filmoteca.getPeliculas(), privKeyPeliculas, sign);
      SignedObject soDirectores =
          new SignedObject(
              (ArrayList<Director>) filmoteca.getDirectores(), privKeyDirectores, sign);
      SignedObject soActores =
          new SignedObject((ArrayList<Actor>) filmoteca.getActores(), privKeyActores, sign);

      oosPeliculas.writeObject(soPeliculas);
      oosDirectores.writeObject(soDirectores);
      oosActores.writeObject(soActores);
    } catch (IOException | NoSuchAlgorithmException | InvalidKeyException | SignatureException e) {
      LOGGER.log(Level.SEVERE, "no se pudieron guardar los datos en archivos binarios", e);
    }
  }

  private PrivateKey createPrivateKey(String s) {
    try (FileOutputStream fosKey = new FileOutputStream(getPathKey(s).toFile())) {
      KeyPairGenerator kpg = KeyPairGenerator.getInstance("RSA");
      KeyPair kp = kpg.generateKeyPair();
      byte[] pubKey = kp.getPublic().getEncoded();
      fosKey.write(pubKey);
      return kp.getPrivate();
    } catch (IOException | NoSuchAlgorithmException e) {
      LOGGER.log(Level.SEVERE, "no se pudo crear la clave", e);
      return null;
    }
  }

  private PublicKey loadPublicKey(String s) {
    try {
      byte[] keyBytes = Files.readAllBytes(getPathKey(s));
      X509EncodedKeySpec spec = new X509EncodedKeySpec(keyBytes);
      KeyFactory kf = KeyFactory.getInstance("RSA");
      return kf.generatePublic(spec);
    } catch (IOException | NoSuchAlgorithmException | InvalidKeySpecException e) {
      LOGGER.log(
          Level.INFO, "no se pudo cargar la clave pública, se ignorara el archivo binario", e);
      return null;
    }
  }

  public void exportPeliculasToHtml() {
    File filePeliculasHtml =
        pathDesktopFolderFile(filmoteca.getNombreCarpeta(), Filmoteca.HTML_PELICULAS).toFile();

    try (PrintWriter pw =
        new PrintWriter(
            new OutputStreamWriter(
                new FileOutputStream(filePeliculasHtml), StandardCharsets.UTF_8))) {
      String style =
          "<style>\n"
              + "#peliculas {\n"
              + "  font-family: \"Trebuchet MS\", Arial, Helvetica, sans-serif;\n"
              + "  border-collapse: collapse;\n"
              + "  width: 100%;\n"
              + "}\n"
              + "\n"
              + "#peliculas td, #peliculas th {\n"
              + "  border: 1px solid #ddd;\n"
              + "  padding: 8px;\n"
              + "}\n"
              + "\n"
              + "#peliculas tr:nth-child(even){background-color: #f2f2f2;}\n"
              + "\n"
              + "#peliculas tr:hover {background-color: #ddd;}\n"
              + "\n"
              + "#peliculas th {\n"
              + "  padding-top: 12px;\n"
              + "  padding-bottom: 12px;\n"
              + "  text-align: left;\n"
              + "  background-color: #4CAF50;\n"
              + "  color: white;\n"
              + "}\n"
              + "</style>\n";
      pw.printf("<!DOCTYPE html>%n");
      pw.printf("<HTML>%n<HEAD><meta charset=\"UTF-8\"><title>PELÍCULAS</title></HEAD>%n<BODY>%n");
      pw.printf("<table id=\"peliculas\">%n");
      pw.println(style);
      pw.printf(
          "<TR><TH>TÍTULO</TH><TH>AÑO</TH><TH>DURACIÓN</TH><TH>PAÍS</TH><TH>DIRECCIÓN</TH>"
              + "<TH>GUION</TH><TH>MÚSICA</TH><TH>FOTOGRAFÍA</TH><TH>REPARTO</TH>"
              + "<TH>PRODUCTORA</TH><TH>GÉNERO</TH><TH>SINOPSIS</TH></TR>%n");

      for (Pelicula p : filmoteca.getPeliculas()) {
        pw.printf("%s%n", p.peliculaToHtml());
      }

      pw.println("</TABLE>");
      pw.println("</BODY>\n</HTML>");
    } catch (FileNotFoundException e) {
      LOGGER.log(Level.SEVERE, "no se pudieron exportar las películas a HTML", e);
    }
  }

  public void exportDirectoresToCol() {
    File fileDirectoresCol =
        pathDesktopFolderFile(filmoteca.getNombreCarpeta(), Filmoteca.COL_DIRECTORES).toFile();

    try (PrintWriter pw =
        new PrintWriter(
            new OutputStreamWriter(
                new FileOutputStream(fileDirectoresCol), StandardCharsets.UTF_8))) {
      pw.printf("NOMBRE\tFECHA DE NACIMIENTO\tNACIONALIDAD\tOCUPACIÓN\tPELÍCULAS%n");

      for (Director d : filmoteca.getDirectores()) {
        pw.printf("%s%n", d.directorToCol());
      }
    } catch (FileNotFoundException e) {
      LOGGER.log(Level.SEVERE, "no se pudieron exportar los directores a .col", e);
    }
  }

  public void darAltaPelicula(
      String titulo,
      Integer anno,
      Integer duracion,
      String pais,
      String direccion,
      String guion,
      String musica,
      String fotografia,
      String reparto,
      String productora,
      String genero,
      String sinopsis,
      String delim) {
    filmoteca.crearPelicula(
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
  }

  public boolean darBajaPelicula(String titulo) {
    return filmoteca.eliminarPelicula(titulo);
  }

  public boolean buscarPelicula(String titulo) {
    return filmoteca.buscarPelicula(titulo, filmoteca.getPeliculas()) != null;
  }

  public void setAnnoPeli(String titulo, Integer anno) {
    Pelicula peliculaBuscada = filmoteca.buscarPelicula(titulo, filmoteca.getPeliculas());
    peliculaBuscada.setAnno(anno);
  }

  public void setDuracionPeli(String titulo, Integer duracion) {
    Pelicula peliculaBuscada = filmoteca.buscarPelicula(titulo, filmoteca.getPeliculas());
    peliculaBuscada.setDuracion(duracion);
  }

  public void setPaisPeli(String titulo, String pais) {
    Pelicula peliculaBuscada = filmoteca.buscarPelicula(titulo, filmoteca.getPeliculas());
    peliculaBuscada.setPais(pais);
  }

  public void setGuionPeli(String titulo, String guion) {
    Pelicula peliculaBuscada = filmoteca.buscarPelicula(titulo, filmoteca.getPeliculas());
    peliculaBuscada.setGuion(guion);
  }

  public void setMusicaPeli(String titulo, String musica) {
    Pelicula peliculaBuscada = filmoteca.buscarPelicula(titulo, filmoteca.getPeliculas());
    peliculaBuscada.setMusica(musica);
  }

  public void setFotografiaPeli(String titulo, String fotografia) {
    Pelicula peliculaBuscada = filmoteca.buscarPelicula(titulo, filmoteca.getPeliculas());
    peliculaBuscada.setFotografia(fotografia);
  }

  public void setProductoraPeli(String titulo, String productora) {
    Pelicula peliculaBuscada = filmoteca.buscarPelicula(titulo, filmoteca.getPeliculas());
    peliculaBuscada.setProductora(productora);
  }

  public void setGeneroPeli(String titulo, String genero) {
    Pelicula peliculaBuscada = filmoteca.buscarPelicula(titulo, filmoteca.getPeliculas());
    peliculaBuscada.setGenero(genero);
  }

  public void setSinopsisPeli(String titulo, String sinopsis) {
    Pelicula peliculaBuscada = filmoteca.buscarPelicula(titulo, filmoteca.getPeliculas());
    peliculaBuscada.setSinopsis(sinopsis);
  }

  public String getStringPeli(String titulo) {
    Pelicula peliculaBuscada = filmoteca.buscarPelicula(titulo, filmoteca.getPeliculas());
    return peliculaBuscada.peliculaInfo();
  }

  public void darAltaDirector(
      String nombre,
      LocalDate fechaNac,
      String nacion,
      String ocupacion,
      String peliculas,
      String delim) {
    filmoteca.crearDirector(nombre, fechaNac, nacion, ocupacion, peliculas, delim);
  }

  public String darBajaDirector(String nombre) {
    return filmoteca.eliminarDirector(nombre);
  }

  public boolean buscarDirector(String nombre) {
    return filmoteca.buscarDirector(nombre, filmoteca.getDirectores()) != null;
  }

  public void setFechaNacDire(String nombre, LocalDate fechaNac) {
    Director directorBuscado = filmoteca.buscarDirector(nombre, filmoteca.getDirectores());
    directorBuscado.setFechaNac(fechaNac);
  }

  public void setNacionDire(String nombre, String nacion) {
    Director directorBuscado = filmoteca.buscarDirector(nombre, filmoteca.getDirectores());
    directorBuscado.setNacion(nacion);
  }

  public void setOcupacionDire(String nombre, String ocupacion) {
    Director directorBuscado = filmoteca.buscarDirector(nombre, filmoteca.getDirectores());
    directorBuscado.setOcupacion(ocupacion);
  }

  public void darAltaActor(
      String nombre,
      LocalDate fechaNac,
      String nacion,
      Integer annoDebut,
      String peliculas,
      String delim) {
    filmoteca.crearActor(nombre, fechaNac, nacion, annoDebut, peliculas, delim);
  }

  public String darBajaActor(String nombre) {
    return filmoteca.eliminarActor(nombre);
  }

  public boolean buscarActor(String nombre) {
    return filmoteca.buscarActor(nombre, filmoteca.getActores()) != null;
  }

  public void setFechaNacActor(String nombre, LocalDate fechaNac) {
    Actor actorBuscado = filmoteca.buscarActor(nombre, filmoteca.getActores());
    actorBuscado.setFechaNac(fechaNac);
  }

  public void setNacionActor(String nombre, String nacion) {
    Actor actorBuscado = filmoteca.buscarActor(nombre, filmoteca.getActores());
    actorBuscado.setNacion(nacion);
  }

  public void setAnnoDebutActor(String nombre, Integer annoDebut) {
    Actor actorBuscado = filmoteca.buscarActor(nombre, filmoteca.getActores());
    actorBuscado.setAnnoDebut(annoDebut);
  }

  public String getPeliculasActorAsTable(String nombre) {
    List<Pelicula> peliculasActor =
        filmoteca.buscarActor(nombre, filmoteca.getActores()).getPeliculas();

    peliculasActor.sort(
        (a, b) -> {
          Integer annoA = a.getAnno();
          Integer annoB = b.getAnno();
          Integer checkRes = checkNull(annoA, annoB);

          if (checkRes != null) {
            return checkRes;
          }

          return annoA.compareTo(annoB);
        });

    return filmoteca.getPeliculasAsTable(peliculasActor);
  }

  public String getPeliculasAsTable() {
    List<Pelicula> peliculas = filmoteca.getPeliculas();

    peliculas.sort((a, b) -> a.getTitulo().compareToIgnoreCase(b.getTitulo()));

    return filmoteca.getPeliculasAsTable(peliculas);
  }

  public String getDirectoresAsTable() {
    List<Director> directores = filmoteca.getDirectores();

    directores.sort(
        (a, b) -> {
          LocalDate fechaA = a.getFechaNac();
          LocalDate fechaB = b.getFechaNac();
          Integer checkRes = checkNull(fechaA, fechaB);

          if (checkRes != null) {
            return checkRes;
          }

          return fechaA.compareTo(fechaB);
        });

    directores.sort(
        (a, b) -> {
          String nacionA = a.getNacion();
          String nacionB = b.getNacion();

          if (nacionA.equals(NO_AVAILABLE)) {
            return 1;
          } else if (nacionB.equals(NO_AVAILABLE)) {
            return -1;
          }
          return nacionA.compareToIgnoreCase(nacionB);
        });

    return filmoteca.getDirectoresAsTable();
  }

  public String getActoresAsTable() {
    List<Actor> actores = filmoteca.getActores();

    actores.sort((a, b) -> a.getNombre().compareToIgnoreCase(b.getNombre()));

    actores.sort(
        (a, b) -> {
          Integer annoDebutA = a.getAnnoDebut();
          Integer annoDebutB = b.getAnnoDebut();
          Integer checkRes = checkNull(annoDebutA, annoDebutB);

          if (checkRes != null) {
            return checkRes;
          }

          return annoDebutA.compareTo(annoDebutB);
        });

    return filmoteca.getActoresAsTable();
  }

  private Integer checkNull(Object a, Object b) {
    if (a == null && b == null) {
      return 0;
    } else if (a == null) {
      return 1;
    } else if (b == null) {
      return -1;
    }
    return null;
  }

  public String getNoAvailable() {
    return Pelicula.NO_AVAILABLE;
  }
}
