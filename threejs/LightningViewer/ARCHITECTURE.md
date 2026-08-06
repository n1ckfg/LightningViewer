# LightningViewer Architecture

LightningViewer is a lightweight, web-based 3D animation viewer built with HTML5, JavaScript, and Three.js. It is designed to load, parse, and render 3D grease-pencil animations exported from Lightning Artist (usually as `.latk` or `.json` files).

## Core Technologies

*   **HTML5/CSS3**: Provides the foundational structure and full-window canvas container.
*   **Three.js**: The core 3D rendering engine used to draw the strokes, manage the scene, camera, and handle the render loop.
*   **latk.js**: The standard Lightning Artist Toolkit library (`js/libraries/latk/latk.js`). It owns all file reading and the animation data model. JSZip is bundled inside it, so `.latk` archives are handled without a separate ZIP dependency.
*   **THREE.MeshLine**: A specialized Three.js extension used to render thick lines (strokes) since native WebGL lines have a maximum thickness limitation.

## Application Structure

The application is largely a single-page application (SPA) with logic centralized in `index.html` and supporting modules in the `js/` directory.

### 1. `index.html` (Main Entry Point)

This file contains the setup, rendering loop, and the bridge from latk.js data to Three.js geometry. It holds no `.latk` parsing logic of its own.

*   **Data Structures**: None of its own. The animation lives in a single global `Latk` instance named `latk`, made of latk.js `LatkLayer` / `LatkFrame` / `LatkStroke` / `LatkPoint` objects. The name must stay `latk`, because `Latk.jsonToGp()` reads its options (`yUp`, `useScaleAndOffset`) from that global.
*   **Loading (`loadLatk`, `loadLatkFile`)**:
    *   `loadLatk(path)` calls `Latk.read(path)`, which handles both zipped `.latk` and plain `.json` URLs and flips `latk.ready` when done.
    *   `loadLatkFile(file)` handles drag-and-drop. A dropped `.json` is parsed and handed to `latk.readJson()`; a dropped `.latk` is unzipped with the JSZip bundled in latk.js, then handed to the same `latk.readJson()`.
    *   Both first replace `latk` with a fresh, not-yet-ready instance, so the render loop cannot rebuild against the previous animation while the new one loads.
*   **Geometry (`buildFrames`)**: Runs once `latk.ready` is set. For each stroke it scales and offsets the points (`laScale`, `laOffset`), builds a `THREE.Geometry`, wraps it in a `MeshLine`, and assigns a material from a deduplicated color palette. The resulting per-frame mesh lists are stored on each `LatkLayer` as `meshFrames`, alongside the `counter` / `loopCounter` fields latk.js already provides for playback.
*   **Animation Loop (`draw`)**:
    *   Maintains a fixed framerate (default 12 FPS) using a delta-time accumulator.
    *   Advances each layer's `counter` and swaps the scene contents to the meshes for the active frame.
*   **Export (`writeJson`)**: Serializes `latk.layers` back to Lightning Artist JSON. Because it reads the latk.js data model directly, it writes the original point data rather than reversing the scale and offset baked into the Three.js geometry.

Note: latk.js also exposes `Latk.write()`, `getLongestLayer()`, and `roundVal()`, but those methods are currently non-functional in the library, so the viewer keeps local equivalents.

### 2. Input and Camera Controllers (`js/`)

The application implements a custom first-person camera control system split across several files:

*   **`threejs-wasd.js`**:
    *   Listens for keyboard events (W, A, S, D, Q, E).
    *   Translates the camera forward, backward, left, right, up, and down based on a smoothed velocity (`movingSpeed` and `movingDelta`).
*   **`threejs-mouse.js`**:
    *   Implements a drag-to-look mechanic (or pointer-lock based look).
    *   Translates mouse/touch movement into Eulerian angles (Pitch/Yaw) to rotate the camera view.
*   **`threejs-util.js`**:
    *   Provides Three.js specific utilities, such as clearing the scene safely (disposing of geometries and materials to prevent memory leaks) and handling window resize events to update the camera aspect ratio and renderer size.
*   **`general-util.js`**:
    *   Contains generic math functions (lerp, distance, map, clamp), random number generators, and browser utilities like saving images or reading URL queries.

## Data Flow

1.  **Input**: A `.latk` or `.json` file is loaded from `animationPath`, or drag-and-dropped onto the browser window.
2.  **Reading**: latk.js does the work — `Latk.read()` for a URL, or `latk.readJson()` after the viewer unzips a dropped `.latk`. Either way `Latk.jsonToGp()` walks the `grease_pencil` array and produces `LatkLayer` → `LatkFrame` → `LatkStroke` → `LatkPoint` objects, and sets `latk.ready`.
3.  **Geometry Generation**: `buildFrames()` turns each stroke's points into a `THREE.Geometry`, wraps it in a `MeshLine`, and assigns a palette material matching the stroke color.
4.  **Rendering**: `renderer.setAnimationLoop(draw)` runs continuously. Depending on the elapsed time, the scene is cleared of the previous frame's strokes and populated with the current frame's strokes.
