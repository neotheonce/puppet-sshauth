module Puppet::Parser::Functions
  newfunction(
    :gethomedir, 
    :type => :rvalue, 
    :doc => "Returns home directory name of user specified in args[0]"
  ) do |args|

    # get fact getent_passwd and convert it into hash of user entries
    dirs={}
    entires = lookupvar('getent_passwd').split('|')
    entires.each do |item|
      user,pw,uid,gid,gecos,homedir,shell = item.split(':')
      dirs[user] = homedir ? homedir : ""
    end

    # make sure args[0] is a strings
    if args[0].is_a?(String)
      dirs[args[0]]

    else 
      Puppet.warning "gethomedir: usage: gethomedir( user )"
      nil

    end
  end

end

