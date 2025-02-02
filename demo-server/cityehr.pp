###
# Puppet Script for cityEHR on Ubuntu 24.04
###

$cityehr_version = '1.8.0-SNAPSHOT'
$cityehr_war_path = '/opt/tomcat/webapps/cityehr.war'

exec { 'download-cityehr':
  command => "curl -L https://openhealthinformatics.com/wp-content/resources/cityehr-webapp-${cityehr_version}.war -o ${cityehr_war_path}",
  path    => '/usr/bin',
  user    => 'tomcat',
  group   => 'tomcat',
  creates => $cityehr_war_path,
  require => [
    Package['file'],
    Package['curl'],
    Service['tomcat']
  ],
}
