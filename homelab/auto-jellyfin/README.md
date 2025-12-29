# Auto Jellyfin setup

I followed this [guide](https://github.com/bryce-hoehn/automated-jellyfin-guide?tab=readme-ov-file) for most of the setup, you can find the `compose.yml` file in this folder.

1. Create `~/docker/` folder
2. Place `compose.yml` file in the folder
3. Install docker and docker compose: `sudo apt-get install docker docker-compose`
4. Create a `/jellyfin/tv` and `/jellyfin/movies` directory. I did it at the root to make path mgmt easier in the compose file like so:

```
sudo mkdir -p /jellyfin/tv
sudo mkdir -p /jellyfin/movies
sudo mkdir /downloaded_content
```

5. Set everything up by running `docker compose up -d` while in `~/docker`

I had to make the following changes:

- remove `network_mode: service:gluetun` from prowlarr
- added tor container, required to access 1337x to bypass cloudflare
- added tor network in the compose file for the `tor` and `prowlarr` containers

## Prowlarr setup

1. Access [http://localhost:9696/settings/indexers](http://localhost:9696/settings/indexers) or whichever IP from `ip a` (linux) or `ipconfig getifaddr en0`
2. Create new Indexer Proxy
   - Socks5
   - Host: `tor`
   - Port: `9050`
3. On the host machine, copy `prowlarr/1337x-tor.yml` to `~/docker/prowlarr/Definitions/Custom/` (you may have to create the `Custom` folder)
4. Restart the container: `docker compose restart prowlarr`
5. Add indexer:
   - Select the custom indexer `1337x (Tor)`
   - Select Base URL: `http://l337xdark...onion/`. Check [https://1337x.to/about](https://1337x.to/about) for the new onion URL if needed.
   - Select test, hopefully without any errors. You may have to wait a few minutes for the `tor` container to complete setup, you can cehck the logs using `sudo docker logs tor`

And thats it!
