Mastermind game created using ruby 

Rules credit: https://replit.com/@rlmoser/rubyMastermind#README.md

    How to play Mastermind:

    You can choose to be the code maker or the code breaker
    This is a 1-player game against the computer.
    There are six different number combinations:
    The code maker will choose four to create a 'master code'. For example,
    1341
    As you can see, there can be more then one of the same number/color.
    In order to win, the code breaker needs to guess the 'master code' in 12 or less turns.


    Clues:
    After each guess, there will be up to four clues to help crack the code.

    ● This clue means you have 1 correct number in the correct location.
    ○ This clue means you have 1 correct number, but in the wrong location.

    Clue Example:
    To continue the example, using the above 'master code' a guess of 1463 would produce 3 clues:
    1463  ● ○ ○ 
    The guess had 1 correct number in the correct location [1] and 2 correct numbers in a wrong location [3,4].
    
    Options:
    You can play as code maker or as code breaker, if you choose to play as code maker,
    you will be asked to create a code and the computer will try to crack it 
    (Takes an average of 5 turns to crack)

    If you choose to be code breaker, the computer will generate a random code which you will have to try and crack.
