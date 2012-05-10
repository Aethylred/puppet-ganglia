# NeSI Manifest to install the Ganglia web front end
#
# Do NOT use directly: use ganglia::webfrontend

class ganglia::webfrontend::install {

  include web::apache
  include web::apache::mod_php
  include ganglia::parameters

  # Need to figure out if the metaserver is a requirement for the webfrontend
  # include ganglia::metaserver

# We are going to install the 'latest stable' from the ganglia site
  package{$ganglia::parameters::webfrontend_package:
    ensure => purged,
  }

}