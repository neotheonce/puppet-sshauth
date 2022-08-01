# getent.rb
# Tue Dec 18 13:53:39 PST 2012
# agould@ucop.edu


require 'facter'

# Returns passwd entry for all users using "getent".
Facter.add(:getent_passwd) do
  if RUBY_VERSION < "1.9"
    users = ''
    %x{/usr/bin/getent passwd}.each do |n|
       users << n.chomp+'|'
    end
  else
    users = ''
    %x{/usr/bin/getent passwd}.each_line do |n|
       users << n.chomp+'|'
    end
  end
  setcode do
      users
  end
end

# Returns groups entry for all groups using "getent".
Facter.add(:getent_group) do
  if RUBY_VERSION < "1.9"
    groups = ''
    %x{/usr/bin/getent group}.each do |n|
       groups << n.chomp+'|'
    end
  else
    groups = ''
    %x{/usr/bin/getent group}.each_line do |n|
       groups << n.chomp+'|'
    end
  end
  setcode do
      groups
  end
end
