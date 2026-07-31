import 'package:antinote/antinote.dart';
import 'package:antinote_app/protos/account.pb.dart';
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
              tokenCredentials.unpackInto(
                SerializedTokenCredentials.getDefault(),
              ),
            ),
          _
              when tokenCredentials.canUnpackInto(
                SerializedPasswordCredentials.getDefault(),
              ) =>
            PasswordCredentials.restore(
              tokenCredentials.unpackInto(
                SerializedPasswordCredentials.getDefault(),
              ),
            ),
          _ => throw UnimplementedError(
            'Unknown credentials type: ${tokenCredentials.typeUrl}',
          ),
        };
}

extension SetCredentials on AntinoteAccount {
  AntinoteAccount setCredentials(Credentials credentials) => deepCopy()
    ..tokenCredentials = Any.pack(
      (credentials as SerializableObject).serialize(),
      typeUrlPrefix: 'antinote',
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
          tokenCredentials: Any.pack(serialize(), typeUrlPrefix: 'antinote'),
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
          tokenCredentials: Any.pack(serialize(), typeUrlPrefix: 'antinote'),
        ),
      _ => throw UnimplementedError('Unknown credentials type: $runtimeType'),
    };
  }
}
