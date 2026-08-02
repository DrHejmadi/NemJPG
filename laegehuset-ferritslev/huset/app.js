/* ═══════════════════════════════════════════════════════════════
   HUSET — levende himmel, åbningsstatus og dagbånd
   Ingen afhængigheder.
   ═══════════════════════════════════════════════════════════════ */
(() => {
  'use strict';

  const reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;
  const clamp = (v,a,b) => v<a?a:v>b?b:v;
  const pad = n => String(n).padStart(2,'0');

  /* ── 1. Åbningstider ───────────────────────────────────────────
     Telefon      08.00–11.45, pause 09.45–10.15
     Konsultation man–fre 07.30–14.00, onsdag til 16.15
     Vagtmobil    12.00–16.00 (kun uopsætteligt behov)
     Lægevagten   16.00–08.00 samt weekend
     ─────────────────────────────────────────────────────────── */
  const statusEl  = document.getElementById('status');
  const statusTxt = document.getElementById('statusTxt');

  function stateNow(now) {
    const day = now.getDay();                 // 0 = søndag
    const t   = now.getHours() + now.getMinutes()/60;
    const wed = day === 3;
    const closeCons = wed ? 16.25 : 14;

    if (day === 0 || day === 6)
      return ['closed', 'Lukket i weekenden — ring til Lægevagten på 70 11 07 07'];

    if (t < 7.5)  return ['closed', `Lukket nu — vi åbner kl. 07.30 (om ${untilTxt(7.5 - t)})`];
    if (t < 8)    return ['open',    'Åbent — konsultationen er i gang. Telefonen åbner kl. 8.00'];
    if (t < 8.5)  return ['open',    'Telefonen er åben for tid samme dag indtil kl. 8.30'];
    if (t < 9.75) return ['open',    'Telefonen er åben — ring på 65 98 10 02'];
    if (t < 10.25)return ['limited', 'Telefonpause og møde — vi tager telefonen igen kl. 10.15'];
    if (t < 11.75)return ['open',    'Telefonen er åben — ring på 65 98 10 02'];
    if (t < 12)   return ['limited', 'Telefonen er lukket for i dag. Konsultationen kører videre'];
    if (t < 16)   return ['limited', t < closeCons
                          ? 'Kun akut uopsætteligt behov — du stilles om til vagtmobilen'
                          : 'Konsultationen er slut. Kun akut uopsætteligt behov indtil kl. 16.00'];
    return ['closed', 'Lukket for i dag — ring til Lægevagten på 70 11 07 07'];
  }

  function untilTxt(hours) {
    const m = Math.round(hours * 60);
    if (m < 60) return `${m} min.`;
    const h = Math.floor(m / 60);
    return `${h} t. ${pad(m % 60)} min.`;
  }

  function paintStatus() {
    const now = new Date();
    const [kind, txt] = stateNow(now);
    statusEl.classList.remove('is-open','is-limited','is-closed');
    statusEl.classList.add('is-' + kind);
    statusTxt.textContent = txt;
  }

  /* ── 2. Dagbånd ───────────────────────────────────────────── */
  const dbNow = document.getElementById('daybarNow');
  function paintDaybar() {
    const now = new Date();
    const t = now.getHours() + now.getMinutes()/60;
    const day = now.getDay();
    if (day === 0 || day === 6 || t < 7 || t > 17) { dbNow.classList.add('off'); return; }
    dbNow.classList.remove('off');
    dbNow.style.left = (((t - 7) / 10) * 100).toFixed(2) + '%';
  }

  paintStatus(); paintDaybar();
  setInterval(() => { paintStatus(); paintDaybar(); }, 30000);

  /* ── 3. Levende himmel ────────────────────────────────────── */
  const cv = document.getElementById('sky');
  const ctx = cv.getContext('2d', { alpha: false });
  let W = 0, H = 0, blobs = [];

  /* Dagcyklus: farvestemning følger klokken */
  function mood() {
    const h = new Date().getHours() + new Date().getMinutes()/60;
    if (h < 6)  return { base:'#EFE9E2', a:'#D9DEE6', b:'#E7DFD2', c:'#DCE4DC' }; // nat/tidlig
    if (h < 10) return { base:'#FDF7EC', a:'#FBE6C4', b:'#EAF0E2', c:'#FBEEDF' }; // morgen
    if (h < 15) return { base:'#FBF7EF', a:'#F1F5E8', b:'#FBEFDD', c:'#E9F1EC' }; // dag
    if (h < 19) return { base:'#FCF4E7', a:'#FAE3C9', b:'#F0EADB', c:'#EDE7DA' }; // eftermiddag
    return       { base:'#F6F0E6', a:'#E7DFD4', b:'#DFE3E4', c:'#EDE2D3' };       // aften
  }

  function build() {
    const dpr = Math.min(devicePixelRatio || 1, 1.6);
    W = innerWidth; H = innerHeight;
    cv.width = Math.round(W*dpr); cv.height = Math.round(H*dpr);
    cv.style.width = W+'px'; cv.style.height = H+'px';
    ctx.setTransform(dpr,0,0,dpr,0,0);
    const m = mood();
    blobs = [
      { x:.18, y:.18, r:.55, c:m.a, sx:.00013, sy:.00009, px:.9,  py:.6 },
      { x:.82, y:.30, r:.48, c:m.b, sx:.00009, sy:.00012, px:1.3, py:.8 },
      { x:.55, y:.82, r:.62, c:m.c, sx:.00011, sy:.00007, px:.7,  py:1.1 },
      { x:.08, y:.75, r:.42, c:m.b, sx:.00015, sy:.00010, px:1.1, py:.5 }
    ];
  }

  function paintSky(t) {
    const m = mood();
    ctx.fillStyle = m.base;
    ctx.fillRect(0,0,W,H);
    const big = Math.max(W,H);
    for (const b of blobs) {
      const x = (b.x + Math.sin(t*b.sx + b.px) * 0.07) * W;
      const y = (b.y + Math.cos(t*b.sy + b.py) * 0.06) * H;
      const r = b.r * big * (0.92 + 0.08*Math.sin(t*0.00008 + b.px));
      const g = ctx.createRadialGradient(x,y,0,x,y,r);
      g.addColorStop(0, b.c);
      g.addColorStop(1, 'rgba(255,255,255,0)');
      ctx.globalAlpha = .55;
      ctx.fillStyle = g;
      ctx.beginPath(); ctx.arc(x,y,r,0,6.284); ctx.fill();
    }
    ctx.globalAlpha = 1;
  }

  let raf = 0, running = true;
  function loop(ts) {
    paintSky(ts || 0);
    if (running) raf = requestAnimationFrame(loop);
  }

  build();
  if (reduce) { paintSky(0); }
  else { raf = requestAnimationFrame(loop); }

  let rTo = 0;
  addEventListener('resize', () => {
    clearTimeout(rTo);
    rTo = setTimeout(() => { build(); if (reduce) paintSky(0); }, 140);
  }, { passive:true });

  document.addEventListener('visibilitychange', () => {
    if (reduce) return;
    if (document.hidden) { running = false; cancelAnimationFrame(raf); }
    else if (!running)   { running = true; build(); raf = requestAnimationFrame(loop); }
  });

  /* ── 4. Menu ──────────────────────────────────────────────── */
  const hamb = document.getElementById('hamb');
  const menu = document.getElementById('menu');
  hamb.addEventListener('click', () => {
    const open = menu.classList.toggle('open');
    hamb.classList.toggle('x', open);
    hamb.setAttribute('aria-expanded', String(open));
    document.body.style.overflow = open ? 'hidden' : '';
  });
  menu.addEventListener('click', e => {
    if (e.target.closest('a') && menu.classList.contains('open')) hamb.click();
  });
  addEventListener('keydown', e => {
    if (e.key === 'Escape' && menu.classList.contains('open')) hamb.click();
  });

  /* ── 5. Aktivt menupunkt ──────────────────────────────────── */
  const links = [...menu.querySelectorAll('a')];
  const targets = links.map(a => document.querySelector(a.getAttribute('href'))).filter(Boolean);
  let idxNow = -1, tick = false;
  addEventListener('scroll', () => {
    if (tick) return; tick = true;
    requestAnimationFrame(() => {
      const y = scrollY + innerHeight*0.32;
      let i = -1;
      targets.forEach((t,j) => { if (t.offsetTop <= y) i = j; });
      if (i !== idxNow) { idxNow = i; links.forEach((a,j) => a.classList.toggle('here', j===i)); }
      tick = false;
    });
  }, { passive:true });

  /* ── 6. Reveal ────────────────────────────────────────────── */
  const rv = [...document.querySelectorAll('.sec > .wrap > *, .hero__col > *, .hero__arch, .tri, .tile, .p-card, .hours article')];
  rv.forEach(el => el.classList.add('rv'));
  if ('IntersectionObserver' in window && !reduce) {
    const io = new IntersectionObserver(es => {
      es.forEach(e => { if (e.isIntersecting) { e.target.classList.add('in'); io.unobserve(e.target); } });
    }, { rootMargin:'0px 0px -5% 0px', threshold:0.04 });
    rv.forEach(el => io.observe(el));
  } else {
    rv.forEach(el => el.classList.add('in'));
  }
})();
