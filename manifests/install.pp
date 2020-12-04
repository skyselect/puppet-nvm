# See README.md for usage information
define nvm::install (
  $user,
  $home,
  $version,
  $nvm_dir,
  $nvm_repo,
  $dependencies,
  $refetch,
) {

  exec { "git clone ${nvm_repo} ${nvm_dir} #$user":
    command => "git clone ${nvm_repo} ${nvm_dir}",
    cwd     => $home,
    user    => 'root',
    unless  => "/usr/bin/test -d ${nvm_dir}/.git",
    require => $dependencies,
    notify  => Exec["git checkout ${nvm_repo} ${version} #$user"],
  }

  if $refetch {
    exec { "git fetch ${nvm_repo} ${nvm_dir} #$user":
      command => 'git fetch',
      cwd     => $nvm_dir,
      user    => 'root',
      require => Exec["git clone ${nvm_repo} ${nvm_dir}"],
      notify  => Exec["git checkout ${nvm_repo} ${version} #$user"],
    }
  }

  exec { "git checkout ${nvm_repo} ${version} #$user":
    command     => "git checkout --quiet ${version}",
    cwd         => $nvm_dir,
    user        => 'root',
    refreshonly => true,
    notify      => Exec["chown -R $user $nvm_dir"],
  }

  exec { "chown -R $user $nvm_dir":
    command     => "chown -R ${user} ${nvm_dir}",
    cwd         => $nvm_dir,
    user        => 'root',
    refreshonly => true,
  }

}
