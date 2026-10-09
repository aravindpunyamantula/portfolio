"use client";
import { useEffect, useRef, useState } from "react";
import OrbitFallback from "./OrbitFallback";
import * as THREE from "three";
import { RoomEnvironment } from "three/addons/environments/RoomEnvironment.js";

export default function ParticleScene({
  system = false,
  dark = false,
  dispersed = false,
  scrollDriven = true,
  model = "knot",
  onReady,
  onSettled,
}: {
  system?: boolean;
  dark?: boolean;
  dispersed?: boolean;
  scrollDriven?: boolean;
  model?: "knot" | "orbit";
  onReady?: () => void;
  onSettled?: () => void;
}) {
  const host = useRef<HTMLDivElement>(null);
  const callbacks = useRef({ onReady, onSettled });
  callbacks.current = { onReady, onSettled };
  const automatic = useRef(scrollDriven);
  automatic.current = scrollDriven;
  const settled = useRef(false);
  const mode = useRef(system);
  const darkMode = useRef(dark);
  const scatterMode = useRef(dispersed);
  const redraw = useRef<() => void>(() => {});
  const [failed, setFailed] = useState(false);
  useEffect(() => {
    mode.current = system;
    darkMode.current = dark;
    scatterMode.current = dispersed;
    settled.current = false;
    redraw.current();
  }, [system, dark, dispersed, failed]);
  useEffect(() => {
    const element = host.current;
    if (!element) return;
    let renderer: THREE.WebGLRenderer;
    try {
      renderer = new THREE.WebGLRenderer({
        alpha: true,
        antialias: true,
        powerPreference: "low-power",
      });
    } catch {
      setFailed(true);
      callbacks.current.onReady?.();
      callbacks.current.onSettled?.();
      return;
    }
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 1.7));
    renderer.setClearColor(0x000000, 0);
    renderer.toneMapping = THREE.ACESFilmicToneMapping;
    renderer.toneMappingExposure = 1.35;
    element.appendChild(renderer.domElement);
    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(38, 1, 0.1, 100);
    camera.position.set(0, 0.4, model === "orbit" ? 7.2 : 9.5);
    const pmrem = new THREE.PMREMGenerator(renderer);
    const room = new RoomEnvironment();
    const environment = pmrem.fromScene(room, 0.04);
    scene.environment = environment.texture;
    room.dispose();
    pmrem.dispose();
    scene.add(new THREE.AmbientLight(0xffffff, 2));
    const blueLight = new THREE.PointLight(0x184fff, 50);
    blueLight.position.set(3, 2, 4);
    scene.add(blueLight);
    const whiteLight = new THREE.DirectionalLight(0xffffff, 5);
    whiteLight.position.set(-3, 4, 5);
    scene.add(whiteLight);
    const group = new THREE.Group();
    scene.add(group);
    const knotGeo = new THREE.TorusKnotGeometry(1.36, 0.32, 240, 32, 2, 3);
    const metal = new THREE.MeshStandardMaterial({
      color: 0xeff2ff,
      metalness: 1,
      roughness: 0.18,
      transparent: true,
    });
    const knot = new THREE.Mesh(knotGeo, metal);
    group.add(knot);
    knot.visible = model !== "orbit";
    const orbitMeshes: THREE.Mesh<
      THREE.TorusGeometry,
      THREE.MeshBasicMaterial
    >[] = [];
    if (model === "orbit") {
      [0x9aafd1, 0x2454e6, 0xd2dbec].forEach((color, i) => {
        const mesh = new THREE.Mesh(
          new THREE.TorusGeometry(1.65, 0.13, 24, 160),
          new THREE.MeshBasicMaterial({
            color,
            transparent: true,
            toneMapped: false,
          }),
        );
        mesh.rotation.set(1.12, 0, [-0.61, 0.61, Math.PI / 2][i], "ZXY");
        group.add(mesh);
        orbitMeshes.push(mesh);
      });
    }
    const coreGeo = new THREE.IcosahedronGeometry(0.42, 1);
    const coreMat = new THREE.MeshStandardMaterial({
      color: 0x174cff,
      metalness: 0.55,
      roughness: 0.22,
    });
    const core = new THREE.Mesh(coreGeo, coreMat);
    group.add(core);
    core.visible = model !== "orbit";
    const count = window.innerWidth < 700 ? 2000 : 5000;
    const positions = new Float32Array(count * 3),
      base = new Float32Array(count * 3),
      targets = new Float32Array(count * 3),
      scattered = new Float32Array(count * 3);
    const colors = new Float32Array(count * 3);
    let seed = 41;
    const random = () => {
      seed = (seed * 1664525 + 1013904223) >>> 0;
      return seed / 4294967296;
    };
    for (let i = 0; i < count; i++) {
      const t = random() * Math.PI * 2,
        phi = random() * Math.PI * 2,
        radius = 1.72 + random() * 0.32;
      const x = (radius + 0.35 * Math.cos(phi)) * Math.cos(t),
        y = 0.35 * Math.sin(phi),
        z = (radius + 0.35 * Math.cos(phi)) * Math.sin(t);
      base.set([x, y, z], i * 3);
      positions.set([x, y, z], i * 3);
      const layer = i % 3;
      const a = random() * Math.PI * 2,
        r = Math.sqrt(random()) * 2.1;
      targets.set(
        [
          Math.cos(a) * r,
          (layer - 1) * 1.1 + (random() - 0.5) * 0.08,
          Math.sin(a) * r,
        ],
        i * 3,
      );
      const direction = new THREE.Vector3(x, y, z).normalize();
      const scatterRadius = 2.3 + random() * 1.6;
      scattered.set(
        [
          direction.x * scatterRadius + (random() - 0.5),
          direction.y * scatterRadius + (random() - 0.5) * 3,
          direction.z * scatterRadius + (random() - 0.5),
        ],
        i * 3,
      );
      const color = new THREE.Color(i % 6 === 0 ? 0x85bcff : 0x2454e6);
      colors.set([color.r, color.g, color.b], i * 3);
    }
    const particleGeo = new THREE.BufferGeometry();
    particleGeo.setAttribute(
      "position",
      new THREE.BufferAttribute(positions, 3),
    );
    particleGeo.setAttribute("color", new THREE.BufferAttribute(colors, 3));
    const particleMat = new THREE.PointsMaterial({
      size: 0.025,
      vertexColors: true,
      transparent: true,
      opacity: 0.85,
      depthWrite: false,
    });
    const particles = new THREE.Points(particleGeo, particleMat);
    group.add(particles);
    particles.rotation.x = 0.55;
    const rings: THREE.Mesh[] = [];
    const ringMat = new THREE.MeshBasicMaterial({
      color: 0x6689f5,
      transparent: true,
      opacity: 0.22,
    });
    for (let i = 0; i < 3; i++) {
      const ring = new THREE.Mesh(
        new THREE.TorusGeometry(2.15, 0.004, 8, 160),
        ringMat,
      );
      ring.rotation.x = Math.PI / 2;
      ring.position.y = (i - 1) * 1.1;
      group.add(ring);
      rings.push(ring);
    }
    const dustGeo = new THREE.BufferGeometry(),
      dust = new Float32Array(120 * 3);
    for (let i = 0; i < 120; i++)
      dust.set(
        [(random() - 0.5) * 9, (random() - 0.5) * 7, (random() - 0.5) * 6],
        i * 3,
      );
    dustGeo.setAttribute("position", new THREE.BufferAttribute(dust, 3));
    const dustMat = new THREE.PointsMaterial({
      color: 0x5478df,
      size: 0.015,
      transparent: true,
      opacity: 0.55,
    });
    scene.add(new THREE.Points(dustGeo, dustMat));
    const shadowGeo = new THREE.CircleGeometry(1.65, 64),
      shadowMat = new THREE.MeshBasicMaterial({
        color: 0x294083,
        transparent: true,
        opacity: 0.045,
      });
    const shadow = new THREE.Mesh(shadowGeo, shadowMat);
    shadow.rotation.x = -Math.PI / 2;
    shadow.position.y = -2.1;
    scene.add(shadow);
    shadow.visible = model !== "orbit";
    const reduced = window.matchMedia("(prefers-reduced-motion: reduce)");
    let frame = 0,
      visible = true,
      destroyed = false,
      blend = 0,
      scatter = 0,
      pointerX = 0,
      pointerY = 0;
    let ready = false;
    const start = performance.now();
    const render = () => {
      frame = 0;
      if (destroyed || document.hidden || (!visible && settled.current)) return;
      const t = reduced.matches ? 0 : (performance.now() - start) / 1000;
      const rect = element.getBoundingClientRect();
      const scroll = Math.max(0, Math.min(1, -rect.top / window.innerHeight));
      const desired = mode.current
        ? 1
        : automatic.current
          ? Math.min(1, scroll * 1.8)
          : 0;
      blend = reduced.matches
        ? mode.current
          ? 1
          : 0
        : THREE.MathUtils.lerp(blend, desired, 0.065);
      scatter = reduced.matches
        ? scatterMode.current
          ? 1
          : 0
        : THREE.MathUtils.lerp(scatter, scatterMode.current ? 1 : 0, 0.055);
      for (let i = 0; i < positions.length; i++) {
        const assembled = base[i] * (1 - blend) + targets[i] * blend;
        positions[i] = assembled * (1 - scatter) + scattered[i] * scatter;
      }
      particleGeo.attributes.position.needsUpdate = true;
      particleMat.size = 0.025 + scatter * 0.009;
      metal.opacity = (1 - blend * 0.94) * (1 - scatter);
      orbitMeshes.forEach((mesh, i) => {
        mesh.material.opacity = 1 - scatter;
        mesh.rotation.x = 1.12;
        mesh.rotation.z = [-0.61, 0.61, Math.PI / 2][i] * (1 - blend);
        mesh.position.y = (i - 1) * 1.1 * blend;
        mesh.scale.setScalar(1 - blend * 0.15);
      });
      if (model === "orbit")
        particleMat.opacity = Math.max(scatter, blend * 0.5);

      knot.scale.setScalar(1 - blend * 0.18);
      knot.rotation.set(t * 0.07, 0.35 + t * 0.12, 0.25);
      core.rotation.set(t * 0.2, t * 0.3, t * 0.1);
      core.scale.setScalar(1 + blend * 0.3 - scatter * 0.45);
      group.rotation.x = THREE.MathUtils.lerp(
        group.rotation.x,
        0.22 + pointerY * 0.18,
        0.04,
      );
      group.rotation.y = THREE.MathUtils.lerp(
        group.rotation.y,
        pointerX * 0.25 +
          (model === "orbit" ? Math.sin(t * 0.3) * 0.08 : t * 0.035),
        0.04,
      );
      group.position.y = Math.sin(t * 0.7) * 0.06 + scroll * 0.35;
      particles.rotation.x = 0.5 * (1 - blend);
      particles.rotation.y = t * 0.045;
      rings.forEach((ring, i) => {
        ring.visible = blend > 0.03 && scatter < 0.6;
        ring.scale.setScalar(0.9 + 0.1 * blend);
        ring.position.y = (i - 1) * 1.1 * blend;
      });
      dustMat.color.set(darkMode.current ? 0x9ebcff : 0x5478df);
      renderer.render(scene, camera);
      if (!ready) {
        ready = true;
        callbacks.current.onReady?.();
      }
      if (
        !settled.current &&
        Math.abs(blend - desired) < 0.003 &&
        Math.abs(scatter - (scatterMode.current ? 1 : 0)) < 0.003
      ) {
        settled.current = true;
        element.dataset.renderedView = mode.current ? "blueprint" : "product";
        element.dataset.renderedDispersed = String(scatterMode.current);
        callbacks.current.onSettled?.();
      }
      if (!reduced.matches) frame = requestAnimationFrame(render);
    };
    const request = () => {
      if (!frame && !destroyed) frame = requestAnimationFrame(render);
    };
    redraw.current = request;
    const resize = () => {
      const { width, height } = element.getBoundingClientRect();
      if (!width || !height) return;
      renderer.setSize(width, height);
      camera.aspect = width / height;
      camera.updateProjectionMatrix();
      request();
    };
    const onPointer = (e: PointerEvent) => {
      if (reduced.matches) return;
      const rect = element.getBoundingClientRect();
      pointerX = (e.clientX - rect.left) / rect.width - 0.5;
      pointerY = (e.clientY - rect.top) / rect.height - 0.5;
    };
    const onLeave = () => {
      pointerX = 0;
      pointerY = 0;
    };
    const onVisibility = () => {
      if (document.hidden) {
        cancelAnimationFrame(frame);
        frame = 0;
      } else request();
    };
    const observer = new IntersectionObserver(([entry]) => {
      visible = entry.isIntersecting;
      if (visible) request();
      else {
        cancelAnimationFrame(frame);
        frame = 0;
      }
    });
    observer.observe(element);
    const resizer = new ResizeObserver(resize);
    resizer.observe(element);
    element.addEventListener("pointermove", onPointer);
    element.addEventListener("pointerleave", onLeave);
    document.addEventListener("visibilitychange", onVisibility);
    reduced.addEventListener("change", request);
    const onContextLost = (e: Event) => {
      e.preventDefault();
      setFailed(true);
      callbacks.current.onSettled?.();
      cancelAnimationFrame(frame);
    };
    renderer.domElement.addEventListener("webglcontextlost", onContextLost);
    resize();
    request();
    return () => {
      destroyed = true;
      cancelAnimationFrame(frame);
      observer.disconnect();
      resizer.disconnect();
      element.removeEventListener("pointermove", onPointer);
      element.removeEventListener("pointerleave", onLeave);
      document.removeEventListener("visibilitychange", onVisibility);
      reduced.removeEventListener("change", request);
      renderer.domElement.removeEventListener(
        "webglcontextlost",
        onContextLost,
      );
      scene.traverse((obj) => {
        if (obj instanceof THREE.Mesh || obj instanceof THREE.Points) {
          obj.geometry.dispose();
          const materials = Array.isArray(obj.material)
            ? obj.material
            : [obj.material];
          materials.forEach((m) => m.dispose());
        }
      });
      environment.texture.dispose();
      environment.dispose();
      renderer.dispose();
      renderer.domElement.remove();
      redraw.current = () => {};
    };
  }, []);
  return (
    <div ref={host} className="particle-scene" aria-hidden="true">
      {failed && (
        <OrbitFallback
          system={system}
          dispersed={dispersed}
          onSettled={() => {
            if (host.current) {
              host.current.dataset.renderedView = system
                ? "blueprint"
                : "product";
              host.current.dataset.renderedDispersed = String(dispersed);
            }
            callbacks.current.onSettled?.();
          }}
        />
      )}
    </div>
  );
}
