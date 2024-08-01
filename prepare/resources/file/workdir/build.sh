# install packages
install_pkg=$(realpath "./install_pkg.sh")
include_pkg=''
exclude_pkg=''
bash $install_pkg -i -d $(realpath 'linglong/sources') -p $PREFIX -I \"$include_pkg\" -E \"$exclude_pkg\"

## build-from-source
## build-from-source/

# uninstall dev packages
bash $install_pkg -u -r '\-dev'
