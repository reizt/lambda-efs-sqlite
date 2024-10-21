base=http://localhost:8000
out=tmp/out.json

get() {
  url=$1
  echo $url
  curl -X GET $base$url > $out
  jq . $out
}
post() {
  url=$1
  data=$2
  echo $url
  curl -X POST -H 'Content-Type: application/json' -d $data $base$url > $out
  jq . $out
}

mkdir -p tmp
post /users '{"name": "John Doe"}'
user_id=$(jq .id $out)
get /users
get /users/$user_id
post /posts '{"title": "Title", "content": "Hello World", "user_id": '$user_id'}'
post_id=$(jq .id $out)
get /posts
get /posts/$post_id
