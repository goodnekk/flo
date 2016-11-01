/* lexical grammar */



%lex

	%{
		if(!yy.indentstack){
			yy.indentstack = [0];
		}
	%}

%%
/* control logic */
'when'                return 'WHEN';
'then'                return 'THEN';
'else'                return 'ELSE';
'unfold'              return 'UNFOLD';
'as'                  return 'AS';

/* operators */
':'                   return 'SET';
','                   return 'COMMA';
'('                   return 'LP';
')'                   return 'RP';
'['                   return 'LBR';
']'                   return 'RBR';
'->'                  return 'FNC';
'#'                   return 'UNFOLDER';

/* math */
'+'                   return 'ADD';
'-'                   return 'MIN';
'*'                   return 'TIMES';
'/'                   return 'DIVIDE';

/* boolean logic */
'=='                  return 'IS';
'is'                  return 'IS';
'!='                  return 'ISNT';
'isnt'                return 'IS';
'!'                   return 'NOT';
'not'                 return 'NOT';
'>'                   return 'LARGER';
'<'                   return 'SMALER';
'>='                  return 'LARGERORIS';
'<='                  return 'SMALERORIS';
'and'                 return 'AND';
'&&'                  return 'AND';

/* literals and variables */
[0-9]+("."[0-9]+)?\b  return 'NUMBER';
\"[^\"]*\"            return 'STRING';
'true'                return 'TRUE';
'false'               return 'FALSE';
[a-zA-Z]+             return 'ID';

/* whitespace */
(\r\n|\r|\n)[ \t]*(?=(\r\n|\r|\n)) /* consume empty lines */
(\r\n|\r|\n)[ \t]*	%{ /* deal with indentation */
							var current = yy.indentstack[0]; //get the current indentation level
							yytext = yytext.replace(/^(\r\n|\r|\n)+/, ''); //remove line break characters
							var indent = yytext.length; //count amount of indents

							var tokens = ['EOL'];
							if(indent > current){
								yy.indentstack.unshift(indent);
								tokens.unshift('INDENT');
								return tokens;
							}
							if(indent < current){
								while(indent < current){
									tokens.unshift('DEDENT');
									tokens.unshift('EOL');

									yy.indentstack.shift();
									current = yy.indentstack[0];
								}

								return tokens;
							}
							return 'EOL';
					%}

<<EOF>>               return 'EOF';
\s+ 	              /*ignore all other whitespace*/

/lex

%options token-stack
%ebnf

%right UNFOLDER
%left FNC
%left UNFOLD AS
%left ADD MIN
%left TIMES DIVIDE
%left IS ISNT LARGER SMALLER LARGERORIS SMALLERORIS
%left WHEN THEN ELSE



%start PROGRAM

%% /* language grammar */

PROGRAM
    : LINES EOF
        {return $1}
    ;

LINES
    : LINE EOL
        {$$ = [$1];}
    | LINE EOL LINES
        {$$ = [$1].concat($3);}
    ;

BLOCK
    : INDENT LINES DEDENT
        {$$ = $2;}
    ;

LINE
    : MAPPING
        {$$ = $1;}
    | WHENSTATEMENT
        {$$ = $1;}
    | E
        {$$ = $1;}
    | EOL
        {}
    ;

MAPPING
    : ID SET E
        {$$ = {type: "mapping", id: $1, expression: $3}}
    ;

E
    : ID
        {$$={type: "id", val: $1}}
    | NUMBER
        {$$={type: "flow", val: $1}}
    | STRING
        {$$={type: "flow", val: $1}}
    | BOOLEAN
        {$$={type: "flow", val: $1}}
    | LP ARGUMENTLIST RP FNC E
        {$$ = {type: "mapper", args: $2, expression:[$5]}}
    | ID LP LIST RP
        {$$ = {type: "expression", mod: $1, args: $3}}
    | ID LP RP
        {$$ = {type: "expression", mod: $1, args: []}}
    | WHEN E SET E ELSE SET E
        {$$ = {type: "when", expression: $2, then: $4, else: $7}}
	| WHEN E SET E EOL ELSE SET E
        {$$ = {type: "when", expression: $2, then: $4, else: $8}}
    | E ADD E
        {$$ = {type: "stdexpression", mod: "add", args: [$1,$3]}}
    | E MIN E
        {$$ = {type: "stdexpression", mod: "min", args: [$1,$3]}}
    | E TIMES E
        {$$ = {type: "stdexpression", mod: "mult", args: [$1,$3]}}
    | E DIVIDE E
        {$$ = {type: "stdexpression", mod: "div", args: [$1,$3]}}
    | E IS E
        {$$ = {type: "stdexpression", mod: "is", args: [$1,$3]}}
    | E LARGER E
        {$$ = {type: "stdexpression", mod: "smaller", args: [$1,$3]}}
    | E SMALLER E
        {$$ = {type: "stdexpression", mod: "larger", args: [$1,$3]}}
    | E LARGERORIS E
        {$$ = {type: "stdexpression", mod: "smalleroris", args: [$1,$3]}}
    | E SMALLERORIS E
        {$$ = {type: "stdexpression", mod: "largeroris", args: [$1,$3]}}
	| LBR LIST RBR
		{$$ = {type: "array", val:$2 }}
	| UNFOLD ID AS ID SET E
		{$$ = {type: "unfold", array:$2, id:$4, expression: $6}}
	| EOL BLOCK
		{$$ = {type: "block", array:$2}}
    ;

BOOLEAN
    : TRUE
        {$$ = true}
    | FALSE
        {$$ = false}
    ;

ARGUMENTLIST
	: ID
		{$$ = [$1];}
	| ID COMMA ARGUMENTLIST
		{$$ = [$1].concat($3);}
	;

LIST
    : E
        {$$ = [$1];}
    | E COMMA LIST
        {$$ = [$1].concat($3);}
    ;
