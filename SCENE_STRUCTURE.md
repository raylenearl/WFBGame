# WFBGame Scene Structure Documentation

## Overview
This document defines the expected node hierarchy and configuration for the WFBGame project.

## Root Scene Hierarchy

```
Main (Node2D) [Main.gd]
├── Ball (CharacterBody2D) [Ball.gd]
│   ├── CollisionShape2D
│   └── Sprite2D (or ColorRect for testing)
│
├── Player (CharacterBody2D) [Player.gd] - Quarterback (QB)
│   ├── CollisionShape2D
│   └── Sprite2D (blue team color)
│
├── RunningBack (CharacterBody2D) [RunningBack.gd] - RB
│   ├── CollisionShape2D
│   └── Sprite2D (red team color)
│
├── Receiver (CharacterBody2D) [Receiver.gd] - Wide Receiver (WR)
│   ├── CollisionShape2D
│   └── Sprite2D (green team color)
│
├── Camera2D [Camera.gd]
│   └── (Configured to follow Player)
│
├── CanvasLayer
│   └── DebugUI (Label) [DebugUI.gd]
│       └── (Displays game stats and controls)
│
└── Environment nodes (optional)
    ├── Field background (ColorRect or Sprite2D)
    ├── Boundaries (StaticBody2D or Area2D for field limits)
    └── Markers (Position2D for key locations)
```

## Node Configuration Details

### Main (Root)
- **Type**: Node2D
- **Script**: Main.gd
- **Purpose**: Scene coordinator, initializes camera following
- **Properties**:
  - Position: (0, 0)
  - Visible: true

### Ball
- **Type**: CharacterBody2D
- **Script**: Ball.gd
- **Purpose**: The football object
- **Components**:
  - **CollisionShape2D**: CircleShape2D (radius ~15 pixels)
  - **Sprite2D**: Brown/football colored or simple circle for testing
- **Properties**:
  - Position: (500, 300) - Starting position (center of field)
  - Collision Layer: 1 (disabled in Player.gd code)
  - Collision Mask: 1 (disabled in Player.gd code)

### Player (QB)
- **Type**: CharacterBody2D
- **Script**: Player.gd
- **Purpose**: Quarterback - player controlled
- **Components**:
  - **CollisionShape2D**: RectangleShape2D or CapsuleShape2D
  - **Sprite2D**: Blue colored (represents QB)
- **Properties**:
  - Position: (300, 300) - Start left side
  - Collision Layer: 1 (disabled)
  - Collision Mask: 1 (disabled)
  - Modulate Color: (0.5, 0.5, 1.0) - Blue tint

### RunningBack (RB)
- **Type**: CharacterBody2D
- **Script**: RunningBack.gd
- **Purpose**: Running back - secondary player
- **Components**:
  - **CollisionShape2D**: RectangleShape2D or CapsuleShape2D
  - **Sprite2D**: Red colored (represents RB)
- **Properties**:
  - Position: (400, 350) - Start lower left
  - Collision Layer: 1 (disabled)
  - Collision Mask: 1 (disabled)
  - Modulate Color: (0.6, 0.3, 0.3) - Red tint

### Receiver (WR)
- **Type**: CharacterBody2D
- **Script**: Receiver.gd
- **Purpose**: Wide receiver - target for throws
- **Components**:
  - **CollisionShape2D**: RectangleShape2D or CapsuleShape2D
  - **Sprite2D**: Green colored (represents WR)
- **Properties**:
  - Position: (700, 250) - Start right side
  - Collision Layer: 1 (disabled)
  - Collision Mask: 1 (disabled)
  - Modulate Color: (0.3, 0.6, 0.3) - Green tint

### Camera2D
- **Type**: Camera2D
- **Script**: Camera.gd
- **Purpose**: Follows the Player (QB)
- **Properties**:
  - Enabled: true
  - Zoom: (0.8, 0.8)
  - Make Current: true (set in _ready())
  - Smoothing: optional (can add for better UX)

### DebugUI (Label)
- **Type**: Label
- **Script**: DebugUI.gd
- **Parent**: CanvasLayer (so it appears on top)
- **Purpose**: Display real-time game stats and controls
- **Properties**:
  - Offset Left: 10
  - Offset Top: 10
  - Font Size: 14
  - Text: Updated each frame with game information

### CanvasLayer
- **Type**: CanvasLayer
- **Purpose**: Renders UI on top of game world
- **Properties**:
  - Layer: 1

## Setup Instructions

### 1. Create the Main Scene
1. Create a new Node2D scene, save as `main.tscn`
2. Rename root node to "Main"
3. Attach `Main.gd` script to Main node

### 2. Create Player Nodes
For each of Player, RunningBack, Receiver:
1. Add CharacterBody2D as child of Main
2. Add CollisionShape2D as child (set shape to CircleShape2D or CapsuleShape2D)
3. Add Sprite2D as child (use colored squares/circles or sprites)
4. Attach corresponding script (Player.gd, RunningBack.gd, Receiver.gd)
5. Set node names exactly as referenced in scripts

### 3. Create Ball
1. Add CharacterBody2D as child of Main
2. Name it "Ball"
3. Add CollisionShape2D with CircleShape2D
4. Add Sprite2D (brown/tan color)
5. Attach Ball.gd script

### 4. Setup Camera
1. Add Camera2D as child of Main
2. Attach Camera.gd script
3. Set Camera2D properties (enabled, make_current in _ready)

### 5. Setup UI
1. Add CanvasLayer as child of Main
2. Add Label as child of CanvasLayer
3. Name it "DebugUI"
4. Attach DebugUI.gd script
5. Set label properties (offset, font size)

### 6. Input Map
Configure input actions in Project > Project Settings > Input Map:
- move_left (A key)
- move_right (D key)
- move_up (W key)
- move_down (S key)
- sprint (Shift key)
- pick_up (E key)
- drop (Q key)
- handoff (F key)
- throw (Space key)

See INPUT_MAP.md for details.

## Node Path References

Scripts reference nodes using `get_node()` with these paths:
- Ball: `get_parent().get_node("Ball")`
- Player (QB): `get_parent().get_node("Player")`
- RunningBack: `get_parent().get_node("RunningBack")`
- Receiver: `get_parent().get_node("Receiver")`
- DebugUI: `get_parent().get_node("DebugUI")` or via CanvasLayer

**Important**: Node names must match exactly as referenced in scripts!

## Collision Configuration

All player nodes have collision disabled:
```gdscript
set_collision_layer_value(1, false)
set_collision_mask_value(1, false)
```

This prevents physics collisions. If you add a Defense team or obstacles later, update collision settings.

## Testing Checklist

- [ ] All nodes present with correct names
- [ ] Scripts attached to correct nodes
- [ ] Input actions configured
- [ ] Game runs without errors
- [ ] Camera follows Player (QB)
- [ ] DebugUI displays on screen
- [ ] Player can move with WASD
- [ ] Controls respond to inputs

## Color Reference

- **Player (QB)**: Light Blue (0.5, 0.5, 1.0)
- **RunningBack (RB)**: Light Red (0.6, 0.3, 0.3)
- **Receiver (WR)**: Light Green (0.3, 0.6, 0.3)
- **Ball**: Brown or tan

When controllable, colors brighten:
- **QB Active**: (0.5, 0.5, 1.0)
- **RB Active**: (1.0, 0.5, 0.5)
- **WR Active**: (0.5, 1.0, 0.5)
