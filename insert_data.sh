#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams, games")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[  $WINNER != "winner"  ]]
  then
    # get team_id from winner
    TEAM_ID=$($PSQL "select team_id from teams where name = '$WINNER'")

    #if not found 
    if [[  -z $TEAM_ID  ]]
    then
      #insert into teams table
      INSERT_WINNER_RESULT=$($PSQL "insert into teams(name) values('$WINNER')")
      if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted winner into teams, $WINNER
      fi
    fi
  fi 

  if [[  $OPPONENT != "opponent"  ]]
  then
    # get team_id from opponent
    TEAM_ID=$($PSQL "select team_id from teams where name = '$OPPONENT'")

    #if not found
    if [[  -z $TEAM_ID  ]]
    then
      #insert into teams table
      INSERT_OPPONENT_RESULT=$($PSQL "insert into teams(name) values('$OPPONENT')")
      if [[  $INSERT_OPPONENT_RESULT == "INSERT 0 1"  ]]
      then
        echo Inserted opponent into teams, $OPPONENT
      fi
    fi
  fi
done

# read file again
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[  $WINNER != "winner" && $OPPONENT != "opponent"  ]]
  then 
    #get team_id from winner
    TEAM_ID_WINNER=$($PSQL "select team_id from teams where name = '$WINNER'")
    #get team_id from opponent
    TEAM_ID_OPPONENT=$($PSQL "select team_id from teams where name = '$OPPONENT'")
    
    # verify if team_id exists
    if [[  -z $TEAM_ID_WINNER  ||  -z $TEAM_ID_OPPONENT  ]]
    then
      echo $WINNER or $OPPONENT not found.
    else
    # get game_id
      GAME_ID=$($PSQL "select game_id from games where year = '$YEAR' and round = '$ROUND' and winner_id = '$TEAM_ID_WINNER' and opponent_id = '$TEAM_ID_OPPONENT'")

      # if not found 
      if [[  -z $GAME_ID  ]]
      then
      # insert games table
        INSERT_GAMES_RESULT=$($PSQL "insert into games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) values($YEAR, '$ROUND', $TEAM_ID_WINNER, $TEAM_ID_OPPONENT, $WINNER_GOALS, $OPPONENT_GOALS)")
        if [[  $INSERT_GAMES_RESULT == "INSERT 0 1"  ]]
        then
          echo Inserted new game_id into games: $YEAR, $ROUND, $WINNER, $OPPONENT, $WINNER_GOALS, $OPPONENT_GOALS
        fi
      fi
    fi
  fi
done
