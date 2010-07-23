/*

== Definition: openssl::certificate::x509

Creates a certificate, key and CSR according to datas provided.

Require class openssl::genx509

Parameters:
- *$ensure*:       ensure wether certif and its config are present or not
- *$country*:      certificate countryName
- *$state*:        certificate stateOrProvinceName
- *$locality*:     certificate localityName
- *$commonname*:   certificate CommonName
- *$altnames*:     certificate subjectAltName. Can be an array or a single string.
- *$organisation*: certificate organizationName
- *$unit*:         certificate organizationalUnitName
- *$email*:        certificate emailAddress
- *$days*:         certificate validity
- *$base_dir*:     where cnf, crt, csr and key should be placed. Directory must exist
- *$owner*:        cnf, crt, csr and key owner. User must exist

*/
define openssl::certificate::x509($ensure=present,
  $country,
  $state=false,
  $locality=false,
  $organisation,
  $commonname,
  $unit=false,
  $altnames=false,
  $email=false,
  $days=365,
  $base_dir='/etc/ssl/certs',
  $owner='root'
  ) {

  file {"${base_dir}/${name}.cnf":
    ensure  => present,
    owner   => $owner,
    content => template("openssl/cert.cnf.erb"),
  }

  case $ensure {
    'present': {
      File["${base_dir}/${name}.cnf"] {
        notify => Exec["create ${name} certificate"],
      }

      exec {"create ${name} certificate":
        creates => "${base_dir}/${name}.crt",
        user    => $owner,
        command => "/usr/local/sbin/generate-ssl-cert.sh ${name} ${base_dir}/${name}.cnf ${base_dir}/ ${days}",
        require => [File["${base_dir}/${name}.cnf"], Class['openssl::genx509']],
      }
    }

    'absent':{
      file {[
        "${base_dir}/${name}.crt",
        "${base_dir}/${name}.csr",
        "${base_dir}/${name}.key",
        ]:
        ensure => absent,
      }
    }

    default: { fail "Unknown \$ensure value: ${ensure}"}
  }
}
