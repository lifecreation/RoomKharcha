// Chhota service worker: app install ho sake, aur net na ho to last dekha hua page khule.
// Hamesha pehle network se naya page leta hai, isliye purana version atakta nahi.
self.addEventListener("install", () => self.skipWaiting());
self.addEventListener("activate", e => e.waitUntil(self.clients.claim()));
self.addEventListener("fetch", e => {
  const req = e.request;
  if (req.method !== "GET" || new URL(req.url).origin !== self.location.origin) return;
  e.respondWith(
    fetch(req)
      .then(res => { const copy = res.clone(); caches.open("rk-shell").then(c => c.put(req, copy)); return res; })
      .catch(() => caches.match(req))
  );
});
