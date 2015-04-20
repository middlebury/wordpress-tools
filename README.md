# WordPress Tools

This package includes helper scripts for pulling sites down from production to development in an incremental
fashion since our WP installation is so big and unwieldy.

## Configuration

Configure the scripts by copying `wordpress-tools/config.ini.example` to `wordpress-tools/config.ini` and
setting the appropriate values for each installation you are working with. Each installation is defined as
its own section and you can define as many "production" sources and "dev" destinations as you need.

    [midd]
    ; Destination to import data into.
    dev_http_host     = anvil.middlebury.edu
    dev_http_path     = "/~afranco/wordpress/"
    dev_fs_path       = /home/afranco/private_html/wordpress/wordpress/
    dev_db_host       = localhost
    dev_db_database   = afranco_wordpress_midd
    dev_db_user       = testuser
    dev_db_password   = testpassword

    ; Location to source data from.
    prod_http_host    = sites.middlebury.edu
    prod_http_path    = /
    prod_fs_host      = orator.middlebury.edu
    prod_fs_path      = /var/www/wordpress-mu/
    prod_fs_user      =                           ; Might be 'root' or some other account, defaults to the current user account
    prod_db_host      = snipe.middlebury.edu
    prod_db_database  = wordpress
    prod_db_user      = wad_export_ro
    prod_db_password  = password

## Setup

To use these tools, add the wordpress-tools/bin directory to your PATH environmental variable. Usually this 
is done by adding the following to your .bash_profile:

    export PATH=$PATH:$HOME/path/to/wordpress-tools/bin

When you start a new bash shell, the scripts will be in your path and you can call them directly without 
specifying the full path.

## Usage

Normally, you will want to use the `wp_refresh` and `wp_refresh_single` commands to refresh a default set of sites or
a single site by id.

For example, to refresh the default set of testing sites for the "midd" section, run:

    wp_refresh midd

To refresh a single site with id "2639" in the "midd" section, run:

    wp_refresh_single midd 2639