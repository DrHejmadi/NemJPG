# NemJPG - Ideer og Implementeringsplan

*Baseret på research fra ChatGPT, Gemini, Claude og websogninger (marts 2026)*

---

## 1. Konkurrentanalyse

### Eksisterende vaerktoejer og deres styrker

| Vaerktoej | Styrker | Svagheder |
|---|---|---|
| **IrfanView** | Hurtig, let, kommandolinje, EXIF-haandtering, lossless JPG rotation, plugins | Kun Windows, aeldre UI, batch-dialog er forvirrende |
| **XnConvert** | 500+ formater, 80+ handlinger, presets, drag-drop, cross-platform | Kraever installation, kompleks for simple opgaver |
| **ImageMagick** | Alment kraftfuldt, open source, kommandolinje | Svaer at bruge, silent data corruption rapporteret, ingen GUI |
| **FastStone Photo Resizer** | God batch resize+convert, preview, rename | Kun Windows, kraever installation |
| **File Converter** | Hoejreklik-kontekstmenu, simpel | Kraever installation, begraenset formatering |
| **reaConverter** | Kontekstmenu, presets, poleret UI | Kommerciel (betalt) |

### Hvad NemJPG mangler vs. konkurrenterne

1. **Resize/skalering** - alle konkurrenter tilbyder dette
2. **Output-mappe** - mulighed for at gemme JPG i en undermappe
3. **Kvalitetsvalg** - brugeren kan ikke aendre 95%
4. **Presets/konfiguration** - XnConvert har gemte presets
5. **Drag-and-drop** - XnConvert og File Converter har dette
6. **Hoejreklik-kontekstmenu** - File Converter og reaConverter
7. **Metadata/EXIF** - IrfanView bevarer/redigerer EXIF
8. **Undermapper (rekursion)** - de fleste konkurrenter har dette
9. **Omdoebning** - navngivningsmonstre (prefix, suffix, nummerering)
10. **Progress/fremskridt** - visuel progress bar

---

## 2. Typiske brugerklager (fra forums og Reddit)

1. **Programmet fryser** ved store batch-konverteringer (85%+ gennemfoert)
2. **Stille data-korruption** - filer der ser OK ud men er beskadigede
3. **Transparens-problemer** - sort baggrund i stedet for hvid (NemJPG loeser dette!)
4. **Ingen smart/inkrementel konvertering** - vil kun konvertere nye filer (NemJPG loeser dette!)
5. **Filudvidelse-mismatch** - .jpeg vs .jpg skaber problemer
6. **For store output-filer** - darlig default komprimering
7. **Kommandolinje er forvirrende** - ImageMagick er overvaldende
8. **Destruktiv redigering** - originaler overskrevet (NemJPG loeser dette!)
9. **Kraever installation** - brugere vil bare have noget der virker

### NemJPG's eksisterende fordele
- Loeser allerede problem 3, 4, 8 og 9
- "Zero footprint" - ingen installation
- Bruger native Windows-komponenter

---

## 3. Feature-ideer rangeret efter impact vs. kompleksitet

### Tier 1: Hoej impact, lav kompleksitet (goer foerst)

| # | Feature | Beskrivelse | Kompleksitet |
|---|---|---|---|
| 1.1 | **Kvalitetsvalg** | Spoerg brugeren: Hoej (95%), Medium (80%), Lav (60%), Web (70% + resize) | Let |
| 1.2 | **Output-undermappe** | Gem JPG i en "JPG_output" mappe i stedet for samme mappe | Let |
| 1.3 | **Rekursiv undermapper** | Valgfrit: inkluder billeder i undermapper | Let |
| 1.4 | **Vis filstoerrelse-besparelse** | Vis original vs. ny stoerrelse og total besparelse | Let |
| 1.5 | **Slet originaler (valgfrit)** | Spoerg om originaler skal slettes efter konvertering | Let |
| 1.6 | **Simpel menu ved start** | Vis en menu med valgmuligheder foer konvertering starter | Let-Medium |

