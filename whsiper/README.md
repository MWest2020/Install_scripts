# Whisper Installer voor Windows

Een automatische installer voor OpenAI Whisper met GPU ondersteuning op Windows systemen.

## 🎯 Wat doet deze installer?

Deze PowerShell script installeert automatisch:
- **Python 3.10.11** in een geïsoleerde omgeving
- **PyTorch** met CUDA ondersteuning (voor NVIDIA GPU's) of CPU-only versie
- **OpenAI Whisper** voor spraak-naar-tekst transcriptie
- **Virtual environment** voor schone installatie

## 🚀 Installatie

### Vereisten
- Windows 10/11
- (Optioneel) NVIDIA GPU met recent drivers voor GPU-versnelling

### Installeren

1. **Download** `install_whisper.ps1`
2. **Open PowerShell als Administrator** (aanbevolen) of als gewone gebruiker
3. **Voer uit:**
   ```powershell
   .\install_whisper.ps1
   ```

### Installatie Locaties
- **Met admin rechten:** `C:\whisper-python310`
- **Zonder admin rechten:** `C:\Users\[gebruiker]\whisper-python310`

## 📝 Gebruik

### Virtual Environment Activeren

**Eerst altijd de virtual environment activeren:**
```powershell
& 'C:\Users\mwest\whisper-python310\venv\Scripts\Activate.ps1'
```

*Vervang `mwest` met je eigen gebruikersnaam, of gebruik `C:\whisper-python310\venv\Scripts\Activate.ps1` als je admin rechten had.*

### Basis Transcriptie

**Eenvoudigste gebruik:**
```bash
whisper audiobestand.mp3
```

**Met Nederlandse taal specificatie:**
```bash
whisper interview.mp3 --language Dutch
```

**Met specifiek model:**
```bash
whisper interview.mp3 --language Dutch --model medium
```

### Uitgebreide Voorbeelden

**Voor interviews/vergaderingen:**
```bash
whisper vergadering.mp3 --language Dutch --model medium --output_dir transcripties
```

**Voor ondertitels (SRT):**
```bash
whisper video.mp4 --language Dutch --model medium --output_format srt
```

**Alleen tekstbestand:**
```bash
whisper opname.wav --language Dutch --model medium --output_format txt
```

**Met woordtijdstempels:**
```bash
whisper interview.mp3 --language Dutch --model medium --word_timestamps True
```

**Vertaling naar Engels:**
```bash
whisper nederlands.mp3 --language Dutch --task translate --model medium
```

## 🎛️ Beschikbare Opties

### Modellen (van snel naar accuraat)
- `tiny` - Snelst, minder accuraat
- `base` - Balans tussen snelheid en kwaliteit
- `small` - Goede kwaliteit, redelijk snel
- `medium` - **Aanbevolen** voor de meeste gebruik
- `large` - Beste kwaliteit, langzamer
- `turbo` - **Nieuwste**, zeer snel en accuraat (default)

### Output Formaten
- `txt` - Platte tekst
- `srt` - Ondertitels met tijdstempels
- `vtt` - WebVTT ondertitels
- `json` - Gestructureerde data met metadata
- `tsv` - Tab-separated values
- `all` - Alle formaten (default)

### Talen
Whisper ondersteunt 100+ talen, waaronder:
- `Dutch` of `nl` - Nederlands
- `English` of `en` - Engels
- `German` of `de` - Duits
- `French` of `fr` - Frans
- `Spanish` of `es` - Spaans

## 🛠️ Handige Tips

### Batch Verwerking
```bash
# Activeer environment eenmalig
& 'C:\Users\mwest\whisper-python310\venv\Scripts\Activate.ps1'

# Verwerk meerdere bestanden
whisper interview1.mp3 interview2.mp3 meeting.wav --language Dutch --model medium --output_dir transcripties
```

### Kwaliteit Optimalisatie
```bash
# Voor beste kwaliteit (langzamer)
whisper opname.mp3 --language Dutch --model large --temperature 0 --beam_size 5

# Voor snelheid (iets minder accuraat)
whisper opname.mp3 --language Dutch --model turbo --fp16 True
```

### Lange Bestanden
```bash
# Voor lange opnames met goede geheugen management
whisper lange_vergadering.mp3 --language Dutch --model medium --verbose False
```

## 🔧 Troubleshooting

### "Command not found" Error
**Probleem:** `whisper: command not found`  
**Oplossing:** Virtual environment activeren:
```powershell
& 'C:\Users\mwest\whisper-python310\venv\Scripts\Activate.ps1'
```

### Langzame Verwerking
**Als je NVIDIA GPU hebt maar verwerking is langzaam:**
1. Controleer of CUDA wordt gebruikt:
   ```python
   python -c "import torch; print('CUDA available:', torch.cuda.is_available())"
   ```
2. Indien `False`, herinstalleer met admin rechten

### Geheugen Problemen
**Voor grote bestanden:**
- Gebruik `--model medium` in plaats van `large`
- Voeg `--fp16 True` toe
- Sluit andere toepassingen

### Kwaliteit Problemen
**Als transcriptie onnauwkeurig is:**
- Specificeer de juiste taal: `--language Dutch`
- Gebruik een groter model: `--model large`
- Voor ruis: voorbewerk audio met Audacity
- Voeg context toe: `--initial_prompt "Interview over technologie"`

## 📊 Prestatie Verwachtingen

### Met NVIDIA GPU (CUDA):
- **Turbo model:** ~10x sneller dan real-time
- **Medium model:** ~8x sneller dan real-time  
- **Large model:** ~4x sneller dan real-time

### CPU-only:
- **Turbo model:** ~2x sneller dan real-time
- **Medium model:** ~1x real-time
- **Large model:** ~0.5x real-time

## 🔄 Updates

**Whisper updaten:**
```bash
& 'C:\Users\mwest\whisper-python310\venv\Scripts\Activate.ps1'
pip install --upgrade git+https://github.com/openai/whisper.git
```

**PyTorch updaten:**
```bash
& 'C:\Users\mwest\whisper-python310\venv\Scripts\Activate.ps1'
pip install --upgrade torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
```

## 🗂️ Bestandsstructuur

Na installatie:
```
C:\Users\[gebruiker]\whisper-python310\
├── python.exe                 # Python executable
├── venv\                      # Virtual environment
│   ├── Scripts\
│   │   ├── Activate.ps1      # Environment activatie
│   │   ├── python.exe        # Venv Python
│   │   └── whisper.exe       # Whisper command
│   └── Lib\                  # Python packages
└── ...
```

## 🎬 Voorbeeldworkflow

```bash
# 1. Environment activeren
& 'C:\Users\mwest\whisper-python310\venv\Scripts\Activate.ps1'

# 2. Transcribeer interview
whisper interview.mp3 --language Dutch --model medium --output_dir transcripties

# 3. Resultaten bekijken
# transcripties/interview.txt    - Platte tekst
# transcripties/interview.srt    - Ondertitels
# transcripties/interview.json   - Gedetailleerde data

# 4. Voor ondertitels op video
whisper presentatie.mp4 --language Dutch --model medium --output_format srt

# 5. Environment deactiveren (optioneel)
deactivate
```

## 📞 Support

Voor problemen of vragen:
1. Controleer eerst deze README
2. Test met een klein audiobestand
3. Verify installatie: `whisper --help`
4. Check GPU: `python -c "import torch; print(torch.cuda.is_available())"`

---

**🎉 Success! Je bent nu klaar om audio te transcriberen met Whisper!**
