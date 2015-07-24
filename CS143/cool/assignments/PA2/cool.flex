/*
 *  The scanner definition for COOLi.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */

%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;
char *string_buf_end = string_buf + MAX_STR_CONST - 1;
int comment_level = 0;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;


%}

 /*
  * Define names for regular expressions here.
  */
DARROW          =>

%x str
%x str_error
%x nested_comment
%%

  /* 
   * Comments:
   *    1. Any charaters between two dashes and the next newline (or EOF,
   *        if there is no next newline) are treated as comments
   *    2. Comments may also be written by enclosing (*...*)
   *    3. The latter form of comment my be nested
   *
   */


"*)"                        {
    cool_yylval.error_msg = "Unmatched Comment";
    return (ERROR);
}

"--".*\n                    {
    ++curr_lineno;
}

"--".*                      {}

"(*"                        {
    comment_level = 1;
    BEGIN(nested_comment);
}
<nested_comment>{
    <<EOF>>                 {
        BEGIN(INITIAL);
        cool_yylval.error_msg = "EOF in comment";
        return (ERROR);
    }

    "(*"                    {
        ++comment_level;    
    }

    \n                      {
        ++curr_lineno;       
    }
    "*)"                    {
        --comment_level;
        if(!comment_level){
            BEGIN(INITIAL);
        }

    }
    .                       {
        
    }
}

    /*
     * The multiple-character operators.
     */

{DARROW}                    {
    return (DARROW);    
}

"<="                        {
    return (LE);    
}

"<-"                        {
    return (ASSIGN);    
}

"+"                         {
    return '+';
}

"-"                         {
    return '-';    
}

"*"                         {
    return '*';    
}

"/"                         {
    return '/';    
}

"("                         {
    return '(';    
}

")"                         {
    return  ')';     
}

"="                         {
    return  '=';    
}

"<"                         {
    return '<';    
}

"."                         {
    return '.';    
}

"~"                         {
    return '~';    
}

","                         {
    return ',';    
}

";"                         {
    return ';';    
}

":"                         {
    return ':';    
}

"@"                         {
    return '@';    
}

"{"                         {
    return '{';    
}

"}"                         {
    return '}';
 }




(?i:class)                  {
    return (CLASS);    
}

(?i:else)                   {
    return (ELSE);    
}

(?i:fi)                     {
    return (FI);    
}

(?i:if)                     {
    return (IF);    
}

(?i:in)                     {
    return (IN);    
}

(?i:inherits)               {
    return (INHERITS);    
}

(?i:isvoid)                 {
    return (ISVOID);    
}

(?i:let)                    {
    return (LET);    
}

(?i:loop)                   {
    return (LOOP);    
}

(?i:pool)                   {
    return (POOL);    
}

(?i:then)                   {
    return (THEN);    
}

(?i:while)                  {
    return (WHILE);    
}

(?i:case)                   {
    return (CASE);    
}

(?i:esac)                   {
    return (ESAC);    
}

(?i:new)                    {
    return (NEW);    
}

(?i:of)                     {
    return (OF);    
}

(?i:not)                    {
    return (NOT);    
}

f(?i:alse)                  {
    cool_yylval.boolean = false;
    return (BOOL_CONST);
}

t(?i:rue)                   {
    cool_yylval.boolean = true;
    return (BOOL_CONST);
}
    /*
     * Integeres: non-empty strings of digits 0-9
     */
[0-9]+                     {
    cool_yylval.symbol = inttable.add_string(yytext);
    return (INT_CONST);
}

    /* Identifiers:
     *  - strings(other than keywords) consisting of letters, digits
          and the underscore character
        - type identifiers begin with a capital letter, object identifiers
          begin with a lower case letter
        - self and SELF_TYPE are identifiers treated specially by COOL,
          but are not treated as keywords
        - special syntactic symbols: parentheses, assignment operator, etc.
      */
[a-z][a-zA-Z0-9_]*   {
    cool_yylval.symbol = idtable.add_string(yytext);
    return (OBJECTID);
}

[A-Z][[A-Za-z0-9_]*     {
    cool_yylval.symbol = idtable.add_string(yytext);    
    return (TYPEID);
}

    /* string constants
       - enclosed in double quotes ".."
       - Within a string, a sequence '\c' denotes the character 'c'
         with the exception of the following:
            \b backspace
            \t tab
            \n newline
            \f formed
       - A non-escapted newline charater may not appear in a string
       - A string may not contain EOF
       - A string may not contain the null
       - Any other character may be included in a string
       - Strings cannot cross file boundaries
     */
\"                          {
    string_buf_ptr = string_buf;
    BEGIN(str);
}
<str>{
    \"                      {
        BEGIN(INITIAL);
        *string_buf_ptr = '\0';
        cool_yylval.symbol = stringtable.add_string(string_buf);
        return (STR_CONST);
    }    
    
    \n                      {
        BEGIN(INITIAL);
        ++curr_lineno;
        cool_yylval.error_msg = "Unterminated string constant";
        return (ERROR);
    }
    <<EOF>>                 {
        BEGIN(INITIAL);
        cool_yylval.error_msg = "Unterminated string constant";
        return (ERROR);
    }
 
    \\n                     {
        if(string_buf_ptr == string_buf_end){
            BEGIN(str_error);
            cool_yylval.error_msg = "String constant too long";
            return (ERROR);
        }
        *string_buf_ptr++ = '\n';
        ++curr_lineno;
    }

    \\t                     {
        if(string_buf_ptr == string_buf_end){
            BEGIN(str_error);
            cool_yylval.error_msg = "String constant too long";
            return (ERROR);
        }
        *string_buf_ptr++ = '\t';
    }

    \\b                     {
        if(string_buf_ptr == string_buf_end){
            BEGIN(str_error);
            cool_yylval.error_msg = "String constant too long";
            return (ERROR);
        }
        *string_buf_ptr++ = '\b';
    }
    \\f                     {
        if(string_buf_ptr == string_buf_end){
            BEGIN(str_error);
            cool_yylval.error_msg = "String constant too long";
            return (ERROR);
        }
        *string_buf_ptr++ = '\f';
    }

    (\0|\\\0)                                {
        BEGIN(str_error);
        cool_yylval.error_msg = "String contains null character";
        return (ERROR);
    }

    \\\n                         {
       if(string_buf_ptr == string_buf_end){
            BEGIN(str_error);
            cool_yylval.error_msg = "String constant too long";
            return (ERROR);
        }
        *string_buf_ptr++ = yytext[1];
        ++curr_lineno;
    }
    \\.                          {
        if(string_buf_ptr == string_buf_end){
            BEGIN(str_error);
            cool_yylval.error_msg = "String constant too long";
            return (ERROR);
        }
        *string_buf_ptr++ = yytext[1];
    }
    
    [^\\\n\"\0\\\0]+                                          {   
        char * yptr = yytext;
        while(string_buf_ptr != string_buf_end && *yptr){
            *string_buf_ptr++ = *yptr++;    
        }
        if(string_buf_ptr == string_buf_end && *yptr){
            BEGIN(str_error);
            cool_yylval.error_msg = "String constant too long";
            return (ERROR);
        }
        
    }
}

<str_error>.*[\"\n]             {
    BEGIN(INITIAL);   
}

\n                              {
    ++curr_lineno;
}

[ \r\t\b\f\v]                       {}

.                               {
         cool_yylval.error_msg = yytext;
         return (ERROR);
}

%%
