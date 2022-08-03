
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

### Configure the AIA
certutil -setreg CA\CACertPublicationURLs "1:C:\Windows\system32\CertSrv\CertEnroll\%1_%3%4.crt\n2:ldap:///CN=%7,CN=AIA,CN=Public Key Services,CN=Services,%6%11\n2:http://pki.Itoutbreak.net/CertEnroll/%1_%3%4.crt"

certutil -getreg CA\CACertPublicationURLs

### Configure the CDP
certutil -setreg CA\CRLPublicationURLs "1:C:\Windows\system32\CertSrv\CertEnroll\%3%8%9.crl\n10:ldap:///CN=%7%8,CN=%2,CN=CDP,CN=Public Key Services,CN=Services,%6%10\n2:http://pki.Itoutbreak.net/CertEnroll/%3%8%9.crl"

certutil -getreg CA\CRLPublicationURLs

### Create CAPolicy.inf for Enterprise Root CA

[Version]

Signature="$Windows NT$"

[PolicyStatementExtension]

Policies=InternalPolicy

[InternalPolicy]

OID= 1.2.3.4.1455.67.89.5

URL=http://pki.Itoutbreak.net/cps.txt

[Certsrv_Server]

RenewalKeyLength=2048

RenewalValidityPeriod=Years

RenewalValidityPeriodUnits=10

LoadDefaultTemplates=0

AlternateSignatureAlgorithm=0