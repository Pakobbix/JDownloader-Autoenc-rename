# JDownloader-Autoenc-rename

Linux Skripte zum automatischen encode zu HEVC und Spezieller Audio Codecs (eac3 & dts) zu AC3 und umbenennen via FileBot.

# Voraussetzungen

Ihr benötigt dafür einige Tools. Dazu gehören:

 - [JDownloader](https://jdownloader.org/jdownloader2) + Archive Extractor + Event Scripter
 - FFmpeg (Falls mit Nvidia genutzt wird, [nutzt diese Anleitung für NVENC encoding](https://docs.nvidia.com/video-technologies/video-codec-sdk/ffmpeg-with-nvidia-gpu/))
 - [Filebot](https://www.filebot.net/#download) (Ich selbst nutze Version 4.8.5)
 - Bash in der Version 4 oder höher ( bash --version also Kommando im terminal eingeben)
 - whiptail (Nur für das Config Skript) Ist bei fast allen Linux Distributionen, sowie auf Synology Geräten vorinstalliert.
 - Einen Skript Ordner /home/$USER/.local/scripts als Default in den Skripten)
 - Einen Ordner für den Downloads (In den JDownloader Einstellungen)
 - Einen Ordner für das Entpacken (/mnt/downloads/entpackt/ als Default in den Skripten)
 - Einen Ordner für das encoden (/mnt/Medien/encode/ als default in den Skripten)

Optional:
 - Einen Logfile (Ordner) 
 - Ordner für das einsortieren (Filme, Serien, Animes /mnt/Medien/* als Default im Skript)

# Benachrichtigungen:

Mir fehlte noch eine Möglichkeit, darauf aufmerksam zu werden, falls etwas nicht funktioniert.
Daher wurden erstmal Discord Nachrichten hinzugefügt. Falls die Encodierung oder das Umbenennen Fehlschlägt, 
sendet das jeweilige Skript eine Nachricht an einen Discord Channel. Die Webhook URL kann in der JDAutoConfig hinterlegt werden.

# Kleine Info

Ich bin bei weitem kein Profi, und es gibt bestimmt eine MENGE!! Dinge, die man verbessern könnte.

Außerdem: Diese Skripte sind nur zum **Teil universell**. Es kann durchaus zu Problemen kommen.
Per Default ist Nvidia's NVENC zum encoden angegeben, da ich nur Nvidia Grafikkarten habe.

Die Skripte hatte ich erstellt, um so viel wie möglich zu automatisieren. Und entweder war alles veraltet, oder nur zum teil automatisch.

# Was machen die Skripte?

JDownloader startet nach dem Entpacken das **jdautoenc.sh** Skript. Diese überprüft, ob bereits ein Skript läuft und wartet dann erstmal.

Danach überprüft das Skript die länge der Videos im entpackten Ordner, den verwendeten Video Codec und benutzter Audio Codec uund entscheidet, wie das Video encoded werden soll. Dann löscht es die Quelldatei (falls FFmpeg erfolgreich war)

Sobald alle Dateien, die **jdautoenc.sh** im entpackten ordner gefunden hat encoded sind, startet dieser das **rename.sh** Skript.

Das **rename.sh** Skript überprüft wieder erstmal, ob noch das jdautoenc.sh gestartet wurde, und wartet auf die Beendigung.

Dann fängt das Skript an, die Dateien im encoded Ordner umzubenennen.


Und da ich so eine faule Sau bin, gibts noch ein **addrename** und **removerename** Skript. Durch diese beiden ist es relativ einfach neue rename Optionen hinzuzufügen oder alte zu löschen.

Im JDownloader (falls ihr my.jdownloader.org nutzt) fügt einfach den Codeblock in das Scripts Feld und ändert den Pfad (/home/hhofmann/.local/scripts/) eurem Pfad entsprechend an:

 
```
[{"eventTrigger":"ON_ARCHIVE_EXTRACTED", "enabled":true, "name":"AutoENC", "script":"var script = '/home/hhofmann/.local/scripts/jdautoenc.sh'\n\nvar path = archive.getFolder()\nvar name = archive.getName()\nvar label = archive.getDownloadLinks() && archive.getDownloadLinks()[0].getPackage().getComment() ? archive.getDownloadLinks()[0].getPackage().getComment() : 'N/A'\n\nvar command = [script, path, name, label, 'ARCHIVE_EXTRACTED']\n\nlog(command)\nlog(callSync(command))\n", "eventTriggerSettings":{"isSynchronous":false}, "id":1639245703676}]
```

# JD im Docker:

Falls ihr JD2 im Docker laufen habt, ist dies auch kein weiteres Problem. Ihr müsst dann ledeglich den Pfad zu den Skripten in die Volume Paramter hinzufügen.
hinzuzufügen zum docker pull command:

```
-v /pfad/der/Skripte:/Docker/interner/pfad
```

oder falls ihr docker-compose verwendet:

```
volumes:
  - /Pfad/zu/den/Skripten:/Container/interner/Pfad/zu/den/skripten
```
und dann JD2 im Docker angeben, dass dort die Skripte liegen. Ihr müsst dann natürlich die Pfade für die Ordner & weiteren Skripte in der startencode.sh oder per config.sh an die internen Container Pfade anpassen.

Falls FFmpeg nicht im Docker verfügbar ist, oder nur per Software encodiert werden soll/kann, oder gar nicht encodiert werden soll, könnt/solltest ihr in der JDAutoConfig beim Encodieren=yes auf no ändern.

# Was noch zu tun ist:

für das **jdautoenc** Skript:
- Übersichtlichere FFmpeg stats im log
  - Wrapper wie ffpb funktionieren leider nicht.
- Skript anpassen, um vielleicht auch Videos, die nicht in Archiven gepackt sind zu Encoden

für das **rename** Skript
- Verbesserter Film abgleich. (auch per TVDB?)

Allgemein:
- Terminal/Zenity Konfigurationsskript für Leute, die sich nicht auskennen.
  - Konfigurationsskript muss nun mal endlich fertig werden.
- **addrename**: wenn rename konfiguriert für Filme abgleich, muss addrename auch angepasst werden. 
- Allgemeine verbesserung und Fehlerbehebungen. Da ich erst noch lerne, muss noch einiges angepasst werden, damit es auf jedem Linux basierten Gerät oder per WSL funktioniert und nicht nur bei mir.
