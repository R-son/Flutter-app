#!/bin/bash

BACKEND_DIR="./backend"
FLUTTER_DIR="./flutter_app"

BACKEND_PID=0
FLUTTER_PID=0

start_servers() {
  if [ $BACKEND_PID -eq 0 ]; then
    echo "Starting backend server..."
    cd $BACKEND_DIR
    node server.js &
    BACKEND_PID=$!
    cd - > /dev/null
    echo "Backend server started with PID $BACKEND_PID"
  else
    echo "Backend server is already running with PID $BACKEND_PID"
  fi

  if [ $FLUTTER_PID -eq 0 ]; then
    echo "Starting Flutter app..."
    cd $FLUTTER_DIR
    flutter run -d all &
    FLUTTER_PID=$!
    cd - > /dev/null
    echo "Flutter app started with PID $FLUTTER_PID"
  else
    echo "Flutter app is already running with PID $FLUTTER_PID"
  fi
}

stop_servers() {
  if [ $BACKEND_PID -ne 0 ]; then
    echo "Stopping backend server with PID $BACKEND_PID..."
    kill $BACKEND_PID
    BACKEND_PID=0
    echo "Backend server stopped."
  else
    echo "Backend server is not running."
  fi

  if [ $FLUTTER_PID -ne 0 ]; then
    echo "Stopping Flutter app with PID $FLUTTER_PID..."
    kill $FLUTTER_PID
    FLUTTER_PID=0
    echo "Flutter app stopped."
  else
    echo "Flutter app is not running."
  fi
}

restart_servers() {
  echo "Restarting servers..."
  stop_servers
  start_servers
}

status_servers() {
  if [ $BACKEND_PID -ne 0 ]; then
    echo "Backend server is running with PID $BACKEND_PID"
  else
    echo "Backend server is not running."
  fi

  if [ $FLUTTER_PID -ne 0 ]; then
    echo "Flutter app is running with PID $FLUTTER_PID"
  else
    echo "Flutter app is not running."
  fi
}

reseed_database() {
  echo "Reseeding database..."
  cd $BACKEND_DIR
  node seed.js
  if [ $? -eq 0 ]; then
    echo "Database reseeded successfully."
  else
    echo "Error reseeding the database."
  fi
  cd - > /dev/null
}

manage_servers() {
  while true; do
    echo ""
    echo "Server Management Options:"
    echo "1. Start servers"
    echo "2. Stop servers"
    echo "3. Restart servers"
    echo "4. Show server status"
    echo "5. Reseed database"
    echo "6. Exit"
    echo -n "Enter your choice: "
    read choice

    case $choice in
      1) start_servers ;;
      2) stop_servers ;;
      3) restart_servers ;;
      4) status_servers ;;
      5) reseed_database ;;
      6) echo "Exiting..."; exit 0 ;;
      *) echo "Invalid choice. Please try again." ;;
    esac
  done
}

manage_servers