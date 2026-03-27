#!/usr/bin/env bash

python3 vol.py -f /mnt/d/CyberDefenders/Reveal/original/192-Reveal.dmp windows.info | tee ../output/windows_info.txt
python3 vol.py -f /mnt/d/CyberDefenders/Reveal/original/192-Reveal.dmp windows.pslist | tee ../output/pslist.txt
python3 vol.py -f /mnt/d/CyberDefenders/Reveal/original/192-Reveal.dmp windows.pstree | tee ../output/pstree.txt
python3 vol.py -f /mnt/d/CyberDefenders/Reveal/original/192-Reveal.dmp windows.malfind | tee ../output/malfind.txt
python3 vol.py -f /mnt/d/CyberDefenders/Reveal/original/192-Reveal.dmp windows.cmdline | tee ../output/cmdline.txt
python3 vol.py -f /mnt/d/CyberDefenders/Reveal/original/192-Reveal.dmp windows.userassist | tee ../output/userassist.txt
python3 vol.py -f /mnt/d/CyberDefenders/Reveal/original/192-Reveal.dmp windows.sessions | tee ../output/sessions.txt