
### Create a CAPolicy.inf for the standalone offline root CA

[Version]
Signature=”$Windows NT$”
[PolicyStatementExtension]
Policies=InternalPolicy
[InternalPolicy]
OID= 1.2.3.4.1455.67.89.5
[Certsrv_Server]
RenewalKeyLength=4096
RenewalValidityPeriod=Years
RenewalValidityPeriodUnits=20
CRLPeriod=Years
CRLPeriodUnits=20
CRLDeltaPeriod=Days
CRLDeltaPeriodUnits=0
LoadDefaultTemplates=0


### To define Active Directory Configuration Partition Distinguished Name ###
Certutil -setreg CA\DSConfigDN "CN=Configuration,DC=Itoutbreak,DC=net"
Certutil -setreg CA\DSDomain "dc=itoutbreak,dc=net"

### To define CRL Overlap Period Units and CRL Overlap Period ###
Certutil -setreg CA\CRLOverlapPeriodUnits 3
Certutil -setreg CA\CRLOverlapPeriod "Weeks"

### To define Validity Period Units for all issued certificates by this CA ###
Certutil -setreg CA\ValidityPeriodUnits 10
Certutil -setreg CA\ValidityPeriod "Years"


### Configure the AIA ###
certutil -setreg CA\CACertPublicationURLs "1:C:\Windows\system32\CertSrv\CertEnroll\%1_%3%4.crt\n2:ldap:///CN=%7,CN=AIA,CN=Public Key Services,CN=Services,%6%11\n2:http://pki.Itoutbreak.net/CertEnroll/%1_%3%4.crt"

certutil -getreg CA\CACertPublicationURLs

### Configure the CDP ###
certutil -setreg CA\CRLPublicationURLs "1:C:\Windows\system32\CertSrv\CertEnroll\%3%8%9.crl\n10:ldap:///CN=%7%8,CN=%2,CN=CDP,CN=Public Key Services,CN=Services,%6%10\n2:http://pki.Itoutbreak.net/CertEnroll/%3%8%9.crl"

certutil -getreg CA\CRLPublicationURLs


### To define CRL Period Units and CRL Period
Certutil -setreg CA\CRLPeriodUnits 52
Certutil -setreg CA\CRLPeriod "Weeks"
Certutil -setreg CA\CRLDeltaPeriodUnits 0



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


### Publish the Root CA Certificate and CRL
certutil -f -dspublish "A:\CA01_Fabrikam Root CA.crt" RootCA
certutil -f -dspublish "A:\Fabrikam Root CA.crl" RootCA

### To add  Root CA Certificate and CRL in local store
certutil -addstore -f root "CA01_Itoutbreak Root CA.crt"
certutil -addstore -f root "Itoutbreak Root CA.crl"


### Perform Post Installation Configuration Tasks on the Subordinate Issuing CA

Certutil -setreg CA\CRLPeriodUnits 1
Certutil -setreg CA\CRLPeriod "Weeks"
Certutil -setreg CA\CRLDeltaPeriodUnits 1
Certutil -setreg CA\CRLDeltaPeriod "Days"
### Define CRL overlap settings by running the following command from an administrative command prompt:
Certutil -setreg CA\CRLOverlapPeriodUnits 12
Certutil -setreg CA\CRLOverlapPeriod "Hours"

Certutil -setreg CA\ValidityPeriodUnits 5
Certutil -setreg CA\ValidityPeriod "Years"