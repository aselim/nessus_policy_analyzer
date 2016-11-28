# nessus_policy_analyzer

This may not be the best coding or tool, However it is a quick script it helped me to fullfill a request of on of my customer during a consultation course....So fill free to use it.

This a simple analyzer for Nessus Policy, It is developed as need to analyze nessus policy for one of my customer as requirement for PCI-QSA to ensure that Policy is covering important vulnerability scans

Script list the disabled families & the diabled plugins and there Severity (Risk Factor) and the output file is .CSV that can be filtered using spreadsheets to filter on Critical,High, Medium severities and comply the policy as per the PCI-DSS

Note: This is sample script, done for specific need may be used and develop it more maturity

# Usaga:

- npa.sh nessus_policy.nessus

# Prerequisities:

- install xmlstarlet package