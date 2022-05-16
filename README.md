# Work in Progress!!

Dies ist eine Überarbeitung der Skripte. Benutzung auf eigene Gefahr! Tests stehen noch aus.

# JDownloader-Autoenc-rename

Linux Skripte zum automatischen encode zu HEVC und Spezieller Audio Codecs (eac3 & dts) zu AC3 und umbenennen via FileBot.

# Voraussetzungen

Ihr benötigt dafür einige Tools. Dazu gehören:

 - [JDownloader](https://jdownloader.org/jdownloader2) + Archive Extractor + Event Scripter
 - FFmpeg (Falls mit Nvidia genutzt wird, [nutzt diese Anleitung für NVENC encoding](https://docs.nvidia.com/video-technologies/video-codec-sdk/ffmpeg-with-nvidia-gpu/))
 - [Filebot](https://www.filebot.net/#download) (Ich selbst nutze Version 4.8.5)

 - Einen Logfile Ordner (/home/$USER/.local/logs als Default in den Skripten)
 - Einen Skript Ordner /home/$USER/.local/scripts als Default in den Skripten)
 - Einen Ordner für den Download (In den JDownloader Einstellungen)
 - Einen Ordner für das Entpacken (/mnt/downloads/entpackt/ als Default in den Skripten)
 - Einen Ordner für das encoden (/mnt/Medien/encode/ als default in den Skripten)
 - Bash in der Version 4 oder höher ( bash --version also Kommando im terminal eingeben)
 - Ordner für das einsortieren (Filme, Serien, Animes /mnt/Medien/* als Default im Skript)

# Benachrichtigungen:

Mir fehlte noch eine Möglichkeit, darauf aufmerksam zu werden, falls etwas nicht funktioniert.
Daher wurden erstmal Discord Nachrichten hinzugefügt. Falls die Encodierung oder das Umbenennen Fehlschlägt, 
sendet das jeweilige Skript eine Nachricht an einen Discord Channel. Die Webhook URL kann bei startencode.sh hinterlegt werden.

# Was machen die Skripte?

Ich bin bei weitem kein Profi, und es gibt bestimmt eine MENGE!! Dinge, die man verbessern könnte.

Außerdem: Diese Skripte sind nur zum **Teil universell**. Es kann durchaus zu Problemen kommen.
Per Default ist Nvidia's NVENC zum encoden angegeben, da ich nur Nvidia Grafikkarten habe.

Die Skripte hatte ich erstellt, um so viel wie möglich zu automatisieren.
Bei mir liegen diese alle in ~/.local/scripts/.

JDownloader startet nach dem Entpacken das **startencode.sh** Skript. Diese überprüft, ob bereits ein Skript läuft und wartet dann erstmal.

Danach startet das **startencode.sh** Skript, das **jdautoenc.sh** Skript, das je nach Länge des Videos, benutzter Video Codec und benutzter Audio Codec entscheidet, wie das Video encoded werden soll. Dann löscht es die Quelldatei (falls FFmpeg erfolgreich war)

Sobald alle Dateien, die **jdautoenc.sh** im entpackten ordner gefunden hat encoded sind, startet dieser das **rename.sh** Skript.

Das **rename.sh** Skript überprüft wieder erstmal, ob noch eines der anderen beiden Skripte gestartet wurde, und wartet auf die Beendigung.

Dann fängt das Skript an, die Dateien im encoded Ordner umzubenennen.


Und da ich so eine faule Sau bin, gibts noch ein **addrename** und **removerename** Skript. Durch diese beiden ist es relativ einfach neue rename Optionen hinzuzufügen oder alte zu löschen.

Im JDownloader (falls ihr my.jdownloader.org nutzt) fügt einfach den Codeblock in das Scripts Feld und ändert den Pfad (/home/hhofmann/.local/scripts/) eurem Pfad entsprechend an:

 
```
[{"eventTrigger":"ON_ARCHIVE_EXTRACTED", "enabled":true, "name":"AutoENC", "script":"var script = '/home/hhofmann/.local/scripts/startencode.sh'\n\nvar path = archive.getFolder()\nvar name = archive.getName()\nvar label = archive.getDownloadLinks() && archive.getDownloadLinks()[0].getPackage().getComment() ? archive.getDownloadLinks()[0].getPackage().getComment() : 'N/A'\n\nvar command = [script, path, name, label, 'ARCHIVE_EXTRACTED']\n\nlog(command)\nlog(callSync(command))\n", "eventTriggerSettings":{"isSynchronous":false}, "id":1639245703676}]
```
# Was noch zu tun ist:

Für das **startencode** Skript:
- Filebot format in eine variable in das startencode.sh Skript.
- Hardware-Beschleunigungs Variable für FFmpeg mit verschiedenen Konfigurationen (Nvenc, AMD_amf, Intel QuickSync oder rein Softtware) in das startencode script
  - Wenn das geschehen, kann man dies auch automatisieren, und das skript schaut selbstständig nach, was benutzt werden kann.  z.B. per ffmpeg -codecs grep if condition (Müsste noch ausgeklügelt werden, da ich quicksync angezeigt bekomme trotz AMD CPU)

für das **jdautoenc** Skript:
- Übersichtlichere FFmpeg stats im log
  - Wrapper wie ffpb funktionieren leider nicht.
- Skript anpassen, um vielleicht auch Videos, die nicht in Archiven gepackt sind zu Encoden
- Encoding als auswahl. Ein paar enthusiasten mögen kein Encoding, ich mach das zwecks Festplatten Platz. 

für das **rename** Skript
- Verbesserter Film abgleich. (auch per TVDB?)
  - Abgleich vielleicht in eine txt packen? dadurch muss das addrename nicht ständig angepasst werden bei Skript Änderungen
  - Im Grunde muss die Rename nur die txt auslesen und nach den passenden keywords/TVDB_ID abgleichen

Allgemein:

- Terminal/Zenity Konfigurationsskript für Leute, die sich nicht auskennen.
  - Konfigurationsskript muss nun mal endlich fertig werden.
- **addrename**: wenn rename konfiguriert für Filme abgleich, muss addrename auch angepasst werden. 
- Allgemeine verbesserung und Fehlerbehebungen. Da ich erst noch lerne, muss noch einiges angepasst werden, damit es auf jedem Linux basierten Gerät funktioniert und nicht nur bei mir.
