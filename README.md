# vortexos

Distro Linux personale basata su [Zena](https://github.com/Zena-Linux/Zena), costruita con [bootc](https://containers.github.io/bootc/) su Fedora immutabile.

## Differenze rispetto a Zena upstream

| Componente | Zena upstream | vortexos |
|---|---|---|
| Compositor Wayland | niri + xwayland-satellite | **Hyprland** |
| Display manager | greetd + dms-greeter (niri) | greetd + agreety (Hyprland) |
| Idle / lock | — | **hypridle + hyprlock** |
| Sfondo | — | **hyprpaper** |
| Barra di sistema | (quickshell/DMS) | **waybar** (minimal, tema Catppuccin Mocha) |
| Launcher | — | **wofi** |
| Notifiche | — | **dunst** |
| Terminale default | alacritty | **kitty** (alacritty rimane installato) |
| Config sistema | system-files/wm/ | + **system-files/custom/** (protette da sync) |

Tutto il resto di Zena rimane invariato: kernel CachyOS-LTO, systemd-homed, integrazione Nix, DMS (Dank Material Shell), Flatpak, tailscale, ecc.

---

## Primo avvio: `bootc switch`

Da un sistema Fedora già configurato con bootc (o qualsiasi sistema bootc-compatible):

```bash
sudo bootc switch ghcr.io/Dexmodzz/vortexos:latest
```

Al prossimo riavvio il sistema caricherà vortexos. Il vecchio deployment resta disponibile per il rollback.

---

## Ricevere aggiornamenti con `bootc upgrade`

Dopo il primo `bootc switch`, il sistema sa già da quale registro aggiornarsi. Per scaricare e preparare la nuova versione:

```bash
sudo bootc upgrade
```

Il comando scarica la nuova immagine in background e la prepara come nuovo deployment. L'aggiornamento diventa attivo al prossimo riavvio:

```bash
sudo reboot
```

Il deployment precedente viene mantenuto automaticamente: se qualcosa va storto puoi sempre tornare indietro.

---

## Personalizzare le configurazioni

Le configurazioni specifiche di vortexos vivono in `system-files/custom/`:

```
system-files/custom/
├── etc/
│   ├── hypr/
│   │   ├── hyprland.conf   ← compositor, keybind, monitor, autostart
│   │   ├── hyprpaper.conf  ← sfondo
│   │   └── hypridle.conf   ← spegnimento schermo e lock automatico
│   ├── greetd/
│   │   └── config.toml     ← display manager (greeter)
│   └── waybar/
│       ├── config          ← layout e moduli della barra
│       └── style.css       ← tema CSS della barra
```

### Come modificare e aggiornare

1. Modifica i file in `system-files/custom/` nel repo
2. Fai commit e push su `main`:
   ```bash
   git add system-files/custom/
   git commit -m "hypr: aggiusta keybind e aggiungi monitor"
   git push origin main
   ```
3. Il workflow `build.yml` si attiva automaticamente e builda una nuova immagine OCI su `ghcr.io`
4. Sul sistema, aggiorna con:
   ```bash
   sudo bootc upgrade && sudo reboot
   ```

> **Override personale:** le config in `/etc/hypr/` sono config di sistema. Un utente può sovrascriverle mettendo i file in `~/.config/hypr/` — Hyprland le legge con precedenza sulla config di sistema.

---

## Sync upstream automatico

Ogni giorno alle 06:00 UTC il workflow `sync-upstream.yml` controlla se Zena upstream ha nuovi commit.

**Se ci sono aggiornamenti:**
- Aggiorna automaticamente `build-scripts/`, `patches/` e il `Containerfile` (solo le parti non personalizzate)
- **Non tocca mai** i file in `system-files/custom/` né quelli elencati in `PROTECTED_FILES.txt`
- Apre una Pull Request con titolo `chore: sync upstream Zena YYYY-MM-DD`
- La descrizione della PR include: lista file aggiornati, link al commit upstream, avvisi se upstream ha toccato zone vicine alle nostre personalizzazioni

**Come gestire la PR di sync:**

1. Leggi la descrizione della PR e controlla il diff
2. Controlla in particolare se `Containerfile` o `build-scripts/de/wm/packages.sh` sono stati modificati — potrebbero toccare i pacchetti che abbiamo aggiunto
3. Se tutto è ok, fai merge della PR su `main`
4. Il workflow `build.yml` si attiva e aggiorna l'immagine su ghcr.io

**Se non ci sono novità:** il workflow termina silenziosamente senza aprire PR.

---

## Rollback a una versione precedente

bootc mantiene automaticamente i deployment precedenti. Per tornare all'ultima versione funzionante:

```bash
# Visualizza i deployment disponibili
sudo bootc status

# Torna al deployment precedente
sudo bootc rollback

# Riavvia per applicare il rollback
sudo reboot
```

Per tornare a una versione specifica (tag data o SHA del commit):

```bash
sudo bootc switch ghcr.io/Dexmodzz/vortexos:2026-01-15
# oppure
sudo bootc switch ghcr.io/Dexmodzz/vortexos:abc1234
```

I tag disponibili sono visibili su: `https://github.com/Dexmodzz/vortexos/pkgs/container/vortexos`

---

## Struttura del repo

```
vortexos/
├── Containerfile                  ← build OCI (bootc)
├── build-scripts/
│   ├── build.sh                   ← orchestratore moduli (NON modificare)
│   └── modules/
│       ├── base/                  ← kernel CachyOS, dnf repos, pacchetti base, servizi
│       ├── de/wm/                 ← pacchetti e servizi Hyprland/DMS
│       └── integrations/          ← homed, Nix, NVIDIA, virtualizzazione
├── system-files/
│   ├── common/                    ← file di sistema condivisi (sync upstream)
│   ├── wm/                        ← file specifici WM da Zena (sync upstream)
│   └── custom/                    ← PERSONALIZZAZIONI VORTEXOS (escluse dal sync)
├── patches/                       ← patch applicate al sistema (sync upstream)
├── PROTECTED_FILES.txt            ← lista file esclusi dal sync automatico
├── .upstream-sha                  ← SHA upstream tracciato per il sync
└── .github/workflows/
    ├── build.yml                  ← build e push su ghcr.io con cosign
    └── sync-upstream.yml          ← sync automatico da Zena upstream
```

---

## Crediti

- [Zena Linux](https://github.com/Zena-Linux/Zena) — progetto upstream
- [bootc](https://containers.github.io/bootc/) — sistema di aggiornamento OCI
- [Hyprland](https://hyprland.org/) — compositor Wayland
- [DMS (Dank Material Shell)](https://github.com/danklinux) — shell visuale
- [Waybar](https://github.com/Alexays/Waybar) — barra di sistema
- [CachyOS](https://cachyos.org/) — kernel ottimizzato
