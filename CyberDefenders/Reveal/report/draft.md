# Forensics Assignment - Reveal

## Memory Forensics
Memory forensics is the process of analyzing volatile memory (RAM) to recover runtime artifacts such as processes, command lines, loaded DLLs, user sessions, and suspicious executable memory regions.

## Volatility 3
Volatility 3 is a memory forensics framework used to extract artifacts from memory images through plugins.

Plugins used:
- windows.info
- windows.pslist
- windows.pstree
- windows.malfind
- windows.cmdline
- windows.userassist
- windows.sessions

## Analysis Summary
The suspicious process was identified as powershell.exe.
Its parent PID was 4120.
Command-line analysis revealed that the malware accessed a remote WebDAV share and executed a second-stage DLL payload named 3435.dll from the shared directory davwwwroot.
The execution method used rundll32, which maps to MITRE ATT&CK sub-technique T1218.011.
Session analysis showed that the malicious process ran under the username Elon.
Based on IOC correlation with threat intelligence, the malware family was identified as StrelaStealer.

## Final Answers
1. powershell.exe
2. 4120
3. 3435.dll
4. davwwwroot
5. T1218.011
6. Elon
7. StrelaStealer