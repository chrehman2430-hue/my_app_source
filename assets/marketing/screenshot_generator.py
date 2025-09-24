#!/usr/bin/env python3
"""
Marketing Screenshot Generator for Finance Budget App
Creates professional app store screenshots with highlights
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_marketing_screenshots():
    # Create marketing directory
    os.makedirs('assets/marketing', exist_ok=True)
    
    # Screenshot dimensions (iPhone 14 Pro Max)
    width, height = 1290, 2796
    
    # Brand colors
    primary_color = (30, 136, 229)  # #1E88E5
    secondary_color = (13, 71, 161)  # #0D47A1
    accent_color = (255, 255, 255)  # White
    text_color = (33, 33, 33)  # Dark gray
    
    # Create screenshots
    screenshots = [
        {
            'title': 'Track Your Expenses',
            'subtitle': 'Beautiful charts and insights',
            'features': ['Real-time expense tracking', 'Category-based organization', 'Visual spending analysis'],
            'filename': 'screenshot_1_expenses.png'
        },
        {
            'title': 'Budget Management',
            'subtitle': 'Stay on track with your goals',
            'features': ['Smart budget planning', 'Progress tracking', 'Spending alerts'],
            'filename': 'screenshot_2_budget.png'
        },
        {
            'title': 'Savings Goals',
            'subtitle': 'Achieve your financial dreams',
            'features': ['Visual progress rings', 'Goal milestones', 'Achievement rewards'],
            'filename': 'screenshot_3_savings.png'
        },
        {
            'title': 'Premium Features',
            'subtitle': 'Unlock advanced capabilities',
            'features': ['Cloud sync & backup', 'Export to Excel/PDF', 'Advanced analytics'],
            'filename': 'screenshot_4_premium.png'
        },
        {
            'title': 'Beautiful Design',
            'subtitle': 'Material 3 with dark mode',
            'features': ['Modern interface', 'Smooth animations', 'Accessibility focused'],
            'filename': 'screenshot_5_design.png'
        }
    ]
    
    for i, screenshot in enumerate(screenshots):
        # Create image
        img = Image.new('RGB', (width, height), accent_color)
        draw = ImageDraw.Draw(img)
        
        # Draw header background
        header_height = 400
        draw.rectangle([0, 0, width, header_height], fill=primary_color)
        
        # Draw gradient effect
        for y in range(header_height):
            alpha = int(255 * (1 - y / header_height * 0.3))
            color = (*primary_color, alpha)
            draw.rectangle([0, y, width, y + 1], fill=primary_color)
        
        # Draw phone mockup frame
        phone_margin = 100
        phone_width = width - (phone_margin * 2)
        phone_height = height - 800
        phone_y = header_height + 100
        
        # Phone shadow
        shadow_offset = 20
        draw.rounded_rectangle([
            phone_margin + shadow_offset, 
            phone_y + shadow_offset,
            phone_margin + phone_width + shadow_offset,
            phone_y + phone_height + shadow_offset
        ], radius=50, fill=(0, 0, 0, 50))
        
        # Phone frame
        draw.rounded_rectangle([
            phone_margin, phone_y,
            phone_margin + phone_width,
            phone_y + phone_height
        ], radius=50, fill=(20, 20, 20))
        
        # Phone screen
        screen_margin = 20
        draw.rounded_rectangle([
            phone_margin + screen_margin,
            phone_y + screen_margin,
            phone_margin + phone_width - screen_margin,
            phone_y + phone_height - screen_margin
        ], radius=40, fill=accent_color)
        
        # Draw app interface mockup
        screen_x = phone_margin + screen_margin + 20
        screen_y = phone_y + screen_margin + 60
        screen_w = phone_width - (screen_margin * 2) - 40
        screen_h = phone_height - (screen_margin * 2) - 120
        
        # App bar
        draw.rectangle([screen_x, screen_y, screen_x + screen_w, screen_y + 80], fill=primary_color)
        
        # Content area with sample charts/cards
        content_y = screen_y + 100
        
        if i == 0:  # Expenses screen
            # Draw expense cards
            for j in range(4):
                card_y = content_y + (j * 120)
                draw.rounded_rectangle([
                    screen_x + 20, card_y,
                    screen_x + screen_w - 20, card_y + 100
                ], radius=15, fill=(245, 245, 245))
                
                # Category icon
                draw.ellipse([
                    screen_x + 40, card_y + 20,
                    screen_x + 80, card_y + 60
                ], fill=primary_color)
                
                # Amount bar
                bar_width = 200 + (j * 50)
                draw.rounded_rectangle([
                    screen_x + 100, card_y + 40,
                    screen_x + 100 + bar_width, card_y + 60
                ], radius=10, fill=secondary_color)
        
        elif i == 1:  # Budget screen
            # Draw budget progress bars
            for j in range(3):
                bar_y = content_y + (j * 150)
                progress = 0.3 + (j * 0.2)
                
                # Background bar
                draw.rounded_rectangle([
                    screen_x + 20, bar_y,
                    screen_x + screen_w - 20, bar_y + 40
                ], radius=20, fill=(230, 230, 230))
                
                # Progress bar
                progress_width = int((screen_w - 40) * progress)
                color = primary_color if progress < 0.8 else (255, 152, 0)
                draw.rounded_rectangle([
                    screen_x + 20, bar_y,
                    screen_x + 20 + progress_width, bar_y + 40
                ], radius=20, fill=color)
        
        elif i == 2:  # Savings screen
            # Draw circular progress rings
            for j in range(2):
                for k in range(2):
                    ring_x = screen_x + 50 + (k * 200)
                    ring_y = content_y + 50 + (j * 200)
                    ring_size = 120
                    
                    # Background ring
                    draw.ellipse([
                        ring_x, ring_y,
                        ring_x + ring_size, ring_y + ring_size
                    ], outline=(230, 230, 230), width=15)
                    
                    # Progress ring (partial)
                    draw.arc([
                        ring_x, ring_y,
                        ring_x + ring_size, ring_y + ring_size
                    ], start=-90, end=90 + (j * k * 90), fill=primary_color, width=15)
        
        # Draw title and subtitle
        title_y = 50
        try:
            # Try to use a system font
            title_font = ImageFont.truetype("arial.ttf", 72)
            subtitle_font = ImageFont.truetype("arial.ttf", 48)
            feature_font = ImageFont.truetype("arial.ttf", 36)
        except:
            # Fallback to default font
            title_font = ImageFont.load_default()
            subtitle_font = ImageFont.load_default()
            feature_font = ImageFont.load_default()
        
        # Title
        title_bbox = draw.textbbox((0, 0), screenshot['title'], font=title_font)
        title_width = title_bbox[2] - title_bbox[0]
        title_x = (width - title_width) // 2
        draw.text((title_x, title_y), screenshot['title'], fill=accent_color, font=title_font)
        
        # Subtitle
        subtitle_bbox = draw.textbbox((0, 0), screenshot['subtitle'], font=subtitle_font)
        subtitle_width = subtitle_bbox[2] - subtitle_bbox[0]
        subtitle_x = (width - subtitle_width) // 2
        draw.text((subtitle_x, title_y + 100), screenshot['subtitle'], fill=accent_color, font=subtitle_font)
        
        # Features list at bottom
        features_y = height - 400
        for j, feature in enumerate(screenshot['features']):
            feature_y = features_y + (j * 60)
            
            # Bullet point
            draw.ellipse([80, feature_y + 15, 100, feature_y + 35], fill=primary_color)
            
            # Feature text
            draw.text((120, feature_y), f"• {feature}", fill=text_color, font=feature_font)
        
        # Save screenshot
        img.save(f'assets/marketing/{screenshot["filename"]}', 'PNG', quality=95)
        print(f"Created {screenshot['filename']}")
    
    print("Marketing screenshots created successfully!")

def create_feature_graphics():
    """Create feature highlight graphics"""
    
    # Feature graphic dimensions
    width, height = 1200, 630
    
    features = [
        {
            'title': 'Smart Budget Tracking',
            'description': 'AI-powered insights for better financial decisions',
            'icon': '📊',
            'filename': 'feature_budget_tracking.png'
        },
        {
            'title': 'Premium Analytics',
            'description': 'Advanced charts and export capabilities',
            'icon': '📈',
            'filename': 'feature_premium_analytics.png'
        },
        {
            'title': 'Goal Achievement',
            'description': 'Visual progress tracking for savings goals',
            'icon': '🎯',
            'filename': 'feature_goal_achievement.png'
        }
    ]
    
    primary_color = (30, 136, 229)
    accent_color = (255, 255, 255)
    
    for feature in features:
        img = Image.new('RGB', (width, height), primary_color)
        draw = ImageDraw.Draw(img)
        
        # Gradient background
        for y in range(height):
            alpha = int(255 * (1 - y / height * 0.3))
            color = (primary_color[0], primary_color[1], primary_color[2])
            draw.rectangle([0, y, width, y + 1], fill=color)
        
        try:
            title_font = ImageFont.truetype("arial.ttf", 64)
            desc_font = ImageFont.truetype("arial.ttf", 36)
            icon_font = ImageFont.truetype("arial.ttf", 120)
        except:
            title_font = ImageFont.load_default()
            desc_font = ImageFont.load_default()
            icon_font = ImageFont.load_default()
        
        # Icon
        icon_bbox = draw.textbbox((0, 0), feature['icon'], font=icon_font)
        icon_width = icon_bbox[2] - icon_bbox[0]
        icon_x = (width - icon_width) // 2
        draw.text((icon_x, 100), feature['icon'], fill=accent_color, font=icon_font)
        
        # Title
        title_bbox = draw.textbbox((0, 0), feature['title'], font=title_font)
        title_width = title_bbox[2] - title_bbox[0]
        title_x = (width - title_width) // 2
        draw.text((title_x, 280), feature['title'], fill=accent_color, font=title_font)
        
        # Description
        desc_bbox = draw.textbbox((0, 0), feature['description'], font=desc_font)
        desc_width = desc_bbox[2] - desc_bbox[0]
        desc_x = (width - desc_width) // 2
        draw.text((desc_x, 380), feature['description'], fill=accent_color, font=desc_font)
        
        img.save(f'assets/marketing/{feature["filename"]}', 'PNG', quality=95)
        print(f"Created {feature['filename']}")
    
    print("Feature graphics created successfully!")

if __name__ == "__main__":
    create_marketing_screenshots()
    create_feature_graphics()
