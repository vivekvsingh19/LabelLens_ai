# Home Screen Design — Black & White Minimal

## Design Philosophy

**Information > Decoration**
**Whitespace > Cards**
**Typography > Icons**
**Confidence > Excitement**

---

## Color System

### Light Mode
- **Background**: `#FFFFFF` (Pure white)
- **Text Primary**: `#000000` (Pure black)
- **Text Secondary**: `#6B6B6B` (Medium grey)
- **Text Tertiary**: `#9B9B9B` (Light grey)
- **Divider**: `#E5E5E5` (Very light grey)
- **Status SAFE**: `#4A5D4A` (Muted grey-green, 20% opacity on text)
- **Status CAUTION**: `#6B5D4A` (Muted amber-grey, 20% opacity on text)
- **Status AVOID**: `#6B4A4A` (Muted grey-red, 20% opacity on text)

### Dark Mode
- **Background**: `#000000` (Pure black)
- **Text Primary**: `#FFFFFF` (Pure white)
- **Text Secondary**: `#9B9B9B` (Medium grey)
- **Text Tertiary**: `#6B6B6B` (Dark grey)
- **Divider**: `#1A1A1A` (Very dark grey)
- **Status SAFE**: `#5A6B5A` (Muted grey-green, 20% opacity on text)
- **Status CAUTION**: `#7B6B5A` (Muted amber-grey, 20% opacity on text)
- **Status AVOID**: `#7B5A5A` (Muted grey-red, 20% opacity on text)

---

## Typography Hierarchy

### Font Family
- **Primary**: SF Pro Display / Inter (system fallback)
- **Monospace**: SF Mono / Roboto Mono (for numbers/scores)

### Scale
- **H1 (Hero)**: 32px, Weight 700, Letter-spacing -0.5px
- **H2 (Section)**: 20px, Weight 600, Letter-spacing 0px
- **H3 (Subsection)**: 16px, Weight 600, Letter-spacing 0px
- **Body Large**: 16px, Weight 400, Line-height 24px
- **Body**: 14px, Weight 400, Line-height 20px
- **Body Small**: 12px, Weight 400, Line-height 16px
- **Caption**: 11px, Weight 500, Letter-spacing 0.5px, Uppercase

---

## Spacing System

- **Unit**: 4px base
- **XS**: 4px
- **S**: 8px
- **M**: 16px
- **L**: 24px
- **XL**: 32px
- **XXL**: 48px
- **XXXL**: 64px

**Screen Padding**: 24px horizontal, 16px vertical

---

## Screen Layout Structure

### Top → Bottom Flow

```
┌─────────────────────────────────┐
│ [App Bar - Minimal]             │
├─────────────────────────────────┤
│ [Greeting Section]              │
│                                 │
│ [Daily Food Safety Summary]     │
│                                 │
│ [Primary Action Button]         │
│                                 │
│ [Daily Insight]                 │
│                                 │
│ [Personal Food Safety Score]    │
│                                 │
│ [Recent Scans List]             │
│                                 │
│ [Premium Tease]                 │
└─────────────────────────────────┘
```

---

## Screen 1: FIRST-TIME USER

### Purpose
Onboard new users with clarity and minimal friction. No overwhelming data.

---

### Layout Details

#### 1. App Bar (Minimal)
**Height**: 56px
**Padding**: 24px horizontal, 16px vertical

**Content**:
- Left: Empty (no logo, no title)
- Right: Profile icon (24px, grey, 40% opacity)

**Visual**: Invisible border-bottom (1px, divider color)

---

#### 2. Greeting Section
**Padding**: 24px horizontal, 32px top, 16px bottom

**Content**:
```
Good evening
Let's review your food choices today
```

**Typography**:
- Line 1: Body Small, Weight 500, Secondary color
- Line 2: H1, Weight 700, Primary color

**Spacing**: 4px between lines

---

#### 3. Empty State Message
**Padding**: 24px horizontal, 48px vertical

**Content**:
```
Scan your first food label to get started
```

**Typography**: Body, Weight 400, Secondary color, Center-aligned

**Visual**: No card, no border, just text

---

#### 4. Primary Action Button
**Padding**: 24px horizontal, 32px vertical

