#!/usr/bin/env python3
"""
Imagefront - UI Image Generator
Generates UI mockup images using AI image generation models
"""

import os
import sys
import argparse
import json
from datetime import datetime
from pathlib import Path
from dotenv import load_dotenv

def main():
    parser = argparse.ArgumentParser(description='Generate UI mockup image using AI')
    parser.add_argument('screen_id', help='Screen ID (e.g., login-screen)')
    parser.add_argument('prompt', help='Description of the UI to generate')
    parser.add_argument('--style', default='shadcn/ui', help='UI style reference (default: shadcn/ui)')
    parser.add_argument('--model', choices=['imagen', 'dall-e-3', 'stable-diffusion', 'flux'],
                       default='imagen', help='Image generation model (default: imagen - Google Imagen/Nano Banana)')
    parser.add_argument('--size', default='1792x1024', help='Image size (default: 1792x1024)')
    parser.add_argument('--output-dir', default='ui_specs', help='Output directory')

    args = parser.parse_args()

    # Load environment variables
    load_dotenv()

    # Check for API key
    if args.model == 'imagen':
        api_key = os.getenv('GOOGLE_API_KEY')
        if not api_key:
            print("[ERROR] GOOGLE_API_KEY not found in .env file")
            print("Please create a .env file with your Google API key")
            print("Get your key at: https://aistudio.google.com/apikey")
            sys.exit(1)
    elif args.model == 'dall-e-3':
        api_key = os.getenv('OPENAI_API_KEY')
        if not api_key:
            print("[ERROR] OPENAI_API_KEY not found in .env file")
            print("Please create a .env file with your OpenAI API key")
            sys.exit(1)

    # Setup paths
    screen_dir = Path(args.output_dir) / args.screen_id
    versions_dir = screen_dir / 'versions'
    versions_dir.mkdir(parents=True, exist_ok=True)

    # Determine version number
    existing_versions = list(versions_dir.glob('*-v*.png'))
    version_num = len(existing_versions) + 1
    version = f"v{version_num}"

    # Create filename
    today = datetime.now().strftime('%Y-%m-%d')
    filename = f"{today}-{version}.png"
    output_path = versions_dir / filename

    # Build enhanced prompt for UI generation
    enhanced_prompt = build_ui_prompt(args.prompt, args.style)

    print(f"[*] Generating UI mockup for '{args.screen_id}'...")
    print(f"    Model: {args.model}")
    print(f"    Style: {args.style}")
    print(f"    Size: {args.size}")
    print(f"    Output: {output_path}")
    print()

    # Generate image based on model
    if args.model == 'imagen':
        success = generate_with_imagen(enhanced_prompt, output_path, args.size)
    elif args.model == 'dall-e-3':
        success = generate_with_dalle(enhanced_prompt, output_path, args.size)
    elif args.model == 'stable-diffusion':
        success = generate_with_replicate(enhanced_prompt, output_path, 'stability-ai/sdxl')
    elif args.model == 'flux':
        success = generate_with_replicate(enhanced_prompt, output_path, 'black-forest-labs/flux-schnell')

    if success:
        # Update metadata
        update_metadata(screen_dir, version, filename, args.prompt, enhanced_prompt)

        print()
        print("[OK] UI mockup generated successfully!")
        print(f"     Image: {output_path}")
        print()
        print("Next steps:")
        print(f"1. Review the image: {output_path}")
        print(f"2. Annotate elements: python scripts/annotate-ui.py {args.screen_id} {version}")
        print(f"3. Create manifest: python scripts/create-manifest.py {args.screen_id} {version}")
    else:
        print("[ERROR] Failed to generate image")
        sys.exit(1)

