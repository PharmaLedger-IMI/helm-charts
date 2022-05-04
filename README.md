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

### Howto

1. We use [GitHub Flow](https://docs.github.com/en/get-started/quickstart/github-flow).
    1. Create a branch derived from branch `master`.
    2. Make your changes and test them.
    3. Create a Pull Request.
    4. Verify that all checks pass. If not, fix the issues on your branch and push them again.
    5. Wait for your Pull Request to be reviewed.
    6. After successful Review, your Pull Request will be merged.
2. Several checks run on a Pull Request. They all need to pass, otherwise your changes will not be accepted.
3. In case you are doing changes on a helm chart
    1. Bump the version in `Chart.yaml`,
    2. Run `pre-commit run -a` to update the documentation. Please use [Helm-Docs 1.8.1](https://github.com/norwoodj/helm-docs/releases/tag/v1.8.1).
4. After your Pull Request has been accepted and has been merged to `master` branch, an automated process will create a new Release of the modified helm charts.

### Some checks are failing? What can I do?

- Detect-Secrets checks are failing? Check if all "detected secrets" are *false positives*.

    You can mark *false positives*, see [here](https://github.com/Yelp/detect-secrets#inline-allowlisting)

    E.g.

    ```yaml
    # 1. Secret and comment in same line (note: not always working):

    SomeSecretString # pragma: allowlist secret

    # 2. Comment one line above Secret:

    # pragma: allowlist nextline secret
    SomeSecretString

    # 3. For helm template comments:

    {{- /*
        # pragma: allowlist nextline secret
    */}}SomeSecretString

    # 4. For helm values.yaml (which will be used to generate docs via helm-docs)
    # Note: a) Add   <!-- # pragma: allowlist secret -->   one line before the value as it becomes part of the generate doc file.
    #       b) Add   # pragma: allowlist secret            at the end of the line which contains the value.

    # -- Description for 'sha'.
    # Additional line of description.
    # <!-- # pragma: allowlist secret -->
    sha: "f9814e1d2f1be7f7f09addd1d877090fe457d5b66ca2dcf9a311cf1e67168590" # pragma: allowlist secret


    ```

- Checkov checks are failing? See [here](https://www.checkov.io/2.Basics/Suppressing%20and%20Skipping%20Policies.html) and scroll down to Kubernetes Examples

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
    name: mypod
    annotations:
        checkov.io/skip1: CKV_K8S_20=I don't care about Privilege Escalation :-O
        checkov.io/skip2: CKV_K8S_14
        checkov.io/skip3: CKV_K8S_11=I have not set CPU limits as I want BestEffort QoS
    spec:
    containers:
    ...
    
    ```
