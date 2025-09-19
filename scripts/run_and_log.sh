#!/usr/bin/env bash

# scripts/run_and_log.sh
# Runs a given command and logs its stdout and stderr to a timestamped file.

if [ -z "$1" ]; then
  echo "Usage: $0 <command_to_run>"
  exit 1
fi

COMMAND="$@"
LOG_DIR="logs"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/command_output_${TIMESTAMP}.log"

echo "Running command: '$COMMAND'" | tee -a "$LOG_FILE"
echo "Logging output to: '$LOG_FILE'" | tee -a "$LOG_FILE"
echo "---------------------------------------------------" | tee -a "$LOG_FILE"

# Execute the command and redirect stdout and stderr to the log file
# Using 'eval' to handle commands with arguments correctly
eval "$COMMAND" 2>&1 | tee -a "$LOG_FILE"

EXIT_CODE=${PIPESTATUS[0]} # Get the exit code of the first command in the pipe

echo "---------------------------------------------------" | tee -a "$LOG_FILE"
echo "Command finished with exit code: $EXIT_CODE" | tee -a "$LOG_FILE"

exit $EXIT_CODE
