---
name: FinCollect Executive
colors:
  surface: '#f9f9ff'
  surface-dim: '#cfdaf2'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f0f3ff'
  surface-container: '#e7eeff'
  surface-container-high: '#dee8ff'
  surface-container-highest: '#d8e3fb'
  on-surface: '#111c2d'
  on-surface-variant: '#434656'
  inverse-surface: '#263143'
  inverse-on-surface: '#ecf1ff'
  outline: '#747688'
  outline-variant: '#c4c5d9'
  surface-tint: '#0046f9'
  primary: '#0038ca'
  on-primary: '#ffffff'
  primary-container: '#0f4cff'
  on-primary-container: '#dadeff'
  inverse-primary: '#b9c3ff'
  secondary: '#505f76'
  on-secondary: '#ffffff'
  secondary-container: '#d0e1fb'
  on-secondary-container: '#54647a'
  tertiary: '#00573a'
  on-tertiary: '#ffffff'
  tertiary-container: '#00724d'
  on-tertiary-container: '#6df9bc'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dde1ff'
  primary-fixed-dim: '#b9c3ff'
  on-primary-fixed: '#001356'
  on-primary-fixed-variant: '#0034bf'
  secondary-fixed: '#d3e4fe'
  secondary-fixed-dim: '#b7c8e1'
  on-secondary-fixed: '#0b1c30'
  on-secondary-fixed-variant: '#38485d'
  tertiary-fixed: '#6ffbbe'
  tertiary-fixed-dim: '#4edea3'
  on-tertiary-fixed: '#002113'
  on-tertiary-fixed-variant: '#005236'
  background: '#f9f9ff'
  on-background: '#111c2d'
  surface-variant: '#d8e3fb'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  title-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
  headline-md-mobile:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  container-padding: 16px
  gutter: 12px
---

## Brand & Style
The design system is engineered for field agents and loan executives who require high-velocity data entry and crystal-clear status visibility under various lighting conditions. The brand personality is **Professional, Trustworthy, and Efficient**. 

The aesthetic follows a **Modern Fintech** direction—a refinement of Material Design 3 that prioritizes utility over decoration. It utilizes a "Surface-on-Surface" architecture where depth is communicated through subtle tonal shifts rather than heavy shadows. The UI remains airy and focused, ensuring that high-stress tasks like debt collection and identity verification feel systematic and manageable.

## Colors
The palette is anchored by **Royal Blue**, a color that evokes stability and institutional trust. 

- **Primary (#0F4CFF):** Used for primary actions, active states, and branding elements.
- **Success/Warning/Danger:** High-saturation tokens used strictly for status indicators (e.g., "Paid", "Pending", "Overdue"). 
- **Neutral:** A range of Slate grays is used for typography and iconography to maintain a softer, more modern feel than pure black.
- **Surface Strategy:** The background is pure white to maximize legibility in outdoor environments. Secondary surfaces use subtle light grays to group related information without adding visual weight.

## Typography
This design system utilizes **Inter** for its exceptional legibility and neutral, systematic character. 

- **Headlines:** Use SemiBold (600) weights with tighter letter-spacing for a modern, "app-first" feel.
- **Body Text:** Standardized at 16px for primary reading to ensure accessibility for field executives moving between tasks. 
- **Labels:** Set in Medium (500) weight with slight tracking for all-caps status chips and secondary metadata.
- **Scale:** The hierarchy is optimized for mobile-first density, ensuring that even data-heavy tables remain readable.

## Layout & Spacing
The layout follows a **4px baseline grid** to ensure mathematical consistency across Android and iOS implementations.

- **Grid:** A fluid 4-column grid for mobile with 16px side margins.
- **Rhythm:** Use `16px (md)` for standard padding between elements and `24px (lg)` for separating distinct logical sections.
- **Density:** For data-entry forms, use a vertical rhythm of `12px` to allow more fields to be visible above the fold.

## Elevation & Depth
Elevation in this design system is communicative rather than decorative. 

- **Level 0 (Flat):** Background and secondary layout containers.
- **Level 1 (Soft Shadow):** Primary cards and list items. Use a very soft, diffused shadow: `Y: 2, Blur: 8, Spread: 0, Opacity: 6%` of the neutral color.
- **Level 2 (Floating):** Floating Action Buttons (FABs) and active Modals. Use a more pronounced shadow: `Y: 4, Blur: 12, Spread: 0, Opacity: 10%`.
- **Level 3 (Overlay):** Top-level sheets and pickers. 

Avoid high-contrast borders; instead, use 1px subtle outlines (`#E2E8F0`) for interactive elements on white backgrounds.

## Shapes
The shape language is defined by **Rounded (0.5rem / 8px)** foundations with strategic use of larger radii for cards.

- **Small Components:** Checkboxes and small buttons use a `4px` radius.
- **Standard Components:** Input fields and buttons use an `8px` radius.
- **Containers:** Dashboard cards and bottom sheets use a `16px` radius (`rounded-lg`) to create a friendlier, modern fintech feel.
- **Full Round:** Status chips and FABs use the pill-shape (`rounded-full`).

## Components

- **Buttons:** 
  - *Primary:* Royal Blue background, white text, 48px height for touch-target optimization.
  - *Secondary:* Ghost style with 1px slate outline or subtle gray fill.
- **Cards:** White background with `16px` corners and Level 1 elevation. Include a 4px left-border accent using the status colors (Success/Warning/Danger) for overdue or priority items.
- **Floating Action Button (FAB):** Material-style 56px circle in Primary color, positioned at the bottom right. Use a white icon.
- **Status Chips:** Pill-shaped with a 12% opacity background of the status color and a 100% opacity text color (e.g., Light Red background with Deep Red text for "Overdue").
- **Input Fields:** Outlined style with `8px` radius. Labels should transition to the top border on focus (Material 3 style). Use a `2px` border-width for the active state in Royal Blue.
- **Bottom Navigation:** Fixed at the bottom, white background, `0.5px` top border. Icons use Primary color for active states and Slate for inactive.
- **Progress Bars:** Thin `4px` tracks. Use Primary color for general progress and Status colors for specific goals (e.g., Collection Target).