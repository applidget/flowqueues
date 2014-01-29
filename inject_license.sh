
for i in `find . -name "*.coffee"` # or whatever other pattern...
do
  if ! grep -q Copyright $i
  then
    cat LICENSE $i >$i.new && mv $i.new $i
  fi
done
