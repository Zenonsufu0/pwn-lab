cd ~/pwn-lab/CyberDefenders/Reveal

cat > .gitignore <<'EOF'
.venv/
volatility3/
*.dmp
*.raw
*.zip
symbols/
cache/
__pycache__/
EOF

cat > README.md <<'EOF'
# CyberDefenders - Reveal

## Overview
Memory forensics challenge solved with Volatility 3.

## Tools
- Volatility 3
- WSL Ubuntu

## Structure
- notes/ : analysis notes
- output/ : saved volatility outputs
- scripts/ : commands used
- report/ : draft report

## Key Findings
- Malicious process: powershell.exe
- Parent PID: 4120
- Second-stage payload: 3435.dll
- Shared directory: davwwwroot
- MITRE ATT&CK sub-technique: T1218.011
- Username: Elon
- Malware family: StrelaStealer
EOF

cat .gitignore
echo "-----"
cat README.md