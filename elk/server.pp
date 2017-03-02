include ::stdlib
include ::apt


apt::source { 'jenkins':
  comment  => 'this is a docker repo',
  location => 'https://apt.dockerproject.org/repo',
  #release  => 'yakkety',
  release  => 'ubuntu-xenial',
  repos       => 'main',
    key         => {
      'id'     => '58118E89F3A912897C070ADBF76221572C52609D',
      'source' => 'https://apt.dockerproject.org/gpg',
    },
  include_src => false,
}

package { 'docker-engine':
  ensure => installed,
  require => Apt::Source['jenkins'],
}

file { '/data':
  ensure => directory,
} ~> file { '/data/data.csv':
    ensure => file,
    source => "/vagrant/data.csv"
  } ~> file { '/data/csvPipe.conf':
    ensure => file,
    source => "/vagrant/csvPipe.conf",
  } ~> file { '/data/transform.py':
    ensure => file,
    mode => "755",
    source => "/vagrant/transform.py"
  }

exec { 'transformdata':
  command      => '/usr/bin/python /data/transform.py',
  path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
  creates     => '/data/output.csv',
  require => File['/data/transform.py'],
}