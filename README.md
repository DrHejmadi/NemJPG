# Fire bud — Dykkerlæge & Lægehuset Ferritslev

Fire komplette designbud på to hjemmesider. Samme indhold som i dag, fire helt forskellige
udtryk. Ren HTML/CSS/JS — ingen frameworks, ingen build, ingen eksterne kald.

**Start her:** åbn `index.html` i roden. Den viser alle fire bud side om side.

---

## Hvad ligger hvor

```
index.html                              Oversigtsside — vælg mellem de fire bud
favicon.svg

dykkerlaege/
  nedstigningen/                        BUD A · filmisk, mørk, scroll-drevet
    index.html  style.css  app.js  favicon.svg
  instrumentet/                         BUD B · redaktionel, klinisk, interaktiv
    index.html  style.css  app.js  favicon.svg

laegehuset-ferritslev/
  huset/                                BUD A · varm, fynsk, live åbningsstatus
    index.html  style.css  app.js  favicon.svg
  klarbesked/                           BUD B · værktøj, søgning først
    index.html  style.css  app.js  favicon.svg

assets/
  fonts/      9 selvhostede variable webfonts (.woff2, latin-subset)
  img/dyk/    dykkerbilleder, WebP i to størrelser
  img/lhf/    lægehusets billeder og portrætter, WebP i to størrelser
  video/      dykkermedicin-intro.mp4
  previews/   skærmbilleder brugt på oversigtssiden
```

---

## De fire bud

### 1 · Dykkermedicin — «Nedstigningen» (bud A)

Hele siden er ét dyk. Sidens scrollposition er en rigtig dykkerprofil: du starter på
overfladen, stiger ned til 40 m ved underviserne, og på vej op holder du sikkerhedsstop
på 5 m — præcis dér hvor tilmeldingen ligger.

* **Levende hav i canvas.** Vandsøjlens farve, lysstråler, marinesne og bobler beregnes
  ud fra din aktuelle «dybde». Lyset forsvinder efterhånden som du kommer ned, og
  kommer igen på vej op.
* **Dykkercomputer.** Fast HUD med dybde, omgivende tryk (1 + d/10 bar) og vejledende
  nul-stop-tid, interpoleret fra en tabel for atmosfærisk luft. Status skifter mellem
  Overfladen / Nedstigning / Arbejdsdybde / Maksimal dybde / Sikkerhedsstop.
* **Dybdestige** i venstre side (bliver til fuldskærmsmenu under 1180 px).
* **Dykkerlygte** følger musen på computer; slået fra på touch og ved reduceret bevægelse.
* Koøje-ramme om introvideoen, glasruder, nitter og genskin.

### 2 · Dykkermedicin — «Instrumentet» (bud B)

Bevidst det stik modsatte: papir og blæk, hårfine linjer, tabeldata, 12-kolonners gitter
og papirkorn. Som en artikel i et fagtidsskrift.

* **Instrumentet** (sektion 02) er sidens hjerte: træk i dybdeskyderen og se
  omgivende tryk, inspiratoriske partialtryk for O₂ og N₂, gasvolumen efter Boyles lov,
  luftforbrugsfaktor, nul-stop-tid og ækvivalent narkosedybde ændre sig i realtid.
  Advarselsflag tænder ved kvælstofnarkose, ved Pₒ₂ ≥ 1,4 bar og ved MOD for atmosfærisk
  luft. Formlerne står i panelet.
  Modellen er illustrativ og erstatter ikke tabel eller dykkercomputer — det står på siden.
* **Duotone-plader.** Billederne ligger i tonet monokrom og springer i fuld farve ved hover.
* **Kinetisk overskrift**, nyhedsticker, læseprogress i toppen, tælleanimation på tal.
* **Lyst og mørkt tema** med knap i toppen; følger systemet indtil du vælger selv.

### 3 · Lægehuset Ferritslev — «Huset» (bud A)

Et hus, ikke en portal. Buede former, papirfarver, Fraunces (samme skrift som hejmadi.com).

* **Live åbningsstatus** ved siden af overskriften: ved præcis hvad klokken er og siger
  fx «Telefonen er åben for tid samme dag indtil kl. 8.30», «Telefonpause og møde — vi tager
  telefonen igen kl. 10.15» eller «Lukket i weekenden — ring til Lægevagten».
* **Dagbånd**: hele dagens rytme på én linje — konsultation, telefontid, pause, vagtmobil —
  med en «nu»-markør der flytter sig.
* **Levende himmel** i canvas bag hero'en. Farvestemningen følger tidspunktet på dagen
  (morgen, dag, eftermiddag, aften).
