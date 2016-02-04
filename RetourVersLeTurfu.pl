#!/usr/bin/perl

use Getopt::Long;
use POSIX qw/strftime/;

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
  "backup" => \$backup,
  "logs" => \$logs
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
  elsif ($logs) {
    logs();
  }

  exit 1;
}

# Lancement du daemon
sub start {
  die "Démon déjà lancé.\n" if daemonExists();
  writeLog("Lancement du démon...");
  checkPath();
  loadConfig();
  addLine(".retourVersLeTurfu", "test");
  print $confs{"dir"},"\n";
  print $confs{"interval"},"\n";
  print $confs{"path"},"\n";
  print "Démon lancé.\n";
  writeLog("Démon lancé.");
}

# Arret du daemon
sub stop {
  unlink ".retourVersLeTurfu" or die "unlink : $!";
  print "Démon arrêté.\n";
  writeLog("Démon arrêté");
}

# Récupération de sauvegarde
sub backup {
  print "fonction backup à implémenter\n";
  writeLog("Sauvegarde backupé");
}

# Affiche les logs
sub logs {
  die "Logs introuvables : $!" if (! -e "retourVersLeTurfu.log");
  open(FIC, "<retourVersLeTurfu.log") or die "open : $!";
  print <FIC>;
  close(FIC);
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
    writeLog("Configuration chargé");
  }
}

# Ecrit dans le fichier de config
sub writeConfig {
  my $dir = shift();
  chomp($dir);
  my $interval = shift();
  chomp($interval);
  my $path = shift();
  chomp($path);
  my $chaine = $dir.":".$interval.":".$path."\n" ;
  open(FIC, ">retourVersLeTurfu.conf") or die "open : $!";
  print FIC $chaine;
  close(FIC);
  writeLog("Configuration modifié");
}

# Vérifie si le démon existe
sub daemonExists {
  return -e ".retourVersLeTurfu";
}

# Ecrit dans le fichier de logs
sub writeLog
{
  addLine("retourVersLeTurfu.log","Création fichier de log") if (! -e "retourVersLeTurfu.log");
  my $line = $_[0];
  addLine("retourVersLeTurfu.log", $line);
}

# Ajoute un ligne à un fichier
sub addLine
{
  open(FIC, ">>", $_[0]) or die "open : $!";
  print FIC dateFormat(), " ", $_[1], "\n";
  close(FIC);
}

# Met en forme la date
sub dateFormat
{
  return strftime('%Y-%m-%d %H:%M:%S',localtime);
}
