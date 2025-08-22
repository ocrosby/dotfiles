#!/bin/bash

# Purpose: Set up Cursor configuration for a new project
# Usage: ./setup-cursor-project.sh [project-type]

set -Eeuo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project type (default to generic)
PROJECT_TYPE=${1:-"generic"}

echo -e "${BLUE}🚀 Setting up Cursor configuration for ${PROJECT_TYPE} project...${NC}"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Not in a git repository. Initializing...${NC}"
    git init
fi

# Create .cursor directory
mkdir -p .cursor

# Copy template .cursorrules
if [ -f ~/dotfiles/.cursorrules-template ]; then
    cp ~/dotfiles/.cursorrules-template .cursorrules
    echo -e "${GREEN}✅ Created .cursorrules from template${NC}"
else
    echo -e "${RED}❌ Template not found at ~/dotfiles/.cursorrules-template${NC}"
    exit 1
fi

# Create .cursor/environment.json
cat > .cursor/environment.json << 'JSON_EOF'
{
  "agentCanUpdateSnapshot": true
}
JSON_EOF
echo -e "${GREEN}✅ Created .cursor/environment.json${NC}"

# Customize .cursorrules based on project type
case $PROJECT_TYPE in
    "python"|"py")
        echo -e "${BLUE}🐍 Customizing for Python project...${NC}"
        sed -i '' 's/## Project Type: \[Web App\/API\/Library\/CLI\/etc.\]/## Project Type: Python Application/' .cursorrules
        sed -i '' 's/- \*\*Architecture\*\*: \[Describe your preferred architecture\]/- **Architecture**: src layout, services (facades), adapters (I\/O), domain (pure)/' .cursorrules
        sed -i '' 's/- \*\*Framework\*\*: \[List primary frameworks\/libraries\]/- **Framework**: Python, FastAPI\/Django, SQLAlchemy, Pydantic/' .cursorrules
        ;;
    "web"|"frontend")
        echo -e "${BLUE}🌐 Customizing for Web project...${NC}"
        sed -i '' 's/## Project Type: \[Web App\/API\/Library\/CLI\/etc.\]/## Project Type: Web Application/' .cursorrules
        sed -i '' 's/- \*\*Architecture\*\*: \[Describe your preferred architecture\]/- **Architecture**: Component-based, separation of concerns, API-first/' .cursorrules
        sed -i '' 's/- \*\*Framework\*\*: \[List primary frameworks\/libraries\]/- **Framework**: React\/Next.js, TypeScript, Tailwind CSS/' .cursorrules
        ;;
    "api"|"backend")
        echo -e "${BLUE}🔌 Customizing for API project...${NC}"
        sed -i '' 's/## Project Type: \[Web App\/API\/Library\/CLI\/etc.\]/## Project Type: API Service/' .cursorrules
        sed -i '' 's/- \*\*Architecture\*\*: \[Describe your preferred architecture\]/- **Architecture**: Layered architecture, REST\/GraphQL, dependency injection/' .cursorrules
        sed -i '' 's/- \*\*Framework\*\*: \[List primary frameworks\/libraries\]/- **Framework**: FastAPI\/Express, OpenAPI, JWT auth/' .cursorrules
        ;;
    "go"|"golang")
        echo -e "${BLUE}🐹 Customizing for Go project...${NC}"
        echo -e "${YELLOW}⚠️  Go project type not yet implemented${NC}"
        ;;
    *)
        echo -e "${YELLOW}⚠️  Unknown project type: ${PROJECT_TYPE}. Using generic template.${NC}"
        ;;
esac

# Create .gitignore entries for Cursor
if [ -f .gitignore ]; then
    echo "" >> .gitignore
    echo "# Cursor" >> .gitignore
    echo ".cursor/rules/" >> .gitignore
    echo "!.cursor/environment.json" >> .gitignore
    echo -e "${GREEN}✅ Updated .gitignore for Cursor${NC}"
else
    echo -e "${YELLOW}⚠️  No .gitignore found. Consider creating one.${NC}"
fi

echo -e "${GREEN}🎉 Cursor configuration setup complete!${NC}"
echo -e "${BLUE}📝 Next steps:${NC}"
echo -e "   1. Review and customize .cursorrules for your specific project"
echo -e "   2. Restart Cursor to load the new configuration"
echo -e "   3. The AI will now follow your engineering standards"
echo ""
echo -e "${BLUE}💡 Tip: Run this script in any new project to get consistent Cursor setup${NC}"
