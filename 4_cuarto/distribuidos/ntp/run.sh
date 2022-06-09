#!/bin/bash

PROJECT_NAME="ntp-rest"
CLIENT_NAME="client.jar"
TOMCAT_PORT="8080"

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
project_dir="${script_dir}/${PROJECT_NAME}"

usage() {
    cat <<EOF
Uso: $(basename "${BASH_SOURCE[0]}") [-h] -c cliente servidor1 [servidor2...]

Script para ejecutar ${PROJECT_NAME} en distintos equipos.

Opciones disponibles:
-h, --help              Imprime este mensaje
-c, --cliente           Direccion IP del cliente
EOF
    exit
}

parse_params() {
    host=''

    while :; do
        case "${1-}" in
        -h | --help) usage ;;
        -c | --cliente)
            host="${2-}"
            shift
            ;;
        -?*) echo "Opcion desconocida: $1" && exit 1 ;;
        *) break ;;
        esac
        shift
    done

    args=("$@")

    [[ -z "${host-}" ]] && echo "Hay que especificar el cliente" && exit 1
    [[ ${#args[@]} -eq 0 ]] && echo "Hay que especificar al menos un servidor" && exit 1

    return 0
}

check_ssh() {
    [ ! -f "${HOME}/.ssh/id_rsa.pub" ] && ssh-keygen
    ssh-copy-id -i "${HOME}/.ssh/id_rsa.pub" "$1" >/dev/null 2>&1

    remote_home=$(ssh "$1" "echo \${HOME}")
    remote_script_dir="${remote_home}${script_dir#"${HOME}"}"

    if ssh "$1" [[ ! -f "${remote_script_dir}/${PROJECT_NAME}/${CLIENT_NAME}" ]]; then
        echo "Cliente no encontrado en $1"
        echo "Desplegando el cliente..."
        ./setup.sh -l "$1"
    fi
}

parse_params "$@"

for server in "${args[@]}"; do
    if ! nc -z "${server}" "${TOMCAT_PORT}" 2>/dev/null; then
        echo "No se puede establecer una conexion con el servidor de Tomcat en ${server}"
        echo "Desplegando el servidor en ${server}..."
        ./setup.sh "${server}"
        sleep 5
    fi
done

if [ -n "${host}" ]; then
    if [ "${host}" = "127.0.0.1" ] || [ "${host}" = "localhost" ] ||
        [[ "$(hostname -I)" == *"${host}"* ]] ||
        { [[ -n "$(dig +short "${host}")" ]] && [[ "$(hostname -I)" == *"$(dig +short "${host}")"* ]]; }; then
        if [[ ! -f "${project_dir}/${CLIENT_NAME}" ]]; then
            echo "Cliente no encontrado en $1"
            echo "Desplegando el cliente..."
            ./setup.sh -l "${host}"
        fi
        java -jar "${project_dir}/${CLIENT_NAME}" "${args[@]}" &
    else
        if ! nc -z "${host}" 22 2>/dev/null; then
            echo "No se puede establecer una conexion SSH con el host ${host}"
        else
            check_ssh "${host}"
            ssh "${host}" "java -jar ${remote_script_dir}/${PROJECT_NAME}/${CLIENT_NAME}" "${args[@]}" &
        fi
    fi
fi