**Button**:
- **Text**: "Scan Food Label"
- **Subtext**: "Ingredients • sugar • additives"
- **Height**: 64px
- **Background**: Light mode = Black (#000000), Dark mode = White (#FFFFFF)
- **Text Color**: Light mode = White, Dark mode = Black
- **Typography**: Button text = Body Large, Weight 600; Subtext = Body Small, Weight 400, Secondary color
- **Border**: None
- **Corner Radius**: 0px (sharp corners, editorial feel)

**Spacing**: 8px between main text and subtext

---

#### 5. Bottom Spacing
**Padding**: 64px bottom (for safe area)

---

## Screen 2: RETURNING USER

### Purpose
Show meaningful data without clutter. Editorial, not dashboard-like.

---

### Layout Details

#### 1. App Bar (Minimal)
**Same as First-Time User**

---

#### 2. Greeting Section
**Same as First-Time User**

**Dynamic Content**:
- Time-based greeting: "Good morning" / "Good afternoon" / "Good evening"
- Second line: "Let's review your food choices today"

---

#### 3. Daily Food Safety Summary (Hero Block)
**Padding**: 24px horizontal, 0px vertical

**Content Structure**:
```
Today's Food Safety
Moderate exposure
1 product high in added sugar
```

**Layout**:
- No card border
- No background color (transparent)
- Typography-only block

**Typography**:
- Line 1 (Label): Caption, Weight 500, Secondary color, Uppercase
- Line 2 (Status): H2, Weight 600, Primary color
- Line 3 (Detail): Body, Weight 400, Secondary color

**Spacing**:
- 8px between label and status
- 4px between status and detail

**Status Text Options**:
- "Low exposure" (if all scans are SAFE)
- "Moderate exposure" (if mix of SAFE/CAUTION)
- "High exposure" (if any AVOID or multiple CAUTION)

---

#### 4. Primary Action Button
**Same as First-Time User**

---

#### 5. Divider
**Height**: 1px
**Color**: Divider color
**Margin**: 32px vertical, 24px horizontal

**Visual**: Simple line, no decorative elements

---

#### 6. Daily Insight (Educational Block)
**Padding**: 24px horizontal, 0px vertical

**Content Structure**:
```
Today's Insight
Added sugars often appear under multiple names.
```

**Layout**:
- No card
- No background
- Editorial text block

**Typography**:
- Line 1 (Label): Caption, Weight 500, Secondary color, Uppercase
- Line 2 (Insight): Body, Weight 400, Primary color

**Spacing**: 8px between label and insight

**Insight Rotation**:
- Rotate daily from curated list of educational facts
- Examples:
  - "Added sugars often appear under multiple names."
  - "Preservatives extend shelf life but may cause sensitivities."
  - "Natural flavors can still contain synthetic compounds."

---

#### 7. Personal Food Safety Score
**Padding**: 24px horizontal, 32px vertical

**Content Structure**:
```
Your Food Safety Score
72 ↑
This week
```

**Layout**:
- Minimal numeric emphasis
- No gauge, no chart, no progress bar

**Typography**:
- Line 1 (Label): Caption, Weight 500, Secondary color, Uppercase
- Line 2 (Score): 48px, Weight 700, Primary color, Monospace font
- Line 3 (Arrow + Period): Body Small, Weight 400, Secondary color
- Arrow: Unicode "↑" or "↓" or "→" (no icon)

**Spacing**:
- 8px between label and score
- 4px between score and period

**Score Calculation**:
- Based on last 7 days of scans
- SAFE = +10, CAUTION = +5, AVOID = -10
- Clamped to 0-100

**Arrow Logic**:
- ↑ = Improved from last week
- ↓ = Declined from last week
- → = No change

---

#### 8. Divider
**Same as Section 5**

---

#### 9. Recent Scans List
**Padding**: 24px horizontal, 0px vertical

**Content Structure**:
```
Recent Scans
Cornflakes        Caution
Protein Bar       Avoid
Greek Yogurt      Safe
```

**Layout**:
- Text-only list
- No thumbnails
- No cards
- Two-column layout (Product name | Status)

**Typography**:
- Section Label: Caption, Weight 500, Secondary color, Uppercase
- Product Name: Body, Weight 400, Primary color
- Status: Body Small, Weight 600, Status color (muted)

**Spacing**:
- 16px between label and first item
- 12px between items

**Status Display**:
- SAFE: "Safe" (muted grey-green)
- CAUTION: "Caution" (muted amber-grey)
- AVOID: "Avoid" (muted grey-red)

**List Limit**: Show last 3-5 scans only

**Interaction**: Tap to view full result (navigate to Result Screen)

---

#### 10. Premium Tease (Editorial Link)
**Padding**: 24px horizontal, 32px vertical

**Content**:
```
Unlock weekly food safety insights →
```

**Layout**:
- Single line
- Looks like a text link, not a button
- Right-aligned arrow (→)

**Typography**: Body, Weight 400, Secondary color

**Visual**:
- No underline (unless hover/pressed)
- Subtle, non-intrusive

**Conditional Display**:
- Only show after user has scanned 3+ products
- Hide if user is already premium

**Interaction**: Tap to open subscription paywall

---

#### 11. Bottom Spacing
**Padding**: 64px bottom (for safe area + bottom nav)

---

## UX Interactions

### Scroll Behavior
- **Scroll Type**: Standard vertical scroll
- **Over-scroll**: Subtle bounce (iOS) / glow (Android)
- **No parallax, no sticky headers**

### Loading States
- **Initial Load**: Show skeleton with same typography hierarchy (grey placeholders)
- **No spinners, no progress bars**

### Error States
- **Network Error**:
  ```
  Unable to load your data
  Check your connection and try again
  ```
  (Body, Secondary color, Center-aligned)

### Empty States
- **No Scans**: Show first-time user layout
- **No Recent Scans**: Hide "Recent Scans" section entirely

---

## Accessibility

### Text Scaling
- Support up to 200% system font scaling
- All text uses relative units (sp, not dp)

### Contrast
- Primary text: WCAG AAA (21:1)
- Secondary text: WCAG AA (4.5:1 minimum)

### Touch Targets
- Primary button: 64px height (minimum 44px)
- List items: 48px minimum height
- All interactive elements: 44px minimum

### Screen Reader
- Semantic labels for all sections
- Status announcements for score changes
- Button labels: "Scan Food Label, Ingredients sugar additives"

---

## Animations (Minimal)

### On Load
- **Fade In**: 200ms, ease-out
- **No slide, no scale, no bounce**

### Button Press
- **Opacity**: 0.7 for 100ms
- **No ripple, no elevation change**

### List Item Tap
- **Opacity**: 0.7 for 100ms
- **No highlight, no background change**

### Score Update
- **Fade In**: 300ms, ease-out
- **No number counting animation**

---

## Copy Guidelines

### Tone
- **Serious but approachable**
- **Educational, not preachy**
- **Confident, not salesy**

### Voice
- Second person ("your", "you")
- Active voice
- Short sentences
- No exclamation marks

### Examples
- ✅ "Scan your first food label to get started"
- ✅ "Today's Food Safety"
- ✅ "Moderate exposure"
- ❌ "Get started now!"
- ❌ "🎉 Great job!"
- ❌ "You're doing amazing!"

---

## State Management Notes

### Required Data
- User's scan history (last 7 days)
- Daily insight (rotated)
- Food Safety Score (calculated)
- Premium status (boolean)
- Scan count (for premium tease logic)

### Refresh Logic
- **On App Open**: Fetch latest scans
- **After New Scan**: Update summary, score, recent list
- **Daily Reset**: Rotate insight at midnight (local time)

---

## Implementation Checklist

- [ ] Typography system (H1-H3, Body, Caption)
- [ ] Color tokens (light/dark mode)
- [ ] Spacing system (4px base)
- [ ] First-time user layout
- [ ] Returning user layout
- [ ] Daily summary calculation
- [ ] Food Safety Score calculation
- [ ] Recent scans list (text-only)
- [ ] Premium tease logic
- [ ] Loading states
- [ ] Error states
- [ ] Accessibility labels
- [ ] Text scaling support
- [ ] Minimal animations

---

## Design Rationale

### Why No Cards?
Cards create visual noise. Whitespace and typography hierarchy provide structure without decoration.

### Why No Icons?
Icons are decoration. Text communicates intent clearly. Reserve icons for navigation only.

### Why Sharp Corners?
Sharp corners feel editorial and serious. Rounded corners feel playful and consumer-friendly.

### Why Monospace for Score?
Numbers in monospace feel precise and data-driven. Serif/sans-serif numbers can feel casual.

### Why Text-Only List?
Product images add visual clutter. Text is faster to scan and more information-dense.

---

**END OF HOME SCREEN DESIGN**

