
### Create a CAPolicy.inf for the standalone offline root CA

[Version]

Signature="$Windows NT$"

[Certsrv_Server]

RenewalKeyLength=2048 ; recommended 4096

RenewalValidityPeriod=Years

RenewalValidityPeriodUnits=20

AlternateSignatureAlgorithm=0


### To define Active Directory Configuration Partition Distinguished Name
Certutil -setreg CA\DSConfigDN "CN=Configuration,DC=Itoutbreak,DC=net"

