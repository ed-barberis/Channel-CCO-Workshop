#!/bin/sh -eux
# install oracle mysql shell command-line utility on centos stream 8 linux.

# set default value for cco lab devops home environment variable if not set. -----------------------
devops_home="${devops_home:-/opt/cco-lab-devops}"           # [optional] devops home (defaults to '/opt/cco-lab-devops').

# create scripts directory (if needed). ------------------------------------------------------------
mkdir -p ${devops_home}/provisioners/scripts/centos
cd ${devops_home}/provisioners/scripts/centos

# install mysql shell. -----------------------------------------------------------------------------
mysqlsh_release="8.0.37-1"
mysqlsh_binary="mysql-shell-${mysqlsh_release}.el8.x86_64.rpm"
mysqlsh_checksum="3dabd25d0a5fc8053cae2025b1a09c66"

# download mysql shell repository.
rm -f ${mysqlsh_binary}
wget --no-verbose --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" https://dev.mysql.com/get/Downloads/MySQL-Shell/${mysqlsh_binary}

# verify the downloaded binary using the md5 checksum.
echo "${mysqlsh_checksum} ${mysqlsh_binary}" | md5sum --check -
# mysql-shell-${mysqlsh_release}.el8.x86_64.rpm: OK

# install mysql shell. -----------------------------------------------------------------------------
dnf -y install ${mysqlsh_binary}

# verify mysql shell installation.
mysqlsh --version

# mysqlsh command-line examples. -------------------------------------------------------------------
# MySQL Shell User Guide
#   This is the MySQL Shell User Guide extract from the MySQL 8.0 Reference Manual.
#   https://dev.mysql.com/doc/mysql-shell-excerpt/8.0/en/
#
#   For help with using MySQL, please visit either the MySQL Forums or MySQL Mailing Lists,
#   where you can discuss your issues with other MySQL users.
#
# Example Usage:
#   $ mysqlsh
#   MySQL JS > \connect root@localhost:3306
#   MySQL JS > \sql
#   MySQL JS > show databases;
#   MySQL JS > \use mysql
#   MySQL JS > show tables;
#   MySQL JS > \exit
