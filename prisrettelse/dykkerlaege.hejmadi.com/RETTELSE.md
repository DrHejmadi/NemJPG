# Prisrettelse — dykkerlaege.hejmadi.com

Erhvervsdykkerundersøgelsen ændres fra **900 kr** til **1.500 kr**.

`index.html` i denne mappe er en kopi af den side, der ligger live på
dykkerlaege.hejmadi.com, med prisen rettet. Kun tre linjer er ændret —
resten af filen er uændret, tegn for tegn.

## De tre ændringer

| Linje | Før | Efter |
|---|---|---|
| 240 | `Årlig erhvervsdykkerundersøgelse <span class="price">900 kr</span>` | `… <span class="price">1.500 kr</span>` |
| 321 | `<div class="amount">900 kr <span>ekskl. moms</span></div>` | `<div class="amount">1.500 kr <span>ekskl. moms</span></div>` |
| 322 | `<p>Fast pris. 1.125 kr inkl. moms.</p>` | `<p>Fast pris. 1.875 kr inkl. moms.</p>` |

## Forudsætning: 1.500 kr er ekskl. moms

Alle priser på siden vises med beløbet **ekskl. moms** som overskrift og
inkl.-moms-tallet som underlinje (700 kr → 875 kr, 500 kr → 625 kr).
1.500 kr er derfor sat ind efter samme mønster: 1.500 kr ekskl. moms =
**1.875 kr inkl. moms**.

Hvis de 1.500 kr i stedet er ment **inkl.** moms, skal de to linjer være:

```html
<div class="amount">1.200 kr <span>ekskl. moms</span></div>
<p>Fast pris. 1.500 kr inkl. moms.</p>
```

og linje 240: `<span class="price">1.200 kr</span>` (listen står under
overskriften "Alle priser er ekskl. moms").

## Sådan lægges den op

Siden hostes på one.com (Apache/Varnish, ns01.one.com) — ikke på GitHub —
så den kan ikke pushes herfra. Upload `index.html` i one.com's filhåndtering
i webroden, hvor den nuværende `index.html` ligger.

Siden refererer kun til fire filer, som allerede ligger på serveren og
**ikke** skal røres: `favicon.svg`, `cookie.js`, `img/anita.jpg`,
`img/michael.jpg`.

Alternativt kan de tre linjer rettes direkte i one.com's teksteditor —
søg efter `900 kr` og `1.125 kr`.

## Kontrolleret

Siden er indlæst i headless Chromium ved 390 px og 1440 px: ingen vandret
scroll, ingen JavaScript-fejl, og alle ni prisfelter viser de rigtige tal.
(De fire "file not found" i konsollen lokalt er netop de fire filer ovenfor,
som ikke ligger i denne mappe — på serveren er de der.)
