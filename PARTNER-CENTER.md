# NemJPG — Microsoft Partner Center Indsendelse

Komplet guide og al butikstekst klar til copy-paste.

---

## Trin 1 — Opret konto og reserver appnavn

1. Gå til **[partner.microsoft.com](https://partner.microsoft.com)** → Tilmeld dig
2. Vælg **Individuel udviklerkonto** (ikke virksomhed)
3. Betal **$19 engangsgebyr** (kreditkort)
4. Når kontoen er aktiv: **Apps og spil → Ny produkt → App**
5. Reserver appnavnet: **`NemJPG`**

> Gem din **Publisher-identitet** (vises som `CN=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`)  
> under: Kontoindstillinger → Organisationsprofil

---

## Trin 2 — Opdater AppxManifest.xml

Åbn `NemJPG/Windows/Package/AppxManifest.xml` og erstat linje 14:

```xml
Publisher="CN=PUBLISHER-IDENTITY-FROM-PARTNER-CENTER"
```

med din rigtige Publisher-identitet fra Partner Center, fx:

```xml
Publisher="CN=12345678-ABCD-1234-ABCD-1234567890AB"
```

---

## Trin 3 — Opret signeringscertifikat

Kør dette **på en Windows-maskine** i PowerShell (som administrator):

```powershell
# Erstat CN= med din Publisher-identitet fra Partner Center
$publisherId = "CN=12345678-ABCD-1234-ABCD-1234567890AB"
$password = "VælgEtSterktPassword123!"

$cert = New-SelfSignedCertificate `
    -Subject $publisherId `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -Type CodeSigningCert `
    -HashAlgorithm SHA256 `
    -NotAfter (Get-Date).AddYears(3)

$pwd = ConvertTo-SecureString $password -AsPlainText -Force
Export-PfxCertificate -Cert $cert -FilePath "NemJPG-cert.pfx" -Password $pwd

# Konverter til base64 (til GitHub Secret)
$bytes = [IO.File]::ReadAllBytes("NemJPG-cert.pfx")
[Convert]::ToBase64String($bytes) | Set-Clipboard
Write-Host "Base64-certifikat kopieret til udklipsholderen"
```

Tilføj derefter to **GitHub Secrets** i dit repo (Settings → Secrets → Actions):

| Secret-navn | Værdi |
|-------------|-------|
| `CERT_PFX_BASE64` | Base64-indholdet fra udklipsholderen |
| `CERT_PASSWORD` | Passwordet du valgte ovenfor |

---

## Trin 4 — Byg MSIX via GitHub Actions

```bash
git add .
git commit -m "Opdater Publisher-identitet til Partner Center"
git tag v2.0.0
git push origin main --tags
```

GitHub Actions bygger automatisk `NemJPG-v2.0.0.msix`.  
Download den under **Actions → build → Artifacts**.

---

## Trin 5 — Udfyld butiksindsendelse i Partner Center

Gå til din reserverede app → **Indsend til Store → Ny indsendelse**

### 5a. Priser og tilgængelighed
- **Pris:** Gratis
- **Markeder:** Alle markeder (eller vælg manuelt)
- **Udgivelsesdato:** Udgiv så snart den er certificeret

### 5b. App-egenskaber

| Felt | Værdi |
|------|-------|
| Kategori | Foto og video |
| Underkategori | Fotoredigering |
| Understøtter ikke spilkontrollere | ✓ |
| Systemkrav — Hukommelse (min) | 512 MB |
| Systemkrav — Lager (min) | 100 MB |

### 5c. Aldersklassificering

Besvar IARC-spørgeskemaet. Svar **Nej** på alle spørgsmål om vold, sex, gambling osv.  
Forventet klassificering: **E (Everyone) / 3+**

### 5d. Pakker

Upload `NemJPG-v2.0.0.msix`

---

## Trin 6 — Butiksoversigt (copy-paste)

Partner Center → Butiksoversigter → Tilføj/rediger sprog

---

### DANSK (da-DK)

**Appnavn**
```
NemJPG
```

**Kort beskrivelse** (maks 270 tegn)
```
Konverter billeder til JPG med ét klik. Højreklik på en PNG, WebP, HEIC eller RAW-fil og vælg "Konverter til JPG". Gemmer i bedste kvalitet i samme mappe. Alt foregår lokalt – ingen upload, ingen konto.
```

**Beskrivelse** (maks 10.000 tegn)
```
NemJPG gør billedkonvertering så simpelt som muligt. Installér appen og konverter herefter billeder direkte fra Stifinder – ingen åben app nødvendig.

━━ SÅDAN FUNGERER DET ━━

1. Højreklik på en billedfil i Stifinder
2. Vælg "Konverter til JPG"
3. Færdig – foto.jpg gemmes i samme mappe som kildefilen

━━ FUNKTIONER ━━

• Ét klik fra Stifinder via højrekliksmenu
• Gemmer i samme mappe med samme filnavn + .jpg
• Bedste JPEG-kvalitet (100%)
• Understøtter 15+ formater: PNG, BMP, GIF, TIFF, WebP, HEIC, HEIF, AVIF, DNG, CR2, NEF, ARW, ORF og flere
• Hvid baggrund erstatter gennemsigtige pixels (PNG/WebP)
• Træk-og-slip grænseflade til batchkonvertering
• Kører 100% lokalt – ingen netværksforbindelser
• Ingen konto, ingen abonnement, ingen reklamer

━━ UNDERSTØTTEDE FORMATER ━━

Standard: PNG, BMP, GIF, TIFF/TIF, WebP, ICO
Moderne: HEIC, HEIF, AVIF
RAW-kamera: DNG, CR2 (Canon), NEF (Nikon), ARW (Sony), ORF (Olympus), RW2 (Panasonic)

Note: HEIC/HEIF kræver HEIF Image Extensions fra Microsoft Store (gratis, ofte forudinstalleret på Windows 11).

━━ PRIVATLIV ━━

NemJPG indsamler, gemmer eller sender ingen data. Alle billeder behandles udelukkende lokalt på din maskine.
```

**Søgeord** (maks 7, kommasepareret)
```
billedkonvertering, konverter til jpg, png til jpg, heic til jpg, raw til jpg, webp til jpg, billedomformer
```

**Privatlivspolitik-URL**
```
https://hejmadi.com/NemJPG/privacy.html
```

---

### ENGLISH (en-US)

**App name**
```
NemJPG
```

**Short description** (max 270 chars)
```
Convert images to JPG with one click. Right-click any PNG, WebP, HEIC or RAW file and choose "Convert to JPG". Saves at best quality in the same folder. Fully local — no uploads, no account.
```

**Description**
```
NemJPG makes image conversion as simple as possible. Install the app, then convert images directly from File Explorer — no need to open anything.

━━ HOW IT WORKS ━━

1. Right-click any image file in File Explorer
2. Choose "Convert to JPG"
3. Done — photo.jpg is saved next to the original

━━ FEATURES ━━

• One-click conversion from File Explorer context menu
• Output saved in the same folder with the same filename + .jpg
• Best JPEG quality (100%)
• 15+ formats supported: PNG, BMP, GIF, TIFF, WebP, HEIC, HEIF, AVIF, DNG, CR2, NEF, ARW, ORF and more
• White background fills transparent pixels (PNG/WebP)
• Drag-and-drop interface for batch conversion
• Runs 100% locally — no network connections ever made
• No account, no subscription, no ads

━━ SUPPORTED FORMATS ━━

Standard: PNG, BMP, GIF, TIFF/TIF, WebP, ICO
Modern: HEIC, HEIF, AVIF
RAW camera: DNG, CR2 (Canon), NEF (Nikon), ARW (Sony), ORF (Olympus), RW2 (Panasonic)

Note: HEIC/HEIF requires the free HEIF Image Extensions from the Microsoft Store (often pre-installed on Windows 11).

━━ PRIVACY ━━

NemJPG collects, stores, and transmits zero data. All image processing happens entirely on your device.
```

**Search terms**
```
image converter, convert to jpg, png to jpg, heic to jpg, raw to jpg, webp to jpg, photo converter
```

**Privacy policy URL**
```
https://hejmadi.com/NemJPG/privacy.html
```

---

## Trin 7 — Screenshots

Partner Center kræver **mindst 1 screenshot** pr. sprog. Anbefalet: 3–5 stykker.

**Krav:**
- Mindst 1366×768 px (eller 768×1366 for portræt)
- PNG eller JPEG
- Maks 50 MB pr. billede

**Tag disse 3 screenshots på Windows 11:**

| # | Hvad der vises | Fremgangsmåde |
|---|---------------|---------------|
| 1 | Appens hovedvindue med drag-drop zone | Åbn NemJPG normalt |
| 2 | Konverteringsresultater (grøn liste med filnavne) | Konverter 3–4 PNG-filer |
| 3 | Højrekliksmenu i Stifinder med "Konverter til JPG" | Højreklik på en .png-fil |

**Tip:** Brug Windows Snipping Tool (Win+Shift+S) og gem som PNG.

---

## Trin 8 — Indsend

- Klik **Gem** på alle sektioner (de skal have grønt flueben)
- Klik **Send til Store**
- Microsoft certificerer typisk inden for **1–3 hverdage**
- Du modtager e-mail når appen er live

---

## Tjekliste

- [ ] Partner Center-konto oprettet ($19 betalt)
- [ ] Appnavn "NemJPG" reserveret
- [ ] Publisher-identitet kopieret fra Partner Center
- [ ] `AppxManifest.xml` opdateret med Publisher-identitet
- [ ] Signeringscertifikat oprettet og eksporteret som .pfx
- [ ] `CERT_PFX_BASE64` og `CERT_PASSWORD` tilføjet som GitHub Secrets
- [ ] `git tag v2.0.0 && git push --tags` kørt
- [ ] MSIX downloadet fra GitHub Actions
- [ ] Butiksoversigt udfyldt (DA + EN)
- [ ] 3 screenshots uploadet
- [ ] Privatlivspolitik-URL indsat
- [ ] Indsendt til certificering
