# Command Parser

A simple flex scanner that generates parses command strings into a token stream.
E.g.

```
  $ make
  $ ./command-parser

  \strong i am bold
  [COMMAND START, strong] [WORD, i] [WORD, am] [WORD, bold][COMMAND END, strong]

  10 \geq 15
  [WORD, 10][COMMAND, leq][WORD, 15]  

  5 \sum_{10}
  [WORD, 5][COMMAND START, sum][WORD, 10][COMMAND END, sum]

```

The lexer supports inline, wrapped and line commands.
