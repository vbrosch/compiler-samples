%{
/* need this for the call to atof() below */
#include <math.h>
#include <string.h>

char* prefix;

%}

LETTER    [A-Za-z]
VOWEL     [AEIOUaeiou]
CONSONANT [A-Za-z]{-}[AEIOUaeiou]

%x  prefixed_vowel
%x  prefixed_cons

%%

{VOWEL}     { printf("%s", yytext); BEGIN(prefixed_vowel); }
{CONSONANT} { prefix = strdup(yytext); BEGIN(prefixed_cons); }

<prefixed_vowel>{LETTER}* { printf("%s", yytext); }
<prefixed_vowel>[ \t\n]   { printf("ay "); BEGIN(INITIAL); }

<prefixed_cons>{LETTER}*  { printf("%s", yytext); }
<prefixed_cons>[ \t \n]   { printf("%say ", prefix); BEGIN(INITIAL); prefix = ""; }

%%

int main(int argc, char** argv){
    yyin = stdin;
    yylex();
}
