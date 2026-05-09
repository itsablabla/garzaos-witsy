import '@css/index.css';
import '@css/form.css';
import '@css/panel.css';
import './renderer/web.css';

const app = document.querySelector<HTMLDivElement>('#app');

if (app) {
  app.innerHTML = `
    <main class="web-home">
      <section class="web-hero" aria-labelledby="web-title">
        <img class="web-logo" src="./assets/icon.png" alt="" />
        <p class="web-eyebrow">Witsy Web Preview</p>
        <h1 id="web-title">Witsy is an AI desktop assistant.</h1>
        <p class="web-subtitle">
          The full Witsy experience runs as a cross-platform Electron app with local desktop integration,
          provider configuration, MCP tools, voice, document search, and automation features.
        </p>
        <div class="web-actions">
          <a class="web-button web-button-primary" href="https://github.com/nbonamy/witsy" rel="noreferrer">View project</a>
          <a class="web-button web-button-secondary" href="https://github.com/nbonamy/witsy/releases" rel="noreferrer">Download desktop app</a>
        </div>
      </section>
      <section class="web-card" aria-labelledby="web-deployment-title">
        <h2 id="web-deployment-title">Static deployment is healthy</h2>
        <p>
          This nginx-hosted page is intentionally browser-safe and does not load the Electron renderer or preload API.
        </p>
      </section>
    </main>
  `;
}
