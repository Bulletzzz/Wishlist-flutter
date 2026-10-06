import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/wishlist_provider.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});
  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final _name = TextEditingController();
  final _nameFocus = FocusNode();
  final _scroll = ScrollController();
  BookCategory? _editing;
  String? _error, _status;

  @override
  void dispose() {
    _name.dispose();
    _nameFocus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _clear() {
    _name.clear();
    setState(() {
      _editing = null;
      _error = null;
    });
  }

  void _save(WishlistProvider wishlist) {
    final name = _name.text.trim();
    setState(() {
      _error = name.isEmpty ? 'Informe o nome da categoria.' : null;
      _status = null;
    });
    if (_error != null) {
      _nameFocus.requestFocus();
      return;
    }
    final editing = _editing != null;
    if (editing) {
      wishlist.editCategory(_editing!, name);
    } else {
      wishlist.addCategory(BookCategory(name: name));
    }
    _clear();
    setState(
      () =>
          _status = editing ? 'Categoria atualizada.' : 'Categoria adicionada.',
    );
    _nameFocus.requestFocus();
  }

  void _edit(BookCategory category) {
    _name.text = category.name;
    setState(() {
      _editing = category;
      _error = null;
      _status = null;
    });
    if (_scroll.hasClients) {
      _scroll.animateTo(
        0,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
    _nameFocus.requestFocus();
  }

  Widget _form(WishlistProvider wishlist) {
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Card(
        semanticContainer: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  _editing == null ? 'Uma nova categoria' : 'Editar categoria',
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Use um nome que ajude a encontrar suas próximas leituras.',
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _name,
                focusNode: _nameFocus,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(wishlist),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                decoration: InputDecoration(
                  labelText: 'Nome da categoria (obrigatório)',
                  errorText: _error,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _save(wishlist),
                icon: Icon(_editing == null ? Icons.add : Icons.check),
                label: Text(
                  _editing == null ? 'Adicionar categoria' : 'Salvar categoria',
                ),
              ),
              if (_editing != null) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    _clear();
                    setState(() => _status = 'Edição cancelada.');
                    _nameFocus.requestFocus();
                  },
                  child: const Text('Cancelar'),
                ),
              ],
              if (_status != null) ...[
                const SizedBox(height: 16),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _status!,
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _collection(WishlistProvider wishlist) {
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text('Suas categorias', style: theme.textTheme.titleLarge),
          ),
          const SizedBox(height: 8),
          const Text('Um lugar para cada universo de leitura.'),
          const SizedBox(height: 20),
          if (wishlist.categories.isEmpty)
            Card(
              semanticContainer: false,
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    ExcludeSemantics(
                      child: Icon(
                        Icons.bookmarks_outlined,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Organize do seu jeito',
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Crie sua primeira categoria, como Romance ou Fantasia.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          for (final category in wishlist.categories) ...[
            Card(
              semanticContainer: false,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        category.name,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        Tooltip(
                          message: 'Editar categoria',
                          child: OutlinedButton.icon(
                            onPressed: () => _edit(category),
                            icon: const Icon(Icons.edit_outlined),
                            label: Text(
                              'Editar',
                              semanticsLabel:
                                  'Editar categoria ${category.name}',
                            ),
                          ),
                        ),
                        Tooltip(
                          message: 'Excluir categoria',
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: theme.colorScheme.error,
                            ),
                            onPressed: () {
                              wishlist.removeCategory(category);
                              if (_editing == category) _clear();
                              setState(
                                () => _status =
                                    'Categoria ${category.name} excluída. Os livros foram mantidos sem categoria.',
                              );
                            },
                            icon: const Icon(Icons.delete_outline),
                            label: Text(
                              'Excluir',
                              semanticsLabel:
                                  'Excluir categoria ${category.name}',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Voltar à lista de desejos',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Categorias'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 850;
                return FocusTraversalGroup(
                  child: ListView(
                    controller: _scroll,
                    padding: EdgeInsets.all(
                      constraints.maxWidth < 500 ? 16 : 32,
                    ),
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          'Cada história no seu lugar.',
                          style: theme.textTheme.headlineMedium,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Crie e edite categorias para organizar os livros da sua lista de desejos.',
                      ),
                      const SizedBox(height: 28),
                      if (wide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 4, child: _form(wishlist)),
                            const SizedBox(width: 28),
                            Expanded(flex: 6, child: _collection(wishlist)),
                          ],
                        )
                      else ...[
                        _form(wishlist),
                        const SizedBox(height: 28),
                        _collection(wishlist),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
