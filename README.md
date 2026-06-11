# Containerized Multi-Platform Probe for PRTG

This is the [docker container][dockerhub] of the [Multi-Platform Probe] for Paessler PRTG.
Use this container to install and configure the multi-platform probe to monitor remote systems.

For more information about remote probes and PRTG, see the [PRTG Manual: Remote Probes and Multiple Probes][prtgmanual:probes].

  [dockerhub]: https://hub.docker.com/r/paessler/multi-platform-probe
  [Multi-Platform Probe]: https://helpdesk.paessler.com/en/support/solutions/articles/76000063903
  [prtgmanual:probes]: https://www.paessler.com/manuals/prtg/remote_probes_and_multiple_probes

## Compatibility and requirements

The multi-platform probe is always backwards compatible with at least three PRTG stable
releases.
For more information on which multi-platform probe versions are compatible with
which PRTG versions, see the [Knowledge Base](https://helpdesk.paessler.com/en/support/solutions/articles/76000084909).


We recommend that you always update to the latest version of PRTG via the Auto-Update feature.

Requires a `NATS server` connection configured in PRTG.

 [prtg-96]: https://www.paessler.com/prtg/history/stable#24.2.96.1315
 [manual]: https://manuals.paessler.com/multiplatformprobemanual.pdf

## How to use the multi-platform probe container

The set up to use this container is a three-part process:

1. [Configure the NATS server](#configure-the-nats-server)
2. [Configure PRTG](#configure-prtg)
3. [Install and use the container](#container-usage)

ℹ️ If you already have a NATS server configured in PRTG, skip to [step 3](#container-usage).

### Configure the NATS server

Paessler PRTG ships with a NATS server. For the step-by-step instructions on how configure the NATS server for the Multi-Platform Probe, see section **2.1: Configure NATS server connection** in the [Multi-Platform Probe for PRTG][manual] manual.

ℹ️ If you want to deploy your NATS server on a non-Windows system, see the NATS documentation on their website.

### Configure PRTG

For step-by-step instructions on how to configure PRTG, see section **2.3: Configure PRTG connection** in the [Multi-Platform Probe for PRTG][manual] manual.

### Container usage

You can now use containers to set up multi-platform probe instances.

To run the multi-platform probe for PRTG, you have to create a configuration file with at least the following items:

```yaml
access_key: YOUR_PROBE_ACCESS_KEY
nats:
  url: tls://localhost:23561
  authentication:
    seed: YOUR_NKEY_SEED
    pubkey: YOUR_PUBLIC_NKEY
  tenant: YOUR_TENANT_NAME
```

You must put the configuration file into the `/config/config.yml` volume of the docker container.
For all available configuration options, see [config.full-example.yml](./config/config.full-example.yml).

ℹ️ If necessary you can put your custom [CA certificate][TLS] into `/config/certs` and specify it in the `/config/config.yml` as well:

```yaml
access_key: YOUR_PROBE_ACCESS_KEY
nats:
  url: tls://localhost:23561
  authentication:
    seed: YOUR_NKEY_SEED
    pubkey: YOUR_PUBLIC_NKEY
  tenant: YOUR_TENANT_NAME
  server_ca: /config/certs/ca.crt
```

ℹ️ The container also used the `/config` volume to store the [multi-platform probe's GID][GID] and therefore cannot be set as read-only (`:ro`) unless you specify the [multi-platform probe's GID][GID] as an environment variable.

You can also use the `/opt/paessler/share/scripts` volume for the scripts of the [Script v2][prtgmanual:scriptv2] sensor.

#### Generate a configuration file using the built-in wizard

Instead of creating a `config.yaml` configuration file manually, you can use the interactive configuration `config wizard` subcommand of the probe.
The wizard guides you through all mandatory settings and outputs a configuration file at the specified output path.

##### creating a config using docker compose

The following examples show how to run the `config wizard` interactively to save a config file directly to the mounted `./config/` folder.

```sh
docker compose run --rm prtgmpprobe config --output-path "/config/config.yaml" wizard
```

or using `docker run` directly:

```sh
docker run -it --rm \
  -v $(pwd)/config:/config \
  paessler/multi-platform-probe:latest \
  config --output-path "/config/config.yaml" wizard
```

The container exits after the wizard finishes. The config file is written to the `./config` folder.

[prtgmanual:scriptv2]: https://www.paessler.com/manuals/prtg/script_v2_sensor
[TLS]: https://kb.paessler.com/en/topic/91877-how-can-i-create-a-tls-certificate
[GID]: https://www.paessler.com/manuals/prtg/prtg_administration_tool_on_remote_probe_systems#:~:text=GID

```sh
docker run -it \
  --network bridge \
  -v $(pwd)/scripts:/opt/paessler/share/scripts:ro \
  -v $(pwd)/config:/config \
  --cap-add NET_ADMIN \
  --cap-add NET_RAW \
  paessler/multi-platform-probe:latest
```

You can also use `docker-compose`. There is an example file here: [docker-compose.yml](docker-compose.yml)

### Customization

The multi-platform probe container supports all safe environment variables which are environment variables which do not contain secrets.
While the container provides some defaults, we recommend that you change the following environment variables to your liking:

| Environment Variable | Description | Default |
| -- | -- | -- |
| `PRTGMPPROBE__NAME` | The name of the object shown in PRTG. | `multi-platform-probe@$(hostname)` |
| `PRTGMPPROBE__ID` | The GID of the multi-platform probe. This must be a valid UUIDv4. The container automatically generates the GID when you create it and stores the GID in the `/config` volume. If you want to ensure that you always get the same UUIDv4, then we recommend that you use `uuidgen(1)` with a unique DNS string for your container, e.g. `uuidgen --namespace @dns --name com.paesslerfans.containers.acme --sha1`. | Randomly generated on the first run. |
| `PRTGMPPROBE__LINUX_UID` | The Linux User ID for `paessler_mpprobe` that service runs as and files are owned by. | `999` |
| `PRTGMPPROBE__LINUX_GID` | The Linux Group ID for `paessler_mpprobe` that service runs as and files are owned by. | `999` |

## Feedback and issues

We are thankful for any feedback or ideas on how to improve. If you want to submit feedback or report an issue, please open an issue in our [Issue Tracker].

 [Issue Tracker]: https://github.com/PaesslerAG/docker-multi-platform-probe/issues

## Licensing

See [LICENSE](./LICENSE) for the full MIT License text.