### Tier 2: Hoej impact, medium kompleksitet

| # | Feature | Beskrivelse | Kompleksitet |
|---|---|---|---|
| 2.1 | **Resize/skalering** | Max bredde/hoejde, procent-skalering, web-optimeret preset | Medium |
| 2.2 | **Drag-and-drop mappe** | Traek en mappe hen paa .bat-filen for at konvertere den | Medium |
| 2.3 | **Konfigurationsfil** | nemjpg.ini med gemte indstillinger (kvalitet, resize, output) | Medium |
| 2.4 | **Navngivningsmonstre** | Prefix/suffix, f.eks. "foto_001.jpg", "{original}_web.jpg" | Medium |
| 2.5 | **EXIF-bevarelse** | Kopier EXIF-data fra original til JPG | Medium |
| 2.6 | **Flere output-formater** | Ikke kun JPG - ogsaa PNG, WebP, BMP konvertering | Medium |

### Tier 3: Medium impact, hoej kompleksitet

| # | Feature | Beskrivelse | Kompleksitet |
|---|---|---|---|
| 3.1 | **Hoejreklik-kontekstmenu** | "Konverter til JPG" i Windows Stifinder | Hoej |
| 3.2 | **SendTo-integration** | Tilfoej til Windows "Send til"-menu | Medium-Hoej |
| 3.3 | **Watch-mappe** | Overvaag en mappe og konverter nye filer automatisk | Hoej |
| 3.4 | **Parallel konvertering** | Brug PowerShell 7+ ForEach-Object -Parallel | Hoej |
| 3.5 | **Progressive JPEG** | Web-optimeret JPEG med progressive loading | Hoej |
| 3.6 | **GUI-version** | Simpel WPF/WinForms GUI med preview | Meget hoej |

### Tier 4: Niche/kreative ideer

| # | Feature | Beskrivelse | Kompleksitet |
|---|---|---|---|
| 4.1 | **"NemJPG Lite" familie** | NemPNG.bat, NemWebP.bat - en serie af enkle konvertere | Let |
| 4.2 | **Filstoerrelse-maal** | "Konverter saa JPG er under 2MB" (til email/upload) | Medium |
| 4.3 | **Vandmaerke** | Tilfoej tekst-vandmaerke til alle billeder | Hoej |
| 4.4 | **Rapport/log-fil** | Gem en log med hvad der blev konverteret | Let |
| 4.5 | **Auto-orientering** | Roter baseret paa EXIF-orientering | Medium |
| 4.6 | **Baggrundsfarbevalg** | Hvid, sort, eller brugerdefineret farve for transparens | Let |

---

## 4. Unikke differentierende faktorer

### NemJPG's "superpower": Ekstrem enkelhed

Konkurrenterne kraever alle installation. NemJPG's USP er:

1. **En enkelt fil** - ingen installation, ingen runtime, ingen admin-rettigheder
2. **Dobbeltklik og faerdig** - ingen UI at laere, ingen indstillinger at finde
3. **Portabel** - kan vaere paa USB-noeglen, sendes per email, ligge paa et delt drev
4. **Transparent** - brugeren kan aabne filen i Notepad og se praecis hvad den goer
5. **Zero footprint** - efterlader intet paa systemet

### Strategi: Bevar enkelheden, tilfoej "power user" muligheder

- **Standard-tilstand**: Dobbeltklik = konverter alt til JPG (som nu)
- **Avanceret tilstand**: Koer med argumenter eller konfigurationsfil for power users
- **Familie-tilgang**: Lav flere simple .bat-filer (NemPNG, NemWebP, NemResize)

---

## 5. Skal NemJPG forblive en .bat-fil?

### Mulighed A: Behold .bat (anbefalet for v1-v2)

| Fordele | Ulemper |
|---|---|
| Ingen installation | Begreanset UI |
| Portabel | SmartScreen-advarsler |
| Transparent kode | PowerShell execution policy |
| Extremt lille filstoerrelse | Windows-only |

