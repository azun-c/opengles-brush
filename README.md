# opengles-brush
A simple standalone OpenGL ES app for brush stroke

- Version 1: Pure OpenGL ES version was committed with the hash: [1451ec8](https://github.com/azun-c/opengles-brush/commit/151abd9cb14c665706e10852771e8b1e653c0b79)
  - Note the background text: "OpenGL ES"
- Version 2: OpenGL ES migrated to Metal since the commit [151abd9](https://github.com/azun-c/opengles-brush/commit/b05a859fd6b381cb862d500f8081a50900b8b868).
  - Note the background text: "OpenGL ES to Metal"
  - This version we can turn on/off Metal migration or can configure to use either OpenGL ES or Metal drawings alternatively for specific timespans (5 seconds each)

---
### How does the current OpenGL ES draw a dot (circle) with a specific color?

- For example:

  https://github.com/azun-c/opengles-brush/assets/114891397/61b744a3-b967-4933-919c-882f2e8e0d37

- First, when tapped, depends on how big the brush size is, the app will determine a square at the tapped location.
  - Note: at this time, the square has not been painted with a color yet - the pink color just to show the shape

  ![square-dot](https://github.com/azun-c/opengles-brush/assets/114891397/ca562f0a-2078-48dd-a535-304b040af8eb)


- Then, the shape will be filled with a corresponding texture( or image) (textures are located [here](https://github.com/azun-c/opengles-brush/tree/main/opengles-brush/textures))

  ![square-with-texture](https://github.com/azun-c/opengles-brush/assets/114891397/fad0754e-1aa5-49fe-9648-ef584c538de3)


- Note that: the texture has only 2 colors: white at the center and black at edges and borders. Next, the texture will be processed(or redrawn) with the target color. By mapping:
  - White pixel -> target color pixel
  - Black pixel -> transparent pixel
  
  <img width="300" alt="texture-processing" src="https://github.com/azun-c/opengles-brush/assets/114891397/d7902502-cae9-49ea-ab85-2498b5966e4b">

- Final result:
  
  <img width="300" alt="texture-final-result" src="https://github.com/azun-c/opengles-brush/assets/114891397/6ea915a9-d525-429a-a01f-e0f92ea19ea9">

- And a curve line is just a series of `soft` dots that partially overlap when tapped and moved the finger on the screen.

### Rendering method: Offscreen rendering (aka Drawing to texture, Rendering to texture):

- The app uses a rendering method called [Offerscreen rendering](https://microsoft.github.io/Win2D/WinUI3/html/Offscreen.htm#:~:text=Apps%20occasionally%20need%20to%20draw,%22drawing%20to%20a%20texture%22.)

- Instead of rendering straight to the screen, it's storing the results in a texture. There are a couple of advantages of this method. Two on top advantages are:
  - The app will later need to access(read) the rendering data for storing purpose. However, the screen buffer data is a WRITE only buffer. We can only write the data for displaying to it, but cannot read the rendered data
  - When displaying to screen, there should be some `heavy` tasks because it's related to display, screens, I/O, etc. In the meantime, if we render directly to screen (buffer), including the preprocessing pixels(calcuations, translations, color transformations, blending, etc.), will result in a bad experience or an intermittent failure.
- So offscreen rendering manages a couple of offscreen buffers, all the computations are done and pixels are drawn on those buffers first, the final buffer holds the rendering data (which is similar to a texture, or an image). And the final step, we just need to write the exact pixels of the texture to the screen buffer. No more heavy tasks related to rendering pixels.
- ![Offscreen-rendering](https://github.com/azun-c/opengles-brush/assets/114891397/a9a559d3-6447-45e3-afa3-f6a66fab3341)
  - For example, with the current state, there is already a blue circle of the top left of screen, we tap in the middle of the screen to draw another red circle.
  - At that point, the offscreen buffer(also the offscreen texture) store `an image` of the current screen state. Then it we manages to render the red circle after a couple of rendering steps
  - At the end of the drawing frame(a drawing loop), we copy the final buffer's texture to the screen buffer for displaying
  - Begining a new drawing frame, the offscreen buffer now consists of 2 separate circles
  - When saving, we can read the offscreen texture's pixels the store as how we want

- For the OpenGL app, we can see that it has 2 objects: `_m_onScreen` and `m_offScreen`. Which stand for screen buffer and offscreen buffer.

### Rendering pipeline: 
- Source: ([OpenGL_ES_2.0_Programming_Guide - Page 37/457](https://usermanual.wiki/Pdf/OpenGL20ES202020Programming20Guide.197713012/view))
  ![pipeline](https://github.com/azun-c/opengles-brush/assets/114891397/447cfcdc-c6b3-4093-8d9a-c6e189db4c89)


- Let's dive into a bit. Let's focus on the stages with items marked as red number inside red circle. To easily imagine, I put sample data and result for each stage according to the OpenGL brush stroke app beside the stage items.
  - (1) Vertex Arrays/ Buffer Objects: In general, graphics libraries will work with simple geometries, called primities. They are points(formed by 1 vertex), lines(formed by 2 vertices), triangles(formed by 3 vertices). So our job is to translate our shapes into prmities, which are in turn defined by a set of vertices.
    - Especially, in the app, when rendering a single circle, it first renders a square. Let's "simply" think that drawing a square is equal to drawing 2 triangles: the first triangle has 3 vertices (v0, v1, v2), the second triangle has 3 vertices(v3, v4, v5), and v3 is exactly the same as v0, v4 is exactly the same as v2. (No spacing between 2 triangles)
    - So the vertex array should be fetched with 6 vertices. (In reality, there are actually 18 vertices in this case :D, but not much different)
  - (2) Vertex Shader: This is a sub-routine, a small program, for processing every vertex from the vertex arrays. Its major responsibility is to map the position of each to the proper location in the drawing surface. And there may be some other processing if needed(such translations, scale, etc.)
    - The parameter is a vertex, passed from the vertex arrays.
  - (3) Primities Assembly: Based on the primity type (point, line, triangle), at this stage, a set of processed vertices, which are the outputs of stage 2, be reassembled into a corresponding primity.
    - For example: If we're about to draw lines, then the `Primities Assembly` will be waiting until it receives 2 processed vertices in order to reassemble into a line. Similarly, for triangles, after `Vertex Shader` outputs 3 vertices, then the `Primities Assembly` will reassemble into a triangle.
    - In our case, the vertex array has 6 vertices (v0,.., v5), once the vertex shader finishes processing 3 vertices (v0, v1, v2), output as (v00, v11, v22) (into primities assembly buffer), the prmities assembly will reassemble into a triangle, before passing to the next stage.
    - Note: This stage is a hidden stage. We have no control over it.
  - (4) Rasterization: At this stage, we have a primity(according to its vertices). To make a primity visible, we need to allocate colors to it by setting color to every single pixel belonging to the primity. However, we only have the pixel positions of very few vertices (i.e.: 3 for triangle), how can we determine if a pixel is inside or outside of the primity? This is the reason that the Rasterization comes into place. [Rasterization](https://www.khronos.org/opengl/wiki/Rasterization) is the process whereby each individual Primitive is broken down into discrete elements called Fragments. These fragments will be in turn fetched to the stage, called `Fragment Shader`.
    - Note: This stage is a hidden stage. We have no control over it.
 - (5) Texture Memory: This is where textures are stored, so that they can be used as samplers (in `Fragment Shader`), contributing to detemine the target color of a pixel.
 - (6) Fragment Shader: 
