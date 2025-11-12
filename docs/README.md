# Documentation Assets

This directory contains visual assets and documentation files for the Terraform + Docker Demo project.

## Files

### architecture.svg
Visual diagram showing the complete infrastructure architecture including:
- Docker Desktop environment
- Custom bridge network (172.20.0.0/16)
- Three main containers:
  - Nginx reverse proxy (port 80 → 8080)
  - Flask application (port 5000)
  - PostgreSQL database (port 5432)
- External access points (localhost:8080)
- Persistent data volumes
- Network connections and data flow

**Format:** SVG (Scalable Vector Graphics)
**Size:** 800x600px
**Used in:** README.md Architecture section

## Viewing the Diagram

### In GitHub/GitLab
The SVG will render automatically in README.md when viewing on GitHub or GitLab.

### Locally
Open the SVG file in any modern web browser:
```bash
open docs/architecture.svg
```

## Editing the Diagram

The SVG is a text-based format and can be edited with:
- Any text editor (for code-level changes)
- Vector graphics editors like:
  - Adobe Illustrator
  - Inkscape (free)
  - Figma
  - Sketch

## Style Guide

The diagram uses:
- **Colors:**
  - Containers: White background (#ffffff) with blue border (#2563eb)
  - Network: Light blue background (#eff6ff) with dashed border
  - Docker: Light gray background (#f8fafc)
  
- **Typography:**
  - Titles: 16px, weight 600
  - Labels: 14px
  - Ports: 12px monospace
  - Small text: 12px

- **Layout:**
  - Consistent spacing and alignment
  - Clear visual hierarchy
  - Logical left-to-right data flow

