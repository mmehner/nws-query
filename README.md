# nws-query
query [Nachtragswörterbuch des Sanskrit (NWS)](https://nws.uzi.uni-halle.de/) with Emacs and keep a slim backlog of your queries locally.

## Dependencies
- w3m
- emacs-w3m (available on [MELPA](https://melpa.org/#/w3m))
- sed

## Installation
### Emacs
1. Add `nws-query.el` to a directory included in the list `load-path` or modify this list to include the directory with
   `(add-to-list 'load-path "/PATH/TO/nws-query/")` in your init file,
2. add `(require 'nws-search)` to your init-file,
3. (optional) if you wish to keep a local backlog of your queries, set the variable `nwslocal` to the directory you wish to use a local database and keep your backlog in, e.g. `(setq nws-local "PATH/TO/nws/")`.

### Shell (Bash)
1. (Optional) set the environmental variable `nwslocal` to the directory holding your local database by adding `export nwslocal="/PATH/TO/NWS/"` to a file that is sourced by bash at startup, most commonly `.bashrc` in your home directory.

## Usage
### General remarks
1. Both the emacs function `nws-query` and the bash script `nws-query.sh` search your local database/backlog first as this will yield results faster. If the variable `nwslocal` either isn't set or if the searchstring is not in this local database, the function will fall back to online search. So if you want to use online search exclusively, just don't set the variable(s), if you want to systematically scrape for offline searching, you can use the shell-script `nws-scrape.sh /PATH/TO/nws/` with a local directory that will serve as your local database; this will take several hours but can be interrupted and continued at any time.
2. The query can be input in IAST or Harvard-Kyoto but will invariably be saved as a file named "NWS_" plus the search term in Harvard-Kyoto if `nwslocal` is set.

### Emacs
1. Evaluate the main provided function with `M-x nws-query`, browse the opening dictionary frame, close by pressing `q`,
2. (optional) if you are frequently using one or the other function, consider [creating a keybinding](https://www.gnu.org/software/emacs/manual/html_node/elisp/Key-Binding-Commands.html).

### Shell (Bash)
1. Execute `nws-query.sh` with the search term in Harvad-Kyoto as the first argument.
