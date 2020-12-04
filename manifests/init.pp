# See README.md for usage information
define nvm (
  $user                = $title,
  $home                = undef,
  $nvm_dir             = undef,
  $profile_path        = undef,
  $install_node        = undef,
  $manage_dependencies = true,
  $manage_profile      = true,
  $manage_user         = false,
  $node_instances      = {},
  $nvm_repo            = 'https://github.com/nvm-sh/nvm.git',
  $refetch             = false,
  $version             = 'v0.37.2',
) {

  if $home == undef and $user == 'root' {
    $final_home = '/root'
  }
  elsif $home == undef {
    $final_home = "/home/${user}"
  }
  else {
    $final_home = $home
  }

  if $nvm_dir == undef {
    $final_nvm_dir = "/home/${user}/.nvm"
  }
  else {
    $final_nvm_dir = $nvm_dir
  }

  if $profile_path == undef {
    $final_profile_path = "/home/${user}/.bashrc"
  }
  else {
    $final_profile_path = $profile_path
  }

  # FIXME needs syntax update
  #  validate_string($user)
  #  validate_string($final_home)
  #  validate_string($final_nvm_dir)
  #  validate_string($final_profile_path)
  #  validate_string($version)
  #  validate_bool($manage_user)
  #  validate_bool($manage_dependencies)
  #  validate_bool($manage_profile)
  #  if $install_node {
  #    validate_string($install_node)
  #  }
  #  validate_hash($node_instances)

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  if $manage_dependencies {
    $nvm_install_require = Package['git','wget','make']
    ensure_packages(['git', 'wget', 'make'])
  }
  else {
    $nvm_install_require = undef
  }

  if $manage_user {
    user { $user:
      ensure     => present,
      home       => $final_home,
      managehome => true,
      before     => Nvm::Install[$user]
    }
  }

  nvm::install { $user:
    user         => $user,
    home         => $final_home,
    version      => $version,
    nvm_dir      => $final_nvm_dir,
    nvm_repo     => $nvm_repo,
    dependencies => $nvm_install_require,
    refetch      => $refetch,
  }

  if $manage_profile {

    #   if !defined(File[$final_profile_path]) {
    file { $final_profile_path:
      ensure => 'present',
      path   => $final_profile_path,
      owner  => $user,
    }
    #   }

    file_line { "add NVM_DIR to $user profile file":
      path    => $final_profile_path,
      line    => "export NVM_DIR=${final_nvm_dir}",
      require => File[$final_profile_path],
    } ->

    file_line { "add . ~/.nvm/nvm.sh to $user profile file":
      path => $final_profile_path,
      line => "[ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\"  # This loads nvm",
    }
  }

  if $install_node {
    $final_node_instances = merge($node_instances, {
      "${install_node}" => {
        set_default => true,
      },
      })
  }
  else {
    $final_node_instances = $node_instances
  }

  create_resources(::nvm::node::install, $final_node_instances, {
    user        => $user,
    nvm_dir     => $final_nvm_dir,
    })

}
