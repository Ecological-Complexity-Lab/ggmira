/*
 * Feedback on the docs (pkgdown adds this file to every page).
 *
 * Three ways in: select text (a Feedback bubble appears), the 💬 next to a
 * heading, or the Feedback button at the bottom right. A small form takes
 * the comment, its type and the reader's name; "Open on GitHub" opens a
 * new issue in the ggmira repository, filled in with the page, section,
 * argument, selected text and version (label feedback and the type).
 * The reader checks it and clicks Submit (a GitHub account is needed). R has the same: mira_feedback().
 */
(() => {
const start = () => {
  const REPO = 'https://github.com/Ecological-Complexity-Lab/ggmira';
  const LABEL = 'feedback';
  const TYPES = [
    ['bug', 'Bug: wrong or broken'],
    ['unclear', 'Unclear: hard to follow'],
    ['missing', 'Missing: something to add'],
    ['idea', 'Idea'],
  ];
  // GitHub drops issue links much past 8000 characters: keep the parts short
  const MAX_QUOTE = 1000;
  const MAX_COMMENT = 3000;
  const TITLE_WORDS = 60; // characters of the comment in the title
  const NAME_KEY = 'ggmira-feedback-name';
  const HEADINGS = 'h1, h2, h3';

  const main = document.querySelector('main');
  if (!main) return;

  const storage = {
    get: () => { try { return localStorage.getItem(NAME_KEY) ?? ''; } catch { return ''; } },
    set: (v) => { try { localStorage.setItem(NAME_KEY, v); } catch { /* private window */ } },
  };

  // ---- context: page, section, argument ----------------------------------

  const headingText = (h) => h.textContent.replace(/💬/g, '').trim();

  function pageInfo() {
    const parts = location.pathname.split('/').filter(Boolean);
    const file = (parts.pop() || 'index.html').replace(/\.html$/, '');
    const folder = parts.pop();
    const h1 = main.querySelector('h1');
    const title = h1 ? headingText(h1) : document.title;
    if (folder === 'reference' && file !== 'index') return { name: file, path: `reference/${file}.html`, title };
    if (folder === 'articles') return { name: title, path: `articles/${file}.html`, title };
    if (folder === 'reference') return { name: 'Reference index', path: 'reference/index.html', title };
    return { name: file === 'index' ? 'Home' : title, path: `${file}.html`, title };
  }

  /** The nearest h2/h3 at or before `node`, and the argument it is in, if any. */
  function sectionOf(node) {
    const el = node?.nodeType === Node.ELEMENT_NODE ? node : node?.parentElement;
    let heading = null;
    for (const h of main.querySelectorAll('h2, h3')) {
      if (h === el || h.contains(el) || (h.compareDocumentPosition(el) & Node.DOCUMENT_POSITION_FOLLOWING)) heading = h;
    }
    let argument = null;
    const dd = el?.closest('dd');
    const dt = el?.closest('dt') ?? (dd ? dd.previousElementSibling : null);
    if (dt && dt.id?.startsWith('arg-')) argument = { name: dt.querySelector('code')?.textContent ?? dt.textContent.trim(), id: dt.id };
    return { heading: heading ? { text: headingText(heading), id: heading.id } : null, argument };
  }

  function version() {
    return document.querySelector('.navbar small.nav-text')?.textContent.trim() ?? '';
  }

  // ---- the issue ---------------------------------------------------------

  function issueUrl({ page, section, quote, type, comment, name }) {
    const where = [section.heading?.text, section.argument && `\`${section.argument.name}\``].filter(Boolean).join(' › ');
    const anchor = section.argument?.id ?? section.heading?.id;
    const short = comment.replace(/\s+/g, ' ').trim();
    const title = `[${page.name}] ${where ? `${where.replace(/`/g, '')}: ` : ''}` +
      (short.length > TITLE_WORDS ? `${short.slice(0, TITLE_WORDS)}…` : short);
    const quoted = quote.length > MAX_QUOTE ? `${quote.slice(0, MAX_QUOTE)}… (shortened)` : quote;
    const meta = [
      `**Page:** ${page.title} (\`${page.path}${anchor ? `#${anchor}` : ''}\`)`,
      where && `**Section:** ${where}`,
      `**Type:** ${type}`,
      name && `**From:** ${name}`,
      `**ggmira:** ${version()}`,
    ].filter(Boolean);
    const parts = [meta.join('  \n')];
    if (quoted) parts.push(quoted.split('\n').map(line => `> ${line}`).join('\n'));
    parts.push(comment.trim());
    const body = parts.join('\n\n');
    const query = { title, body, labels: `${LABEL},${type}` };
    return `${REPO}/issues/new?` +
      Object.entries(query).map(([k, v]) => `${k}=${encodeURIComponent(v)}`).join('&');
  }

  // ---- the form ------------------------------------------------------------

  const dialog = document.createElement('dialog');
  dialog.className = 'fb-dialog';
  dialog.innerHTML = `
    <form method="dialog" class="fb-form">
      <div class="fb-head"><strong>Feedback on the docs</strong>
        <button type="button" class="fb-close" aria-label="Close">×</button></div>
      <p class="fb-where"></p>
      <blockquote class="fb-quote"></blockquote>
      <fieldset class="fb-types"><legend>What is it?</legend>
        ${TYPES.map(([value, label], i) => `<label><input type="radio" name="type" value="${value}"${i === 1 ? ' checked' : ''}> ${label}</label>`).join('')}
      </fieldset>
      <label class="fb-label">Comment
        <textarea name="comment" rows="5" maxlength="${MAX_COMMENT}" required
          placeholder="What is wrong, confusing or missing? What did you expect?"></textarea></label>
      <label class="fb-label">Your name <input name="name" type="text" autocomplete="name"></label>
      <p class="fb-note">Opens a filled-in issue on GitHub in a new tab: check it and click <em>Submit new issue</em>.</p>
      <div class="fb-buttons"><button type="button" class="btn btn-light fb-cancel">Cancel</button>
        <button type="submit" class="btn btn-primary">Open on GitHub</button></div>
    </form>`;
  document.body.appendChild(dialog);
  const form = dialog.querySelector('form');
  let current = null; // { page, section, quote }

  function openForm(section, quote) {
    current = { page: pageInfo(), section, quote: quote.trim() };
    const where = [current.page.name, section.heading?.text, section.argument && section.argument.name]
      .filter(Boolean).join(' › ');
    dialog.querySelector('.fb-where').textContent = where;
    const q = dialog.querySelector('.fb-quote');
    q.textContent = current.quote.length > 300 ? `${current.quote.slice(0, 300)}…` : current.quote;
    q.hidden = !current.quote;
    form.comment.value = '';
    form.name.value = storage.get();
    dialog.showModal();
    form.comment.focus();
  }

  form.addEventListener('submit', (event) => {
    event.preventDefault();
    if (!current) return;
    const name = form.name.value.trim();
    storage.set(name);
    window.open(issueUrl({ ...current, type: form.type.value, comment: form.comment.value, name }), '_blank', 'noopener');
    dialog.close();
  });
  for (const selector of ['.fb-close', '.fb-cancel']) {
    dialog.querySelector(selector).addEventListener('click', () => dialog.close());
  }

  // ---- three ways in ---------------------------------------------------------

  // 1. Selected text: a bubble by the selection
  const bubble = document.createElement('button');
  bubble.type = 'button';
  bubble.className = 'fb-bubble';
  bubble.textContent = '💬 Feedback';
  bubble.hidden = true;
  document.body.appendChild(bubble);
  let selected = null; // { section, quote }

  bubble.addEventListener('mousedown', (event) => event.preventDefault()); // keep the selection
  bubble.addEventListener('click', () => {
    bubble.hidden = true;
    if (selected) openForm(selected.section, selected.quote);
  });

  function placeBubble() {
    const selection = window.getSelection();
    const text = selection?.toString().trim();
    if (!text || dialog.open || !selection.rangeCount || !main.contains(selection.anchorNode)) {
      bubble.hidden = true;
      return;
    }
    const range = selection.getRangeAt(0);
    const rects = range.getClientRects();
    const rect = rects[rects.length - 1] ?? range.getBoundingClientRect();
    selected = { section: sectionOf(range.startContainer), quote: text };
    bubble.hidden = false;
    const left = Math.min(window.scrollX + rect.right + 6, window.scrollX + document.documentElement.clientWidth - bubble.offsetWidth - 8);
    bubble.style.left = `${Math.max(8, left)}px`;
    bubble.style.top = `${window.scrollY + rect.bottom + 6}px`;
  }
  document.addEventListener('mouseup', () => setTimeout(placeBubble, 0));
  document.addEventListener('keyup', (event) => { if (event.shiftKey || event.key === 'Escape') placeBubble(); });
  document.addEventListener('selectionchange', () => { if (!window.getSelection()?.toString().trim()) bubble.hidden = true; });

  // 2. A heading: 💬 next to it
  for (const heading of main.querySelectorAll(HEADINGS)) {
    // The page's table of contents is built from the headings: keep its text
    heading.dataset.tocText ??= headingText(heading);
    const button = document.createElement('button');
    button.type = 'button';
    button.className = 'fb-heading';
    button.textContent = '💬';
    button.title = 'Feedback on this section';
    button.setAttribute('aria-label', 'Feedback on this section');
    button.addEventListener('click', (event) => {
      event.preventDefault();
      const section = heading.tagName === 'H1' ? { heading: null, argument: null } : sectionOf(heading);
      openForm(section, '');
    });
    heading.appendChild(button);
  }

  // 3. The page: a button at the bottom right
  const pageButton = document.createElement('button');
  pageButton.type = 'button';
  pageButton.className = 'fb-page btn btn-primary';
  pageButton.textContent = '💬 Feedback';
  pageButton.title = 'Feedback on this page (or select text, or use the 💬 next to a heading)';
  pageButton.addEventListener('click', () => openForm({ heading: null, argument: null }, ''));
  document.body.appendChild(pageButton);
};
// pkgdown loads this file in <head>: wait for the page
if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start);
else start();
})();
