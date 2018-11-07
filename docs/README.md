# Thenafter

This is a BNF parser to generate a First and Follow tables.

## How to use

* Download the release, and open in the command terminal like
<pre>
    thenafter grammar.file
</pre>
* Then, will be generated a file with the table for the first and follow

## Specifying the language generated

Use the --l flag, and write the language extension name after the flag, like:
<pre>
    thenafter grammar.file --l java
</pre>
The default extension generated is a .lua file
