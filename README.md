# JDownloader-Autoenc-rename
Linux Skripte zum automatischen encode zu HEVC/AC3 und umbenennen via FileBot

Die Skripte hatte ich erstellt, um soviel wie möglich zu automatisieren.
Bei mir liegen diese alle in ~/.local/scripts/.

JDownloader startet nach dem Entpacken das startencode.sh Skript. Diese überprüft ob bereits ein Skript läuft und wartet dann erstmal.

Danach startet das startencode.sh Skript das jdautoenc.sh Skript das jenach Länge des Videos, benutzter Video Codec, benutzter Audio Codec entscheidet, wie das video encoded werden soll. Dann löscht es die quelldatei (falls dieses im encoded Ordner)

Sobald alle Dateien die jdautoenc.sh im entpackten ordner gefunden hat encoded sind, startet dieser das rename.sh Skript.

Das rename.sh Skript überprüft wieder erstmal, ob noch eines der anderen beiden Skripte gestartet wurde, und wartet auf die Beendigung.

Dann fängt das Skript an, die dateien im encoded Ordner umzubenennen.
