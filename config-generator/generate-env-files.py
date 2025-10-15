#!/usr/bin/env python3
"""
Generate .env files for non-Java services (Node.js, Python) from templates

Usage:
    python3 generate-env-files.py [project-root] [environment]

Arguments:
    project-root: Path to TrainTicket project (default: parent of current directory)
    environment: Target environment name (default: dev)
"""
import os
import re
import sys
from pathlib import Path

def replace_tokens(content, properties):
    """Replace ${TOKEN} with actual values"""
    def replacer(match):
        token = match.group(1)
        value = properties.get(token, f"${{{token}}}")  # Keep original if not found
        if value.startswith("${"):
            print(f"  WARNING: No value found for token: {token}")
        return value
    
    return re.sub(r'\$\{([^}]+)\}', replacer, content)

def process_env_template(template_file, output_file, properties):
    """Process a single .env.template file"""
    print(f"\n[PROCESSING] {template_file.parent.name}")
    
    # Read template
    with open(template_file, 'r') as f:
        content = f.read()
    
    # Replace tokens
    processed_content = replace_tokens(content, properties)
    
    # Write output
    with open(output_file, 'w') as f:
        f.write(processed_content)
    
    print(f"  ✓ Generated: {output_file}")

def read_properties(properties_file):
    """Read properties from .ini file"""
    properties = {}
    with open(properties_file, 'r') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            if '=' in line:
                key, value = line.split('=', 1)
                properties[key.strip()] = value.strip()
    return properties

def main():
    # Get project root from command line or use parent of current directory
    if len(sys.argv) > 1:
        project_root = Path(sys.argv[1]).resolve()
    else:
        project_root = Path(__file__).parent.parent.resolve()
    
    # Get environment from command line or use 'dev'
    environment = sys.argv[2] if len(sys.argv) > 2 else 'dev'
    
    print(f"Project root: {project_root}")
    print(f"Environment: {environment}\n")
    
    # Read environment properties
    properties_file = project_root / 'properties' / f'{environment}.application.ini'
    
    if not properties_file.exists():
        print(f"ERROR: Properties file not found: {properties_file}")
        sys.exit(1)
    
    print(f"Loading properties from: {properties_file}")
    properties = read_properties(properties_file)
    print(f"Loaded {len(properties)} properties\n")
    
    # Find all .env.template files
    template_files = list(project_root.glob('ts-*/.env.template'))
    
    if not template_files:
        print("No .env.template files found")
        print("\nNote: For non-Java services, use Docker environment variables directly")
        print("      or create .env files manually as shown in README.md")
        return
    
    processed = 0
    for template_file in sorted(template_files):
        output_file = template_file.parent / '.env'
        try:
            process_env_template(template_file, output_file, properties)
            processed += 1
        except Exception as e:
            print(f"  ERROR: {e}")
    
    print(f"\n{'='*60}")
    print(f"Summary: Processed {processed}/{len(template_files)} services")
    print(f"{'='*60}")

if __name__ == '__main__':
    main()
