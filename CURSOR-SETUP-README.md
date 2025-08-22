# Cursor Setup System

This directory contains everything you need to maintain consistent Cursor configuration across all your projects.

## Files

- **`.cursorrules-template`** - Template file with your engineering standards
- **`setup-cursor-project.sh`** - Script to quickly set up new projects
- **`CURSOR-SETUP-README.md`** - This documentation

## Quick Setup for New Projects

### Option 1: Use the Setup Script (Recommended)

```bash
# Navigate to your new project directory
cd ~/projects/my-new-project

# Run the setup script with project type
~/dotfiles/setup-cursor-project.sh python    # For Python projects
~/dotfiles/setup-cursor-project.sh web       # For web/frontend projects
~/dotfiles/setup-cursor-project.sh api       # For API/backend projects
~/dotfiles/setup-cursor-project.sh go        # For Go projects
~/dotfiles/setup-cursor-project.sh           # Generic setup
```

### Option 2: Manual Copy

```bash
# Copy the template
cp ~/dotfiles/.cursorrules-template .cursorrules

# Create .cursor directory
mkdir -p .cursor

# Create environment.json
cat > .cursor/environment.json << EOF
{
  "agentCanUpdateSnapshot": true
}
EOF
```

## What Gets Set Up

✅ **`.cursorrules`** - Your engineering standards and patterns  
✅ **`.cursor/environment.json`** - AI snapshot update permissions  
✅ **`.gitignore` updates** - Proper Cursor file handling  
✅ **Project-specific customization** - Based on project type  

## Project Types Supported

- **`python`/`py`** - Python applications (FastAPI, Django, etc.)
- **`web`/`frontend`** - Web applications (React, Next.js, etc.)
- **`api`/`backend`** - API services (FastAPI, Express, etc.)
- **`go`/`golang`** - Go applications (coming soon)
- **`generic`** - Default template for any project type

## Customization

After running the setup script:

1. **Review `.cursorrules`** - Customize for your specific project
2. **Add project-specific rules** - Domain knowledge, team practices, etc.
3. **Update framework sections** - Add your specific libraries and tools

## Benefits

- 🚀 **Consistent setup** across all projects
- ⚡ **Quick onboarding** for new team members
- 🎯 **AI follows your standards** automatically
- 🔧 **Easy maintenance** - update template, propagate to projects

## Updating the Template

When you want to improve your standards:

1. Edit `~/dotfiles/.cursorrules-template`
2. Copy to projects that need updates: `cp ~/dotfiles/.cursorrules-template .cursorrules`
3. Customize project-specific sections as needed

## Troubleshooting

- **Script not found**: Ensure `~/dotfiles/setup-cursor-project.sh` exists and is executable
- **Template not found**: Check `~/dotfiles/.cursorrules-template` exists
- **Permissions**: Run `chmod +x ~/dotfiles/setup-cursor-project.sh` if needed

## Example Usage

```bash
# Set up a new Python API project
mkdir ~/projects/user-service
cd ~/projects/user-service
~/dotfiles/setup-cursor-project.sh api

# Set up a new React frontend
mkdir ~/projects/admin-dashboard
cd ~/projects/admin-dashboard
~/dotfiles/setup-cursor-project.sh web

# Set up a generic project
mkdir ~/projects/utility-scripts
cd ~/projects/utility-scripts
~/dotfiles/setup-cursor-project.sh
```

Now every project will have consistent Cursor configuration that follows your engineering standards! 🎉
