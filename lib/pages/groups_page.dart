import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../widgets/universal_image.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  // criar ou editar
  void _showGroupDialog(BuildContext context,
      {String? docId, String? currentName, String? currentDesc}) {
    final nameController = TextEditingController(text: currentName);
    final descController = TextEditingController(text: currentDesc);
    final isEditing = docId != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar Grupo' : 'Novo Grupo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Nome do Grupo'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(hintText: 'Descrição'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                if (isEditing) {
                  // ATUALIZAR
                  FirestoreService().updateGroup(
                      docId, nameController.text, descController.text);
                } else {
                  // CRIAR
                  final user = FirebaseAuth.instance.currentUser;
                  FirestoreService().createGroup(nameController.text,
                      descController.text, user?.uid ?? 'anonimo');
                }
                Navigator.pop(context);
              }
            },
            child: Text(isEditing ? 'Salvar' : 'Criar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grupos de Leitura',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.black),
            onPressed: () => _showGroupDialog(context),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getGroupsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(child: Text('Erro ao carregar grupos.'));
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('Nenhum grupo criado ainda.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final isOwner = data['ownerId'] == currentUserId;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: ClipOval(
                    child: UniversalImage(
                        imageUrl: data['imageUrl'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover),
                  ),
                  title: Text(data['name'] ?? 'Grupo',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(data['description'] ?? ''),

                  // botão editar ou excluir
                  trailing: isOwner
                      ? PopupMenuButton(
                          icon: const Icon(Icons.more_vert),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(children: [
                                Icon(Icons.edit, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('Editar')
                              ]),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Excluir',
                                    style: TextStyle(color: Colors.red))
                              ]),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'delete') {
                              service.deleteGroup(doc.id);
                            } else if (value == 'edit') {
                              _showGroupDialog(context,
                                  docId: doc.id,
                                  currentName: data['name'],
                                  currentDesc: data['description']);
                            }
                          },
                        )
                      : const Icon(Icons.chevron_right),

                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Entrando no grupo...')));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
