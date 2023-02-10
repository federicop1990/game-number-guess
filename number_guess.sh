#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

START_MENU(){
  #get username
  echo "Enter your username:"
  read USERNAME

  #get username from db
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

  # username doesn't exist
  if [[ -z $USER_ID ]]
  then
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
    #insert to users table
    INSERT_TO_USERS=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    #get user_id
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
  # username exists
  else
    #get games played
    GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games WHERE user_id = '$USER_ID'")

    #get best game (less tries)
    MIN_TRIES=$($PSQL "SELECT MIN(tries) FROM games WHERE user_id = '$USER_ID'")

    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $MIN_TRIES guesses."
  fi
  GUESSING_GAME
}

GUESSING_GAME(){
  NUM_TO_GUESS=$((1 + $RANDOM % 1000))

  # count tries
  TRIES=0

  # guess number
  echo $NUM_TO_GUESS

  GUESS=0
  # check whether guessed or not
  WIN=0
  echo -e "\nGuess the secret number between 1 and 1000:"
  while [[ $WIN = 0 ]]
  do
    read GUESS
    # if try is not a positive number
    if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
      echo -e "\nThat is not an integer, guess again:"
    # if try is correct
    elif [[ $NUM_TO_GUESS = $GUESS ]]
    then
      TRIES=$(($TRIES + 1))
      echo -e "\nYou guessed it in $TRIES tries. The secret number was $NUM_TO_GUESS. Nice job!"
      # insert into db
      INSERT_TO_GAMES=$($PSQL "insert into games(user_id, tries) values($USER_ID, $TRIES)")
      WIN=1
    # if try is greater
    elif [[ $NUM_TO_GUESS -gt $GUESS ]]
    then
      TRIES=$(($TRIES + 1))
      echo -e "\nIt's higher than that, guess again:"
    # if try is smaller
    else
      TRIES=$(($TRIES + 1))
      echo -e "\nIt's lower than that, guess again:"
    fi
  done
}

START_MENU