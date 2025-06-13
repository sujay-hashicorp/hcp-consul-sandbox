## HCP Consul Client Configuration

This directory is expected to contain the configuration files necessary for running Consul clients that connect to an HCP Consul Dedicated cluster.

### What to include

From the HCP UI, download the "Client Configuration" for your Consul cluster.

Steps:

1. Navigate to your HCP Consul cluster.
2. Go to the **"Client Configuration"** tab.
3. Click **"Download Client Configuration"**.
4. Unzip the downloaded file.
5. Copy the contents of the unzipped folder into this `client_config/` directory.

You should see files like:

```
client_config/
├── ca.pem
├── consul.hcl
```

These are required by your EC2 Consul clients to authenticate and securely connect to the HCP Consul server.