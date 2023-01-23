#!/bin/bash
#
# La Caja Fuerte
# Primera practica evaluable, Sistemas Operativos I, Grupo A2
#

ROJO='\033[0;31m'
VERDE='\033[0;32m'
AMARILLO='\033[0;33m'
NEGRITA='\033[1m'
NOCOLOR='\033[0m'

CONF='conf.cfg'

error() {
  echo -e "${ROJO}[ERROR]: $@${NOCOLOR}\n" >&2
}

clear

if [[ -e "${CONF}" ]]; then
  source "${CONF}"
else
  if ! touch "${CONF}"; then
    error "No se puede crear el archivo ${CONF}"
    echo 'Ejecute combinator.sh en un directorio en el que tenga' \
      'permisos de escritura'
    exit -1
  fi
  echo 'LONGITUD=4' >"${CONF}"
  echo 'ESTADISTICAS=estadisticas.txt' >>"${CONF}"
  source "${CONF}"
fi

if mkdir -p "$(dirname "${ESTADISTICAS}")"; then
  if touch "${ESTADISTICAS}"; then
    EST_TMP="$(dirname "${ESTADISTICAS}")/est.tmp"
  else
    error "Ruta de estadisticas en ${CONF} no valida"
    exit -1
  fi
else
  error "Ruta de estadisticas en ${CONF} no valida"
  exit -1
fi

if [[ -n "$1" ]]; then
  if [[ '-l' = "$1" ]]; then
    if [[ "$2" -ge 2 && "$2" -le 6 ]]; then
      LONGITUD="$2"
    else
      error 'Longitud no valida'
      echo 'Introduce un valor entre 2 y 6'
      exit -1
    fi
  else
    error 'Opcion incorrecta'
    echo 'Uso: combinator.sh [-l longitud ]'
    exit -1
  fi
fi

num_aleatorio() {
  num_rnd[i]="$((RANDOM % 10))"

  for ((j = 0; j < i; j++)); do
    if [[ "${num_rnd[i]}" -eq "${num_rnd[j]}" ]]; then
      num_aleatorio
    fi
  done
}

jugar() {
  num_secreto=''
  rango="$((10 ** LONGITUD))"

  for ((i = 0; i < LONGITUD; i++)); do
    num_aleatorio
    num_secreto="${num_secreto}${num_rnd[i]}"
  done

  num_intento=0
  tiempo_inicial="$SECONDS"
  while [[ "${num_introducido}" != "${num_secreto}" ]]; do
    ((num_intento++))

    echo -e "${NEGRITA}\n\nNumero oculto:${NOCOLOR}"
    for ((i = 0; i < LONGITUD; i++)); do
      if [[ "${resultado[i]}" = 'A' ]]; then
        printf "%d" "${num_rnd[i]}"
      else
        printf "_"
      fi
    done
    echo -e "\n\nSemiaciertos: "
    for ((i = 0; i < LONGITUD; i++)); do
      if [[ "${resultado[i]}" = 'S' ]]; then
        printf "%d " "${num_digito[i]}"
      fi
    done
    echo -e "\n\nLongitud: ${LONGITUD}"
    echo "Fichero de estadisticas: ${ESTADISTICAS}"
    echo "Numero del intento: ${num_intento}"
    echo 'Nuevo Intento >>'
    read num_introducido
    if [[ "${num_introducido}" -lt 0 || "${num_introducido}" -ge "${rango}" ]]; then
      error 'Introduce un numero valido'
      continue
    fi

    for ((i = 0; i < LONGITUD; i++)); do
      resultado[i]=''
      num_digito[i]="$(((10#${num_introducido} / (10 ** (LONGITUD - i - 1))) % 10))"

      if [[ "${num_digito[i]}" -eq "${num_rnd[i]}" ]]; then
        resultado[i]='A'
        printf "${VERDE}ACIERTO ${NOCOLOR}"
        continue
      fi

      for ((j = 0; j < LONGITUD; j++)); do
        if [[ "${num_digito[i]}" -eq "${num_rnd[j]}" ]]; then
          resultado[i]='S'
          printf "${AMARILLO}SEMIACIERTO ${NOCOLOR}"
          break
        fi
      done

      if [[ -n "${resultado[i]}" ]]; then
        continue
      else
        printf "${ROJO}FALLO ${NOCOLOR}"
      fi
    done
  done

  partida="$$"
  fecha="$(date +%d/%m/%Y)"
  hora="$(date +%T)"
  tiempo_final="$SECONDS"
  tiempo="$((tiempo_final - tiempo_inicial))"
  echo -e "\n\nPartida: ${partida}"
  echo "Fecha: ${fecha} | Hora: ${hora}"
  echo "Intentos: ${num_intento} | Tiempo: ${tiempo}"
  echo "Longitud: ${LONGITUD} | Combinacion secreta: ${num_secreto}"

  printf "%7s|%10s|%8s|%2s|%4s|%2s|%6s\n" \
    "${partida}" "${fecha}" "${hora}" "${num_intento}" \
    "${tiempo}" "${LONGITUD}" "${num_secreto}" >>"$ESTADISTICAS"

  continuar
}

