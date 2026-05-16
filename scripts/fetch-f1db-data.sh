#!/usr/bin/env bash

# Pull the f1db racing database (svenvc/F1-MRD-Database-PSQL) and load it into PostgreSQL.
# Adapted from The Art of Postgres: Chapter X, YYYYYYYYYY

set -e

NC='\033[0m' # No color (reset)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'

F1DB_DB_NAME=f1db
F1DB_DUMP_PATH=/data/f1db_dump.sql.bz2
F1DB_CONSTRAINTS_PATH=/data/f1db_constraints.sql.bz2
F1DB_DUMP_TARGET_PATH=./f1db_dump.sql
F1DB_CONSTRAINTS_TARGET_PATH=./f1db_constraints.sql

WORK_DIR=/tmp/f1db
mkdir -p $WORK_DIR
cd $WORK_DIR

echo -e "${GREEN}Unzip F1 DB dataset and contraints (Postgres dump)...${NC}"
bunzip2 -kfc $F1DB_DUMP_PATH >> $F1DB_DUMP_TARGET_PATH
bunzip2 -kfc $F1DB_CONSTRAINTS_PATH >> $F1DB_CONSTRAINTS_TARGET_PATH

until pg_isready > /dev/null; do
  echo -e "${YELLOW}Waiting for PostgreSQL to start${NC}"
  sleep 1
done

if psql -lqt | cut -d \| -f 1 | grep -qw $F1DB_DB_NAME; then
  if [[ $1 == "--recreate" ]]; then
    echo -e "${YELLOW}--recreate flag was given, dropping database $F1DB_DB_NAME${NC}"
    dropdb $F1DB_DB_NAME
  else
    echo -e "${RED}$F1DB_DB_NAME PostgreSQL database already exists, skipping${NC}"
    echo -e "${RED}Include the --recreate flag if you want to drop and reseed the database${NC}"
    exit 1
  fi
fi

echo -e "${GREEN}Creating PostgreSQL database...${NC}"
createdb $F1DB_DB_NAME

echo -e "${GREEN}Importing f1db data into PostgreSQL...${NC}"
psql -d $F1DB_DB_NAME -q -f $F1DB_DUMP_TARGET_PATH

echo -e "${GREEN}Applying constraints...${NC}"
psql -d $F1DB_DB_NAME -q -f $F1DB_CONSTRAINTS_TARGET_PATH

echo -e "${GREEN}Cleaning up...${NC}"
rm $F1DB_DUMP_TARGET_PATH $F1DB_CONSTRAINTS_TARGET_PATH

echo -e "${GREEN}Done! 🎉${NC}"