#!/bin/bash

peer channel join -o orderer.example.com:7050 -b ./channel-artifacts/mychannel.block

peer chaincode install -n mycc -v 1.0 -p github.com/chaincode/chaincode_example02/go/

sleep 10

peer chaincode query -C mychannel -n mycc -c '{"Args":["query","a"]}'

peer chaincode invoke -o orderer.example.com:7050 -C mychannel  -n mycc --peerAddresses peer2.org1.example.com:11051 --peerAddresses peer0.org2.example.com:9051 -c '{"Args":["invoke","a","b","10"]}'