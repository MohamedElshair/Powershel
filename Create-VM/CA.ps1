
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

### To define CRL Period Units and CRL Period, run the following commands from an administrative command prompt:
Certutil -setreg CA\CRLPeriodUnits 52
Certutil -setreg CA\CRLPeriod "Weeks"
Certutil -setreg CA\CRLDeltaPeriodUnits 0

### To define CRL Overlap Period Units and CRL Overlap Period, run the following commands from an administrative command prompt:
Certutil -setreg CA\CRLOverlapPeriodUnits 12
Certutil -setreg CA\CRLOverlapPeriod "Hours"

### To define Validity Period Units for all issued certificates by this CA, type following command and then press Enter. In this lab, the Enterprise Issuing CA should receive a 10 year lifetime for its CA certificate. To configure this, run the following commands from an administrative command prompt:
Certutil -setreg CA\ValidityPeriodUnits 10
Certutil -setreg CA\ValidityPeriod "Years"
