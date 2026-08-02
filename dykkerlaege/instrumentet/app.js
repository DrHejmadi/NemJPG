/* ═══════════════════════════════════════════════════════════════
   INSTRUMENTET — tryk-, gas- og dybdemodel + redaktionel adfærd
   Ingen afhængigheder.
   ═══════════════════════════════════════════════════════════════ */
(() => {
  'use strict';

  const reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;
  const clamp = (v,a,b) => v<a?a:v>b?b:v;
  const dk = (n, d=2) => n.toFixed(d).replace('.', ',');

  /* ── Tema ──────────────────────────────────────────────────── */
  const themeBtn = document.getElementById('themeBtn');
  themeBtn.addEventListener('click', () => {
    const cur = document.documentElement.dataset.theme;
    const sysDark = matchMedia('(prefers-color-scheme: dark)').matches;
    const now = cur ? cur : (sysDark ? 'dark' : 'light');
    const next = now === 'dark' ? 'light' : 'dark';
    document.documentElement.dataset.theme = next;
    try { localStorage.setItem('fd-theme', next); } catch (e) {}
    const meta = document.querySelector('meta[name="theme-color"]');
    if (meta) meta.setAttribute('content', next === 'dark' ? '#0C0E0F' : '#f2f0eb');
  });

  /* ── Mobilmenu ─────────────────────────────────────────────── */
  const burger = document.getElementById('burger');
  const nav = document.getElementById('nav');
  burger.addEventListener('click', () => {
    const open = nav.classList.toggle('open');
    burger.classList.toggle('x', open);
    burger.setAttribute('aria-expanded', String(open));
    document.body.style.overflow = open ? 'hidden' : '';
  });
  nav.addEventListener('click', e => {
    if (e.target.closest('a') && nav.classList.contains('open')) burger.click();
  });
  addEventListener('keydown', e => {
    if (e.key === 'Escape' && nav.classList.contains('open')) burger.click();
  });

  /* ── Læseprogress + aktivt navpunkt ────────────────────────── */
  const bar = document.querySelector('#progress span');
  const navLinks = [...nav.querySelectorAll('a')];
  const navTargets = navLinks.map(a => document.querySelector(a.getAttribute('href'))).filter(Boolean);
  let navIdx = -1, ticking = false;

  function onScroll() {
    if (ticking) return;
    ticking = true;
    requestAnimationFrame(() => {
      const h = document.documentElement.scrollHeight - innerHeight;
      bar.style.width = (clamp(scrollY / Math.max(1, h), 0, 1) * 100).toFixed(2) + '%';

      const y = scrollY + innerHeight * 0.35;
      let idx = -1;
      navTargets.forEach((t, i) => { if (t.offsetTop <= y) idx = i; });
      if (idx !== navIdx) {
        navIdx = idx;
        navLinks.forEach((a, i) => a.classList.toggle('here', i === idx));
      }
      ticking = false;
    });
  }
  addEventListener('scroll', onScroll, { passive: true });
  onScroll();

  /* ── Kinetisk overskrift + reveal ──────────────────────────── */
  const ups = [...document.querySelectorAll('.sec__head, .body-lg, .margin, .pillars, .plates, .row__body, .row__fig, .sched, .faculty, .datasheet, .closer__h, .closer__img, .spec, .hero__sub, .inst')];
  ups.forEach(el => el.classList.add('up'));
  const kins = [...document.querySelectorAll('[data-kin]')];

  if ('IntersectionObserver' in window && !reduce) {
    const io = new IntersectionObserver(es => {
      es.forEach(e => { if (e.isIntersecting) { e.target.classList.add('in'); io.unobserve(e.target); } });
    }, { rootMargin: '0px 0px -6% 0px', threshold: 0.05 });
    ups.forEach(el => io.observe(el));
    requestAnimationFrame(() => kins.forEach(k => k.classList.add('in')));
  } else {
    ups.forEach(el => el.classList.add('in'));
    kins.forEach(k => k.classList.add('in'));
  }

  /* ── Tælleanimation ────────────────────────────────────────── */
  const counters = [...document.querySelectorAll('[data-count]')];
  if ('IntersectionObserver' in window && !reduce) {
    const cio = new IntersectionObserver(es => {
      es.forEach(e => {
        if (!e.isIntersecting) return;
        cio.unobserve(e.target);
        const el = e.target;
        const end = parseFloat(el.dataset.count);
        const t0 = performance.now(), dur = 1100;
        const fmt = n => end >= 1000 ? Math.round(n).toLocaleString('da-DK') : String(Math.round(n));
        (function step(t) {
          const p = clamp((t - t0) / dur, 0, 1);
          el.textContent = fmt(end * (1 - Math.pow(1 - p, 3)));
          if (p < 1) requestAnimationFrame(step);
        })(t0);
      });
    }, { threshold: 0.6 });
    counters.forEach(c => cio.observe(c));
  }

  /* ══ INSTRUMENTET ═══════════════════════════════════════════
     Model for atmosfærisk luft i saltvand.
       P_amb   = 1 + d/10                       [bar]
       P_insp  = (P_amb − P_H2O) · F_gas        [bar],  P_H2O ≈ 0,063 bar
       Boyle   = V/V0 = 1 / P_amb
       END     = (P_amb · 0,79 / 0,79 …)        forenklet: (d + 10) · 0,79/0,79
     Tallene er vejledende og illustrative.
     ═══════════════════════════════════════════════════════════ */
  const FO2 = 0.209, FN2 = 0.79, PH2O = 0.063;
  const NDL = [[12,147],[14,98],[16,72],[18,56],[20,45],[22,37],[25,29],[30,20],[35,14],[40,9],[45,6],[50,4],[60,3]];

  function ndl(d) {
    if (d < 11) return null;
    for (let i = 0; i < NDL.length - 1; i++) {
      if (d <= NDL[i+1][0]) {
        const t = (d - NDL[i][0]) / (NDL[i+1][0] - NDL[i][0]);
        return Math.max(3, Math.round(NDL[i][1] + (NDL[i+1][1] - NDL[i][1]) * clamp(t,0,1)));
      }
    }
    return 3;
  }

  const slider  = document.getElementById('depth');
  const outD    = document.getElementById('outDepth');
  const outP    = document.getElementById('outP');
  const outPO2  = document.getElementById('outPO2');
  const outPN2  = document.getElementById('outPN2');
  const outSAC  = document.getElementById('outSAC');
  const outNDL  = document.getElementById('outNDL');
  const outNDLu = document.getElementById('outNDLu');
  const outEND  = document.getElementById('outEND');
  const outVol  = document.getElementById('outVol');
  const outVolT = document.getElementById('outVolTxt');
  const boyle   = document.getElementById('boyleNow');
  const flags   = document.getElementById('flags');
  const presets = [...document.querySelectorAll('.inst__presets button')];

  function render(d) {
    const P    = 1 + d / 10;
    const Palv = Math.max(0, P - PH2O);
    const pO2  = Palv * FO2;
    const pN2  = Palv * FN2;
    const vol  = 1 / P;
    const n    = ndl(d);
    /* Ækvivalent narkosedybde på luft — ilt regnes med som narkotisk */
    const end  = Math.max(0, d);

    outD.textContent   = String(d);
    outP.textContent   = dk(P, 2);
    outPO2.textContent = dk(pO2, 2);
    outPN2.textContent = dk(pN2, 2);
    outSAC.textContent = dk(P, 1);
    outEND.textContent = String(Math.round(end));
    if (n === null) { outNDL.textContent = '∞'; outNDLu.textContent = ''; }
    else            { outNDL.textContent = String(n); outNDLu.textContent = 'min'; }

    const pct = Math.round(vol * 100);
    outVol.textContent  = String(pct);
    outVolT.textContent = pct + ' %';
    boyle.style.transform = `scale(${Math.max(0.14, Math.sqrt(vol)).toFixed(3)})`;

    /* Flag */
    const f = [];
    if (d === 0) f.push(['surface', 'Overfladen · 1 atm']);
    if (d > 0 && d <= 10) f.push(['', 'Største relative volumenændring sker her']);
    if (d >= 18) f.push(['', 'Nul-stop-tid begrænser dykket']);
    if (d >= 30) f.push(['warn', 'Kvælstofnarkose kan indtræde']);
    /* MOD-grænser vurderes på omgivende tryk (dykkerkonvention) */
    const pO2amb = P * FO2;
    if (pO2amb >= 1.4) f.push(['warn', 'Pₒ₂ ≥ 1,4 bar — anbefalet arbejdsgrænse']);
    if (pO2amb >= 1.6) f.push(['stop', 'Pₒ₂ ≥ 1,6 bar — MOD for atmosfærisk luft']);
    if (d >= 40) f.push(['warn', 'Ud over sportsdykkergrænsen på 40 m']);
    if (!f.length) f.push(['', 'Inden for nul-stop']);

    flags.innerHTML = f.map(([k, t]) =>
      `<li class="flag"${k ? ` data-flag="${k}"` : ''}>${t}</li>`).join('');

    presets.forEach(b => b.setAttribute('aria-pressed', String(+b.dataset.d === d)));
  }

  if (slider) {
    slider.addEventListener('input', () => render(+slider.value));
    presets.forEach(b => b.addEventListener('click', () => {
      slider.value = b.dataset.d;
      render(+b.dataset.d);
      slider.focus();
    }));
    render(+slider.value);

    /* Kør ét blødt sweep første gang instrumentet ses — så man
       opdager at det kan bruges. */
    if ('IntersectionObserver' in window && !reduce) {
      let done = false;
      const iio = new IntersectionObserver(es => {
        es.forEach(e => {
          if (!e.isIntersecting || done) return;
          done = true; iio.disconnect();
          const t0 = performance.now(), dur = 2200, to = 30;
          (function step(t) {
            const p = clamp((t - t0) / dur, 0, 1);
            const e2 = p < 0.5 ? 2*p*p : 1 - Math.pow(-2*p + 2, 2) / 2;
            const v = Math.round(to * e2);
            slider.value = v; render(v);
            if (p < 1) requestAnimationFrame(step);
          })(t0);
        });
      }, { threshold: 0.45 });
      iio.observe(document.getElementById('instrument'));
    }
  }
})();
