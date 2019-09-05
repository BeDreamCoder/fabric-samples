#!/bin/bash

export FABRIC_CA_CLIENT_HOME=$GOPATH/src/github.com/hyperledger/fabric-samples/first-network/fabric-ca-client/admin

fabric-ca-client enroll -u http://admin:adminpw@localhost:7054
fabric-ca-client revoke -e peer2.org1.example.com -r removefromcrl --gencrl

cp -rf ./fabric-ca-client/admin/msp/crls ./crypto-config/peerOrganizations/org1.example.com/msp/crls
export FABRIC_CFG_PATH=$PWD && ../bin/configtxgen -printOrg Org1MSP > ./channel-artifacts/org1.json