configuracion() {
  echo -e '\nSeleccione el parametro que desea modificar'
  echo "  1) Longitud (actual: ${LONGITUD})"
  echo "  2) Ruta del fichero de estadisticas (actual: ${ESTADISTICAS})"
  echo "  3) Ninguno"

  read opcion_conf
  if [[ "${opcion_conf}" -eq 1 ]]; then
    echo -e '\nLongitud nueva (no introducir nada para conservar la longitud):'
    read LONGITUD_NUEVA
    if [[ -n "${LONGITUD_NUEVA}" ]]; then
      while [[ "${LONGITUD_NUEVA}" -lt 2 || "${LONGITUD_NUEVA}" -gt 6 ]]; do
        error 'Longitud incorrecta'
        echo 'Introduce una longitud del 2 a 6:'
        read LONGITUD_NUEVA
      done
    else
      LONGITUD_NUEVA="${LONGITUD}"
    fi

    mv "${CONF}" "${CONF}.old"
    echo "LONGITUD=${LONGITUD_NUEVA}" >"${CONF}"
    grep "ESTADISTICAS" <"${CONF}.old" >>"${CONF}"
    rm "${CONF}.old"
    source "${CONF}"
    configuracion
  elif [[ "${opcion_conf}" -eq 2 ]]; then
    echo -e '\nFichero nuevo de estadisticas (no introducir nada para ' \
      'conservar el fichero de estadisticas):'
    read ESTADISTICAS_NUEVA
    if [[ -n "${ESTADISTICAS_NUEVA}" ]]; then
      error_est=1
      while [[ "${error_est}" -ne 0 ]]; do
        if [[ -d "${ESTADISTICAS_NUEVA}" ]]; then
          ESTADISTICAS_NUEVA="${ESTADISTICAS_NUEVA}/estadisticas.txt"
        fi
        if mkdir -p "$(dirname "${ESTADISTICAS_NUEVA}")"; then
          if touch "${ESTADISTICAS_NUEVA}"; then
            EST_TMP="$(dirname "${ESTADISTICAS_NUEVA}")/est.tmp"
            error_est=0
          else
            error 'Ruta de estadisticas no valida'
            echo 'Introduce una ruta valida:'
            read ESTADISTICAS_NUEVA
          fi
        else
          error 'Ruta de estadisticas no valida'
          echo 'Introduce una ruta valida:'
          read ESTADISTICAS_NUEVA
        fi
      done
    else
      ESTADISTICAS_NUEVA="${ESTADISTICAS}"
    fi

    mv "${CONF}" "${CONF}.old"
    grep "LONGITUD" <"${CONF}.old" >"${CONF}"
    echo "ESTADISTICAS=${ESTADISTICAS_NUEVA}" >>"${CONF}"
    rm "${CONF}.old"
    source "${CONF}"
    configuracion
  elif [[ "${opcion_conf}" -eq 3 ]]; then
    continuar
  else
    error 'Opcion no valida'
    configuracion
  fi
}

