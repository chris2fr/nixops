for i in alice bob bind sogo fossil 
do
  echo $i
  cp .secrets.$i{,`date -I`}
  pwgen -c -n -y -r "\"',|\$\`" -B -1 10 > .secrets.$i
done