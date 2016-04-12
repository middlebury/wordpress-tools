# WordPress Tools

This package includes helper scripts for pulling sites down from production
to development in an incremental fashion since our WP installation is so big
and unwieldy.

## Configuration

Configure the scripts by copying `wordpress-tools/config.ini.example` to
`wordpress-tools/config.ini` and setting the appropriate values for each
installation you are working with. Each installation is defined as its own section
and you can define as many "production" sources and "dev" destinations as you need.

## Setup

To use these tools, add the wordpress-tools/bin directory to your PATH
environmental variable. Usually this is done by adding the following to
your .bash_profile:

    export PATH=$PATH:$HOME/path/to/wordpress-tools/bin

When you start a new bash shell, the scripts will be in your path and you can
call them directly without specifying the full path.

## Usage

Normally, you will want to use the `wp_refresh` and `wp_refresh_single`
commands to refresh a default set of sites or a single site by id.

For example, to refresh the default set of testing sites for the "midd" section, run:

    wp_refresh_configured midd

To refresh a single site with id "2639" in the "midd" section, run:

    wp_refresh_single midd 2639

To refresh several sites with ids "2639", "3121", and "2134" in the "midd" section, run:

    wp_refresh midd 2639 3121 2134

Note that wp_refresh also supports being piped a list of ids to refresh. This
allows command-chains like the following, which would refresh all sites using
the "widget-shortcode" plugin in the "midd" installation:

    wp_get_sites_using_plugin midd widget-shortcode | awk '{print $1;}' | wp_refresh midd
