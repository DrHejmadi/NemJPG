/* ═══════════════════════════════════════════════════════════════
   KLAR BESKED — søgning, live-status og tastaturnavigation
   Ingen afhængigheder.
   ═══════════════════════════════════════════════════════════════ */
(() => {
  'use strict';

  const reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;
  const pad = n => String(n).padStart(2,'0');

  /* ── Tema ──────────────────────────────────────────────────── */
  const themeBtn = document.getElementById('themeBtn');
  themeBtn.addEventListener('click', () => {
    const cur = document.documentElement.dataset.theme;
    const sys = matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
    const next = (cur || sys) === 'dark' ? 'light' : 'dark';
    document.documentElement.dataset.theme = next;
    try { localStorage.setItem('lhf-theme', next); } catch(e) {}
    const m = document.querySelector('meta[name="theme-color"]');
    if (m) m.setAttribute('content', next === 'dark' ? '#0B0B0C' : '#FFFFFF');
  });

  /* ══ 1. Søgeindeks ═══════════════════════════════════════════
     Bygges af selve siden — ingen liste at holde ved lige.
     ═════════════════════════════════════════════════════════ */
  const norm = s => s.toLowerCase()
    .replace(/æ/g,'ae').replace(/ø/g,'oe').replace(/å/g,'aa')
    .replace(/[^\wåæø\s-]/g,' ')
    .replace(/\s+/g,' ').trim();

  const index = [];
  document.querySelectorAll('details.q').forEach(d => {
    const sum = d.querySelector('summary');
    const sec = d.closest('section');
    const head = (() => {
      let el = d.previousElementSibling;
      while (el && !el.classList.contains('idx__h')) el = el.previousElementSibling;
      return el ? el.textContent.trim() : (sec?.querySelector('.h2')?.textContent.trim() || '');
    })();
    const body = d.querySelector('.a')?.textContent || '';
    index.push({
      el: d,
      title: sum.textContent.trim(),
      group: head,
      tags: d.dataset.tags || '',
      hay: norm([sum.textContent, head, d.dataset.tags || '', body].join(' '))
    });
  });

  const q       = document.getElementById('q');
  const results = document.getElementById('results');
  const clearQ  = document.getElementById('clearQ');
  let cursor = -1, current = [];

  function score(item, terms) {
    let s = 0;
    const t = norm(item.title), g = norm(item.tags);
    for (const w of terms) {
      if (!item.hay.includes(w)) return -1;      // alle ord skal findes
      if (t.startsWith(w)) s += 60;
      else if (t.includes(w)) s += 34;
      if (g.includes(w)) s += 22;
      s += 4;
    }
    return s;
  }

  const OPEN='\u0001', CLOSE='\u0002';
  function highlight(text, terms) {
    let out = text;
    for (const w of terms) {
      if (w.length < 2) continue;
      const re = new RegExp('(' + w.replace(/[.*+?^${}()|[\]\\]/g,'\\$&') + ')', 'gi');
      out = out.replace(re, OPEN + '$1' + CLOSE);
    }
    return out
      .replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')
      .split(OPEN).join('<mark>')
      .split(CLOSE).join('</mark>');
  }

  function render(list, terms) {
    results.innerHTML = '';
    if (!list.length) {
      results.innerHTML = '<li class="none">Ingen træf. Prøv et andet ord — eller ring 65 98 10 02.</li>';
      show(true); return;
    }
    list.forEach((it, i) => {
      const li = document.createElement('li');
      li.id = 'res-' + i;
      li.setAttribute('role','option');
      li.setAttribute('aria-selected', String(i === cursor));
      const b = document.createElement('button');
      b.type = 'button';
      b.tabIndex = -1;
      b.innerHTML = `<b>${highlight(it.title, terms)}</b><small>${it.group}</small>`;
      b.addEventListener('click', () => jump(it));
      li.appendChild(b);
      results.appendChild(li);
    });
    show(true);
    setActive(cursor);
  }

  function show(on) {
    results.hidden = !on;
    q.setAttribute('aria-expanded', String(on));
    document.getElementById('search').classList.toggle('is-open', on);
    if (!on) q.removeAttribute('aria-activedescendant');
  }

  function setActive(i) {
    [...results.children].forEach((li, j) => li.setAttribute('aria-selected', String(j === i)));
    if (i >= 0 && results.children[i]) q.setAttribute('aria-activedescendant', 'res-' + i);
    else q.removeAttribute('aria-activedescendant');
  }

  function jump(item) {
    show(false);
    document.querySelectorAll('details.q[open]').forEach(d => { if (d !== item.el) d.open = false; });
    item.el.open = true;
    const y = item.el.getBoundingClientRect().top + scrollY - 110;
    scrollTo({ top: y, behavior: reduce ? 'auto' : 'smooth' });
    item.el.classList.remove('hit');
    void item.el.offsetWidth;
    item.el.classList.add('hit');
    setTimeout(() => item.el.classList.remove('hit'), 1800);
    item.el.querySelector('summary').focus({ preventScroll: true });
  }

  function search() {
    const raw = q.value.trim();
    clearQ.hidden = !raw;
    if (raw.length < 2) { show(false); current = []; cursor = -1; return; }
    const terms = norm(raw).split(' ').filter(Boolean);
    const rawTerms = raw.toLowerCase().split(/\s+/).filter(Boolean);
    current = index
      .map(it => ({ it, s: score(it, terms) }))
      .filter(r => r.s >= 0)
      .sort((a,b) => b.s - a.s)
      .slice(0, 8)
      .map(r => r.it);
    cursor = current.length ? 0 : -1;
    render(current, [...new Set([...rawTerms, ...terms])]);
  }

  q.addEventListener('input', search);
  q.addEventListener('focus', () => { if (q.value.trim().length >= 2) search(); });

  q.addEventListener('keydown', e => {
    if (e.key === 'Escape') { q.value = ''; clearQ.hidden = true; show(false); q.blur(); return; }
    if (!current.length) return;
    if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
      e.preventDefault();
      cursor = (cursor + (e.key === 'ArrowDown' ? 1 : -1) + current.length) % current.length;
      setActive(cursor);
      results.children[cursor]?.scrollIntoView({ block:'nearest' });
    } else if (e.key === 'Enter') {
      e.preventDefault();
      if (current[cursor]) jump(current[cursor]);
    }
  });

  clearQ.addEventListener('click', () => { q.value=''; clearQ.hidden = true; show(false); q.focus(); });

  document.addEventListener('click', e => {
    if (!e.target.closest('#search')) show(false);
  });

  document.querySelectorAll('.chip').forEach(c => c.addEventListener('click', () => {
    q.value = c.dataset.q; q.focus(); search();
  }));

  document.getElementById('openSearch').addEventListener('click', () => {
    q.scrollIntoView({ block:'center', behavior: reduce ? 'auto' : 'smooth' });
    setTimeout(() => q.focus(), reduce ? 0 : 350);
  });

  addEventListener('keydown', e => {
    const tag = (e.target.tagName || '').toLowerCase();
    if (tag === 'input' || tag === 'textarea') return;
    if (e.key === '/' || ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 'k')) {
      e.preventDefault();
      q.scrollIntoView({ block:'center', behavior: reduce ? 'auto' : 'smooth' });
      setTimeout(() => q.focus(), reduce ? 0 : 300);
    }
  });

  /* ══ 2. Live-status ══════════════════════════════════════════ */
  const live = document.getElementById('live');
  const big  = document.getElementById('liveBig');
  const sub  = document.getElementById('liveSub');
  const nxt  = document.getElementById('liveNext');
  const strip = [...document.querySelectorAll('#liveStrip li')];

  function untilTxt(hours) {
    const m = Math.max(1, Math.round(hours * 60));
    if (m < 60) return `${m} min.`;
    return `${Math.floor(m/60)} t. ${pad(m % 60)} min.`;
  }

  function tick() {
    const now = new Date();
    const day = now.getDay();
    const t = now.getHours() + now.getMinutes()/60;
    const closeCons = day === 3 ? 16.25 : 14;   /* onsdag har konsultation til 16.15 */
    let kind, head, text, next = '';

    if (day === 0 || day === 6) {
      kind = 'closed'; head = 'Lukket';
      text = 'Det er weekend. Ved akut behov: ring til Lægevagten på 70 11 07 07.';
      const daysTo = day === 6 ? 2 : 1;
      next = `Vi åbner igen mandag kl. 07.30 (om ${daysTo} ${daysTo === 1 ? 'dag' : 'dage'}).`;
    } else if (t < 7.5) {
      kind = 'closed'; head = 'Lukket';
      text = 'Konsultationen åbner kl. 07.30, telefonen kl. 8.00.';
      next = `Åbner om ${untilTxt(7.5 - t)}`;
    } else if (t < 8) {
      kind = 'open'; head = 'Åbent';
      text = 'Konsultationen er i gang. Telefonen åbner kl. 8.00.';
      next = `Telefonen åbner om ${untilTxt(8 - t)}`;
    } else if (t < 8.5) {
      kind = 'open'; head = 'Telefonen er åben';
      text = 'Lige nu tager vi imod ønsker om tid samme dag. Ring 65 98 10 02.';
      next = `Tid samme dag-vinduet lukker om ${untilTxt(8.5 - t)}`;
    } else if (t < 9.75) {
      kind = 'open'; head = 'Telefonen er åben';
      text = 'Alle henvendelser. Ring 65 98 10 02.';
      next = `Pause kl. 9.45 (om ${untilTxt(9.75 - t)}).`;
    } else if (t < 10.25) {
      kind = 'limited'; head = 'Telefonpause';
      text = 'Vi holder pause og møde. Vi tager telefonen igen kl. 10.15.';
      next = `Åbner om ${untilTxt(10.25 - t)}`;
    } else if (t < 11.75) {
      kind = 'open'; head = 'Telefonen er åben';
      text = 'Alle henvendelser. Ring 65 98 10 02.';
      next = `Telefonen lukker kl. 11.45 (om ${untilTxt(11.75 - t)}).`;
    } else if (t < 12) {
      kind = 'limited'; head = 'Telefonen er lukket';
      text = 'Konsultationen kører videre. Vagtmobilen åbner kl. 12.00.';
      next = `Vagtmobil om ${untilTxt(12 - t)}`;
    } else if (t < 16) {
      kind = 'limited'; head = 'Kun akut';
      text = 'Ved uopsætteligt behov stilles du om til vagtmobilen. Bemærk, at den vagthavende samtidig har patienter.';
      next = `Lægevagten overtager kl. 16.00 (om ${untilTxt(16 - t)}).`;
    } else if (t < closeCons) {
      kind = 'limited'; head = 'Kun akut';
      text = 'Konsultationen kører til kl. 16.15. Telefonisk er det Lægevagten på 70 11 07 07 fra kl. 16.00.';
      next = `Konsultationen slutter om ${untilTxt(closeCons - t)}`;
    } else {
      kind = 'closed'; head = 'Lukket';
      text = 'Ring til Lægevagten på 70 11 07 07 ved akut behov.';
      next = day === 5 ? 'Vi åbner igen mandag kl. 07.30.' : 'Vi åbner igen i morgen kl. 07.30.';
    }

    live.classList.remove('live--open','live--limited','live--closed');
    live.classList.add('live--' + kind);
    big.textContent = head;
    sub.textContent = text;
    nxt.textContent = next;

    const weekend = (day === 0 || day === 6);
    strip.forEach(li => {
      const a = parseFloat(li.dataset.from), b = parseFloat(li.dataset.to);
      li.classList.toggle('now', !weekend && t >= a && t < b);
      li.classList.toggle('past', weekend || t >= b);
    });
  }
  tick();
  setInterval(tick, 20000);

  /* ══ 3. Reveal ═══════════════════════════════════════════════ */
  const h1 = document.querySelector('.hero__h1');
  requestAnimationFrame(() => h1.classList.add('in'));

  const rv = [...document.querySelectorAll('.sec > .h2, .sec > .sub, .paths, .idx, .team, .cols, .roster, .kontakt, .live')];
  rv.forEach(el => el.classList.add('rv'));
  if ('IntersectionObserver' in window && !reduce) {
    const io = new IntersectionObserver(es => {
      es.forEach(e => { if (e.isIntersecting) { e.target.classList.add('in'); io.unobserve(e.target); } });
    }, { rootMargin:'0px 0px -5% 0px', threshold:0.03 });
    rv.forEach(el => io.observe(el));
  } else {
    rv.forEach(el => el.classList.add('in'));
  }

  /* ══ 4. Åbn accordion via #hash ══════════════════════════════ */
  function openFromHash() {
    const id = location.hash.slice(1);
    if (!id) return;
    const el = document.getElementById(id);
    if (el && el.tagName === 'DETAILS') { el.open = true; }
  }
  openFromHash();
  addEventListener('hashchange', openFromHash);
})();
