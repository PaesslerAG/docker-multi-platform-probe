# Containerized Multi-Platform Probe for PRTG

This is the [docker container][dockerhub] of the [Multi-Platform Probe] for Paessler PRTG.
Use this container to install and configure the multi-platform probe to monitor remote systems.

For more information about remote probes and PRTG, see the [PRTG Manual: Remote Probes and Multiple Probes][prtgmanual:probes].

  [dockerhub]: https://hub.docker.com/r/paessler/multi-platform-probe
  [Multi-Platform Probe]: https://kb.paessler.com/en/topic/90140
  [prtgmanual:probes]: https://www.paessler.com/manuals/prtg/remote_probes_and_multiple_probes

## Compatibility and requirements

Requires as of **[PRTG 24.2.96][prtg-96]**.
We recommend that you always update to the latest version of PRTG via the Auto-Update feature.

Requires a [NATS server](#install-and-configure-a-nats-server) connection configured in PRTG.

 [prtg-96]: https://www.paessler.com/prtg/history/stable#24.2.96.1315
 [manual]: https://paessler.canto.global/direct/document/qvou34dmut1uh0gg6mqee3ip2k/K-e9xGiEiT58XzlH3s_Nf-B3lVk/original?content-type=application%2Fpdf&name=Multi-Platform+Probe+Manual.pdf

## How to use the multi-platform probe container

The set up to use this container is a three-part process:

1. [Install and configure a NATS server](#install-and-configure-a-nats-server)
2. [Configure PRTG](#configure-prtg)
3. [Install and use the container](#container-usage)

ℹ️ If you already have a NATS server configured in PRTG, skip to [step 3](#container-usage).

### Install and configure a NATS server

Paessler GmbH provides the **NATS Server for Paessler PRTG** Windows installer that does the following:

* Installs the NATS server executable.
* Configures the NATS server.
* Installs and starts the NATS server service in the background.

For the installer and step-by-step instructions on how to set up a NATS server on Windows, see section **Step 1: Install a NATS server** in the [Multi-Platform Probe for PRTG (PDF)][manual] manual.

ℹ️ If you want to deploy your NATS server on a non-Windows system, see the NATS documentation on their website.

### Configure PRTG

Once you set up your NATS server, you must configure PRTG to accept connections to the NATS server.
This is done from the PRTG web interface via **Setup** | **Cores & Probes** | **[Multi-Platform Probe Connection Settings][prtg-manual:cores]**.

For step-by-step instructions on how to configure PRTG, see section **Step 2: Configure connection in PRTG** in the [Multi-Platform Probe for PRTG (PDF)][manual] manual.

 [prtg-manual:cores]: https://www.paessler.com/manuals/prtg/core_and_probes#multi_platform_probe_connection

### Container usage

You can now use containers to set up multi-platform probe instances.

To run the multi-platform probe for PRTG, you have to create a configuration file with at least the following items:

```yaml
access_key: YOUR_PROBE_ACCESS_KEY
nats:
  url: tls://localhost:23561
  authentication:
    user: USER
    password: PASSWORD
```

You must put the configuration file into the `/config/config.yml` volume of the docker container.
For all available configuration options, see [config.full-example.yml](./config/config.full-example.yml).

ℹ️ If necessary you can put your custom [CA certificate][TLS] into `/config/certs` and specify it in the `/config/config.yml` as well:

```yaml
access_key: YOUR_PROBE_ACCESS_KEY
nats:
  url: tls://localhost:23561
  authentication:
    user: USER
    password: PASSWORD
  server_ca: /config/certs/ca.crt
```

ℹ️ The container also used the `/config` volume to store the [multi-platform probe's GID][GID] and therefore cannot be set as read-only (`:ro`) unless you specify the [multi-platform probe's GID][GID] as an environment variable.

You can also use the `/opt/paessler/share/scripts` volume for the scripts of the [Script v2][prtgmanual:scriptv2] sensor.

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
|--|--|--|
| `PRTGMPPROBE__NAME` | The name of the object shown in PRTG. | `multi-platform-probe@$(hostname)` |
| `PRTGMPPROBE__ID` | The GID of the multi-platform probe. This must be a valid UUIDv4. The container automatically generates the GID when you create it and stores the GID in the `/config` volume. If you want to ensure that you always get the same UUIDv4, then we recommend that you use `uuidgen(1)` with a unique DNS string for your container, e.g. `uuidgen --namespace @dns --name com.paesslerfans.containers.acme --sha1`. | Randomly generated on the first run. |


## Feedback and issues

We are thankful for any feedback or ideas on how to improve. If you want to submit feedback or report an issue, please open an issue in our [Issue Tracker].

 [Issue Tracker]: https://github.com/PaesslerAG/docker-multi-platform-probe/issues

## Licensing

See [LICENSE](./LICENSE) for the full MIT License text.
