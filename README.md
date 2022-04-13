# Helm charts

This is the new home of Helm Charts for Pharma Ledger.

## Requirements

- [helm 3](https://helm.sh/docs/intro/install/)

## Installing the Helm Repository

Add the repo as follow

```bash
helm repo add pharmaledger-imi https://pharmaledger-imi.github.io/helm-charts
```

Then you can run `helm search repo pharmaledger-imi` to see the chart(s). On installation use the `--version` flag to specify a chart version.

## Development

1. We use [GitHub Flow](https://docs.github.com/en/get-started/quickstart/github-flow).
    1. Create a branch derived from branch `master`.
    2. Make your changes and test them.
    3. Create a Pull Request.
    4. Verify that all checks pass. If not, fix the issues on your branch and push them again.
    5. Wait for your Pull Request to be reviewed.
    6. After successful Review, your Pull Request will be merged.
2. Several checks run on a Pull Request. They all need to pass, otherwise your changes will not be accepted.
3. In case you are doing changes on a helm chart
    1. bump the version in `Chart.yaml`,
    2. Run `pre-commit run -a` to update the documentation.
4. After your Pull Request has been accepted and has been merged to `master` branch, an automated process will create a new Release of the modified helm charts.