def build_ui_prompt(user_prompt, style):
    """Build enhanced prompt for UI generation"""

    style_guidelines = {
        'shadcn/ui': 'modern, clean design with rounded corners, subtle shadows, neutral color palette (slate/zinc), high contrast text, card-based layout',
        'material': 'Material Design 3 style with elevation, bold colors, floating action buttons, bottom sheets',
        'fluent': 'Microsoft Fluent Design with acrylic materials, depth, motion, subtle gradients',
        'ant-design': 'Ant Design style with blue primary color, clean typography, table-heavy layouts',
        'chakra': 'Chakra UI style with accessible colors, consistent spacing, smooth animations'
    }

    style_desc = style_guidelines.get(style, style)

    prompt = f"""Create a high-fidelity UI mockup for a web application screen.

Description: {user_prompt}

Design Style: {style_desc}

Requirements:
- Desktop web interface (1920x1080 or similar)
- Professional, modern design
- Clear visual hierarchy
- Readable text and labels
- Realistic UI elements (buttons, inputs, cards, etc.)
- Consistent spacing and alignment
- Include realistic placeholder content
- Photo-realistic rendering
- No code, just the visual design

The image should look like a polished product screenshot, not a wireframe."""

    return prompt

def generate_with_imagen(prompt, output_path, size='1792x1024'):
    """Generate image using Google Imagen (Nano Banana)"""
    try:
        import google.generativeai as genai

        api_key = os.getenv('GOOGLE_API_KEY')
        genai.configure(api_key=api_key)

        print("[...] Calling Google Imagen API...")

        # Parse size
        width, height = map(int, size.split('x'))

        # Use Imagen 3 model
        model = genai.ImageGenerationModel("imagen-3.0-generate-001")

        result = model.generate_images(
            prompt=prompt,
            number_of_images=1,
            aspect_ratio="16:9" if width > height else "9:16",
            safety_filter_level="block_few",
            person_generation="allow_adult"
        )

        # Save the image
        print("[...] Saving image...")
        if result.images:
            result.images[0].save(str(output_path))
            return True
        else:
            print("[ERROR] No image generated")
            return False

    except ImportError:
        print("[ERROR] google-generativeai package not installed")
        print("Install with: pip install google-generativeai")
        return False
    except Exception as e:
        print(f"[ERROR] {e}")
        return False

def generate_with_dalle(prompt, output_path, size='1792x1024'):
    """Generate image using DALL-E 3"""
    try:
        from openai import OpenAI

        client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))

        print("[...] Calling DALL-E 3 API...")

        response = client.images.generate(
            model="dall-e-3",
            prompt=prompt,
            size=size,
            quality="hd",
            n=1,
        )

        image_url = response.data[0].url

        # Download image
        import requests
        print("[...] Downloading image...")
        img_data = requests.get(image_url).content

        with open(output_path, 'wb') as f:
            f.write(img_data)

        return True

    except ImportError:
        print("[ERROR] openai package not installed")
        print("Install with: pip install openai")
        return False
    except Exception as e:
        print(f"[ERROR] {e}")
        return False

def generate_with_replicate(prompt, output_path, model):
    """Generate image using Replicate"""
    try:
        import replicate

        print(f"[...] Calling Replicate API ({model})...")

        output = replicate.run(
            model,
            input={"prompt": prompt}
        )

        # Download image
        import requests
        img_data = requests.get(output[0]).content

        with open(output_path, 'wb') as f:
            f.write(img_data)

        return True

    except ImportError:
        print("[ERROR] replicate package not installed")
        print("Install with: pip install replicate")
        return False
    except Exception as e:
        print(f"[ERROR] {e}")
        return False

def update_metadata(screen_dir, version, filename, user_prompt, enhanced_prompt):
    """Update screen metadata file"""
    metadata_path = screen_dir / 'metadata.json'

    if metadata_path.exists():
        with open(metadata_path, 'r') as f:
            metadata = json.load(f)
    else:
        metadata = {
            'screenId': screen_dir.name,
            'createdAt': datetime.now().isoformat(),
            'versions': []
        }

    # Add new version
    metadata['versions'].append({
        'version': version,
        'filename': filename,
        'createdAt': datetime.now().isoformat(),
        'prompt': {
            'user': user_prompt,
            'enhanced': enhanced_prompt
        }
    })

    metadata['currentVersion'] = version
    metadata['updatedAt'] = datetime.now().isoformat()

    with open(metadata_path, 'w') as f:
        json.dump(metadata, f, indent=2)

if __name__ == '__main__':
    main()
