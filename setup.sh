#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Setting up Banking Management System...${NC}\n"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo -e "${BLUE}Checking prerequisites...${NC}"

# Check for C++ compiler
if ! command_exists g++; then
    echo -e "${RED}Error: g++ is not installed${NC}"
    echo "Please install g++ before continuing"
    exit 1
fi

# Check for CMake
if ! command_exists cmake; then
    echo -e "${RED}Error: cmake is not installed${NC}"
    echo "Please install cmake before continuing"
    exit 1
fi

# Check for Node.js and npm
if ! command_exists node; then
    echo -e "${RED}Error: Node.js is not installed${NC}"
    echo "Please install Node.js before continuing"
    exit 1
fi

if ! command_exists npm; then
    echo -e "${RED}Error: npm is not installed${NC}"
    echo "Please install npm before continuing"
    exit 1
fi

# Check for SQLite3
if ! command_exists sqlite3; then
    echo -e "${RED}Error: sqlite3 is not installed${NC}"
    echo "Please install sqlite3 before continuing"
    exit 1
fi

echo -e "${GREEN}All prerequisites are satisfied!${NC}\n"

# Setup backend
echo -e "${BLUE}Setting up backend...${NC}"
cd backend
mkdir -p build && cd build
cmake ..
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: CMake configuration failed${NC}"
    exit 1
fi

cmake --build .
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Backend build failed${NC}"
    exit 1
fi
cd ../..

echo -e "${GREEN}Backend setup completed successfully!${NC}\n"

# Setup frontend
echo -e "${BLUE}Setting up frontend...${NC}"
cd frontend
npm install
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Frontend dependencies installation failed${NC}"
    exit 1
fi
cd ..

echo -e "${GREEN}Frontend setup completed successfully!${NC}\n"

# Create start script
echo -e "${BLUE}Creating start script...${NC}"
cat > start.sh << 'EOL'
#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Start backend server
echo -e "${BLUE}Starting backend server...${NC}"
cd backend/build
./banking_system &
BACKEND_PID=$!
cd ../..

# Wait for backend to start
sleep 2

# Start frontend development server
echo -e "${BLUE}Starting frontend development server...${NC}"
cd frontend
npm start &
FRONTEND_PID=$!
cd ..

# Handle shutdown
cleanup() {
    echo -e "\n${BLUE}Shutting down servers...${NC}"
    kill $BACKEND_PID
    kill $FRONTEND_PID
    exit 0
}

trap cleanup SIGINT

echo -e "${GREEN}Both servers are running!${NC}"
echo "Backend server: http://localhost:8000"
echo "Frontend server: http://localhost:3000"
echo -e "${BLUE}Press Ctrl+C to stop both servers${NC}"

# Keep script running
wait
EOL

chmod +x start.sh

echo -e "${GREEN}Start script created successfully!${NC}\n"

echo -e "${GREEN}Setup completed successfully!${NC}"
echo -e "To start the application, run: ${BLUE}./start.sh${NC}"
echo -e "Backend will run on: ${BLUE}http://localhost:8000${NC}"
echo -e "Frontend will run on: ${BLUE}http://localhost:3000${NC}"
echo -e "\nDefault admin credentials:"
echo -e "Username: ${BLUE}admin${NC}"
echo -e "Password: ${BLUE}admin123${NC}"