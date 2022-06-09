package filmoteca.data;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

class Pelicula implements Serializable {

  static final String NO_AVAILABLE = "n/a";
  private static final long serialVersionUID = 11L;
  private static final String UNIDAD_DURACION = " min.";
  private final String titulo;
  private Integer anno;
  private Integer duracion;
  private String pais;
  private List<Director> direccion = new ArrayList<>();
  private String guion;
  private String musica;
  private String fotografia;
  private List<Actor> reparto = new ArrayList<>();
  private String productora;
  private String genero;
  private String sinopsis;

  Pelicula(String titulo) {
    this.titulo = titulo;
    pais = NO_AVAILABLE;
    guion = NO_AVAILABLE;
    musica = NO_AVAILABLE;
    fotografia = NO_AVAILABLE;
    productora = NO_AVAILABLE;
    genero = NO_AVAILABLE;
    sinopsis = NO_AVAILABLE;
  }

  Pelicula(
      String titulo,
      Integer anno,
      Integer duracion,
      String pais,
      String guion,
      String musica,
      String fotografia,
      String productora,
      String genero,
      String sinopsis) {
    this.titulo = titulo;
    this.anno = anno;
    this.duracion = duracion;
    this.pais = pais;
    this.guion = guion;
    this.musica = musica;
    this.fotografia = fotografia;
    this.productora = productora;
    this.genero = genero;
    this.sinopsis = sinopsis;
  }

  String peliculaToHtml() {
    String campoHtml = "<TD>%s</TD>";

    return String.format(
        "<TR>" + campoHtml + campoHtml + campoHtml + campoHtml + campoHtml + campoHtml + campoHtml
            + campoHtml + campoHtml + campoHtml + campoHtml + campoHtml + "</TR>",
        getTitulo(),
        (getAnno() != null) ? getAnno() : NO_AVAILABLE,
        (getDuracion() != null) ? getDuracion() + UNIDAD_DURACION : NO_AVAILABLE,
        getPais(),
        direccionToString(),
        getGuion(),
        getMusica(),
        getFotografia(),
        repartoToString(),
        getProductora(),
        getGenero(),
        getSinopsis());
  }

  String peliculaInfo() {
    return String.format(
        "%nTítulo: %s%n"
            + "Año: %s%n"
            + "Duración: %s%n"
            + "País: %s%n"
            + "Dirección: %s%n"
            + "Guion: %s%n"
            + "Música: %s%n"
            + "Fotografía: %s%n"
            + "Reparto: %s%n"
            + "Productora: %s%n"
            + "Género: %s%n"
            + "Sinopsis: %s",
        getTitulo(),
        (getAnno() != null) ? getAnno() : NO_AVAILABLE,
        (getDuracion() != null) ? getDuracion() + UNIDAD_DURACION : NO_AVAILABLE,
        getPais(),
        direccionToString(),
        getGuion(),
        getMusica(),
        getFotografia(),
        repartoToString(),
        getProductora(),
        getGenero(),
        getSinopsis());
  }

  String peliculaToTable() {
    return String.format(
        "| %-65s | %-4s | %-8s | %-25s | %-15s |",
        getTitulo(),
        (getAnno() != null) ? getAnno() : NO_AVAILABLE,
        (getDuracion() != null) ? getDuracion() + UNIDAD_DURACION : NO_AVAILABLE,
        getPais(),
        getGenero());
  }

  private String direccionToString() {
    if (getDireccion() == null || getDireccion().isEmpty()) {
      return NO_AVAILABLE;
    }

    StringBuilder sb = new StringBuilder();
    String prefix = "";
    for (Director d : getDireccion()) {
      sb.append(prefix);
      prefix = ", ";
      sb.append(d.getNombre());
    }
    return sb.toString();
  }

  private String repartoToString() {
    if (getReparto() == null || getDireccion().isEmpty()) {
      return NO_AVAILABLE;
    }

    StringBuilder sb = new StringBuilder();
    String prefix = "";
    for (Actor a : getReparto()) {
      sb.append(prefix);
      prefix = ", ";
      sb.append(a.getNombre());
    }
    return sb.toString();
  }

  String getTitulo() {
    return titulo;
  }

  Integer getAnno() {
    return anno;
  }

  void setAnno(Integer anno) {
    if (anno != null) {
      this.anno = anno;
    }
  }

  private Integer getDuracion() {
    return duracion;
  }

  void setDuracion(Integer duracion) {
    if (duracion != null) {
      this.duracion = duracion;
    }
  }

  private String getPais() {
    return pais;
  }

  void setPais(String pais) {
    if (!pais.equals(NO_AVAILABLE)) {
      this.pais = pais;
    }
  }

  List<Director> getDireccion() {
    return direccion;
  }

  void setDireccion(List<Director> direccion) {
    if (!direccion.isEmpty()) {
      this.direccion = direccion;
    }
  }

  private String getGuion() {
    return guion;
  }

  void setGuion(String guion) {
    if (!guion.equals(NO_AVAILABLE)) {
      this.guion = guion;
    }
  }

  private String getMusica() {
    return musica;
  }

  void setMusica(String musica) {
    if (!musica.equals(NO_AVAILABLE)) {
      this.musica = musica;
    }
  }

  private String getFotografia() {
    return fotografia;
  }

  void setFotografia(String fotografia) {
    if (!fotografia.equals(NO_AVAILABLE)) {
      this.fotografia = fotografia;
    }
  }

  List<Actor> getReparto() {
    return reparto;
  }

  void setReparto(List<Actor> reparto) {
    if (!reparto.isEmpty()) {
      this.reparto = reparto;
    }
  }

  private String getProductora() {
    return productora;
  }

  void setProductora(String productora) {
    if (!productora.equals(NO_AVAILABLE)) {
      this.productora = productora;
    }
  }

  private String getGenero() {
    return genero;
  }

  void setGenero(String genero) {
    if (!genero.equals(NO_AVAILABLE)) {
      this.genero = genero;
    }
  }

  private String getSinopsis() {
    return sinopsis;
  }

  void setSinopsis(String sinopsis) {
    if (!sinopsis.equals(NO_AVAILABLE)) {
      this.sinopsis = sinopsis;
    }
  }
}
