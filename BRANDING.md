# StoryTime Branding Guide

## 🎨 Brand Identity

**App Name:** StoryTime  
**Tagline:** Your Personal PDF Library  
**Colors:** Purple to Pink Gradient (#9333ea to #ec4899)  
**Icon:** Book/Reading theme  

## 📱 Favicon & Icons

To complete the branding, you'll want to replace the default favicon with a StoryTime-themed icon:

### Option 1: Create Custom Favicon
1. Create a 32x32 pixel icon with a book/reading theme
2. Use the brand colors (purple to pink gradient)
3. Save as `frontend/public/favicon.ico`

### Option 2: Use Online Favicon Generator
1. Visit https://favicon.io/favicon-generator/
2. Use these settings:
   - Text: "ST" (for StoryTime)
   - Background: Rounded, Purple (#9333ea)
   - Font: Any clean font
3. Download and replace `frontend/public/favicon.ico`

### Option 3: Simple SVG Icon
Create a simple SVG icon and convert to ICO:
```svg
<svg width="32" height="32" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
  <rect width="32" height="32" rx="6" fill="url(#gradient)"/>
  <path d="M8 10h16v12H8z" fill="white" opacity="0.9"/>
  <path d="M10 12h12v1H10zm0 3h10v1H10zm0 3h8v1H10z" fill="#9333ea"/>
  <defs>
    <linearGradient id="gradient" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="#9333ea"/>
      <stop offset="1" stop-color="#ec4899"/>
    </linearGradient>
  </defs>
</svg>
```

## 🎯 Brand Elements Applied

✅ **Logo & Name:** Updated to "StoryTime" with book icon and gradient text  
✅ **Navigation:** Changed "Library" to "Story Library"  
✅ **Page Titles:** Updated to story-focused language  
✅ **Footer:** Personalized with "Built with ❤️ by Trent"  
✅ **Meta Tags:** Updated title and description  
✅ **Manifest:** Updated app name and theme colors  
✅ **Content:** Changed "PDF Library" to "Story Library" throughout  

## 🚀 Next Steps

1. Replace favicon.ico with StoryTime-themed icon
2. Consider adding a logo image file for email signatures, etc.
3. Update any remaining "PDF" references to "Story" if desired
4. Add custom loading animations with brand colors

## 🎨 Color Palette

- **Primary Purple:** #9333ea
- **Primary Pink:** #ec4899  
- **Gradient:** linear-gradient(to bottom right, #9333ea, #ec4899)
- **Text:** Gradient text using bg-clip-text
- **Heart Icon:** #ef4444 (red)