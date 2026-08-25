generate-code:
	sh protos/run.sh
	sh pigeons/run.sh

build-release-apk:
	env ORG_GRADLE_PROJECT_dev.steenbakker.mobile_scanner.useUnbundled=false flutter build apk --flavor=prodindependent --split-per-abi --obfuscate --split-debug-info=./debug-info

build-playstore-release-apk:
	env ORG_GRADLE_PROJECT_dev.steenbakker.mobile_scanner.useUnbundled=true flutter build apk --flavor=prodplaystore --split-per-abi --obfuscate --split-debug-info=./debug-info

build-playstore-release-bundle:
	env ORG_GRADLE_PROJECT_dev.steenbakker.mobile_scanner.useUnbundled=true flutter build appbundle --flavor=prodplaystore --obfuscate --split-debug-info=./debug-info