### Mulighed B: Kompiler til .exe (overvejes til v3+)

| Fordele | Ulemper |
|---|---|
| Ingen SmartScreen-advarsler (med signering) | Kraever build-process |
| Kan have ikon | Stoerre fil |
| Mere "professionelt" udseende | Mindre transparent |
| Kan lave GUI | Kraever .NET runtime |

### Mulighed C: PowerShell-modul + installer

| Fordele | Ulemper |
|---|---|
| Kontekstmenu-integration | Kraever installation |
| Professionelt | Mister "zero install" USP |
| Kan opdateres via PSGallery | Mere komplekst |

**Anbefaling**: Behold .bat for v1-v2. Overveej .exe til v3 hvis der er nok brugere.

---

## 6. Implementeringsplan

### Fase 1: v1.1 - "Quick Wins" (1-2 dage)

- [ ] Fix og test at v1.0 virker paa Windows (TEST.bat)
- [ ] Tilfoej simpel startmenu: "Tryk 1 for standard, 2 for indstillinger"
- [ ] Kvalitetsvalg: Hoej/Medium/Lav
- [ ] Output til undermappe (valgfrit)
- [ ] Vis filstoerrelse-besparelse efter konvertering
- [ ] Tilfoej log-fil (nemjpg_log.txt)
- [ ] Baggrundsfarbevalg for transparens (hvid/sort)

### Fase 2: v1.5 - "Power Features" (3-5 dage)

- [ ] Resize-funktionalitet (max bredde/hoejde)
- [ ] Drag-and-drop support (traek mappe paa .bat)
- [ ] Rekursiv undermapper (valgfrit)
- [ ] Konfigurationsfil (nemjpg.ini)
- [ ] Omdoebning med monstre ({original}_web.jpg)
- [ ] Filstoerrelse-maal ("under X MB")

### Fase 3: v2.0 - "NemJPG Familie" (1 uge)

- [ ] NemPNG.bat - konverter alt til PNG
- [ ] NemWebP.bat - konverter alt til WebP
- [ ] NemResize.bat - resize uden formatskift
- [ ] EXIF-bevarelse/strip
- [ ] Auto-orientering baseret paa EXIF
- [ ] Faelles hjemmeside for alle NemTools

### Fase 4: v3.0 - "Pro" (2-4 uger, kun hvis demand)

- [ ] Kompiler til .exe med ikon
- [ ] Hoejreklik-kontekstmenu integration
- [ ] SendTo-menu installation
- [ ] Simpel GUI
- [ ] Watch-mappe funktionalitet
- [ ] Windows Store distribution

---

## 7. Prioriteret "goer nu"-liste

1. **Foerst**: Faa v1.0 til at virke (test paa Windows)
2. **Dernaest**: Tilfoej startmenu med kvalitetsvalg
3. **Saa**: Output-undermappe + filstoerrelse-rapport
4. **Dernast**: NemPNG.bat og NemWebP.bat varianter
5. **Til sidst**: Resize og konfigurationsfil

---

## Kilder

- [XnConvert features](https://www.xnview.com/en/xnconvert/)
- [IrfanView vs XnConvert sammenligning](https://alternativeto.net/software/irfanview/)
- [Batch converter brugerklager (forums)](https://forums.overclockers.co.uk/threads/batch-image-converter-tool-keep-two-folders-in-sync-one-resized.18616368/)
- [Hoejreklik image converter (GBTI)](https://gbti.network/devops/how-to-use-imagemagick-to-convert-images-via-right-click-in-windows/)
- [HEIC til JPG PowerShell (brd.la)](https://brd.la/2025/heic-to-jpg/)
- [File Converter kontekstmenu](https://www.addictivetips.com/windows-tips/convert-files-to-other-formats-from-the-context-menu-on-windows-10/)
- [PowerShell kontekstmenu (GitHub)](https://gist.github.com/KyleMit/978086ae267ff5be17811e99c9607986)
- Gemini AI analyse (marts 2026)
- Claude AI analyse (marts 2026)
