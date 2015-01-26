#!/bin/bash

opt_restore=0
usage() {
  prg_name=`basename $0`
  cat <<EOM
  Usage: $prg_name [-h]
-r : rename genv* to goenv*
EOM
  exit 1
}

main() {
  local from=goenv
  local to=genv
  local script=$(basename $0)
  if [ $opt_restore -eq 1 ]; then
    from=genv
    to=goenv
  fi
  for d in "bin libexec plugins"; do
    for f in $(find $d -name ".git" -prune -prune -o -type f); do
      if [ $(basename $f) == $script -o -d $f ]; then
        continue
      fi
      sed -i "s/$from/$to/g" $f
      mv $f $(echo $f | sed "s/$from/$to/")
    done
  done
  cd bin
  rm $from
  ln -s ./../libexec/$to $to
}

OPTIND_OLD=$OPTIND
OPTIND=1
while getopts "hr" opt; do
  case $opt in
    h) usage ;;
    r) opt_restore=1;;
  esac
done
shift `expr $OPTIND - 1`
OPTIND=$OPTIND_OLD
if [ $OPT_ERROR ]; then
  usage
fi

main "$@"

