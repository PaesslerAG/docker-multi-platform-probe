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

You must put it into the `/config/config.yml` volume of the docker container.

Another volume `/opt/paessler/share/scripts` is available for the scripts of the [Script v2][prtgmanual:scriptv2] sensor.

[prtgmanual:scriptv2]: https://www.paessler.com/br/manuals/prtg/script_v2_sensor

```sh
docker run -it \
  --network bridge \
  -v ./scripts:/opt/paessler/share/scripts:ro \
  -v ./config:/config \
  --cap-add NET_ADMIN \
  --cap-add NET_RAW
  paessler/multi-platform-probe:latest
```

You can also use `docker-compose`. There is an example file here: [docker-compose.yml](docker-compose.yml)

## Feedback and issues

We are thankful for any feedback or ideas on how to improve. If you want to submit feedback or report an issue, please open an issue in our [Issue Tracker].

 [Issue Tracker]: https://github.com/PaesslerAG/docker-multi-platform-probe/issues

## Licensing

See [LICENSE](./LICENSE) for the full MIT License text.
