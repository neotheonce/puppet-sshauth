# = Define: sshauth::client
# Install generated key pairs onto clients
#
# === Provides:
# - Collect exported ssh client keys generated by sshauth::key
#
# === Parameters:
# All paramters are optionals.  Use these to override values set in sshauth::key.
# $ensure::	'present'(default) or 'absent'.  Create or remove the client keys.
# $user::	user account on client in which to install the ssh keys
# $filename::	alturnate name of ssh private key file.  public key is ${filename}.pub.
#
# === Usage:
#    
#   # Install keypair "unixsys" without overriding any original parameters
#   sshauth::client {"unixsys": }
#
#   # override $user parameter on this client
#   sshauth::client {"unixsys": user => 'agould' }
#
#   # override $user and $filename parameters.  This installs the 'unixsys'
#   # keypair into agould's account with alturnate keyname
#   sshauth::client {"unixsys": user => 'agould', filename => 'id_rsa-blee'}
#
#   # remove 'unixsys' keys from agould's account.
#   sshauth::client {"unixsys": user => 'agould', ensure => 'absent'}
#
define sshauth::client (
    String           $ensure   = 'present',
    Optional[String] $user     = undef,
    String           $filename = 'id_rsa',
) {

    $_tag = regsubst($name, '@', '_at_')

    # Override the defaults set in sshauth::key, as needed.

    # This is ugly, but we need to accomodate every permutation of the 
    # three params.  Otherwise override bahavior is unpredictible.
    #
    if ( $user and $ensure and $filename ) {
	#notify {"sshauth::client: user ensure filename":}
        Sshauth::Key::Client <<| tag == $_tag |>> {
            user        => $user,
            ensure      => $ensure,
            filename    => $filename,
        }

    } elsif ( $user and $ensure ) {
   	#notify {"sshauth::client: user and ensure":}
        Sshauth::Key::Client <<| tag == $_tag |>> {
            user        => $user,
            ensure      => $ensure,
        }

    } elsif ( $ensure and $filename ) {
  	#notify {"sshauth::client: ensure and filename":}
        Sshauth::Key::Client <<| tag == $_tag |>> {
            ensure      => $ensure,
            filename     => $filename,
        }

    } elsif ( $user and $filename ) {
  	#notify {"sshauth::client: user and filename":}
        Sshauth::Key::Client <<| tag == $_tag |>> {
            user      => $user,
            filename     => $filename,
        }

    } elsif ( $user ) {
 	#notify {"sshauth::client: user only":}
        Sshauth::Key::Client <<| tag == $_tag |>> {
            user      => $user,
        }

    } elsif ( $ensure ) {
	#notify {"sshauth::client: ensure only":}
        Sshauth::Key::Client <<| tag == $_tag |>> {
            ensure      => $ensure,
        }

    } elsif ( $filename ) {
 	#notify {"sshauth::client: filename only":}
        Sshauth::Key::Client <<| tag == $_tag |>> {
            filename      => $filename,
        }

    } else {
	#notify {"sshauth::client: default":}
        Sshauth::Key::Client <<| tag == $_tag |>>
    }

}