* **Rød akutbjælke** øverst med 112 og lægevagten, altid.
* Alle læger, sygeplejersker, farmakonom, uddannelseslæge, praksisassistenter og øvrige
  med portræt og fulde profiler. Triage-kort, priser, praktisk info og kort over Fyn.

### 4 · Lægehuset Ferritslev — «Klar besked» (bud B)

Bygget til den, der har travlt og er bekymret. Sort/hvid, én signalfarve, kæmpe type.

* **Tre nødnumre** klæber til toppen af siden — 112, lægevagten, lægehuset.
* **Instant søgning.** Skriv «recept», «kørekort», «gravid», «blodprøve» — svaret findes,
  mens du skriver, og folder sig ud med et blink. Piletaster + Enter, `/` eller `⌘K`
  åbner søgefeltet. Indekset bygges automatisk af sidens eget indhold, så det aldrig
  bliver forældet.
* **Live statusboks** med stort ÅBENT/LUKKET, hvad der gælder lige nu, og hvad der sker
  som det næste — plus dagens forløb med markering af, hvor vi er.
* **«Din vej ind»** — tre ruter i stedet for en menu.
* Alt indhold som foldelister, så siden er kort og skanbar. Mørkt tema.

---

## Om indholdet

Teksterne er de eksisterende, gengivet så tæt som muligt. De er læst igennem for
**sprog, ikke for mening**: stavning, kommaer, orddeling og manglende mellemrum.

Rettede eksempler:

| Original | Rettet til |
|---|---|
| «Vi arbejdet efter princippet» | «Vi arbejder efter princippet» |
| «Helena Thell , Rikke Bak Toft Andreasen ogNicolai Soll» | «Helena Thell, Rikke Bak Toft Andreasen og Nicolai Soll» |
| «Programmet er foreløbigt og rækkefølgen kan ændres» | «Programmet er foreløbigt, og rækkefølgen kan ændres» |
| «ØNH-undersøgelse med fokus på tryk-udligning» | «… på trykudligning» |
| «Anita har ansat som sygeplejerske» | «Anita har været ansat som sygeplejerske» |
| «Giftlinjen er en landsækkende telefonrådgivning» | «… landsdækkende …» |
| «kun håndterer kutte henvendelser» | «… akutte henvendelser» |
| «udenlanske prostituerede» | «udenlandske prostituerede» |
| «kunstig inteligens» | «kunstig intelligens» |
| «universiterne» | «universiteterne» |

**Nyskrevet tekst** — det eneste, der ikke stod på de gamle sider — er den korte
brugstekst, som de nye elementer kræver: introduktionen til instrumentet, etiketterne i
dagbåndet, de tre «vej ind»-kort, statusteksterne og oversigtssiden. Alt sammen let at
slette, hvis du hellere vil undvære det.

**Ikke medtaget fra det gamle site** (bevidst — de er lange enkeltemner, der fint kan
blive liggende som undersider): behandlingsvejledning ved fnat, vorter, glemt p-pille,
den fulde privatlivspolitik (der linkes til den), inhalationsvideoer og
find-speciallæge-værktøjet.

---

## Teknik

* **Ingen afhængigheder.** Ingen npm, ingen build, ingen CDN. Læg en mappe på en
  webserver, og den virker.
* **Ingen eksterne kald.** Alle 9 skrifter er selvhostede (`assets/fonts/`, latin-subset,
  variable, 21–147 KB pr. stk.). Ingen Google Fonts, ingen analytics, ingen cookies.
* **Billeder** er komprimeret til WebP i to bredder med `srcset`/`sizes` og
  `loading="lazy"` + `decoding="async"`. Samlet ~2,7 MB for alle fire sider.
* **Tilgængelighed.** Semantisk HTML, springlink, synlige fokusmarkeringer,
  `aria-live` på statusfelter, tastaturbetjening overalt, korrekt overskriftshierarki.
* **`prefers-reduced-motion`** slår al bevægelse fra — også canvas-animationerne, der
  falder tilbage til et statisk billede.
* **Print.** Alle fire sider har et print-stylesheet: baggrunde og HUD forsvinder,
  foldelister åbnes, teksten bliver sort på hvidt.
* **Ydelse.** Canvas-løkkerne stopper på `visibilitychange`, scroll-handlers er
  rAF-throttlede, og partikelantal skaleres efter skærmareal. Første visning vejer
  120–320 KB pr. side; videoen hentes først, når nogen trykker play (`preload="none"`).

### Struktureret data

