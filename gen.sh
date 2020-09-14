#!/bin/sh

for run in {1..10}
do
    pri=$(wg genkey)
    pub=$(echo "$pri" | wg pubkey)
    echo "  {"
    echo "    name: '',"
    echo "    ip: '10.10.10.xxx',"
    echo "    private: '$pri',"
    echo "    public: '$pub',"
    echo "  },"
done
