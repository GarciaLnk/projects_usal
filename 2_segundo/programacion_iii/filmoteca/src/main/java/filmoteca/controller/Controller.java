package filmoteca.controller;

import filmoteca.data.Model;
import java.io.File;
import java.time.LocalDate;
import java.util.logging.Level;
import java.util.logging.Logger;

public class Controller {

  private static final Logger LOGGER = Logger.getLogger(Controller.class.getName());
  private final Model model = new Model();

  public boolean arranque() {
    File dirFilm = new File(model.getPathFilmoteca().toString());
    if (!dirFilm.exists() && !dirFilm.mkdir()) { // solo hace mkdir si no existe dirFilm
      LOGGER.log(Level.SEVERE, "no se pudo crear la carpeta de la filmoteca en el Escritorio");
      return false;
    }

    if (!model.loadDirectoresFromBin(model.getPathDirectoresBin())) {
      LOGGER.log(Level.INFO, "se importará directores.txt");
      if (!model.importDirectoresFromTxt(model.getPathDirectoresTxt())) {
        LOGGER.log(Level.WARNING,
            "no se ha encontrado ningún archivo desde el que importar los directores");
      }
    }

    if (!model.loadActoresFromBin(model.getPathActoresBin())) {
      LOGGER.log(Level.INFO, "se importará directores.txt");
      if (!model.importActoresFromTxt(model.getPathActoresTxt())) {
        LOGGER.log(Level.WARNING,
            "no se ha encontrado ningún archivo desde el que importar los actores");
      }
    }

    if (!model.loadPeliculasFromBin(model.getPathPeliculasBin())) {
      LOGGER.log(Level.INFO, "se importará peliculas.txt");
      if (!model.importPeliculasFromTxt(model.getPathPeliculasTxt())) {
        LOGGER.log(Level.WARNING,
            "no se ha encontrado ningún archivo desde el que importar las películas");
      }
    }

    return true;
  }

  public void salida() {
    model.saveToBin();
  }

  public void exportDirectoresToCol() {
    model.exportDirectoresToCol();
  }

  public void exportPeliculasToHtml() {
    model.exportPeliculasToHtml();
  }

  public void darAltaPelicula(String titulo, Integer anno, Integer duracion, String pais,
      String direccion, String guion, String musica, String fotografia, String reparto,
      String productora, String genero, String sinopsis, String delim) {
    model.darAltaPelicula(titulo, anno, duracion, pais, direccion, guion, musica, fotografia,
        reparto, productora, genero, sinopsis, delim);
  }

  public boolean darBajaPelicula(String titulo) {
    return model.darBajaPelicula(titulo);
  }

  public boolean buscarPelicula(String titulo) {
    return model.buscarPelicula(titulo);
  }

  public void setAnnoPeli(String titulo, Integer anno) {
    model.setAnnoPeli(titulo, anno);
  }

  public void setDuracionPeli(String titulo, Integer duracion) {
    model.setDuracionPeli(titulo, duracion);
  }

  public void setPaisPeli(String titulo, String pais) {
    model.setPaisPeli(titulo, pais);
  }

  public void setGuionPeli(String titulo, String guion) {
    model.setGuionPeli(titulo, guion);
  }

  public void setMusicaPeli(String titulo, String musica) {
    model.setMusicaPeli(titulo, musica);
  }

  public void setFotografiaPeli(String titulo, String fotografia) {
    model.setFotografiaPeli(titulo, fotografia);
  }

  public void setProductoraPeli(String titulo, String productora) {
    model.setProductoraPeli(titulo, productora);
  }

  public void setGeneroPeli(String titulo, String genero) {
    model.setGeneroPeli(titulo, genero);
  }

  public void setSinopsisPeli(String titulo, String sinopsis) {
    model.setSinopsisPeli(titulo, sinopsis);
  }

  public String getStringPeli(String titulo) {
    return model.getStringPeli(titulo);
  }

  public void darAltaDirector(String nombre, LocalDate fechaNac, String nacion, String ocupacion,
      String peliculas, String delim) {
    model.darAltaDirector(nombre, fechaNac, nacion, ocupacion, peliculas, delim);
  }

  public String darBajaDirector(String nombre) {
    return model.darBajaDirector(nombre);
  }

  public boolean buscarDirector(String nombre) {
    return model.buscarDirector(nombre);
  }

  public void setFechaNacDire(String nombre, LocalDate fechaNac) {
    model.setFechaNacDire(nombre, fechaNac);
  }

  public void setNacionDire(String nombre, String nacion) {
    model.setNacionDire(nombre, nacion);
  }

  public void setOcupacionDire(String nombre, String ocupacion) {
    model.setOcupacionDire(nombre, ocupacion);
  }

  public void darAltaActor(String nombre, LocalDate fechaNac, String nacion, Integer annoDebut,
      String peliculas, String delim) {
    model.darAltaActor(nombre, fechaNac, nacion, annoDebut, peliculas, delim);
  }

  public String darBajaActor(String nombre) {
    return model.darBajaActor(nombre);
  }

  public boolean buscarActor(String nombre) {
    return model.buscarActor(nombre);
  }

  public void setFechaNacActor(String nombre, LocalDate fechaNac) {
    model.setFechaNacActor(nombre, fechaNac);
  }

  public void setNacionActor(String nombre, String nacion) {
    model.setNacionActor(nombre, nacion);
  }

  public void setAnnoDebutActor(String nombre, Integer annoDebut) {
    model.setAnnoDebutActor(nombre, annoDebut);
  }

  public String getPeliculasActorAsTable(String nombre) {
    return model.getPeliculasActorAsTable(nombre);
  }

  public String getPeliculasAsTable() {
    return model.getPeliculasAsTable();
  }

  public String getDirectoresAsTable() {
    return model.getDirectoresAsTable();
  }

  public String getActoresAsTable() {
    return model.getActoresAsTable();
  }

  public String getNoAvailable() {
    return model.getNoAvailable();
  }
}
