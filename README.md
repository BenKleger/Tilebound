# Tilebound
A systems-driven isometric action prototype featuring procedural level generation, tile-based traversal, and emergent combat interactions built in Godot.

## Overview
Tilebound explores isometric movement and combat systems with a focus on procedural environments, physics-driven interactions, and deterministic gameplay behavior.

The goal is to build a flexible foundation for experimenting with traversal, combat mechanics, and emergent system interactions in a modular architecture.


# Core Systems

## Procedural Level Generation
Generates tile-based isometric levels at runtime
Supports traversal constraints and fall-off regions
Designed for modular expansion of room types and layout systems

## Movement System
Full 8-direction isometric movement
Coyote-time
Input buffering for responsiveness
Supports air control, dash, and directional momentum

## Combat Systems
Projectile-based weapon system with physics-driven interactions
Grapple/interactable object mechanics
Deterministic enemy behavior logic

## Weapon Accuracy System
Shots are aimed toward the mouse position with controlled angular/positional variance
Accuracy stat determines deviation from intended aim vector
Enables balancing between precision weapons and high-spread weapon archetypes
Supports future scaling for progression and status effects

## Entity Logic / AI
### Enemy Targeting System
Enemies use radius-based perception for player engagement
Player entering detection radius triggers state transitions
Enemies transition between idle → alert → engaged states based on proximity
Designed for future expansion into line-of-sight or stealth systems
### Additional Behavior Systems
Modular enemy behavior design
Data-driven attack patterns (where applicable)
Rule-based interaction logic for consistent simulation behavior

## Design Goals
Build system-first gameplay architecture
Emphasize emergent behavior from simple rule interactions
Keep systems modular and reusable
Explore interactions between traversal, physics, and combat in isometric space

## Tech Stack
Godot Engine
GDScript

## Controls
WASD / Arrow Keys – Move | Shift – Dash | Space - Jump | E - Grapple | Left Mouse Button – Attack

## Screenshots
<img width="634" height="424" alt="{6BDCB99A-E7C8-45B9-8E16-13C69E6C67C4}" src="https://github.com/user-attachments/assets/1ea6dcae-8dea-4abf-9f5f-ede2138870f6" />
<img width="1021" height="576" alt="{D73798AA-FB54-4172-BF4C-B1E8DA09FB38}" src="https://github.com/user-attachments/assets/c29cb7b7-5d07-4493-ac21-3abc787ad2e2" />
<img width="783" height="488" alt="{D2AD3C92-0F5D-4F82-96C8-219188A24921}" src="https://github.com/user-attachments/assets/54415d96-9f16-4b10-ab2c-cf37ee5f058c" />


# Running The Project (Windows only)
1. Download Tilebound.zip from the repository 
2. Extract all
3. Run Tilebound.exe
