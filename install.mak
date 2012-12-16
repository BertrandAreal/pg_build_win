#
# This script collects up PostgreSQL and its dependencies into a single
# install tree.
# 

libs-install: zlib-install

install: postgresql-install libs-install