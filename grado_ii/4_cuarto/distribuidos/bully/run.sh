#!/bin/bash

PROJECT_NAME="bully-rest"
CLIENT_NAME="client.jar"
TOMCAT_PORT="8080"

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
project_dir="${script_dir}/${PROJECT_NAME}"

usage() {
    cat <<EOF
Uso: $(basename "${BASH_SOURCE[0]}") [-h] -g gestor servidor1 [servidor2...]

Script para ejecutar ${PROJECT_NAME} en distintos equipos.

Opciones disponibles:
-h, --help              Imprime este mensaje
-g, --gestor            Direccion IP del gestor
-m, --monitor           Arrancar gestor en modo monitor
EOF
    exit
}

parse_params() {
    host=''
    monitor=false

    while :; do
        case "${1-}" in
        -h | --help) usage ;;
        -g | --gestor)
            host="${2-}"
            shift
            ;;
        -m | --monitor) monitor=true ;;
        -?*) echo "Opcion desconocida: $1" && exit 1 ;;
        *) break ;;
        esac
        shift
    done

    args=("$@")

    [[ -z "${host-}" ]] && echo "Hay que especificar el gestor" && exit 1
    [[ ${#args[@]} -eq 0 ]] && echo "Hay que especificar al menos un servidor" && exit 1

    return 0
}

check_ssh() {
    [ ! -f "${HOME}/.ssh/id_rsa.pub" ] && ssh-keygen
    ssh-copy-id -i "${HOME}/.ssh/id_rsa.pub" "$1" >/dev/null 2>&1

    remote_home=$(ssh "$1" "echo \${HOME}")
    remote_script_dir="${remote_home}${script_dir#"${HOME}"}"

    if ssh "$1" [[ ! -f "${remote_script_dir}/${PROJECT_NAME}/${CLIENT_NAME}" ]]; then
        echo "Gestor no encontrado en $1"
        echo "Desplegando el gestor..."
        ./setup.sh -g "$1"
    fi
}

parse_params "$@"

espera=false
for i in "${!args[@]}"; do
    if ! nc -z "${args[$i]}" "${TOMCAT_PORT}" 2>/dev/null; then
        echo "No se puede establecer una conexion con el servidor de Tomcat en ${args[$i]}"
        echo "Desplegando el servidor en ${args[$i]}..."
        ./setup.sh "${args[$i]}"
        espera=true
    fi

    if [ "${args[$i]}" = "127.0.0.1" ] || [ "${args[$i]}" = "localhost" ]; then
        args[$i]="$(hostname -I | awk '{print $1;}')"
    fi
done

if ${espera}; then
    sleep 5
fi

if [ -n "${host}" ]; then
    if [ "${host}" = "127.0.0.1" ] || [ "${host}" = "localhost" ] ||
        [[ "$(hostname -I)" == *"${host}"* ]] ||
        { [[ -n "$(dig +short "${host}")" ]] && [[ "$(hostname -I)" == *"$(dig +short "${host}")"* ]]; }; then
        if [[ ! -f "${project_dir}/${CLIENT_NAME}" ]]; then
            echo "Gestor no encontrado en $1"
            echo "Desplegando el gestor..."
            ./setup.sh -g "${host}"
        fi
        if ${monitor}; then
            java -jar "${project_dir}/${CLIENT_NAME}" -monitor "${args[@]}"
        else
            java -jar "${project_dir}/${CLIENT_NAME}" "${args[@]}"
        fi
    else
        if ! nc -z "${host}" 22 2>/dev/null; then
            echo "No se puede establecer una conexion SSH con el host ${host}"
        else
            check_ssh "${host}"
            if ${monitor}; then
                ssh "${host}" "java -jar ${remote_script_dir}/${PROJECT_NAME}/${CLIENT_NAME}" -monitor "${args[@]}"
            else
                ssh "${host}" "java -jar ${remote_script_dir}/${PROJECT_NAME}/${CLIENT_NAME}" "${args[@]}"
            fi
        fi
    fi
fi
