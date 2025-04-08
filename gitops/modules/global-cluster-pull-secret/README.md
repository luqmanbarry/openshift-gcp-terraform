# Global Pull Secret

The module update the cluster global pull secret to add credentials for private registries.

The pull secret must be of this json object format:

```yaml
{
  "auths": {
    "my-registry.example.com": {
      "username": "value",
      "password": "value"
    }
  }
}
```

Once you have the pull secret, create a KeyVault secret with value the json object.

Update the `values.<cluster-name>.yaml` file to set the KeyVault secret name.