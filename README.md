# vim-simpledb

Vim plugin to execute postgresql commands from VIM buffer

## Installation

### Pathogen

If you use git submodules, run this command from your .vim folder:

    git submodule add https://github.com/Azorej/vim-simpledb bundle/simpledb

Otherwise, , run this command from your .vim folder:

    git clone https://github.com/Azorej/vim-simpledb bundle/simpledb

### Vundle

Add this line to your vimrc

    Bundle 'Azorej/vim-simpledb'

## Usage

Default key mapping for execution: `<enter>`.

1. Create new file with .sql extension (without extensions, mapping would not work)

2. Create first line with commented parameters:

    `-- -h localhost -U postgres -d my_database`

    Note: if you don't want to enter password each time, you should create .pgpass (.my.cnf for mysql) file

    There is also usefull key `-q` to avoid messages like 'Timing is on' etc.

3. Add sql statements to your file

4. Hit `<enter>` to execute all not commented queries

5. Hit `<leader><enter>` to execute all queries in the current paragraph

6. Select multiple lines in visual mode and hit `<enter>` to execute just those queries

## Configuration

If you do not want timings to be displayed, add this to your `.vimrc`:

    let g:simpledb_show_timing = 0
