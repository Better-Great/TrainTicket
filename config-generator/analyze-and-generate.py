#!/usr/bin/env python3
"""
Analyze all application.yml files and generate complete application.properties.ini templates

Usage:
    python3 analyze-and-generate.py [project-root]
    
If project-root is not provided, uses current directory's parent.
"""
import os
import re
import yaml
import sys
from pathlib import Path

def yml_to_properties(data, prefix=''):
    """Convert YAML dict to properties format"""
    properties = []
    
    if isinstance(data, dict):
        for key, value in data.items():
            new_prefix = f"{prefix}.{key}" if prefix else key
            if isinstance(value, dict):
                properties.extend(yml_to_properties(value, new_prefix))
            elif isinstance(value, list):
                # Handle lists - join with comma for simple values
                if all(isinstance(item, (str, int, float, bool)) for item in value):
                    properties.append((new_prefix, ','.join(map(str, value))))
            else:
                properties.append((new_prefix, str(value) if value is not None else ''))
    
    return properties

def extract_tokens_from_value(value):
    """Extract ${TOKEN} patterns from values"""
    if isinstance(value, str):
        matches = re.findall(r'\$\{([^:}]+)', value)
        return matches
    return []

def find_all_tokens(data):
    """Recursively find all tokens in YAML data"""
    tokens = set()
    
    if isinstance(data, dict):
        for key, value in data.items():
            if isinstance(value, (dict, list)):
                tokens.update(find_all_tokens(value))
            elif isinstance(value, str):
                tokens.update(extract_tokens_from_value(value))
    elif isinstance(data, list):
        for item in data:
            tokens.update(find_all_tokens(item))
    
    return tokens

def convert_env_to_properties_token(value):
    """Convert ${ENV_VAR:default} to ${PropertyName} format"""
    if not isinstance(value, str):
        return str(value) if value is not None else ''
    
    # Find all ${VAR:default} patterns
    def replacer(match):
        env_var = match.group(1).split(':')[0]  # Get just the var name before :
        # Convert ENV_VAR style to PropertyName style
        parts = env_var.split('_')
        property_name = ''.join(word.capitalize() for word in parts)
        return f'${{{property_name}}}'
    
    result = re.sub(r'\$\{([^}]+)\}', replacer, value)
    return result

def main():
    # Get project root from command line or use parent of current directory
    if len(sys.argv) > 1:
        project_root = Path(sys.argv[1]).resolve()
    else:
        project_root = Path(__file__).parent.parent.resolve()
    
    print(f"Project root: {project_root}\n")
    
    services_info = {}
    all_env_vars = set()
    
    # Find all ts-* services
    for service_dir in sorted(project_root.glob('ts-*')):
        if not service_dir.is_dir():
            continue
        
        service_name = service_dir.name
        
        # Look for application.yml or application.yaml
        yml_paths = [
            service_dir / 'src/main/resources/application.yml',
            service_dir / 'src/main/resources/application.yaml'
        ]
        
        yml_file = None
        for path in yml_paths:
            if path.exists():
                yml_file = path
                break
        
        if not yml_file:
            continue
        
        print(f"\n{'='*80}")
        print(f"Processing: {service_name}")
        print(f"{'='*80}")
        
        try:
            with open(yml_file, 'r') as f:
                content = f.read()
                # Find all environment variables used
                env_vars = re.findall(r'\$\{([A-Z_]+)', content)
                all_env_vars.update(env_vars)
                
                data = yaml.safe_load(content)
                
                if not data:
                    print(f"  WARNING: Empty or invalid YAML")
                    continue
                
                # Convert to properties
                properties = yml_to_properties(data)
                
                # Generate template content
                template_lines = []
                for prop_key, prop_value in properties:
                    converted_value = convert_env_to_properties_token(prop_value)
                    template_lines.append(f"{prop_key}={converted_value}")
                
                # Write template file
                template_file = service_dir / 'application.properties.ini'
                with open(template_file, 'w') as f:
                    f.write('\n'.join(template_lines))
                
                print(f"  ✓ Generated template with {len(properties)} properties")
                print(f"  ✓ File: {template_file}")
                
                services_info[service_name] = {
                    'properties': properties,
                    'env_vars': set(env_vars)
                }
                
        except Exception as e:
            print(f"  ERROR: {e}")
            import traceback
            traceback.print_exc()
    
    print(f"\n{'='*80}")
    print(f"Summary")
    print(f"{'='*80}")
    print(f"Processed {len(services_info)} services")
    print(f"Found {len(all_env_vars)} unique environment variables")
    print(f"\nEnvironment variables found:")
    for var in sorted(all_env_vars):
        print(f"  - {var}")

if __name__ == '__main__':
    main()
