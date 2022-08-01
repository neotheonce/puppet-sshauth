# sshauth::key::master
#
# Create/regenerate/remove a key pair on the keymaster.
# This definition is private, i.e. it is not intended to be called directly by users.
# ssh::auth::key calls it to create virtual keys, which are realized in ssh::auth::keymaster.

define sshauth::key::master (
    String            $ensure  = 'present',
    Boolean           $force   = false,
    Optional[String]  $keytype = undef,
    Optional[Integer] $length  = undef,
    Optional[String]  $maxdays = undef,
    Optional[String]  $mindate = undef,
) {
    include sshauth::params
    
    Exec { path => '/usr/bin:/usr/sbin:/bin:/sbin' }
    
#    File {
#        owner => 'puppet',
#        group => 'puppet',
#        mode  => '0600',
#    }

    $keydir  = "${sshauth::params::keymaster_storage}/${name}"
    $keyfile = "${keydir}/key"

    file { $keydir:
        ensure => directory,
        mode   => '0644',
        owner  => 'puppet',
        group  => 'puppet',
    }
    
    file { $keyfile:
        ensure => $ensure,
        mode   => '0600',
        owner  => 'puppet',
        group  => 'puppet',
    }
    
    file { "${keyfile}.pub":
        ensure => $ensure,
        mode   => '0644',
        owner  => 'puppet',
        group  => 'puppet',
    }

    if $ensure == 'present' {
    # Remove the existing key pair, if
    # * $force is true, or
    # * $maxdays or $mindate criteria aren't met, or
    # * $keytype or $length have changed
        $reason = ''
        $keycontent = file("${keyfile}.pub", '/dev/null')
        if ! empty($keycontent) {
            if $force {
                $reason = 'force=true'
            }
            
            if !$reason and !empty($mindate) and generate('/usr/bin/find', $keyfile, '!', '-newermt', "${mindate}") {
                $reason = "created before ${mindate}"
            }
            
            if !$reason and !empty($maxdays) and generate('/usr/bin/find', $keyfile, '-mtime', "+${maxdays}") {
                $reason = "older than ${maxdays} days"
            }
            
            if !$reason and $keycontent =~ /^ssh-... [^ ]+ (...) (\d+)$/ {
                if $keytype != $1 {
                    $reason = "keytype changed: $1 -> ${keytype}"
                } else {
                    if $length != Integer($2) {
                        $reason = "length changed: $2 -> ${length}"
                    }
                }
            }
            
            if !empty($reason) {
                exec { "Revoke previous key ${name}: ${reason}":
                    command => "rm ${keyfile} ${keyfile}.pub",
                    before  => Exec["Create key ${name}: ${keytype}, ${length} bits"],
                }
            }
        }

        # Create the key pair.
        # We "repurpose" the comment field in public keys on the keymaster to
        # store data about the key, i.e. $keytype and $length.  This avoids
        # having to rerun ssh-keygen -l on every key at every run to determine
        # the key length.
        exec { "Create key ${name}: ${keytype}, ${length} bits":
            command => "ssh-keygen -t ${keytype} -b ${length} -f ${keyfile} -C \"${keytype} ${length}\" -N \"\"",
            user    => 'puppet',
            group   => 'puppet',
            creates => $keyfile,
            before  => [ File[$keyfile], File["${keyfile}.pub"] ],
            require => File[$keydir],
        }
    } # if $ensure  == "present"
}
