{ writeShellScriptBin }:

writeShellScriptBin "pynq-deploy" (builtins.readFile ./pynq_deploy.sh)
