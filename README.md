# azure-pipelines-agent

Azure Pipelines agent on Fedora.

## Local Build

```sh
docker build -t ado-agent .
```

## Local Run

```sh
export AGENT_URL="https://dev.azure.com/example-org"
export AGENT_POOL="example-pool"
export AGENT_NAME="example-agent"

AGENT_TOKEN=$(cat ~/example-ado-pat-token.txt)
export AGENT_TOKEN
```

```sh
docker run -it --rm --name ado-agent \
  -e AGENT_URL \
  -e AGENT_POOL \
  -e AGENT_NAME \
  -e AGENT_TOKEN \
  ado-agent
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
