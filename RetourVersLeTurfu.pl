#!/usr/bin/perl

use Getopt::Long;

%confs;
$confs{"dir"}="/home";
$confs{"interval"}="300";
$confs{"path"}="/srv/backup/";

checkParameter();

# Verifie les paramétres
sub checkParameter {
  GetOptions(
  "start" => \$start,
  "stop" => \$stop,
  "config" => \$config,
  "backup" => \$backup
  )
  or die ("Parametre(s) incorrect : Pour plus d'informations, lire le fichier README.md\n");

  if ($start) {
    start();
  }

  elsif ($stop) {
    stop();
  }

  elsif ($backup) {
    backup();
  }

  elsif ($config) {
    config();
  }

  exit 1;
}

# Lancement du daemon
sub start {
  die "Démon déjà lancé.\n" if daemonExists();
  checkPath();
  loadConfig();
  open(FILE,">>.retourVersLeTurfu") or die "open : $!";
  close(FILE);
  print $confs{"dir"},"\n";
  print $confs{"interval"},"\n";
  print $confs{"path"},"\n";
  print "Démon lancé.\n";
}

# Arret du daemon
sub stop {
  unlink ".retourVersLeTurfu" or die "unlink : $!";
  print "Démon arrêté.\n";
}

# Récupération de sauvegarde
sub backup {
  print "fonction backup à implémenter\n";
}

# Configure le système de backup
sub config {
  my %config;
  print "Repertoire à sauvegarder :\n";
  $config[0] = <STDIN>;
  print "Intervalle de sauvegarde :\n";
  $config[1] = <STDIN>;
  print "Repertoire de sauvegarde sur le serveur de sauvegarde :\n";
  $config[2] = <STDIN>;
  chomp(%config);
  writeConfig($config[0],$config[1],$config[2]);
}

# Vérifie si le $path existe bien, sinon le créé
sub checkPath {
  if (! -d $confs{"path"}) {
    mkdir $confs{"path"} or die "mkdir : $!";
  }
}

# Charge le fichier de config
sub loadConfig {
  if (-f "retourVersLeTurfu.conf") {
    open(FIC, "retourVersLeTurfu.conf") or die "open : $!";
    while(<FIC>) {
      my @list = split(':');
      $confs{"dir"}=$list[0];
      $confs{"interval"}=$list[1];
      $confs{"path"}=$list[2];
    }
    close(FIC);
  }
}

# Ecrit dans le fichier de config
sub writeConfig {
  my $dir = shift();
  my $interval = shift();
  my $path = shift();
  my $chaine = $dir.":".$interval.":".$path."\n" ;
  open(FIC, ">retourVersLeTurfu.conf") or die "open : $!";
  print FIC $chaine;
  close(FIC);
}

# Vérifie si le démon existe
sub daemonExists {
  return -e ".retourVersLeTurfu";
}