Begge dykkersider udgiver `Course`-schema med `CourseInstance`, sted, datoer og pris.
Begge lægehussider udgiver `MedicalClinic`-schema med adresse, telefon, CVR og
åbningstider.

---

## Sådan kører du det lokalt

```bash
# hvilken som helst statisk server, fx:
npx http-server . -p 8080
# eller
python3 -m http.server 8080
```

Åbn så `http://localhost:8080/`.

Filerne kan også åbnes direkte fra disken (`file://`), men så blokerer browseren
webfonts og video i nogle tilfælde — brug hellere en server.

## Sådan lægger du et bud i drift

Hvert bud er selvstændigt. For at sætte fx «Nedstigningen» op på
`dykkerlaege.hejmadi.dk`:

1. Kopiér `dykkerlaege/nedstigningen/*` til webrodens top.
2. Kopiér `assets/fonts/`, `assets/img/dyk/` og `assets/video/` med.
3. Ret stierne fra `../../assets/` til `assets/` i `index.html` og `style.css`
   (i CSS'en er det kun `@font-face`-blokken øverst).
4. Ret `og:image` og eventuelle absolutte links.

Til `hejmadi.github.io` kan mappen lægges direkte ind som fx
`/dykkermedicin/`, og så virker `../../assets/`-stierne, hvis `assets/` ligger i roden.

---

## Ting du selv skal beslutte

* **Tre steder modsiger jeres nuværende sider hinanden.** Jeg har ikke gættet — I skal vælge:
  * **Kørekortsattest:** prislisten siger «750 kr. inkl. moms», mens kørekortsiden siger
    «500,- kr. … dog 750 kr. ved erhvervskørekort til personbefordring». Begge står i dag på
    sitet; nu ligger de tæt på hinanden og er lette at se. Ret det ene sted.
  * **Receptfornyelse pr. telefon:** receptsiden siger «telefonisk mellem kl. 9.00–12.00»,
    men åbningstiderne siger, at telefonen er åben 8.30–11.45 med pause 9.45–10.15 og lukker
    kl. 11.45. De to kan ikke passe samtidig.
  * **Rejsevaccination:** prislisten siger «tilbydes ikke i lægehuset — kontakt i stedet en
    vaccinationsklinik», mens rejsevaccinationssiden beskriver en vaccinationsplan hos jeres
    sygeplejersker til 300 kr. Jeg har brugt prislistens formulering, fordi den er den mest
    entydige — men den anden tekst ligger stadig på det nuværende site.
* **To navne staves forskelligt i jeres eget indhold**, og jeg har ladet begge stavemåder
  stå, som de står i dag — men I skal nok vælge én af hver:
  * «Dorte Oxholm Olsen» (overskrift på lægesiden) vs. «Dorthe Oxholm» (billedtekst og forside)
  * «Rikke Bak Toft Andreasen» (forside) vs. «Rikke Toft Bak Andreasen» (lægesiden)
  * «Nicolai Soll» (forside) vs. «Nicolai Soll Osei» (lægesiden)
* **Bookinglinket.** `https://www.laegevejen.dk/` er brugt som mål for «Book tid samme
  dag». Hvis I har et direkte dybt link ind i jeres booking, skal det ind i stedet
  (søg efter `laegevejen.dk` i de to lægehussider).
* **Helligdage.** Åbningsstatus regner kun med hverdage kontra weekend. På juledag vil den
  altså sige «Telefonen er åben». Skal den kende danske helligdage, skal der en datotabel
  (eller en påskeberegning) ind i begge `app.js` — sig til, så lægger jeg den ind.
  Onsdagens lange konsultationsdag til kl. 16.15 er der taget højde for.
* **Ventelisten til kurset.** Kontaktoplysningen ligger kun i billedet
  `assets/img/dyk/tilmelding.webp`. Det er formentlig med vilje — en adresse i et billede
  bliver ikke høstet af spamrobotter. Prisen er, at den hverken kan kopieres, klikkes
  eller læses op af en skærmlæser. Vil du have begge dele, er en almindelig løsning at
  skrive adressen som tekst og sætte den sammen med JavaScript. Sig til, hvis den skal ind.
* **Introvideoen** fylder 11 MB. Den hentes ikke, før nogen trykker play, så den koster
  intet ved sidevisning — men skal nogen se den på mobildata, er det stadig 11 MB.
  En omkodning til H.264 720p ville typisk lande på 2–3 MB uden synligt tab.
* **Billedernes ophav.** Dykkerbillederne ser ud til at være AI-genererede (der er et
  sparkle-mærke i nederste højre hjørne på flere af dem). Til en artikel i et
  fagtidsskrift bør det formentlig oplyses.
