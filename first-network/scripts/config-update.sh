#!/bin/bash

export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export CHANNEL_NAME=mychannel

peer channel fetch config config_block.pb -o orderer.example.com:7050 -c $CHANNEL_NAME

configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json

jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"Org1MSP":.[1]}}}}}' config.json ./channel-artifacts/org1.json > modified_config.json

configtxlator proto_encode --input config.json --type common.Config --output config.pb

configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb

configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_config.pb --output org1_update.pb

configtxlator proto_decode --input org1_update.pb --type common.ConfigUpdate | jq . > org1_update.json

echo '{"payload":{"header":{"channel_header":{"channel_id":"mychannel", "type":2}},"data":{"config_update":'$(cat org1_update.json)'}}}' | jq . > org1_update_in_envelope.json

configtxlator proto_encode --input org1_update_in_envelope.json --type common.Envelope --output org1_update_in_envelope.pb

peer channel signconfigtx -f org1_update_in_envelope.pb

export CORE_PEER_LOCALMSPID="Org2MSP"

export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp

export CORE_PEER_ADDRESS=peer0.org2.example.com:9051

peer channel update -f org1_update_in_envelope.pb -c $CHANNEL_NAME -o orderer.example.com:7050