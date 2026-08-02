/* ═══════════════════════════════════════════════════════════════
   NEDSTIGNINGEN — dybdemotor, havbaggrund og dykkercomputer
   Ingen afhængigheder. Alt tegnes i canvas 2D.
   ═══════════════════════════════════════════════════════════════ */
(() => {
  'use strict';

  const reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  const fine   = window.matchMedia('(pointer: fine)').matches;
  const clamp  = (v, a, b) => v < a ? a : v > b ? b : v;
  const lerp   = (a, b, t) => a + (b - a) * t;
  const ease   = t => t * t * (3 - 2 * t);

  /* ── 1. Dybdeprofil ────────────────────────────────────────── */
  const sections = [...document.querySelectorAll('[data-depth-start]')];
  let stops = [];

  function measure() {
    stops = sections.map(el => {
      const r = el.getBoundingClientRect();
      const top = r.top + window.scrollY;
      return {
        el, top, bottom: top + r.height,
        a: parseFloat(el.dataset.depthStart),
        b: parseFloat(el.dataset.depthEnd)
      };
    });
  }

  function depthAt(y) {
    if (!stops.length) return 0;
    if (y <= stops[0].top) return stops[0].a;
    const last = stops[stops.length - 1];
    if (y >= last.bottom) return last.b;
    for (const s of stops) {
      if (y >= s.top && y <= s.bottom) {
        const t = (y - s.top) / Math.max(1, s.bottom - s.top);
        return lerp(s.a, s.b, ease(t));
      }
      if (y < s.top) return s.a;
    }
    return last.b;
  }

  /* ── 2. Farver efter dybde ─────────────────────────────────── */
  const PALETTE = [
    [  0, [ 74, 172, 202]],
    [  4, [ 44, 148, 186]],
    [ 10, [ 18, 111, 157]],
    [ 18, [  9,  82, 126]],
    [ 26, [  6,  56,  92]],
    [ 34, [  4,  36,  62]],
    [ 42, [  2,  21,  36]],
    [ 60, [  1,  11,  20]]
  ];

  function colAt(d) {
    d = clamp(d, 0, 60);
    for (let i = 0; i < PALETTE.length - 1; i++) {
      const [d0, c0] = PALETTE[i], [d1, c1] = PALETTE[i + 1];
      if (d <= d1) {
        const t = (d - d0) / (d1 - d0);
        return [
          Math.round(lerp(c0[0], c1[0], t)),
          Math.round(lerp(c0[1], c1[1], t)),
          Math.round(lerp(c0[2], c1[2], t))
        ];
      }
    }
    return PALETTE[PALETTE.length - 1][1];
  }
  const rgb = c => `rgb(${c[0]},${c[1]},${c[2]})`;

  /* ── 3. Havbaggrund ────────────────────────────────────────── */
  const cv  = document.getElementById('ocean');
  const ctx = cv.getContext('2d', { alpha: false });
  let W = 0, H = 0, DPR = 1;
  let snow = [], bubbles = [], shafts = [];

  function build() {
    DPR = Math.min(window.devicePixelRatio || 1, 2);
    W = window.innerWidth; H = window.innerHeight;
    cv.width = Math.round(W * DPR); cv.height = Math.round(H * DPR);
    cv.style.width = W + 'px'; cv.style.height = H + 'px';
    ctx.setTransform(DPR, 0, 0, DPR, 0, 0);

    const area = W * H;
    const nSnow = clamp(Math.round(area / 14000), 34, 120);
    snow = Array.from({ length: nSnow }, () => ({
      x: Math.random() * W,
      y: Math.random() * H * 3,
      r: 0.5 + Math.random() * 2.1,
      z: 0.25 + Math.random() * 0.95,          // parallaksedybde
      v: 0.06 + Math.random() * 0.32,          // egen synkehastighed
      a: 0.12 + Math.random() * 0.5,
      w: Math.random() * Math.PI * 2           // sidevals
    }));

    const nBub = clamp(Math.round(area / 46000), 8, 28);
    bubbles = Array.from({ length: nBub }, () => newBubble(true));

    shafts = Array.from({ length: 8 }, (_, i) => ({
      x: (i + 0.5) / 8 + (Math.random() - 0.5) * 0.06,
      w: 0.03 + Math.random() * 0.075,
      tilt: (Math.random() - 0.5) * 0.55,
      a: 0.35 + Math.random() * 0.65,
      s: 0.14 + Math.random() * 0.3
    }));
  }

  function newBubble(spread) {
    return {
      x: Math.random() * W,
      y: spread ? Math.random() * H : H + 20 + Math.random() * 120,
      r: 1.1 + Math.random() * 3.6,
      v: 0.35 + Math.random() * 1.15,
      w: Math.random() * Math.PI * 2,
      a: 0.16 + Math.random() * 0.34
    };
  }

  /* ── 4. Tilstand ───────────────────────────────────────────── */
  const state = { depth: 0, shown: 0, scroll: 0, prev: 0, dir: 1, t: 0 };

  function paint() {
    const d = state.shown;

    /* Vandsøjlens gradient: toppen af skærmen er ~10 m højere oppe */
    const g = ctx.createLinearGradient(0, 0, 0, H);
    g.addColorStop(0,    rgb(colAt(d - 9)));
    g.addColorStop(0.45, rgb(colAt(d)));
    g.addColorStop(1,    rgb(colAt(d + 11)));
    ctx.fillStyle = g;
    ctx.fillRect(0, 0, W, H);

    /* Overfladen set nedefra — kun de øverste meter */
    const surf = clamp(1 - d / 7, 0, 1);
    if (surf > 0.01) {
      const sy = H * 0.06 - d * 9;
      ctx.save();
      ctx.globalCompositeOperation = 'lighter';
      ctx.globalAlpha = surf * 0.5;
      for (let i = 0; i < 5; i++) {
        const yy = sy - i * 13;
        ctx.beginPath();
        ctx.moveTo(-20, yy);
        for (let x = -20; x <= W + 20; x += 26) {
          ctx.lineTo(x, yy + Math.sin(x * 0.014 + state.t * 0.0011 + i * 1.3) * (7 - i));
        }
        ctx.lineTo(W + 20, yy - 60); ctx.lineTo(-20, yy - 60); ctx.closePath();
        ctx.fillStyle = `rgba(215,248,255,${0.05 + i * 0.018})`;
        ctx.fill();
      }
      ctx.restore();
    }

    /* Lysstråler ovenfra — svinder med dybden */
    const rays = clamp(1 - d / 27, 0, 1);
    if (rays > 0.015) {
      ctx.save();
      ctx.globalCompositeOperation = 'lighter';
      for (const s of shafts) {
        const sway = Math.sin(state.t * 0.00022 * (0.6 + s.s) + s.x * 9) * W * 0.045;
        const x0 = s.x * W + sway;
        const w0 = s.w * W;
        const grad = ctx.createLinearGradient(x0, -H * 0.15, x0 + s.tilt * W * 0.5, H * 1.05);
        const al = rays * s.a * (0.10 + 0.045 * Math.sin(state.t * 0.0006 + s.x * 12));
        grad.addColorStop(0,   `rgba(198,244,255,${al})`);
        grad.addColorStop(0.5, `rgba(150,225,250,${al * 0.42})`);
        grad.addColorStop(1,   'rgba(120,200,235,0)');
        ctx.fillStyle = grad;
        ctx.beginPath();
        ctx.moveTo(x0 - w0 * 0.34, -H * 0.15);
        ctx.lineTo(x0 + w0 * 0.34, -H * 0.15);
        ctx.lineTo(x0 + s.tilt * W * 0.5 + w0 * 1.5, H * 1.05);
        ctx.lineTo(x0 + s.tilt * W * 0.5 - w0 * 1.5, H * 1.05);
        ctx.closePath();
        ctx.fill();
      }
      ctx.restore();
    }

    /* Marinesne — samlet i fire alfa-lag, så det bliver fire fills i stedet for ~190 */
    const sc = state.scroll;
    const dim = clamp(1.15 - d / 55, 0.25, 1);
    ctx.save();
    ctx.fillStyle = '#dff4fb';
    for (let b = 0; b < 4; b++) {
      ctx.globalAlpha = (0.14 + b * 0.16) * dim;
      ctx.beginPath();
      for (const p of snow) {
        const a = p.a * (0.35 + 0.65 * p.z);
        if (Math.min(3, Math.floor(a * 4)) !== b) continue;
        const y = ((p.y - sc * p.z * 0.42 + state.t * p.v * 0.012) % (H + 160) + H + 160) % (H + 160) - 80;
        const x = p.x + Math.sin(state.t * 0.0004 + p.w) * 9 * p.z;
        const r = p.r * (0.5 + p.z * 0.8);
        ctx.moveTo(x + r, y);
        ctx.arc(x, y, r, 0, 6.284);
      }
      ctx.fill();
    }
    ctx.restore();

    /* Bobler — stiger opad */
    ctx.save();
    ctx.strokeStyle = 'rgba(220,248,255,.55)';
    ctx.lineWidth = 1;
    for (const b of bubbles) {
      b.y -= b.v * 1.5;
      b.w += 0.02;
      if (b.y < -30) Object.assign(b, newBubble(false));
      const x = b.x + Math.sin(b.w) * 7;
      ctx.globalAlpha = b.a;
      ctx.beginPath(); ctx.arc(x, b.y, b.r, 0, 6.284); ctx.stroke();
      ctx.globalAlpha = b.a * 0.6;
      ctx.fillStyle = 'rgba(235,252,255,.35)';
      ctx.beginPath(); ctx.arc(x - b.r * 0.3, b.y - b.r * 0.3, b.r * 0.32, 0, 6.284); ctx.fill();
    }
    ctx.restore();
  }

  function paintStatic() {
    const d = state.depth;
    const g = ctx.createLinearGradient(0, 0, 0, H);
    g.addColorStop(0, rgb(colAt(d - 9)));
    g.addColorStop(1, rgb(colAt(d + 11)));
    ctx.fillStyle = g; ctx.fillRect(0, 0, W, H);
  }

  /* ── 5. Dykkercomputer ─────────────────────────────────────── */
  const hud       = document.getElementById('hud');
  const elDepth   = document.getElementById('hudDepth');
  const elPress   = document.getElementById('hudPress');
  const elNdl     = document.getElementById('hudNdl');
  const elNdlLab  = document.getElementById('hudNdlLabel');
  const elNdlUnit = document.getElementById('hudNdlUnit');
  const elFill    = document.getElementById('hudFill');
  const elStatus  = document.getElementById('hudStatus');

  /* Vejledende nul-stop-tider på atmosfærisk luft (min) */
  const NDL = [[12,147],[14,98],[16,72],[18,56],[20,45],[22,37],[25,29],[30,20],[35,14],[40,9],[45,6]];
  function ndlAt(d) {
    if (d < 11) return null;
    for (let i = 0; i < NDL.length - 1; i++) {
      if (d <= NDL[i + 1][0]) {
        const t = (d - NDL[i][0]) / (NDL[i + 1][0] - NDL[i][0]);
        return Math.max(5, Math.round(lerp(NDL[i][1], NDL[i + 1][1], clamp(t, 0, 1))));
      }
    }
    return 5;
  }

  let lastHud = -1;
  function drawHud() {
    const d = state.shown;
    if (Math.abs(d - lastHud) < 0.04) return;
    lastHud = d;

    elDepth.textContent = d.toFixed(1);
    elPress.textContent = (1 + d / 10).toFixed(2);

    const n = ndlAt(d);
    if (n === null) { elNdl.textContent = '∞'; elNdlUnit.textContent = ''; elNdlLab.textContent = 'Nul-stop'; }
    else            { elNdl.textContent = n;   elNdlUnit.textContent = 'min'; elNdlLab.textContent = 'Nul-stop'; }

    elFill.style.width = (clamp(d / 42, 0, 1) * 100).toFixed(1) + '%';

    let txt, alert = false;
    const up = state.dir < 0;
    if (d < 1.2)                    txt = 'Overfladen';
    else if (up && d >= 2.5 && d <= 6.5) { txt = 'Sikkerhedsstop 3:00'; alert = true; }
    else if (d < 18)                txt = up ? 'Opstigning' : 'Nedstigning';
    else if (d < 32)                txt = 'Arbejdsdybde';
    else                            { txt = 'Maksimal dybde'; alert = true; }
    if (elStatus.textContent !== txt) elStatus.textContent = txt;
    elStatus.classList.toggle('alert', alert);
  }

  /* ── 6. Løkke ──────────────────────────────────────────────── */
  let running = true, raf = 0;

  function frame(ts) {
    state.t = ts || 0;
    const target = state.depth;
    state.shown += (target - state.shown) * 0.075;
    if (Math.abs(target - state.shown) < 0.003) state.shown = target;
    paint();
    drawHud();
    markProfile();
    if (running) raf = requestAnimationFrame(frame);
  }

  /* Under reduceret bevægelse tegner vi kun, når noget faktisk ændrer sig */
  function still() {
    state.shown = state.depth;
    paintStatic();
    drawHud();
    markProfile();
  }

  function onScroll() {
    const y = window.scrollY + window.innerHeight * 0.5;
    state.scroll = window.scrollY;
    const d = depthAt(y);
    if (d > state.depth + 0.02) state.dir = 1;
    else if (d < state.depth - 0.02) state.dir = -1;
    state.depth = d;
    hud.classList.toggle('on', window.scrollY > 40);
    markLadder();
    if (reduce) still();
  }

  /* ── 7. Dybdestige ─────────────────────────────────────────── */
  const ladder = document.getElementById('ladder');
  const links  = [...ladder.querySelectorAll('a')];
  const targets = links.map(a => document.querySelector(a.getAttribute('href'))).filter(Boolean);
  let ladderIdx = -1;

  function markLadder() {
    const y = window.scrollY + window.innerHeight * 0.42;
    let idx = 0;
    targets.forEach((t, i) => { if (t.offsetTop <= y) idx = i; });
    if (idx === ladderIdx) return;
    ladderIdx = idx;
    links.forEach((a, i) => a.classList.toggle('here', i === idx));
  }

  /* ── 8. Reveal ─────────────────────────────────────────────── */
  const rev = [...document.querySelectorAll('.reveal')];
  if ('IntersectionObserver' in window && !reduce) {
    const io = new IntersectionObserver((es) => {
      es.forEach(e => { if (e.isIntersecting) { e.target.classList.add('in'); io.unobserve(e.target); } });
    }, { rootMargin: '0px 0px -8% 0px', threshold: 0.06 });
    rev.forEach(el => io.observe(el));
  } else {
    rev.forEach(el => el.classList.add('in'));
  }

  /* ── 9. Dykkerlygte (kun mus) ──────────────────────────────── */
  if (fine && !reduce) {
    document.body.classList.add('has-pointer');
    const torch = document.querySelector('.torch');
    let tx = -1e4, ty = -1e4, cx = -1e4, cy = -1e4, tRaf = 0;
    addEventListener('pointermove', e => {
      tx = e.clientX; ty = e.clientY;
      if (!tRaf) tRaf = requestAnimationFrame(moveTorch);
    }, { passive: true });
    function moveTorch() {
      cx += (tx - cx) * 0.12; cy += (ty - cy) * 0.12;
      torch.style.transform = `translate3d(${cx}px,${cy}px,0)`;
      tRaf = (Math.abs(tx - cx) > 0.5 || Math.abs(ty - cy) > 0.5) ? requestAnimationFrame(moveTorch) : 0;
    }
  }

  /* ── 10. Mobilmenu ─────────────────────────────────────────── */

  /* ── Fokusstyring i fuldskærmsmenuen ────────────────────────── */
  function menuFocus(panel, toggle, isOpen) {
    if (isOpen) {
      /* visibility skifter først ved næste frame — vent, ellers ignoreres focus() */
      requestAnimationFrame(() => requestAnimationFrame(() => {
        const first = panel.querySelector('a,button');
        if (first) first.focus();
      }));
    } else {
      toggle.focus();
    }
  }
  function trapTab(panel, e) {
    if (e.key !== 'Tab') return;
    const items = [...panel.querySelectorAll('a,button')]
      .filter(el => el.getBoundingClientRect().width > 0);
    if (!items.length) return;
    const first = items[0], last = items[items.length - 1];
    if (e.shiftKey && document.activeElement === first) { e.preventDefault(); last.focus(); }
    else if (!e.shiftKey && document.activeElement === last) { e.preventDefault(); first.focus(); }
  }

  const menuBtn = document.getElementById('menuBtn');
  menuBtn.addEventListener('click', () => {
    const open = ladder.classList.toggle('open');
    menuBtn.setAttribute('aria-expanded', String(open));
    menuBtn.classList.toggle('x', open);
    document.body.style.overflow = open ? 'hidden' : '';
    menuFocus(ladder, menuBtn, open);
  });
  ladder.addEventListener('keydown', e => {
    if (ladder.classList.contains('open')) trapTab(ladder, e);
  });
  matchMedia('(min-width:1401px)').addEventListener('change', e => {
    if (e.matches && ladder.classList.contains('open')) menuBtn.click();
  });
  ladder.addEventListener('click', e => {
    if (e.target.closest('a')) {
      ladder.classList.remove('open');
      menuBtn.classList.remove('x');
      menuBtn.setAttribute('aria-expanded', 'false');
      document.body.style.overflow = '';
    }
  });
  addEventListener('keydown', e => {
    if (e.key === 'Escape' && ladder.classList.contains('open')) menuBtn.click();
  });

  /* ── 11. Video: pause baggrundsanimation under afspilning ──── */
  const vid = document.getElementById('introVideo');
  if (vid && !reduce) {
    const halt = () => { running = false; cancelAnimationFrame(raf); };
    const go   = () => { if (!running && !document.hidden) { running = true; raf = requestAnimationFrame(frame); } };
    vid.addEventListener('play',  halt);
    vid.addEventListener('pause', go);
    vid.addEventListener('ended', go);
  }

  /* ── 12. Sidens dykkerprofil (footer) ──────────────────────── */
  const PF = {
    svg:  document.getElementById('profile'),
    grid: document.getElementById('pfGrid'),
    line: document.getElementById('pfLine'),
    area: document.getElementById('pfArea'),
    now:  document.getElementById('pfNow'),
    dot:  document.getElementById('pfDot'),
    axis: document.getElementById('pfAxis'),
    depths: document.getElementById('pfDepths'),
    W: 1000, H: 150, MAX: 45, built: false
  };

  function buildProfile() {
    if (!PF.svg || !stops.length) return;
    const docH = Math.max(1, document.documentElement.scrollHeight - window.innerHeight);
    const px = t => t * PF.W;
    const py = d => (d / PF.MAX) * PF.H;

    /* Kurven samples ved samme funktion som baggrunden bruger */
    const N = 160, pts = [];
    for (let i = 0; i <= N; i++) {
      const t = i / N;
      const y = t * docH + window.innerHeight * 0.5;
      pts.push([px(t), py(clamp(depthAt(y), 0, PF.MAX))]);
    }
    const d = pts.map((p, i) => (i ? 'L' : 'M') + p[0].toFixed(1) + ' ' + p[1].toFixed(1)).join(' ');
    PF.line.setAttribute('d', d);
    PF.area.setAttribute('d', `${d} L${PF.W} ${PF.H} L0 ${PF.H} Z`);

    /* Dybdelinjer i svg'en, etiketter som HTML (svg'en er skævt skaleret) */
    PF.grid.innerHTML = [10, 20, 30, 40].map(m =>
      `<line x1="0" y1="${py(m).toFixed(1)}" x2="${PF.W}" y2="${py(m).toFixed(1)}"></line>`).join('');
    if (PF.depths && !PF.depths.children.length) {
      PF.depths.innerHTML = [10, 20, 30, 40]
        .map(m => `<span style="top:${((m / PF.MAX) * 100).toFixed(1)}%">${m} m</span>`).join('');
    }

    /* Sektionsnavne under grafen */
    if (!PF.built) {
      PF.axis.innerHTML = links.map((a, i) => {
        const t = clamp((targets[i].offsetTop) / docH, 0, 1);
        return `<span style="left:${(t * 100).toFixed(2)}%">${a.querySelector('em').textContent}</span>`;
      }).join('');
      PF.built = true;
    }
  }

  function markProfile() {
    if (!PF.svg || !PF.line.getAttribute('d')) return;
    const docH = Math.max(1, document.documentElement.scrollHeight - window.innerHeight);
    const t = clamp(window.scrollY / docH, 0, 1);
    const x = t * PF.W;
    const y = (clamp(state.shown, 0, PF.MAX) / PF.MAX) * PF.H;
    PF.now.setAttribute('x1', x); PF.now.setAttribute('x2', x);
    PF.dot.setAttribute('cx', x); PF.dot.setAttribute('cy', y);
  }

  /* ── 13. Opstart ───────────────────────────────────────────── */
  let rTo = 0;
  function onResize() {
    clearTimeout(rTo);
    rTo = setTimeout(() => { build(); measure(); buildProfile(); onScroll(); lastHud = -1; if (reduce) still(); }, 110);
  }

  build(); measure(); buildProfile(); onScroll();
  state.shown = state.depth;
  addEventListener('scroll', onScroll, { passive: true });
  addEventListener('resize', onResize, { passive: true });
  addEventListener('orientationchange', onResize, { passive: true });
  addEventListener('load', () => { measure(); buildProfile(); onScroll(); });

  document.addEventListener('visibilitychange', () => {
    if (reduce) return;
    if (document.hidden) { running = false; cancelAnimationFrame(raf); }
    else if (!running)   { running = true; raf = requestAnimationFrame(frame); }
  });

  if (reduce) still(); else raf = requestAnimationFrame(frame);
})();
