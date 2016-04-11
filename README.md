# HS

## how to play

```sh
$ perl main.pl
Welcome to HS.
Enter Player 1 name.
$ hoge
Enter Player 2 name.
$ fuga
hoge's turn.
tell me your choice.
...
```

## choice_list
```
# input the word below...
attack: attack by your field card.
play: play by your hand.
surrender: you are loser!
end: end your turn 
list: display information
clear: cleanup console
```

## how to read "list"
```
hoge 's information .
mana 1 / 1 .
hero health:30 .

### hand ### - The cards you have.
===.
no: 1.
cost: 1.
attack: 1.
health: 1.
===.
no: 2.
cost: 2.
attack: 2.
health: 1.
===.
no: 3.
cost: 4.
attack: 3.
health: 5.

### field ### - The cards you have played

fuga 's information .
mana 0 / 0 .
hero health:30 .


### field ### - The Cards opponent have played
```
