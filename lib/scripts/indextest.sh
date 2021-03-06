#! /bin/bash
# indextest.sh
# Diagnostic program to show how a set of marc records would be indexed,
# without actually adding any records to Solr.
# $Id: indextest.sh 

# marquis, 11/2013
# discussion:
#   https://groups.google.com/forum/#!topic/solrmarc-tech/Q7uYebjRjd8
# source:
#   https://code.google.com/p/solrmarc/source/browse/trunk/script_templates/indextest

# Example run:
# % pwd
# /Users/marquis/src/clio-spectrum
# % lib/scripts/indextest.sh  tmp/extracts/spectrum_subset/current/subset.mrc  config/SolrMarc/config.properties  
# 


E_BADARGS=65

scriptdir=$( (cd -P $(dirname $0) && pwd) )
if ! [ -e $scriptdir/SolrMarc.jar ] 
then
  scriptdir=$( (cd -P $(dirname $0)/.. && pwd) )
fi

if ! [ -p /dev/stdin ]
then  
  if [ $# -eq 0 ]
  then
    echo "    Usage: `basename $0` [config.properties] ./path/to/marc.mrc "
    echo "      Note that if the config.properties file is not specified the Jarfile will be searched for"
    echo "      a file whose name ends with \"config.properties\""
    exit $E_BADARGS
  fi
fi

# another variant???
# java -Dmarc.just_index_dont_add="true" -jar $scriptdir/SolrMarc.jar $1 $2 $3 

java -Dsolrmarc.main.class="org.solrmarc.marc.MarcPrinter" -jar $scriptdir/SolrMarc.jar index $1 $2 $3 $4 $5 $6

exit 0

