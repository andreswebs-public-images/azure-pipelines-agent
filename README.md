# azure-pipelines-agent

Azure Pipelines agent on Fedora.

## Local Build

```sh
docker build -t ado-agent .
```

## Run

```sh
export AGENT_URL="https://dev.azure.com/example-org"
export AGENT_POOL="example-pool"
export AGENT_NAME="example-agent"

AGENT_TOKEN=$(cat ~/example-ado-pat-token.txt)
export AGENT_TOKEN
```

### Local Docker

```sh
docker run -it --rm --name ado-agent \
  -e AGENT_URL \
  -e AGENT_POOL \
  -e AGENT_NAME \
  -e AGENT_TOKEN \
  ado-agent
```

## k8s

Manifest: [k8s.yml](k8s.yml)

```sh
kubectl create secret generic ado-agent \
    --from-literal=AGENT_URL="${AGENT_URL}" \
    --from-literal=AGENT_POOL="${AGENT_POOL}" \
    --from-literal=AGENT_TOKEN="${AGENT_TOKEN}" \
```

```sh
kubectl apply -f k8s.yml
```

## Authors

**Andre Silva** - [@andreswebs](https://github.com/andreswebs)

## License

This project is licensed under the [Unlicense](UNLICENSE.md).

## References

<https://github.com/microsoft/azure-pipelines-agent>

<https://github.com/actions/runner-images>

<https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops>

<https://www.domstamand.com/creating-an-azure-devops-hosted-agent-image-for-vmware/>
