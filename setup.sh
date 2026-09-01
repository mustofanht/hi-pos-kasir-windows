#!/bin/bash

# 🚀 Jaya Property POS - Auto Setup Script
# Script ini akan membantu setup development environment

echo "=================================================="
echo "🚀 Jaya Property POS - Setup Script"
echo "=================================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
    fi
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${GREEN}ℹ️  $1${NC}"
}

# 1. Check Java Version
echo "1️⃣  Checking Java version..."
JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1)

if [ "$JAVA_VERSION" == "11" ] || [ "$JAVA_VERSION" == "17" ]; then
    print_status 0 "Java version $JAVA_VERSION is compatible"
else
    print_warning "Java version $JAVA_VERSION is NOT compatible!"
    print_info "Required: Java 11 or Java 17"
    echo ""
    echo "To install Java 11:"
    echo "  brew install openjdk@11"
    echo "  sudo ln -sfn /opt/homebrew/opt/openjdk@11/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-11.jdk"
    echo ""
    echo "To install Java 17:"
    echo "  brew install openjdk@17"
    echo "  sudo ln -sfn /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk"
    echo ""
    read -p "Do you want to continue anyway? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi
echo ""

# 2. Check FVM
echo "2️⃣  Checking FVM installation..."
if command -v fvm &> /dev/null; then
    FVM_VERSION=$(fvm --version)
    print_status 0 "FVM is installed (version $FVM_VERSION)"
else
    print_status 1 "FVM is not installed"
    echo "Install FVM: https://fvm.app/docs/getting_started/installation"
    exit 1
fi
echo ""

# 3. Check Flutter version
echo "3️⃣  Checking Flutter version..."
REQUIRED_FLUTTER="3.10.6"
if fvm list | grep -q "$REQUIRED_FLUTTER"; then
    print_status 0 "Flutter $REQUIRED_FLUTTER is installed"

    # Check if it's the local version
    if fvm list | grep "$REQUIRED_FLUTTER" | grep -q "●"; then
        print_status 0 "Flutter $REQUIRED_FLUTTER is set as local version"
    else
        print_warning "Flutter $REQUIRED_FLUTTER is not set as local version"
        echo "Setting Flutter $REQUIRED_FLUTTER as local version..."
        fvm use $REQUIRED_FLUTTER
    fi
else
    print_warning "Flutter $REQUIRED_FLUTTER is not installed"
    echo "Installing Flutter $REQUIRED_FLUTTER..."
    fvm install $REQUIRED_FLUTTER
    fvm use $REQUIRED_FLUTTER
fi
echo ""

# 4. Clean previous builds
echo "4️⃣  Cleaning previous builds..."
fvm flutter clean
print_status 0 "Project cleaned"
echo ""

# 5. Get dependencies
echo "5️⃣  Installing dependencies..."
fvm flutter pub get
if [ $? -eq 0 ]; then
    print_status 0 "Dependencies installed successfully"
else
    print_status 1 "Failed to install dependencies"
    exit 1
fi
echo ""

# 6. Check Android licenses
echo "6️⃣  Checking Android licenses..."
print_info "You may need to accept Android licenses"
read -p "Do you want to check/accept Android licenses? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    fvm flutter doctor --android-licenses
fi
echo ""

# 7. Run Flutter Doctor
echo "7️⃣  Running Flutter Doctor..."
echo ""
fvm flutter doctor -v
echo ""

# 8. Summary
echo "=================================================="
echo "📊 Setup Summary"
echo "=================================================="
echo ""
echo "✅ Project setup completed!"
echo ""
echo "Next steps:"
echo "  1. Check Flutter Doctor output above"
echo "  2. Connect a device or start an emulator"
echo "  3. Run: fvm flutter run"
echo ""
echo "For more details, see SETUP_GUIDE.md"
echo ""
