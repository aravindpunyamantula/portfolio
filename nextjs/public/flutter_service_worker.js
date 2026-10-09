// Retire the Flutter worker when an existing visitor receives this deployment.
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    for (const key of ['flutter-app-cache', 'flutter-temp-cache', 'flutter-app-manifest']) {
      await caches.delete(key);
    }
    await self.registration.unregister();
    const windows = await self.clients.matchAll({ type: 'window' });
    for (const window of windows) await window.navigate(window.url);
  })());
});
