#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Running Banking Management System tests...${NC}\n"

# Test backend compilation
echo -e "${BLUE}Testing backend compilation...${NC}"
cd backend/build
cmake --build .
if [ $? -ne 0 ]; then
    echo -e "${RED}Backend compilation test failed${NC}"
    exit 1
fi
echo -e "${GREEN}Backend compilation test passed${NC}\n"

# Test backend server startup
echo -e "${BLUE}Testing backend server startup...${NC}"
./banking_system &
BACKEND_PID=$!
sleep 2

# Test if backend server is running
curl -s http://localhost:8000/api/health > /dev/null
if [ $? -ne 0 ]; then
    echo -e "${RED}Backend server startup test failed${NC}"
    kill $BACKEND_PID
    exit 1
fi
echo -e "${GREEN}Backend server startup test passed${NC}"
kill $BACKEND_PID
cd ../..

# Test frontend dependencies
echo -e "\n${BLUE}Testing frontend dependencies...${NC}"
cd frontend
npm install
if [ $? -ne 0 ]; then
    echo -e "${RED}Frontend dependencies test failed${NC}"
    exit 1
fi

# Test frontend build
echo -e "\n${BLUE}Testing frontend build...${NC}"
npm run build
if [ $? -ne 0 ]; then
    echo -e "${RED}Frontend build test failed${NC}"
    exit 1
fi
echo -e "${GREEN}Frontend build test passed${NC}"
cd ..

# Test database initialization
echo -e "\n${BLUE}Testing database initialization...${NC}"
if [ ! -f "backend/build/banking.db" ]; then
    echo -e "${RED}Database initialization test failed${NC}"
    exit 1
fi
echo -e "${GREEN}Database initialization test passed${NC}\n"

# Test default admin account
echo -e "${BLUE}Testing default admin account...${NC}"
curl -s -X POST http://localhost:8000/api/login \
     -H "Content-Type: application/json" \
     -d '{"username":"admin","password":"admin123"}' > /dev/null
if [ $? -ne 0 ]; then
    echo -e "${RED}Default admin account test failed${NC}"
    exit 1
fi
echo -e "${GREEN}Default admin account test passed${NC}\n"

echo -e "${GREEN}All tests passed successfully!${NC}"
echo -e "You can now start the application using: ${BLUE}./start.sh${NC}"