# Auto Jellyfin setup

I followed this [guide](https://github.com/bryce-hoehn/automated-jellyfin-guide?tab=readme-ov-file) for most of the setup, you can find the `compose.yml` file in this folder.

1. Create `~/docker/` folder
2. Place `compose.yml` file in the folder
3. Install docker and docker compose: `sudo apt-get install docker docker-compose`
4. Create a `/jellyfin/tv` and `/jellyfin/movies` directory. I did it at the root to make path mgmt easier in the compose file.

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

## 1. Prowlarr setup

I setup prowlarr with nyaa.si and 1337x.to for anime and movies/shows. This may not be applicable if you use different trackers. Nyaa.si was simple to setup within prowlarr, however 1337x was a bit more difficult.

1. Access [http://localhost:9696/settings/indexers](http://localhost:9696/settings/indexers) or whichever IP from `ip a` (linux) or `ipconfig getifaddr en0`
2. Under `Settings -> Indexers`, create new Indexer Proxy
   - Socks5
   - Host: `tor`
   - Port: `9050`
3. Copy `homelab/auto-jellyfin/prowlarr/1337x-tor.yml` to the machine hosting everthing at `~/docker/prowlarr/Definitions/Custom/` (you may have to create the `Custom` folder)
4. Restart the container: `docker compose restart prowlarr`
5. Add the `1337 tor` indexer:
   - Select the custom indexer `1337x (Tor)`
   - Select Base URL: `http://l337xdark...onion/`. Check [https://1337x.to/about](https://1337x.to/about) for the new onion URL if needed.
   - Select test, hopefully without any errors. You may have to wait a few minutes for the `tor` container to complete setup, you can cehck the logs using `sudo docker logs tor`

## 2. Follow Bryce's guide, which i've edited and pasted below

### Jellyfin

1. Navigate to http://localhost:8096
2. Follow the setup wizard
3. Add libraries for TV and Movies. The library folders should be located at /media/movies and /media/tv respectively.

See [documentation](https://jellyfin.org/docs/general/quick-start.html) for more information

### qBittorrent

#### Set Download Directory

1. Navigate to qBittorrent Web UI at http://localhost:8080
2. Click on Tools > Options
3. Under the "Downloads" tab change "Default Save Path" to /downloads/completed
4. Check the box next to "Keep incomplete torrents in:" Make sure it's set to /downloads/incomplete

#### Bind qBittorrent to VPN

This will ensure that qBittorrent only downloads over your VPN connection.

1. Navigate to qBittorrent Web UI at http://localhost:8080
2. Click on Tool > Options
3. Go to the Advanced tab
4. Change Network interface from Any to the interface corresponding to your VPN (probably something like tun0)

#### Change default login (Optional)

By default the login to the web UI is just "admin".

1. qBittorrent generates a random password on install. This password can be found by running `docker logs qbittorrent`.
2. Navigate to Tools > Options > WebUI > Authentication
3. Enter a new password.

### Prowlarr

See [Prowlarr Quick Start Guide](https://wiki.servarr.com/prowlarr/quick-start-guide)

### Sonarr / Radarr

#### Connect to qBittorrent

1. Navigate to Settings > Downloads Clients > Add
2. Select "qBittorrent"
3. Enter "qBittorrent" in the "Name" field
4. Set host and port to the qBittorrent Web UI. If you followed this guide correctly the default values should be correct
5. Enter the Username and Password for the webui
6. Click "Save"

#### Set root directory

1. Navigate to Settings > Media Management
2. Scroll to the bottom of the page and click on "Add Root Folder"
3. Sonarr: Select /tv
4. Radarr: Select /movies

#### Create quality profile

You will want to create a quality profile to specify what resolution you want your TV Shows and Movies to be.

1. Navigate to Settings > Profiles
2. Select the Any profile
3. Check all qualities you would like to allow and uncheck all qualities you would like to disable. For example if you want your movie quality to cap out at 1080p to save disk space uncheck everything above Bluray-1080p. Sonarr/Radarr will prioritize the highest allowed resolution but will download lower allowed ones if it can't find it.
4. (Optional) Allow upgrades by checking the "Upgrades Allowed" Checkbox. You can then change the "Upgrade Until" drop down to your prefered maximum resolution. This is useful for if you want your library to be entirely 1080p but the only torrent available for a specific show or movie is 720p. This way it will still download the 720p torrent but if a 1080p torrent ever comes along it will automatically download it and replace the 720p version.

#### File renaming (Optional)

I like having this setting enabled to keep my media folders nice and organized.

1. Navigate to Settings > Media Management
2. Check the checkbox under "Rename Episodes/Movies"
3. (Optional) Configure episode format by preference

### Jellyseerr

#### Connect Sonarr and Radarr

**Sonarr:**

1. Upon startup, configuration will prompt you for Sonarr details.
2. Enter hostname and port. If you followed this guide correctly it should just be sonarr:8989
3. Enter API key. You can find this in Sonarr under Settings > General
4. Leave base URL blank unless you configured one in Sonarr
5. Under Sonarr Interface click on "Load Qualities", "Load Folders", and "Load Languages"
6. Select "Any" under Quality Profiles
7. Select /tv under Default Root Folders
8. Select your prefered languages under Language Profiles

**Radarr:**

1. Upon startup, configuration will prompt you for Sonarr details.
2. Enter hostname and port. If you followed this guide correctly it should just be radarr:7878
3. Enter API key. You can find this in Radarr under Settings > General
4. Leave base URL blank unless you configured one in Radarr
5. Under Radarr Interface click on "Load Profiles" and "Load Root Folders"
6. Select "Any" under Quality Profiles
7. Select /movies under Default Root Folders
8. Select Physical / Web under Default Minimum Availability. Optionally you could select and earlier setting in case a movie gets leaked before being released to DVD but you will more often than not probably just get cam recordings.

## 3. Usage

This is just a general guide to how I would use this, not a rule set. I found this helpful to wrap my head around things.

1. Open Jellyseer on a computer on the network (something like http://192.168.18.29:5055), and browse for shows and movies. This is where you request the content, which will get sent through the system.
2. You can monitor the shows and movies that have been added through Sonarr (shows) and Radarr (movies) through their web interfaces. YOu can monitor the torrents being downloaded through the qbittorrent web ui.
3. Open Jellyfin on the viewing device (TV app, or client computer) and you should see the requested media appear. It may take a minute to completely sync.
4. And thats it!
