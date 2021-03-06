#!/bin/bash

opt_restore=0
usage() {
  prg_name=`basename $0`
  cat <<EOM
  Usage: $prg_name [-h]
-r : rename golangenv* to goenv*
EOM
  exit 1
}

main() {
  local cmd="sed"
  local option="-i"

  case $OSTYPE in
    darwin*)
      option='-i "" -e'
      if which gsed >/dev/null 2>&1; then
        cmd="gsed"
        option="-i"
      fi
      ;;
  esac

  local from=goenv
  local to=golangenv
  local script=$(basename $0)
  if [ $opt_restore -eq 1 ]; then
    from=golangenv
    to=goenv
  fi
  for d in "bin libexec plugins"; do
    for f in $(find $d -name ".git" -prune -prune -o -type f); do
      if [ $(basename $f) == $script -o -d $f ]; then
        continue
      fi
      eval $cmd $option "s/$from/$to/g" $f
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

