#!/bin/bash
set -eu

error() {
    echo >&2 "Error: $*"
}

#################

PRTGMPPROBE__BINARY=/opt/paessler/mpprobe/prtgmpprobe

_passthrough=0
for _arg in "$@"
do
    case "$_arg" in
        --help|example-config)
            _passthrough=1
        ;;
    esac
done
if [ $_passthrough -neq 0 ] ; then
    exec gosu paessler_mpprobe:paessler_mpprobe \
        ${PRTGMPPROBE__BINARY} \
        "$@"
fi

PRTGMPPROBE__CONFIG_FILE=${PRTGMPPROBE__CONFIG_FILE:-/config/config.yml} # needs to be provided by user
PRTGMPPROBE__ID_FILE=${PRTGMPPROBE__ID_FILE:-/config/id.txt}

for _var in PRTGMPPROBE__ACCESS_KEY \
            PRTGMPPROBE__NATS__AUTHENTICATION__USER \
            PRTGMPPROBE__NATS__AUTHENTICATION__PASSWORD
do
    if [ -n "${!_var-}" ] ; then
        error "Setting ${_var} = ${!_var-} as environment variable is insecure. Please set any security related variables inside ${PRTGMPPROBE__CONFIG_FILE}."
        echo >&2 " "
        echo >&2 "Example:"
        ${PRTGMPPROBE__BINARY} example-config >&2
        exit 1
    fi
done

# Handling Env vars

if [ ! -f "${PRTGMPPROBE__CONFIG_FILE}" ] ; then
    error "Configuration file ${PRTGMPPROBE__CONFIG_FILE} does not exist. Please create one."
    echo >&2 " "
    echo >&2 "Example:"
    ${PRTGMPPROBE__BINARY} example-config >&2
    exit 1
fi

# Get/Generate a probe id from PRTGMPPROBE__ID_FILE or from PRTGMPPROBE__ID if not set in PRTGMPPROBE__CONFIG_FILE
if [ ! grep -q "^id:" "${PRTGMPPROBE__CONFIG_FILE}" ] ; then
    if [ -z "${PRTGMPPROBE__ID-}" ] ; then
        if [ ! -f "${PRTGMPPROBE__ID_FILE}" ] ; then
            cat /proc/sys/kernel/random/uuid > ${PRTGMPPROBE__ID_FILE} || (
                error "Unable to write to ${PRTGMPPROBE__ID_FILE}. Please either set PRTGMPPROBE__ID in the container environment, 'id:' in the ${PRTGMPPROBE__CONFIG_FILE} or make sure the location ${PRTGMPPROBE__ID_FILE} is writable."
                echo >&2 " "
                echo >&2 "Example:"
                echo >&2 "PRTGMPPROBE__ID=$(cat /proc/sys/kernel/random/uuid)"
                exit 1
            )
        fi
        PRTGMPPROBE__ID=$(cat ${PRTGMPPROBE__ID_FILE})
        export PRTGMPPROBE__ID
    fi
fi

export PRTGMPPROBE__NAME=${PRTGMPPROBE__NAME:-"multi-platform-probe@$(hostname)"}

export PRTGMPPROBE__MOMO__DIR=${PRTGMPPROBE__MOMO__DIR:-/opt/paessler/mpprobe/monitoringmodules/}
export PRTGMPPROBE__MAX_SCHEDULING_DELAY=${PRTGMPPROBE__MAX_SCHEDULING_DELAY:-300}
export PRTGMPPROBE__HEARTBEAT_INTERVAL=${PRTGMPPROBE__HEARTBEAT_INTERVAL:-30}
export PRTGMPPROBE__NATS__CLIENT_NAME=${PRTGMPPROBE__NATS__CLIENT_NAME:-${PRTGMPPROBE__NAME}}

# Containers don't have journald available
export PRTGMPPROBE__LOGGING__CONSOLE__LEVEL=${PRTGMPPROBE__LOGGING__CONSOLE__LEVEL:-"info"}
export PRTGMPPROBE__LOGGING__CONSOLE__WITHOUT_TIME=${PRTGMPPROBE__LOGGING__CONSOLE__WITHOUT_TIME:-"true"}
export PRTGMPPROBE__LOGGING__JOURNALD__LEVEL=${PRTGMPPROBE__LOGGING__JOURNALD__FIELD_PREFIX:-"off"}
export PRTGMPPROBE__LOGGING__JOURNALD__FIELD_PREFIX=${PRTGMPPROBE__LOGGING__JOURNALD__FIELD_PREFIX:-"PRTGMPPROBE"}

env | grep PRTGMPPROBE__ >&2

# add capabilities for icmp to the probe executable
setcap cap_net_admin,cap_net_raw+eip ${PRTGMPPROBE__BINARY} || true

exec gosu paessler_mpprobe:paessler_mpprobe \
    ${PRTGMPPROBE__BINARY} \
    --config ${PRTGMPPROBE__CONFIG_FILE} \
    "$@"
