# JDownloader-Autoenc-rename
Linux Skripte zum automatischen encode zu HEVC/AC3 und umbenennen via FileBot.

Ich bin bei weitem kein Profi, und es gibt bestimmt eine MENGE!! die man verbessern könnte.

Außerdem: Diese Skripte sind nur zum Teil Universell. Es kann durchaus zu Problemen kommen und ich werde bestimmt die Ordner/Skript Pfade als comment in das startencode.sh Skript hinzufügen, dass diese dann an die anderen weitergibt, wenn ich die Zeit und lust habe.

Die Skripte hatte ich erstellt, um soviel wie möglich zu automatisieren.
Bei mir liegen diese alle in ~/.local/scripts/.

JDownloader startet nach dem Entpacken das startencode.sh Skript. Diese überprüft ob bereits ein Skript läuft und wartet dann erstmal.

Danach startet das startencode.sh Skript das jdautoenc.sh Skript das jenach Länge des Videos, benutzter Video Codec, benutzter Audio Codec entscheidet, wie das video encoded werden soll. Dann löscht es die quelldatei (falls dieses im encoded Ordner)

Sobald alle Dateien die jdautoenc.sh im entpackten ordner gefunden hat encoded sind, startet dieser das rename.sh Skript.

Das rename.sh Skript überprüft wieder erstmal, ob noch eines der anderen beiden Skripte gestartet wurde, und wartet auf die Beendigung.

Dann fängt das Skript an, die dateien im encoded Ordner umzubenennen.


Und da ich so eine faule Sau bin, gibts noch ein addrename und removerename Skript. Durch diese beiden ist es relativ einfach neue rename optionen hinzuzufügen oder alte zu löschen.

Im JDownloader (falls ihr my.jdownloader.org nutzt, fügt einfach den Codeblock in das Scripts Feld und ändert den Pfad (/home/hhofmann/.local/scripts/) eurem Pfad entsprechend an :

 
```
[{"eventTrigger":"ON_ARCHIVE_EXTRACTED", "enabled":true, "name":"AutoENC", "script":"var script = '/home/hhofmann/.local/scripts/startencode.sh'\n\nvar path = archive.getFolder()\nvar name = archive.getName()\nvar label = archive.getDownloadLinks() && archive.getDownloadLinks()[0].getPackage().getComment() ? archive.getDownloadLinks()[0].getPackage().getComment() : 'N/A'\n\nvar command = [script, path, name, label, 'ARCHIVE_EXTRACTED']\n\nlog(command)\nlog(callSync(command))\n", "eventTriggerSettings":{"isSynchronous":false}, "id":1639245703676}]
```

