import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  // MessageBubble que deve ser o primeiro da sequência.
  const MessageBubble.first({
    super.key,
    required this.userImage,
    required this.username,
    required this.message,
    required this.isMe,
  }) : isFirstInSequence = true;

  // MessageBubble continua a sequencia.
  const MessageBubble.next({
    super.key,
    required this.message,
    required this.isMe,
  }) : isFirstInSequence = false,
       userImage = null,
       username = null;

  // Se este MessageBubble é ou não o primeiro de uma sequência de mensagens
  // do mesmo usuário.
  // Modifica ligeiramente o MessageBubble para esses diferentes casos - apenas
  // mostra a imagem do usuário para a primeira mensagem do mesmo usuário e altera
  // o formato do balão para as mensagens subsequentes.
  final bool isFirstInSequence;

  // Imagem do usuário para ser exibida próxima ao balão.
  // Não é necessário se a mensagem não for a primeira da sequência.
  final String? userImage;

  // Nome de usuário.
  // Não é necessário se a mensagem não for a primeira da sequência.
  final String? username;
  final String message;

  // Controla como a MessageBubble será alinhada.
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        if (userImage != null)
          Positioned(
            top: 15,
            // Alinha a imagem do usuário à direita, se a mensagem for do usuário.
            right: isMe ? 0 : null,
            child: CircleAvatar(
              backgroundImage: NetworkImage(userImage!),
              backgroundColor: theme.colorScheme.primary.withAlpha(180),
              radius: 23,
            ),
          ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 46),
          child: Row(
            // Define a direção da mensagem.
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // A primeira mensagem da sequência tem um espaço visual no topo
                  if (isFirstInSequence) const SizedBox(height: 18),
                  if (username != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 13, right: 13),
                      child: Text(
                        username!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  // Caixa que envolve a mensagem.
                  Container(
                    decoration: BoxDecoration(
                      color:
                          isMe
                              ? Colors.grey[300]
                              : theme.colorScheme.secondary.withAlpha(200),
                      // Mostrar somente a "borda de fala" do BubbleMessage se for o primeiro
                      // na cadeia.
                      // Se a "caixa de fala" está à esquerda ou à direita depende
                      // se o BubbleMessage é ou não o usuário atual.
                      borderRadius: BorderRadius.only(
                        topLeft:
                            !isMe && isFirstInSequence
                                ? Radius.zero
                                : const Radius.circular(12),
                        topRight:
                            isMe && isFirstInSequence
                                ? Radius.zero
                                : const Radius.circular(12),
                        bottomLeft: const Radius.circular(12),
                        bottomRight: const Radius.circular(12),
                      ),
                    ),
                    constraints: const BoxConstraints(maxWidth: 200),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 12,
                    ),
                    child: Text(
                      message,
                      style: TextStyle(
                        height: 1.3,
                        color:
                            isMe
                                ? Colors.black87
                                : theme.colorScheme.onSecondary,
                      ),
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
