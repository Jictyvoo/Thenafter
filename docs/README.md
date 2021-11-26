# Thenafter

> **Archived**
> 
> This project was reestructured and refactored in Dart-lang, see [thenafter-dart](https://github.com/Jictyvoo/thenafter-dart)

This is a BNF parser to generate a First and Follow tables.

## How to use

* Download the release, and open in the command terminal like

<pre>
    thenafter grammar.file
</pre>

* Then, will be generated a file with the table for the first and follow
* WARNING -> The program is case sensitive

## Specifying the language generated

Use the --l flag, and write the language extension name after the flag, like:
<pre>
    thenafter grammar.file --l java
</pre>
The default extension generated is a .lua file

## Singletone Flags

These flags doesn't need a argument to work. Below will be some ones

* Production -> This flag is used to generate the production object in the requested language.

<pre>--p</pre>
