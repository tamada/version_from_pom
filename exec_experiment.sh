#! /bin/bash

function usage() {
  echo "execute experiments. details are shown in https://tamada.github.io/blog/20211104-vfp"
  echo "$(basename $0) [OPTIONS]"
  echo "OPTIONS"
  echo "    -h      print this message."
  echo "    -c      clean the products"
  echo "    -C      clean all"
  echo "    -r      clean and re-build"
  echo "    -R      clean all and re-build"
}

function clean() {
  rm -rf classes2 META-INF
  rm -rf target/jmods
  rm -rf target/mods2
  rm -rf vfp-jar vfp-module vfp2-jar vfp2-module *.build_artifacts.txt
}

function clean_all() {
  clean
  mvn clean
}

function command_check() {
  if [[ $(which -s $1) -ne 0 ]]; then
    echo "$1: command not found"
    exit 1
  fi
}

function build_project() {
  mvn package
}

function build_jmod() {
  mkdir -p target/jmods
  if [[ ! -f target/jmods/vfp-1.0.0.jmod ]]; then
    jmod create --module-version 1.0.0 --class-path target/mods/vfp-1.0.0.jar target/jmods/vfp-1.0.0.jmod
  fi
}

function update_module_info() {
  cp -r target/classes ./classes2
  jar xf target/jmods/vfp-1.0.0.jmod classes/module-info.class
  cp classes/module-info.class classes2
}

function build_versioned_module_impl() {
  mkdir -p target/mods2
  jar xf target/mods/vfp-1.0.0.jar META-INF
  rm -rf classes2/META-INF
  cp -r META-INF classes2
  (cd classes2 ; jar cfM ../target/mods2/vfp2-1.0.0.jar META-INF/MANIFEST.MF *)
}

function cleanup() {
  rm -rf META_INF classes
}

function build_versioned_module() {
  build_jmod
  update_module_info
  build_versioned_module_impl
  cleanup
}

function build_native_image() {
  target=$1
  shift
  if [[ ! -f $target ]] ; then
    echo "native-image $@ $target"
    native-image $@ $target
  fi
}

function build_native_images() {
  build_native_image vfp-jar     -jar target/mods/vfp-1.0.0.jar
  build_native_image vfp-module  --module-path target/mods --module jp.cafebabe.vfp/jp.cafebabe.vfp.Main
  build_native_image vfp2-jar    -jar target/mods2/vfp-1.0.0.jar
  build_native_image vfp2-module --module-path target/mods2 --module jp.cafebabe.vfp/jp.cafebabe.vfp.Main
}

function build_targets() {
  build_versioned_module
  build_native_images
}

function init() {
  command_check mvn
  command_check jmod
  command_check native-image
  build_project
  build_targets
}

function perform() {
  echo "========== Plain =========="
  java -cp target/classes jp.cafebabe.vfp.Main
  echo "========== Jar =========="
  java -jar target/mods/vfp-1.0.0.jar
  echo "========== Module =========="
  java --module-path target/mods --module jp.cafebabe.vfp/jp.cafebabe.vfp.Main
  echo "========== Plain2 =========="
  java -cp classes2 jp.cafebabe.vfp.Main
  echo "========== Jar2 =========="
  java -jar target/mods2/vfp-1.0.0.jar
  echo "========== Module2 =========="
  java --module-path target/mods2 --module jp.cafebabe.vfp/jp.cafebabe.vfp.Main
  echo "========== Native-Jar =========="
  ./vfp-jar
  echo "========== Native-Module =========="
  ./vfp-module
  echo "========== Native-Jar2 =========="
  ./vfp2-jar
  echo "========== Native-Module2 =========="
  ./vf2-pmodule
}

function execute() {
  init
  perform
}

while getopts hcCrR OPT
do
  case $OPT in
      h) usage
         exit 0
         ;;
      c) clean
         exit 0
         ;;
      C) clean_all
         exit 0
         ;;
      r) clean
         execute
         exit 0
         ;;
      R) clean_all
         execute
         exit 0
         ;;
  esac
done

execute
