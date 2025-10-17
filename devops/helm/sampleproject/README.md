# sampleproject

A Helm chart for deploying the sampleproject application on Kubernetes.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+

## Installing the Chart

To install the chart, you can use the base `values.yaml` file and override it with an environment-specific values file.

For example, to deploy the `dev` environment:

```bash
helm install my-release-dev . --namespace expenses -f ./values.yaml -f ../env/dev/values.yaml
```

Similarly, for `qa` and `prod` environments:

```bash
# QA
helm install my-release-qa . --namespace expenses -f ./values.yaml -f ../env/qa/values.yaml

# Production
helm install my-release-prod . --namespace expenses -f ./values.yaml -f ../env/prod/values.yaml
```

The `helm install` command has a `-f` or `--values` flag that can be specified multiple times. The rightmost file will have the highest precedence.

## Uninstalling the Chart

To uninstall/delete a release:

```bash
helm uninstall <release-name> --namespace expenses
```

For example:
```bash
helm uninstall my-release-dev --namespace expenses
```

## Configuration

The `values.yaml` file contains the default configuration for the chart.
The `env` directory contains environment-specific overrides for `dev`, `qa`, and `prod`.

You can further override these values by providing your own `values.yaml` file or by using the `--set` flag during installation.

For example, to change the frontend service type to `NodePort` for a `dev` deployment:

```bash
helm install my-release-dev . --namespace expenses -f ./values.yaml -f ../env/dev/values.yaml --set frontend.service.type=NodePort
```

Refer to the `values.yaml` file for the full list of configurable parameters.