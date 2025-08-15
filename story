<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Story Showcase</title>
  <style>
    :root {
      --bg: #0b0d12; /* deep slate */
      --panel: #121621;
      --muted: #a8b0c0;
      --text: #e8ecf4;
      --accent: #7cc4ff;
      --accent-2: #a78bfa; /* soft purple */
      --card: #0f1320;
      --ring: rgba(124,196,255,.45);
    }
    html, body { height: 100%; }
    body {
      margin: 0; font-family: ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, "Helvetica Neue", Arial, "Noto Sans", "Apple Color Emoji", "Segoe UI Emoji";
      background: radial-gradient(1200px 800px at 20% -10%, #162032 0%, transparent 60%),
                  radial-gradient(1000px 700px at 120% -20%, #1f1338 0%, transparent 60%),
                  var(--bg);
      color: var(--text);
    }
    .shell { display: grid; grid-template-columns: 280px 1fr; gap: 16px; max-width: 1200px; margin: 24px auto; padding: 0 16px; }
    .sidebar { position: sticky; top: 16px; height: calc(100dvh - 32px); background: linear-gradient(180deg, #121621, #0e1220); border: 1px solid rgba(255,255,255,.06); border-radius: 16px; overflow: hidden; }
    .brand { padding: 16px 16px 8px; border-bottom: 1px solid rgba(255,255,255,.06); background: linear-gradient(180deg, rgba(124,196,255,.08), transparent 50%); }
    .brand h1 { font-size: 18px; margin: 0; letter-spacing: .2px; }
    .brand p { margin: 6px 0 0; color: var(--muted); font-size: 13px; }
    .chapters { list-style: none; margin: 0; padding: 8px 8px 12px; overflow: auto; height: calc(100% - 78px); }
    .chapters li { margin: 6px 0; }
    .chapters button { width: 100%; text-align: left; padding: 10px 12px; background: transparent; color: var(--text); border: 1px solid rgba(255,255,255,.06); border-radius: 10px; cursor: pointer; transition: .2s transform, .2s background; }
    .chapters button[aria-current="true"], .chapters button:hover { background: rgba(124,196,255,.08); border-color: rgba(124,196,255,.35); box-shadow: 0 0 0 3px var(--ring); }

    .content { background: linear-gradient(180deg, rgba(255,255,255,.02), transparent 30%); border: 1px solid rgba(255,255,255,.06); border-radius: 16px; padding: 18px; }
    .chapter-header { display: flex; align-items: baseline; gap: 10px; margin: 6px 0 10px; }
    .chapter-header h2 { margin: 0; font-size: 24px; }
    .chapter-header span { color: var(--muted); font-size: 13px; }
    .chapter-text { color: #dbe2ee; line-height: 1.6; font-size: 16px; white-space: pre-wrap; background: linear-gradient(180deg, rgba(167,139,250,.05), transparent 40%); border: 1px dashed rgba(167,139,250,.35); border-radius: 12px; padding: 12px; }

    .gallery { display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 10px; margin-top: 14px; }
    .card { background: var(--card); border: 1px solid rgba(255,255,255,.06); border-radius: 12px; overflow: hidden; cursor: zoom-in; position: relative; }
    .card img { display: block; width: 100%; height: 160px; object-fit: cover; filter: saturate(1.02) contrast(1.05); transition: .2s transform; }
    .card:hover img { transform: scale(1.02); }
    .cap { font-size: 12px; color: var(--muted); padding: 8px 10px; display: block; }

    .meta { display: flex; gap: 8px; align-items: center; margin: 10px 0 0; }
    .meta a { color: var(--accent); text-decoration: none; font-size: 13px; }
    .meta a:hover { text-decoration: underline; }

    /* Lightbox */
    .lightbox { position: fixed; inset: 0; background: rgba(0,0,0,.9); display: none; align-items: center; justify-content: center; z-index: 50; }
    .lightbox.open { display: flex; }
    .lightbox img { max-width: min(92vw, 1600px); max-height: 86vh; object-fit: contain; box-shadow: 0 10px 40px rgba(0,0,0,.6); border-radius: 10px; }
    .lb-cap { color: #dbe2ee; font-size: 14px; margin-top: 10px; text-align: center; max-width: 92vw; }
    .lb-close, .lb-prev, .lb-next { position: fixed; top: 12px; background: rgba(255,255,255,.06); border: 1px solid rgba(255,255,255,.2); color: #fff; backdrop-filter: blur(6px); padding: 8px 12px; border-radius: 10px; cursor: pointer; }
    .lb-close { right: 12px; }
    .lb-prev, .lb-next { top: 50%; transform: translateY(-50%); }
    .lb-prev { left: 12px; }
    .lb-next { right: 12px; }

    @media (max-width: 880px) {
      .shell { grid-template-columns: 1fr; }
      .sidebar { position: static; height: auto; }
      .chapters { height: auto; max-height: 40vh; }
    }
  </style>
</head>
<body>
  <div class="shell">
    <aside class="sidebar" role="complementary">
      <div class="brand">
        <h1>Story Showcase</h1>
        <p>Clean chapters • Thumbnail gallery • Lightbox</p>
      </div>
      <ul class="chapters" id="chapterList" role="tablist" aria-label="Chapters"></ul>
    </aside>

    <main class="content" role="main">
      <div class="chapter-header">
        <h2 id="chapterTitle">Chapter Title</h2>
        <span id="chapterMeta"></span>
      </div>
      <div id="chapterText" class="chapter-text">Select a chapter on the left to begin.</div>

      <div class="meta" id="albumLinks" aria-live="polite"></div>

      <section class="gallery" id="gallery" aria-label="Image gallery"></section>
    </main>
  </div>

  <!-- Lightbox -->
  <div class="lightbox" id="lightbox" aria-modal="true" role="dialog" aria-label="Image viewer">
    <button class="lb-close" id="lbClose" aria-label="Close">Close ✕</button>
    <button class="lb-prev" id="lbPrev" aria-label="Previous">◀</button>
    <div>
      <img id="lbImg" alt="Expanded image" />
      <div class="lb-cap" id="lbCap"></div>
    </div>
    <button class="lb-next" id="lbNext" aria-label="Next">▶</button>
  </div>

  <script>
    /* =============================
       1) EDIT YOUR CONTENT HERE
       ============================= */
    const STORY = {
      title: "Curse of Strahd — The Story So Far",
      chapters: [
        {
          id: "arrival",
          title: "Arrival in Barovia",
          date: "2025-01-17",
          text: `Fog like wet wool. A letter that shouldn't exist. The gates creaked open and we stepped into a valley that swallowed sound...\n\n**Party**: Ket L. Ball (cleric), Hoberm (druid), Rick Warmont (paladin), Gadwick (mage).`,
          album: [
            { label: "Imgur album", href: "https://imgur.com/a/your-album" }
          ],
          images: [
            { src: "https://images.unsplash.com/photo-1469474968028-56623f02e42e?q=80&w=1920&auto=format&fit=crop", alt: "Misty forest road", cap: "Road to Barovia" },
            { src: "https://images.unsplash.com/photo-1519681393784-d120267933ba?q=80&w=1920&auto=format&fit=crop", alt: "Old letter", cap: "The letter" }
          ]
        },
        {
          id: "village",
          title: "The Village and the Doll",
          date: "2025-02-02",
          text: `Hoberm tried to cheer a grieving mother with an opossum. It... did not work. We learned the doll was a clue.`,
          album: [ { label: "Dropbox folder", href: "https://www.dropbox.com/scl/fo/your-folder?rlkey=xyz" } ],
          images: [
            { src: "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?q=80&w=1920&auto=format&fit=crop", alt: "Candlelit room", cap: "Grief and resolve" },
            { src: "https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?q=80&w=1920&auto=format&fit=crop", alt: "Porcelain doll", cap: "The doll" }
          ]
        }
      ]
    };

    /* =============================
       2) APP CODE (no edits needed)
       ============================= */
    const chapterList = document.getElementById('chapterList');
    const chapterTitle = document.getElementById('chapterTitle');
    const chapterMeta  = document.getElementById('chapterMeta');
    const chapterText  = document.getElementById('chapterText');
    const gallery      = document.getElementById('gallery');
    const albumLinks   = document.getElementById('albumLinks');

    // Populate sidebar
    STORY.chapters.forEach((c, i) => {
      const li = document.createElement('li');
      const btn = document.createElement('button');
      btn.textContent = c.title;
      btn.setAttribute('role','tab');
      btn.setAttribute('aria-controls', `panel-${c.id}`);
      btn.addEventListener('click', () => loadChapter(i));
      li.appendChild(btn); chapterList.appendChild(li);
    });

    // Load first chapter
    loadChapter(0);

    function loadChapter(index){
      const c = STORY.chapters[index];
      ;[...chapterList.querySelectorAll('button')].forEach((b,i)=>{
        b.setAttribute('aria-current', i===index ? 'true' : 'false');
      });
      chapterTitle.textContent = c.title;
      chapterMeta.textContent = c.date ? new Date(c.date).toLocaleDateString() : '';
      chapterText.innerHTML = renderMarkdown(c.text || '');

      // Album links
      albumLinks.innerHTML = '';
      (c.album||[]).forEach(a => {
        const link = document.createElement('a');
        link.href = a.href; link.target = '_blank'; link.rel = 'noopener';
        link.textContent = a.label;
        albumLinks.appendChild(link);
      });

      // Thumbs
      gallery.innerHTML = '';
      (c.images||[]).forEach((img, i) => {
        const card = document.createElement('figure'); card.className = 'card';
        const im = document.createElement('img'); im.loading = 'lazy';
        im.src = img.src; im.alt = img.alt || '';
        im.addEventListener('click', () => openLightbox(c.images, i));
        const cap = document.createElement('figcaption'); cap.className='cap'; cap.textContent = img.cap || '';
        card.appendChild(im); card.appendChild(cap); gallery.appendChild(card);
      });

      // Update URL hash for sharing specific chapter
      history.replaceState(null, '', `#${c.id}`);
    }

    // Simple Markdown renderer (bold, italics, code, links, headings-ish)
    function renderMarkdown(md){
      return md
        .replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')
        .replace(/^###\s?(.*)$/gm, '<strong style="font-size:16px">$1</strong>')
        .replace(/^##\s?(.*)$/gm, '<strong style="font-size:18px">$1</strong>')
        .replace(/^#\s?(.*)$/gm, '<strong style="font-size:20px">$1</strong>')
        .replace(/\*\*([^*]+)\*\*/g,'<strong>$1</strong>')
        .replace(/\*([^*]+)\*/g,'<em>$1</em>')
        .replace(/`([^`]+)`/g,'<code style="background:#0b1120;padding:2px 6px;border-radius:6px;border:1px solid rgba(255,255,255,.08)">$1</code>')
        .replace(/\n\n/g,'</p><p>')
        .replace(/^/,'<p>')
        .concat('</p>')
        .replace(/\[([^\]]+)\]\(([^)]+)\)/g,'<a href="$2" target="_blank" rel="noopener">$1</a>');
    }

    // Lightbox
    const lb = document.getElementById('lightbox');
    const lbImg = document.getElementById('lbImg');
    const lbCap = document.getElementById('lbCap');
    const lbClose = document.getElementById('lbClose');
    const lbPrev = document.getElementById('lbPrev');
    const lbNext = document.getElementById('lbNext');

    let lbSet = []; let lbIndex = 0;
    function openLightbox(set, i){ lbSet = set; lbIndex = i; updateLB(); lb.classList.add('open'); }
    function updateLB(){ const it = lbSet[lbIndex]; lbImg.src = it.src; lbCap.textContent = it.cap || it.alt || ''; }
    function closeLB(){ lb.classList.remove('open'); }
    function prevLB(){ lbIndex = (lbIndex - 1 + lbSet.length) % lbSet.length; updateLB(); }
    function nextLB(){ lbIndex = (lbIndex + 1) % lbSet.length; updateLB(); }

    lbClose.addEventListener('click', closeLB); lbPrev.addEventListener('click', prevLB); lbNext.addEventListener('click', nextLB);
    lb.addEventListener('click', (e)=>{ if(e.target === lb) closeLB(); });
    window.addEventListener('keydown', (e)=>{
      if(!lb.classList.contains('open')) return;
      if(e.key === 'Escape') closeLB();
      if(e.key === 'ArrowLeft') prevLB();
      if(e.key === 'ArrowRight') nextLB();
    });

    // Deep-link to chapter via hash
    window.addEventListener('load', () => {
      const id = location.hash.replace('#','');
      const idx = STORY.chapters.findIndex(c => c.id === id);
      if(idx >= 0) loadChapter(idx);
      // Set site title
      document.querySelector('.brand h1').textContent = STORY.title || 'Story Showcase';
    });
  </script>
</body>
</html>
