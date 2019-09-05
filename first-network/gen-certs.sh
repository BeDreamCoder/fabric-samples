#!/bin/bash

docker cp cli:/opt/gopath/src/github.com/hyperledger/fabric/peer/mychannel.block ./channel-artifacts/

FABRIC_CA_CLIENT=$GOPATH/src/github.com/hyperledger/fabric-samples/first-network/fabric-ca-client

export FABRIC_CA_CLIENT_HOME=$FABRIC_CA_CLIENT/admin

# enroll admin
fabric-ca-client enroll -u http://admin:adminpw@localhost:7054

# add affiliation
fabric-ca-client affiliation add com -M $FABRIC_CA_CLIENT_HOME/msp -u http://admin:adminpw@localhost:7054

fabric-ca-client affiliation add com.example -M $FABRIC_CA_CLIENT_HOME/msp -u http://admin:adminpw@localhost:7054

fabric-ca-client affiliation add com.example.org1 -M $FABRIC_CA_CLIENT_HOME/msp -u http://admin:adminpw@localhost:7054

# register peer
fabric-ca-client register --id.name peer2.org1.example.com --id.type peer --id.affiliation "com.example.org1" \
                    --id.attrs '"role=peer",ecert=true' --id.secret=peer2pw --csr.cn=peer2.org1.example.com \
                    --csr.hosts=['peer2.org1.example.com'] -M $FABRIC_CA_CLIENT_HOME/msp -u http://admin:adminpw@localhost:7054

export FABRIC_CA_CLIENT_HOME=$FABRIC_CA_CLIENT/peer2.org1.example.com

# gen msp
fabric-ca-client enroll -u http://peer2.org1.example.com:peer2pw@localhost:7054 -M $FABRIC_CA_CLIENT_HOME/msp

cp -rf ./crypto-config/peerOrganizations/org1.example.com/msp/admincerts ./fabric-ca-client/peer2.org1.example.com/msp/admincerts

cp -rf ./crypto-config/peerOrganizations/org1.example.com/msp/tlscacerts ./fabric-ca-client/peer2.org1.example.com/msp/tlscacerts

# gen tls
fabric-ca-client enroll -d --enrollment.profile tls -u http://peer2.org1.example.com:peer2pw@localhost:7054 \
                    --csr.cn=peer2.org1.example.com --csr.hosts=['peer2.org1.example.com'] -M $FABRIC_CA_CLIENT_HOME/tls

cp ./fabric-ca-client/peer2.org1.example.com/tls/keystore/* ./fabric-ca-client/peer2.org1.example.com/tls/server.key
cp ./fabric-ca-client/peer2.org1.example.com/tls/signcerts/* ./fabric-ca-client/peer2.org1.example.com/tls/server.crt
cp ./fabric-ca-client/peer2.org1.example.com/tls/tlscacerts/* ./fabric-ca-client/peer2.org1.example.com/tls/ca.crt
#cp ./crypto-config/peerOrganizations/org1.example.com/tlsca/tlsca.org1.example.com-cert.pem ./fabric-ca-client/peer2.org1.example.com/tls/ca.crt
