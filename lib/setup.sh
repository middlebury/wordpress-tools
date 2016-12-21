#!/bin/bash

# Validate that we have the minimum to do setup.
if [ -z "$usage" ]; then
  echo "Error: usage must be defined before sourcing setup.sh"
  exit 10
fi
if [ -z "$wp_tools_path" ]; then
  echo "Error: wp_tools_path was not defined before sourcing setup.sh"
  exit 10
fi

# Print help for this script
if [[ $* == "*-h*" || $* == "*--help*" || $* == "*-?*" ]]; then
  echo "$usage"
  exit 1
fi

# Ensure our config file exits
if [ ! -f "$wp_tools_path/config.ini" ]; then
  echo "No configuration file found at: $wp_tools_path/config.ini"
  echo "Copy the config.ini.example to config.ini and edit it."
  exit 11
fi
config_file=$wp_tools_path/config.ini

# Ensure that the config-section parameter is passed and that it is one of our sections
config_section=$1
if [ -z "$config_section" ]; then
  echo "$usage"
  echo "    <config-section> must not be empty"
  exit 12
fi
sections=$($wp_tools_path/lib/ini_get_sections $config_file)
section_found=0
for section in $sections; do
  if [[ $section == $config_section ]]; then
    section_found=1
    break
  fi
done
if [[ $section_found -lt 1 ]]; then
  echo "$usage"
  echo "    <config-section> '$config_section' was not found in $config_file"
  exit 12
fi

# Load up our standard variables
dev_http_host=$($wp_tools_path/lib/ini_get_var $config_file $config_section 'dev_http_host')
if [ -z "$dev_http_host" ]; then
  echo "$usage"
  echo "    dev_http_host was not defined in section [$config_section] of $config_file"
  exit 13
fi

dev_http_path=$($wp_tools_path/lib/ini_get_var $config_file $config_section 'dev_http_path')
if [ -z "$dev_http_path" ]; then
  echo "$usage"
  echo "    dev_http_path was not defined in section [$config_section] of $config_file"
  exit 13
fi
# Trim off any trailing slashes
dev_http_path=${dev_http_path%/}


dev_fs_path=$($wp_tools_path/lib/ini_get_var $config_file $config_section 'dev_fs_path')
if [ -z "$dev_fs_path" ]; then
  echo "$usage"
  echo "    dev_fs_path was not defined in section [$config_section] of $config_file"
  exit 13
fi

dev_db_host=$($wp_tools_path/lib/ini_get_var $config_file $config_section 'dev_db_host')
if [ -z "$dev_db_host" ]; then
  echo "$usage"
  echo "    dev_db_host was not defined in section [$config_section] of $config_file"
  exit 13
fi

dev_db_database=$($wp_tools_path/lib/ini_get_var $config_file $config_section 'dev_db_database')
if [ -z "$dev_db_database" ]; then
  echo "$usage"
  echo "    dev_db_database was not defined in section [$config_section] of $config_file"
  exit 13
fi

dev_db_user=$($wp_tools_path/lib/ini_get_var $config_file $config_section 'dev_db_user')
if [ -z "$dev_db_user" ]; then
  echo "$usage"
  echo "    dev_db_user was not defined in section [$config_section] of $config_file"
  exit 13
fi

dev_db_password=$($wp_tools_path/lib/ini_get_var $config_file $config_section 'dev_db_password')
if [ -z "$dev_db_password" ]; then
  echo "$usage"
  echo "    dev_db_password was not defined in section [$config_section] of $config_file"
  exit 13
fi

prod_http_host=$($wp_tools_path/lib/ini_get_var $config_file $config_section 'prod_http_host')
if [ -z "$prod_http_host" ]; then
  echo "$usage"
  echo "    prod_http_host was not defined in section [$config_section] of $config_file"
  exit 13
fi

prod_http_path=$($wp_tools_path/lib/ini_get_var $config_file $config_section 'prod_http_path')
if [ -z "$prod_http_path" ]; then
  echo "$usage"
  echo "    prod_http_path was not defined in section [$config_section] of $config_file"
  exit 13
fi
# Trim off any trailing slashes
prod_http_path=${prod_http_path%/}

prod_fs_host=$($wp_tools_path/lib/ini_get_var $config_file $config_section 'prod_fs_host')
if [ -z "$prod_fs_host" ]; then
  echo "$usage"
  echo "    prod_fs_host was not defined in section [$config_section] of $config_file"
  exit 13
fi

prod_fs_path=$($wp_tools_path/lib/ini_get_var $config_file $config_section 'prod_fs_path')
if [ -z "$prod_fs_path" ]; then
  echo "$usage"
  echo "    prod_fs_path was not defined in section [$config_section] of $config_file"
  exit 13
fi

prod_fs_user=$($wp_tools_path/lib/ini_get_var $config_file $config_section 'prod_fs_user')
if [ ! -z "$prod_fs_user" ]; then
	prod_fs_user_prefix="${prod_fs_user}@"
else
	prod_fs_user_prefix=""
fi

# If we have a specific SSH key specified, make sure that we can read it and
# prep our variable for usage in the rsync command.
rsync_key=$($wp_tools_path/lib/ini_get_var $config_file $config_section 'rsync_key')
if [ ! -z "$rsync_key" ]; then
  if [ ! -r "$rsync_key" ]; then
    echo "$usage"
    echo "    rsync_key was specified, but the file specified at $rsync_key is not readable."
    exit 13
  fi
else
	rsync_key=""
fi

prod_db_host=$($wp_tools_path/lib/ini_get_var $config_file $config_section 'prod_db_host')
if [ -z "$prod_db_host" ]; then
  echo "$usage"
  echo "    prod_db_host was not defined in section [$config_section] of $config_file"
  exit 13
fi

prod_db_database=$($wp_tools_path/lib/ini_get_var $config_file $config_section 'prod_db_database')
if [ -z "$prod_db_database" ]; then
  echo "$usage"
  echo "    prod_db_database was not defined in section [$config_section] of $config_file"
  exit 13
fi

prod_db_user=$($wp_tools_path/lib/ini_get_var $config_file $config_section 'prod_db_user')
if [ -z "$prod_db_user" ]; then
  echo "$usage"
  echo "    prod_db_user was not defined in section [$config_section] of $config_file"
  exit 13
fi

prod_db_password=$($wp_tools_path/lib/ini_get_var $config_file $config_section 'prod_db_password')
if [ -z "$prod_db_password" ]; then
  echo "$usage"
  echo "    prod_db_password was not defined in section [$config_section] of $config_file"
  exit 13
fi
