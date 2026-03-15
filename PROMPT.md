# NemJPG - Fortsættelsesprompt

Kopier nedenstående til en ny Claude Code-session:

---

## Projekt: NemJPG

**Placering:** `/Users/michaelhejmadi/Documents/Hejmadi.com/NemJPG/`

### Hvad er NemJPG?
Et standalone Windows-program (enkelt `.bat`-fil) der konverterer alle billedfiler i sin mappe til JPG. Ingen installation kræves - bruger Windows' indbyggede PowerShell + WPF (PresentationCore/WIC).

### Filer i mappen:
- `Konverter til JPG.bat` — selve programmet (batch + indlejret PowerShell)
- `TEST.bat` — automatisk testscript (opretter testbilleder, kører konverteren, tjekker resultat)
- `beskrivelse.html` — hjemmeside med download, vejledning, FAQ
- `index.html` — alternativ hjemmeside-version
- `icon.svg` — ikon til hjemmeside og program

### Teknisk arkitektur:
- `.bat`-filen indeholder PowerShell-kode efter markøren `# PSSTART`
- Trin 1: Batch kører PowerShell der udtrækker koden til en temp `.ps1`-fil via `-split '# PSSTART\r?\n', 2`
- Trin 2: Batch kører den udtrukne `.ps1` med `-File` og `-ScriptDir` parameter
- Bruger WPF's `BitmapDecoder` (WIC) til at læse billeder og `JpegBitmapEncoder` til at gemme
- Tegner på hvid baggrund for at håndtere gennemsigtighed (RGBA → RGB)
- Understøtter: PNG, BMP, GIF, TIFF, WebP, ICO, HEIC, HEIF, AVIF, WDP, DNG, CR2, NEF, ARW

### Status / kendte opgaver:
- **Ikke testet endnu** — programmet er udviklet på macOS og kan kun testes på Windows
- Brugeren skal køre `TEST.bat` på en Windows-PC og rapportere resultatet
- Hvis det fejler, skal PowerShell-koden debugges (typiske fejlkilder: encoding, PS 5.1-kompatibilitet, WPF-assembly loading)
- `convert_to_jpg.py` i projektets rod er en ældre Python-version der ikke bruges længere

### Hvad der skal gøres:
1. Få bekræftet at programmet virker på Windows (brugeren tester med TEST.bat)
2. Rette eventuelle fejl baseret på testresultater
3. Opdatere `beskrivelse.html` hvis der sker ændringer i programmet
4. Eventuelt integrere NemJPG-siden i hovedsiden for hejmadi.com
