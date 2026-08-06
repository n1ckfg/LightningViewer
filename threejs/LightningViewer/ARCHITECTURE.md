# LightningViewer Architecture

LightningViewer is a lightweight, web-based 3D animation viewer built with HTML5, JavaScript, and Three.js. It is designed to load, parse, and render 3D grease-pencil animations exported from Lightning Artist (usually as `.latk` or `.json` files).

## Core Technologies

*   **HTML5/CSS3**: Provides the foundational structure and full-window canvas container.
*   **Three.js**: The core 3D rendering engine used to draw the strokes, manage the scene, camera, and handle the render loop.
*   **JSZip**: A library used to handle `.latk` files, which are ZIP archives containing JSON data.
*   **THREE.MeshLine**: A specialized Three.js extension used to render thick lines (strokes) since native WebGL lines have a maximum thickness limitation.

## Application Structure

The application is largely a single-page application (SPA) with logic centralized in `index.html` and supporting modules in the `js/` directory.

### 1. `index.html` (Main Entry Point)

This file contains the primary setup, rendering loop, and data parsing logic.
*   **Data Structures**: Defines a `Layer` class to hold stroke coordinates (X, Y, Z), colors, and frame sequences.
*   **Loading & Parsing (`jsonToGp`)**: 
    *   Accepts Drag-and-Drop files.
    *   If a `.latk` file is dropped, `JSZip` extracts the underlying JSON.
    *   The JSON is parsed into `Layer` objects. 
    *   Coordinates are scaled and offset, and Three.js `MeshLine` geometries are created for each stroke.
*   **Animation Loop (`draw`)**: 
    *   Maintains a fixed framerate (default 12 FPS) using a delta-time accumulator.
    *   Advances the current frame index and updates the scene to display only the strokes for the active frame.
*   **Export (`writeJson`)**: Allows the currently loaded animation to be re-exported/saved as a JSON file.

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

1.  **Input**: User drag-and-drops a `.latk` or `.json` file onto the browser window.
2.  **Extraction**: `JSZip` reads the binary content and extracts the JSON string (if `.latk`).
3.  **Parsing**: The JSON string is parsed. The `grease_pencil` array is iterated over to extract layers, frames, strokes, and individual 3D points.
4.  **Geometry Generation**: For each stroke, a `THREE.Geometry` is populated with vertices. It is then wrapped in a `THREE.MeshLine` and assigned a material (with color matching the JSON data).
5.  **Rendering**: The `requestAnimationFrame` loop continually calls `renderer.render(scene, camera)`. Depending on the elapsed time, the scene is cleared of the previous frame's strokes and populated with the current frame's strokes.
