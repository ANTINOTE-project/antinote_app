import 'package:antinote/antinote.dart';
import 'package:antinote_app/protos/account.pb.dart';
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart';
import 'package:uuid/v4.dart';

extension LoadCredentials on AntinoteAccount {
  TokenCredentials? get credentials => !hasTokenCredentials()
      ? null
      : TokenCredentials.restore(
          tokenCredentials.unpackInto(SerializedTokenCredentials.create()),
        );
}

extension SetCredentials on AntinoteAccount {
  AntinoteAccount setCredentials(TokenCredentials credentials) => deepCopy()
    ..tokenCredentials = Any.pack(
      credentials.serialize(),
      typeUrlPrefix: 'antinote',
    )
    ..freeze();
}

extension CredentialsAsAntinoteAccount on TokenCredentials {
  AntinoteAccount asAntinoteAccount(RemoteSession session) {
    return AntinoteAccount(
      uid: const UuidV4().generate(),
      name: session.user.name,
      username: username,
      establishmentName: session.anyInstance.establishmentName.trim(),
      baseUrl: baseUrl.toString(),
      workspaceName: workspace.label,
      tokenCredentials: Any.pack(serialize(), typeUrlPrefix: 'antinote'),
    );
  }
}
