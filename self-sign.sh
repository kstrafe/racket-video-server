#! /usr/bin/env bash
openssl req -x509 -newkey rsa:4096 -keyout private-key.pem -out server-cert.pem -days 365