estadisticas() {
  i=0
  sum_longitud=0
  sum_tiempo=0
  while IFS='|' read e_partida[i] e_fecha[i] e_hora[i] e_intentos[i] \
    e_tiempo[i] e_longitud[i] e_combinacion[i]; do
    sum_longitud=$((sum_longitud + e_longitud[i]))
    sum_tiempo=$((sum_tiempo + e_tiempo[i]))
    ((i++))
  done <"${ESTADISTICAS}"

  t_corta=0
  t_larga=0
  l_corta="${e_longitud[0]}"
  l_larga="${e_longitud[0]}"
  i_corta=0
  i_larga=0
  for ((j = 1; j < i; j++)); do
    if [[ "${e_tiempo[j]}" -lt "${e_tiempo[t_corta]}" ]]; then
      t_corta="${j}"
    elif [[ "${e_tiempo[j]}" -gt "${e_tiempo[t_larga]}" ]]; then
      t_larga="${j}"
    fi

    if [[ "${e_longitud[j]}" -lt "${l_corta}" ]]; then
      l_corta="${e_longitud[j]}"
    elif [[ "${e_longitud[j]}" -gt "${l_larga}" ]]; then
      l_larga="${e_longitud[j]}"
    fi

    if [[ "${e_longitud[j]}" -eq "${l_corta}" ]]; then
      if [[ "${e_intentos[j]}" -lt "${e_intentos[i_corta]}" ]]; then
        i_corta="${j}"
      fi
    elif [[ "${e_longitud[j]}" -eq "${l_larga}" ]]; then
      if [[ "${e_intentos[j]}" -lt "${e_intentos[i_larga]}" ]]; then
        i_larga="${j}"
      fi
    fi
  done

  {
    echo -e "${NEGRITA}ESTADISTICAS${NOCOLOR}"

    echo -e '\nGENERALES'
    echo "Numero total de partidas jugadas: ${i}"
    if [[ "${i}" -ne 0 ]]; then
      echo "Media de las longitudes de las combinaciones de todas las partidas" \
        "jugadas: $((sum_longitud / i))"
      echo "Media de los tiempos de todas las partidas jugadas: $((sum_tiempo / i))"
    fi
    echo "Tiempo total invertido en todas las partidas: ${sum_tiempo}"

    echo -e '\nJUGADAS ESPECIALES'
    echo -e 'Jugada mas corta:'
    echo "Partida: ${e_partida[t_corta]}"
    echo "Fecha: ${e_fecha[t_corta]} | Hora: ${e_hora[t_corta]}"
    echo "Intentos: ${e_intentos[t_corta]}      | Tiempo: ${e_tiempo[t_corta]}"
    echo "Longitud: ${e_longitud[t_corta]}      | Combinacion secreta:" \
      "${e_combinacion[t_corta]}"

    echo -e '\nJugada mas larga:'
    echo "Partida: ${e_partida[t_larga]}"
    echo "Fecha: ${e_fecha[t_larga]} | Hora: ${e_hora[t_larga]}"
    echo "Intentos: ${e_intentos[t_larga]}      | Tiempo: ${e_tiempo[t_larga]}"
    echo "Longitud: ${e_longitud[t_larga]}      | Combinacion secreta:" \
      "${e_combinacion[t_larga]}"

    echo -e '\nJugada de menos intentos con la combinacion mas larga:'
    echo "Partida: ${e_partida[i_larga]}"
    echo "Fecha: ${e_fecha[i_larga]} | Hora: ${e_hora[i_larga]}"
    echo "Intentos: ${e_intentos[i_larga]}      | Tiempo: ${e_tiempo[i_larga]}"
    echo "Longitud: ${e_longitud[i_larga]}      | Combinacion secreta:" \
      "${e_combinacion[i_larga]}"

    echo -e '\nJugada de menos intentos con la combinacion mas corta:'
    echo "Partida: ${e_partida[i_corta]}"
    echo "Fecha: ${e_fecha[i_corta]} | Hora: ${e_hora[i_corta]}"
    echo "Intentos: ${e_intentos[i_corta]}      | Tiempo: ${e_tiempo[i_corta]}"
    echo "Longitud: ${e_longitud[i_corta]}      | Combinacion secreta:" \
      "${e_combinacion[i_corta]}"
  } >"${EST_TMP}"

  # comando para mostrar las estadisticas de arriba a abajo
  more "${EST_TMP}"
  rm "${EST_TMP}"
  continuar
}

grupo() {
  echo '      Grupo:'
  echo -e "  ${NEGRITA}Alberto Garcia Martin${NOCOLOR}"
  echo -e "  ${NEGRITA}Ivan Campos Alamillo${NOCOLOR}"
  continuar
}

continuar() {
  echo -e '\nPulse INTRO para continuar.'
  read
  clear
}

menu() {
  echo 'J)JUGAR'
  echo 'C)CONFIGURACION'
  echo 'E)ESTADISTICAS'
  echo 'G)GRUPO'
  echo 'S)SALIR'
  echo '"La Caja Fuerte". Introduzca una opcion >>'
  read opcion
  clear

  case "${opcion}" in
  J | j) jugar ;;
  C | c) configuracion ;;
  E | e) estadisticas ;;
  G | g) grupo ;;
  S | s) exit 0 ;;
  *) error 'Opcion no valida' ;;
  esac
}

while true; do
  menu
done
