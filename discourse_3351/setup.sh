ziti edge quickstart

ziti edge create identity server -o server.jwt
ziti edge enroll server.jwt

ziti edge create identity client -o client.jwt
ziti edge create config sample.intercept.v1 intercept.v1 '{"protocols":["tcp"],"addresses":["my.intercept.hostname"], "portRanges":[{"low":80, "high":80},{"low":443, "high":443}]}'
ziti edge create service sample --configs "sample.intercept.v1"

ziti edge create service-policy sample.bind Bind --identity-roles "@server" --service-roles "@sample"
ziti edge create service-policy sample.dial Dial --identity-roles "@client" --service-roles "@sample"

