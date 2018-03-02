
set -e;

cd "$HOME"

mkdir -p "$HOME/.quicklock/locks"

curl https://rawgit.com/oresoftware/quicklock/master/install.sh --output "$HOME/.quicklock/ql.sh"

echo "To complete installation of 'quicklock' add the following line to your .bash_profile file:";

echo ". \"$HOME/.quicklock/ql.sh\"";

