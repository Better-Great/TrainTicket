# Configuration Generator Scripts

Python scripts for analyzing and generating configuration files for TrainTicket microservices.

## 📋 Scripts Overview

| Script | Purpose |
|--------|---------|
| `analyze-and-generate.py` | Analyze application.yml files and generate templates |
| `generate-dev-properties.py` | Generate environment property files |
| `generate-env-files.py` | Generate .env files for non-Java services |

## 🚀 Usage

### 1. Analyze and Generate Templates

Analyzes all `application.yml` files and creates `application.properties.ini` templates:

```bash
cd config-generator

# Use current project (auto-detect parent directory)
python3 analyze-and-generate.py

# Or specify project root explicitly
python3 analyze-and-generate.py /path/to/TrainTicket
```

**Output**: Creates `application.properties.ini` in each service directory

### 2. Generate Environment Properties

Creates comprehensive property files with all service configurations:

```bash
# Generate dev properties
python3 generate-dev-properties.py

# Generate for specific environment
python3 generate-dev-properties.py /path/to/TrainTicket qa

# Generate prod properties
python3 generate-dev-properties.py /path/to/TrainTicket prod
```

**Output**: Creates `properties/{environment}.application.ini`

### 3. Generate .env Files (Optional)

For non-Java services that use `.env` files:

```bash
# Generate dev .env files
python3 generate-env-files.py

# Generate for specific environment
python3 generate-env-files.py /path/to/TrainTicket qa
```

**Note**: Most non-Java services use Docker environment variables directly.

## 📝 Script Arguments

All scripts accept the same arguments:

```bash
python3 <script>.py [project-root] [environment]
```

**Arguments**:
- `project-root` (optional): Path to TrainTicket project
  - Default: Auto-detects parent directory
- `environment` (optional): Target environment (dev, qa, prod)
  - Default: `dev`

## 🔧 Configuration

### Service Ports

Edit `SERVICE_PORTS` dict in `generate-dev-properties.py`:

```python
SERVICE_PORTS = {
    'YourNewService': '19000',
    # ...
}
```

### Database Services

Edit `DB_SERVICES` list in `generate-dev-properties.py`:

```python
DB_SERVICES = [
    'YourNewService',
    # ...
]
```

## 📦 Requirements

**No external dependencies required!**

- Python 3.6+
- Standard library only (os, sys, re, pathlib, yaml)

## 🎯 Workflow

### Initial Setup

```bash
# 1. Analyze all services
python3 analyze-and-generate.py

# 2. Generate property files
python3 generate-dev-properties.py

# 3. Run token replacement (Java services)
cd ..
./replace-tokens.sh dev
```

### Adding New Services

```bash
# 1. Update SERVICE_PORTS and DB_SERVICES in generate-dev-properties.py

# 2. Regenerate properties
python3 generate-dev-properties.py

# 3. Analyze new service
python3 analyze-and-generate.py

# 4. Run token replacement
cd ..
./replace-tokens.sh dev
```

## ✅ Best Practices

1. **Don't commit generated files**:
   - `application.properties` ❌
   - `.env` ❌
   - `properties/prod.application.ini` (with real credentials) ❌

2. **Do commit templates**:
   - `application.properties.ini` ✅
   - `.env.template` ✅
   - `properties/dev.application.ini` (with dummy values) ✅

3. **Use version control for configuration code**:
   - These Python scripts ✅
   - Service port mappings ✅
   - Database service lists ✅

## 🐛 Troubleshooting

### Script not found

```bash
cd /path/to/TrainTicket/config-generator
ls -la *.py
```

### Python version

```bash
python3 --version  # Should be 3.6+
```

### YAML module not found

```bash
pip3 install pyyaml
```

## 📊 Output Examples

### analyze-and-generate.py

```
================================================================================
Processing: ts-auth-service
================================================================================
  ✓ Generated template with 10 properties
  ✓ File: /path/to/ts-auth-service/application.properties.ini
...
Summary: Processed 41 services, Found 170 environment variables
```

### generate-dev-properties.py

```
✓ Generated: /path/to/properties/dev.application.ini
✓ Total service ports: 45
✓ Total database configs: 27
✓ Total properties: ~240
```

---

**For main documentation**: See `../README.md` and `../ts-token-replacement-service/README.md`

