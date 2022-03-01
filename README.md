# Graphite

Graphite is a FPGA based open source 3D graphics accelerator.

## Features

- Draw line;
- Draw textured triangle.

## Requirements

- SDL2
- Verilator 4.213 or above

## Getting Started
```bash
git clone https://github.com/dcliche/graphite.git
cd graphite/rtl/sim
make run
```

- Press 1 to select the cube model;
- Press 2 to select the teapot model;
- Press W/A/S/D and arrows to move the camera;
- Press SPACE to start/stop the rotation of the model;
- Press TAB to enable/disable the wireframe mode;
- Press T to enable/disable texture mapping;
- Press L to enable/disable lighting.
