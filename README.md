# JDownloader-Autoenc-rename

Linux scripts to automatically encode to HEVC and special audio codecs (eac3 & dts) to AC3 and rename via FileBot.

# Experimental! Only tested with german and english !!

# Requirements

I try to use as few external programs as possible, so that everyone can use them regardless of hardware. But there are still some tools you'll need: 

 - [JDownloader](https://jdownloader.org/jdownloader2) + Archive Extractor + Event Scripter
   - JDownloader obious. Archive Extractor + Event Scripter so the script can be startet if archive is successfully unpacked.
 - FFmpeg (If used with Nvidia, [use this guide for NVENC encoding](https://docs.nvidia.com/video-technologies/video-codec-sdk/ffmpeg-with-nvidia-gpu/))
   - For encoding. Also used for checking codecs and duration (via ffprobe command).
 - [Filebot](https://www.filebot.net/#download) (I use version 4.8.5 myself)
   - For renaming. Best match rate so unrivaled if you ask me.
 - Bash version 4 or higher ( bash --version so enter command in terminal)
   - Some commands need bash v4 like for converting to lower/uppercase. 
 - whiptail (Only for the config script) Is preinstalled on almost all Linux distributions, as well as on Synology devices.
   - i choose whiptail for the config script, because it's more available than dialogue and i like the style.
 - A script folder /home/$USER/.local/scripts as default in the scripts)
 - A folder for downloads (in the JDownloader settings)
 - A folder for unpacking (/mnt/downloads/entpack/ as default in the scripts)
 - A folder for encoding (/mnt/media/encode/ as default in the scripts)

Optional:
 - A logfile (folder) 
 - Folder for sorting (movies, series, anime /mnt/media/* as default in the scripts).

# Notifications:

You can setup Discord Nextcloud Talk and/or Apprise Notifications if:
 - File already exists (encoding error)
 - Duration of encoded video doesn't match sourcefile (encoding error)
 - FileBot couldn't rename files 3 times in a row

 # Known Bugs:

 - FileBot can't rename files sometimes, even if it restarts the whole process 2 times in a row. Need to manually start jdautoenc.sh again, works first time.. always. Dunno (detects the right anime/series/movie but couldn't move them, or access them. Working on it)

# Little info

I am far from being a professional, and there are definitely a LOT!!! Things that could be improved.

Also: these scripts are only **part universal**. There may well be some problems.
By default, Nvidia's NVENC is specified for encoding, since I only have Nvidia graphics cards.

I had created the scripts to automate as much as possible. And either everything was out of date, or only partially automated.

# What do the scripts do?

JDownloader starts the **jdautoenc.sh** script after unpacking. This checks if a script is already running and then waits.

After that the script checks the length of the videos in the unpacked folder, the used video codec and audio codec and decides how to encode the video. Then it deletes the source file (if FFmpeg was successful and the encoded video duration match the sourcefile duration).

Once all files found by **jdautoenc.sh** in the unpacked folder are encoded, it starts the **rename.sh** script.

The **rename.sh** script again first checks if the jdautoenc.sh was still started and waits for the completion.

Then the script starts to rename the files in the encoded folder.


And because I'm such a lazy pig, there is also a **addrename** and **removerename** script. With these two it is relatively easy to add new rename options or delete old ones.

In JDownloader (if you use my.jdownloader.org) just add the codeblock in the scripts field and change the path (/home/hhofmann/.local/scripts/) to your path:

 
```
[{"eventTrigger": "ON_ARCHIVE_EXTRACTED", "enabled":true, "name": "AutoENC", "script": "var script = '/home/hhofmann/.local/scripts/jdautoenc.sh'\n\nvar path = archive.getFolder()\nvar name = archive.getName()\nvar label = archive.getDownloadLinks() && archive.getDownloadLinks()[0]. getPackage().getComment() ? archive.getDownloadLinks()[0].getPackage(). getComment() : 'N/A'\n\nvar command = [script, path, name, label, 'ARCHIVE_EXTRACTED']\n\nlog(command)\nlog(callSync(command))\n", "eventTriggerSettings":{"isSynchronous":false}, "id":1639245703676}]
```

# JD in Docker:

If you have JD2 running in Docker, this shouldn't be a problem, as long as ffmpeg is included. You just need to add the path to the scripts in the volume parameters.
add to the docker pull command:

```
-v /path/of/scripts:/docker/internal/path
```

or if you use docker-compose:

```
volumes:
  - /path/to/the/scripts:/container/internal/path/to/the/scripts
```
and then tell JD2 in Docker that's where the scripts are. You will of course then need to adjust the paths for the folders & other scripts in startcode.sh or via config.sh to match the internal container paths.

You can disable encoding via JDAutoConfig or config.sh script as long as software encoding isn't available or ffmpeg can't be installed.

# What else to do:

For the **jdautoenc** script:
- Clearer FFmpeg stats in the log.
  - Wrappers like ffpb don't work unfortunately.
- Adapt script to maybe encode videos that are not packed in archives as well

for the **rename** script
- Improved movie matching.

General:
- more stable workflow
- fixing bugs
- add more language files
