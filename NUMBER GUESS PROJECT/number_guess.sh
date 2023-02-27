#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

PLAY_GAME() {
  read GUESS
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
      PLAY_GAME
      exit
  fi
  NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES+1))
  if [ $GUESS -eq $SECRET_NUMBER ]
    then
      GAMES_PLAYED=$(($GAMES_PLAYED+1))
      if [ $NUMBER_OF_GUESSES -lt $BEST_GAME ]
        then
          BEST_GAME=$NUMBER_OF_GUESSES
      fi
      UPDATE_USER_RESULT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE username='$USERNAME'")
      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
  elif [ $GUESS -gt $SECRET_NUMBER ]
    then
      echo "It's lower than that, guess again:"
      PLAY_GAME
  else
    echo "It's higher than that, guess again:"
    PLAY_GAME
  fi
}
GAMES_PLAYED=0
BEST_GAME=10000
echo "Enter your username:"
read USERNAME
USERNAME_QUERY_RESULT=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")
if [[ -z $USERNAME_QUERY_RESULT ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    INSERT_RESULT=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, 0)")
  else
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")
    BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))
NUMBER_OF_GUESSES=0
echo "Guess the secret number between 1 and 1000:"
PLAY_GAME