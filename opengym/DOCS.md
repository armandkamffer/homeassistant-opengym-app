# openGym

Web UI on port **8080**. Passkeys need HTTPS (except on `localhost`), so put the app behind
Nabu Casa remote UI is *not* enough — use Tailscale Serve, Cloudflare Tunnel, Caddy or Nginx
Proxy Manager, then set:

- `rp_id`: bare hostname, e.g. `gym.example.com`
- `origin`: full URL, e.g. `https://gym.example.com`

Set both **before** creating profiles; changing `rp_id` later invalidates passkeys.
Data lives in the app's `/data` and is included in Home Assistant backups.
