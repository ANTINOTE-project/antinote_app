generate-code:
	sh protos/run.sh
	sh pigeons/run.sh

build-release-apk:
	./flutter/bin/flutter build apk --flavor=prod --split-per-abi --obfuscate --split-debug-info=./debug-info