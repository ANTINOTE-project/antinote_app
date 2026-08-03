import 'package:antinote/antinote.dart';
import 'package:antinote_app/data/protos/account.pb.dart';
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart';
import 'package:uuid/v4.dart';

extension LoadCredentials on AntinoteAccount {
  Credentials? get credentials => !hasTokenCredentials()
      ? null
      : switch (tokenCredentials) {
          _
              when tokenCredentials.canUnpackInto(
                SerializedTokenCredentials.getDefault(),
              ) =>
            TokenCredentials.restore(
              tokenCredentials.unpackInto(SerializedTokenCredentials.create()),
            ),
          _
              when tokenCredentials.canUnpackInto(
                SerializedPasswordCredentials.getDefault(),
              ) =>
            PasswordCredentials.restore(
              tokenCredentials.unpackInto(
                SerializedPasswordCredentials.create(),
              ),
            ),
          _ => throw UnimplementedError(
            'Unknown credentials type: ${tokenCredentials.typeUrl}',
          ),
        };
}

const _prefix = 'antinote';

extension SetCredentials on AntinoteAccount {
  AntinoteAccount setCredentials(Credentials credentials) => deepCopy()
    ..tokenCredentials = Any.pack(
      (credentials as SerializableObject).serialize(),
      typeUrlPrefix: _prefix,
    )
    ..freeze();
}

extension CredentialsAsAntinoteAccount on Credentials {
  AntinoteAccount asAntinoteAccount(RemoteSession session) {
    return switch (this) {
      TokenCredentials(
        username: final username,
        baseUrl: final baseUrl,
        workspace: final workspace,
        serialize: final serialize,
      ) =>
        AntinoteAccount(
          uid: const UuidV4().generate(),
          name: session.user.name,
          username: username,
          establishmentName: session.anyInstance.establishmentName.trim(),
          baseUrl: baseUrl.toString(),
          workspaceName: workspace.label,
          tokenCredentials: Any.pack(serialize(), typeUrlPrefix: _prefix),
        ),
      PasswordCredentials(
        username: final username,
        baseUrl: final baseUrl,
        workspace: final workspace,
        serialize: final serialize,
      ) =>
        AntinoteAccount(
          uid: const UuidV4().generate(),
          name: session.user.name,
          username: username,
          establishmentName: session.anyInstance.establishmentName.trim(),
          baseUrl: baseUrl.toString(),
          workspaceName: workspace.label,
          tokenCredentials: Any.pack(serialize(), typeUrlPrefix: _prefix),
        ),
      _ => throw UnimplementedError('Unknown credentials type: $runtimeType'),
    };
  }
}
