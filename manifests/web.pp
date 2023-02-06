$packages = [ 'httpd', 'php', 'php-mysqlnd', 'git']

package { $packages: }

vcsrepo { '/code':
  ensure   => present,
  provider => git,
  source   => 'https://github.com/shekeriev/do2-app-pack.git',
}

file { '/var/www/app1':
  ensure  => present,
  recurse => true,
  source  => "/code/app1/web/",
}

file { '/var/www/app4':
  ensure  => present,
  recurse => true,
  source  => "/code/app4/web/",
}

class { 'firewall': }

firewall { '000 accept 8081/tcp':
  action   => 'accept',
  dport    => 8081,
  proto    => 'tcp',
}

firewall { '000 accept 8082/tcp':
  action   => 'accept',
  dport    => 8082,
  proto    => 'tcp',
}

file {'/etc/httpd/conf.d/vhost-app1.conf':
  ensure  => present,
  content => 'Listen 8081
  <VirtualHost  *:8081>
    DocumentRoot "/var/www/app1"
  </VirtualHost>',
}

file {'/etc/httpd/conf.d/vhost-app4.conf':
  ensure  => present,
  content => 'Listen 8082
  <VirtualHost  *:8082>
    DocumentRoot "/var/www/app4"
  </VirtualHost>',
}

file_line { 'hosts-web':
    ensure => present,
    path   => '/etc/hosts',
    line   => '192.168.99.101  web.do2.lab  web',
    match  => '^192.168.99.101',
}

file_line { 'hosts-db':
    ensure => present,
    path   => '/etc/hosts',
    line   => '192.168.99.102  db.do2.lab  db',
    match  => '^192.168.99.102',
}

class { selinux:
    mode => 'permissive',
}

service { httpd:
  ensure => running,
  enable => true,
}
