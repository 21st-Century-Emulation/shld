docker build -q -t shld .
docker run --rm --name shld -d -p 8080:8080 -e WRITE_MEMORY_API=http://localhost:8080/api/v1/debug/writeMemory shld

sleep 5
RESULT=`curl -s --header "Content-Type: application/json" \
  --request POST \
  --data '{"opcode":42,"state":{"a":181,"b":0,"c":0,"d":0,"e":0,"h":25,"l":10,"flags":{"sign":false,"zero":false,"auxCarry":false,"parity":false,"carry":false},"programCounter":0,"stackPointer":0,"cycles":2}}' \
  http://localhost:8080/api/v1/execute\?highByte=1\&lowByte=3`
EXPECTED='{"opcode":42,"state":{"a":181,"b":0,"c":0,"d":0,"e":0,"h":25,"l":10,"flags":{"sign":false,"zero":false,"auxCarry":false,"parity":false,"carry":false},"programCounter":0,"stackPointer":0,"cycles":18}}'

docker kill shld

DIFF=`diff <(jq -S . <<< "$RESULT") <(jq -S . <<< "$EXPECTED")`

if [ $? -eq 0 ]; then
    echo -e "\e[32mSHLD Test Pass \e[0m"
    exit 0
else
    echo -e "\e[31mSHLD Test Fail  \e[0m"
    echo "$RESULT"
    echo "$DIFF"
    exit -1
fi