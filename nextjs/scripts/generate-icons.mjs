import { mkdir, writeFile } from "node:fs/promises";
import { createRequire } from "node:module";
import { resolve } from "node:path";
const require = createRequire(import.meta.url);
const sharp = require("sharp");
const publicDir = resolve(import.meta.dirname, "../public");
await mkdir(resolve(publicDir, "icons"), { recursive: true });
// Drawn as paths so every size keeps the same italic serif A without a font dependency.
const mark = (maskable = false) =>
  `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><rect width="512" height="512" rx="${maskable ? 0 : 48}" fill="#05265b"/><g ${maskable ? 'transform="translate(51.2 51.2) scale(.8)"' : ""}><path fill="#fffdf8" fill-rule="evenodd" d="M90 402L104 386L134 378L292 128L272 115L380 108L363 130L382 375L414 385L425 402H284L292 386L316 377L312 316H204L167 376L199 387L188 402ZM222 283H310L304 161Z"/></g></svg>`;
await writeFile(resolve(publicDir, "favicon.svg"), mark());
await writeFile(resolve(publicDir, "icons/monogram.svg"), mark());
const sizes = [
  16, 32, 48, 64, 96, 128, 144, 152, 167, 180, 192, 256, 384, 512, 1024,
];
for (const size of sizes)
  await sharp(Buffer.from(mark()))
    .resize(size, size)
    .png()
    .toFile(resolve(publicDir, `icons/icon-${size}.png`));
for (const size of [192, 512])
  await sharp(Buffer.from(mark(true)))
    .resize(size, size)
    .png()
    .toFile(resolve(publicDir, `icons/maskable-${size}.png`));
await sharp(Buffer.from(mark()))
  .resize(180, 180)
  .png()
  .toFile(resolve(publicDir, "icons/apple-touch-icon.png"));
await sharp(Buffer.from(mark()))
  .resize(32, 32)
  .png()
  .toFile(resolve(publicDir, "favicon.png"));
const images = await Promise.all(
  [16, 32, 48].map((size) =>
    sharp(Buffer.from(mark())).resize(size, size).png().toBuffer(),
  ),
);
const header = Buffer.alloc(6);
header.writeUInt16LE(1, 2);
header.writeUInt16LE(images.length, 4);
let offset = 6 + images.length * 16;
const entries = images.map((image, i) => {
  const size = [16, 32, 48][i],
    entry = Buffer.alloc(16);
  entry[0] = size;
  entry[1] = size;
  entry.writeUInt16LE(1, 4);
  entry.writeUInt16LE(32, 6);
  entry.writeUInt32LE(image.length, 8);
  entry.writeUInt32LE(offset, 12);
  offset += image.length;
  return entry;
});
await writeFile(
  resolve(publicDir, "favicon.ico"),
  Buffer.concat([header, ...entries, ...images]),
);
// Keep previous URLs working for cached manifests and existing bookmarks.
for (const [name, size, mask] of [
  ["Icon-192.png", 192, false],
  ["Icon-512.png", 512, false],
  ["Icon-maskable-192.png", 192, true],
  ["Icon-maskable-512.png", 512, true],
])
  await sharp(Buffer.from(mark(mask)))
    .resize(size, size)
    .png()
    .toFile(resolve(publicDir, "icons", name));
console.log("Generated the A monogram, ICO, iOS, Android, and maskable icons.");
